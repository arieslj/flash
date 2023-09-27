with t as
    (
        select
            dm.p_date
            ,dm.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by dm.p_date, pr.pno order by pr.routed_at desc ) rk
        from dwm.dwd_my_dc_should_be_delivery_d dm
        join my_staging.parcel_route pr on pr.pno = dm.pno and pr.routed_at > '2023-09-01' and pr.routed_at >= date_sub(dm.p_date, interval 8 hour) and pr.routed_at < date_add(dm.p_date, interval 16 hour)
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and dm.p_date >= '2023-09-14'
            and dm.should_delevry_type not in ('非当日应派')
    )
select
    a1.p_date 日期
    ,a1.staff_info_id 快递员
    ,ss.name 网点
    ,smr.name 大区
    ,a4.should_count 当日应派
    ,a1.scan_count 交接总量
    ,convert_tz(a2.routed_at, '+00:00', '+08:00') 第一票交接时间
    ,convert_tz(a3.finished_at, '+00:00', '+08:00') 第一票妥投时间
from
    (
        select
            t1.p_date
            ,t1.staff_info_id
            ,count(distinct t1.pno) scan_count
        from t t1
        where
            t1.rk = 1
        group by 1,2
    ) a1
left join
    (
        select
            *
            ,row_number() over (partition by t2.p_date,t2.staff_info_id order by t2.routed_at) rn
        from t t2
    ) a2 on a2.p_date = a1.p_date and a2.staff_info_id = a1.staff_info_id and a2.rn = 1
left join
    (
        select
            date(convert_tz(pi.finished_at, '+00:00', '+08:00')) p_date
            ,pi.ticket_delivery_staff_info_id
            ,pi.finished_at
            ,row_number() over (partition by date(convert_tz(pi.finished_at, '+00:00', '+08:00')), pi.ticket_delivery_staff_info_id order by pi.finished_at) rk
        from my_staging.parcel_info pi
        where
            pi.state = 5
            and pi.finished_at >= '2023-09-13 16:00:00'
    ) a3 on a3.p_date = a1.p_date and a3.ticket_delivery_staff_info_id = a1.staff_info_id and a3.rk = 1
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
left join my_staging.sys_store ss on ss.id = hsi.sys_store_id
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            dm.p_date
            ,dm.dst_store_id
            ,count(distinct dm.pno) should_count
        from dwm.dwd_my_dc_should_be_delivery_d dm
        where
            dm.p_date >= '2023-09-14'
            and dm.should_delevry_type not in ('非当日应派')
        group by 1,2
    ) a4 on a4.dst_store_id = hsi.sys_store_id and a4.p_date = a1.p_date
;


with t as
    (
        select
            a.*
        from
            (
                select
                    dm.p_date
                    ,dm.pno
                    ,ps.third_sorting_code
                    ,dm.dst_store_id
                    ,row_number() over (partition by ps.pno order by ps.created_at desc) rk
                from dwm.dwd_my_dc_should_be_delivery_d dm
                join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = dm.pno and ps.dst_store_id = dm.dst_store_id
                where
                    ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    and dm.p_date >= '2023-09-14'
            ) a
        where
            a.rk = 1
    )
, sort as
(
    select
        t1.p_date
        ,t1.third_sorting_code
        ,t1.dst_store_id
        ,t1.pno
        ,pr.routed_at
        ,row_number() over (partition by t1.p_date, t1.dst_store_id,t1.third_sorting_code order by pr.routed_at desc ) r1
        ,row_number() over (partition by t1.p_date, t1.dst_store_id,t1.third_sorting_code order by pr.routed_at ) r2
    from my_staging.parcel_route pr
    join t t1 on t1.pno = pr.pno
    where
        pr.route_action = 'SORTING_SCAN'
        and pr.routed_at >= date_sub(t1.p_date, interval 8 hour)
        and pr.routed_at < date_add(t1.p_date, interval 16 hour)
    )
select
    a1.p_date 日期
    ,a1.third_sorting_code 网格
    ,dm.store_name 网点
    ,dm.region_name 大区
    ,a1.pno_count 当日应派
    ,a2.sort_count 已分拣数
    ,convert_tz(s3.routed_at, '+00:00', '+08:00') 第一票分拣扫描
    ,convert_tz(s2.routed_at, '+00:00', '+08:00') 最后一票分拣扫描
from
    (
        select
            t1.p_date
            ,t1.dst_store_id
            ,t1.third_sorting_code
            ,count(distinct t1.pno) pno_count
        from  t t1
        group by 1,2,3
    ) a1
left join
    (
        select
            s1.p_date
            ,s1.dst_store_id
            ,s1.third_sorting_code
            ,count(distinct s1.pno) sort_count
        from  sort s1
        group by 1,2,3
    ) a2 on a2.p_date = a1.p_date and a2.dst_store_id = a1.dst_store_id and  a2.third_sorting_code = a1.third_sorting_code
left join sort s2 on s2.p_date = a1.p_date and s2.dst_store_id = a1.dst_store_id and s2.third_sorting_code = a1.third_sorting_code and s2.r1 = 1
left join sort s3 on s3.p_date = a1.p_date and s3.dst_store_id = a1.dst_store_id and s3.third_sorting_code = a1.third_sorting_code and s3.r2 = 1
left join dwm.dim_my_sys_store_rd dm on dm.store_id = a1.dst_store_id and dm.stat_date = date_sub(curdate(), interval 1 day)