/*
  =====================================================================+
  表名称：1854d_ph_qaqc_misdirected_data_monitoring
  功能描述：菲律宾错发包裹监控

  需求来源：
  编写人员: 吕杰
  设计日期：2023-11-22
  修改日期:
  修改人员:
  修改原因:
  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
  +=====================================================================
*/

with t as
    (
        select
            pr.pno '运单号waybill'
            ,pi.client_id '客户ID Client ID'
            ,loi.item_name '物品名称Item Name'
            ,pi.exhibition_weight '物品重量 Item weight'
            ,pi.exhibition_length * pi.exhibition_width * pi.exhibition_height '物品体积Item volume'
            ,ss.name '揽件网点pick-up outlet'
            ,pi.cod_amount/100 'COD金额COD amount'
            ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 'COGS金额COGS amount'
            ,ss2.name '目的网点Destination outlet'
            ,ft.store_name '装车网点loading outlet'
            ,ft.real_leave_time  '发车时间outbound time'
            ,ft.next_store_name  '卸货网点unloading outlet'
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') '到车时间inbound time'
            ,ft.proof_id 出车凭证
            ,'错发有路由' '异常类型Exception Type'
        from ph_staging.parcel_route pr
        left join ph_staging.order_info oi on oi.pno = pr.pno and oi.created_at > date_sub(curdate(), interval 3 month)
        left join ph_staging.parcel_info pi on pi.pno = pr.pno and pi.created_at > date_sub(curdate(), interval 3 month)
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
        left join ph_drds.lazada_order_info_d loi on loi.pno = pr.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.store_id = ft.next_store_id
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'  -- 到件入仓
            and pr.routed_at > date_sub(curdate(), interval 32 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour) -- yesterday
            and pr.store_category not in (8,12)
            and pr.store_id != pi.dst_store_id
    )
select
    t1.*
    ,a2.CN_element '最后一步有效路由Last effective Route'
    ,a2.store_name '操作网点Operational outlet'
    ,convert_tz(a2.routed_at, '+00:00', '+08:00') '操作时间Operation time'
from  t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_name
            ,ddd.CN_element
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.运单号waybill = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and  ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(curdate(), interval 2 day)
    ) a2 on a2.pno = t1.运单号waybill and a2.rk = 1
;

-- 需求 2

with t as
    (
        select
            pr.pno
            ,pr.next_store_name
            ,pr.next_store_id
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,ft.real_arrive_time
            ,ft.proof_id
        from ph_staging.parcel_route pr
        left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id and pr.store_id = ft.store_id
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and ft.real_arrive_time is not null
    )
select
    t1.pno
    ,pi.client_id '客户ID Client ID'
    ,loi.item_name '物品名称Item Name'
    ,loi.item_name '物品名称Item Name'
    ,pi.exhibition_weight '物品重量 Item weight'
    ,pi.exhibition_length * pi.exhibition_width * pi.exhibition_height '物品体积Item volume'
    ,ss.name '揽件网点pick-up outlet'
    ,pi.cod_amount/100 'COD金额COD amount'
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 'COGS金额COGS amount'
    ,ss2.name '目的网点Destination outlet'
    ,t1.store_name '装车网点loading outlet'
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') '发车时间outbound time'
    ,t1.next_store_name  '卸货网点unloading outlet'
    ,t1.real_arrive_time '到车时间inbound time'
    ,t1.proof_id '车辆凭证PVD'
    ,'' '操作网点Operational outlet'
    ,'' '操作时间Operation Time'
    ,'错发无路由' '异常类型Exception Type'
    ,a2.CN_element '最后一步有效路由Last effective Route'
    ,a2.store_name '操作网点Operational outlet'
    ,convert_tz(a2.routed_at, '+00:00', '+08:00') '操作时间Operation time'
from t t1
left join ph_staging.parcel_info pi on pi.pno = t1.pno  and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_drds.lazada_order_info_d loi on loi.pno = t1.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.order_info oi on oi.pno = t1.pno and oi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join
    (
        select
            pr.store_id
            ,pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.next_store_id
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            -- and pr.routed_at < date_sub(curdate(), interval 8 hour)
        group by 1,2
    ) pr on pr.pno = t1.pno and pr.store_id = t1.next_store_id
left join
    (
        select
            pr.pno
           ,pr.routed_at
           ,pr.store_name
           ,ddd.CN_element
           ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    ) a2 on a2.pno = t1.pno and a2.rk = 1
where
    pr.pno is null