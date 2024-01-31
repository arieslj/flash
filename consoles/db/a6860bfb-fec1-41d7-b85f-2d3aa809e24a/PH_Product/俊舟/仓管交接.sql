with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.staff_info_id
            ,hsi.sys_store_id
            ,pr.pno
        from ph_staging.parcel_route pr
        join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id and hsi.state = 1 and hsi.formal = 1 and hsi.job_title = 37
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at >= '2023-12-04 16:00:00'
            and pr.routed_at < '2023-12-17 16:00:00'
        group by 1,2,3
    ),
    bs as
    (
        select
            *
        from ph_staging.parcel_route pr
        join t t1 on t1.pno
    )
select
    t1.staff_info_id 员工ID
    ,t1.pr_date 日期
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,t1.pno_count 交接量
    ,fn.pno_count  妥投量
    ,if(hsa.staff_info_id is not null, '是', '否' ) 当日是否出差
from t t1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t1.staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= t1.pr_date and hsa.employment_end_date >= t1.pr_date
left join
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.staff_info_id
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        join t t1 on t1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= '2023-11-01'
            and pr.routed_at >= date_sub(t1.pr_date, interval 8 hour)
            and pr.routed_at < date_add(t1.pr_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1,2
    ) fn on fn.staff_info_id = t1.staff_info_id and fn.pr_date = t1.pr_date
;





select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 网点
    ,a1.pr_date 日期
    ,a1.staff_info_id 员工ID
    ,a1.pno_count 交接包裹数
    ,a2.pno_count 妥投包裹数
from
    (
        select
            a.pr_date
            ,a.staff_info_id
            ,count(distinct a.pno) pno_count
        from
            (
                select
                    pr.pno
                    ,pr.staff_info_id
                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+08:00')) order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                where
                    pr.routed_at > '2023-12-20 16:00:00'
                    and pr.routed_at < '2024-01-03 16:00:00'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a
        where
            a.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
            and a.rk = 1
        group by 1,2
    ) a1
left join
    (
        select
            pr.staff_info_id
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-12-20 16:00:00'
           and pr.routed_at < '2024-01-03 16:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
            and pr.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
        group by 1,2
    ) a2 on a2.staff_info_id = a1.staff_info_id and a2.pr_date = a1.pr_date
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )

