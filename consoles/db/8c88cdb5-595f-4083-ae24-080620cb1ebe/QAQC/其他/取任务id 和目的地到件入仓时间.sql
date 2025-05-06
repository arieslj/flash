select
    t.pno
    ,concat('SSRD', plt.id) 任务ID
from bi_pro.parcel_lose_task plt
join tmpale.tmp_th_pno_lj_1123 t on t.pno = plt.pno and t.type = 1
where
    plt.source = 11
    and plt.state in (1,2,3,4)
group by 1;


select
    t.pno
    ,coalesce(a.pr_time, va.pr_time) ptime
from tmpale.tmp_th_pno_lj_1123 t
left join
    (
        select
            pr.pno
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') pr_time
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_1123 t on t.pno = pr.pno and pr.store_name = t.store
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    ) a on a.pno = t.pno and a.rk = 1
left join
    (
        select
            pr.pno
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') pr_time
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_1123 t on t.pno = pr.pno and pr.store_name = t.store
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) va  on va.pno = t.pno and va.rk = 1
where
    t.pno is not null


;

select
    count(distinct plt.pno)
from bi_pro.parcel_lose_task plt
where
    plt.source = 3
    and plt.created_at >= '2023-10-26'
    and plt.created_at < '2023-10-27'