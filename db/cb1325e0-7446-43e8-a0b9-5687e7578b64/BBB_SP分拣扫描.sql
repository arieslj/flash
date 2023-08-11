with t as
(
    select
        ds.stat_date
        ,ds.pno
        ,ds.store_id
        ,ss.name
    from my_bi.dc_should_delivery_2023_07 ds
    left join my_staging.sys_store ss on ds.store_id = ss.id
    where
        ds.stat_date >= '2023-07-28'
        and ds.stat_date <= '2023-07-31'
)
select
    t1.stat_date 统计日期
    ,t1.store_id 网点ID
    ,t1.name 网点
    ,t1.pno 单号
    ,if(sc.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
    ,dmp.third_sorting_code 第三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,t1.stat_date
            ,row_number() over (partition by t1.stat_date,pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
    ) sc on sc.pno = t1.pno and sc.rk = 1 and sc.stat_date = t1.stat_date
left join
    (
        select
            pr.pno
            ,t1.stat_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at >= date_sub(t1.stat_date,interval 8 hour)
            and pr.routed_at < date_add(t1.stat_date, interval 16 hour)
        group by 1,2
    ) cf on cf.pno = t1.pno and cf.stat_date = t1.stat_date
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,dmp.third_sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = t1.store_id
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1