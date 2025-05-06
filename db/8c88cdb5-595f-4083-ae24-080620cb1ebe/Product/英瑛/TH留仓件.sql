with t as
    ( -- 普通KA
        select
            ppd.pno
            ,pi.client_id
            ,pi.state
            ,pi.created_at
            ,count(distinct ppd.id) ppd_cnt
        from fle_staging.parcel_problem_detail ppd
        join fle_staging.parcel_info pi on pi.pno = ppd.pno
        left join fle_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
        where
            ppd.parcel_problem_type_category = 2
            and ppd.created_at > date_sub(date_sub(curdate(), interval 90 day), interval 7 hour)
            and ppd.diff_marker_category in (14, 40)
            and pi.state in (1,2,3,4,6)
            and bc.client_id is null
            and kp.id is not null
        group by 1,2,3
        having count(distinct ppd.id) >= 3
    )
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 包裹状态
    ,t1.client_id
    ,sd.name 归属部门
    ,ss2.name 归属网点
    ,kp2.staff_info_name 销售代表
    ,a1.ppd_cnt 上报收件人改约时间次数
    ,a2.ppd_cnt 上报联系不上次数
    ,a3.CN_element 最近一次上报的留仓件
    ,datediff(curdate(), convert_tz(t1.created_at, '+00:00', '+08:00')) 揽收至今天数
from t t1
left join fle_staging.ka_profile kp2 on kp2.id = t1.client_id
left join fle_staging.sys_department sd on sd.id = kp2.department_id
left join fle_staging.sys_store ss2 on ss2.id = kp2.store_id
left join
    (
        select
            ppd.pno
            ,count(ppd.id) ppd_cnt
        from fle_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.parcel_problem_type_category = 2
            and ppd.created_at > date_sub(date_sub(curdate(), interval 90 day), interval 7 hour)
            and ppd.diff_marker_category = 14 -- 改约
        group by 1
    ) a1 on a1.pno = t1.pno
left join
    (
        select
            ppd.pno
            ,count(ppd.id) ppd_cnt
        from fle_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.parcel_problem_type_category = 2
            and ppd.created_at > date_sub(date_sub(curdate(), interval 90 day), interval 7 hour)
            and ppd.diff_marker_category = 40 -- 联系不上
        group by 1
    ) a2 on a2.pno = t1.pno
left join
    (
        select
            a.*
            ,ddd.CN_element
        from
            (
                select
                    ppd.pno
                    ,ppd.diff_marker_category
                    ,row_number() over (partition by ppd.pno order by ppd.created_at desc) rk
                from fle_staging.parcel_problem_detail ppd
                join t t1 on t1.pno = ppd.pno
                where
                    ppd.parcel_problem_type_category = 2
                    and ppd.created_at > date_sub(date_sub(curdate(), interval 90 day), interval 7 hour)
            ) a
        left join dwm.dwd_dim_dict ddd on ddd.element = a.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            a.rk = 1
    ) a3 on a3.pno = t1.pno