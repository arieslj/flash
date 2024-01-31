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
left join my_bi.translations t2 on t2.t_key = a1.duty_reasons and  t2.lang ='zh-CN'