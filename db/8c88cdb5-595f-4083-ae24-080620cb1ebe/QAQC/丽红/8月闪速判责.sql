with t as
    (
        select
            distinct
            plt.pno
            ,pi.state
            ,plt.vip_enable
            ,pi.dst_store_id
            ,plt.client_id
        from bi_pro.parcel_lose_task plt
        join fle_staging.parcel_info pi on pi.pno = plt.pno
        where
            plt.parcel_created_at > '2024-08-01'
            and plt.parcel_created_at < '2024-09-01'
            and plt.source in (1,2,5,7,8,12)
            and ( plt.state in (1,2,3,4) or pi.state in (7,8,5,4))
            and pi.created_at > '2024-07-30'
    )
select
    t1.pno
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
    ,ddd.CN_element 最后有效操作路由
    ,a1.staff_info_id 最后操作人
    ,ss.name 目的地网点
    ,if(t1.vip_enable = 1, 'y', 'n') 是否KAM
    ,t1.client_id 客户ID
from t t1
left join fle_staging.sys_store ss on ss.id = t1.dst_store_id
left join
    (
        select
            pr.route_action
            ,pr.pno
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-07-31'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a1 on a1.pno = t1.pno and a1.rk = 1
left join dwm.dwd_dim_dict ddd on ddd.element = a1.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'