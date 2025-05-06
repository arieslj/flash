select
    pr.pno
    ,ddd.CN_element 路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 路由时间
    ,hjt.job_name 操作者岗位
    ,pr.staff_info_id 操作人
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
#     ,json_extract(pr.extra_value, '$.illegalBarCode') ss
#     ddd.CN_element
#     ,count(distinct pr.pno) cnt

from ph_staging.parcel_route pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.db = 'ph_staging'
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(),1)
left join ph_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hst.job_title
where
    pr.routed_at > '2024-5-28 16:00:00'
    and pr.routed_at < '2024-05-29 16:00:00'
    and pr.route_action in ('INVENTORY', 'DELIVERY_CONFIRM' )
    and json_extract(pr.extra_value, '$.illegalBarCode') = true
# group by 1


;
