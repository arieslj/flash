select
    pr.pno
    ,date (convert_tz(pr.routed_at, '+00:00', '+08:00')) 'departure date'
    ,json_extract(pr.extra_value, '$.proofId') pvd
    ,ft.next_store_name destination
    ,case pi.state
        when 1 then 'RECEIVED'
        when 2 then 'IN_TRANSIT'
        when 3 then 'DELIVERING'
        when 4 then 'STRANDED'
        when 5 then 'SIGNED'
        when 6 then 'IN_DIFFICULTY'
        when 7 then 'RETURNED'
        when 8 then 'ABNORMAL_CLOSED'
        when 9 then 'CANCEL'
    end as parcel_tatus
from
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.extra_value
            ,pr.store_id
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2025-01-15 16:00:00'
            and pr.routed_at < '2025-02-28 16:00:00'
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN' -- 车货关联出港
            and pr.store_id = 'PH53022N00' -- 08 PS1-HUB_Davao
    ) pr
join ph_staging.parcel_info pi on pr.pno = pi.pno and pi.created_at > '2024-10-01'
left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and ft.store_id = pr.store_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2025-01-15 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) va_pr on pr.pno = va_pr.pno and pr.routed_at < va_pr.routed_at
where
    va_pr.pno is null
    and pi.state in (1,2,3,4,6,8)