with t as
    (
        select
            pr.pno
            ,pi.dst_store_id
            ,ss.name
        from my_staging.parcel_route pr
        join my_staging.parcel_info pi on pi.pno = pr.pno
        left join my_staging.sys_store ss on ss.id = pi.dst_store_id
        where
            pr.routed_at > '2024-09-30 16:00:00'
            and pr.routed_at < '2024-10-07 16:00:00'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.store_id = 'MY04040300'
            and ss.province_code in ('MY16', 'MY14', 'MY15')
    )
select
    t1.pno
    ,t1.name 目的地网点
    ,ft.plan_arrive_time 计划到达时间
    ,ft.line_name 车线名称
    ,t2.pack_no 集包号
    ,d1.cn_element 第一次有效路由
    ,convert_tz(p1.routed_at, '+00:00', '+08:00') 第一次有效路由时间
    ,d2.cn_element 第二次有效路由
    ,convert_tz(p2.routed_at, '+00:00', '+08:00') 第二次有效路由时间
from t t1
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,json_extract(pr.extra_value, '$.proofId') proof
            ,json_extract(pr.extra_value, '$.packPno') pack_no
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.dst_store_id
        where
            pr.routed_at > '2024-09-30 16:00:00'
            and pr.route_action in ( 'ARRIVAL_GOODS_VAN_CHECK_SCAN')
    ) t2 on t2.pno = t1.pno and t2.rk = 1
left join my_bi.fleet_time ft on ft.proof_id = t2.proof and ft.next_store_id = t2.store_id
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.dst_store_id
        where
            pr.routed_at > '2024-09-30 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) p1 on p1.pno = t1.pno and p1.rk = 1
left join dwm.dwd_dim_dict d1 on d1.element = p1.route_action and d1.db = 'my_staging' and d1.tablename = 'parcel_route' and d1.fieldname = 'route_action'
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.dst_store_id
        where
            pr.routed_at > '2024-09-30 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) p2 on p2.pno = t1.pno and p2.rk = 2
left join dwm.dwd_dim_dict d2 on d2.element = p2.route_action and d2.db = 'my_staging' and d2.tablename = 'parcel_route' and d2.fieldname = 'route_action'