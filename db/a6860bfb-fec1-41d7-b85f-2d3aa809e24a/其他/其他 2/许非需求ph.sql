with t as
    (
        select
            plt.pno
            ,bc.client_name
            ,plt.client_id
            ,plt.created_at
            ,plt.updated_at
            ,plt.parcel_created_at
        from ph_bi.parcel_lose_task plt
        join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.source = 3
            and plt.parcel_created_at >= '2023-08-01'
    )
select
    t1.pno
    ,t1.client_id 客户ID
    ,t1.client_name 客户名称
    ,if(t1.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,t1.parcel_created_at 包裹揽收时间
    ,t1.created_at 判责任务生成时间
    ,t1.updated_at 判责时间
    ,t2.store_id 判责后第一个有效路由网点ID
    ,t2.store_name 判责后第一个有效路由网点
    ,t2.staff_info_id 判责后第一个有效路由操作人
    ,convert_tz(t2.routed_at, '+00:00', '+08:00')  判责后第一个有效路由时间
    ,ddd.CN_element  判责后第一个有效路由
from t t1
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at
            ,pr.staff_info_id
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-08-01'
            and pr.routed_at > date_sub(t1.updated_at, interval 8 hour)
            and pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) t2 on t2.pno = t1.pno and t2.rk = 1
left join dwm.dwd_dim_dict ddd on ddd.element = t2.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join ph_staging.order_info oi on oi.pno = t1.pno
where
    if(t2.routed_at is not null ,t2.routed_at > date_sub(t1.updated_at, interval 8 hour), 1 = 1)