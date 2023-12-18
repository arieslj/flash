select
    date(convert_tz(pr.routed_at, '+00:00', '+08:00')) 日期
    ,pr.staff_info_id
    ,pr.staff_info_name
    ,count(distinct pr.pno ) 交接包裹数
from ph_staging.parcel_route pr
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.routed_at > '2023-12-01 16:00:00'
    and pr.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
group by 1,2,3