select
    distinct pi.pno
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join rot_pro.parcel_route pr on pr.pno = pi.pno
join bi_pro.parcel_lose_task plt on plt.pno = pi.pno
where
    pi.created_at > '2025-02-28 17:00:00'
    and pi.created_at < '2025-04-30 17:00:00'
    and ss.category in (2,14) -- DC,PDC
    and pr.routed_at > '2025-02-28 17:00:00'
    and pr.route_action ='PENDING_RETURN'
    and pr.store_category = 4
    and plt.state = 6
    and plt.parcel_created_at > '2025-02-28 17:00:00'
