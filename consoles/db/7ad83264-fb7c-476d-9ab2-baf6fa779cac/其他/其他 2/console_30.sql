 select
    dp.store_name 网点Branch
    ,dp.piece_name 片区District
    ,dp.region_name 大区Area
    ,plt.pno 运单Tracking_Number
    ,plt.client_id
    ,bc.client_name
    ,plt.created_at 任务创建时间Task_Generation_time
    ,plt.parcel_created_at 包裹揽收时间Receive_time
    ,concat(ddd.element, ddd.CN_element) 最后有效路由Last_effective_route
    ,plt.last_valid_routed_at 最后有效路由操作时间Last_effective_routing_time
    ,plt.last_valid_staff_info_id 最后有效路由操作员工Last_effective_route_operate_id
    ,ss.name 最后有效路由操作网点Last_operate_branch
from ph_bi.parcel_lose_task plt
join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join ph_bi.parcel_detail pd on pd.pno = plt.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = plt.last_valid_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
where
    plt.source in (3,33)
    and plt.state in (1,2,3,4)
    and plt.created_at >= '2023-09-01'