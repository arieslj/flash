select
    sp.name Province
    ,di.pno
    ,ddd.EN_element
    ,pi.dst_detail_address
    ,pi.dst_phone
    ,pi.dst_name
from ph_staging.diff_info di
join ph_staging.parcel_info pi on di.pno = pi.pno
join ph_staging.sys_store ss on ss.id = di.store_id
left join ph_staging.sys_province sp on sp.code = ss.province_code
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    di.created_at > date_sub(curdate(), interval 32 hour)
    and di.created_at < date_sub(curdate(), interval 8 hour)
    and di.diff_marker_category in (31,17,14,40)
    and ss.province_code in ('PH64', 'PH24')
