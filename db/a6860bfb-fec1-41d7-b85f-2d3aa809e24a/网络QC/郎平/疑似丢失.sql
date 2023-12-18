with t as
    (
         select
            dp.store_name 网点Branch
            ,dp.piece_name 片区District
            ,dp.region_name 大区Area
            ,plt.pno 运单Tracking_Number
            ,pi.exhibition_weight 重量
            ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
            ,pi2.cod_amount/100 COD
            ,plt.created_at 任务创建时间Task_Generation_time
            ,plt.parcel_created_at 包裹揽收时间Receive_time
            ,concat(ddd.element, ddd.CN_element) 最后有效路由Last_effective_route
            ,plt.last_valid_routed_at 最后有效路由操作时间Last_effective_routing_time
            ,plt.last_valid_staff_info_id 最后有效路由操作员工Last_effective_route_operate_id
            ,ss.name 最后有效路由操作网点Last_operate_branch
        from ph_bi.parcel_lose_task plt
        left join ph_bi.parcel_detail pd on pd.pno = plt.pno
        left join ph_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month )
        left join  ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = plt.last_valid_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.source in (3,33)
            and plt.state in (1,2,3,4)
    )
select
   t1.*
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 到达网点时间
from t t1
left join
    (
        select
            pr.routed_at
            ,pr.pno
            ,row_number() over (partition by pr.pno order by pr.routed_at) rn
        from ph_staging.parcel_route pr
        join t t1 on t1.运单Tracking_Number = pr.pno and t1.网点Branch = pr.store_name
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a on a.pno = t1.运单Tracking_Number and a.rn = 1