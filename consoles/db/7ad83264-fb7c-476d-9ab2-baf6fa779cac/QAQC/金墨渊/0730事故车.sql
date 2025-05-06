with t as
    (
        select
            pi.pno
            ,ss.name pick_store
            ,ss2.name dst_store
            ,case pi.article_category
                 when 0 then '文件'
                 when 1 then '干燥食品'
                 when 2 then '日用品'
                 when 3 then '数码产品'
                 when 4 then '衣物'
                 when 5 then '书刊'
                 when 6 then '汽车配件'
                 when 7 then '鞋包'
                 when 8 then '体育器材'
                 when 9 then '化妆品'
                 when 10 then '家居用具'
                 when 11 then '水果'
                 when 99 then '其它'
            end as 品类
            ,pi.exhibition_weight
            ,pi.client_id
            ,oi.cod_amount/100  cod
            ,oi.cogs_amount/100 cogs
        from ph_staging.fleet_van_proof_parcel_detail fvp
        join ph_staging.parcel_info pi on pi.pno = fvp.relation_no
        left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
        where
            fvp.relation_category in (1,3)
            and fvp.created_at > date_sub(curdate(), interval 6 month)
            and fvp.proof_id = 'PN1SR2410A3X'
    )

select
    t1.pno 运单号
    ,t1.pick_store 揽件网点
    ,t1.dst_store 目的网点
    ,t1.品类 物品类型
    ,t1.exhibition_weight 物品重量
    ,t1.client_id 客户ID
    ,t1.cod
    ,t1.cogs
    ,a.CN_element 最后一步有效操作
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 操作时间
    ,a.store_name 操作DC
from t t1
left join
    (
        select
            pr.pno
            ,ddd.CN_element
            ,pr.store_name
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 6 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a on a.pno = t1.pno and a.rk = 1
