select
    a3.pno
    ,convert_tz(a3.routed_at, '+00:00', '+07:00') 妥投时间
    ,a3.route_action 最后一次有效路由
    ,convert_tz(a3.last_routed_at, '+00:00', '+07:00') 最后一次有效路由时间
from
    (
        select
            a1.pno
            ,a1.routed_at
            ,a2.routed_at last_routed_at
            ,a2.route_action
            ,row_number() over (partition by a1.pno order by a2.routed_at desc) rk
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                from rot_pro.parcel_route pr
                where
                    pr.routed_at > '2024-10-31 17:00:00'
                    and pr.route_action = 'DELIVERY_CONFIRM'
            ) a1
        join
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,pr.route_action
                from rot_pro.parcel_route pr
                where
                    pr.routed_at > '2024-10-31 17:00:00'
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            ) a2 on a2.pno = a1.pno
        where
            a2.routed_at > a1.routed_at
    ) a3
where
    a3.rk = 1