with t as
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 31 hour)
            and pr.routed_at < date_sub(curdate(), interval 7 hour)
            and pr.marker_category = 19
            and pr.store_category in (8,12)
            and pr.route_action = 'DIFFICULTY_HANDOVER'
    )
select
    t1.pno 上报破损运单号
    ,t1.store_name 上报分拨中心
    ,convert_tz(t1.routed_at, '+00:00', '+07:00') 上报日期时间
    ,if(p1.pno is not null, 'Y', 'N') 该分拨中心是否扫描发件出仓
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 扫描发件出仓日期时间
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        where
            pr.routed_at > date_sub(curdate(), interval 3 day)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > t1.routed_at
    ) p1 on p1.pno = t1.pno and p1.rk = 1

