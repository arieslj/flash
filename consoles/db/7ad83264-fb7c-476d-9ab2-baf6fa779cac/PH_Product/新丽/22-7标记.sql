select
    pr.pno 运单号
    ,pi.client_id 客户iD
    ,bc.client_name 客户名称
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 标记时间
    ,ddd.CN_element 标记原因
    ,pr.staff_info_id 标记快递员
    ,dp.store_name 标记网点
    ,dp.piece_name 标记网点所属片区
    ,dp.region_name 标记网点所属大区
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id /*and bc.client_name = 'shopee'*/
left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action = 'DELIVERY_MARKER'
    and pr.routed_at >= '2024-01-29 14:00:00'
    and pr.routed_at < '2024-01-29 23:00:00'