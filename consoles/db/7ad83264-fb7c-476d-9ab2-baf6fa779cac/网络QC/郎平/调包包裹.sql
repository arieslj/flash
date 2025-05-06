
with sc as
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0403 t on t.pno = pr.pno
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at > '2024-01-01'
    )
, de as
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0403 t on t.pno = pr.pno
        where
            pr.route_action = 'DETAIN_WAREHOUSE'
            and pr.routed_at > '2024-01-01'
    )
select
    t.pno
    ,convert_tz(ari.routed_at, '+00:00', '+08:00') 到达DC时间
    ,s1.staff_info_id 第一个交接派送快递员ID
    ,s2.staff_info_id 第一个留仓DCO
    ,s3.staff_info_id 第二个交接派送快递员ID
    ,d1.staff_info_id 第二个留仓DCO
    ,d2.staff_info_id 第三个交接派送快递员ID
    ,d3.staff_info_id 第三个留仓DCO
    ,convert_tz(ret.routed_at, '+00:00', '+08:00') 退回时间
    ,wt.staff_info_id 退回复称操作人员
from tmpale.tmp_ph_pno_lj_0403 t
left join sc s1 on s1.pno = t.pno and s1.rk = 1
left join sc s2 on s2.pno = t.pno and s2.rk = 2
left join sc s3 on s3.pno = t.pno and s3.rk = 3
left join de d1 on d1.pno = t.pno and d1.rk = 1
left join de d2 on d2.pno = t.pno and d2.rk = 2
left join de d3 on d3.pno = t.pno and d3.rk = 3
left join
    (
        select
            pr.pno
            ,max(pr.routed_at) routed_at
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0403 t on t.pno = pr.pno
        where
            pr.route_action = 'SYSTEM_AUTO_RETURN'
            and pr.routed_at > '2024-01-01'
        group by 1
    ) ret on ret.pno = t.pno
left join
    (
        select
            wt.pno
            ,wt.staff_info_id
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join tmpale.tmp_ph_pno_lj_0403 t on t.pno = pr.pno
                where
                    pr.route_action = 'PENDING_RETURN'
                    and pr.routed_at > '2024-01-01'
            ) pr
        join
            (
                select
                    pr.pno
                    ,pr.staff_info_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join tmpale.tmp_ph_pno_lj_0403 t on t.pno = pr.pno
                where
                    pr.route_action = 'STORE_KEEPER_UPDATE_WEIGHT'
                    and pr.routed_at > '2024-01-01'
            )  wt on wt.pno = pr.pno
        where
            wt.routed_at > pr.routed_at
    ) wt on wt.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join
            (
                select
                    s1.pno
                    ,s1.store_id
                from sc s1
                group by 1,2
            ) ss on ss.pno = pr.pno and ss.store_id = pr.store_id
        where
            pr.routed_at > '2024-01-01'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN''DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) ari on ari.pno = t.pno and ari.rk = 1
