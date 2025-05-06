     /*
        =====================================================================+
        表名称：2235d_ph_no_arrival_data
        功能描述：菲律宾有发无到数据监控

        需求来源：
        编写人员: 吕杰
        设计日期：2024-08-20
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================
      */

select
    t1.pno
    ,dp.piece_name 片区District
    ,dp.region_name 大区Area
    ,pi.client_id '客户ID Customer ID'
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end '客户类型Customer Type'
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
    end as '物品类型Item Type'
    ,pi.exhibition_weight/1000 '物品重量Item Weigh'
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) '物品体积Item Volume'
    ,oi.cod_amount/100 'COD金额COD Amount'
    ,oi.cogs_amount/100 'COGS金额COGS Amount'
    ,ss.name '揽件网点Pick-up Outlet'
    ,ss2.name '目的地网点DST'
    ,ft.store_name '装车网点Loading Outlet'
    ,dp.store_name '卸车网点Unloading Outlet'
    ,t1.van_in_proof_id '车辆凭证PVD'
    ,convert_tz(t1.van_arrived_at, '+00:00', '+08:00') '到港时间Inbound Attendance Date'
    ,t1.arrival_pack_no '集包号Bagging Code'
    ,pk.seal_count 集包数量
    ,ddd.CN_element 最新有效路由
    ,pss.last_valid_route_staff_id 操作人ID
    ,pss.ss_name 操作网点
   ,convert_tz(pss.last_valid_routed_at, '+00:00', '+08:00') 操作时间
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
left join ph_staging.pack_info pk on pk.pack_no = t1.arrival_pack_no
left join
    (
        select
            pssn.pno
            ,pssn.last_valid_store_id
            ,pssn.last_valid_route_action
            ,pssn.last_valid_route_staff_id
            ,pssn.last_valid_routed_at
            ,ss3.name ss_name
            ,row_number() over (partition by pssn.pno order by pssn.last_valid_routed_at desc) as rn
        from dw_dmd.parcel_store_stage_new pssn
        left join ph_staging.sys_store ss3 on ss3.id = pssn.last_valid_store_id
        where
            pssn.last_valid_routed_at > date_sub(curdate(), interval 1 month)
    ) pss on pss.pno = t1.pno and pss.rn = 1
left join dwm.dwd_dim_dict ddd on ddd.element = pss.last_valid_route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.pno is null