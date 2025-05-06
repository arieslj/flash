with t as
    (
        select
            sws.*
        from
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.store_name
                    ,pr.routed_at
                    ,pr.next_store_id
                    ,pr.next_store_name
                    ,row_number() over (partition by pr.pno, pr.store_id order by pr.routed_at desc) rk
                from rot_pro.parcel_route pr
                where
                    pr.routed_at > '2024-10-31 17:00:00'
                    and pr.routed_at < '2024-11-30 17:00:00'
                    and pr.store_category in (8,12)
                    and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            ) sws
        where
            sws.rk = 1
    )
select
    t1.pno 运单号
    ,date (convert_tz(t1.routed_at, '+00:00', '+07:00')) 日期
    ,t1.store_name HUB
    ,pi.exhibition_weight/1000 重量kg
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 体积
from t t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join
    (
        select
            distinct
            pr.pno
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.next_store_id = pr.store_id
        where
            pr.routed_at > '2024-10-31 17:00:00'
            and pr.routed_at > t1.routed_at
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a1 on t1.pno = a1.pno
left join
    (
        select
            distinct
            pr.pno
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.next_store_id != pr.store_id
        where
            pr.routed_at > '2024-10-31 17:00:00'
            and pr.routed_at > t1.routed_at
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a2 on t1.pno = a2.pno
where
    a1.pno is null
    and a2.pno is not null