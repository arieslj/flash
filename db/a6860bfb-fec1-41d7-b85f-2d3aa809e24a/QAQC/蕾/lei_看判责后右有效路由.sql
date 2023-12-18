with t as
(
    select
        plt2.pno
        ,pcol.created_at
        ,plt2.client_id
        ,plt2.parcel_created_at
        ,plt2.id
        ,group_concat(distinct ss.name) ss_name
    from ph_bi.parcel_cs_operation_log pcol
    left join ph_bi.parcel_lose_task plt2 on pcol.task_id = plt2.id
    left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt2.id
    left join ph_staging.sys_store ss on ss.id = plr.store_id
    where
        pcol.type = 1
        and pcol.action = 4
        and pcol.operator_id != 10001
        and pcol.created_at >= '2023-10-11'
        and pcol.created_at < '2023-11-01'
    group by 1,2,3,4,5
)
select
    a.PNO
    ,concat(kp.id ,  '_', kp.name) Customer
    ,a.parcel_created_at Pickup_Date
    ,a.created_at Close_Date
    ,a.ss_name Responsible_DC
    ,convert_tz(a.routed_at, '+00:00', '+08:00') Effective_status_Date
    ,a.store_name Effective_Status_DC
#     ,a.EN_element
    ,dp.piece_name District
    ,dp.region_name  Area
    ,a.route_action
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
    ,pi.cod_amount/100 cod
    ,if(oi.client_id in ('AA0080','AA0121','AA0051','AA0139','AA0050'), oi.insure_declare_value, oi.cogs_amount)/100 cogs
from
    (
        select
            t1.*
            ,pr.route_action
            ,pr.routed_at
            ,pr.store_name
            ,pr.store_id
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-09-30'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(t1.created_at, interval 8 hour )  -- 有效路由列举
    ) a
left join ph_staging.ka_profile kp on kp.id = a.client_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = a.pno and pi.created_at > '2023-08-01'
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno  and oi.created_at > '2023-08-01'
where
    a.rk = 1
;

#
# select
#     a.pno
#     ,concat(a.id, a.name) Customer
#     ,a.parcel_created_at Pickup_date
#     ,a.updated_at Close_date
#     ,a.dc Responsible_dc
#     ,convert_tz(a.routed_at, '+00:00', '+08:00') Effective_status_date
#     ,dp.store_name Effective_status_dc
#     ,dp.piece_name District
#     ,dp.region_name Area
#     ,ddd.EN_element Parcel_status
# from
#     (
#         select
#             a1.*
#             ,row_number() over (partition by a1.pno order by a1.routed_at) rk
#         from
#             (
#                 select
#                     plt.pno
#                     ,kp.id
#                     ,kp.name
#                     ,plt.parcel_created_at
#                     ,plt.updated_at
#                     ,pr.routed_at
#                     ,pr.store_id
#                     ,group_concat(distinct ss.name) dc
#         #             ,row_number() over (partition by plt.pno order by pr.routed_at) rk
#                 from ph_bi.parcel_lose_task plt
#                 left join ph_staging.ka_profile kp on kp.id = plt.client_id
#                 join ph_staging.parcel_route pr on plt.pno = pr.pno
#                 join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
#                 left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
#                 left join ph_staging.sys_store ss on ss.id = plr.store_id
#                 where
#                     plt.state = 6
#                     and plt.duty_result = 1
#                     and pr.routed_at > date_sub(plt.updated_at, interval 8 hour )
#                     and pr.routed_at >= date_format(now() ,'%y-%m-01')
#                     and pr.routed_at < curdate()
#                 group by 1,2,3,4,5,6,7
#             ) a1
#     ) a
# left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
# left join ph_staging.parcel_info pi on pi.pno = a.pno
# left join dwm.dwd_dim_dict ddd on ddd.element = pi.state and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_info' and ddd.fieldname = 'state'
# where
#     a.rk = 1

;


