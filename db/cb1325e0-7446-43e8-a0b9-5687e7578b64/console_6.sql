with t as
(
    select
        ds.pno
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date = '2023-07-19'
        and ds.store_id = 'MY04020200' -- BBB_SP
)
select
    t1.pno
    ,if(sc.pno is not null , '是', '否') 是否操作分拣扫描
    ,convert_tz(sc.routed_at, '+00:00', '+08:00') 第一次分拣扫描时间
    ,sc.staff_info_id 操作分拣扫描时间
    ,if(cf.pno is not null, '是', '否') 是否标记错分
    ,dmp.sorting_code 三段码
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SORTING_SCAN'
            and pr.routed_at > '2023-07-18 18:00:00'
    ) sc on sc.pno = t1.pno and sc.rk = 1
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
            and pr.routed_at > '2023-07-18 18:00:00'
        group by 1
    ) cf on cf.pno = t1.pno
left join
    (
        select
            dmp.pno
            ,dmp.sorting_code
            ,row_number() over (partition by dmp.pno order by dmp.created_at desc) rk
        from dwm.drds_my_parcel_sorting_code_info dmp
        join t t1 on t1.pno = dmp.pno and dmp.dst_store_id = 'MY04020200'
    ) dmp on dmp.pno = t1.pno and dmp.rk = 1