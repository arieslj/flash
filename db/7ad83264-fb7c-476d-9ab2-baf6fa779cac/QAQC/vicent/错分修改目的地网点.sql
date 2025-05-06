with t as
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        left join ph_staging.parcel_change_detail pcd on pcd.record_id = json_extract(pr.extra_value, '$.parcelChangeId')
        where
            pr.route_action = 'CHANGE_PARCEL_INFO'
            and pr.routed_at > '2024-04-30 16:00:00'
            and pcd.field_name = 'dst_store_id'
            and pcd.old_value = 'PH61183J09'
            and pcd.new_value = 'PH61180200'
        group by pr.pno
    )
select
    a.pno
from
    (
            select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-01-01'
            and pr.store_id = 'PH61183J09'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN''DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a
where
    a.rk = 1
    and a.routed_at > '2024-04-30 16:00:00'