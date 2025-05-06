select
    pr.store_name
    ,count(distinct pr.pno) 妥投量
    ,count(distinct if(pi.returned = 1, pr.pno, null)) 退件妥投量
    ,count(distinct if(pi.returned = 1, pr.pno, null)) / count(distinct pr.pno) 退件率
from rot_pro.parcel_route pr
left join fle_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.routed_at > '2024-06-24 17:00:00'
    and pr.routed_at < '2024-07-01 17:00:00'
    and pr.route_action = 'DELIVERY_CONFIRM'
group by 1
order by 4 desc