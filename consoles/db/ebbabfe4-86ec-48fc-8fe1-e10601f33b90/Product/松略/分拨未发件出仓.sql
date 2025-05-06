-- 目的地网点有有效路由的包裹，然后通过网点表找分管机构分拨，这个包裹在分拨有其他有效路由但是没有发件出仓
with t as
    (
        select
            pr.store_id
            ,pr.pno
            ,pi.state
            ,pr.store_name
        from my_staging.parcel_route pr
        left join my_staging.parcel_info pi on pr.pno = pi.pno and pr.store_id = pi.dst_store_id
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN''DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pi.dst_store_id != pi.ticket_pickup_store_id
        group by 1,2
    )
select
    t1.pno
    ,t1.store_name
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
from t t1
left join my_staging.sys_store ss on ss.id = t1.store_id
left join my_staging.sys_store ss2 on ss2.id = if(ss.category in (8,12), ss.id , substring_index(ss.ancestry, '/', -1))
left join my_staging.parcel_route pr2 on pr2.pno = t1.pno and pr2.store_id = ss2.id and pr2.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
where
    pr2.id is null

;

select substring()