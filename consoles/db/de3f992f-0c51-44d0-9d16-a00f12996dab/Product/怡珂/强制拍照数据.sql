-- L 来源滞留的丢失率

with t as
    (
         select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.store_name
                    ,convert_tz(pr.routed_at, '+00:00', '+07:00') pr_time
                    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
                from rot_pro.parcel_route pr
                where
                    pr.route_action = 'TAKE_PHOTO'
                    and pr.routed_at > '2023-10-31 17:00:00'
                    and pr.routed_at < '2023-11-15 17:00:00'
                    and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3 -- 滞留拍照
            ) a
        where
            a.rk = 1
    )
select
    t1.pno
    ,t1.store_name 网点
    ,if(awl.store_id is not null , '是', '否') 是否爆仓
    ,t1.pr_date 拍照日期
    ,pi.cod_amount/100 cod
    ,if(pi.cod_enabled = 1, '是', '否') 是否cod
    ,datediff(t1.pr_date, ps.first_valid_routed_at) 滞留天数
from  t t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join nl_production.abnormal_white_list awl on awl.store_id = t1.store_id and awl.type = 2 and t1.pr_date >= awl.start_date and t1.pr_date <= awl.end_date
left join
    (
        select
            t1.pno
            ,t1.store_id
            ,pssn.first_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.first_valid_routed_at desc) rk
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno and t1.store_id = pssn.store_id
        where
            pssn.created_at >= '2023-10-20'
    ) ps on ps.pno = t1.pno and ps.store_id = t1.store_id and ps.rk = 1

;
-- 交接分布
with t as
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at  routed_time
            ,convert_tz(pr.routed_at, '+00:00', '+07:00') pr_time
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'TAKE_PHOTO'
            and pr.routed_at > '2023-10-31 17:00:00'
            and pr.routed_at < '2023-11-15 17:00:00'
            and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3 -- 滞留拍照
    )
select
    a2.pno
    ,a2.pr_date 拍照日期
    ,convert_tz(a2.scan_at, '+00:00', '+07:00') 交接时间
from
    (
        select
            a1.pno
            ,a1.pr_date
            ,pr.routed_at scan_at
            ,row_number() over (partition by a1.pno order by pr.routed_at desc ) rk
        from rot_pro.parcel_route pr
        join
            (
                select
                    a.pno
                    ,a.pr_time
                    ,a.pr_date
                    ,a.routed_at
                from
                    (
                        select
                            t1.*
                            ,convert_tz(pr.routed_at, '+00:00', '+07:00') force_time
                            ,pr.routed_at
                            ,pr.remark
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk2
                        from rot_pro.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'FORCE_TAKE_PHOTO'
                            and pr.routed_at > '2023-10-31 17:00:00'
                            and pr.routed_at < '2023-11-15 17:00:00'
                            and pr.routed_at < t1.routed_time
                    ) a
                where
                    a.rk2 = 1
                    and a.remark = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a1 on a1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at > '2023-10-31 17:00:00'
            and pr.routed_at < '2023-11-15 17:00:00'
            and pr.routed_at < a1.routed_at
    ) a2
where
    a2.rk = 1



;

select
    plt.id
    ,plt.pno
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 判责状态
    ,if(plt.state = 6 and plt.duty_result = 1, '是', '否') 是否判责丢失
    ,if(pr.pno is not null, '是', '否' ) 是否找回
    ,pr.CN_element 最新有效路由
    ,pr.store_name 最新有效路由网点
from bi_pro.parcel_lose_task plt
left join
    (
        select
            pr2.pno
            ,pr2.route_action
            ,pr2.store_name
            ,ddd.CN_element
            ,row_number() over (partition by pr2.pno order by pr2.routed_at desc ) rk
        from rot_pro.parcel_route pr2
        join bi_pro.parcel_lose_task plt on plt.pno = pr2.pno and plt.state = 6 and plt.duty_result = 1
        left join dwm.dwd_dim_dict ddd on ddd.element = pr2.route_action and ddd.db = 'rot_pro' and ddd.fieldname = 'route_action'
        where
            pr2.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr2.routed_at > date_sub(plt.updated_at, interval 7 hour)
            and plt.created_at >= '2023-11-01'
            and plt.created_at < '2023-11-16'
            and pr2.routed_at > '2023-10-31 17:00:00'
    ) pr on pr.pno = plt.pno and pr.rk = 1
where
    plt.source = 12
    and plt.created_at >= '2023-11-01'
    and plt.created_at < '2023-11-16'




;
-- 打印面单
with t as
    (

        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at  routed_time
            ,convert_tz(pr.routed_at, '+00:00', '+07:00') pr_time
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'TAKE_PHOTO'
            and pr.routed_at > '2023-10-31 17:00:00'
            and pr.routed_at < '2023-11-15 17:00:00'
            and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 1
    )
select
    a3.*
from
    (

        select
            a2.pno
            ,pr.store_id 路由发生网点id
            ,pr.store_name 路由发生网点
            ,a2.remark 路由
            ,convert_tz(pr.routed_at, '+00:00', '+07:00') 路由发生时间
            ,case
                when pr.store_id = pi.ticket_pickup_store_id then '揽收'
                when pr.store_id = pi.dst_store_id then '派送'
                else '中转'
            end 环节
            ,if(pi.returned = 1, '逆向', '正向') 正逆向
            ,row_number() over (partition by a2.pno,a2.remark order by pr.routed_at desc) rk
        from
            (
                select
                    a1.pno
                    ,a1.remark
                    ,a1.store_id
                    ,a1.routed_at force_time
                from
                    (
                        select
                            t1.pno
                            ,pr.routed_at
                            ,pr.store_id
                            ,pr.store_name
                            ,pr.remark
                            ,row_number() over (partition by t1.pno order by pr.routed_at desc ) rk
                        from rot_pro.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'FORCE_TAKE_PHOTO'
                            and pr.routed_at > '2023-10-31 17:00:00'
                            and pr.routed_at < '2023-11-15 17:00:00'
                            and pr.routed_at < t1.routed_time
                    ) a1
                where
                    a1.rk = 1
                    and a1.remark in ('SHIPMENT_WAREHOUSE_SCAN', 'RECEIVE_WAREHOUSE_SCAN', 'REPLACE_PNO')
            ) a2
        join rot_pro.parcel_route pr on a2.pno = pr.pno and a2.store_id = pr.store_id and a2.remark = pr.route_action
        left join fle_staging.parcel_info pi on pi.pno = a2.pno and pi.created_at > '2023-10-01'
        where
            pr.routed_at > '2023-10-31 17:00:00'
            and pr.routed_at < '2023-11-15 17:00:00'
            and pr.routed_at < a2.force_time
    ) a3
where
    a3.rk = 1


;

with t as
    (

        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at  routed_time
            ,convert_tz(pr.routed_at, '+00:00', '+07:00') pr_time
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'TAKE_PHOTO'
            and pr.routed_at > '2023-10-31 17:00:00'
            and pr.routed_at < '2023-11-15 17:00:00'
            and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 1
    )

select
    a3.*
from
    (
        select
            a2.pno
            ,ddd.CN_element
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from
            (
                select
                    a1.pno
                    ,a1.remark
                    ,a1.store_id
                    ,a1.routed_at force_time
                from
                    (
                        select
                            t1.pno
                            ,pr.routed_at
                            ,pr.store_id
                            ,pr.store_name
                            ,pr.remark
                            ,row_number() over (partition by t1.pno order by pr.routed_at desc ) rk
                        from rot_pro.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'FORCE_TAKE_PHOTO'
                            and pr.routed_at > '2023-10-31 17:00:00'
                            and pr.routed_at < '2023-11-15 17:00:00'
                            and pr.routed_at < t1.routed_time
                    ) a1
                where
                    a1.rk = 1
                    and a1.remark in ('DIFFICULTY_HANDOVER')
            ) a2
        join rot_pro.parcel_route pr on a2.pno = pr.pno and a2.store_id = pr.store_id and a2.remark = pr.route_action
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.routed_at > '2023-10-31 17:00:00'
            and pr.routed_at < '2023-11-15 17:00:00'
            and pr.routed_at < a2.force_time
    ) a3
where
    a3.rk = 1

;


with t as
    (

        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at  routed_time
            ,convert_tz(pr.routed_at, '+00:00', '+07:00') pr_time
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'TAKE_PHOTO'
            and pr.routed_at > '2023-10-31 17:00:00'
            and pr.routed_at < '2023-11-15 17:00:00'
            and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 1
    )

select
    a3.pno
    ,a3.pr_date 日期
    ,if(awl.store_id is not null , '是', '否') 当日是否爆仓
from
    (
        select
            a2.pno
            ,a2.store_id
            ,a2.pr_date
            ,ddd.CN_element
            ,row_number() over (partition by pr.pno,pr.route_action order by pr.routed_at desc) rk
        from
            (
                select
                    a1.pno
                    ,a1.remark
                    ,a1.pr_date
                    ,a1.store_id
                    ,a1.routed_at force_time
                from
                    (
                        select
                            t1.pno
                            ,t1.pr_date
                            ,pr.routed_at
                            ,pr.store_id
                            ,pr.store_name
                            ,pr.remark
                            ,row_number() over (partition by t1.pno order by pr.routed_at desc ) rk
                        from rot_pro.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'FORCE_TAKE_PHOTO'
                            and pr.routed_at > '2023-10-31 17:00:00'
                            and pr.routed_at < '2023-11-15 17:00:00'
                            and pr.routed_at < t1.routed_time
                    ) a1
                where
                    a1.rk = 1
                    and a1.remark in ('DETAIN_WAREHOUSE', 'DELIVERY_TICKET_CREATION_SCAN')
            ) a2
        join rot_pro.parcel_route pr on a2.pno = pr.pno and a2.store_id = pr.store_id and a2.remark = pr.route_action
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.routed_at > '2023-10-31 17:00:00'
            and pr.routed_at < '2023-11-15 17:00:00'
            and pr.routed_at < a2.force_time
    ) a3
left join nl_production.abnormal_white_list awl on awl.store_id = a3.store_id and  awl.type = 2 and awl.start_date <= a3.pr_date and a3.pr_date <= awl.end_date
where
    a3.rk = 1

