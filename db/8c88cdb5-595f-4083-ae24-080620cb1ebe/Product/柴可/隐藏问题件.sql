select
    di.pno
    ,cdt.diff_info_id
from fle_staging.diff_info di
left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
join rot_pro.parcel_route pr on pr.pno = di.pno and pr.route_action = 'DIFFICULTY_HANDOVER' and json_extract(pr.extra_value, '$.diffInfoId') = di.id
where
    di.state = 0
    and cdt.show_enabled = 1
    and json_extract(pr.extra_value, '$.returnVisitEnabled') = 2
    and di.diff_marker_category = 17
    and di.created_at > '2024-07-12 17:00:00'
    and di.created_at < '2024-07-19 17:00:00'