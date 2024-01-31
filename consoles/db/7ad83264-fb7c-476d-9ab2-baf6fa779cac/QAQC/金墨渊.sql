select
#     date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
#     ,count(distinct pr.pno) 交接量
#     ,count(distinct if(ppd.pno is null and pi.state not in (5,7,8,9), pr.pno, null)) 未终态交接未留仓量

    pr.pno
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_problem_detail ppd on ppd.pno = pr.pno and ppd.created_at > '2024-01-28 16:00:00' and ppd.created_at < '2024-01-29 20:00:00'
where
    pr.routed_at > '2024-01-28 16:00:00'
    and pr.routed_at < '2024-01-29 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and ppd.pno is null
    and pi.state not in (5,7,8,9)
group by 1