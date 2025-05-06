with t as
(
    select
        ds.pno
        ,ds.p_date
        ,ds.dst_store_id
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.p_date = curdate() -- 今日应派
        and ds.should_delevry_type != '非当日应派'
)
select
    t1.p_date
    ,t1.dst_store_id
    ,dm.store_name
    ,dm.piece_name
    ,dm.region_name
    ,t1.pno
    ,if(scan.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(scan.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,scan.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null , '是', '否') 是否标记错分
    ,sort.third_sorting_code 第三段码
    ,convert_tz(del.routed_at, '+00:00', '+08:00') 当日第一次交接时间
from t t1
left join dwm.dim_my_sys_store_rd dm on dm.store_id = t1.dst_store_id and dm.stat_date = date_sub(curdate(), interval 1 day )
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at >= date_sub(curdate(), interval 8 hour)
            and pr.routed_at < date_add(curdate(), interval 16 hour)
            and pr.route_action = 'SORTING_SCAN'
    ) scan on scan.pno = t1.pno and scan.rk = 1
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at >= date_sub(curdate(), interval 8 hour)
            and pr.routed_at < date_add(curdate(), interval 16 hour)
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
        group by 1
    ) cf on cf.pno = t1.pno
left join
    (
        select
            ps.pno
            ,ps.third_sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc ) rn
        from my_drds_pro.parcel_sorting_code_info ps
        join t t1 on t1.pno = ps.pno and ps.dst_store_id = t1.dst_store_id
    ) sort on sort.pno = t1.pno and sort.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at >= date_sub(curdate(), interval 8 hour)
            and pr.routed_at < date_add(curdate(), interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    ) del on del.pno = t1.pno and del.rk = 1

;



select
    a.dst_store_id 网点ID
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,a.third_sorting_code 三段码
    ,a.pno 单号
    ,a.should_delevry_type 包裹类型
    ,a.staff_info_id 分拣员工
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 分拣时间
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.routed_at) rk
        from
            (
                select
                    ds.dst_store_id
                    ,dp.third_sorting_code
                    ,ds.pno
                    ,ds.should_delevry_type
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                from dwm.dwd_my_dc_should_be_delivery ds
                left join dwm.drds_my_parcel_sorting_code_info  dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                join my_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= date_sub(curdate(), interval 8 hour) and pr.routed_at < date_add(curdate(), interval 16 hour)
                where
                    ds.p_date = curdate()
            ) a
        where
            a.rn = 1
    ) a
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    a.rk = 1
