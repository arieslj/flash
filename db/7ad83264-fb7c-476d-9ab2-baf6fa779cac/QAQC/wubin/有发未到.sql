select
    t1.pno
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
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
    end as 物品类型
    ,pi.exhibition_weight/1000 物品重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 物品体积
    ,oi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 COGS金额
    ,ss.name 揽件网点
    ,ss2.name 目的地网点
    ,ft.store_name 装车网点
    ,dp.store_name 卸车网点
    ,t1.van_in_proof_id 车辆凭证
    ,convert_tz(t1.van_arrived_at, '+00:00', '+08:00') 到港时间
    ,t1.arrival_pack_no 集包号
from
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,pssn.store_id
            ,pssn.van_in_proof_id
            ,pssn.arrival_pack_no
        from dw_dmd.parcel_store_stage_new pssn
        where
            pssn.van_arrived_at > date_sub(curdate() , interval 32 hour)
            and pssn.van_arrived_at < date_sub(curdate(), interval 8 hour)
    ) t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            from ph_staging.parcel_route pr
        where
            pr.routed_at > date_sub(curdate() , interval 32 hour)
            and pr.routed_at < date_add(curdate(), interval 4 hour)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr on t1.pno = pr.pno and pr.routed_at > t1.van_arrived_at
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.order_info oi on oi.pno = t1.pno and oi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join ph_bi.fleet_time ft on ft.proof_id = t1.van_in_proof_id and ft.next_store_id = t1.store_id
where
    pr.pno is null

