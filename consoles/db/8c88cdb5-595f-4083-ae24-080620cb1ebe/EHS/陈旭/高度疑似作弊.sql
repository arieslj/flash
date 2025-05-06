select
    pr.pno
    ,count(distinct date (convert_tz(pr.routed_at, '+00:00', '+07:00'))) change_days
from rot_pro.parcel_route pr
join fle_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.routed_at > '2024-07-31 17:00:00'
   -- and pr.routed_at < '2024-08-31 17:00:00'
    and pi.created_at > '2024-07-31 17:00:00'
    and pi.created_at < '2024-08-31 17:00:00'
    and pr.marker_category = 14
group by 1
having change_days >= 3