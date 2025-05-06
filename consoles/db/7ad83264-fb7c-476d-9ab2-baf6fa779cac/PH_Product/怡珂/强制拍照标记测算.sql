select
    a.pno
    ,'正向' 流向
    ,a.max_value/100 包裹价值取最大
from
    (
        select
            ps.pno
            ,pi.cod_amount
            ,pai.cogs_amount
            ,greatest(coalesce(pi.cod_amount, 0), coalesce(pai.cogs_amount, 0)) max_value
            ,datediff(now(), ps.arrive_dst_route_at) diff_days
        from ph_bi.parcel_sub ps
        join ph_staging.parcel_info pi on pi.pno = ps.pno
        left join ph_staging.parcel_additional_info pai on pai.pno = ps.pno
        where
            pi.state in (1,2,3,4,6)
            and pi.returned = 0
            and ps.arrive_dst_route_at > '1970-01-01 00:00:00'
    ) a
where
    ( a.max_value < 500000 and a.diff_days >= 5 )
    or ( a.max_value >= 500000 and a.diff_days >= 3 )

union all

select
    a.pno
    ,'反向' 流向
    ,a.max_value 包裹价值取最大
from
    (
        select
            pi.pno
            ,oi.cod_amount
            ,oi.cogs_amount
            ,greatest(coalesce(oi.cod_amount, 0), coalesce(oi.cogs_amount, 0)) max_value
            ,datediff(now(), convert_tz(pi.created_at, '+00:00', '+08:00')) diff_days
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.customary_pno
        left join ph_staging.parcel_route pr on pi.pno = pr.pno and  pr.store_id != pi.ticket_pickup_store_id and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
        where
            pr.pno is null
            and pi.state in (1,2,3,4,6)
            and pi.returned = 1
    ) a
where
    ( a.max_value < 500000 and a.diff_days >= 5 )
    or ( a.max_value >= 500000 and a.diff_days >= 3 )



