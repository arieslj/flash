select
    pr.pno
    ,pr.staff_info_id
    ,pr.store_id
    ,pr.store_name
    ,pr.routed_at
    ,json_extract(pr.extra_value, '$.phone') phone
    ,lead(pr.routed_at, 1) over (partition by pr.pno order by pr.routed_at) next_routed_at
from rot_pro.parcel_route pr
 join tmpale.tmp_th_phone_lj_0522 t on t.staff = pr.staff_info_id
where
    pr.routed_at > '2024-05-20 17:00:00'
    and pr.routed_at < '2024-05-21 17:00:00'
    and pr.route_action = 'PHONE'
   -- and pr.staff_info_id  = '181927'
;


;


select
    t.*
    ,pr.pno
from rot_pro.parcel_route pr
join tmpale.tmp_th_phone_lj_0522 t on t.satff = pr.staff_info_id
join fle_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.routed_at > '2024-05-20 17:00:00'
    and pr.routed_at < '2024-05-21 17:00:00'

