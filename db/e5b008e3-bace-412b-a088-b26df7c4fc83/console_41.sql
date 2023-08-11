-- 错分
-- 疑难件结果是继续派送，当前网点未发件出仓，无新增其他网点有效路由
select
    di.pno
    ,di.store_id
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
join ph_staging.parcel_change_detail pcd on pcd.pno = di.pno and pcd.field_name = 'dst_store_id' and pcd.created_at > di.created_at
left join ph_staging.parcel_route pr on pr.pno = di.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.parcel_route pr2 on pr2.pno = di.pno and pr2.routed_at > cdt.updated_at and pr2.store_id != di.store_id and pr2.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
where
    di.diff_marker_category = 31
    and cdt.negotiation_result_category in (5,6)
    and pr.pno is null
    and pi.state not in (5,7,8,9)
    and di.created_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour )
    and pr2.pno is null
group by 1,2




