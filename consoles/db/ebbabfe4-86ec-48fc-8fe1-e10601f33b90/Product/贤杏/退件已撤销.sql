select
    pi.customary_pno 正向运单号
    ,pi.pno 退件运单号
    ,pi.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,case pi2.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 正向包裹状态
    ,ss.name 退件揽收网点
    ,case pi2.cod_enabled
        when 0 then '否'
        when 1 then '是'
    end 是否COD
    ,pi2.cod_amount/100 COD金额
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 退件揽收时间
from my_staging.parcel_info pi
left join my_staging.parcel_info pi2 on pi.customary_pno = pi2.pno
left join my_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join my_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
where
    pi.returned = 1
    and pi.state = 9
    and pi.created_at > '2023-12-31 16:00:00'
    and pi.created_at < '2024-05-31 16:00:00'

;

with t as
    (
        select
            pi.customary_pno forward_pno
            ,pi.pno return_pno
            ,pi.client_id
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end as  client_type
            ,case pi2.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end as parcel_state
            ,ss.name return_pick_store
            ,case pi2.cod_enabled
                when 0 then '否'
                when 1 then '是'
            end cod_or_not
            ,pi2.cod_amount/100 cod
            ,convert_tz(pi.created_at, '+00:00', '+08:00') return_pick_time
        from my_staging.parcel_info pi
        left join my_staging.parcel_info pi2 on pi.customary_pno = pi2.pno
        left join my_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
        left join my_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        where
            pi.returned = 1
            and pi.state = 9
            and pi.created_at > '2023-12-31 16:00:00'
            and pi.created_at < '2024-05-31 16:00:00'
    )
, pn as
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,pr.remark
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from my_staging.parcel_route pr
                join t t1 on t1.forward_pno = pr.pno
                where
                    pr.route_action = 'PENDING_RETURN'
                    and pr.routed_at > '2023-10-01'
            ) a
        where
            a.rk = 1
    )
, mark as
    (
        select
            pn.pno
            ,ddd.cn_element
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join pn on pn.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.routed_at > '2023-10-01'
            and pr.routed_at < pn.routed_at
    )
select
    t1.forward_pno 正向单号
    ,t1.return_pno 退件单号
    ,t1.client_id 客户ID
    ,t1.client_type 客户类型
    ,t1.parcel_state 正向包裹状态
    ,t1.return_pick_store 退件揽收网点
    ,t1.cod_or_not 是否cod
    ,t1.cod cod金额
    ,t1.return_pick_time 退件揽收时间
    ,dai.delivery_attempt_num 正向包裹尝试派送次数
    ,p1.remark 待退件备注
    ,di.cn_element 待退件前的最后一次提交的疑难件类型
    ,m1.cn_element 待退件前最近一次派件标记原因
    ,m2.cn_element 待退件前倒数第2次派件标记原因
    ,m3.cn_element 待退件前倒数第3次派件标记原因
    ,m4.cn_element 待退件前倒数第4次派件标记原因
    ,ss.sct_state 闪速判案结果
from t t1
left join my_staging.delivery_attempt_info dai on dai.pno = t1.forward_pno
left join pn p1 on p1.pno = t1.forward_pno
left join
    (
        select
            t1.pno
            ,ddd.cn_element
            ,row_number() over (partition by di.pno order by di.created_at desc) rk
        from my_staging.diff_info di
        join pn t1 on t1.pno = di.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            di.created_at > '2023-10-01'
            and di.created_at < t1.routed_at
    ) di on di.pno = t1.forward_pno and di.rk = 1
left join mark m1 on m1.pno = t1.forward_pno and m1.rk = 1
left join mark m2 on m2.pno = t1.forward_pno and m2.rk = 2
left join mark m3 on m3.pno = t1.forward_pno and m3.rk = 3
left join mark m4 on m4.pno = t1.forward_pno and m4.rk = 4
left join
    (
        select
            t1.forward_pno
            ,case sct.state
                when 1 then '待处理'
                when 2 then '不属实'
                when 3 then '属实'
                when 4 then '待处理-联系不到客户'
                when 5 then '已处理-联系不到客户'
            end sct_state
        from my_bi.ss_court_task sct
        join t t1 on t1.forward_pno = sct.pno
        where
            sct.created_at > '2023-10-01'
    ) ss on ss.forward_pno = t1.forward_pno



