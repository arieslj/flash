select
    pr.pno
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 打印面单时间
from
    (
        select
            pr.pno
            ,pr.routed_at
        from rot_pro.parcel_route pr
        where
            pr.routed_at > '2024-03-31 17:00:00'
            and pr.route_action = 'PRINTING'
    ) pr
join
    (
        select
            pr.pno
            ,pr.routed_at
        from rot_pro.parcel_route pr
        where
            pr.routed_at > '2024-03-31 17:00:00'
            and pr.route_action in ('INVENTORY', 'SORTING_SCAN')
    ) pr1 on pr.pno = pr1.pno
left join rot_pro.parcel_route pr2 on pr.pno = pr2.pno and pr2.route_action = 'DELIVERY_CONFIRM'
where
    timestampdiff(hour, pr.routed_at, pr1.routed_at) < 24
    and ( pr2.pno is null or ( convert_tz(pr2.routed_at, '+00:00', '+07:00') > date_add(date (convert_tz(pr.routed_at, '+00:00', '+07:00')), interval 2 day)))
group by 1,2