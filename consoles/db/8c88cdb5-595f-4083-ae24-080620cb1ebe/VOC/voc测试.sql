select
    cdt.*
    ,di.pno
from fle_staging.customer_diff_ticket cdt
left join fle_staging.diff_info di on di.id = cdt.diff_info_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
# left join nl_production.violation_return_visit vrv on vrv.type = 3 and json_extract(vrv.extra_value, '$.diff_id') = di.id
left join tmpale.tmp_th_voc_staff_work tt on tt.staff_id = cdt.operator_id
where
    cdt.organization_type = 2
    and cdt.vip_enable = 1
    and cdt.show_enabled = 0
    and cdt.created_at >= date_sub('${sdate}', interval 7 hour)
    and cdt.created_at < date_add('${edate}', interval 17 hour)
    and cdt.state not in (5,6)
    and ( cdt.operator_id is null or tt.staff_id is  not null )
    and
        (
            di.diff_marker_category in (20,21,17,23,25)
            or ( di.diff_marker_category = 26 and bc.client_name = 'shopee' )
            or ( di.diff_marker_category = 39 and bc.client_name = 'tiktok')
        )
    and bc.client_name in ('lazada', 'shopee', 'tiktok')
    and di.diff_marker_category = 17