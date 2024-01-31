select
    pr.pno
    ,pr.staff_info_id 员工ID
    ,ddd.CN_element 标记原因
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 标记时间
    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) 标记日期
from ph_staging.parcel_route pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    pr.routed_at > '2023-10-18 16:00:00'
    and pr.routed_at < '2023-10-26 16:00:00'
    and pr.route_action = 'DELIVERY_MARKER'
    and pr.staff_info_id in (126699, 127394, 142490, 148004)