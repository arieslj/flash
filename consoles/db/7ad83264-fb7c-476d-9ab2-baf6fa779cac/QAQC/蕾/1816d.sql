/*
  =====================================================================+
  表名称：1816d_ph_high_value_monitor
  功能描述：菲律宾高价值包裹监控

  需求来源：
  编写人员: 吕杰
  设计日期：2023-10-30
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
            oi.pno
            ,oi.insure_declare_value/100 cogs
            ,oi.cod_amount/100 cod
            ,oi.remark
            ,pi.client_id
            ,pi.ticket_pickup_store_id
            ,pi.dst_store_id
            ,pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,pi.created_at
            ,pi.ticket_pickup_staff_info_id
            ,oi.src_name
            ,oi.src_phone
            ,oi.dst_name
            ,oi.dst_phone
            ,oi.dst_store_id oi_dst_store_id
            ,oi.dst_detail_address
            ,pi.state
            ,oi.weight
            ,pi.exhibition_weight
        from ph_staging.order_info oi
        join dwm.dwd_dim_bigClient bc on bc.client_id = oi.client_id
        left join ph_staging.parcel_info pi on oi.pno = pi.pno and pi.created_at > date_sub(curdate(), interval 3 month)
        where
            oi.cod_amount > 500000
            and bc.client_name = 'lazada'
            and oi.created_at > date_sub(curdate(), interval 3 month)
            and oi.state < 3
            and ( pi.state is null or pi.state in (1,2,3,4,6))
    )
select
    convert_tz(t1.created_at, '+00:00', '+08:00') 'Pick up date'
    ,concat(kp.id, '-', kp.name) Customer
    ,t1.pno 'Tracking number'
    ,dp.item_name 'Item name'
    ,ss_pick.name 'Pickup branch'
    ,t1.ticket_pickup_staff_info_id 'Pickup courier'
    ,ss_dst.name 'Destination branch'
    ,t1.dst_detail_address 'Recipient address'
    ,t1.cod as 'COD_AMOUNT'
    ,t1.cogs as 'COGS_AMOUNT'
    ,t1.weight/1000 'Order weight/kg'
    ,t1.exhibition_weight/1000 'Weight/kg'
    ,case t1.state
        when 1 then 'RECEIVED'
        when 2 then 'IN_TRANSIT'
        when 3 then 'DELIVERING'
        when 4 then 'STRANDED'
        when 5 then 'SIGNED'
        when 6 then 'IN_DIFFICULTY'
        when 7 then 'RETURNED'
        when 8 then 'ABNORMAL_CLOSED'
        when 9 then 'CANCEL'
    end 'Status'
    ,t1.src_name Seller
    ,t1.src_phone 'Seller number'
    ,t1.dst_name Consignee
    ,t1.dst_phone 'Consignee number'
    ,sp.name 'Consignee province'
    ,sc.name 'Consignee city'
    ,sd.name 'Consignee barangay'
    ,datediff(curdate(), ps.first_valid_routed_at) days
    ,las.EN_element 'Last operation'
    ,convert_tz(las.routed_at, '+00:00', '+08:00') 'Operation time'
    ,las.store_name 'Operator hub'
#     ,if(bc.client_name = 'lazada', oi.remark, null) lazada_order_id
    ,if(bc.client_name = 'lazada', substring(t1.remark, -5), null) lazada_order_id
from t t1
# left join ph_staging.parcel_info pi on t1.pno = pi.pno and pi.created_at > date_sub(curdate(), interval 3 month )
left join ph_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.drds_ph_lazada_order_info_d dp on dp.pno = t1.pno
left join ph_staging.sys_store ss_pick on ss_pick.id = t1.ticket_pickup_store_id
left join ph_staging.sys_store ss_dst on ss_dst.id = coalesce(t1.dst_store_id, t1.oi_dst_store_id)
left join ph_staging.sys_province sp on sp.code = t1.dst_province_code
left join ph_staging.sys_city sc on sc.code = t1.dst_city_code
left join ph_staging.sys_district sd on sd.code = t1.dst_district_code
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join
    (-- 包裹最新网点
        select
            pssn.*
            ,row_number() over (partition by pssn.pno order by pssn.valid_store_order) rk
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        where
            pssn.created_at > date_sub(curdate(), interval 3 month )
    ) ps on ps.pno = t1.pno and ps.rk = 1
left join
    (-- 最新有效路由
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_name
            ,pr.route_action EN_element
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
       -- left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 3 month )
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) las on las.pno = t1.pno and las.rk = 1



