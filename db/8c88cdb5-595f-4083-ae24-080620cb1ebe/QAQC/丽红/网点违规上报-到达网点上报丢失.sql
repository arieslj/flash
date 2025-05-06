select
    distinct
    ps.pno
    ,ps.store_name 网点
    ,convert_tz(ps.routed_at, '+00:00', '+07:00') 到港时间
from
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at
            ,date_add(pr.routed_at, interval 2 hour) routed_at_2_hour
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN'
            and pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval 7 hour)
            and pr.store_category in (1,2,10,14)
    ) ps
join
    (
        select
            di.pno
            ,di.store_id
            ,di.created_at
        from fle_staging.diff_info di
        where
            di.created_at > date_sub(curdate(), interval 31 day)
            and di.diff_marker_category = 22
    ) di on ps.pno = di.pno and ps.store_id = di.store_id
left join
    (
        select
            pr.pno
            ,pr.store_id
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval 7 hour)
    ) pr on ps.pno = pr.pno and ps.store_id = pr.store_id
where
    ps.routed_at < di.created_at
    and di.created_at < ps.routed_at_2_hour
    and pr.pno is null


;


select
    distinct
    ps.pno
    ,ps.store_name 网点
    ,convert_tz(ps.routed_at, '+00:00', '+07:00') 到港时间
from
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at
            ,date_add(pr.routed_at, interval 2 hour) routed_at_2_hour
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN'
           -- and pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval 7 hour)
            and pr.routed_at > '2025-02-08 17:00:00'
            and pr.routed_at < '2025-02-12 17:00:00'
            and pr.store_category in (1,2,10,14)
    ) ps
join
    (
        select
            di.pno
            ,di.store_id
            ,di.created_at
        from fle_staging.diff_info di
        where
            di.created_at > date_sub(curdate(), interval 31 day)
            and di.diff_marker_category = 22
    ) di on ps.pno = di.pno and ps.store_id = di.store_id
left join
    (
        select
            pr.pno
            ,pr.store_id
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
          --  and pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval 7 hour)
            and pr.routed_at > '2025-02-08 17:00:00'
            and pr.routed_at < '2025-02-12 17:00:00'
    ) pr on ps.pno = pr.pno and ps.store_id = pr.store_id
where
    ps.routed_at < di.created_at
    and di.created_at < ps.routed_at_2_hour
    and pr.pno is null
