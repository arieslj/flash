select
    pr.staff_info_id
    ,pr.pno
    ,pi.client_id
    ,pr.route_action
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pr.staff_info_id = 131531
    and pr.routed_at > '2024-03-19 12:00:00'
    and pr.routed_at < '2024-03-19 13:00:00'
    and bc.client_name = 'shein'