with t as
    (
        select
            plt.id
            ,plt.pno
        from ph_bi.parcel_lose_task plt
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
        where
            plt.created_at >= '2023-10-01'
            and plt.created_at < '2023-11-01'
            and pcol.action = 4
        group by 1,2

        union all

        select
            plt.id
            ,plt.pno
        from ph_bi.parcel_lose_task plt
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 4
        where
            plt.created_at >= '2023-10-01'
            and plt.created_at < '2023-11-01'
            and plt.state = 5
            and plt.operator_id not in (10000,10001)
            and pcol.id is null
        group by 1,2
    )
select
    concat('SSRD', plt2.id) 任务ID
    ,plt2.created_at 任务生成时间
    ,plt2.pno
    ,case plt2.source
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
    end 来源
    ,case
        when plt2.state =  1 then '丢失件待处理'
        when plt2.state =  2 then '疑似丢失件待处理'
        when plt2.state =  3 then '待工单回复'
        when plt2.state =  4 then '已工单回复'
        when plt2.state =  5 and plt2.operator_id not in (10000,10001) then '人工-无须追责'
        when plt2.state =  5 and plt2.operator_id in (10000,10001) then '系统-无须追责'
        when plt2.state =  6 then '责任人已认定'
    end 当前状态
    ,case
        when a1.operator_id in (10000,10001) and a1.action = 3 then '系统-无须追责'
        when a1.operator_id  not in (10000,10001) and a1.action = 3 then '人工-无须追责'
        when a1.action = 4 then '责任人已认定'
    end 第一次判责状态
    ,a1.created_at 第一次判责时间
    ,case plt2.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 当前判责类型
    ,t2.t_value 判责原因
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
        ELSE '其他'
	end as '包裹状态'
    ,ss.name 目的地网点
    ,wo.created_at 工单创建时间
    ,wor.created_at 工单回复时间
    ,wo.created_staff_info_id 工单创建人
    ,a1.operator_id 判责操作人
    ,if(a2.duty_num > 1, '是', '否') 是否改判
    ,plt2.parcel_created_at 揽收时间
    ,plt2.client_id 客户ID
    ,las.CN_element 最后操作有效路由
    ,las.store_name 最后操作网点
    ,if(a3.pno is null , '否', '是') 第一次判责后是否产生有效路由
    ,a3.CN_element 有效路由
from ph_bi.parcel_lose_task plt2
join t t1 on t1.id = plt2.id
left join ph_staging.parcel_info pi on pi.pno = plt2.pno
left join
    (
        select
            t1.id
            ,pcol.action
            ,pcol.created_at
            ,pcol.operator_id
            ,row_number() over (partition by t1.id order by pcol.created_at) rk
        from ph_bi.parcel_cs_operation_log pcol
        join t t1 on t1.id = pcol.task_id
        where
            pcol.action in (3,4)
    ) a1 on a1.id = plt2.id and a1.rk = 1
left join
    (
        select
            t1.id
            ,wo.created_at
            ,wo.created_staff_info_id
            ,row_number() over (partition by t1.id order by wo.created_at) rk
        from ph_bi.work_order wo
        join t t1 on t1.id = wo.loseparcel_task_id
    ) wo on wo.id = t1.id and wo.rk = 1
left join
    (
        select
            t1.id
            ,wor.created_at
            ,row_number() over (partition by t1.id order by wor.created_at) rk
        from ph_bi.work_order wo
        join t t1 on t1.id = wo.loseparcel_task_id
        left join ph_bi.work_order_reply wor on wor.order_id = wo.id
    ) wor on wor.id = t1.id and wor.rk = 1
left join
    (
         select
            t1.id
            ,count(pcol.id) duty_num
        from ph_bi.parcel_cs_operation_log pcol
        join t t1 on t1.id = pcol.task_id
        where
            pcol.action in (3,4)
        group by 1
    ) a2 on a2.id = t1.id
left join
    (
        select
            pr.pno
            ,ddd2.CN_element
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join
            (
                select
                    t1.pno
                    ,min(pcol.created_at) p_time
                from ph_bi.parcel_cs_operation_log pcol
                join t t1 on t1.id = pcol.task_id
                where
                    pcol.action in (3,4)
                group by 1
            ) pc on pc.pno = pr.pno
        left join dwm.dwd_dim_dict ddd2 on ddd2.element = pr.route_action and ddd2.tablename = 'parcel_route'
        where
            pr.routed_at > '2023-08-31 16:00:00'
            and pr.routed_at > date_sub(pc.p_time, interval 8 hour)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a3  on a3.pno = t1.pno and a3.rk = 1
left join ph_bi.translations t2 on t2.t_key = plt2.duty_reasons and  t2.lang ='zh-CN'
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
# left join ph_bi.parcel_detail pd  on pd.pno = plt2.pno
# left join ph_staging.sys_store ss_pd on ss_pd.id = pd.last_valid_store_id
# left join dwm.dwd_dim_dict ddd on ddd.element = pd.last_valid_action and ddd.tablename = 'parcel_route'
left join
    (
        select
            pr.pno
            ,pr.store_name
            ,ddd2.CN_element
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd2 on ddd2.element = pr.route_action and ddd2.tablename = 'parcel_route'
        where
            pr.routed_at > '2023-08-31 16:00:00'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) las on las.pno = t1.pno and las.rk = 1