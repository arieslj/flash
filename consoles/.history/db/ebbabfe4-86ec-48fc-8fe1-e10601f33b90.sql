select
    pi.pno
    ,pi.client_id
    ,pi.cod_amount/100 cod
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)
from my_staging.parcel_info pi
left join my_staging.order_info oi on oi.pno = pi.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
where
    pi.created_at >= '2024-01-22 16:00:00'
    and pi.created_at < '2024-01-23 16:00:00'
    and pi.returned = 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pi.pno = 'M0601X88X7HU'
    )
select
    t1.*
    ,lead(route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
from t t1
where
    t1.route_action = 'RECEIVED';
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pi.pno = 'M0601X88X7HU'
    )
select
    t1.*
    ,lead(route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
from t t1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pi.pno = 'M0601X88X7HU'
    )
select
    t1.*
    ,lead(t1.route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
    ,lead(t1.next_store_name) over (partition by t1.pno order by t1.routed_at) next_next_store_name
from t t1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
           --  and pi.pno = 'M0601X88X7HU'
    )
select
    *
from
    (
        select
            t1.*
            ,lead(t1.route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
            ,lead(t1.routed_at, 1) over (partition by t1.pno order by t1.routed_at) next_routed_at
            ,lead(t1.routed_at, 2) over (partition by t1.pno order by t1.routed_at) 2_next_routed_at
            ,lead(t1.next_store_name) over (partition by t1.pno order by t1.routed_at) next_next_store_name
        from t t1
    ) a
where
    a.route_action = 'RECEIVED'
    and a.next_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and ( a.2_next_routed_at is null or timestampdiff(minute, a.next_routed_at, a.2_next_routed_at) > 360 );
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
           --  and pi.pno = 'M0601X88X7HU'
    )
select
    *
from
    (
        select
            t1.*
            ,lead(t1.route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
            ,lead(t1.routed_at, 1) over (partition by t1.pno order by t1.routed_at) next_routed_at
            ,lead(t1.routed_at, 2) over (partition by t1.pno order by t1.routed_at) 2_next_routed_at
            ,lead(t1.next_store_name) over (partition by t1.pno order by t1.routed_at) next_next_store_name
        from t t1
    ) a
where
    a.route_action = 'RECEIVED'
    and a.next_action = 'SHIPMENT_WAREHOUSE_SCAN';
;-- -. . -..- - / . -. - .-. -.--
select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER');
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
           --  and pi.pno = 'M0601X88X7HU'
    )
select
    *
from
    (
        select
            t1.*
            ,lead(t1.route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
            ,lead(t1.routed_at, 1) over (partition by t1.pno order by t1.routed_at) next_routed_at
            ,lead(t1.routed_at, 2) over (partition by t1.pno order by t1.routed_at) 2_next_routed_at
            ,lead(t1.next_store_name) over (partition by t1.pno order by t1.routed_at) next_next_store_name
        from t t1
    ) a;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
           --  and pi.pno = 'M0601X88X7HU'
    )
select
    *
from
    (
        select
            t1.*
            ,lead(t1.route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
            ,lead(t1.routed_at, 1) over (partition by t1.pno order by t1.routed_at) next_routed_at
            ,lead(t1.routed_at, 2) over (partition by t1.pno order by t1.routed_at) 2_next_routed_at
            ,lead(t1.next_store_name) over (partition by t1.pno order by t1.routed_at) next_next_store_name
        from t t1
    ) a
where
    a.route_action = 'RECEIVED';
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
           --  and pi.pno = 'M0601X88X7HU'
    )
select
    *
from
    (
        select
            t1.*
            ,lead(t1.route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
            ,lead(t1.routed_at, 1) over (partition by t1.pno order by t1.routed_at) next_routed_at
            ,lead(t1.routed_at, 2) over (partition by t1.pno order by t1.routed_at) 2_next_routed_at
            ,lead(t1.next_store_name) over (partition by t1.pno order by t1.routed_at) next_next_store_name
        from t t1
    ) a
where
    a.route_action = 'RECEIVED';
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
           --  and pi.pno = 'M0601X88X7HU'
    )
select
    *
from
    (
        select
            t1.*
            ,lead(t1.route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
            ,lead(t1.routed_at, 1) over (partition by t1.pno order by t1.routed_at) next_routed_at
            ,lead(t1.routed_at, 2) over (partition by t1.pno order by t1.routed_at) 2_next_routed_at
            ,lead(t1.next_store_name) over (partition by t1.pno order by t1.routed_at) next_next_store_name
        from t t1
    ) a
where
    a.route_action = 'RECEIVED'
    and a.next_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and ( a.2_next_routed_at is null or timestampdiff(minute, a.next_routed_at, a.2_next_routed_at) > 360 );
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
            ,pi.customary_pno
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pi.created_at < '2024-01-23 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
           --  and pi.pno = 'M0601X88X7HU'
    )
, a as
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,lead(t1.route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
                    ,lead(t1.routed_at, 1) over (partition by t1.pno order by t1.routed_at) next_routed_at
                    ,lead(t1.routed_at, 2) over (partition by t1.pno order by t1.routed_at) 2_next_routed_at
                    ,lead(t1.next_store_name,1) over (partition by t1.pno order by t1.routed_at) next_next_store_name
                    ,lead(t1.next_store_id,1) over (partition by t1.pno order by t1.routed_at) next_next_store_id
                from t t1
            ) a
        where
            a.route_action = 'RECEIVED'
            and a.next_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and ( a.2_next_routed_at is null or timestampdiff(minute, a.next_routed_at, a.2_next_routed_at) > 360 )
    )
select
    a1.pno 退件单号
    ,ss.name 退件揽收网点
    ,a1.next_next_store_name 下一网点
    ,convert_tz(a1.next_routed_at, '+00:00', '+08:00') 揽收网点发件出仓时间
    ,pi.cod_amount/100 cod金额
    ,pai.cogs_amount/100 cog金额
    ,if(ha.pno is not null, 'Y', 'N') 下一网点是否上报有发无到
    ,pr.cn_element 最后有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后有效路由时间
from a a1
left join my_staging.sys_store ss on ss.id = a1.ticket_pickup_store_id
left join my_staging.parcel_info pi on pi.pno = a1.customary_pno
left join my_staging.parcel_additional_info pai on pai.pno = a1.customary_pno
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join a a1 on a1.pno = pr.pno
        where
            pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at > '2023-12-31 16:00:00'
            and pr.store_id = a1.next_next_store_id
        group by 1
    ) ha on ha.pno = a1.pno
left join
    (
        select
            pr.pno
            ,ddd.cn_element
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        join  a a1 on a1.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > '2023-12-31 16:00:00'
    ) pr on pr.pno = a1.pno and pr.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
from my_staging.parcel_route pr
join
    (
        select
            a.*
        from
            (
                select
                    pi.pno
                    ,pi.cod_amount
                    ,pi.ticket_pickup_store_id
                    ,pr.next_store_id
                    ,pr.next_store_name
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from my_staging.parcel_info pi
                left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
                where
                    pi.returned = 1
                    and pi.created_at > '2023-12-31 16:00:00'
                    and pi.created_at < '2024-01-23 16:00:00'
            ) a
        where
            a.rk = 1
    ) a on a.pno = pr.pno and a.ticket_pickup_store_id = pr.store_id
where
    pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    and pr.routed_at > a.routed_at;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from my_staging.parcel_info pi
left join dwm.parcel_store_stage_new pssn on pssn.pno = pi.pno and pssn.store_id = pi.ticket_pickup_store_id
where
    pi.returned = 1
    and pi.created_at > '2023-12-31 16:00:00'
    and pi.created_at < '2024-01-23 16:00:00'
    and pssn.last_valid_routed_at > pssn.shipped_at;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pssn.next_store_name
            ,pssn.next_store_id
            ,pssn.store_name
            ,pssn.shipped_at
        from my_staging.parcel_info pi
        left join dwm.parcel_store_stage_new pssn on pssn.pno = pi.pno and pssn.store_id = pi.ticket_pickup_store_id
        where
            pi.returned = 1
            and pi.created_at > '2023-12-31 16:00:00'
            and pi.created_at < '2024-01-23 16:00:00'
            and pssn.last_valid_routed_at > pssn.shipped_at
        group by 1
    )
select
    t1.pno 运单号
    ,t1.store_name 揽收网点
    ,t1.next_store_name 下一站网点
    ,t1.shipped_at 揽收网点发件出仓时间
    ,pr.cn_element 最后有效路由
    ,convert_tz(pr.routed_at, '+00:00',  '+08:00') 最后有效路由时间
    ,if(ha.pno is not null, 'Y', 'N') 下一网点是否上报有发无到
    ,pi.cod_amount/100 cod金额
    ,pai.cogs_amount/100 cogs金额
from t t1
left join my_staging.parcel_info pi on pi.returned_pno = t1.pno
left join my_staging.parcel_additional_info pai on pai.pno = pi.pno
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t a1 on a1.pno = pr.pno
        where
            pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at > '2023-12-31 16:00:00'
            and pr.store_id = a1.next_store_id
        group by 1
    ) ha on ha.pno = t1.pno
left join
    (
        select
            pr.pno
            ,ddd.cn_element
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        join t a1 on a1.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > '2023-12-31 16:00:00'
    ) pr on pr.pno = t1.pno and pr.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.routed_at
from my_staging.parcel_route pr
left join dwm.parcel_store_stage_new pssn on pssn.pno = pr.pno and pssn.store_id = pr.store_id
where
    pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
    and pr.routed_at > '2023-12-31 16:00:00'
    and pr.routed_at < '2024-01-23 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.routed_at
from my_staging.parcel_route pr
# left join dwm.parcel_store_stage_new pssn on pssn.pno = pr.pno and pssn.store_id = pr.store_id
where
    pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
    and pr.routed_at > '2023-12-31 16:00:00'
    and pr.routed_at < '2024-01-23 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.routed_at
from my_staging.parcel_route pr
# left join dwm.parcel_store_stage_new pssn on pssn.pno = pr.pno and pssn.store_id = pr.store_id
where
    pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
    and pr.routed_at > '2023-12-31 16:00:00'
#     and pr.routed_at < '2024-01-23 16:00:00'
order by  2 desc;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pssn.pno
            ,pssn.last_routed_at
            ,pssn.store_name
            ,ft.store_id
        from dwm.parcel_store_stage_new pssn
        left join my_bi.fleet_time ft on ft.next_store_id = pssn.store_id and pssn.van_in_proof_id = ft.proof_id
        where
            pssn.last_route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pssn.last_routed_at >= '2024-01-01'
            and pssn.last_routed_at < '2024-01-24'
            and pssn.first_valid_route_action is null
        group by 1,2,3,4
    )
select
    t1.pno 运单号
    ,if(pi.returned = 1, '退件', '正向') 方向
    ,pi.customary_pno 正向单号
    ,t1.last_routed_at 上报时间
    ,case pr.store_category
          when 1 then 'SP'
          when 2 then 'DC'
          when 4 then 'SHOP'
          when 5 then 'SHOP'
          when 6 then 'FH'
          when 7 then 'SHOP'
          when 8 then 'Hub'
          when 9 then 'Onsite'
          when 10 then 'BDC'
          when 11 then 'fulfillment'
          when 12 then 'B-HUB'
          when 13 then 'CDC'
          when 14 then 'PDC'
        end 最后有效路由网点类型
    ,pr.cn_element 最后有效路由
    ,convert_tz(pr.routed_at, '+00:00',  '+08:00') 最后有效路由时间
    ,pr.staff_info_id 最后有效路由操作人
    ,pr.store_name 最后有效操作网点
    ,t1.store_name 下一站网点
    ,if(plt.pno is not null, 'Y', 'N') 是否判责丢失
    ,plt.dc_store  责任网点
from  t t1
left join
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.staff_info_id
            ,pr.routed_at
            ,ddd.cn_element
            ,pr.store_category
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > '2023-10-01'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join my_staging.parcel_info pi on pi.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(distinct ss.name) dc_store
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.state = 6
            and plt.duty_result = 1
        group by 1
    ) plt on plt.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pssn.pno
            ,pssn.last_routed_at
            ,pssn.store_name
            ,fvp.store_id
        from dwm.parcel_store_stage_new pssn
        left join my_staging.fleet_van_proof_parcel_detail fvp on fvp.relation_no = pssn.pno and fvp.next_store_id = pssn.store_id
        where
            pssn.last_route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pssn.last_routed_at >= '2024-01-01'
            and pssn.last_routed_at < '2024-01-24'
            and pssn.first_valid_route_action is null
        group by 1,2,3,4
    )
select
    t1.pno 运单号
    ,if(pi.returned = 1, '退件', '正向') 方向
    ,pi.customary_pno 正向单号
    ,t1.last_routed_at 上报时间
    ,case pr.store_category
          when 1 then 'SP'
          when 2 then 'DC'
          when 4 then 'SHOP'
          when 5 then 'SHOP'
          when 6 then 'FH'
          when 7 then 'SHOP'
          when 8 then 'Hub'
          when 9 then 'Onsite'
          when 10 then 'BDC'
          when 11 then 'fulfillment'
          when 12 then 'B-HUB'
          when 13 then 'CDC'
          when 14 then 'PDC'
        end 最后有效路由网点类型
    ,pr.cn_element 最后有效路由
    ,convert_tz(pr.routed_at, '+00:00',  '+08:00') 最后有效路由时间
    ,pr.staff_info_id 最后有效路由操作人
    ,pr.store_name 最后有效操作网点
    ,t1.store_name 下一站网点
    ,if(plt.pno is not null, 'Y', 'N') 是否判责丢失
    ,plt.dc_store  责任网点
from  t t1
left join
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.staff_info_id
            ,pr.routed_at
            ,ddd.cn_element
            ,pr.store_category
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > '2023-10-01'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join my_staging.parcel_info pi on pi.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(distinct ss.name) dc_store
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.state = 6
            and plt.duty_result = 1
        group by 1
    ) plt on plt.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at
            ,convert_tz(pr.routed_at, '+00:00',  '+08:00') pr_time
        from my_staging.parcel_route pr
        where
            pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at > '2023-12-31 16:00:00'
            and pr.routed_at < '2024-01-23 16:00:00'
    )
select
    a1.pno 运单号
    ,if(pi.returned = 1, '退件', '正向') 方向
    ,pi.customary_pno 正向单号
    ,a1.pr_time 上报时间
    ,case a1.store_category
          when 1 then 'SP'
          when 2 then 'DC'
          when 4 then 'SHOP'
          when 5 then 'SHOP'
          when 6 then 'FH'
          when 7 then 'SHOP'
          when 8 then 'Hub'
          when 9 then 'Onsite'
          when 10 then 'BDC'
          when 11 then 'fulfillment'
          when 12 then 'B-HUB'
          when 13 then 'CDC'
          when 14 then 'PDC'
    end 最后有效路由网点类型
    ,a1.cn_element  最后有效路由
    ,convert_tz(a1.routed_at, '+00:00',  '+08:00') 最后有效路由时间
    ,a1.staff_info_id 最后有效路由操作人
    ,a1.store_name 最后有效操作网点
    ,a1.sub_store 下一站网点
    ,if(plt.pno is not null, 'Y', 'N') 是否判责丢失
    ,plt.dc_store  责任网点
from
    (
        select
            a.*
        from
            (
                select
                    t1.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,ddd.cn_element
                    ,pr.routed_at
                    ,pr.staff_info_id
                    ,t1.pr_time
                    ,t1.store_name sub_store
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from my_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno and t1.store_id != pr.store_id
                left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                where
                    pr.routed_at < t1.routed_at
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            ) a
        where
            a.rk = 1
    ) a1
left join my_staging.parcel_info pi on pi.pno = a1.pno
left join
    (
        select
            plt.pno
            ,group_concat(distinct ss.name) dc_store
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.state = 6
            and plt.duty_result = 1
        group by 1
    ) plt on plt.pno = a1.pno;
;-- -. . -..- - / . -. - .-. -.--
- 场景2
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
            ,pi.customary_pno
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 0
            and pi.created_at > '2023-12-31 16:00:00'
            and pi.created_at < '2024-01-23 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
           --  and pi.pno = 'M0601X88X7HU'
    )
, a as
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,lead(t1.route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
                    ,lead(t1.routed_at, 1) over (partition by t1.pno order by t1.routed_at) next_routed_at
                    ,lead(t1.routed_at, 2) over (partition by t1.pno order by t1.routed_at) 2_next_routed_at
                    ,lead(t1.next_store_name,1) over (partition by t1.pno order by t1.routed_at) next_next_store_name
                    ,lead(t1.next_store_id,1) over (partition by t1.pno order by t1.routed_at) next_next_store_id
                from t t1
            ) a
        where
            a.route_action = 'RECEIVED'
            and a.next_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and ( a.2_next_routed_at is null or timestampdiff(minute, a.next_routed_at, a.2_next_routed_at) > 360 )
    )
select
    a1.pno 退件单号
    ,ss.name 退件揽收网点
    ,a1.next_next_store_name 下一网点
    ,convert_tz(a1.next_routed_at, '+00:00', '+08:00') 揽收网点发件出仓时间
    ,pi.cod_amount/100 cod金额
    ,pai.cogs_amount/100 cog金额
    ,if(ha.pno is not null, 'Y', 'N') 下一网点是否上报有发无到
    ,pr.cn_element 最后有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后有效路由时间
from a a1
left join my_staging.sys_store ss on ss.id = a1.ticket_pickup_store_id
left join my_staging.parcel_info pi on pi.pno = a1.pno -- 正向就用原单号了
left join my_staging.parcel_additional_info pai on pai.pno = a1.pno
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join a a1 on a1.pno = pr.pno
        where
            pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at > '2023-12-31 16:00:00'
            and pr.store_id = a1.next_next_store_id
        group by 1
    ) ha on ha.pno = a1.pno
left join
    (
        select
            pr.pno
            ,ddd.cn_element
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        join  a a1 on a1.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > '2023-12-31 16:00:00'
    ) pr on pr.pno = a1.pno and pr.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.store_id
            ,pr.next_store_id
            ,pr.next_store_name
            ,pr.route_action
            ,pr.routed_at
            ,pi.customary_pno
        from my_staging.parcel_info pi
        left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > '2023-12-31 16:00:00'
        where
            pi.returned = 0
            and pi.created_at > '2023-12-31 16:00:00'
            and pi.created_at < '2024-01-23 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
           --  and pi.pno = 'M0601X88X7HU'
    )
, a as
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,lead(t1.route_action, 1) over (partition by t1.pno order by t1.routed_at) next_action
                    ,lead(t1.routed_at, 1) over (partition by t1.pno order by t1.routed_at) next_routed_at
                    ,lead(t1.routed_at, 2) over (partition by t1.pno order by t1.routed_at) 2_next_routed_at
                    ,lead(t1.next_store_name,1) over (partition by t1.pno order by t1.routed_at) next_next_store_name
                    ,lead(t1.next_store_id,1) over (partition by t1.pno order by t1.routed_at) next_next_store_id
                from t t1
            ) a
        where
            a.route_action = 'RECEIVED'
            and a.next_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and ( a.2_next_routed_at is null or timestampdiff(minute, a.next_routed_at, a.2_next_routed_at) > 360 )
    )
select
    a1.pno 退件单号
    ,ss.name 退件揽收网点
    ,a1.next_next_store_name 下一网点
    ,convert_tz(a1.next_routed_at, '+00:00', '+08:00') 揽收网点发件出仓时间
    ,pi.cod_amount/100 cod金额
    ,pai.cogs_amount/100 cog金额
    ,if(ha.pno is not null, 'Y', 'N') 下一网点是否上报有发无到
    ,pr.cn_element 最后有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后有效路由时间
from a a1
left join my_staging.sys_store ss on ss.id = a1.ticket_pickup_store_id
left join my_staging.parcel_info pi on pi.pno = a1.pno -- 正向就用原单号了
left join my_staging.parcel_additional_info pai on pai.pno = a1.pno
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join a a1 on a1.pno = pr.pno
        where
            pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at > '2023-12-31 16:00:00'
            and pr.store_id = a1.next_next_store_id
        group by 1
    ) ha on ha.pno = a1.pno
left join
    (
        select
            pr.pno
            ,ddd.cn_element
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        join  a a1 on a1.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > '2023-12-31 16:00:00'
    ) pr on pr.pno = a1.pno and pr.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amoun/100 cogs
from my_staging.parcel_info pi
join tmpale.tmp_my_pno_lj_0126 t on t.pno = pi.pno
left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join my_staging.parcel_additional_info pai on pai.pno = pi2.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
from my_staging.parcel_info pi
join tmpale.tmp_my_pno_lj_0126 t on t.pno = pi.pno
left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join my_staging.parcel_additional_info pai on pai.pno = pi2.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pick.client_name 客户
    ,pick.avg_date_pick 日均揽收量
    ,los.pno_cnt 丢失量
    ,dam.pno_cnt 破损量
from
    (
        select
            a1.client_name
            ,count(distinct a1.pno)/count(distinct a1.pick_date) avg_date_pick
        from
            (
                select
                    case
                        when pi.src_name = 'Allgoodthings' and pi.src_phone = '0182044409' then 'Allgoodthings'
                        when pi.src_name = 'Floofy' and pi.src_phone = '0182992741' then 'Floofy'
                        when pi.src_name = 'RedPanda' and pi.src_phone = '0182992741' then 'RedPanda'
                        else 'Unknown'
                    end client_name
                    ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) pick_date
                    ,pi.pno
                from my_staging.parcel_info pi
                where
                    pi.created_at > '2023-12-31 16:00:00'
                    and pi.returned = 0
                    and pi.src_name in ('Allgoodthings', 'Floofy', 'RedPanda')
                    and pi.src_phone in ('0182044409', '0182992741', '0182992741')
            ) a1
        group by 1
    ) pick
left join
    (
        select
            case
                when pi.src_name = 'Allgoodthings' and pi.src_phone = '0182044409' then 'Allgoodthings'
                when pi.src_name = 'Floofy' and pi.src_phone = '0182992741' then 'Floofy'
                when pi.src_name = 'RedPanda' and pi.src_phone = '0182992741' then 'RedPanda'
                else 'Unknown'
            end client_name
            ,count(distinct plt.pno) pno_cnt
        from my_bi.parcel_lose_task plt
        join my_staging.parcel_info pi on pi.pno = plt.pno and pi.src_name in ('Allgoodthings', 'Floofy', 'RedPanda') and pi.src_phone in ('0182044409', '0182992741', '0182992741')
        where
            plt.updated_at >= '2023-12-31'
            and plt.state = 6
            and plt.duty_result = 1
        group by 1
    ) los on pick.client_name = los.client_name
left join
    (
        select
            case
                when pi.src_name = 'Allgoodthings' and pi.src_phone = '0182044409' then 'Allgoodthings'
                when pi.src_name = 'Floofy' and pi.src_phone = '0182992741' then 'Floofy'
                when pi.src_name = 'RedPanda' and pi.src_phone = '0182992741' then 'RedPanda'
                else 'Unknown'
            end client_name
            ,count(distinct plt.pno) pno_cnt
        from my_bi.parcel_lose_task plt
        join my_staging.parcel_info pi on pi.pno = plt.pno and pi.src_name in ('Allgoodthings', 'Floofy', 'RedPanda') and pi.src_phone in ('0182044409', '0182992741', '0182992741')
        where
            plt.updated_at >= '2023-12-31'
            and plt.state = 6
            and plt.duty_result = 2
        group by 1
    ) dam on pick.client_name = dam.client_name;
;-- -. . -..- - / . -. - .-. -.--
select
                    case
                        when pi.src_name = 'Allgoodthings' and pi.src_phone = '0182044409' then 'Allgoodthings'
                        when pi.src_name = 'Floofy' and pi.src_phone = '0182992741' then 'Floofy'
                        when pi.src_name = 'RedPanda' and pi.src_phone = '0182992741' then 'RedPanda'
                        else 'Unknown'
                    end client_name
                    ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) pick_date
                    ,pi.pno
                from my_staging.parcel_info pi
                where
                    pi.created_at > '2023-12-31 16:00:00'
                    and pi.returned = 0
                    and pi.src_name in ('Allgoodthings', 'Floofy', 'RedPanda')
                    and pi.src_phone in ('0182044409', '0182992741', '0182992741');
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when pi.src_name = 'Allgoodthings' and pi.src_phone = '0182044409' then 'Allgoodthings'
        when pi.src_name = 'Floofy' and pi.src_phone = '0182992741' then 'Floofy'
        when pi.src_name = 'RedPanda' and pi.src_phone = '0182992741' then 'RedPanda'
        else 'Unknown'
    end 客户
    ,plt.pno
    ,plt.updated_at 判责时间
from my_bi.parcel_lose_task plt
join my_staging.parcel_info pi on pi.pno = plt.pno and pi.src_name in ('Allgoodthings', 'Floofy', 'RedPanda') and pi.src_phone in ('0182044409', '0182992741', '0182992741')
where
    plt.updated_at >= '2023-12-31'
    and plt.state = 6
    and plt.duty_result = 1
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,bc.client_name
            ,plt.parcel_created_at
            ,plt.client_id
            ,pi.cod_amount
            ,plt.updated_at
            ,pi.state
            ,pi.finished_at
            ,plt.duty_reasons
            ,case
                when bc.client_name = 'lazada' then lza.end_date
                when bc.client_name = 'shopee' then shp.attempt_end_date
                when bc.client_name = 'tiktok' then ttk.end_date
            end sla_date
        from my_staging.parcel_info pi
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name in ('lazada','shopee','tiktok')
        left join my_bi.parcel_lose_task plt on plt.pno = pi.pno
        left join dwm.dwd_ex_my_lazada_pno_period lza on lza.pno = pi.pno
        left join dwm.dwd_ex_my_shopee_pno_period shp on shp.pno = pi.pno
        left join dwm.dwd_ex_my_tiktok_sla_detail ttk on ttk.pno = pi.pno
        where
            pi.returned = 0
            and pi.created_at >= '2023-09-30 16:00:00'
            and pi.created_at < '2023-12-31 16:00:00'
            and pi.state < 9
            and plt.state = 6
            and plt.duty_result = 1
        group by 1
    )
select
    a1.pno
    ,a1.client_id
    ,a1.client_name
    ,a1.cod_amount/100
    ,pai.cogs_amount/100
    ,a1.parcel_created_at
    ,a2.plt_at
    ,a1.updated_at
    ,t2.t_value
    ,case a1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 当前状态
    ,a3.delivery_attempt_num
    ,if(a1.state = 5, convert_tz(a1.finished_at, '+00:00', '+08:00'), null) 妥投时间
from
    (
        select
            t1.*
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-09-30 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(t1.updated_at, interval 8 hour )
            and pr.routed_at < date_add(t1.sla_date, interval 16 hour)
        group by t1.pno
    ) a1
left join
    (
        select
            plt.pno
            ,plt.created_at plt_at
            ,row_number() over (partition by plt.pno order by plt.created_at desc) rk
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at >= '2023-09-30'
    ) a2 on a1.pno = a2.pno and a2.rk = 1
left join my_staging.parcel_additional_info pai on pai.pno = a1.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-09-30 16:00:00'
            and json_extract(pr.extra_value, '$.deliveryAttempt') = 'true'
            and pr.routed_at < date_sub(t1.updated_at, interval 8 hour)
    ) a3 on a3.pno = a1.pno and a3.rk = 1
left join my_bi.translations t2 on t2.t_key = a1.duty_reasons and  t2.lang ='zh-CN';
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,bc.client_name
            ,plt.parcel_created_at
            ,plt.client_id
            ,pi.cod_amount
            ,plt.updated_at
            ,pi.state
            ,pi.finished_at
            ,plt.duty_reasons
            ,case
                when bc.client_name = 'lazada' then lza.end_date
                when bc.client_name = 'shopee' then shp.attempt_end_date
                when bc.client_name = 'tiktok' then ttk.end_date
            end sla_date
        from my_staging.parcel_info pi
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name in ('lazada','shopee','tiktok')
        left join my_bi.parcel_lose_task plt on plt.pno = pi.pno
        left join dwm.dwd_ex_my_lazada_pno_period lza on lza.pno = pi.pno
        left join dwm.dwd_ex_my_shopee_pno_period shp on shp.pno = pi.pno
        left join dwm.dwd_ex_my_tiktok_sla_detail ttk on ttk.pno = pi.pno
        where
            pi.returned = 0
            and pi.created_at >= '2023-09-30 16:00:00'
            and pi.created_at < '2023-12-31 16:00:00'
            and pi.state < 9
            and plt.state = 6
            and plt.duty_result = 1
        group by 1
    )
select
    a1.pno
    ,a1.client_id
    ,a1.client_name
    ,a1.cod_amount/100
    ,pai.cogs_amount/100
    ,a1.parcel_created_at
    ,a2.plt_at
    ,a1.updated_at
    ,t2.t_value
    ,case a1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 当前状态
    ,a3.delivery_attempt_num
    ,if(a1.state = 5, convert_tz(a1.finished_at, '+00:00', '+08:00'), null) 妥投时间
from
    (
        select
            t1.pno, t1.client_name, t1.parcel_created_at, t1.client_id, t1.cod_amount, t1.updated_at, t1.state, t1.finished_at, t1.duty_reasons, t1.sla_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-09-30 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(t1.updated_at, interval 8 hour )
            and pr.routed_at < date_add(t1.sla_date, interval 16 hour)
        group by t1.pno
    ) a1
left join
    (
        select
            plt.pno
            ,plt.created_at plt_at
            ,row_number() over (partition by plt.pno order by plt.created_at desc) rk
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at >= '2023-09-30'
    ) a2 on a1.pno = a2.pno and a2.rk = 1
left join my_staging.parcel_additional_info pai on pai.pno = a1.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-09-30 16:00:00'
            and json_extract(pr.extra_value, '$.deliveryAttempt') = 'true'
            and pr.routed_at < date_sub(t1.updated_at, interval 8 hour)
    ) a3 on a3.pno = a1.pno and a3.rk = 1
left join my_bi.translations t2 on t2.t_key = a1.duty_reasons and  t2.lang ='zh-CN';
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,bc.client_name
            ,plt.parcel_created_at
            ,plt.client_id
            ,pi.cod_amount
            ,plt.updated_at
            ,pi.state
            ,pi.finished_at
            ,plt.duty_reasons
            ,case
                when bc.client_name = 'lazada' then lza.end_date
                when bc.client_name = 'shopee' then shp.attempt_end_date
                when bc.client_name = 'tiktok' then ttk.end_date
            end sla_date
        from my_staging.parcel_info pi
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name in ('lazada','shopee','tiktok')
        left join my_bi.parcel_lose_task plt on plt.pno = pi.pno
        left join dwm.dwd_ex_my_lazada_pno_period lza on lza.pno = pi.pno
        left join dwm.dwd_ex_my_shopee_pno_period shp on shp.pno = pi.pno
        left join dwm.dwd_ex_my_tiktok_sla_detail ttk on ttk.pno = pi.pno
        where
            pi.returned = 0
            and pi.created_at >= '2023-09-30 16:00:00'
            and pi.created_at < '2023-12-31 16:00:00'
            and pi.state < 9
            and plt.state = 6
            and plt.duty_result = 1
        group by 1
    )
select
    a1.pno 运单号
    ,a1.client_id 客户ID
    ,a1.client_name 客户名称
    ,a1.cod_amount/100 COD
    ,pai.cogs_amount/100 COGS
    ,a1.parcel_created_at 揽收时间
    ,a2.plt_at 最后一次进入闪速时间
    ,a1.updated_at 判责时间
    ,t2.t_value 判责原因
    ,case a1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 当前状态
    ,a3.delivery_attempt_num 尝试派送次数
    ,if(a1.state = 5, convert_tz(a1.finished_at, '+00:00', '+08:00'), null) 妥投时间
from
    (
        select
            t1.pno, t1.client_name, t1.parcel_created_at, t1.client_id, t1.cod_amount, t1.updated_at, t1.state, t1.finished_at, t1.duty_reasons, t1.sla_date
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-09-30 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(t1.updated_at, interval 8 hour )
            and pr.routed_at < date_add(t1.sla_date, interval 16 hour)
        group by t1.pno
    ) a1
left join
    (
        select
            plt.pno
            ,plt.created_at plt_at
            ,row_number() over (partition by plt.pno order by plt.created_at desc) rk
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at >= '2023-09-30'
    ) a2 on a1.pno = a2.pno and a2.rk = 1
left join my_staging.parcel_additional_info pai on pai.pno = a1.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-09-30 16:00:00'
            and json_extract(pr.extra_value, '$.deliveryAttempt') = 'true'
            and pr.routed_at < date_sub(t1.updated_at, interval 8 hour)
    ) a3 on a3.pno = a1.pno and a3.rk = 1
left join my_bi.translations t2 on t2.t_key = a1.duty_reasons and  t2.lang ='zh-CN';
;-- -. . -..- - / . -. - .-. -.--
select
    min(pi.created_at)
from my_staging.parcel_info pi
where
    pi.state in (1,2,3,4,6);