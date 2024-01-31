-- 背景：如果是丢失/破损找到包裹，COD正向未满足尝试派送失败可以考虑继续派送拿回cod

left join ph_bi.translations t2 on t2.t_key = plt2.duty_reasons and  t2.lang ='zh-CN';
# left join ph_staging.parcel_info pi on pi.pno = plt.pno
# left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
# left join ph_staging.order_info oi on oi.pno
with t as
    (
        select
            plt.pno
            ,plt.client_id
            ,plt.duty_reasons
            ,bc.client_name
            ,plt.parcel_created_at
            ,date_sub(plt.updated_at, interval 8 hour) update_time
        from ph_bi.parcel_lose_task plt
        join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        where
            plt.parcel_created_at >= '2023-10-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.duty_result = 1
            and plt.state = 6
        group by 1,2,3,4,5,6
    )
select
    month(a1.parcel_created_at) 揽收月份
    ,a1.pno 包裹号
    ,pi2.pno 正向单号
    ,a1.parcel_created_at 揽收时间
    ,a1.client_name
    ,t2.t_value 判责原因
    ,if(pi2.cod_enabled = 1, 'y', 'n') 是否cod
    ,pi2.cod_amount/100 cod金额
    ,if(a1.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,if(pi.returned = 1, dai.returned_delivery_attempt_num, dai.delivery_attempt_num) 尝试派送次数
from
    (
        select
            t1.*
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > t1.update_time
        group by 1,2,3,4,5,6
    ) a1
left join ph_staging.parcel_info pi on pi.pno = a1.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_bi.translations t2 on t2.t_key = a1.duty_reasons and  t2.lang ='zh-CN'
left join ph_staging.delivery_attempt_info dai on dai.pno = pi2.pno