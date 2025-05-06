-- 仓内HUB

select
#     count(distinct pr.pno) HUB_仓内48H
    distinct
    pr.pno
from
    (
        select
            pi.pno
            ,ss.name
            ,pr.routed_at
            ,row_number() over (partition by pi.pno order by pr.routed_at desc) rk
        from my_staging.parcel_info pi
        join my_staging.sys_store ss on ss.id = pi.duty_store_id
        join my_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.duty_store_id
        where
            pi.created_at > '2024-09-30 16:00:00'
            and pi.state not in (5,7,8,9)
            and ss.category in (8,12)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr
where
    pr.rk = 1
    and timestampdiff(hour, pr.routed_at, now()) > 56 -- 48 + 7


;


-- 揽收
select
    distinct
    if(awl.store_id is not null, '爆仓', '非爆仓') 是否爆仓
#     ,count(distinct pr.pno) 包裹量
   , pr.pno
from
    (
        select
            pi.pno
            ,pr.routed_at
            ,ss.id
            ,ss.name
            ,row_number() over (partition by pi.pno order by pr.routed_at desc) rk
        from my_staging.parcel_info pi
        join my_staging.sys_store ss on ss.id = pi.duty_store_id
        join my_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'RECEIVED'
        where
            pi.created_at > '2024-09-30 16:00:00'
            and pi.state = 1
            and ss.category not in (8,12) -- 非HUB
    ) pr
left join my_nl.abnormal_white_list awl on awl.store_id = pr.id and awl.type = 2 and awl.start_date <= date_sub(curdate(), 1) and awl.end_date >= date_sub(curdate(), 1)
where
    pr.rk = 1
    and timestampdiff(hour , pr.routed_at, now()) > 32 -- 24 + 8
# group by 1


;





-- 派送

select
    distinct
    if(awl.store_id is not null, '爆仓', '非爆仓') 是否爆仓
#     ,count(distinct pr.pno) 包裹量
    ,pr.pno
from
    (
        select
            pi.pno
            ,pr.routed_at
            ,ss.id
            ,ss.name
            ,row_number() over (partition by pi.pno order by pr.routed_at desc) rk
        from my_staging.parcel_info pi
        join my_staging.sys_store ss on ss.id = pi.duty_store_id
        join my_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        where
            pi.created_at > '2024-09-30 16:00:00'
            and pi.state = 3
            and ss.category not in (8,12) -- 非HUB
    ) pr
left join my_nl.abnormal_white_list awl on awl.store_id = pr.id and awl.type = 2 and awl.start_date <= date_sub(curdate(), 1) and awl.end_date >= date_sub(curdate(), 1)
where
    pr.rk = 1
    and timestampdiff(hour , pr.routed_at, now()) > 32 -- 24 + 8



;


-- 仓内

select
    distinct
    if(awl.store_id is not null, '爆仓', '非爆仓') 是否爆仓
    ,pr.pno
#     ,count(distinct if(timestampdiff(hour , pr.routed_at, now()) > 79 , pr.pno, null)) 包裹量
from
    (
        select
            pi.pno
            ,ss.name
            ,ss.id
            ,pr.routed_at
            ,row_number() over (partition by pi.pno order by pr.routed_at desc) rk
        from my_staging.parcel_info pi
        join my_staging.sys_store ss on ss.id = pi.duty_store_id
        join my_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.duty_store_id
        where
            pi.created_at > '2024-09-30 16:00:00'
            and pi.state not in (1,3,5,7,8,9)
            and ss.category not in (8,12)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr
left join my_nl.abnormal_white_list awl on awl.store_id = pr.id and awl.type = 2 and awl.start_date <= date_sub(curdate(), 1) and awl.end_date >= date_sub(curdate(), 1)
where
    pr.rk = 1
    and awl.store_id is null
    and timestampdiff(hour , pr.routed_at, now()) > 80 -- 48+
# group by 1

union all

select
    distinct
    if(awl.store_id is not null, '爆仓', '非爆仓') 是否爆仓
    ,pr.pno
#     ,count(distinct if(timestampdiff(hour , pr.routed_at, now()) > 175 , pr.pno, null)) 包裹量
from
    (
        select
            pi.pno
            ,ss.name
            ,ss.id
            ,pr.routed_at
            ,row_number() over (partition by pi.pno order by pr.routed_at desc) rk
        from my_staging.parcel_info pi
        join my_staging.sys_store ss on ss.id = pi.duty_store_id
        join my_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.duty_store_id
        where
            pi.created_at > '2024-09-30 16:00:00'
            and pi.state not in (1,3,5,7,8,9)
            and ss.category not in (8,12)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr
left join my_nl.abnormal_white_list awl on awl.store_id = pr.id and awl.type = 2 and awl.start_date <= date_sub(curdate(), 1) and awl.end_date >= date_sub(curdate(), 1)
where
    pr.rk = 1
    and awl.store_id is not null
    and timestampdiff(hour , pr.routed_at, now()) > 176 -- 168+8



;





-- 中转


select
    distinct
    if(awl.store_id is not null, '爆仓', '非爆仓') 是否爆仓
    ,a2.pno
#     ,count(distinct a2.pno) 包裹量
from
    (
        select
            a1.pno
            ,a1.id
            ,coalesce(ft.sign_time, ft.real_arrive_time, ft.plan_arrive_time) use_time
            ,convert_tz(coalesce(ft.sign_time, ft.real_arrive_time, ft.plan_arrive_time), '+08:00', '+00:00') use_time_at
        from
            (
                select
                    pr.pno
                    ,pr2.extra_value
                    ,pr.id
                    ,row_number() over (partition by pr.pno order by pr2.routed_at desc) rk
                from
                    (
                        select
                            pi.pno
                            ,ss.name
                            ,ss.id
                        from my_staging.parcel_info pi
                        join my_staging.sys_store ss on ss.id = pi.duty_store_id
                        left join
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                from my_staging.parcel_route pr
                                where
                                    pr.routed_at > '2024-09-30 16:00:00'
                                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                            ) pr on pr.pno = pi.pno and pr.store_id = pi.duty_store_id
                        where
                            pi.created_at > '2024-09-30 16:00:00'
                            and pi.state not in (1,3,5,7,8,9)
                            and ss.category not in (8,12)
                            and pr.pno is null
                    ) pr
                left join my_staging.parcel_route pr2  on pr2.pno = pr.pno and pr2.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr2.next_store_id = pr.id
            ) a1
        left join my_bi.fleet_time ft on ft.proof_id = json_extract(a1.extra_value, '$.proofId') and ft.next_store_id = a1.id
        where
            a1.rk = 1
    )  a2
left join my_nl.abnormal_white_list awl on awl.store_id = a2.id and awl.type = 2 and awl.start_date <= date_sub(curdate(), 1) and awl.end_date >= date_sub(curdate(), 1)
left join
    (
        select
            pr.pno
            ,pr.routed_at
        from my_staging.parcel_route pr
        join my_staging.parcel_info pi2 on pi2.pno = pr.pno
        where
            pr.routed_at > '2024-09-30 16:00:00'
            and pi2.created_at > '2024-09-30 16:00:00'
            and pi2.state not in (1,3,5,7,8,9)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr on pr.pno = a2.pno and pr.routed_at > a2.use_time_at
where
    pr.pno is null
    and timestampdiff(hour, a2.use_time_at, now()) > 56 -- 24+8