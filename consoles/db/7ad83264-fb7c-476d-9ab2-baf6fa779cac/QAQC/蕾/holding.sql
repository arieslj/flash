select
    pi.pno
    ,if(pcd.old_value is null ,ss.name ,ss2.name) 应派送网点
    ,convert_tz(pr.routed_at,'+00:00','+08:00') 进入Holding日期
    ,ddd.CN_element 最后有效路由
    ,pd.resp_store_updated 最后路由时间
from ph_staging.parcel_info pi
join ph_staging.parcel_route pr on pr.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_bi.parcel_detail pd on pd.pno = pi.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pd.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join ph_staging.parcel_change_detail pcd on pcd.pno = pi.pno and pcd.field_name = 'dst_store_id' and pcd.new_value = 'PH19040F05'
left join ph_staging.sys_store ss2 on ss2.id = pcd.old_value
where
    pi.state in (1,2,3,4,6)
    and pr.route_action = 'REFUND_CONFIRM'