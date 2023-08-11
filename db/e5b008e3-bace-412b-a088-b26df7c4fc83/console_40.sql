with t as
(
        select
            pr.pno
            ,pr.routed_at
        from ph_staging.parcel_route pr
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
        where
            pr.routed_at > '2023-08-07 16:00:00'
        group by 1,2
)
select
    pr.pno
from ph_staging.parcel_route pr
join t t1 on t1.pno = pr.pno and pr.routed_at < t1.routed_at
where
    pr.route_action = 'CHANGE_PARCEL_CLOSE'
    and pr.store_id = '130' -- QAQC操作
group by 1