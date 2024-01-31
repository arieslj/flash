select
    a.*
    ,if(a.isappeal_info > 0, 'y', 'n') 是否申诉
    ,if(a.isappeal_flag > 0, 'y', 'n') 是否申诉通过
from
    (
        select
            plt.pno
            ,if(kp.id is null, '小c', '普通KA') 客户类型
            ,plt.created_at 进入闪速认定的时间
            ,if(plt.state = 6, plt.updated_at, null) 闪速认定判责的时间
            ,case plt.state
                when 1 then '丢失件待处理'
                when 2 then '疑似丢失件待处理'
                when 3 then '待工单回复'
                when 4 then '已工单回复'
                when 5 then '无须追责'
                when 6 then '责任人已认定'
            end 闪速认定状态
            ,if(a.pno is not null, '是', '否') 认定丢失之后是否有丢失件解锁
            ,group_concat(distinct case plt2.source
                WHEN 1 THEN 'A-问题件-丢失'
                WHEN 2 THEN 'B-记录本-丢失'
                WHEN 3 THEN 'C-包裹状态未更新'
                WHEN 4 THEN 'D-问题件-破损/短少'
                WHEN 5 THEN 'E-记录本-索赔-丢失'
                WHEN 6 THEN 'F-记录本-索赔-破损/短少'
                WHEN 7 THEN 'G-记录本-索赔-其他'
                WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
                WHEN 9 THEN 'I-问题件-外包装破损险'
                WHEN 10 THEN 'J-问题记录本-外包装破损险'
                when 11 then 'K-超时效包裹'
                when 12 then 'L-高度疑似丢失'
            end ) 进入A来源外的其他来源
            ,sum(if(am.isappeal in (2,3,4,5), 1, 0)) isappeal_info
            ,sum(case
                    when  am.isappeal = 1 then 0
                    when  am.isappeal = 2 then 0
                    when  am.isappeal = 3 then 0
                    when  am.isappeal = 4 then 1
                    when  am.isappeal = 5 or am.isdel = 1 then 1
                end ) isappeal_flag
        from bi_pro.parcel_lose_task plt
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
        left join fle_staging.ka_profile kp on kp.id = plt.client_id
        left join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.losr_task_id') = plt.id
        left join bi_pro.parcel_lose_task plt2 on plt2.pno = plt.pno and plt2.source > 1
        left join
            (
                select
                    plt.pno
                from bi_pro.parcel_lose_task plt
                left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
                join bi_pro.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 4
                left join rot_pro.parcel_route pr on pr.pno = plt.pno and pr.routed_at > '2023-12-31 17:00:00'
                where
                    plt.created_at >= '2024-01-01'
                    and plt.created_at < '2024-01-02'
                    and plt.source = 1
                    and bc.client_id is null
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                    and pr.routed_at > date_sub(pcol.created_at, interval 7 hour)
                group by 1
            ) a on a.pno = plt.pno
        where
            plt.created_at >= '2024-01-01'
            and plt.created_at < '2024-01-02'
            and bc.client_id is null
            and plt.source = 1
        group by 1,2,3,4,5,6
    ) a