select
    ddd.CN_element
    ,count(distinct pr.id)/count(distinct date (convert_tz(pr.routed_at, '+00:00', '+08:00'))) as avg_num
from ph_staging.parcel_route pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    pr.routed_at > '2024-03-31 16:00:00'
    and pr.routed_at < '2024-04-30 16:00:00'
    and pr.route_action = 'DELIVERY_MARKER'
group by ddd.CN_element