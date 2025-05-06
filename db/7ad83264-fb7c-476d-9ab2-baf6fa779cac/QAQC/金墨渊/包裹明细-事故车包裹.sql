select
    t.pno
    ,ss.name 揽件DC
    ,pi.client_id 客户ID
    ,if(bc.client_name = 'tiktok', toi.shop_name, kp.name) 店铺名称
    ,case pi.article_category
        when 0 then '文件/document'
        when 1 then '干燥食品/dry food'
        when 2 then '日用品/daily necessities'
        when 3 then '数码产品/digital product'
        when 4 then '衣物/clothes'
        when 5 then '书刊/Books'
        when 6 then '汽车配件/auto parts'
        when 7 then '鞋包/shoe bag'
        when 8 then '体育器材/sports equipment'
        when 9 then '化妆品/cosmetics'
        when 10 then '家居用具/Houseware'
        when 11 then '水果/fruit'
        when 99 then '其它/other'
    end 物品类型
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 COGS
    ,convert_tz(pn5.routed_at, '+00:00', '+08:00') PN5装车时间
    ,ss2.name 目的DC
    ,las.CN_element 最后一步操作路由
    ,convert_tz(las.routed_at, '+00:00', '+08:00') 操作时间
    ,las.store_name 操作DC
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0723 t on t.pno = pi.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_ph_tiktok_order_info toi on pi.pno = toi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join ph_staging.order_info oi on oi.pno = pi.pno and oi.created_at > '2024-04-01'
left join
    (
        select
            t.pno
            ,pr.routed_at
            ,row_number() over (partition by t.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0723 t on t.pno = pr.pno
        where
            pr.routed_at > '2024-07-14'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.store_id = 'PH19280F01'  -- PN5
    ) pn5 on pn5.pno = pi.pno and pn5.rk = 1
left join
    (
        select
            t.pno
            ,pr.routed_at
            ,pr.store_name
            ,ddd.CN_element
            ,row_number() over (partition by t.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0723 t on t.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > '2024-07-14'
            and pr.route_action in('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) las on las.pno = pi.pno and las.rk = 1
where
    pi.created_at > '2024-07-01'

;


select
    a.pno
    ,a.CN_element 最后一步有效路由
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 操作时间
    ,a.store_name 操作网点
from
    (
        select
            t.pno
            ,pr.routed_at
            ,pr.store_name
            ,ddd.CN_element
            ,row_number() over (partition by t.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0806 t on t.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
           and pr.route_action in('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a
where
    a.rk = 1


;


select * from tmpale.tmp_ph_pno_lj_0723