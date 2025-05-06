-- 1.0

select
    plt.pno
    ,plt.id
    ,ddd.CN_element 最后有效路由
    ,ss.name 最后有效路由网点
    ,case plt.state
        when 1 then '待处理'   -- 待处理
        when 2 then '待处理' -- 待处理
        when 3 then '待工单回复'  -- 待工单回复
        when 4 then '已工单回复' -- 已工单回复
        when 5 then '无须追责'  -- 无须追责
        when 6 then '责任人已认定' -- 责任人已认定
    end 当前判责状态
    ,case
        when plt.state = 5 then '改判无须追责'
        when plt.state = 6 and ps.pnt > 1  then '维持有责'
        when plt.state = 6 and ps.pnt = 1 then '未改判'
    end 改判结果
    ,case plt.source
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
    end 问题来源渠道
    ,ddd2.CN_element 包裹当前路由
from bi_pro.parcel_lose_task plt
join fle_staging.sys_store ss on ss.id = plt.last_valid_store_id
left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join bi_pro.parcel_detail pd on pd.pno = plt.pno
left join dwm.dwd_dim_dict ddd2 on ddd2.element = pd.last_valid_action and ddd2.db = 'rot_pro' and ddd2.tablename = 'parcel_route' and ddd2.fieldname = 'route_action'
left join
    (
        select
            pcol.task_id
            ,count(distinct pcol.id) pnt
        from bi_pro.parcel_cs_operation_log pcol
        where
            pcol.type = 1
            and pcol.action = 4
            and pcol.created_at > '2024-07-01'
        group by 1
    ) ps on ps.task_id = plt.id
where
    plt.penalties > 0
    and plt.duty_result = 1
    and plt.created_at > '2024-07-01'
    and plt.created_at < '2024-08-01'
    and ss.category in (8,12)


;


-- 2

with t as
    (
        select
            plt.pno
            ,plt.id
            ,plt.created_at
            ,date_sub(plt.created_at, interval 7 hour) low_create_at
            ,date_sub(plt.updated_at, interval 7 hour) low_update_at
            ,plt.updated_at
            ,ss.name
            ,ddd.CN_element route_action_1
            ,ddd2.CN_element  route_action_2
        from bi_pro.parcel_lose_task plt
        join fle_staging.sys_store ss on ss.id = plt.last_valid_store_id
        left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        left join bi_pro.parcel_detail pd on pd.pno = plt.pno
        left join dwm.dwd_dim_dict ddd2 on ddd2.element = pd.last_valid_action and ddd2.db = 'rot_pro' and ddd2.tablename = 'parcel_route' and ddd2.fieldname = 'route_action'
        where
            plt.source = 3
            and plt.created_at > '2024-07-01'
            and plt.created_at < '2024-08-01'
            and plt.state = 5
            and plt.operator_id in (10000,10001)
            and ss.category in (8,12)
    )
select
    t1.pno
    ,t1.route_action_1 包裹疑似丢失前最后有效路由
    ,t1.name 包裹疑似丢失前最后有效路由网点
    ,t1.created_at 包裹进入丢失的时间
    ,t2.store_name 包裹自动解锁后最后有效路由
    ,ddd.CN_element 包裹自动解锁后最后有效路由
from t t1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,pr.route_action
            ,row_number() over(partition by t1.pno order by pr.routed_at desc) as rn
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-06-30'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) t2 on t2.pno = t1.pno and t2.rn = 1
left join dwm.dwd_dim_dict ddd on ddd.element = t2.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'


;

with t as
    (
        select
            plt.pno
            ,plt.id
            ,plt.created_at
            ,date_sub(plt.created_at, interval 7 hour) low_create_at
            ,date_sub(plt.updated_at, interval 7 hour) low_update_at
            ,plt.updated_at
            ,ss.name
            ,plt.operator_id
            ,ddd.CN_element route_action_1
        from bi_pro.parcel_lose_task plt
        join fle_staging.sys_store ss on ss.id = plt.last_valid_store_id
        left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            plt.created_at > '2024-07-01'
            and plt.created_at < '2024-08-01'
            and plt.state = 5
            and plt.duty_result = 1
            and ss.category in (8,12)
    )
select
    t1.pno
    ,t1.route_action_1 包裹疑似丢失前最后有效路由
    ,t1.name 包裹疑似丢失前最后有效路由网点
    ,case
        when t1.operator_id = 10000 then '系统自动解锁'
        when t1.operator_id != 10000 then 'qaqc改判无责'
    end 解锁方式
    ,ddd.CN_element 包裹自动解锁后最后有效路由
from t t1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,pr.route_action
            ,row_number() over(partition by t1.pno order by pr.routed_at desc) as rn
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-06-30'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) t2 on t2.pno = t1.pno and t2.rn = 1
left join dwm.dwd_dim_dict ddd on ddd.element = t2.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'

