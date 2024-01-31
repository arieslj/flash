select
    pr.pno '运单号waybill'
    ,pi.client_id '客户ID Client ID'
    ,loi.item_name 物品名称Item Name
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
    and pr.store_id != pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno '运单号waybill'
    ,pi.client_id '客户ID Client ID'
    ,loi.item_name '物品名称Item Name'
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
    and pr.store_id != pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            ft.proof_id
            ,fvp.relation_no
            ,ft.next_store_id
        from ph_bi.fleet_time ft
        left join ph_staging.fleet_van_proof_parcel_detail fvp on fvp.proof_id = ft.proof_id and fvp.relation_category = 1
        where
            ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
            and ft.real_arrive_time < curdate()
            and ft.arrive_type in (3,5)
        group by 1,2,3
    )
select
    t1.*
from  t t1
left join
    (
        select
            pr.store_id
            ,pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.relation_no = pr.pno and pr.store_id = t1.next_store_id
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
        group by 1,2
    ) pr on pr.pno = t1.relation_no and pr.store_id = t1.next_store_id
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            ft.proof_id
            ,fvp.relation_no
            ,ft.next_store_id
            ,ft.next_store_name
        from ph_bi.fleet_time ft
        left join ph_staging.fleet_van_proof_parcel_detail fvp on fvp.proof_id = ft.proof_id and fvp.relation_category = 1
        where
            ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
            and ft.real_arrive_time < curdate()
            and ft.arrive_type in (3,5)
        group by 1,2,3,4
    )
select
    t1.*
from  t t1
left join
    (
        select
            pr.store_id
            ,pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.relation_no = pr.pno and pr.store_id = t1.next_store_id
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
        group by 1,2
    ) pr on pr.pno = t1.relation_no and pr.store_id = t1.next_store_id
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            ft.proof_id
            ,fvp.relation_no
            ,ft.store_id
            ,ft.store_name
            ,ft.next_store_id
            ,ft.next_store_name
        from ph_bi.fleet_time ft
        left join ph_staging.fleet_van_proof_parcel_detail fvp on fvp.proof_id = ft.proof_id and fvp.relation_category = 1
        where
            ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
            and ft.real_arrive_time < curdate()
            and ft.arrive_type in (3,5)
        group by 1,2,3,4,5,6
    )
select
    t1.*
from  t t1
left join
    (
        select
            pr.store_id
            ,pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.relation_no = pr.pno and pr.store_id = t1.next_store_id
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
        group by 1,2
    ) pr on pr.pno = t1.relation_no and pr.store_id = t1.next_store_id
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
            ,pr.next_store_name
            ,pr.next_store_id
        from ph_staging.parcel_route pr
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
    )
select
    t1.*
from  t t1
left join
    (
        select
            pr.store_id
            ,pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.next_store_id
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
        group by 1,2
    ) pr on pr.pno = t1.pno and pr.store_id = t1.next_store_id
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
            ,pr.next_store_name
            ,pr.next_store_id
        from ph_staging.parcel_route pr
        left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and ft.real_arrive_time is not null
    )
select
    t1.*
from  t t1
left join
    (
        select
            pr.store_id
            ,pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.next_store_id
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            -- and pr.routed_at < date_sub(curdate(), interval 8 hour)
        group by 1,2
    ) pr on pr.pno = t1.pno and pr.store_id = t1.next_store_id
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
            ,pr.next_store_name
            ,pr.next_store_id
        from ph_staging.parcel_route pr
        left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and ft.real_arrive_time is not null
    )
select
    t1.*
from  t t1
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
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
            ,pr.next_store_name
            ,pr.next_store_id
            ,pr.store_name
            ,pr.store_id
        from ph_staging.parcel_route pr
        left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and ft.real_arrive_time is not null
    )
select
    t1.*
from  t t1
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
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,ss.name
    ,pi.ticket_pickup_staff_info_id
    ,hsi.name
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_1120 t on t.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_pickup_staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
select
    convert_tz(pr.routed_at, '+00:00', '+08:00')
    ,pr.pno
    ,pr.next_store_id
    ,pr.next_store_name
    ,dp.par_par_store_name
from ph_staging.parcel_route pr
join tmpale.tmp_ph_pno_lj_1120_v2 t on t.pno = pr.pno
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.next_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.store_category in (8,12);
;-- -. . -..- - / . -. - .-. -.--
select
    convert_tz(pr.routed_at, '+00:00', '+08:00') 发件出仓时间
    ,pr.pno
    ,pr.next_store_id 下一站网点id
    ,pr.next_store_name 下一站网点
    ,dp.par_par_store_name 下一站网点对应上级分拨
    ,pr2.CN_element 最后一步有效路由
    ,convert_tz(pr2.routed_at, '+00:00', '+08:00') 操作时间
from tmpale.tmp_ph_pno_lj_1120_v2 t
left join ph_staging.parcel_route pr on t.pno = pr.pno
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.next_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,ddd.CN_element
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_1120_v2 t on t.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.db = 'ph_staging'
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr2 on pr2.pno = t.pno and pr2.rk = 1
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.store_category in (8,12);
;-- -. . -..- - / . -. - .-. -.--
select
    convert_tz(pr.routed_at, '+00:00', '+08:00') 发件出仓时间
    ,pr.pno
    ,pr.next_store_id 下一站网点id
    ,pr.next_store_name 下一站网点
    ,dp.par_par_store_name 下一站网点对应上级分拨
    ,pr2.CN_element 最后一步有效路由
    ,convert_tz(pr2.routed_at, '+00:00', '+08:00') 操作时间
from tmpale.tmp_ph_pno_lj_1120_v2 t
left join ph_staging.parcel_route pr on t.pno = pr.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_category in (8,12) -- hub
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.next_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,ddd.CN_element
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_1120_v2 t on t.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.db = 'ph_staging'
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr2 on pr2.pno = t.pno and pr2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
#         tp.id 揽件任务ID
#         ,tp.staff_info_id 快递员
#         ,ss.name 网点
    count(tp.id)
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-11-14 16:00:00'
    and tp.created_at < '2023-11-20 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-11-14 16:00:00'
    and tp.created_at < '2023-11-17 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-11-17 16:00:00'
    and tp.created_at < '2023-11-20 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno '运单号waybill'
    ,pi.client_id '客户ID Client ID'
    ,loi.item_name '物品名称Item Name'
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
    and pr.store_id != pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
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
    ,t1,next_store_name  '卸货网点unloading outlet'
    ,t1.real_arrive_time '到车时间inbound time'
    ,t1.proof_id '车辆凭证PVD'
    ,'' '操作网点Operational outlet'
    ,'' '操作时间Operation Time'
    ,'错发无路由' '异常类型Exception Type'
from  t t1
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
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
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
            and ft.real_arrive_time is not null;
;-- -. . -..- - / . -. - .-. -.--
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
    ,t1,next_store_name  '卸货网点unloading outlet'
    ,t1.real_arrive_time '到车时间inbound time'
    ,t1.proof_id '车辆凭证PVD'
    ,'' '操作网点Operational outlet'
    ,'' '操作时间Operation Time'
    ,'错发无路由' '异常类型Exception Type'
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
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
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
    ,t1,next_store_name  '卸货网点unloading outlet'
    ,t1.real_arrive_time '到车时间inbound time'
    ,t1.proof_id '车辆凭证PVD'
#     ,'' '操作网点Operational outlet'
#     ,'' '操作时间Operation Time'
#     ,'错发无路由' '异常类型Exception Type'
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
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
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
    pi.pno
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
    ,t1,next_store_name  '卸货网点unloading outlet'
    ,t1.real_arrive_time '到车时间inbound time'
    ,t1.proof_id '车辆凭证PVD'
    ,'' '操作网点Operational outlet'
    ,'' '操作时间Operation Time'
    ,'错发无路由' '异常类型Exception Type'
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
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
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
#     ,pi.client_id '客户ID Client ID'
#     ,loi.item_name '物品名称Item Name'
#     ,loi.item_name '物品名称Item Name'
#     ,pi.exhibition_weight '物品重量 Item weight'
#     ,pi.exhibition_length * pi.exhibition_width * pi.exhibition_height '物品体积Item volume'
#     ,ss.name '揽件网点pick-up outlet'
#     ,pi.cod_amount/100 'COD金额COD amount'
#     ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 'COGS金额COGS amount'
#     ,ss2.name '目的网点Destination outlet'
#     ,t1.store_name '装车网点loading outlet'
#     ,convert_tz(t1.routed_at, '+00:00', '+08:00') '发车时间outbound time'
#     ,t1,next_store_name  '卸货网点unloading outlet'
#     ,t1.real_arrive_time '到车时间inbound time'
#     ,t1.proof_id '车辆凭证PVD'
#     ,'' '操作网点Operational outlet'
#     ,'' '操作时间Operation Time'
#     ,'错发无路由' '异常类型Exception Type'
from t t1;
;-- -. . -..- - / . -. - .-. -.--
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
#     ,pi.client_id '客户ID Client ID'
#     ,loi.item_name '物品名称Item Name'
#     ,loi.item_name '物品名称Item Name'
#     ,pi.exhibition_weight '物品重量 Item weight'
#     ,pi.exhibition_length * pi.exhibition_width * pi.exhibition_height '物品体积Item volume'
#     ,ss.name '揽件网点pick-up outlet'
#     ,pi.cod_amount/100 'COD金额COD amount'
#     ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 'COGS金额COGS amount'
#     ,ss2.name '目的网点Destination outlet'
#     ,t1.store_name '装车网点loading outlet'
#     ,convert_tz(t1.routed_at, '+00:00', '+08:00') '发车时间outbound time'
#     ,t1,next_store_name  '卸货网点unloading outlet'
#     ,t1.real_arrive_time '到车时间inbound time'
#     ,t1.proof_id '车辆凭证PVD'
    ,'' '操作网点Operational outlet'
    ,'' '操作时间Operation Time'
    ,'错发无路由' '异常类型Exception Type'
from t t1;
;-- -. . -..- - / . -. - .-. -.--
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
where
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.src_phone
from ph_staging.parcel_info pi
where
    pi.pno in ('P64022VT13NAE','P64022W9PEJAE','P64022TW3B2DN','P64082SMCPUAE','P64022UPFRUDW','P64022SG9NCAD','P64022U3A6NAE','P64022VQ2ZGAA','P64022VZ26ZAE','P64022VTVKSAD','P64022V9PCXBO','P64022W8ZVTAE','P64022VB3K5BN','P64022VE7XWEJ','P64022W4T9NAN','P64022VUS93BO','P64022VQQ80EI','P64022W2ESPDO','P64022V1GQCAN','P64022UNGXEDU','P64022UB3NEAE','P64022V21F1BO','P12112WRXY5AB','P64022WA7YFAE','P64022VDXA1EI','P64022WMXNPDA','P64022UVZSYDU','P64022TVBBSBP','P64022PVDHUEF','P64022VEJMVDU','P64022WDG5GDA','P64022TYXDFBO','P64022U286GBH','P64022VH7SAZZ','P64022V2R3CDD','P64022VD692AE','P64022VDP28BN','P64022W1Q0RDU','P64022VE6GDDB','P64022VY02GBB','P64022W1EPJDU','P64022W22EJZZ','P64022V3YS3AD','P64022W2XV2DV','P64132VNUBAAC','P64022TW55ACP','P64022V4DBWEU','P64022UK08NBN','P64022V0SHAAN','P64022V3YS4AD','P64022VTX4CEF');
;-- -. . -..- - / . -. - .-. -.--
select
    t.staff
    ,t.store
    ,t.p_date
    ,sc.pi_count
from tmpale.tmp_ph_staff_1124 t
left join
    (
        select
            t.p_date
            ,t.staff
            ,t.store
            ,count(distinct pr.pno) pi_count
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_staff_1124 t on t.staff = pr.staff_info_id and t.store = pr.store_name
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at >= date_sub(t.p_date, interval 8 hour )
            and pr.routed_at < date_add(t.p_date, interval 16 hour)
        group by 1,2,3
    ) sc on sc.staff = t.staff and sc.store = t.store and sc.p_date = t.p_date;
;-- -. . -..- - / . -. - .-. -.--
select
    ppl.replace_pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_pno_log ppl
left join ph_staging.parcel_info pi on pi.pno = ppl.initial_pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
join tmpale.tmp_ph_pno_1125 t on t.pno = ppl.replace_pno
# where
#     ppl.replace_pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')

union all

select
    pi.pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
join tmpale.tmp_ph_pno_1125 t on t.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pssn.store_id
    ,pssn.store_name
    ,count(distinct if(pssn.van_arrived_at is null, pssn.pno, pssn.pno, null)) 应到量
    ,count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null)) 实到量
from dw_dmd.parcel_store_stage_new pssn
where
    pssn.store_category in (1,10)
    and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
    and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    pssn.store_id
    ,pssn.store_name
    ,count(distinct if(pssn.van_arrived_at is null, pssn.pno, null)) 应到量
    ,count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null)) 实到量
from dw_dmd.parcel_store_stage_new pssn
where
    pssn.store_category in (1,10)
    and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
    and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    pssn.store_id
    ,pssn.store_name
    ,count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) 应到量
    ,count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null)) 实到量
from dw_dmd.parcel_store_stage_new pssn
where
    pssn.store_category in (1,10)
    and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
    and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pssn.store_id
        ,pssn.store_name
        ,count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) 应到量
        ,count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null)) 实到量
        ,count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) - count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null))
    from dw_dmd.parcel_store_stage_new pssn
    where
        pssn.store_category in (1,10)
        and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
        and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pssn.store_id
        ,pssn.store_name
        ,count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) 应到量
        ,count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null)) 实到量
        ,count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) - count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null))
    from dw_dmd.parcel_store_stage_new pssn
    where
        pssn.store_category in (1,10)
        and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
        and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
        and pssn.van_arrived_at < date_sub(now(), interval 2 hour)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pssn.store_id
        ,pssn.store_name
        ,count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) 应到量
        ,count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null)) 实到量
        ,count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) - count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null))
    from dw_dmd.parcel_store_stage_new pssn
    where
        pssn.store_category in (1,10)
        and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
        and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
        and pssn.van_arrived_at < date_sub(now(), interval 4 hour)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pssn.store_id
        ,pssn.store_name
        ,count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) 应到量
        ,count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null)) 实到量
        ,count(distinct if(pssn.van_arrived_at is not null, pssn.pno, null)) - count(distinct if(pssn.van_arrived_at is not null and pssn.first_valid_routed_at is not null ,pssn.pno , null)) 差值
    from dw_dmd.parcel_store_stage_new pssn
    where
        pssn.store_category in (1,10)
        and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
        and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
        and pssn.van_arrived_at < date_sub(now(), interval 4 hour)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        ssp.pno
        ,ssp.stat_date
        ,ssp.inventory_class
        ,ssp.resp_store_id
        ,ssp.last_valid_action_route_at
        ,ddd2.CN_element
    from ph_bi.should_stocktaking_parcel_info_recently ssp
    left join dwm.dwd_dim_dict ddd2 on ddd2.element = ssp.last_valid_action and  ddd2.db = 'ph_staging' and ddd2.tablename = 'parcel_route'
    where
        ssp.stat_date = curdate()
        and ssp.hour = hour(now())
        and hour(now()) <= 23;
;-- -. . -..- - / . -. - .-. -.--
select
        pssn.*
    from dw_dmd.parcel_store_stage_new pssn
    where
        pssn.store_category in (1,10)
        and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
        and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
        and pssn.van_arrived_at < date_sub(now(), interval 4 hour)
        and pssn.van_arrived_at is not null
        and pssn.first_valid_routed_at is  null
        and pssn.store_id = 'PH80060800';
;-- -. . -..- - / . -. - .-. -.--
select
    pssn.pno
    ,p2.store_name
    ,p2.last_valid_route_action
    ,convert_tz(p2.last_valid_routed_at, '+00:00', '+08:00') last_valid_routed_time
    ,pssn.store_name
    ,dp.piece_name
    ,dp.region_name
from dw_dmd.parcel_store_stage_new pssn
left join dw_dmd.parcel_store_stage_new p2 on p2.pno = pssn.pno and p2.valid_store_order = pssn.valid_store_order - 1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pssn.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    pssn.store_category in (1,10)
    and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
    and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
    and pssn.van_arrived_at is not null
    and pssn.first_valid_routed_at is  null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
         select
            pssn.pno
            ,pssn.store_name
            ,dp.piece_name
            ,dp.region_name
        from dw_dmd.parcel_store_stage_new pssn
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pssn.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            pssn.store_category in (1,10)
            and pssn.van_arrived_at >= date_sub(curdate(), interval 8 hour)
            and pssn.van_arrived_at < date_add(curdate(), interval 16 hour)
            and pssn.van_arrived_at is not null
            and pssn.first_valid_routed_at is null
    )

select
    t1.pno
    ,a.store_name 最后有效路由操作网点
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 最后有效路由操作时间
    ,a.CN_element 最后有效路由
    ,t1.store_name 下一站网点
    ,t1.piece_name 下一站片区
    ,t1.region_name 下一站大区
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,ddd.CN_element
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(curdate(), interval 1 month )
    ) a on a.pno = t1.pno and a.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            t.p_date
            ,t.staff
            ,t.store
            ,pr.routed_at
            ,pr.pno
            ,row_number() over (partition by t.p_date,t.staff,t.store order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_staff_1124 t on t.staff = pr.staff_info_id and t.store = pr.store_name
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at >= date_sub(t.p_date, interval 8 hour )
            and pr.routed_at < date_add(t.p_date, interval 16 hour)
        group by 1,2,3
    )
select
    s.p_date
    ,s.staff
    ,s.store
    ,count(distinct a2.pno) 包裹数
from tmpale.tmp_ph_staff_1124 s
left join
    (
        select
            t1.*
        from  t  t1
        left join t t2 on t1.p_date = t2.p_date and t1.staff = t2.staff and t1.store = t2.store and t2.rk = 1
        where
            t1.routed_at < date_add(t2.routed_at, interval 2 hour)
    ) a2 on a2.p_date = s.p_date and a2.staff = s.staff and a2.store = s.store
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            t.p_date
            ,t.staff
            ,t.store
            ,pr.routed_at
            ,pr.pno
            ,row_number() over (partition by t.p_date,t.staff,t.store order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_staff_1124 t on t.staff = pr.staff_info_id and t.store = pr.store_name
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at >= date_sub(t.p_date, interval 8 hour )
            and pr.routed_at < date_add(t.p_date, interval 16 hour)
    )
select
    s.p_date
    ,s.staff
    ,s.store
    ,count(distinct a2.pno) 包裹数
from tmpale.tmp_ph_staff_1124 s
left join
    (
        select
            t1.*
        from  t  t1
        left join t t2 on t1.p_date = t2.p_date and t1.staff = t2.staff and t1.store = t2.store and t2.rk = 1
        where
            t1.routed_at < date_add(t2.routed_at, interval 2 hour)
    ) a2 on a2.p_date = s.p_date and a2.staff = s.staff and a2.store = s.store
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            ps.sorting_code
            ,ps.first_sorting_code
            ,ps.second_sorting_code
            ,ps.third_sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc) rk
        from ph_drds.parcel_sorting_code_info ps
        join tmpale.tmp_ph_pno_1129 t on t.pno = ps.pno
    ) a
where
    a.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            t.pno
            ,ps.sorting_code
            ,ps.first_sorting_code
            ,ps.second_sorting_code
            ,ps.third_sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc) rk
        from ph_drds.parcel_sorting_code_info ps
        join tmpale.tmp_ph_pno_1129 t on t.pno = ps.pno
    ) a
where
    a.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-11-20 16:00:00'
    and tp.created_at < '2023-11-24 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-11-20 16:00:00'
    and tp.created_at < '2023-11-23 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-11-23 16:00:00'
    and tp.created_at < '2023-11-26 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-11-26 16:00:00'
    and tp.created_at < '2023-11-29 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    a.ss_category
    ,sum(a.rate) 责任分布
from  
    (
        select
            plt.id
            ,plt.pno
            ,plr.store_id
            ,case
                when ss.category in (1,10) then 'NW'
                when ss.category in (8,12) then 'HUB'
                when ss.category = 6 then 'FH'
            end ss_category
            ,sum(plr.duty_ratio) rate
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on plt.pno = oi.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            and plt.penalties > 0
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
        group by 1,2,3
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
            plt.id
            ,plt.pno
            ,plr.store_id
            ,case
                when ss.category in (1,10) then 'NW'
                when ss.category in (8,12) then 'HUB'
                when ss.category = 6 then 'FH'
            end ss_category
            ,sum(plr.duty_ratio) rate
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on plt.pno = oi.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            and plt.penalties > 0
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    a.ss_category
    ,sum(a.rate) 责任分布
from
    (
        select
            plt.id
            ,plt.pno
            ,plr.store_id
            ,case
                when ss.category in (1,10) then 'NW'
                when ss.category in (8,12) then 'HUB'
                when ss.category = 6 then 'FH'
            end ss_category
            ,sum(plr.duty_ratio) rate
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on plt.pno = oi.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            and plt.penalties > 0
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
        group by 1,2,3
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.ss_category
    ,sum(a.rate) 责任分布
from
    (
        select
            plt.id
            ,plt.pno
            ,plr.store_id
            ,case
                when ss.category in (1,10) then 'NW'
                when ss.category in (8,12) then 'HUB'
                when ss.category = 6 then 'FH'
                when ss.category = 2 then 'DC'
                when ss.category = 4 then 'SHOP'
                when ss.category = 5 then 'SHOP'
                when ss.category = 7 then 'SHOP'
                when ss.category = 9 then 'Onsite'
                when ss.category = 11 then 'fulfillment'
                when ss.category = 13 then 'CDC'
                when ss.category = 14 then 'PDC'
            end ss_category
            ,sum(plr.duty_ratio) rate
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on plt.pno = oi.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            and plt.penalties > 0
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
        group by 1,2,3
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.ss_category
   ,count(distinct a.pno ) 网点分布
from
    (
        select
            plt.id
            ,plt.pno
            ,case
                when ss.category in (1,10) then 'NW'
                when ss.category in (8,12) then 'HUB'
                when ss.category = 6 then 'FH'
                when ss.category = 2 then 'DC'
                when ss.category = 4 then 'SHOP'
                when ss.category = 5 then 'SHOP'
                when ss.category = 7 then 'SHOP'
                when ss.category = 9 then 'Onsite'
                when ss.category = 11 then 'fulfillment'
                when ss.category = 13 then 'CDC'
                when ss.category = 14 then 'PDC'
            end ss_category
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on plt.pno = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            and plt.penalties > 0
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,ss.name ss_name
    ,sum(plr.duty_ratio)/100  rate
from ph_bi.parcel_lose_task plt
join ph_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join ph_staging.order_info oi on plt.pno = oi.pno
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.updated_at >= '2023-09-01'
    and plt.updated_at < '2023-12-01'
    and plt.penalties > 0
    and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.staff_id
    ,ss.name ss_name
    ,sum(plr.duty_ratio)/100  rate
from ph_bi.parcel_lose_task plt
join ph_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join ph_staging.order_info oi on plt.pno = oi.pno
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.updated_at >= '2023-09-01'
    and plt.updated_at < '2023-12-01'
    and plt.penalties > 0
    and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name ss_name
    ,sum(plr.duty_ratio)/100  rate
from ph_bi.parcel_lose_task plt
join ph_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join ph_staging.order_info oi on plt.pno = oi.pno
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.updated_at >= '2023-09-01'
    and plt.updated_at < '2023-12-01'
    and plt.penalties > 0
    and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select * from tmpale.tmp_ph_pno1009;
;-- -. . -..- - / . -. - .-. -.--
select
            plt.pno
            ,plt.client_id
            ,plt.last_valid_routed_at
            ,bc.client_name
            ,plt.last_valid_store_id
            ,ss.name last_valid_store
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) value
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on plt.pno = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            and plt.penalties > 0
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000;
;-- -. . -..- - / . -. - .-. -.--
select
            plt.pno
            ,plt.client_id
            ,plt.last_valid_routed_at
            ,bc.client_name
            ,plt.last_valid_store_id
            ,ss.name last_valid_store
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) value
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on plt.pno = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            -- and plt.penalties > 0
            and coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) > 5000;
;-- -. . -..- - / . -. - .-. -.--
select
            plt.pno
            ,plt.client_id
            ,plt.last_valid_routed_at
            ,bc.client_name
            ,plt.last_valid_store_id
            ,ss.name last_valid_store
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) value
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            -- and plt.penalties > 0
            and coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) > 5000;
;-- -. . -..- - / . -. - .-. -.--
select
            plt.pno
            ,pi.returned
            ,plt.client_id
            ,plt.last_valid_routed_at
            ,bc.client_name
            ,plt.last_valid_store_id
            ,ss.name last_valid_store
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) value
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            -- and plt.penalties > 0
            and coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) > 5000
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select * from tmpale.tmp_ph_pno_plt_1202;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case
        when hst.state = 1 and hst.wait_leave_state = 1 then '待离职'
        when hsi.hire_date > date(date_sub(t.last_valid_routed_at, interval 30 day)) then '新员工'
        when a2.staff_info_id is not null then '操作前30天内有旷工'
    end 员工状态
    ,if(hsi.hire_type = 12, '是', '否' ) 是否众包
    ,if(hsa.staff_info_id is not null, '是', '否') 是否支援
    ,if(t.returned = 1, '是', '否') 是否退件包裹
    ,if(t.returned = 1 and t.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN', '是', '否') 是否退件发件出仓丢失
    ,a3.weight - a3.ori_weight '退件重量-正向件重量'
    ,if(a4.pno is not null, '是', '否') 集包件是否有拆包
from tmpale.tmp_ph_pno_plt_1202 t
left join ph_bi.hr_staff_transfer hst on hst.staff_info_id = t.last_valid_staff_info_id and hst.stat_date = date(last_valid_routed_at)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t.last_valid_staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join t t1 on t1.last_valid_staff_info_id = ad.staff_info_id
        where
            ad.stat_date > '2023-08-01'
            and ad.stat_date < date(t1.last_valid_routed_at)
            and ad.stat_date > date_sub(date(t1.last_valid_routed_at), interval 30 day)
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
        group by 1
    ) a2 on a2.staff_info_id = t.last_valid_staff_info_id
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t.last_valid_staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= date(last_valid_routed_at) and hsa.employment_end_date >= date(last_valid_routed_at)
left join
    (
        select
            t.pno
            ,coalesce(b.after_weight, pi.exhibition_weight) weight
            ,pi2.exhibition_weight ori_weight
        from tmpale.tmp_ph_staff_1124 t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        left join
            (
                select
                    t.pno
                    ,pwr.after_weight
                    ,row_number() over (partition by t.pno order by pwr.created_at desc) rn
                from tmpale.tmp_ph_pno_plt_1202 t
                join dwm.drds_ph_parcel_weight_revise_record_d pwr on pwr.pno = t.pno
                where
                    t.returned = 1
            ) b on b.pno = t.pno and b.rn = 1
        left join ph_staging.parcel_info pi2 on pi2.returned_pno = t.pno
        where
            t.returned = 1
    ) a3 on a3.pno = t.pno
left join
    (
        select
            t.*
        from
            (
                select
                    t.pno
                    ,t.last_valid_store_id
                from tmpale.tmp_ph_pno_plt_1202 t
                join dw_dmd.parcel_store_stage_new pssn on pssn.pno = t.pno and pssn.store_id = t.last_valid_store_id
                where
                    pssn.arrival_pack_no is not null
                group by 1,2
            ) b1
        join ph_staging.parcel_route pr on b1.pno = pr.pno and pr.route_action = 'UNSEAL' and pr.store_id = b1.last_valid_store_id
        group by 1,2
    ) a4 on a4.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case
        when hst.state = 1 and hst.wait_leave_state = 1 then '待离职'
        when hsi.hire_date > date(date_sub(t.last_valid_routed_at, interval 30 day)) then '新员工'
        when a2.staff_info_id is not null then '操作前30天内有旷工'
    end 员工状态
    ,if(hsi.hire_type = 12, '是', '否' ) 是否众包
    ,if(hsa.staff_info_id is not null, '是', '否') 是否支援
    ,if(t.returned = 1, '是', '否') 是否退件包裹
    ,if(t.returned = 1 and t.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN', '是', '否') 是否退件发件出仓丢失
    ,a3.weight - a3.ori_weight '退件重量-正向件重量'
    ,if(a4.pno is not null, '是', '否') 集包件是否有拆包
from tmpale.tmp_ph_pno_plt_1202 t
left join ph_bi.hr_staff_transfer hst on hst.staff_info_id = t.last_valid_staff_info_id and hst.stat_date = date(last_valid_routed_at)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t.last_valid_staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join tmpale.tmp_ph_pno_plt_1202 t1 on t1.last_valid_staff_info_id = ad.staff_info_id
        where
            ad.stat_date > '2023-08-01'
            and ad.stat_date < date(t1.last_valid_routed_at)
            and ad.stat_date > date_sub(date(t1.last_valid_routed_at), interval 30 day)
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
        group by 1
    ) a2 on a2.staff_info_id = t.last_valid_staff_info_id
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t.last_valid_staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= date(last_valid_routed_at) and hsa.employment_end_date >= date(last_valid_routed_at)
left join
    (
        select
            t.pno
            ,coalesce(b.after_weight, pi.exhibition_weight) weight
            ,pi2.exhibition_weight ori_weight
        from tmpale.tmp_ph_staff_1124 t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        left join
            (
                select
                    t.pno
                    ,pwr.after_weight
                    ,row_number() over (partition by t.pno order by pwr.created_at desc) rn
                from tmpale.tmp_ph_pno_plt_1202 t
                join dwm.drds_ph_parcel_weight_revise_record_d pwr on pwr.pno = t.pno
                where
                    t.returned = 1
            ) b on b.pno = t.pno and b.rn = 1
        left join ph_staging.parcel_info pi2 on pi2.returned_pno = t.pno
        where
            t.returned = 1
    ) a3 on a3.pno = t.pno
left join
    (
        select
            t.*
        from
            (
                select
                    t.pno
                    ,t.last_valid_store_id
                from tmpale.tmp_ph_pno_plt_1202 t
                join dw_dmd.parcel_store_stage_new pssn on pssn.pno = t.pno and pssn.store_id = t.last_valid_store_id
                where
                    pssn.arrival_pack_no is not null
                group by 1,2
            ) b1
        join ph_staging.parcel_route pr on b1.pno = pr.pno and pr.route_action = 'UNSEAL' and pr.store_id = b1.last_valid_store_id
        group by 1,2
    ) a4 on a4.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case
        when hst.state = 1 and hst.wait_leave_state = 1 then '待离职'
        when hsi.hire_date > date(date_sub(t.last_valid_routed_at, interval 30 day)) then '新员工'
        when a2.staff_info_id is not null then '操作前30天内有旷工'
    end 员工状态
    ,if(hsi.hire_type = 12, '是', '否' ) 是否众包
    ,if(hsa.staff_info_id is not null, '是', '否') 是否支援
    ,if(t.returned = 1, '是', '否') 是否退件包裹
    ,if(t.returned = 1 and t.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN', '是', '否') 是否退件发件出仓丢失
    ,a3.weight - a3.ori_weight '退件重量-正向件重量'
    ,if(a4.pno is not null, '是', '否') 集包件是否有拆包
from tmpale.tmp_ph_pno_plt_1202 t
left join ph_bi.hr_staff_transfer hst on hst.staff_info_id = t.last_valid_staff_info_id and hst.stat_date = date(last_valid_routed_at)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t.last_valid_staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join tmpale.tmp_ph_pno_plt_1202 t1 on t1.last_valid_staff_info_id = ad.staff_info_id
        where
            ad.stat_date > '2023-08-01'
            and ad.stat_date < date(t1.last_valid_routed_at)
            and ad.stat_date > date_sub(date(t1.last_valid_routed_at), interval 30 day)
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
        group by 1
    ) a2 on a2.staff_info_id = t.last_valid_staff_info_id
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t.last_valid_staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= date(last_valid_routed_at) and hsa.employment_end_date >= date(last_valid_routed_at)
left join
    (
        select
            t.pno
            ,coalesce(b.after_weight, pi.exhibition_weight) weight
            ,pi2.exhibition_weight ori_weight
        from tmpale.tmp_ph_pno_plt_1202 t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        left join
            (
                select
                    t.pno
                    ,pwr.after_weight
                    ,row_number() over (partition by t.pno order by pwr.created_at desc) rn
                from tmpale.tmp_ph_pno_plt_1202 t
                join dwm.drds_ph_parcel_weight_revise_record_d pwr on pwr.pno = t.pno
                where
                    t.returned = 1
            ) b on b.pno = t.pno and b.rn = 1
        left join ph_staging.parcel_info pi2 on pi2.returned_pno = t.pno
        where
            t.returned = 1
    ) a3 on a3.pno = t.pno
left join
    (
        select
            t.*
        from
            (
                select
                    t.pno
                    ,t.last_valid_store_id
                from tmpale.tmp_ph_pno_plt_1202 t
                join dw_dmd.parcel_store_stage_new pssn on pssn.pno = t.pno and pssn.store_id = t.last_valid_store_id
                where
                    pssn.arrival_pack_no is not null
                group by 1,2
            ) b1
        join ph_staging.parcel_route pr on b1.pno = pr.pno and pr.route_action = 'UNSEAL' and pr.store_id = b1.last_valid_store_id
        group by 1,2
    ) a4 on a4.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join tmpale.tmp_ph_pno_plt_1202 t1 on t1.last_valid_staff_info_id = ad.staff_info_id
        where
            ad.stat_date > '2023-08-01'
            and ad.stat_date < date(t1.last_valid_routed_at)
            and ad.stat_date > date_sub(date(t1.last_valid_routed_at), interval 30 day)
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
            t.pno
            ,coalesce(b.after_weight, pi.exhibition_weight) weight
            ,pi2.exhibition_weight ori_weight
        from tmpale.tmp_ph_pno_plt_1202 t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        left join
            (
                select
                    t.pno
                    ,pwr.after_weight
                    ,row_number() over (partition by t.pno order by pwr.created_at desc) rn
                from tmpale.tmp_ph_pno_plt_1202 t
                join dwm.drds_ph_parcel_weight_revise_record_d pwr on pwr.pno = t.pno
                where
                    t.returned = 1
            ) b on b.pno = t.pno and b.rn = 1
        left join ph_staging.parcel_info pi2 on pi2.returned_pno = t.pno
        where
            t.returned = 1;
;-- -. . -..- - / . -. - .-. -.--
select
            t.*
        from
            (
                select
                    t.pno
                    ,t.last_valid_store_id
                from tmpale.tmp_ph_pno_plt_1202 t
                join dw_dmd.parcel_store_stage_new pssn on pssn.pno = t.pno and pssn.store_id = t.last_valid_store_id
                where
                    pssn.arrival_pack_no is not null
                group by 1,2
            ) b1
        join ph_staging.parcel_route pr on b1.pno = pr.pno and pr.route_action = 'UNSEAL' and pr.store_id = b1.last_valid_store_id
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case
        when hst.state = 1 and hst.wait_leave_state = 1 then '待离职'
        when hsi.hire_date > date(date_sub(t.last_valid_routed_at, interval 30 day)) then '新员工'
        when a2.staff_info_id is not null then '操作前30天内有旷工'
    end 员工状态
    ,if(hsi.hire_type = 12, '是', '否' ) 是否众包
    ,if(hsa.staff_info_id is not null, '是', '否') 是否支援
    ,if(t.returned = 1, '是', '否') 是否退件包裹
    ,if(t.returned = 1 and t.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN', '是', '否') 是否退件发件出仓丢失
    ,a3.weight - a3.ori_weight '退件重量-正向件重量'
    ,if(a4.pno is not null, '是', '否') 集包件是否有拆包
from tmpale.tmp_ph_pno_plt_1202 t
left join ph_bi.hr_staff_transfer hst on hst.staff_info_id = t.last_valid_staff_info_id and hst.stat_date = date(last_valid_routed_at)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t.last_valid_staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join tmpale.tmp_ph_pno_plt_1202 t1 on t1.last_valid_staff_info_id = ad.staff_info_id
        where
            ad.stat_date > '2023-08-01'
            and ad.stat_date < date(t1.last_valid_routed_at)
            and ad.stat_date > date_sub(date(t1.last_valid_routed_at), interval 30 day)
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
        group by 1
    ) a2 on a2.staff_info_id = t.last_valid_staff_info_id
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t.last_valid_staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= date(last_valid_routed_at) and hsa.employment_end_date >= date(last_valid_routed_at)
left join
    (
        select
            t.pno
            ,coalesce(b.after_weight, pi.exhibition_weight) weight
            ,pi2.exhibition_weight ori_weight
        from tmpale.tmp_ph_pno_plt_1202 t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        left join
            (
                select
                    t.pno
                    ,pwr.after_weight
                    ,row_number() over (partition by t.pno order by pwr.created_at desc) rn
                from tmpale.tmp_ph_pno_plt_1202 t
                join dwm.drds_ph_parcel_weight_revise_record_d pwr on pwr.pno = t.pno
                where
                    t.returned = 1
            ) b on b.pno = t.pno and b.rn = 1
        left join ph_staging.parcel_info pi2 on pi2.returned_pno = t.pno
        where
            t.returned = 1
    ) a3 on a3.pno = t.pno
left join
    (
        select
            b1.*
        from
            (
                select
                    t.pno
                    ,t.last_valid_store_id
                from tmpale.tmp_ph_pno_plt_1202 t
                join dw_dmd.parcel_store_stage_new pssn on pssn.pno = t.pno and pssn.store_id = t.last_valid_store_id
                where
                    pssn.arrival_pack_no is not null
                group by 1,2
            ) b1
        join ph_staging.parcel_route pr on b1.pno = pr.pno and pr.route_action = 'UNSEAL' and pr.store_id = b1.last_valid_store_id
        group by 1,2
    ) a4 on a4.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case
        when hsi.state = 1 and hsi.wait_leave_state = 1 then '待离职'
        when hsi.hire_date > date(date_sub(t.last_valid_routed_at, interval 30 day)) then '新员工'
        when a2.staff_info_id is not null then '操作前30天内有旷工'
    end 员工状态
    ,if(hsi.hire_type = 12, '是', '否' ) 是否众包
    ,if(hsa.staff_info_id is not null, '是', '否') 是否支援
    ,if(t.returned = 1, '是', '否') 是否退件包裹
    ,if(t.returned = 1 and t.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN', '是', '否') 是否退件发件出仓丢失
    ,a3.weight - a3.ori_weight '退件重量-正向件重量'
    ,if(a4.pno is not null, '是', '否') 集包件是否有拆包
from tmpale.tmp_ph_pno_plt_1202 t
left join ph_bi.hr_staff_transfer hst on hst.staff_info_id = t.last_valid_staff_info_id and hst.stat_date = date(last_valid_routed_at)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t.last_valid_staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join tmpale.tmp_ph_pno_plt_1202 t1 on t1.last_valid_staff_info_id = ad.staff_info_id
        where
            ad.stat_date > '2023-08-01'
            and ad.stat_date < date(t1.last_valid_routed_at)
            and ad.stat_date > date_sub(date(t1.last_valid_routed_at), interval 30 day)
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
        group by 1
    ) a2 on a2.staff_info_id = t.last_valid_staff_info_id
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t.last_valid_staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= date(last_valid_routed_at) and hsa.employment_end_date >= date(last_valid_routed_at)
left join
    (
        select
            t.pno
            ,coalesce(b.after_weight, pi.exhibition_weight) weight
            ,pi2.exhibition_weight ori_weight
        from tmpale.tmp_ph_pno_plt_1202 t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        left join
            (
                select
                    t.pno
                    ,pwr.after_weight
                    ,row_number() over (partition by t.pno order by pwr.created_at desc) rn
                from tmpale.tmp_ph_pno_plt_1202 t
                join dwm.drds_ph_parcel_weight_revise_record_d pwr on pwr.pno = t.pno
                where
                    t.returned = 1
            ) b on b.pno = t.pno and b.rn = 1
        left join ph_staging.parcel_info pi2 on pi2.returned_pno = t.pno
        where
            t.returned = 1
    ) a3 on a3.pno = t.pno
left join
    (
        select
            b1.*
        from
            (
                select
                    t.pno
                    ,t.last_valid_store_id
                from tmpale.tmp_ph_pno_plt_1202 t
                join dw_dmd.parcel_store_stage_new pssn on pssn.pno = t.pno and pssn.store_id = t.last_valid_store_id
                where
                    pssn.arrival_pack_no is not null
                group by 1,2
            ) b1
        join ph_staging.parcel_route pr on b1.pno = pr.pno and pr.route_action = 'UNSEAL' and pr.store_id = b1.last_valid_store_id
        group by 1,2
    ) a4 on a4.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case
        when hsi.state = 1 and hsi.wait_leave_state = 1 then '待离职'
        when hsi.hire_date > date(date_sub(t.last_valid_routed_at, interval 30 day)) then '新员工'
        when a2.staff_info_id is not null then '操作前30天内有旷工'
    end 员工状态
    ,if(hsi.hire_type = 12, '是', '否' ) 是否众包
    ,if(hsa.staff_info_id is not null, '是', '否') 是否支援
    ,if(t.returned = 1, '是', '否') 是否退件包裹
    ,if(t.returned = 1 and t.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN', '是', '否') 是否退件发件出仓丢失
    ,a3.weight - a3.ori_weight '退件重量-正向件重量'
    ,case
        when a4.arrival_pack_no is not null and a4.pno is not null then '是'
        when a4.arrival_pack_no is not null and a4.pno is null then '否'
        else '否'
    end 集包件是否有拆包
from tmpale.tmp_ph_pno_plt_1202 t
left join ph_bi.hr_staff_transfer hst on hst.staff_info_id = t.last_valid_staff_info_id and hst.stat_date = date(last_valid_routed_at)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t.last_valid_staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join tmpale.tmp_ph_pno_plt_1202 t1 on t1.last_valid_staff_info_id = ad.staff_info_id
        where
            ad.stat_date > '2023-08-01'
            and ad.stat_date < date(t1.last_valid_routed_at)
            and ad.stat_date > date_sub(date(t1.last_valid_routed_at), interval 30 day)
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
        group by 1
    ) a2 on a2.staff_info_id = t.last_valid_staff_info_id
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t.last_valid_staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= date(last_valid_routed_at) and hsa.employment_end_date >= date(last_valid_routed_at)
left join
    (
        select
            t.pno
            ,coalesce(b.after_weight, pi.exhibition_weight) weight
            ,pi2.exhibition_weight ori_weight
        from tmpale.tmp_ph_pno_plt_1202 t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        left join
            (
                select
                    t.pno
                    ,pwr.after_weight
                    ,row_number() over (partition by t.pno order by pwr.created_at desc) rn
                from tmpale.tmp_ph_pno_plt_1202 t
                join dwm.drds_ph_parcel_weight_revise_record_d pwr on pwr.pno = t.pno
                where
                    t.returned = 1
            ) b on b.pno = t.pno and b.rn = 1
        left join ph_staging.parcel_info pi2 on pi2.returned_pno = t.pno
        where
            t.returned = 1
    ) a3 on a3.pno = t.pno
left join
    (
        select
            b1.*
            ,pr.route_action
        from
            (
                select
                    t.pno
                    ,t.last_valid_store_id
                    ,pssn.arrival_pack_no
                from tmpale.tmp_ph_pno_plt_1202 t
                join dw_dmd.parcel_store_stage_new pssn on pssn.pno = t.pno and pssn.store_id = t.last_valid_store_id
                where
                    pssn.arrival_pack_no is not null
                group by 1,2,3
            ) b1
        left join ph_staging.parcel_route pr on b1.pno = pr.pno and pr.route_action = 'UNSEAL' and pr.store_id = b1.last_valid_store_id
        group by 1,2,3,4
    ) a4 on a4.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case
        when hsi.state = 1 and hsi.wait_leave_state = 1 then '待离职'
        when hsi.hire_date > date(date_sub(t.last_valid_routed_at, interval 30 day)) then '新员工'
        when a2.staff_info_id is not null then '操作前30天内有旷工'
    end 员工状态
    ,if(hsi.hire_type = 12, '是', '否' ) 是否众包
    ,if(hsa.staff_info_id is not null, '是', '否') 是否支援
    ,if(t.returned = 1, '是', '否') 是否退件包裹
    ,if(t.returned = 1 and t.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN', '是', '否') 是否退件发件出仓丢失
    ,a3.weight - a3.ori_weight '退件重量-正向件重量'
    ,case
        when a4.arrival_pack_no is not null and a4.pno is not null then '是'
        when a4.arrival_pack_no is not null and a4.pno is null then '否'
        else null
    end 集包件是否有拆包
from tmpale.tmp_ph_pno_plt_1202 t
left join ph_bi.hr_staff_transfer hst on hst.staff_info_id = t.last_valid_staff_info_id and hst.stat_date = date(last_valid_routed_at)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t.last_valid_staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join tmpale.tmp_ph_pno_plt_1202 t1 on t1.last_valid_staff_info_id = ad.staff_info_id
        where
            ad.stat_date > '2023-08-01'
            and ad.stat_date < date(t1.last_valid_routed_at)
            and ad.stat_date > date_sub(date(t1.last_valid_routed_at), interval 30 day)
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
        group by 1
    ) a2 on a2.staff_info_id = t.last_valid_staff_info_id
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t.last_valid_staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= date(last_valid_routed_at) and hsa.employment_end_date >= date(last_valid_routed_at)
left join
    (
        select
            t.pno
            ,coalesce(b.after_weight, pi.exhibition_weight) weight
            ,pi2.exhibition_weight ori_weight
        from tmpale.tmp_ph_pno_plt_1202 t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        left join
            (
                select
                    t.pno
                    ,pwr.after_weight
                    ,row_number() over (partition by t.pno order by pwr.created_at desc) rn
                from tmpale.tmp_ph_pno_plt_1202 t
                join dwm.drds_ph_parcel_weight_revise_record_d pwr on pwr.pno = t.pno
                where
                    t.returned = 1
            ) b on b.pno = t.pno and b.rn = 1
        left join ph_staging.parcel_info pi2 on pi2.returned_pno = t.pno
        where
            t.returned = 1
    ) a3 on a3.pno = t.pno
left join
    (
        select
            b1.*
            ,pr.route_action
        from
            (
                select
                    t.pno
                    ,t.last_valid_store_id
                    ,pssn.arrival_pack_no
                from tmpale.tmp_ph_pno_plt_1202 t
                join dw_dmd.parcel_store_stage_new pssn on pssn.pno = t.pno and pssn.store_id = t.last_valid_store_id
                where
                    pssn.arrival_pack_no is not null
                group by 1,2,3
            ) b1
        left join ph_staging.parcel_route pr on b1.pno = pr.pno and pr.route_action = 'UNSEAL' and pr.store_id = b1.last_valid_store_id
        group by 1,2,3,4
    ) a4 on a4.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,pi.returned
            ,plt.client_id
            ,plt.last_valid_routed_at
            ,bc.client_name
            ,plt.last_valid_store_id
            ,ss.name last_valid_store
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,plt.operator_id
            ,coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) value
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            -- and plt.penalties > 0
            and coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) > 5000
        group by 1
    )
select
    t1.*
    ,dp.attendance_started_at 员工上班打卡时间
    ,dp.attendance_end_at 员工下班打卡时间
    ,dp.pickup_par_cnt 员工当日揽收包裹数
    ,dp.delivery_par_cnt '妥投包裹数'
    ,dp.delivery_big_par_cnt '妥投大件包裹数'
    ,dp.delivery_sma_par_cnt 妥投小件包裹数
from t t1
left join dwm.dws_ph_staff_wide_s dp on dp.staff_info_id = t1.last_valid_staff_info_id and dp.stat_date = date(t1.last_valid_routed_at);
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,pi.returned
            ,plt.client_id
            ,plt.last_valid_routed_at
            ,bc.client_name
            ,plt.last_valid_store_id
            ,ss.name last_valid_store
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,plt.operator_id
            ,coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) value
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            -- and plt.penalties > 0
            and coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) > 5000
        group by 1
    )
select
    a1.*
    ,group_concat(ldr.staff_info_id) 该设备登录员工ID
    ,count(ldr.staff_info_id) 该设备登录员工数
from
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,json_extract(pr.extra_value, '$.deviceId') device_id
                    ,row_number() over (partition by t1.pno order by pr.created_at desc) rn
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno and t1.last_valid_store_id = pr.store_id and pr.route_action = t1.last_valid_action
            ) a
        where
            a.rn = 1
    ) a1
left join ph_staging.login_device_record ldr on ldr.device_id = a1.device_id and ldr.created_at > dates_ub(date(a1.last_valid_routed_at), interval  8 hour) and ldr.created_at < date_add(date(a1.last_valid_routed_at), interval 16 hour)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,pi.returned
            ,plt.client_id
            ,plt.last_valid_routed_at
            ,bc.client_name
            ,plt.last_valid_store_id
            ,ss.name last_valid_store
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,plt.operator_id
            ,coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) value
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            -- and plt.penalties > 0
            and coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) > 5000
        group by 1
    )
select
    a1.*
    ,group_concat(ldr.staff_info_id) 该设备登录员工ID
    ,count(ldr.staff_info_id) 该设备登录员工数
from
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,json_extract(pr.extra_value, '$.deviceId') device_id
                    ,row_number() over (partition by t1.pno order by pr.created_at desc) rn
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno and t1.last_valid_store_id = pr.store_id and pr.route_action = t1.last_valid_action
            ) a
        where
            a.rn = 1
    ) a1
left join ph_staging.login_device_record ldr on ldr.device_id = a1.device_id and ldr.created_at > date_sub(date(a1.last_valid_routed_at), interval  8 hour) and ldr.created_at < date_add(date(a1.last_valid_routed_at), interval 16 hour)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,pi.returned
            ,plt.client_id
            ,plt.last_valid_routed_at
            ,bc.client_name
            ,plt.last_valid_store_id
            ,ss.name last_valid_store
            ,plt.last_valid_action
            ,plt.last_valid_staff_info_id
            ,plt.operator_id
            ,coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) value
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2023-09-01'
            and plt.updated_at < '2023-12-01'
            -- and plt.penalties > 0
            and coalesce(if(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)=0, null,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100)), pi.cod_amount/100) > 5000
        group by 1
    )
select
    a1.pno, a1.returned, a1.client_id, a1.last_valid_routed_at, a1.client_name, a1.last_valid_store_id, a1.last_valid_store, a1.last_valid_action, a1.last_valid_staff_info_id, a1.operator_id, a1.value, a1.device_id
    ,group_concat(ldr.staff_info_id) 该设备登录员工ID
    ,count(ldr.staff_info_id) 该设备登录员工数
from
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,json_extract(pr.extra_value, '$.deviceId') device_id
                    ,row_number() over (partition by t1.pno order by pr.created_at desc) rn
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno and t1.last_valid_store_id = pr.store_id and pr.route_action = t1.last_valid_action
            ) a
        where
            a.rn = 1
    ) a1
left join ph_staging.login_device_record ldr on ldr.device_id = a1.device_id and ldr.created_at > date_sub(date(a1.last_valid_routed_at), interval  8 hour) and ldr.created_at < date_add(date(a1.last_valid_routed_at), interval 16 hour)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,if(pi.returned = 1, '是', '否') 是否退件
    ,if(pi.returned = 1, pi2.pno, pi.pno) 正向单号
    ,if(pi.returned = 1, pi.pno, null) 退件单号
    ,if(pi.returned = 1, ss3.name, ss.name)  正向单号揽件网点
    ,if(pi.returned = 1, ss4.name, ss2.name ) 正向单号派件网点
    ,if(pi.returned = 1, pi2.cod_amount/100, pi.cod_amount/100) COD
    ,plt.SS责任网点
    ,plt.套餐
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_1204_lj t on t.pno = pi.pno
left join  ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.ticket_delivery_store_id

left join ph_staging.sys_store ss3 on ss3.id = pi2.ticket_pickup_store_id
left join ph_staging.sys_store ss4 on ss4.id = pi2.ticket_delivery_store_id
left join
    (
        select
            plt.pno
            ,case plt.duty_type
                when 1 then '快递员100%套餐'
                when 2 then '仓7主3套餐(仓管70%主管30%)'
                when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
                when 5 then  '快递员721套餐(快递员70%仓管20%主管10%)'
                when 6 then  '仓管721套餐(仓管70%快递员20%主管10%)'
                when 8 then  'LH全责（LH100%）'
                when 7 then  '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
                when 21 then  '仓7主3套餐(仓管70%主管30%)'
            end 套餐
            ,group_concat(distinct ss.name) SS责任网点
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_1204_lj t on t.pno = plt.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.penalties > 0
            and plt.state = 6
        group by 1,2
    ) plt on plt.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,if(pi.returned = 1, '是', '否') 是否退件
    ,if(pi.returned = 1, pi2.pno, pi.pno) 正向单号
    ,if(pi.returned = 1, pi.pno, null) 退件单号
    ,if(pi.returned = 1, ss3.name, ss.name)  正向单号揽件网点
    ,if(pi.returned = 1, ss4.name, ss2.name ) 正向单号派件网点
    ,if(pi.returned = 1, pi2.cod_amount/100, pi.cod_amount/100) COD
    ,plt.SS责任网点
    ,plt.套餐
from tmpale.tmp_ph_pno_1204_lj t
left join ph_staging.parcel_info pi on t.pno = pi.pno
left join  ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.ticket_delivery_store_id

left join ph_staging.sys_store ss3 on ss3.id = pi2.ticket_pickup_store_id
left join ph_staging.sys_store ss4 on ss4.id = pi2.ticket_delivery_store_id
left join
    (
        select
            plt.pno
            ,case plt.duty_type
                when 1 then '快递员100%套餐'
                when 2 then '仓7主3套餐(仓管70%主管30%)'
                when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
                when 5 then  '快递员721套餐(快递员70%仓管20%主管10%)'
                when 6 then  '仓管721套餐(仓管70%快递员20%主管10%)'
                when 8 then  'LH全责（LH100%）'
                when 7 then  '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
                when 21 then  '仓7主3套餐(仓管70%主管30%)'
            end 套餐
            ,group_concat(distinct ss.name) SS责任网点
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_1204_lj t on t.pno = plt.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.penalties > 0
            and plt.state = 6
        group by 1,2
    ) plt on plt.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,if(pi.returned = 1, pi2.pno, pi.pno) 正向单号
    ,if(pi.returned = 1, pi.pno, null) 退件单号
    ,if(pi.returned = 1, ss3.name, ss.name)  正向单号揽件网点
    ,if(pi.returned = 1, ss4.name, ss2.name ) 正向单号派件网点
    ,if(pi.returned = 1, pi2.cod_amount/100, pi.cod_amount/100) COD
    ,plt.SS责任网点
    ,plt.套餐
from tmpale.tmp_ph_pno_1204_lj t
left join ph_staging.parcel_info pi on t.pno = pi.pno
left join  ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.ticket_delivery_store_id

left join ph_staging.sys_store ss3 on ss3.id = pi2.ticket_pickup_store_id
left join ph_staging.sys_store ss4 on ss4.id = pi2.ticket_delivery_store_id
left join
    (
        select
            plt.pno
            ,case plt.duty_type
                when 1 then '快递员100%套餐'
                when 2 then '仓7主3套餐(仓管70%主管30%)'
                when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
                when 5 then  '快递员721套餐(快递员70%仓管20%主管10%)'
                when 6 then  '仓管721套餐(仓管70%快递员20%主管10%)'
                when 8 then  'LH全责（LH100%）'
                when 7 then  '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
                when 21 then  '仓7主3套餐(仓管70%主管30%)'
            end 套餐
            ,group_concat(distinct ss.name) SS责任网点
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_1204_lj t on t.pno = plt.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.penalties > 0
            and plt.state = 6
        group by 1,2
    ) plt on plt.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
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
    ,ss.name '目的网点'
from tmpale.tmp_ph_pno_1204_lj_zcy t
left join  ph_staging.parcel_info pi on pi.pno = t.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno '运单号waybill'
            ,pi.client_id '客户ID Client ID'
            ,loi.item_name '物品名称Item Name'
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
    ) a2 on a2.pno = t1.运单号waybill and a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
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
    ) a2 on a2.pno = t1.运单号waybill and a2.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
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
    pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
         select
            dp.store_name 网点Branch
            ,dp.piece_name 片区District
            ,dp.region_name 大区Area
            ,plt.pno 运单Tracking_Number
            ,pi.exhibition_length 长
            ,pi.exhibition_width 宽
            ,pi.exhibition_height 高
            ,pi2.cod_amount/100 COD
            ,plt.created_at 任务创建时间Task_Generation_time
            ,plt.parcel_created_at 包裹揽收时间Receive_time
            ,concat(ddd.element, ddd.CN_element) 最后有效路由Last_effective_route
            ,plt.last_valid_routed_at 最后有效路由操作时间Last_effective_routing_time
            ,plt.last_valid_staff_info_id 最后有效路由操作员工Last_effective_route_operate_id
            ,ss.name 最后有效路由操作网点Last_operate_branch
        from ph_bi.parcel_lose_task plt
        left join ph_bi.parcel_detail pd on pd.pno = plt.pno
        left join ph_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month )
        left join  ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = plt.last_valid_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        where
            plt.source in (3,33)
            and plt.state in (1,2,3,4)
    )
select
   t1.*
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 到达网点时间
from t t1
left join
    (
        select
            pr.routed_at
            ,pr.pno
            ,row_number() over (partition by pr.pno order by pr.routed_at) rn
        from ph_staging.parcel_route pr
        join t t1 on t1.运单Tracking_Number = pr.pno and t1.网点Branch = pr.store_name
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a on a.pno = t1.运单Tracking_Number and a.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
with staff as
(
SELECT
    ss.staff_info_id

FROM
    (
    -- 上上月明细
    SELECT
        sm.staff_info_id
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id`
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `ph_backyard`.`staff_mileage_record` sm
        LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.staff_info_id
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id`
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `ph_backyard`.`staff_mileage_record` sm
        LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.staff_info_id=s.staff_info_id
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `ph_backyard`.`staff_mileage_record` sm
            LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-10-01'
            and sm.`mileage_date` <'2023-11-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `ph_backyard`.`staff_mileage_record` sm
            LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
                and sm.`mileage_date` < '2023-12-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
GROUP BY 1
)
SELECt
    sm.mileage_date 日期
    ,sm.staff_info_id 快递员
    ,st.`name` 网点名
    ,mr.`name` 大区
    ,mp.`name` 片区
    ,hjt.job_name 职位
    ,convert_tz(sm.started_at,'+00:00','+07:00') 上班汇报时间
    ,sm.start_kilometres/1000 里程表开始数据
    ,sm.end_kilometres/1000 里程表结束数据
    ,sm.end_kilometres/1000-sm.start_kilometres/1000 当日里程数
    ,sd.day_count 妥投件数
    ,sd.pickup_par_cnt 揽收件数

FROM `ph_backyard`.`staff_mileage_record` sm
JOIN staff as s on sm.`staff_info_id`=s.`staff_info_id`
LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
left join ph_bi.hr_job_title hjt on  hd.job_title=hjt.id
left join dwm.dwd_ph_inp_opt_staff_info_d sd on sd.staff_info_id=sm.`staff_info_id` and sm.mileage_date=sd.stat_date
where smr.`state` =1
and sm.`mileage_date` >= '2023-11-01'
and sm.`mileage_date` < '2023-12-01';
;-- -. . -..- - / . -. - .-. -.--
with staff as
(
SELECT
    ss.staff_info_id

FROM
    (
    -- 上上月明细
    SELECT
        sm.staff_info_id
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id`
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `ph_backyard`.`staff_mileage_record` sm
        LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.staff_info_id
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id`
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `ph_backyard`.`staff_mileage_record` sm
        LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.staff_info_id=s.staff_info_id
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `ph_backyard`.`staff_mileage_record` sm
            LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-10-01'
            and sm.`mileage_date` <'2023-11-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `ph_backyard`.`staff_mileage_record` sm
            LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
                and sm.`mileage_date` < '2023-12-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
GROUP BY 1
)
SELECt
    sm.mileage_date 日期
    ,sm.staff_info_id 快递员
    ,st.`name` 网点名
    ,mr.`name` 大区
    ,mp.`name` 片区
    ,hjt.job_name 职位
    ,convert_tz(sm.started_at,'+00:00','+07:00') 上班汇报时间
    ,sm.start_kilometres/1000 里程表开始数据
    ,sm.end_kilometres/1000 里程表结束数据
    ,sm.end_kilometres/1000-sm.start_kilometres/1000 当日里程数
    ,sd.delivery_par_cnt 妥投件数
    ,sd.pickup_par_cnt 揽收件数

FROM `ph_backyard`.`staff_mileage_record` sm
JOIN staff as s on sm.`staff_info_id`=s.`staff_info_id`
LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
left join ph_bi.hr_job_title hjt on  hd.job_title=hjt.id
left join dwm.dws_my_staff_wide_s sd on sd.staff_info_id=sm.`staff_info_id` and sm.mileage_date=sd.stat_date
where smr.`state` =1
and sm.`mileage_date` >= '2023-11-01'
and sm.`mileage_date` < '2023-12-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT
    ss.员工
    ,ss.网点名称
    ,ss.大区
    ,ss.片区
    ,ss.上上月日均里程数
    ,s.上月日均里程数
    ,ss.上上月日均妥投件数
    ,s.上月日均妥投件数
    ,st.网点人数变化幅度
    ,(s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数 人效变化幅度
    ,(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数 里程变化幅度
FROM
    (
    -- 上上月明细
    SELECT
        sm.员工
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id` 员工
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `ph_backyard`.`staff_mileage_record` sm
        LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >='2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.员工
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id` 员工
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `ph_backyard`.`staff_mileage_record` sm
        LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.员工=s.员工
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `ph_backyard`.`staff_mileage_record` sm
            LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >='2023-10-01'
            and sm.`mileage_date` < '2023-11-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `ph_backyard`.`staff_mileage_record` sm
            LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
                and sm.`mileage_date` < '2023-12-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
/*1. 快递员本月的日均里程和上月的日均里程做对比上涨超过30%；
2. 快递员的派件人效对比上月没有上涨超过20%；
3. 快递员所在网点的日均出勤van人数对比上月没有下降或下降不低于20%。
4. 当月里程>100公里*/
GROUP BY 1;
;-- -. . -..- - / . -. - .-. -.--
with staff as
(
SELECT
    ss.staff_info_id

FROM
    (
    -- 上上月明细
    SELECT
        sm.staff_info_id
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id`
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `ph_backyard`.`staff_mileage_record` sm
        LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.staff_info_id
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id`
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `ph_backyard`.`staff_mileage_record` sm
        LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.staff_info_id=s.staff_info_id
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `ph_backyard`.`staff_mileage_record` sm
            LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-10-01'
            and sm.`mileage_date` <'2023-11-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `ph_backyard`.`staff_mileage_record` sm
            LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `ph_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `ph_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
                and sm.`mileage_date` < '2023-12-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
GROUP BY 1
)
SELECt
    sm.mileage_date 日期
    ,sm.staff_info_id 快递员
    ,st.`name` 网点名
    ,mr.`name` 大区
    ,mp.`name` 片区
    ,hjt.job_name 职位
    ,convert_tz(sm.started_at,'+00:00','+07:00') 上班汇报时间
    ,sm.start_kilometres/1000 里程表开始数据
    ,sm.end_kilometres/1000 里程表结束数据
    ,sm.end_kilometres/1000-sm.start_kilometres/1000 当日里程数
    ,sd.delivery_par_cnt 妥投件数
    ,sd.pickup_par_cnt 揽收件数

FROM `ph_backyard`.`staff_mileage_record` sm
JOIN staff as s on sm.`staff_info_id`=s.`staff_info_id`
LEFT JOIN `ph_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
LEFT JOIN `ph_staging`.`sys_store` st on sm.`store_id` =st.`id`
LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
LEFT JOIN ph_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
left join ph_bi.hr_job_title hjt on  hd.job_title=hjt.id
left join dwm.dws_ph_staff_wide_s sd on sd.staff_info_id=sm.`staff_info_id` and sm.mileage_date=sd.stat_date
where smr.`state` =1
and sm.`mileage_date` >= '2023-11-01'
and sm.`mileage_date` < '2023-12-01';
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,vrv.link_id
from tmpale.tmp_ph_ivr_datail_1205 t
left join nl_production.violation_return_visit vrv on vrv.id = t.taskid;
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.pno
    ,vrv.id
    ,vrv.visit_state
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
    and vrv.visit_staff_id = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 );
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
    and vrv.visit_staff_id = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 );
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
    and vrv.visit_staff_id = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 )
    and vrv.visit_state  = 2;
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
    and  (vrv.visit_staff_id  = 10001 and vrv.visit_state = 2 )OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 );
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN');
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
    -- and  (vrv.visit_staff_id  = 10001 and vrv.visit_state = 2 )OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 )
    and visit_state = 2;
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
     and  (vrv.visit_staff_id  = 10001 and vrv.visit_state = 2 )OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 );
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
     -- and  (vrv.visit_staff_id  = 10001 and vrv.visit_state = 2 )OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 )
    and visit_state = 2;
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
     and vrv.visit_staff_id  = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 );
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
     and vrv.visit_staff_id  = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 )
    and vrv.type  = 3;
;-- -. . -..- - / . -. - .-. -.--
select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
    ,vrv.created_at
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
     and vrv.visit_staff_id  = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 )
    and vrv.type  = 3;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.id as store_id
    ,ss.name as store_name
    ,mp.name as piece_name
    ,mr.name as region_name
    ,adv.staff_info_id as staff_info_id
    ,hsi.job_title
    ,datediff(curdate(),hsi.hire_date)as work_days
    ,hsi.job_title as sub_job_title
    ,ss.id as sub_store_id
    ,ss.name as sub_store_name
    ,mp.name as sub_piece_name
    ,mr.name as sub_region_name
    ,adv.attendance_started_at
	,adv.attendance_end_at
	,('N') as if_support
from ph_staging.sys_store ss1
join ph_bi.attendance_data_v2 adv on ss1.id=adv.sys_store_id and adv.stat_date=current_date and (adv.attendance_started_at is not null or adv.attendance_end_at is not null)
join ph_bi.hr_staff_info hsi on adv.staff_info_id=hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id=hsi.sys_store_id #所属网点信息
left join ph_staging.sys_manage_piece mp on mp.id = ss.manage_piece #所属片区信息
left join ph_staging.sys_manage_region mr on mr.id = ss.manage_region #所属大区信息
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = hsi.staff_info_id and hsa.employment_begin_date <= curdate() and hsa.employment_end_date >= curdate() and hsa.status = 2
where ss1.category in(1,10)
    and hsi.state in(1,3)
    and hsi.job_title in (13,110,1000)
    and hsi.formal =1
    and hsa.staff_info_id is null

union all

select
    ss.id as store_id
    ,ss.name as store_name
    ,mp.name as piece_name
    ,mr.name as region_name
    ,hsa.staff_info_id
	,hsi.job_title
    ,datediff(curdate(),hsi.hire_date)as work_days
    ,hsa.job_title_id as sub_job_title
    ,ss1.id as sub_store_id
    ,ss1.name as sub_store_name
    ,mp1.name as sub_piece_name
    ,mr1.name as sub_region_name
    ,adv.attendance_started_at
	,adv.attendance_end_at
	,('Y') as if_support
from ph_backyard.hr_staff_apply_support_store hsa
join ph_bi.attendance_data_v2 adv on hsa.staff_info_id=adv.staff_info_id and adv.stat_date=current_date and (adv.attendance_started_at is not null or adv.attendance_end_at is not null)
join ph_bi.hr_staff_info hsi on hsi.staff_info_id =hsa.staff_info_id and hsi.formal =1
left join ph_staging.sys_store ss on ss.id=hsi.sys_store_id #所属网点信息
left join ph_staging.sys_manage_piece mp on mp.id = ss.manage_piece #所属片区信息
left join ph_staging.sys_manage_region mr on mr.id = ss.manage_region #所属大区信息
left join ph_staging.sys_store ss1 on ss1.id=hsa.store_id #所属网点信息
left join ph_staging.sys_manage_piece mp1 on mp1.id = ss1.manage_piece #所属片区信息
left join ph_staging.sys_manage_region mr1 on mr1.id = ss1.manage_region #所属大区信息
where hsa.status = 2 #支援审核通过
    and hsa.actual_begin_date <=current_date
    and coalesce(hsa.actual_end_date, curdate())>=current_date
    and hsa.employment_begin_date<=current_date
    and hsa.employment_end_date>=current_date
    and hsa.sub_staff_info_id>0
    and hsa.job_title_id in (13,110,1000)
    and hsi.formal =1;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.id as store_id
    ,ss.name as store_name
    ,mp.name as piece_name
    ,mr.name as region_name
    ,hsa.staff_info_id
	,hsi.job_title
    ,datediff(curdate(),hsi.hire_date)as work_days
    ,hsa.job_title_id as sub_job_title
    ,ss1.id as sub_store_id
    ,ss1.name as sub_store_name
    ,mp1.name as sub_piece_name
    ,mr1.name as sub_region_name
    ,adv.attendance_started_at
	,adv.attendance_end_at
	,('Y') as if_support
from ph_backyard.hr_staff_apply_support_store hsa
join ph_bi.attendance_data_v2 adv on hsa.staff_info_id=adv.staff_info_id and adv.stat_date=current_date and (adv.attendance_started_at is not null or adv.attendance_end_at is not null)
join ph_bi.hr_staff_info hsi on hsi.staff_info_id =hsa.staff_info_id and hsi.formal =1
left join ph_staging.sys_store ss on ss.id=hsi.sys_store_id #所属网点信息
left join ph_staging.sys_manage_piece mp on mp.id = ss.manage_piece #所属片区信息
left join ph_staging.sys_manage_region mr on mr.id = ss.manage_region #所属大区信息
left join ph_staging.sys_store ss1 on ss1.id=hsa.store_id #所属网点信息
left join ph_staging.sys_manage_piece mp1 on mp1.id = ss1.manage_piece #所属片区信息
left join ph_staging.sys_manage_region mr1 on mr1.id = ss1.manage_region #所属大区信息
where hsa.status = 2 #支援审核通过
    and hsa.actual_begin_date <=current_date
    and coalesce(hsa.actual_end_date, curdate())>=current_date
    and hsa.employment_begin_date<=current_date
    and hsa.employment_end_date>=current_date
    and hsa.sub_staff_info_id>0
    and hsa.job_title_id in (13,110,1000)
    and hsi.formal =1;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.id as store_id
    ,ss.name as store_name
    ,mp.name as piece_name
    ,mr.name as region_name
    ,hsa.staff_info_id
	,hsi.job_title
    ,datediff(curdate(),hsi.hire_date)as work_days
    ,hsa.job_title_id as sub_job_title
    ,ss1.id as sub_store_id
    ,ss1.name as sub_store_name
    ,mp1.name as sub_piece_name
    ,mr1.name as sub_region_name
    ,adv.attendance_started_at
	,adv.attendance_end_at
	,('Y') as if_support
from ph_backyard.hr_staff_apply_support_store hsa
join ph_bi.attendance_data_v2 adv on hsa.staff_info_id=adv.staff_info_id and adv.stat_date=current_date and (adv.attendance_started_at is not null or adv.attendance_end_at is not null)
join ph_bi.hr_staff_info hsi on hsi.staff_info_id =hsa.staff_info_id and hsi.formal =1
left join ph_staging.sys_store ss on ss.id=hsi.sys_store_id #所属网点信息
left join ph_staging.sys_manage_piece mp on mp.id = ss.manage_piece #所属片区信息
left join ph_staging.sys_manage_region mr on mr.id = ss.manage_region #所属大区信息
left join ph_staging.sys_store ss1 on ss1.id=hsa.store_id #所属网点信息
left join ph_staging.sys_manage_piece mp1 on mp1.id = ss1.manage_piece #所属片区信息
left join ph_staging.sys_manage_region mr1 on mr1.id = ss1.manage_region #所属大区信息
where hsa.status = 2 #支援审核通过
    and hsa.actual_begin_date <=current_date
    and coalesce(hsa.actual_end_date, curdate())>=current_date
    and hsa.employment_begin_date<=current_date
    and hsa.employment_end_date>=current_date
    and hsa.job_title_id in (13,110,1000)
    and hsi.formal =1;
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-11-29 16:00:00'
    and tp.created_at < '2023-12-01 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-11-29 16:00:00'
    and tp.created_at < '2023-12-02 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-12-02 16:00:00'
    and tp.created_at < '2023-12-05 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pr.routed_at, '+00:00', '+08:00')) 日期
    ,pr.staff_info_id
    ,pr.staff_info_name
    ,count(distinct pr.pno ) 交接包裹数
from ph_staging.parcel_route pr
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.routed_at > '2023-12-01 16:00:00'
    and pr.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plt.client_id
            ,plt.duty_reasons
            ,bc.client_name
            ,plt.parcel_created_at
            ,date_sub(plt.updated_at, interval 8 hour) update_time
        from ph_bi.parcel_lose_task plt
        join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        where
            plt.parcel_created_at >= '2023-10-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.duty_result = 1
            and plt.state = 6
        group by 1,2,3,4,5,6
    )
select
    month(a1.parcel_created_at) 揽收月份
    ,a1.parcel_created_at 揽收时间
    ,a1.client_name
    ,t2.t_value 判责原因
    ,if(pi2.cod_enabled = 1, 'y', 'n') 是否cod
    ,pi2.cod_amount/100 cod金额
    ,if(a1.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,if(pi.returned = 1, dai.returned_delivery_attempt_num, dai.delivery_attempt_num) 尝试派送次数
from
    (
        select
            t1.*
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > t1.update_time
        group by 1,2,3,4,5,6
    ) a1
left join ph_staging.parcel_info pi on pi.pno = a1.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_bi.translations t2 on t2.t_key = a1.duty_reasons and  t2.lang ='zh-CN'
left join ph_staging.delivery_attempt_info dai on dai.pno = pi2.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plt.client_id
            ,plt.duty_reasons
            ,bc.client_name
            ,plt.parcel_created_at
            ,date_sub(plt.updated_at, interval 8 hour) update_time
        from ph_bi.parcel_lose_task plt
        join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        where
            plt.parcel_created_at >= '2023-10-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.duty_result = 1
            and plt.state = 6
        group by 1,2,3,4,5,6
    )
select
    month(a1.parcel_created_at) 揽收月份
    ,a1.pno 包裹号
    ,pi2.pno 正向单号
    ,a1.parcel_created_at 揽收时间
    ,a1.client_name
    ,t2.t_value 判责原因
    ,if(pi2.cod_enabled = 1, 'y', 'n') 是否cod
    ,pi2.cod_amount/100 cod金额
    ,if(a1.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,if(pi.returned = 1, dai.returned_delivery_attempt_num, dai.delivery_attempt_num) 尝试派送次数
from
    (
        select
            t1.*
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > t1.update_time
        group by 1,2,3,4,5,6
    ) a1
left join ph_staging.parcel_info pi on pi.pno = a1.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_bi.translations t2 on t2.t_key = a1.duty_reasons and  t2.lang ='zh-CN'
left join ph_staging.delivery_attempt_info dai on dai.pno = pi2.pno;
;-- -. . -..- - / . -. - .-. -.--
select
          om.phone
          ,vr.task_id
          ,vr.non_reply_num
          ,om.stat_date
          ,om.send_at 发送时间
          ,if(om.delivered_at='1970-01-01 00:00:00',null,om.delivered_at) 送达时间
          ,if(om.read_at='1970-01-01 00:00:00',null,om.read_at)  阅读时间
          ,if(om.reply_at='1970-01-01 00:00:00',null,om.reply_at)  回复时间
          ,REPLACE (json_extract(json_extract(json_extract(im.content, '$.payload'),'$.content'),'$.text'),'"','') 回复内容
          ,case om.status when 1 then '已调用'
                          when 0 then '失败'
                          when 2 then '拒绝或账号不存在'
                          when 3 then '已发送'
                          when 4 then '已送达'
                          when 5 then '已读'
                          else null end as 状态
          ,row_number() over(partition by om.stat_date,om.phone,vr.task_id order by om.send_at) as rn
        from nl_production.chat_outbound_messages om
        left join nl_production.chat_inbound_messages im on om.umid=im.reply_to_umid
        left join nl_production.viber_return_visit vr on om.stat_date=vr.stat_date and om.phone=vr.mobile
        where om.src='bi_viber_visit'
        and om.service_provider=9
        and om.send_at>='2023-12-10'
        and om.send_at<date_add('2023-12-10',interval 1 day);
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,if(oi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,oi.cod_amount/100 cod
from tmpale.tmp_ph_pno_1211 t
join ph_staging.parcel_info pi on pi.pno = t.pno
left join  ph_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno);
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-12-05 16:00:00'
    and tp.created_at < '2023-12-08 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-12-05 16:00:00'
    and tp.created_at < '2023-12-07 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-12-07 16:00:00'
    and tp.created_at < '2023-12-10 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-12-07 16:00:00'
    and tp.created_at < '2023-12-09 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-12-09 16:00:00'
    and tp.created_at < '2023-12-10 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select date_sub(`current_date`, interval 6 day);
;-- -. . -..- - / . -. - .-. -.--
select date_sub(curdate(), interval 6 day);
;-- -. . -..- - / . -. - .-. -.--
select
            acc.pno
            ,am.staff_info_id
            ,acc.complaints_sub_type
            ,date(convert_tz(pi.finished_at, '+00:00', '+08:00')) fin_date
            ,pi.cod_amount
            ,pi.cod_enabled
            ,pi.dst_store_id
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_staging.parcel_info pi on pi.pno = acc.pno and pi.created_at > date_sub(curdate(), interval 40 day)
        where
            acc.complaints_type = 1 -- 虚假妥投
            and acc.created_at >= curdate()
            and acc.created_at < date_add(curdate(), interval 1 day)
        group by 1,2,3,4,5,6,7;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,case pi.state
        when 1 then 'RECEIVED'
        when 2 then 'IN_TRANSIT'
        when 3 then 'DELIVERING'
        when 4 then 'STRANDED'
        when 5 then 'SIGNED'
        when 6 then 'IN_DIFFICULTY'
        when 7 then 'RETURNED'
        when 8 then 'ABNORMAL_CLOSED'
        when 9 then 'CANCEL'
    end as parcel_tatus
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_1212  t on t.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            acc.pno
            ,am.staff_info_id
            ,acc.complaints_sub_type
            ,date(convert_tz(pi.finished_at, '+00:00', '+08:00')) fin_date
            ,pi.cod_amount
            ,pi.cod_enabled
            ,pi.dst_store_id
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_staging.parcel_info pi on pi.pno = acc.pno and pi.created_at > date_sub(curdate(), interval 40 day)
        where
            acc.complaints_type = 1 -- 虚假妥投
            and acc.created_at >= curdate()
            and acc.created_at < date_add(curdate(), interval 1 day)
        group by 1,2,3,4,5,6,7
    )
select
    t1.staff_info_id 工号
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,case
        when hsa.staff_info_id is null and hsi.formal = 1 then '自有'
        when hsa.staff_info_id is not null and hsi.formal = 1 then '支援'
        when hsi.formal = 0 and hsi.hire_type = 11 then '外协'
        when hsi.formal = 0 and hsi.hire_type = 12 then '众包'
    end 快递员分类
    ,if(mw.created_at is not null, '有', '无')  是否收到过警告信
    ,mw.created_at 最近一封警告信日期
    ,if(hsa.staff_info_id is not null, '是', '否') 是否在支援时虚假妥投
    ,hsa.store_name  支援网点
    ,hsa.region_name 支援大区
    ,t1.pno 运单号
    ,if(t1.cod_enabled = 1, '是', '否') 是否COD包裹
    ,case t1.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4 then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6 then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8 then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10 then '未提前电话联系客户'
        when 11 then '包裹破损 没有数据'
        when 12 then '未按照改约时间派件'
        when 13 then '未按订单带包装'
        when 14 then '不找零钱'
        when 15 then '客户通话记录内未看到员工电话'
        when 16 then '未经客户允许取消揽件任务'
        when 17 then '未给客户回执'
        when 18 then '拨打电话时间太短，客户来不及接电话'
        when 19 then '未经客户允许退件'
        when 20 then '没有上门'
        when 21 then '其他'
        when 22 then '未经客户同意改约揽件时间'
        when 23 then '改约的揽件时间和客户要求的时间不一致'
        when 24 then '没有按照改约时间揽件'
        when 25 then '揽件前未提前联系客户'
        when 26 then '答应客户揽件，但最终没有揽'
        when 27 then '很晚才打电话联系客户'
        when 28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29 then '因为超过当日截单时间，要求客户取消'
        when 30 then '声称不是自己负责的区域，要求客户取消'
        when 31 then '拨打电话时间太短，客户来不及接电话'
        when 32 then '不接听客户回复的电话'
        when 33 then '答应客户今天上门，但最终没有揽收'
        when 34 then '没有上门揽件，也没有打电话联系客户'
        when 35 then '货物不属于超大件/违禁品'
        when 36 then '没有收到包裹，且快递员没有联系客户'
        when 37 then '快递员拒绝上门派送'
        when 38 then '快递员擅自将包裹放在门口或他处'
        when 39 then '快递员没有按约定的时间派送'
        when 40 then '代替客户签收包裹'
        when 41 then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42 then '说话不礼貌/没有礼貌/不愿意服务'
        when 43 then '快递员抛包裹'
        when 44 then '报复/骚扰客户'
        when 45 then '快递员收错COD金额'
        when 46 then '虚假妥投'
        when 47 then '派件虚假留仓件/问题件'
        when 48 then '虚假揽件改约时间/取消揽件任务'
        when 49 then '抛客户包裹'
        when 50 then '录入客户信息不正确'
        when 51 then '送货前未电话联系'
        when 52 then '未在约定时间上门'
        when 53 then '上门前不电话联系'
        when 54 then '以不礼貌的态度对待客户'
        when 55 then '录入客户信息不正确'
        when 56 then '与客户发生肢体接触'
        when 57 then '辱骂客户'
        when 58 then '威胁客户'
        when 59 then '上门揽件慢'
        when 60 then '快递员拒绝上门揽件'
        when 61 then '未经客户同意标记收件人拒收'
        when 62 then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '虚假类型'
    ,t1.fin_date 违规日期
    ,today.pno_count 当天虚假妥投件数
    ,7st.pno_count 近7天虚假妥投件数
    ,30st.pno_count 近30天虚假妥投件数
    ,if(hsi.stop_duties_count > 0, '是', '否') 是否停过职
    ,if(30st.pno_count > 0, '是', '否') 是否近1个月被投诉过
    ,if(a1.pno is not null, '是', '否') 是否高价值
    ,if(at1.staff_info_id is not null and at2.staff_info_id is not null and hsi.state = 1, '是', '否') 是否连续旷工两天未被停职
from t t1
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id
left join  dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            mw.created_at
            ,mw.staff_info_id
            ,row_number() over (partition by t1.staff_info_id order by mw.created_at desc) rk
        from ph_backyard.message_warning mw
        join t t1 on t1.staff_info_id = mw.staff_info_id
        where
            mw.is_delete = 0
    ) mw on mw.staff_info_id = t1.staff_info_id and mw.rk = 1 and mw.rk = 1
left join
    (
        select
            hsa.store_name
            ,dp.region_name
            ,hsa.staff_info_id
        from ph_backyard.hr_staff_apply_support_store hsa
        join t t1 on t1.staff_info_id = hsa.staff_info_id
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsa.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            hsa.created_at >= date_sub(curdate(), interval 60 day)
            and hsa.employment_begin_date <= t1.fin_date
            and hsa.employment_end_date >= t1.fin_date
            and hsa.status = 2
    ) hsa on hsa.staff_info_id = t1.staff_info_id
left join
    (
        select
            am.staff_info_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.created_at >= curdate()
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) today on today.staff_info_id = t1.staff_info_id
left join
    (
        select
            am.staff_info_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.created_at >= date_sub(curdate(), interval 6 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 7st on 7st.staff_info_id = t1.staff_info_id
left join
    (
        select
            am.staff_info_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 30st on 30st.staff_info_id = t1.staff_info_id
left join
    (
        select
            t1.pno
        from t t1
        left join ph_staging.parcel_info pi on t1.pno = pi.pno
        left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            pi.created_at >= date_sub(curdate(), interval 60 day)
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
        group by 1
    ) a1 on a1.pno = t1.pno
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join t t1 on t1.staff_info_id = ad.staff_info_id
        where
            ad.stat_date <= t1.fin_date
            and ad.stat_date >= date_sub(t1.fin_date, interval 1 day )
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
        group by 1
    ) at1 on at1.staff_info_id = t1.staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join t t1 on t1.staff_info_id = ad.staff_info_id
        where
            ad.stat_date <= date_sub(t1.fin_date, interval 1 day )
            and ad.stat_date >= date_sub(t1.fin_date, interval 2 day )
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
        group by 1
    ) at2 on at2.staff_info_id = t1.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            acc.pno
            ,am.staff_info_id
            ,acc.complaints_sub_type
            ,date(convert_tz(pi.finished_at, '+00:00', '+08:00')) fin_date
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_staging.parcel_info pi on pi.pno = acc.pno
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.complaints_type = 1 -- 虚假妥投
    )
select
    dp.store_name 网点
    ,dp.region_name 大区
    ,count(distinct if(hsa.staff_info_id is null, t1.staff_info_id, null)) 网点自有员工违规人数
    ,count(distinct if(hsa.staff_info_id is not null, t1.staff_info_id, null)) 前往支援违规人数
    ,count(distinct t1.pno) 虚假件数
    ,7st.pno_count 近7天虚假妥投件数
    ,30st.pno_count 近30天虚假妥投件数
from t t1
left join
    (
        select
            hsa.store_name
            ,dp.region_name
            ,hsa.staff_info_id
            ,t1.fin_date
        from ph_backyard.hr_staff_apply_support_store hsa
        join t t1 on t1.staff_info_id = hsa.staff_info_id
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsa.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            hsa.created_at >= date_sub(curdate(), interval 60 day)
            and hsa.employment_begin_date <= t1.fin_date
            and hsa.employment_end_date >= t1.fin_date
            and hsa.status = 2
    ) hsa  on hsa.staff_info_id = t1.staff_info_id and hsa.fin_date = t1.fin_date
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = am.staff_info_id
        where
            acc.created_at >= date_sub(curdate(), interval 6 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 7st on 7st.sys_store_id = hsi.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = am.staff_info_id
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 30st on 30st.sys_store_id = hsi.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            acc.pno
            ,am.staff_info_id
            ,acc.complaints_sub_type
            ,date(convert_tz(pi.finished_at, '+00:00', '+08:00')) fin_date
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_staging.parcel_info pi on pi.pno = acc.pno
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.complaints_type = 1 -- 虚假妥投
    )
select
    dp.store_name 网点
    ,dp.region_name 大区
    ,count(distinct if(hsa.staff_info_id is null, t1.staff_info_id, null)) 网点自有员工违规人数
    ,count(distinct if(hsa.staff_info_id is not null, t1.staff_info_id, null)) 前往支援违规人数
    ,count(distinct t1.pno) 虚假件数
    ,7st.pno_count 近7天虚假妥投件数
    ,30st.pno_count 近30天虚假妥投件数
from t t1
left join
    (
        select
            hsa.store_name
            ,dp.region_name
            ,hsa.staff_info_id
            ,t1.fin_date
        from ph_backyard.hr_staff_apply_support_store hsa
        join t t1 on t1.staff_info_id = hsa.staff_info_id
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsa.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            hsa.created_at >= date_sub(curdate(), interval 60 day)
            and hsa.employment_begin_date <= t1.fin_date
            and hsa.employment_end_date >= t1.fin_date
            and hsa.status = 2
    ) hsa  on hsa.staff_info_id = t1.staff_info_id and hsa.fin_date = t1.fin_date
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = am.staff_info_id
        where
            acc.created_at >= date_sub(curdate(), interval 6 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 7st on 7st.sys_store_id = hsi.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = am.staff_info_id
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 30st on 30st.sys_store_id = hsi.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            acc.pno
            ,am.staff_info_id
            ,acc.complaints_sub_type
            ,date(convert_tz(pi.finished_at, '+00:00', '+08:00')) fin_date
            ,pi.cod_amount
            ,pi.cod_enabled
            ,pi.dst_store_id
            ,acc.qaqc_callback_result
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_staging.parcel_info pi on pi.pno = acc.pno and pi.created_at > date_sub(curdate(), interval 40 day)
        where
            acc.complaints_type = 1 -- 虚假妥投
            and acc.created_at >= curdate()
            and acc.created_at < date_add(curdate(), interval 1 day)
        group by 1,2,3,4,5,6,7,8
    )
select
    t1.staff_info_id 工号
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,case
        when hsa.staff_info_id is null and hsi.formal = 1 then '自有'
        when hsa.staff_info_id is not null and hsi.formal = 1 then '支援'
        when hsi.formal = 0 and hsi.hire_type = 11 then '外协'
        when hsi.formal = 0 and hsi.hire_type = 12 then '众包'
    end 快递员分类
    ,if(mw.created_at is not null, '有', '无')  是否收到过警告信
    ,mw.created_at 最近一封警告信日期
    ,if(hsa.staff_info_id is not null, '是', '否') 是否在支援时虚假妥投
    ,hsa.store_name  支援网点
    ,hsa.region_name 支援大区
    ,t1.pno 运单号
    ,if(t1.cod_enabled = 1, '是', '否') 是否COD包裹
    ,case t1.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4 then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6 then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8 then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10 then '未提前电话联系客户'
        when 11 then '包裹破损 没有数据'
        when 12 then '未按照改约时间派件'
        when 13 then '未按订单带包装'
        when 14 then '不找零钱'
        when 15 then '客户通话记录内未看到员工电话'
        when 16 then '未经客户允许取消揽件任务'
        when 17 then '未给客户回执'
        when 18 then '拨打电话时间太短，客户来不及接电话'
        when 19 then '未经客户允许退件'
        when 20 then '没有上门'
        when 21 then '其他'
        when 22 then '未经客户同意改约揽件时间'
        when 23 then '改约的揽件时间和客户要求的时间不一致'
        when 24 then '没有按照改约时间揽件'
        when 25 then '揽件前未提前联系客户'
        when 26 then '答应客户揽件，但最终没有揽'
        when 27 then '很晚才打电话联系客户'
        when 28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29 then '因为超过当日截单时间，要求客户取消'
        when 30 then '声称不是自己负责的区域，要求客户取消'
        when 31 then '拨打电话时间太短，客户来不及接电话'
        when 32 then '不接听客户回复的电话'
        when 33 then '答应客户今天上门，但最终没有揽收'
        when 34 then '没有上门揽件，也没有打电话联系客户'
        when 35 then '货物不属于超大件/违禁品'
        when 36 then '没有收到包裹，且快递员没有联系客户'
        when 37 then '快递员拒绝上门派送'
        when 38 then '快递员擅自将包裹放在门口或他处'
        when 39 then '快递员没有按约定的时间派送'
        when 40 then '代替客户签收包裹'
        when 41 then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42 then '说话不礼貌/没有礼貌/不愿意服务'
        when 43 then '快递员抛包裹'
        when 44 then '报复/骚扰客户'
        when 45 then '快递员收错COD金额'
        when 46 then '虚假妥投'
        when 47 then '派件虚假留仓件/问题件'
        when 48 then '虚假揽件改约时间/取消揽件任务'
        when 49 then '抛客户包裹'
        when 50 then '录入客户信息不正确'
        when 51 then '送货前未电话联系'
        when 52 then '未在约定时间上门'
        when 53 then '上门前不电话联系'
        when 54 then '以不礼貌的态度对待客户'
        when 55 then '录入客户信息不正确'
        when 56 then '与客户发生肢体接触'
        when 57 then '辱骂客户'
        when 58 then '威胁客户'
        when 59 then '上门揽件慢'
        when 60 then '快递员拒绝上门揽件'
        when 61 then '未经客户同意标记收件人拒收'
        when 62 then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '虚假类型'
    ,case t1.qaqc_callback_result
        when 0 then '待回访'
        when 1 then '多次未联系上客户'
        when 2 then '误投诉'
        when 3 then '真实投诉，后接受道歉'
        when 4 then '真实投诉，后不接受道歉'
        when 5 then '真实投诉，后受到骚扰/威胁'
        when 6 then '没有快递员联系客户道歉'
        when 7 then '客户投诉回访结果'
        when 8 then '确认网点已联系客户道歉'
        when 20 then '联系不上'
    end '回访结果'
    ,t1.fin_date 违规日期
    ,today.pno_count 当天虚假妥投件数
    ,7st.pno_count 近7天虚假妥投件数
    ,30st.pno_count 近30天虚假妥投件数
    ,if(hsi.stop_duties_count > 0, '是', '否') 是否停过职
    ,if(30st.pno_count > 0, '是', '否') 是否近1个月被投诉过
    ,if(a1.pno is not null, '是', '否') 是否高价值
    ,if(at1.staff_info_id is not null and at2.staff_info_id is not null and hsi.state = 1, '是', '否') 是否连续旷工两天未被停职
from t t1
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id
left join  dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            mw.created_at
            ,mw.staff_info_id
            ,row_number() over (partition by t1.staff_info_id order by mw.created_at desc) rk
        from ph_backyard.message_warning mw
        join t t1 on t1.staff_info_id = mw.staff_info_id
        where
            mw.is_delete = 0
    ) mw on mw.staff_info_id = t1.staff_info_id and mw.rk = 1 and mw.rk = 1
left join
    (
        select
            hsa.store_name
            ,dp.region_name
            ,hsa.staff_info_id
        from ph_backyard.hr_staff_apply_support_store hsa
        join t t1 on t1.staff_info_id = hsa.staff_info_id
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsa.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            hsa.created_at >= date_sub(curdate(), interval 60 day)
            and hsa.employment_begin_date <= t1.fin_date
            and hsa.employment_end_date >= t1.fin_date
            and hsa.status = 2
    ) hsa on hsa.staff_info_id = t1.staff_info_id
left join
    (
        select
            am.staff_info_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.created_at >= curdate()
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) today on today.staff_info_id = t1.staff_info_id
left join
    (
        select
            am.staff_info_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.created_at >= date_sub(curdate(), interval 6 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 7st on 7st.staff_info_id = t1.staff_info_id
left join
    (
        select
            am.staff_info_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 30st on 30st.staff_info_id = t1.staff_info_id
left join
    (
        select
            t1.pno
        from t t1
        left join ph_staging.parcel_info pi on t1.pno = pi.pno
        left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            pi.created_at >= date_sub(curdate(), interval 60 day)
            and coalesce(if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100), pi.cod_amount/100) > 5000
        group by 1
    ) a1 on a1.pno = t1.pno
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join t t1 on t1.staff_info_id = ad.staff_info_id
        where
            ad.stat_date <= t1.fin_date
            and ad.stat_date >= date_sub(t1.fin_date, interval 1 day )
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
        group by 1
    ) at1 on at1.staff_info_id = t1.staff_info_id
left join
    (
        select
            ad.staff_info_id
        from ph_bi.attendance_data_v2 ad
        join t t1 on t1.staff_info_id = ad.staff_info_id
        where
            ad.stat_date <= date_sub(t1.fin_date, interval 1 day )
            and ad.stat_date >= date_sub(t1.fin_date, interval 2 day )
            and ad.attendance_time + ad.BT + ad.BT_Y + ad.AB > 0
            and ad.attendance_started_at is null
            and ad.attendance_end_at is null
        group by 1
    ) at2 on at2.staff_info_id = t1.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            acc.pno
            ,am.staff_info_id
            ,acc.complaints_sub_type
            ,date(convert_tz(pi.finished_at, '+00:00', '+08:00')) fin_date
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_staging.parcel_info pi on pi.pno = acc.pno
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.complaints_type = 1 -- 虚假妥投
    )
select
    a1.网点
    ,a1.大区
    ,a1.网点自有员工违规人数
    ,a1.前往支援违规人数
    ,a1.虚假件数
    ,7st.pno_count 近7天虚假妥投件数
    ,30st.pno_count 近30天虚假妥投件数
from
    (
                select
            dp.store_id
            ,dp.store_name 网点
            ,dp.region_name 大区
            ,count(distinct if(hsa.staff_info_id is null, t1.staff_info_id, null)) 网点自有员工违规人数
            ,count(distinct if(hsa.staff_info_id is not null, t1.staff_info_id, null)) 前往支援违规人数
            ,count(distinct t1.pno) 虚假件数
        #     ,7st.pno_count 近7天虚假妥投件数
        #     ,30st.pno_count 近30天虚假妥投件数
        from t t1
        left join
            (
                select
                    hsa.store_name
                    ,dp.region_name
                    ,hsa.staff_info_id
                    ,t1.fin_date
                from ph_backyard.hr_staff_apply_support_store hsa
                join t t1 on t1.staff_info_id = hsa.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsa.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
                where
                    hsa.created_at >= date_sub(curdate(), interval 60 day)
                    and hsa.employment_begin_date <= t1.fin_date
                    and hsa.employment_end_date >= t1.fin_date
                    and hsa.status = 2
            ) hsa  on hsa.staff_info_id = t1.staff_info_id and hsa.fin_date = t1.fin_date
        left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        group by 1,2
    ) a1
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = am.staff_info_id
        where
            acc.created_at >= date_sub(curdate(), interval 6 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 7st on 7st.sys_store_id = a1.store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct acc.pno) pno_count
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = am.staff_info_id
        where
            acc.created_at >= date_sub(curdate(), interval 29 day)
            and acc.created_at < date_add(curdate(), interval 1 day)
            and acc.complaints_type = 1 -- 虚假妥投
        group by 1
    ) 30st on 30st.sys_store_id = a1.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pr.staff_info_id 操作人
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
    end as 包裹状态
    ,json_extract(pr.extra_value, '$.carrierName') 运营商
from ph_staging.parcel_route pr
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'PHONE'
    and pr.routed_at > '2023-12-10 16:00:00'
    and json_extract(pr.extra_value, '$.callDuration') >= 14
    and json_extract(pr.extra_value, '$.callDuration') <= 17
    and json_extract(pr.extra_value, '$.diaboloDuration') >= 3
    and json_extract(pr.extra_value, '$.diaboloDuration') <= 5
group by 1,2,3,4,5,6,7;
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-12-10 16:00:00'
    and tp.created_at < '2023-12-13 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-12-10 16:00:00'
    and tp.created_at < '2023-12-12 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-12-12 16:00:00'
    and tp.created_at < '2023-12-13 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select * from tmpale.tmp_ph_pno_lj_1214 t;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,ss.name 揽收网点
    ,ss2.name 派送网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_1214 t on t.pno = pi.pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 1, pi2.customary_pno, pi2.pno) = pi2.pno
left join ph_staging.sys_store ss on ss.id = pi2.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi2.ticket_delivery_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,ss.name 揽收网点
    ,ss2.name 派送网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_1214 t on t.pno = pi.pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno) = pi2.pno
left join ph_staging.sys_store ss on ss.id = pi2.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi2.ticket_delivery_store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
        select
            a1.*
        from
            (
                select
                    a.*
                from
                    (
                        select
                            pi.pno
                            ,pi.returned
                            ,pi.client_id
                            ,pi.state
                            ,pi.ticket_pickup_store_id
                            ,pi.dst_store_id
                            ,pi.customary_pno
                            ,pr.store_name
                            ,pr.store_id
                            ,pi.interrupt_category
                            ,pr.route_action
                            ,pr.routed_at
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                        from ph_staging.parcel_info pi
                        left join ph_staging.parcel_route pr on pr.pno = pi.pno
                        where
                            pi.state not in (5,7,8,9)
                            and pi.created_at < date_sub(now(), interval 56 hour)
                            and pi.created_at > date_sub(curdate(), interval 100 day)
                            and pr.routed_at > date_sub(curdate(), interval 60 day)
                            and pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
                    ) a
                where
                    a.rk = 1
            ) a1
        where
            a1.routed_at < date_sub(now(), interval 56 hour)
)
select
    t1.pno
    ,if(t1.returned = 0, '正向', '退件') 包裹流向
    ,t1.client_id
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,ss2.name 揽收网点
    ,case
        when ss2.province_code in ('PH01','PH02','PH03','PH04','PH05','PH06','PH07','PH08','PH09','PH10','PH11','PH12','PH13','PH14','PH15','PH16','PH17','PH18','PH19','PH20','PH21','PH22','PH23','PH24','PH25','PH26','PH27','PH61','PH62','PH63','PH64','PH65','PH66','PH67','PH78','PH79','PH80','PH82') then 'Luzon'
        when ss2.province_code in ('PH44','PH45','PH46','PH47','PH48','PH49','PH50','PH51','PH52','PH53','PH54','PH55','PH56','PH57','PH58','PH59','PH60','PH68','PH69','PH70','PH71','PH72','PH73','PH74','PH75','PH76','PH77','PH83') then 'Mindanao'
        when ss2.province_code in ('PH81') then 'Palawan'
        when ss2.province_code in ('PH28','PH29','PH30','PH31','PH32','PH33','PH34','PH35','PH36','PH37','PH38','PH39','PH40','PH41','PH42','PH43') then 'Visayas'
    end 揽收岛屿
    ,ss3.name 目的地网点
    ,case
        when ss3.province_code in ('PH01','PH02','PH03','PH04','PH05','PH06','PH07','PH08','PH09','PH10','PH11','PH12','PH13','PH14','PH15','PH16','PH17','PH18','PH19','PH20','PH21','PH22','PH23','PH24','PH25','PH26','PH27','PH61','PH62','PH63','PH64','PH65','PH66','PH67','PH78','PH79','PH80','PH82') then 'Luzon'
        when ss3.province_code in ('PH44','PH45','PH46','PH47','PH48','PH49','PH50','PH51','PH52','PH53','PH54','PH55','PH56','PH57','PH58','PH59','PH60','PH68','PH69','PH70','PH71','PH72','PH73','PH74','PH75','PH76','PH77','PH83') then 'Mindanao'
        when ss3.province_code in ('PH81') then 'Palawan'
        when ss3.province_code in ('PH28','PH29','PH30','PH31','PH32','PH33','PH34','PH35','PH36','PH37','PH38','PH39','PH40','PH41','PH42','PH43') then 'Visayas'
    end 目的地岛屿
    ,case a2.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 判责类型
    ,a2.updated_at 判责日期
    ,a3.created_at 最近进入闪速系统时间
#     ,t1.route_action
    ,case t1.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一次有效路由操作
    ,t1.store_name 最后一次有效路由网点
    ,convert_tz(ss.routed_at, '+00:00', '+08:00') 到达网点时间
    ,date(convert_tz(t1.routed_at, '+00:00', '+08:00')) 最后一次有效路由时间
    ,timestampdiff(hour, convert_tz(t1.routed_at, '+00:00', '+08:00'), now()) 最近一次有效路由至今小时数
    ,if(t1.returned = 0, dai.delivery_attempt_num, dai.returned_delivery_attempt_num) 尝试派送次数
    ,if(t1.interrupt_category = 3, '是', '否') 是否有待退件标记
    ,case
        when t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139') and curdate() > laz.delievey_end_date then '是'
        when t1.client_id in ('AA0131', 'AA0132') and curdate() > tik.end_date then '是'
        when t1.client_id in ('AA0090', 'AA0128','AA0089') and curdate() > sho.end_date then '是'
        when t1.client_id in ('AA0149', 'AA0148') and curdate() > she.delievey_end_date then '是'
        else null
    end 是否已经超时
    ,case
        when t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139') and curdate() > laz.delievey_end_date then datediff(curdate(), laz.delievey_end_date)
        when t1.client_id in ('AA0131', 'AA0132') and curdate() > tik.end_date then datediff(curdate(), tik.end_date)
        when t1.client_id in ('AA0090', 'AA0128','AA0089') and curdate() > sho.end_date then datediff(curdate(), sho.end_date)
        when t1.client_id in ('AA0149', 'AA0148') and curdate() > she.delievey_end_date then datediff(curdate(), she.delievey_end_date)
        else null
    end  超时天数
    ,if(t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139'), oi.insure_declare_value/100, oi.cogs_amount/100) cogs金额
    ,oi.cod_amount/100 cod金额
from t t1
left join
    (
        select
            plt.pno
            ,plt.updated_at
            ,plt.duty_result
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 6
    ) a2 on a2.pno = t1.pno
left join
    (
        select
            plt.pno
            ,plt.created_at
            ,row_number() over (partition by plt.pno order by plt.created_at desc ) rk
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at > date_sub(curdate(), interval 100 day)
    ) a3 on a3.pno = t1.pno and a3.rk = 1
left join dwm.dwd_ex_ph_lazada_pno_period laz on laz.pno = t1.pno
left join dwm.dwd_ex_shopee_pno_period sho on sho.pno = t1.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tik on tik.pno = t1.pno
left join dwm.dwd_ex_ph_shein_sla_detail she on she.pno = t1.pno
left join ph_staging.delivery_attempt_info dai on dai.pno = if(t1.returned = 0, t1.pno, t1.customary_pno)
left join
    (
        select
            pr.routed_at
            ,pr.pno
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.store_id
        where
            pr.routed_at > date_sub(curdate(), interval 60 day)
            and  pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) ss on ss.pno = t1.pno and ss.rk = 1
left join ph_staging.order_info oi on oi.pno = t1.pno
left join ph_staging.sys_store ss2 on ss2.id = t1.ticket_pickup_store_id
left join ph_staging.sys_store ss3 on ss3.id = t1.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
            a1.*
        from
            (
                select
                    a.*
                from
                    (
                        select
                            pi.pno
                            ,pi.returned
                            ,pi.client_id
                            ,pi.state
                            ,pi.ticket_pickup_store_id
                            ,pi.dst_store_id
                            ,pi.customary_pno
                            ,pr.store_name
                            ,pr.store_id
                            ,pi.interrupt_category
                            ,pr.route_action
                            ,pr.routed_at
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                        from ph_staging.parcel_info pi
                        left join ph_staging.parcel_route pr on pr.pno = pi.pno
                        where
                            pi.state not in (5,7,8,9)
                            and pi.created_at < date_sub(now(), interval 56 hour)
                            and pi.created_at > date_sub(curdate(), interval 100 day)
                            and pr.routed_at > date_sub(curdate(), interval 40 day)
                            and pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
                    ) a
                where
                    a.rk = 1
            ) a1
        where
            a1.routed_at < date_sub(now(), interval 56 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
        select
            a1.*
        from
            (
                select
                    a.*
                from
                    (
                        select
                            pi.pno
                            ,pi.returned
                            ,pi.client_id
                            ,pi.state
                            ,pi.ticket_pickup_store_id
                            ,pi.dst_store_id
                            ,pi.customary_pno
                            ,pr.store_name
                            ,pr.store_id
                            ,pi.interrupt_category
                            ,pr.route_action
                            ,pr.routed_at
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                        from ph_staging.parcel_info pi
                        left join ph_staging.parcel_route pr on pr.pno = pi.pno
                        where
                            pi.state not in (5,7,8,9)
                            and pi.created_at < date_sub(now(), interval 56 hour)
                            and pi.created_at > date_sub(curdate(), interval 100 day)
                            and pr.routed_at > date_sub(curdate(), interval 40 day)
                            and pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
                    ) a
                where
                    a.rk = 1
            ) a1
        where
            a1.routed_at < date_sub(now(), interval 56 hour)
)
select
    t1.pno
    ,if(t1.returned = 0, '正向', '退件') 包裹流向
    ,t1.client_id
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,ss2.name 揽收网点
    ,case
        when ss2.province_code in ('PH01','PH02','PH03','PH04','PH05','PH06','PH07','PH08','PH09','PH10','PH11','PH12','PH13','PH14','PH15','PH16','PH17','PH18','PH19','PH20','PH21','PH22','PH23','PH24','PH25','PH26','PH27','PH61','PH62','PH63','PH64','PH65','PH66','PH67','PH78','PH79','PH80','PH82') then 'Luzon'
        when ss2.province_code in ('PH44','PH45','PH46','PH47','PH48','PH49','PH50','PH51','PH52','PH53','PH54','PH55','PH56','PH57','PH58','PH59','PH60','PH68','PH69','PH70','PH71','PH72','PH73','PH74','PH75','PH76','PH77','PH83') then 'Mindanao'
        when ss2.province_code in ('PH81') then 'Palawan'
        when ss2.province_code in ('PH28','PH29','PH30','PH31','PH32','PH33','PH34','PH35','PH36','PH37','PH38','PH39','PH40','PH41','PH42','PH43') then 'Visayas'
    end 揽收岛屿
    ,ss3.name 目的地网点
    ,case
        when ss3.province_code in ('PH01','PH02','PH03','PH04','PH05','PH06','PH07','PH08','PH09','PH10','PH11','PH12','PH13','PH14','PH15','PH16','PH17','PH18','PH19','PH20','PH21','PH22','PH23','PH24','PH25','PH26','PH27','PH61','PH62','PH63','PH64','PH65','PH66','PH67','PH78','PH79','PH80','PH82') then 'Luzon'
        when ss3.province_code in ('PH44','PH45','PH46','PH47','PH48','PH49','PH50','PH51','PH52','PH53','PH54','PH55','PH56','PH57','PH58','PH59','PH60','PH68','PH69','PH70','PH71','PH72','PH73','PH74','PH75','PH76','PH77','PH83') then 'Mindanao'
        when ss3.province_code in ('PH81') then 'Palawan'
        when ss3.province_code in ('PH28','PH29','PH30','PH31','PH32','PH33','PH34','PH35','PH36','PH37','PH38','PH39','PH40','PH41','PH42','PH43') then 'Visayas'
    end 目的地岛屿
    ,case a2.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 判责类型
    ,a2.updated_at 判责日期
    ,a3.created_at 最近进入闪速系统时间
#     ,t1.route_action
    ,case t1.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一次有效路由操作
    ,t1.store_name 最后一次有效路由网点
    ,convert_tz(ss.routed_at, '+00:00', '+08:00') 到达网点时间
    ,date(convert_tz(t1.routed_at, '+00:00', '+08:00')) 最后一次有效路由时间
    ,timestampdiff(hour, convert_tz(t1.routed_at, '+00:00', '+08:00'), now()) 最近一次有效路由至今小时数
    ,if(t1.returned = 0, dai.delivery_attempt_num, dai.returned_delivery_attempt_num) 尝试派送次数
    ,if(t1.interrupt_category = 3, '是', '否') 是否有待退件标记
    ,case
        when t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139') and curdate() > laz.delievey_end_date then '是'
        when t1.client_id in ('AA0131', 'AA0132') and curdate() > tik.end_date then '是'
        when t1.client_id in ('AA0090', 'AA0128','AA0089') and curdate() > sho.end_date then '是'
        when t1.client_id in ('AA0149', 'AA0148') and curdate() > she.delievey_end_date then '是'
        else null
    end 是否已经超时
    ,case
        when t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139') and curdate() > laz.delievey_end_date then datediff(curdate(), laz.delievey_end_date)
        when t1.client_id in ('AA0131', 'AA0132') and curdate() > tik.end_date then datediff(curdate(), tik.end_date)
        when t1.client_id in ('AA0090', 'AA0128','AA0089') and curdate() > sho.end_date then datediff(curdate(), sho.end_date)
        when t1.client_id in ('AA0149', 'AA0148') and curdate() > she.delievey_end_date then datediff(curdate(), she.delievey_end_date)
        else null
    end  超时天数
    ,if(t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139'), oi.insure_declare_value/100, oi.cogs_amount/100) cogs金额
    ,oi.cod_amount/100 cod金额
from t t1
left join
    (
        select
            plt.pno
            ,plt.updated_at
            ,plt.duty_result
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 6
    ) a2 on a2.pno = t1.pno
left join
    (
        select
            plt.pno
            ,plt.created_at
            ,row_number() over (partition by plt.pno order by plt.created_at desc ) rk
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at > date_sub(curdate(), interval 100 day)
    ) a3 on a3.pno = t1.pno and a3.rk = 1
left join dwm.dwd_ex_ph_lazada_pno_period laz on laz.pno = t1.pno
left join dwm.dwd_ex_shopee_pno_period sho on sho.pno = t1.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tik on tik.pno = t1.pno
left join dwm.dwd_ex_ph_shein_sla_detail she on she.pno = t1.pno
left join ph_staging.delivery_attempt_info dai on dai.pno = if(t1.returned = 0, t1.pno, t1.customary_pno)
left join
    (
        select
            pr.routed_at
            ,pr.pno
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.store_id
        where
            pr.routed_at > date_sub(curdate(), interval 40 day)
            and  pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) ss on ss.pno = t1.pno and ss.rk = 1
left join ph_staging.order_info oi on oi.pno = t1.pno
left join ph_staging.sys_store ss2 on ss2.id = t1.ticket_pickup_store_id
left join ph_staging.sys_store ss3 on ss3.id = t1.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
        select
            a1.*
        from
            (
                select
                    a.*
                from
                    (
                        select
                            pi.pno
                            ,pi.returned
                            ,pi.client_id
                            ,pi.state
                            ,pi.ticket_pickup_store_id
                            ,pi.dst_store_id
                            ,pi.customary_pno
                            ,pr.store_name
                            ,pr.store_id
                            ,pi.interrupt_category
                            ,pr.route_action
                            ,pr.routed_at
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                        from ph_staging.parcel_info pi
                        left join ph_staging.parcel_route pr on pr.pno = pi.pno
                        where
                            pi.state not in (5,7,8,9)
                            and pi.created_at < date_sub(now(), interval 56 hour)
                            and pi.created_at > date_sub(curdate(), interval 100 day)
                            and pr.routed_at > date_sub(curdate(), interval 40 day)
                            and pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
                    ) a
                where
                    a.rk = 1
            ) a1
        where
            a1.routed_at < date_sub(now(), interval 56 hour)
)
select
    t1.pno
    ,if(t1.returned = 0, '正向', '退件') 包裹流向
    ,t1.client_id
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,ss2.name 揽收网点
    ,case
        when ss2.province_code in ('PH01','PH02','PH03','PH04','PH05','PH06','PH07','PH08','PH09','PH10','PH11','PH12','PH13','PH14','PH15','PH16','PH17','PH18','PH19','PH20','PH21','PH22','PH23','PH24','PH25','PH26','PH27','PH61','PH62','PH63','PH64','PH65','PH66','PH67','PH78','PH79','PH80','PH82') then 'Luzon'
        when ss2.province_code in ('PH44','PH45','PH46','PH47','PH48','PH49','PH50','PH51','PH52','PH53','PH54','PH55','PH56','PH57','PH58','PH59','PH60','PH68','PH69','PH70','PH71','PH72','PH73','PH74','PH75','PH76','PH77','PH83') then 'Mindanao'
        when ss2.province_code in ('PH81') then 'Palawan'
        when ss2.province_code in ('PH28','PH29','PH30','PH31','PH32','PH33','PH34','PH35','PH36','PH37','PH38','PH39','PH40','PH41','PH42','PH43') then 'Visayas'
    end 揽收岛屿
    ,ss3.name 目的地网点
    ,case
        when ss3.province_code in ('PH01','PH02','PH03','PH04','PH05','PH06','PH07','PH08','PH09','PH10','PH11','PH12','PH13','PH14','PH15','PH16','PH17','PH18','PH19','PH20','PH21','PH22','PH23','PH24','PH25','PH26','PH27','PH61','PH62','PH63','PH64','PH65','PH66','PH67','PH78','PH79','PH80','PH82') then 'Luzon'
        when ss3.province_code in ('PH44','PH45','PH46','PH47','PH48','PH49','PH50','PH51','PH52','PH53','PH54','PH55','PH56','PH57','PH58','PH59','PH60','PH68','PH69','PH70','PH71','PH72','PH73','PH74','PH75','PH76','PH77','PH83') then 'Mindanao'
        when ss3.province_code in ('PH81') then 'Palawan'
        when ss3.province_code in ('PH28','PH29','PH30','PH31','PH32','PH33','PH34','PH35','PH36','PH37','PH38','PH39','PH40','PH41','PH42','PH43') then 'Visayas'
    end 目的地岛屿
    ,case a2.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 判责类型
    ,a2.updated_at 判责日期
    ,a3.created_at 最近进入闪速系统时间
#     ,t1.route_action
    ,case t1.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一次有效路由操作
    ,t1.store_name 最后一次有效路由网点
    ,convert_tz(ss.routed_at, '+00:00', '+08:00') 到达网点时间
    ,date(convert_tz(t1.routed_at, '+00:00', '+08:00')) 最后一次有效路由时间
    ,timestampdiff(hour, convert_tz(t1.routed_at, '+00:00', '+08:00'), now()) 最近一次有效路由至今小时数
    ,if(t1.returned = 0, dai.delivery_attempt_num, dai.returned_delivery_attempt_num) 尝试派送次数
    ,if(t1.interrupt_category = 3, '是', '否') 是否有待退件标记
    ,case
        when t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139') and curdate() > laz.delievey_end_date then '是'
        when t1.client_id in ('AA0131', 'AA0132') and curdate() > tik.end_date then '是'
        when t1.client_id in ('AA0090', 'AA0128','AA0089') and curdate() > sho.end_date then '是'
        when t1.client_id in ('AA0149', 'AA0148') and curdate() > she.delievey_end_date then '是'
        else null
    end 是否已经超时
    ,case
        when t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139') and curdate() > laz.delievey_end_date then datediff(curdate(), laz.delievey_end_date)
        when t1.client_id in ('AA0131', 'AA0132') and curdate() > tik.end_date then datediff(curdate(), tik.end_date)
        when t1.client_id in ('AA0090', 'AA0128','AA0089') and curdate() > sho.end_date then datediff(curdate(), sho.end_date)
        when t1.client_id in ('AA0149', 'AA0148') and curdate() > she.delievey_end_date then datediff(curdate(), she.delievey_end_date)
        else null
    end  超时天数
    ,if(t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139'), oi.insure_declare_value/100, oi.cogs_amount/100) cogs金额
    ,oi.cod_amount/100 cod金额
from t t1
left join
    (
        select
            plt.pno
            ,plt.updated_at
            ,plt.duty_result
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 6
    ) a2 on a2.pno = t1.pno
left join
    (
        select
            plt.pno
            ,plt.created_at
            ,row_number() over (partition by plt.pno order by plt.created_at desc ) rk
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at > date_sub(curdate(), interval 100 day)
    ) a3 on a3.pno = t1.pno and a3.rk = 1
left join dwm.dwd_ex_ph_lazada_pno_period laz on laz.pno = t1.pno
left join dwm.dwd_ex_shopee_pno_period sho on sho.pno = t1.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tik on tik.pno = t1.pno
left join dwm.dwd_ex_ph_shein_sla_detail she on she.pno = t1.pno
left join ph_staging.delivery_attempt_info dai on dai.pno = if(t1.returned = 0, t1.pno, t1.customary_pno)
left join
    (
        select
            pssn.first_valid_routed_at routed_at
            ,pssn.pno
            ,row_number() over (partition by pssn.pno order by pssn.created_at desc ) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno and t1.store_id = pssn.store_id
        where
            pssn.created_at > date_sub(curdate(), interval 40 day)
    ) ss on ss.pno = t1.pno and ss.rk = 1
left join ph_staging.order_info oi on oi.pno = t1.pno
left join ph_staging.sys_store ss2 on ss2.id = t1.ticket_pickup_store_id
left join ph_staging.sys_store ss3 on ss3.id = t1.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.staff_info_id
            ,pr.store_id
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id and hsi.state = 1 and hsi.formal = 1 and hsi.job_title = 37
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1,2,3
    )
select
    t1.staff_info_id 员工ID
    ,t1.pr_date 日期
    ,t1.pno_count 交接量
    ,fn.pno_count  妥投量
    ,if(hsa.staff_info_id is not null, '是', '否' ) 当日是否出差
from t t1
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t1.staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= t1.pr_date and hsa.employment_end_date >= t1.pr_date
left join
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.staff_info_id
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        join t t1 on t1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= '2023-11-01'
            and pr.routed_at >= date_sub(t1.pr_date, interval 8 hour)
            and pr.routed_at < date_add(t1.pr_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1,2
    ) fn on fn.staff_info_id = t1.staff_info_id and fn.pr_date = t1.pr_date;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.staff_info_id
            ,pr.store_id
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id and hsi.state = 1 and hsi.formal = 1 and hsi.job_title = 37
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at >= '2023-12-04 16:00:00'
            and pr.routed_at < '2023-12-17 16:00:00'
        group by 1,2,3
    )
select
    t1.staff_info_id 员工ID
    ,t1.pr_date 日期
    ,t1.pno_count 交接量
    ,fn.pno_count  妥投量
    ,if(hsa.staff_info_id is not null, '是', '否' ) 当日是否出差
from t t1
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t1.staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= t1.pr_date and hsa.employment_end_date >= t1.pr_date
left join
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.staff_info_id
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        join t t1 on t1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= '2023-11-01'
            and pr.routed_at >= date_sub(t1.pr_date, interval 8 hour)
            and pr.routed_at < date_add(t1.pr_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1,2
    ) fn on fn.staff_info_id = t1.staff_info_id and fn.pr_date = t1.pr_date;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.staff_info_id
            ,hsi.sys_store_id
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id and hsi.state = 1 and hsi.formal = 1 and hsi.job_title = 37
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at >= '2023-12-04 16:00:00'
            and pr.routed_at < '2023-12-17 16:00:00'
        group by 1,2,3
    )
select
    t1.staff_info_id 员工ID
    ,t1.pr_date 日期
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,t1.pno_count 交接量
    ,fn.pno_count  妥投量
    ,if(hsa.staff_info_id is not null, '是', '否' ) 当日是否出差
from t t1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = t1.staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= t1.pr_date and hsa.employment_end_date >= t1.pr_date
left join
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.staff_info_id
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        join t t1 on t1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= '2023-11-01'
            and pr.routed_at >= date_sub(t1.pr_date, interval 8 hour)
            and pr.routed_at < date_add(t1.pr_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1,2
    ) fn on fn.staff_info_id = t1.staff_info_id and fn.pr_date = t1.pr_date;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,pi.returned_pno 退件单号
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_1218 t on t.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    di.state = 0
    and vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2);
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    di.state = 0
    and vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2)
    and di.diff_marker_category = 17;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    di.state = 0
    and vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2)
    and di.diff_marker_category = 17
    and pi.state = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    di.state = 0
    and vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2)
    and di.diff_marker_category = 17
    and pi.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2)
    and di.diff_marker_category = 17
    and pi.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2)
    and di.diff_marker_category = 17
    and di.state = 0
#     and pi.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2)
    and di.diff_marker_category = 17
#     and di.state = 0
    and pi.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2)
    and di.diff_marker_category = 17
#     and di.state = 0
#     and pi.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct vrv.link_id) pcount
from nl_production.violation_return_visit vrv
where
    vrv.visit_state not in (1,2)
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.type = 3;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2)
    and di.diff_marker_category = 17
#     and di.state = 0
    and pi.state  not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2)
    and di.diff_marker_category = 17
    and di.state = 0
    and pi.state  not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,pi.dst_phone
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_v2 t on pi.pno = t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    case t.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,t.client_name 客户名称
    ,his.回访任务量 历史积压量
    ,his.历史积压处理完成量
    ,his.历史积压未完成量
    ,upp.ticket_count '昨日17-今日9点创建量'
    ,upp.done_ticket_count '昨日17-今日9点处理完成量'
    ,upp.deal_rate '昨日17-今日9点完成率'
    ,low.ticket_count '今日9点-今日17点生成量'
    ,low.done_ticket_count '今日9点-今日17点处理完成量'
    ,low.deal_rate '今日9点-今日17点处理完成率'
    ,tod.未开始拨打数量
    ,tod.拨打一次数量
    ,tod.拨打两次数量
    ,tod.拨打完成数量
    ,total.ticket_count  当日总任务量 -- 17-17
    ,total.day_deal_rate 当日处理完成率  -- 17-17
    ,total.undeal_diff_count 处理完包裹中关联的疑难件未解锁的量 -- 17-17
    ,total.parcel_diff_count 回访任务中包裹处于疑难件处理中状态的量 -- 17-17
    ,total.diff_vrv_finish_count 拒收回访任务处理完毕包裹仍是疑难件状态量 -- 17-17
    ,result.delivery_again_count 继续派送量
    ,result.rts_count 退件量
    ,result.close_count 异常关闭量
from tmpale.tmp_ph_client_visit_info t
left join
    (
        select
#             case vrv.type
#                 when 1 then '揽件任务异常取消'
#                 when 2 then '虚假妥投'
#                 when 3 then '收件人拒收'
#                 when 4 then '标记客户改约时间'
#                 when 5 then 'KA现场不揽收'
#                 when 6 then '包裹未准备好'
#                 when 7 then '上报错分未妥投'
#                 when 8 then '多次尝试派送失败'
#             end vrv_type
            vrv.type
            ,bc.client_name
            ,count(vrv.id) 回访任务量
            ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at >= date_sub('2023-12-19', interval 7 hour), vrv.id, null)) 历史积压处理完成量 -- 查训当日处理完成量
            ,count(if(vrv.visit_state in (1,2), vrv.id, null )) 历史积压未完成量
        from nl_production.violation_return_visit vrv
        join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.created_at <= date_sub('2023-12-19', interval 7 hour) -- 昨天17点之前
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                (
                    (vrv.visit_state in (3,4,5,6,7) and vrv.updated_at > date_sub('2023-12-19', interval 7 hour)) -- 查询日期17点之后处理
                    or vrv.visit_state in (1,2) -- 至今也是未处理
                )
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ) ) -- IVR应处理
            and vrv.visit_state != 0
        group by 1,2
    ) his on his.client_name = t.client_name and his.type = t.type
left join
    (
        select
            vrv.type
            ,bc.client_name
            ,count(vrv.id) ticket_count
            ,count(if(vrv.visit_state in (3,4,5,6,7) , vrv.id, null)) done_ticket_count
            ,count(if(vrv.visit_state in (3,4,5,6,7) , vrv.id, null))/count(vrv.id) deal_rate
        from nl_production.violation_return_visit vrv
        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ) )
            and vrv.visit_state != 0
            and vrv.created_at >= date_sub('2023-12-19', interval 7 hour)
            and vrv.created_at < date_add('2023-12-19', interval 9 hour) -- 昨日17至今日9点
        group by 1,2
    ) upp on upp.type = t.type and upp.client_name = t.client_name
left join
    (
        select
            vrv.type
            ,bc.client_name
            ,count(vrv.id) ticket_count
            ,count(if(vrv.visit_state in (3,4,5,6,7) , vrv.id, null)) done_ticket_count
            ,count(if(vrv.visit_state in (3,4,5,6,7) , vrv.id, null))/count(vrv.id) deal_rate
        from nl_production.violation_return_visit vrv
        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.visit_state != 0
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ) )
            and vrv.created_at >= date_add('2023-12-19', interval 9 hour)
            and vrv.created_at < date_add('2023-12-19', interval 17 hour) -- 昨日17至今日9点
        group by 1,2
    ) low on low.type = t.type and low.client_name = t.client_name
left join
    (
        select
            vrv.type
            ,bc.client_name
            ,count(vrv.id) ticket_count
            ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at < date_add('2023-12-19', interval 1 day), vrv.id, null))/count(vrv.id) day_deal_rate
            ,count(if(cdt.state != 1 and vrv.visit_state in (3,4,7) and cdt.id is not null, vrv.id, null)) undeal_diff_count
            ,count(if(pi.state = 6, vrv.id, null)) parcel_diff_count
            ,count(if(vrv.visit_state in (3,4,5,6,7) and di.diff_marker_category = 17 and di.state = 0 and pi.state = 6 and vrv.type = 3, vrv.id, null )) diff_vrv_finish_count
        from nl_production.violation_return_visit vrv
        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(vrv.extra_value, '$.diff_id')
        left join ph_staging.parcel_info pi on pi.pno = vrv.link_id
        left join ph_staging.diff_info di on di.pno = vrv.link_id
        where
            vrv.type in (3,8)
            and vrv.visit_state != 0
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ))
            and vrv.created_at >= date_sub('2023-12-19', interval 7 hour)
            and vrv.created_at < date_add('2023-12-19', interval 17 hour) -- 17-17
        group by 1,2
    ) total on total.type = t.type and total.client_name = t.client_name
left join
    (
        select
            a1.type
            ,a1.client_name
            ,count(if(a1.result = '退件', a1.id, null)) rts_count
            ,count(if(a1.result = '继续派送', a1.id, null)) delivery_again_count
            ,count(if(a1.result = '异常关闭', a1.id, null)) close_count
        from
            (
                select
                    a.type
                    ,a.client_name
                    ,case
                        when a.type = 3 and a.visit_state in (3,7) or a.rejection_delivery_again = 1 then '退件' -- 多次联系不上、超时效和回访结果是退件
                        when a.type = 3 and a.rejection_delivery_again = 2 then '继续派送' -- 继续派送
                        when a.type = 8 and a.visit_state in (3,7) or a.visit_result = 44 then '退件' --  多次联系不上和回访结果是退件
                        when a.type = 8 and  a.visit_result = 43 then '继续派送'
                        else '异常关闭'
                    end result
                    ,a.id
                from
                    (
                        select
                            vrv.type
                            ,bc.client_name
                            ,vrv.visit_state
                            ,vrv.visit_result
                            ,vrv.id
                            ,json_extract(vrv.extra_value, '$.rejection_delivery_again') rejection_delivery_again
                        from nl_production.violation_return_visit vrv
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
                        where
                            vrv.type in (3,8)
                            and vrv.visit_state != 0
                            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
                            and
                                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ))
                            and vrv.created_at >= date_sub('2023-12-19', interval 7 hour)
                            and vrv.created_at < date_add('2023-12-19', interval 17 hour)
                    ) a
            ) a1
        group by 1,2
    ) result on result.type = t.type and result.client_name = t.client_name
left join
    (
        select
            vrv.type
            ,bc.client_name
            ,count(if(vrv.visit_num = 0 ,vrv.id, null)) 未开始拨打数量
            ,count(if(vrv.visit_num = 1, vrv.id, null)) 拨打一次数量
            ,count(if(vrv.visit_num = 2, vrv.id, null)) 拨打两次数量
            ,count(if(vrv.visit_state in (3,4,5,6,7), vrv.id, null)) 拨打完成数量
        from nl_production.violation_return_visit vrv
        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.visit_state != 0
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ))
            and vrv.created_at >= date_add('2023-12-19', interval 17 hour)
            and vrv.created_at < date_add('2023-12-19', interval 20 hour) -- 当日17-20
        group by 1,2
    ) tod on tod.type = t.type and tod.client_name = t.client_name;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state not in (1,2)
    and di.diff_marker_category = 17
    and di.state = 0
    and pi.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
    vrv.link_id is  not null
    and json_extract(vrv.extra_value, '$.diff_id') is null
    and vrv.visit_state  in (3,4,7,8)
    and di.diff_marker_category = 17
    and di.state = 0
    and pi.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,if(vrv.link_id is null, '否', '是') 是否进回访
    ,if(vrv.visit_state in (3,4,7,8), '是', '否') 是否存在回访完成的任务
    ,if(json_extract(vrv.extra_value, '$.diff_id') is null, '否', '是') 是否存在未关联上疑难件的任务
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
#     vrv.link_id is  not null
#     and json_extract(vrv.extra_value, '$.diff_id') is null
#     and vrv.visit_state  in (3,4,7,8)
    di.diff_marker_category = 17
    and di.state = 0
    and pi.state = 6
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,if(vrv.link_id is null, '否', '是') 是否进回访
    ,if(vrv.visit_state in (3,4,7,8), '是', '否') 是否存在回访完成的任务
    ,if(json_extract(vrv.extra_value, '$.diff_id') is null, '是', '否') 是否存在未关联上疑难件的任务
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
#     vrv.link_id is  not null
#     and json_extract(vrv.extra_value, '$.diff_id') is null
#     and vrv.visit_state  in (3,4,7,8)
    di.diff_marker_category = 17
    and di.state = 0
    and pi.state = 6
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,pi.dst_phone 收件人电话
    ,if(vrv.link_id is null, '否', '是') 是否进回访
    ,if(vrv.visit_state in (3,4,7,8), '是', '否') 是否存在回访完成的任务
    ,if(json_extract(vrv.extra_value, '$.diff_id') is null, '是', '否') 是否存在未关联上疑难件的任务
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
#     vrv.link_id is  not null
#     and json_extract(vrv.extra_value, '$.diff_id') is null
#     and vrv.visit_state  in (3,4,7,8)
    di.diff_marker_category = 17
    and di.state = 0
    and pi.state = 6
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,convert_tz(di.created_at, '+00:00', '+08:00') 提交疑难件时间
    ,pi.dst_phone 收件人电话
    ,if(vrv.link_id is null, '否', '是') 是否进回访
    ,if(vrv.visit_state in (3,4,7,8), '是', '否') 是否存在回访完成的任务
    ,if(json_extract(vrv.extra_value, '$.diff_id') is null, '是', '否') 是否存在未关联上疑难件的任务
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
#     vrv.link_id is  not null
#     and json_extract(vrv.extra_value, '$.diff_id') is null
#     and vrv.visit_state  in (3,4,7,8)
    di.diff_marker_category = 17
    and di.state = 0
    and pi.state = 6
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,convert_tz(di.created_at, '+00:00', '+08:00') 提交疑难件时间
    ,pi.dst_phone 收件人电话
    ,if(vrv.link_id is null, '否', '是') 是否进回访
    ,if(vrv.visit_state in (3,4,7,8), '是', '否') 是否存在回访完成的任务
    ,if(json_extract(vrv.extra_value, '$.diff_id') is null, '是', '否') 是否存在未关联上疑难件的任务
    ,case vrv.visit_result
        when 1 then '联系不上'
        when 2 then '取消原因属实、合理'
        when 3 then '快递员虚假标记/违背客户意愿要求取消'
        when 4 then '多次联系不上客户'
        when 5 then '收件人已签收包裹'
        when 6 then '收件人未收到包裹'
        when 7 then '未经收件人允许投放他处/让他人代收'
        when 8 then '快递员没有联系客户，直接标记收件人拒收'
        when 9 then '收件人拒收情况属实'
        when 10 then '快递员服务态度差'
        when 11 then '因快递员未按照收件人地址送货，客户不方便去取货'
        when 12 then '网点派送速度慢，客户不想等'
        when 13 then '非快递员问题，个人原因拒收'
        when 14 then '其它'
        when 15 then '未经客户同意改约派件时间'
        when 16 then '未按约定时间派送'
        when 17 then '派件前未提前联系客户'
        when 18 then '收件人拒收情况不属实'
        when 19 then '快递员联系客户，但未经客户同意标记收件人拒收'
        when 20 then '快递员要求/威胁客户拒收'
        when 21 then '快递员引导客户拒收'
        when 22 then '其他'
        when 23 then '情况不属实，快递员虚假标记'
        when 24 then '情况不属实，快递员诱导客户改约时间'
        when 25 then '情况属实，客户原因改约时间'
        when 26 then '客户退货，不想购买该商品'
        when 27 then '客户未购买商品'
        when 28 then '客户本人/家人对包裹不知情而拒收'
        when 29 then '商家发错商品'
        when 30 then '包裹物流派送慢超时效'
        when 31 then '快递员服务态度差'
        when 32 then '因快递员未按照收件人地址送货，客户不方便去取货'
        when 33 then '货物验收破损'
        when 34 then '无人在家不便签收'
        when 35 then '客户错误拒收包裹'
        when 36 then '快递员按照要求当场扫描揽收'
        when 37 then '快递员未按照要求当场扫描揽收'
        when 38 then '无所谓，客户无要求'
        when 39 then '包裹未准备好 - 情况不属实，快递员虚假标记'
        when 40 then '包裹未准备好 - 情况属实，客户存在未准备好的包裹'
        when 41 then '虚假修改包裹信息'
        when 42 then '修改包裹信息属实'
        when 43 then '客户需要包裹，继续派送'
        when 44 then '客户不需要包裹，操作退件'
    end as 回访结果
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
where
#     vrv.link_id is  not null
#     and json_extract(vrv.extra_value, '$.diff_id') is null
#     and vrv.visit_state  in (3,4,7,8)
    di.diff_marker_category = 17
    and di.state = 0
    and pi.state = 6
group by 1,2,3,4,5,6;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,convert_tz(di.created_at, '+00:00', '+08:00') 提交疑难件时间
    ,pi.dst_phone 收件人电话
    ,if(vrv.link_id is null, '否', '是') 是否进回访
    ,if(vrv.visit_state in (3,4,7,8), '是', '否') 是否存在回访完成的任务
    ,if(json_extract(vrv.extra_value, '$.diff_id') is null  , '是', '否') 是否存在未关联上疑难件的任务
    ,case vrv.visit_result
        when 1 then '联系不上'
        when 2 then '取消原因属实、合理'
        when 3 then '快递员虚假标记/违背客户意愿要求取消'
        when 4 then '多次联系不上客户'
        when 5 then '收件人已签收包裹'
        when 6 then '收件人未收到包裹'
        when 7 then '未经收件人允许投放他处/让他人代收'
        when 8 then '快递员没有联系客户，直接标记收件人拒收'
        when 9 then '收件人拒收情况属实'
        when 10 then '快递员服务态度差'
        when 11 then '因快递员未按照收件人地址送货，客户不方便去取货'
        when 12 then '网点派送速度慢，客户不想等'
        when 13 then '非快递员问题，个人原因拒收'
        when 14 then '其它'
        when 15 then '未经客户同意改约派件时间'
        when 16 then '未按约定时间派送'
        when 17 then '派件前未提前联系客户'
        when 18 then '收件人拒收情况不属实'
        when 19 then '快递员联系客户，但未经客户同意标记收件人拒收'
        when 20 then '快递员要求/威胁客户拒收'
        when 21 then '快递员引导客户拒收'
        when 22 then '其他'
        when 23 then '情况不属实，快递员虚假标记'
        when 24 then '情况不属实，快递员诱导客户改约时间'
        when 25 then '情况属实，客户原因改约时间'
        when 26 then '客户退货，不想购买该商品'
        when 27 then '客户未购买商品'
        when 28 then '客户本人/家人对包裹不知情而拒收'
        when 29 then '商家发错商品'
        when 30 then '包裹物流派送慢超时效'
        when 31 then '快递员服务态度差'
        when 32 then '因快递员未按照收件人地址送货，客户不方便去取货'
        when 33 then '货物验收破损'
        when 34 then '无人在家不便签收'
        when 35 then '客户错误拒收包裹'
        when 36 then '快递员按照要求当场扫描揽收'
        when 37 then '快递员未按照要求当场扫描揽收'
        when 38 then '无所谓，客户无要求'
        when 39 then '包裹未准备好 - 情况不属实，快递员虚假标记'
        when 40 then '包裹未准备好 - 情况属实，客户存在未准备好的包裹'
        when 41 then '虚假修改包裹信息'
        when 42 then '修改包裹信息属实'
        when 43 then '客户需要包裹，继续派送'
        when 44 then '客户不需要包裹，操作退件'
    end as 回访结果
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
left join nl_production.violation_return_visit vrv2 on vrv2.link_id = di.pno and vrv2.type = 3 and vrv2.visit_state in (1,2)
where
#     vrv.link_id is  not null
#     and json_extract(vrv.extra_value, '$.diff_id') is null
#     and vrv.visit_state  in (3,4,7,8)
    di.diff_marker_category = 17
    and di.state = 0
    and pi.state = 6
    and vrv2.link_id is null
group by 1,2,3,4,5,6;
;-- -. . -..- - / . -. - .-. -.--
select
    substr(vrv.created_at,1,7) 月份
    ,if( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ), 'automatic', 'manual')  回访方式
    ,count(distinct vrv.link_id) pno_count
    ,count(vrv.id) visit_num
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
where
    vrv.created_at > '2023-09-01'
    and vrv.type in (3,8)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    substr(vrv.created_at,1,7) 月份
    ,bc.client_name
    ,if( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ), 'automatic', 'manual')  回访方式
    ,count(distinct vrv.link_id) 包裹量
    ,count(vrv.id) 回访任务量
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
where
    vrv.created_at > '2023-09-01'
    and vrv.type in (3,8)
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.link_id
from
    (
        select
            vrv.link_id
            ,vrv.created_at
            ,date(vrv.created_at) vrv_date
        from nl_production.violation_return_visit vrv
        where
            vrv.type = 3
            and vrv.visit_state in (3,4)
            and vrv.data_source != 16
    ) a1
join
    (
        select
            vrv.link_id
            ,vrv.created_at
            ,date(vrv.created_at) vrv_date
        from nl_production.violation_return_visit vrv
        where
            vrv.type = 3
            and vrv.data_source = 16
    ) a2 on a1.vrv_date = a2.vrv_date and a1.link_id = a2.link_id
where
    a1.created_at < a2.created_at
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.link_id
from
    (
        select
            vrv.link_id
            ,vrv.created_at
            ,date(vrv.created_at) vrv_date
        from nl_production.violation_return_visit vrv
        where
            vrv.type = 3
            and vrv.visit_state in (3,4)
            and vrv.data_source != 16
    ) a1
join
    (
        select
            vrv.link_id
            ,vrv.created_at
            ,date(vrv.created_at) vrv_date
        from nl_production.violation_return_visit vrv
        where
            vrv.type = 3
            and vrv.data_source = 16
    ) a2 on a1.vrv_date = a2.vrv_date and a1.link_id = a2.link_id
join ph_staging.diff_info di on di.pno = a1.link_id and di.diff_marker_category = 17
where
    a1.created_at < a2.created_at
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.link_id
from
    (
        select
            vrv.link_id
            ,vrv.created_at
            ,date(vrv.created_at) vrv_date
        from nl_production.violation_return_visit vrv
        where
            vrv.type = 3
            and vrv.visit_state in (3,4)
            and vrv.data_source != 16
    ) a1
join
    (
        select
            vrv.link_id
            ,vrv.created_at
            ,date(vrv.created_at) vrv_date
        from nl_production.violation_return_visit vrv
        where
            vrv.type = 3
            and vrv.data_source = 16
    ) a2 on a1.vrv_date = a2.vrv_date and a1.link_id = a2.link_id
join ph_staging.diff_info di on di.pno = a1.link_id and di.diff_marker_category = 17 and di.state = 0
where
    a1.created_at < a2.created_at
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    substr(pi.created_at,1,7) 月份
    ,bc.client_name 客户名称
    ,count(pi.pno) 包裹量
from ph_staging.parcel_info pi
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.created_at > '2023-08-31 16:00:00'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    substr(pi.created_at,1,7) 月份
    ,bc.client_name 客户名称
    ,count(pi.pno) 包裹量
from ph_staging.parcel_info pi
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.created_at > '2023-08-31 16:00:00'
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    substr(convert_tz(pi.created_at, '+00:00', '+08:00'),1,7) 月份
    ,bc.client_name 客户名称
    ,count(pi.pno) 包裹量
from ph_staging.parcel_info pi
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.created_at > '2023-08-31 16:00:00'
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    substr(convert_tz(pi.created_at, '+00:00', '+08:00'),1,7) 月份
    ,bc.client_name 客户名称
    ,count(pi.pno) 包裹量
from ph_staging.parcel_info pi
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.created_at > '2023-08-31 16:00:00'
    and pi.state < 9
    and pi.returned = 0
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 < 24 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-24'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 < 36 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-36'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 < 48 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-48'
    ,count(if(timestampdiff(second, am.created_at, acc.store_callback_at)/3600 < 24 and acc.store_callback_expired = 0, acc.id, null)) '任务发放时间-道歉时间-24'
    ,count(if(timestampdiff(second, am.created_at, acc.store_callback_at)/3600 < 36 and acc.store_callback_expired = 0, acc.id, null)) '任务发放时间-道歉时间-36'
    ,count(if(timestampdiff(second, am.created_at, acc.store_callback_at)/3600 < 48 and acc.store_callback_expired = 0, acc.id, null)) '任务发放时间-道歉时间-48'
    ,count(distinct acc.id) 投诉量
    ,count(if(acc.store_callback_expired = 0 and acc.store_callback_at is not null, acc.id, null)) 有道歉量
    ,count(if(acc.store_callback_expired != 0 or  acc.store_callback_at is null, acc.id, null)) 无道歉量
from ph_bi.abnormal_customer_complaint acc
left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
where
    acc.complaints_type = 1
    and acc.created_at >= '2023-09-01'
    and acc.created_at < '2023-10-01';
;-- -. . -..- - / . -. - .-. -.--
select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 网点
    ,a1.pr_date 日期
    ,a1.staff_info_id 员工ID
    ,a1.pno_count 交接包裹数
    ,a2.pno_count 妥投包裹数
from
    (
        select
            a.pr_date
            ,a.staff_info_id
            ,count(distinct a.pno) pno_count
        from
            (
                select
                    pr.pno
                    ,pr.staff_info_id
                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+08:00')) order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                where
                    pr.routed_at > '2023-12-06 16:00:00'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a
        where
            a.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
            and a.rk = 1
    ) a1
left join
    (
        select
            pr.staff_info_id
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-12-06 16:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1,2
    ) a2 on a2.staff_info_id = a1.staff_info_id and a2.pr_date = a1.pr_date
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id - hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 网点
    ,a1.pr_date 日期
    ,a1.staff_info_id 员工ID
    ,a1.pno_count 交接包裹数
    ,a2.pno_count 妥投包裹数
from
    (
        select
            a.pr_date
            ,a.staff_info_id
            ,count(distinct a.pno) pno_count
        from
            (
                select
                    pr.pno
                    ,pr.staff_info_id
                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+08:00')) order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                where
                    pr.routed_at > '2023-12-06 16:00:00'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a
        where
            a.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
            and a.rk = 1
        group by 1,2
    ) a1
left join
    (
        select
            pr.staff_info_id
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-12-06 16:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1,2
    ) a2 on a2.staff_info_id = a1.staff_info_id and a2.pr_date = a1.pr_date
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id - hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 网点
    ,a1.pr_date 日期
    ,a1.staff_info_id 员工ID
    ,a1.pno_count 交接包裹数
    ,a2.pno_count 妥投包裹数
from
    (
        select
            a.pr_date
            ,a.staff_info_id
            ,count(distinct a.pno) pno_count
        from
            (
                select
                    pr.pno
                    ,pr.staff_info_id
                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+08:00')) order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                where
                    pr.routed_at > '2023-12-06 16:00:00'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a
        where
            a.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
            and a.rk = 1
        group by 1,2
    ) a1
left join
    (
        select
            pr.staff_info_id
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-12-06 16:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1,2
    ) a2 on a2.staff_info_id = a1.staff_info_id and a2.pr_date = a1.pr_date
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 网点
    ,a1.pr_date 日期
    ,a1.staff_info_id 员工ID
    ,a1.pno_count 交接包裹数
    ,a2.pno_count 妥投包裹数
from
    (
        select
            a.pr_date
            ,a.staff_info_id
            ,count(distinct a.pno) pno_count
        from
            (
                select
                    pr.pno
                    ,pr.staff_info_id
                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+08:00')) order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                where
                    pr.routed_at > '2023-12-06 16:00:00'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a
        where
            a.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
            and a.rk = 1
        group by 1,2
    ) a1
left join
    (
        select
            pr.staff_info_id
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-12-06 16:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
            and pr.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
        group by 1,2
    ) a2 on a2.staff_info_id = a1.staff_info_id and a2.pr_date = a1.pr_date
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
select date_sub(curdate(), interval 1 day),date_sub(`current_date`, interval 7 day);
;-- -. . -..- - / . -. - .-. -.--
select date_sub(curdate(), interval 1 day),date_sub(curdate(), interval 7 day);
;-- -. . -..- - / . -. - .-. -.--
select
    t.dst_province_code 目的省code
    ,t.dst_city_code 目的市code
    ,t.dst_district_code 目的乡code
    ,t.region_name 目的地网点所属大区
    ,t.piece_name 目的地网点所属片区
    ,t.store_name 目的地网点
    ,t.dst_store_id 目的地网点ID
    ,t3.pno_count '3kg-80cm'
    ,t4.pno_count '4kg-90cm'
    ,t5.pno_count '5kg-95cm'
    ,t6.pno_count '6kg-100cm'
    ,t7.pno_count '7kg-105cm'
    ,t8.pno_count '8kg-110cm'
    ,t9.pno_count '9kg-115cm'
    ,t10.pno_count '10kg-120cm'
from
    (
         select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
        group by 1,2,3,4,5,6,7
    ) t
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80)
                    or pi.exhibition_weight >= 3000
                )
        group by 1,2,3,4,5,6,7
    ) t3 on t3.dst_district_code = t.dst_district_code and t3.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 90)
                     or pi.exhibition_weight >= 4000
                )
        group by 1,2,3,4,5,6,7
    ) t4 on t4.dst_district_code = t.dst_district_code and t4.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 95)
                    or pi.exhibition_weight >= 5000
                )
        group by 1,2,3,4,5,6,7
    ) t5 on t5.dst_district_code = t.dst_district_code and t5.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 100)
                    or pi.exhibition_weight >= 6000
                )
        group by 1,2,3,4,5,6,7
    ) t6 on t6.dst_district_code = t.dst_district_code and t6.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 105)
                    or pi.exhibition_weight >= 7000
                )
        group by 1,2,3,4,5,6,7
    ) t7 on t7.dst_district_code = t.dst_district_code and t7.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 110)
                    or pi.exhibition_weight >= 8000
                )
        group by 1,2,3,4,5,6,7
    ) t8 on t8.dst_district_code = t.dst_district_code and t8.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 115)
                    or pi.exhibition_weight >= 9000
                )
        group by 1,2,3,4,5,6,7
    ) t9 on t9.dst_district_code = t.dst_district_code and t9.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 120)
                    or pi.exhibition_weight >= 10000
                )
        group by 1,2,3,4,5,6,7
    ) t10 on t10.dst_district_code = t.dst_district_code and t10.dst_store_id = t.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    t.src_province_code 揽收省code
    ,t.src_city_code 揽收市code
    ,t.src_district_code 揽收乡code
    ,t.region_name 揽收网点所属大区
    ,t.piece_name 揽收网点所属片区
    ,t.store_name 揽收网点
    ,t.ticket_pickup_store_id 揽收网点ID
    ,t3.pi_count '3kg-60cm'
    ,t4.pi_count '4kg-70cm'
    ,t5.pi_count '5kg-80cm'
    ,t6.pi_count '6kg-85cm'
    ,t7.pi_count '7kg-90cm'
    ,t8.pi_count '8kg-95cm'
    ,t9.pi_count '9kg-100cm'
    ,t10.pi_count '10kg-105cm'
from
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
        group by 1,2,3,4,5,6,7
    ) t
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 60)
                    or pi.exhibition_weight >= 3000
                )
        group by 1,2,3,4,5,6,7
    ) t3 on t3.ticket_pickup_store_id = t.ticket_pickup_store_id and t3.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 70)
                    or pi.exhibition_weight >= 4000
                )
        group by 1,2,3,4,5,6,7
    ) t4 on t4.ticket_pickup_store_id = t.ticket_pickup_store_id and t4.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80)
                    or pi.exhibition_weight >= 5000
                )
        group by 1,2,3,4,5,6,7
    ) t5 on t5.ticket_pickup_store_id = t.ticket_pickup_store_id and t5.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 85)
                    or pi.exhibition_weight >= 6000
                )
        group by 1,2,3,4,5,6,7
    ) t6 on t6.ticket_pickup_store_id = t.ticket_pickup_store_id and t6.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 90)
                    or pi.exhibition_weight >= 7000
                )
        group by 1,2,3,4,5,6,7
    ) t7 on t7.ticket_pickup_store_id = t.ticket_pickup_store_id and t7.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 95)
                    or pi.exhibition_weight >= 8000
                )
        group by 1,2,3,4,5,6,7
    ) t8 on t8.ticket_pickup_store_id = t.ticket_pickup_store_id and t8.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 100)
                    or pi.exhibition_weight >= 9000
                )
        group by 1,2,3,4,5,6,7
    ) t9 on t9.ticket_pickup_store_id = t.ticket_pickup_store_id and t9.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at <= date_sub(curdate(), interval 1 day)
            and pi.created_at >= date_sub(curdate(), interval 7 day)
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 105)
                    or pi.exhibition_weight >= 10000
                )
        group by 1,2,3,4,5,6,7
    ) t10 on t10.ticket_pickup_store_id = t.ticket_pickup_store_id and t10.src_district_code  = t.src_district_code;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
from ph_staging.parcel_route pr
join ph_bi.parcel_lose_task plt on plt.pno = pr.pno and plt.state = 6 and plt.duty_result = 1
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.staff_info_id in (177579,165744)
    and pr.routed_at > '2023-10-01 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
from ph_staging.parcel_route pr
# join ph_bi.parcel_lose_task plt on plt.pno = pr.pno and plt.state = 6 and plt.duty_result = 1
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.staff_info_id in (177579,165744)
    and pr.routed_at > '2023-10-01 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,convert_tz(di.created_at, '+00:00', '+08:00') 提交疑难件时间
    ,pi.dst_phone 收件人电话
    ,if(vrv.link_id is null, '否', '是') 是否进回访
    ,if(vrv.visit_state in (3,4,7,8), '是', '否') 是否存在回访完成的任务
    ,if(json_extract(vrv.extra_value, '$.diff_id') is null  , '是', '否') 是否存在未关联上疑难件的任务
    ,case vrv.visit_result
        when 1 then '联系不上'
        when 2 then '取消原因属实、合理'
        when 3 then '快递员虚假标记/违背客户意愿要求取消'
        when 4 then '多次联系不上客户'
        when 5 then '收件人已签收包裹'
        when 6 then '收件人未收到包裹'
        when 7 then '未经收件人允许投放他处/让他人代收'
        when 8 then '快递员没有联系客户，直接标记收件人拒收'
        when 9 then '收件人拒收情况属实'
        when 10 then '快递员服务态度差'
        when 11 then '因快递员未按照收件人地址送货，客户不方便去取货'
        when 12 then '网点派送速度慢，客户不想等'
        when 13 then '非快递员问题，个人原因拒收'
        when 14 then '其它'
        when 15 then '未经客户同意改约派件时间'
        when 16 then '未按约定时间派送'
        when 17 then '派件前未提前联系客户'
        when 18 then '收件人拒收情况不属实'
        when 19 then '快递员联系客户，但未经客户同意标记收件人拒收'
        when 20 then '快递员要求/威胁客户拒收'
        when 21 then '快递员引导客户拒收'
        when 22 then '其他'
        when 23 then '情况不属实，快递员虚假标记'
        when 24 then '情况不属实，快递员诱导客户改约时间'
        when 25 then '情况属实，客户原因改约时间'
        when 26 then '客户退货，不想购买该商品'
        when 27 then '客户未购买商品'
        when 28 then '客户本人/家人对包裹不知情而拒收'
        when 29 then '商家发错商品'
        when 30 then '包裹物流派送慢超时效'
        when 31 then '快递员服务态度差'
        when 32 then '因快递员未按照收件人地址送货，客户不方便去取货'
        when 33 then '货物验收破损'
        when 34 then '无人在家不便签收'
        when 35 then '客户错误拒收包裹'
        when 36 then '快递员按照要求当场扫描揽收'
        when 37 then '快递员未按照要求当场扫描揽收'
        when 38 then '无所谓，客户无要求'
        when 39 then '包裹未准备好 - 情况不属实，快递员虚假标记'
        when 40 then '包裹未准备好 - 情况属实，客户存在未准备好的包裹'
        when 41 then '虚假修改包裹信息'
        when 42 then '修改包裹信息属实'
        when 43 then '客户需要包裹，继续派送'
        when 44 then '客户不需要包裹，操作退件'
    end as 回访结果
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 3
left join nl_production.violation_return_visit vrv2 on json_extract(vrv2.extra_value, '$.diff_id')  = di.id and vrv2.type = 3 and vrv2.visit_state in (1,2)
where
#     vrv.link_id is  not null
#     and json_extract(vrv.extra_value, '$.diff_id') is null
#     and vrv.visit_state  in (3,4,7,8)
    di.diff_marker_category = 17
    and di.state = 0
    and pi.state = 6
    and vrv2.link_id is null
group by 1,2,3,4,5,6;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,tpor.ticket_pickup_id
from ph_staging.ticket_pickup_order_relation tpor
left join ph_staging.order_info oi on tpor.order_id = oi.id
join tmpale.tmp_ph_pno_lj_1228 t on t.pno = oi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,tpor.ticket_pickup_id
    ,tp.store_id
from ph_staging.ticket_pickup_order_relation tpor
left join ph_staging.order_info oi on tpor.order_id = oi.id
join tmpale.tmp_ph_pno_lj_1228 t on t.pno = oi.pno
left join ph_staging.ticket_pickup tp on tp.id = tpor.ticket_pickup_id;
;-- -. . -..- - / . -. - .-. -.--
select
    concat('SSRD',plt.`id`) 任务ID
    ,plt.created_at 任务生成时间
    ,plt.pno 运单号
    ,case plt.`vip_enable`
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end as 客户类型
    ,case plt.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end as '判责类型'
    ,t.`t_value` 原因
    ,plt.`client_id` 客户ID
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 COGS
    ,plt.`parcel_created_at` 揽收时间
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
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
    ,if(pr1.pno is not null, '是', '否') 是否有发无到
    ,pr.`next_store_name`  下一站点
    ,case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 33 then 'C来源HUB波次举报（临时来源，发送工单后将恢复C来源)'
    end  '问题件来源渠道'
    ,group_concat(distinct wo.order_no) 工单编号
from  `ph_bi`.`parcel_lose_task` plt
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )
left join `ph_staging`.`parcel_route` pr on pr.`pno` = plt.`pno` and pr.`store_id` = plt.`last_valid_store_id`
left join `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
left join `ph_bi`.`translations` t on plt.duty_reasons = t.t_key and t.`lang` = 'zh-CN'
left join ph_staging.parcel_route pr1 on pr1.pno = plt.pno and pr1.route_action = 'HAVE_HAIR_SCAN_NO_TO' and pr1.routed_at > date_sub(curdate(), interval 3 month)
where
    plt.state = 5
    and plt.operator_id not in (10000,10001)
    and plt.updated_at >= date_sub(curdate(), interval 1 day)
    and plt.updated_at < curdate()
    and bc.client_id is null
    and plt.vip_enable = 1
    and plt.duty_reasons in ('parcel_lose_duty_no_res_reasons_1', 'parcel_lose_duty_no_res_reasons_2', 'parcel_lose_duty_no_res_reasons_6', 'parcel_lose_duty_no_res_reasons_7');
;-- -. . -..- - / . -. - .-. -.--
select
    concat('SSRD',plt.`id`) 任务ID
    ,plt.created_at 任务生成时间
    ,plt.pno 运单号
    ,case plt.`vip_enable`
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end as 客户类型
    ,case plt.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end as '判责类型'
    ,t.`t_value` 原因
    ,plt.`client_id` 客户ID
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 COGS
    ,plt.`parcel_created_at` 揽收时间
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
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
    ,if(pr1.pno is not null, '是', '否') 是否有发无到
    ,pr.`next_store_name`  下一站点
    ,case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 33 then 'C来源HUB波次举报（临时来源，发送工单后将恢复C来源)'
    end  '问题件来源渠道'
    ,group_concat(distinct wo.order_no) 工单编号
from  `ph_bi`.`parcel_lose_task` plt
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )
left join `ph_staging`.`parcel_route` pr on pr.`pno` = plt.`pno` and pr.`store_id` = plt.`last_valid_store_id` and pr.routed_at > date_sub(curdate(), interval 3 month)
left join `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
left join `ph_bi`.`translations` t on plt.duty_reasons = t.t_key and t.`lang` = 'zh-CN'
left join ph_staging.parcel_route pr1 on pr1.pno = plt.pno and pr1.route_action = 'HAVE_HAIR_SCAN_NO_TO' and pr1.routed_at > date_sub(curdate(), interval 3 month)
where
    plt.state = 5
    and plt.operator_id not in (10000,10001)
    and plt.updated_at >= date_sub(curdate(), interval 1 day)
    and plt.updated_at < curdate()
    and bc.client_id is null
    and plt.vip_enable = 1
    and plt.duty_reasons in ('parcel_lose_duty_no_res_reasons_1', 'parcel_lose_duty_no_res_reasons_2', 'parcel_lose_duty_no_res_reasons_6', 'parcel_lose_duty_no_res_reasons_7')
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    concat('SSRD',plt.`id`) 任务ID
    ,plt.created_at 任务生成时间
    ,plt.pno 运单号
    ,case plt.`vip_enable`
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end as 客户类型
    ,case plt.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end as '判责类型'
    ,t.`t_value` 原因
    ,plt.`client_id` 客户ID
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 COGS
    ,plt.`parcel_created_at` 揽收时间
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
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
    ,if(pr1.pno is not null, '是', '否') 是否有发无到
    ,pr.`next_store_name`  下一站点
    ,case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 33 then 'C来源HUB波次举报（临时来源，发送工单后将恢复C来源)'
    end  '问题件来源渠道'
    ,group_concat(distinct wo.order_no) 工单编号
from  `ph_bi`.`parcel_lose_task` plt
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )
left join `ph_staging`.`parcel_route` pr on pr.`pno` = plt.`pno` and pr.`store_id` = plt.`last_valid_store_id` and pr.routed_at > date_sub(curdate(), interval 3 month)
left join `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
left join `ph_bi`.`translations` t on plt.duty_reasons = t.t_key and t.`lang` = 'zh-CN'
left join ph_staging.parcel_route pr1 on pr1.pno = plt.pno and pr1.route_action = 'HAVE_HAIR_SCAN_NO_TO' and pr1.routed_at > date_sub(curdate(), interval 3 month)
where
    plt.state = 5
    and plt.operator_id not in (10000,10001)
    and plt.updated_at >= date_sub(curdate(), interval 7 day)
    and plt.updated_at < curdate()
    and bc.client_id is null
    and plt.vip_enable = 1
    and plt.duty_reasons in ('parcel_lose_duty_no_res_reasons_1', 'parcel_lose_duty_no_res_reasons_2', 'parcel_lose_duty_no_res_reasons_6', 'parcel_lose_duty_no_res_reasons_7')
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    concat('SSRD',plt.`id`) 任务ID
    ,plt.created_at 任务生成时间
    ,plt.pno 运单号
    ,case plt.`vip_enable`
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end as 客户类型
    ,case plt.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end as '判责类型'
    ,t.`t_value` 原因
    ,plt.`client_id` 客户ID
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 COGS
    ,plt.`parcel_created_at` 揽收时间
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
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
    ,if(pr1.pno is not null, '是', '否') 是否有发无到
    ,pr.`next_store_name`  下一站点
    ,case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 33 then 'C来源HUB波次举报（临时来源，发送工单后将恢复C来源)'
    end  '问题件来源渠道'
    ,group_concat(distinct wo.order_no) 工单编号
from  `ph_bi`.`parcel_lose_task` plt
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )
left join `ph_staging`.`parcel_route` pr on pr.`pno` = plt.`pno` and pr.`store_id` = plt.`last_valid_store_id` and pr.routed_at > date_sub(curdate(), interval 3 month)
left join `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
left join `ph_bi`.`translations` t on plt.duty_reasons = t.t_key and t.`lang` = 'zh-CN'
left join ph_staging.parcel_route pr1 on pr1.pno = plt.pno and pr1.route_action = 'HAVE_HAIR_SCAN_NO_TO' and pr1.routed_at > date_sub(curdate(), interval 3 month)
where
    plt.state = 5
    and plt.operator_id not in (10000,10001)
    and plt.updated_at >= date_sub(curdate(), interval 7 day)
    and plt.updated_at < curdate()
    and bc.client_id is null
    and plt.vip_enable = 0
    and plt.duty_reasons in ('parcel_lose_duty_no_res_reasons_1', 'parcel_lose_duty_no_res_reasons_2', 'parcel_lose_duty_no_res_reasons_6', 'parcel_lose_duty_no_res_reasons_7')
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    concat('SSRD',plt.`id`) 任务ID
    ,plt.created_at 任务生成时间
    ,plt.pno 运单号
    ,case plt.`vip_enable`
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end as 客户类型
    ,case plt.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end as '判责类型'
    ,t.`t_value` 原因
    ,plt.`client_id` 客户ID
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 COGS
    ,plt.`parcel_created_at` 揽收时间
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
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
    ,if(pr1.pno is not null, '是', '否') 是否有发无到
    ,pr.`next_store_name`  下一站点
    ,case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 33 then 'C来源HUB波次举报（临时来源，发送工单后将恢复C来源)'
    end  '问题件来源渠道'
    ,plt.source_id
    ,group_concat(distinct wo.order_no) 工单编号
from  `ph_bi`.`parcel_lose_task` plt
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )
left join `ph_staging`.`parcel_route` pr on pr.`pno` = plt.`pno` and pr.`store_id` = plt.`last_valid_store_id` and pr.routed_at > date_sub(curdate(), interval 3 month)
left join `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
left join `ph_bi`.`translations` t on plt.duty_reasons = t.t_key and t.`lang` = 'zh-CN'
left join ph_staging.parcel_route pr1 on pr1.pno = plt.pno and pr1.route_action = 'HAVE_HAIR_SCAN_NO_TO' and pr1.routed_at > date_sub(curdate(), interval 3 month)
where
    plt.state = 5
    and plt.operator_id not in (10000,10001)
    and plt.updated_at >= date_sub(curdate(), interval 7 day)
    and plt.updated_at < curdate()
    and bc.client_id is null
    and plt.vip_enable = 0
    and plt.duty_reasons in ('parcel_lose_duty_no_res_reasons_1', 'parcel_lose_duty_no_res_reasons_2', 'parcel_lose_duty_no_res_reasons_6', 'parcel_lose_duty_no_res_reasons_7')
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    concat('SSRD',plt.`id`) 任务ID
    ,plt.created_at 任务生成时间
    ,plt.pno 运单号
    ,case plt.`vip_enable`
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end as 客户类型
    ,case plt.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end as '判责类型'
    ,t.`t_value` 原因
    ,plt.`client_id` 客户ID
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 COGS
    ,plt.`parcel_created_at` 揽收时间
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
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
    ,if(pr1.pno is not null, '是', '否') 是否有发无到
    ,pr.`next_store_name`  下一站点
    ,case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 33 then 'C来源HUB波次举报（临时来源，发送工单后将恢复C来源)'
    end  '问题件来源渠道'
    ,group_concat(distinct wo.order_no) 工单编号
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key)) 包裹外包装且展示面单的照片
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key)) 包裹外包装的照片
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa3.object_key)) 包裹外包装破损的照片
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa4.object_key)) 包裹内填充物的照片
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa5.object_key)) 包裹目前重量的照片
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa6.object_key)) 应收到的产品的照片
from  `ph_bi`.`parcel_lose_task` plt
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )
left join `ph_staging`.`parcel_route` pr on pr.`pno` = plt.`pno` and pr.`store_id` = plt.`last_valid_store_id` and pr.routed_at > date_sub(curdate(), interval 3 month)
left join `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
left join `ph_bi`.`translations` t on plt.duty_reasons = t.t_key and t.`lang` = 'zh-CN'
left join ph_staging.parcel_route pr1 on pr1.pno = plt.pno and pr1.route_action = 'HAVE_HAIR_SCAN_NO_TO' and pr1.routed_at > date_sub(curdate(), interval 3 month)
left join ph_staging.sys_attachment sa1 on sa1.oss_bucket_key = plt.source_id and sa1.object_key regexp 'LABEL'
left join ph_staging.sys_attachment sa2 on sa2.oss_bucket_key = plt.source_id and sa2.object_key regexp 'PACK'
left join ph_staging.sys_attachment sa3 on sa3.oss_bucket_key = plt.source_id and sa3.object_key regexp 'DAMAGED'
left join ph_staging.sys_attachment sa4 on sa4.oss_bucket_key = plt.source_id and sa4.object_key regexp 'FILLER'
left join ph_staging.sys_attachment sa5 on sa5.oss_bucket_key = plt.source_id and sa5.object_key regexp 'WEIGHT'
left join ph_staging.sys_attachment sa6 on sa6.oss_bucket_key = plt.source_id and sa6.object_key regexp 'RECEIVABLE'
where
    plt.state = 5
    and plt.operator_id not in (10000,10001)
    and plt.updated_at >= date_sub(curdate(), interval 7 day)
    and plt.updated_at < curdate()
    and bc.client_id is null
    and plt.vip_enable = 0
    and plt.duty_reasons in ('parcel_lose_duty_no_res_reasons_1', 'parcel_lose_duty_no_res_reasons_2', 'parcel_lose_duty_no_res_reasons_6', 'parcel_lose_duty_no_res_reasons_7')
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    concat('SSRD',plt.`id`) '任务ID Task ID'
    ,plt.created_at '任务生成时间 Task Generation Time'
    ,plt.pno '运单号Tracking Number'
    ,case plt.`vip_enable`
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end as '客户类型Customer Type'
    ,case plt.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end as '判责类型Judgment type'
    ,t.`t_value` '原因Reason'
    ,plt.`client_id` '客户ID Customer ID'
    ,pi.cod_amount/100 'COD金额 COD amount'
    ,oi.cogs_amount/100 COGS
    ,plt.`parcel_created_at` '揽收时间Pickup D/T'
    ,pi.exhibition_weight '重量Weight'
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) '尺寸Size'
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
    ,if(pr1.pno is not null, '是', '否') '是否有发无到Whether Shipped without Arrival'
    ,pr.`next_store_name`  '下一站点Next DC/Hub'
    ,case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 33 then 'C来源HUB波次举报（临时来源，发送工单后将恢复C来源)'
    end  '问题件来源渠道Source of problem'
    ,group_concat(distinct wo.order_no) '工单编号Ticket number'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key)) '包裹外包装且展示面单的照片Photos of the package and showing the face sheet'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key)) '包裹外包装的照片Photos of the outer packaging'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa3.object_key)) '包裹外包装破损的照片Photos of damaged packages'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa4.object_key)) '包裹内填充物的照片Photo of the filling in the package'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa5.object_key)) '包裹目前重量的照片Photo of the current weight of the package'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa6.object_key)) '应收到的产品的照片Photos of the product you should receive'
from  `ph_bi`.`parcel_lose_task` plt
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )
left join `ph_staging`.`parcel_route` pr on pr.`pno` = plt.`pno` and pr.`store_id` = plt.`last_valid_store_id` and pr.routed_at > date_sub(curdate(), interval 3 month)
left join `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
left join `ph_bi`.`translations` t on plt.duty_reasons = t.t_key and t.`lang` = 'zh-CN'
left join ph_staging.parcel_route pr1 on pr1.pno = plt.pno and pr1.route_action = 'HAVE_HAIR_SCAN_NO_TO' and pr1.routed_at > date_sub(curdate(), interval 3 month)
left join ph_staging.sys_attachment sa1 on sa1.oss_bucket_key = plt.source_id and sa1.object_key regexp 'LABEL'
left join ph_staging.sys_attachment sa2 on sa2.oss_bucket_key = plt.source_id and sa2.object_key regexp 'PACK'
left join ph_staging.sys_attachment sa3 on sa3.oss_bucket_key = plt.source_id and sa3.object_key regexp 'DAMAGED'
left join ph_staging.sys_attachment sa4 on sa4.oss_bucket_key = plt.source_id and sa4.object_key regexp 'FILLER'
left join ph_staging.sys_attachment sa5 on sa5.oss_bucket_key = plt.source_id and sa5.object_key regexp 'WEIGHT'
left join ph_staging.sys_attachment sa6 on sa6.oss_bucket_key = plt.source_id and sa6.object_key regexp 'RECEIVABLE'
where
    plt.state = 5
    and plt.operator_id not in (10000,10001)
    and plt.updated_at >= date_sub(curdate(), interval 7 day)
    and plt.updated_at < curdate()
    and bc.client_id is null
    and plt.vip_enable = 0
    and plt.duty_reasons in ('parcel_lose_duty_no_res_reasons_1', 'parcel_lose_duty_no_res_reasons_2', 'parcel_lose_duty_no_res_reasons_6', 'parcel_lose_duty_no_res_reasons_7')
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with
 handover2 as
(
    select
        fn.pno
        ,fn.pno_type
        ,fn.store_id
        ,fn.staff_info_id
        ,fn.finished_at
        ,fn.pi_state
    from
        (
            select
                    pr.pno
                    ,pr.store_id
                    ,pr.staff_info_id
                   -- ,pr.sub_staff_info_id
                    ,pi.state pi_state
                    ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                    ,if(pi.returned=1,'退件','正向件') as pno_type
                    ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                from
                    ( # 所有22点前交接包裹找到最后一次交接的人
                        select
                            pr.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.staff_info_id
                                    ,pr.store_id
                                    -- ,rid.sub_staff_info_id
                                    ,row_number() over(partition by pr.pno order by convert_tz(pr.created_at,'+00:00','+08:00') desc) as rnk
                                from ph_staging.`ticket_delivery`  pr
                                where
                                pr.created_at >=concat(date_sub(current_date,interval 1 day), ' 16:00:00')
                                and pr.created_at <concat(date_sub(current_date,interval 0 day), ' 14:00:00')
                            ) pr
                            where  pr.rnk=1
                    ) pr
                    left join ph_staging.parcel_info pi on pr.pno = pi.pno and pi.created_at >=concat(date_sub(current_date,interval 60 day), ' 16:00:00') and pi.created_at <concat(date_sub(current_date,interval 0 day), ' 09:00:00')
        )fn
)
,
 al as
     (
         select
            t1.网点
            ,t1.大区
            ,t1.片区
            ,t1.员工ID
            ,t1.快递员姓名
            ,t1.work_days  在职时长
            ,t1.快递员类型
            ,ifnull(f2.交接量_非退件, 0) 交接量_非退件
            ,ifnull(f6.非退件妥投量, 0) 非退件妥投量
            ,ifnull(f6.退件妥投量_按地址转换, 0) 退件妥投量_按地址转换
            ,ifnull(f6.非退件妥投量_大件折算, 0 ) 非退件妥投量_大件折算
            ,ifnull(pk.ticket_pickup_cn,0) 揽收任务数
            ,ifnull(pk.pickup_pno_cn,0) 揽收包裹量
            ,f6.finished_at as 22点前快递员结束派件时间
            ,if(ifnull(f2.交接量_非退件,0)<>0 ,concat(round(f6.非退件妥投量/(ifnull(f2.交接量_非退件,0))*100,2),'%'),0) as 妥投率
            ,row_number() over (partition by t1.网点 order by ifnull(f6.非退件妥投量, 0)) rk
#                         ,if(f5.staff_info_id is not null, '是', null) 是否出勤不达标
            ,case
                when (ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))=0 then '是'
                when t1.网点类型=1 and sdt.total_should_delivery_pno/ss.attendance_staff_cn>=40 and (ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<32  then '是'
                when t1.网点类型=1 and sdt.total_should_delivery_pno/ss.attendance_staff_cn<40 and (ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<sdt.total_should_delivery_pno/ss.attendance_staff_cn*0.8  then '是'
                when t1.网点类型=10 and sdt.total_should_delivery_pno/ss.attendance_staff_cn>=40 and (ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<32  then '是'
                when t1.网点类型=10 and sdt.total_should_delivery_pno/ss.attendance_staff_cn<40 and (ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<sdt.total_should_delivery_pno/ss.attendance_staff_cn*0.8  then '是'
                else null
            end as 是否低人效
        from
            (
                select
                    dt.region_name 大区
                    ,dt.piece_name 片区
                    ,dt.store_name 网点
                    ,dt.store_category as 网点类型
                    ,rid.staff_info_id as 员工ID
                    ,rid.store_id
                    ,hsi.name as  快递员姓名
                    ,rid.work_days
                    ,case when rid.job_title=13 then 'bike' when rid.job_title=110 then 'van' when rid.job_title=452 then 'tricycle'   else '' end as 快递员类型
                    #,datediff(curdate(), hsi.hire_date)  在职时长
                from tmpale.tmp_ph_staff_1205 rid
                join ph_bi.hr_staff_info hsi on hsi.staff_info_id =rid.staff_info_id
                left join dwm.dim_ph_sys_store_rd dt on dt.store_id =rid.store_id and dt.stat_date = current_date
            ) t1
        left join
            (-- 非子母件交接量
                select
                    fn.staff_info_id as 员工ID
                    ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
                from  handover2 fn
                group by 1
            )f2 on f2.员工ID = t1.员工ID
        left join
            (
                select
                    pi.ticket_pickup_staff_info_id
                    ,count(distinct pi.ticket_pickup_id) as ticket_pickup_cn
                    ,count(distinct pi.pno) as pickup_pno_cn
                from ph_staging.parcel_info pi
                where pi.state<9
                and pi.returned=0
                and pi.created_at >=concat(date_sub(curdate(), interval 1 day),' 16:00:00')
                and pi.created_at <=concat(curdate(),' 16:00:00')
                group by 1
            )pk on pk.ticket_pickup_staff_info_id = t1.员工ID
        left join
            ( -- 22点前最后一个妥投包裹时间
                select
                    rid.staff_info_id
                    ,max(convert_tz(pi.finished_at,'+00:00','+07:00')) as finished_at
                    ,count(distinct case when pi.returned=0  then pi.pno else null end) as 非退件妥投量
                    ,count(distinct case when pi.returned=1  then pi.dst_detail_address else null end) as 退件妥投量_按地址转换
                    ,sum(case when pi.returned=0 and if(floor(pi.weight/10000)=0,1,floor(pi.weight/10000))<if(floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1<1,1,floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1)
                                then if(floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1<1,1,floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1)
                               when pi.returned=0  then if(floor(pi.weight/10000)=0,1,floor(pi.weight/10000)) else null end) as 非退件妥投量_大件折算
                from ph_staging.parcel_info pi
                join tmpale.tmp_ph_staff_1205 rid on pi.ticket_delivery_staff_info_id=rid.staff_info_id
                where
                    pi.state=5
                    and pi.finished_at>=concat(date_sub(current_date,interval 1 day), ' 16:00:00')
                    and pi.finished_at<=concat(date_sub(current_date,interval 0 day), ' 14:00:00')
                    #and pi.ticket_delivery_staff_info_id='637320'
                group by 1
             ) f6 on f6.staff_info_id = t1.员工ID
        left join
            (
                select
                    sdt.store_id
                    ,count(distinct sdt.pno) as total_should_delivery_pno
                from ph_bi.dc_should_delivery_today sdt
                where sdt.stat_date= current_date
                group by 1
            )sdt on t1.store_id=sdt.store_id
        left join
            (#网点今日出勤人数
                select
                    ss.store_id
                    ,count(distinct ss.staff_info_id) as attendance_staff_cn
                from
                    (
                        select
                            adv.staff_info_id
                            ,if(hsa.staff_info_id is null,adv.sys_store_id,hsa.store_id) as store_id
                            ,if(hsa.staff_info_id is null,hsi.job_title,hsa.job_title_id) as job_title_id
                        from ph_bi.attendance_data_v2 adv
                        join ph_bi.hr_staff_info hsi on hsi.staff_info_id =adv.staff_info_id
                        left join ph_backyard.hr_staff_apply_support_store hsa on adv.staff_info_id=hsa.staff_info_id
                            and hsa.status = 2 #支援审核通过
                            and hsa.actual_begin_date <=current_date
                            and coalesce(hsa.actual_end_date, curdate())>= current_date
                            and hsa.employment_begin_date<=current_date
                            and hsa.employment_end_date>=current_date
                        where  adv.stat_date=current_date and (adv.attendance_started_at is not null or adv.attendance_end_at is not null)
                    )ss
                where ss.job_title_id in(13,110,1000)
                group by 1
            )ss on t1.store_id =ss.store_id
     )
select
    a.*
from
    (
        select
            current_date p_date
            ,fn.网点
            ,fn.大区
            ,fn.片区
            ,fn.员工ID
            ,fn.快递员姓名
            ,convert_tz(swa.started_at, '+00:00', '+08:00') 上班时间
            ,convert_tz(swa.end_at, '+00:00', '+08:00') 下班时间
            ,fn.快递员类型
            ,fn.在职时长
            ,fn.交接量_非退件
            ,fn.非退件妥投量
            ,fn.非退件妥投量_大件折算
            ,fn.退件妥投量_按地址转换
            ,fn.揽收任务数
            ,fn.揽收包裹量
            ,fn.22点前快递员结束派件时间
            ,fn.妥投率
            ,fn.是否出勤不达标
            ,fn.是否低人效v2 是否低人效
           ,if(fn.虚假行为>0,'是',null) as 是否虚假
        from
        (
            select
                a1.*
                ,a2.是否低人效 是否低人效v2
                ,fg.虚假行为
                ,if(f5.staff_info_id is not null, '是', null) 是否出勤不达标
            from al a1
            left join al a2 on a2.员工ID = a1.员工ID and a2.rk <= 2
            left join
                (
                    select
                        a.staff_info_id
                        ,sum(a.揽件虚假量) 虚假揽件量
                        ,sum(a.妥投虚假量) 虚假妥投量
                        ,sum(a.派件标记虚假量) 虚假派件标记量
                        ,sum(a.揽件虚假量)+sum(a.妥投虚假量)+sum(a.派件标记虚假量) as 虚假行为
                    from
                        (
                            select
                                vrv.staff_info_id
                                ,'回访' type
                                ,count(distinct if(vrv.visit_result  in (6), vrv.link_id, null)) 妥投虚假量
                                ,count(distinct if(vrv.visit_result in (18,8,19,20,21,31,32,22,23,24), vrv.link_id, null)) 派件标记虚假量
                                ,count(distinct if(vrv.visit_result in (37,39,3), vrv.link_id, null)) 揽件虚假量
                            from nl_production.violation_return_visit vrv
                            where
                                vrv.visit_state = 4
                                and vrv.updated_at >= date_sub(curdate(), interval 7 hour)
                                and vrv.updated_at < date_add(curdate(), interval 17 hour) -- 昨天
                                and vrv.visit_staff_id not in (10000,10001) -- 非ivr回访
                                and vrv.type in (1,2,3,4,5,6)
                            group by 1

                            union all
                            select
                                acca.staff_info_id
                                ,'投诉' type
                                ,count(distinct if(acca.complaints_type = 2, acca.merge_column, null)) 揽件虚假量
                                ,count(distinct if(acca.complaints_type = 1, acca.merge_column, null)) 妥投虚假量
                                ,count(distinct if(acca.complaints_type = 3, acca.merge_column, null)) 派件标记虚假量
                            from nl_production.customer_complaint_collects acca
                            where
                                acca.callback_state = 2
                                and acca.qaqc_callback_result in (2,3)
                                and acca.qaqc_callback_at >=date_sub(curdate(), interval 7 hour)
                                and acca.qaqc_callback_at <  date_add(curdate(), interval 17 hour)  -- 昨天
                                and acca.type = 1
                                and acca.complaints_type in (1,2,3)
                            group by 1
                        ) a
                    group by 1
                )fg on fg.staff_info_id = a1.员工ID
            left join
                ( --
                    select
                        a2.staff_info_id
                        ,a2.sys_store_id
                        ,a2.attendance_started_at
                        ,a2.shift_start
                        ,a2.attendance_end_at
                    from
                        (
                            select
                                ad.staff_info_id
                                ,hsi.sys_store_id
                                ,ad.shift_start
                                ,ad.attendance_started_at
                                ,ad.attendance_end_at
                                ,row_number() over (partition by hsi.sys_store_id order by timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at) desc) rk
                            from ph_bi.attendance_data_v2 ad
                            left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id
                            where
                                ad.stat_date = curdate()
                                and ad.attendance_started_at > concat(ad.stat_date, ' ', ad.shift_start)
                                and hsi.sys_store_id != -1
                                and hsi.is_sub_staff = 0
                                and hsi.job_title in (13,110,452)
                                and hsi.state = 1
                                and timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at) > 30

                        ) a2
                    where
                        a2.rk <= 2
                ) f5 on f5.staff_info_id = a1.员工ID
        )fn
        left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = fn.员工ID and swa.attendance_date = curdate()
) a
where
a.是否虚假 is not null
or a.是否低人效 is not null
or a.是否出勤不达标 is not null

union all

select
    curdate() p_date
    ,dt.store_name 网点
    ,dt.region_name 大区
    ,dt.piece_name 片区
    ,ad.staff_info_id 员工ID
    ,hsi.name 快递员姓名
    ,ad.attendance_started_at 上班时间
    ,ad.attendance_end_at 下班时间
    ,case hsi.job_title
        when 13 then  'bike'
        when 110 then 'van'
        when 452 then'boat'
    end 快递员类型
    ,datediff(curdate(), hsi.hire_date) 在职时长
    ,'' 交接量_非退件
    ,'' 非退件妥投量
    ,'' 非退件妥投量_大件折算
    ,'' 退件妥投量_按地址转换
    ,'' 揽收任务数
    ,'' 揽收包裹量
    ,'' 22点前快递员结束派件时间
    ,'' 妥投率
    ,'是' 是否出勤不达标
    ,'' 是否低人效
    ,'' 是否虚假
from ph_bi.attendance_data_v2 ad
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = hsi.sys_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0 -- 应出勤
    and ad.stat_date = curdate()
    and ad.attendance_started_at is null
    and ad.attendance_end_at is null
    and hsi.sys_store_id != -1
    and hsi.is_sub_staff = 0
    and hsi.job_title in (13,110,1000)
    and hsi.state = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.id as store_id
    ,ss.name as store_name
    ,mp.name as piece_name
    ,mr.name as region_name
    ,adv.staff_info_id as staff_info_id
    ,hsi.job_title
    ,datediff(curdate(),hsi.hire_date)as work_days
    ,hsi.job_title as sub_job_title
    ,ss.id as sub_store_id
    ,ss.name as sub_store_name
    ,mp.name as sub_piece_name
    ,mr.name as sub_region_name
    ,adv.attendance_started_at
	,adv.attendance_end_at
	,('N') as if_support
from ph_staging.sys_store ss1
join ph_bi.attendance_data_v2 adv on ss1.id=adv.sys_store_id and adv.stat_date=current_date and (adv.attendance_started_at is not null or adv.attendance_end_at is not null)
join ph_bi.hr_staff_info hsi on adv.staff_info_id=hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id=hsi.sys_store_id #所属网点信息
left join ph_staging.sys_manage_piece mp on mp.id = ss.manage_piece #所属片区信息
left join ph_staging.sys_manage_region mr on mr.id = ss.manage_region #所属大区信息
left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = hsi.staff_info_id and hsa.employment_begin_date <= curdate() and hsa.employment_end_date >= curdate() and hsa.status = 2
where ss1.category in(1,10)
    and hsi.state in(1,3)
    and hsi.job_title in (13,110,1000)
    and hsi.formal =1
    and hsa.staff_info_id is null

union all

select
    ss.id as store_id
    ,ss.name as store_name
    ,mp.name as piece_name
    ,mr.name as region_name
    ,hsa.staff_info_id
	,hsi.job_title
    ,datediff(curdate(),hsi.hire_date)as work_days
    ,hsa.job_title_id as sub_job_title
    ,ss1.id as sub_store_id
    ,ss1.name as sub_store_name
    ,mp1.name as sub_piece_name
    ,mr1.name as sub_region_name
    ,adv.attendance_started_at
	,adv.attendance_end_at
	,('Y') as if_support
from ph_backyard.hr_staff_apply_support_store hsa
join ph_bi.attendance_data_v2 adv on hsa.staff_info_id=adv.staff_info_id and adv.stat_date=current_date and (adv.attendance_started_at is not null or adv.attendance_end_at is not null)
join ph_bi.hr_staff_info hsi on hsi.staff_info_id =hsa.staff_info_id and hsi.formal =1
left join ph_staging.sys_store ss on ss.id=hsi.sys_store_id #所属网点信息
left join ph_staging.sys_manage_piece mp on mp.id = ss.manage_piece #所属片区信息
left join ph_staging.sys_manage_region mr on mr.id = ss.manage_region #所属大区信息
left join ph_staging.sys_store ss1 on ss1.id=hsa.store_id #所属网点信息
left join ph_staging.sys_manage_piece mp1 on mp1.id = ss1.manage_piece #所属片区信息
left join ph_staging.sys_manage_region mr1 on mr1.id = ss1.manage_region #所属大区信息
where hsa.status = 2 #支援审核通过
    and hsa.actual_begin_date <=current_date
    and coalesce(hsa.actual_end_date, curdate())>=current_date
    and hsa.employment_begin_date<=current_date
    and hsa.employment_end_date>=current_date
    and hsa.job_title_id in (13,110,1000)
    and hsi.formal =1;
;-- -. . -..- - / . -. - .-. -.--
select * from tmpale.tmp_ph_staff_1205;
;-- -. . -..- - / . -. - .-. -.--
select
    substr(convert_tz(pi.created_at, '+00:00', '+08:00'),1,7) 月份
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,count(pi.pno) 包裹量
from ph_staging.parcel_info pi
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
where
    pi.created_at >= '2023-08-31 16:00:00'
    and pi.created_at < '2023-12-31 16:00:00'
    and pi.state < 9
    and pi.returned = 0
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    sct.created_at
    ,case
        when bc.client_name = 'lazada' then laz.whole_end_date
        when bc.client_name = 'shopee' then shp.end_date
    end  超时日期
    ,case sct.source
        when 1 then '网点提交'
        when 2 then '客户提交'
        when 3 then '系统自动抓取'
    end 来源
    ,bc.client_name
    ,if(pi.returned = 1, '退件', '正向') 超时效类型
from ph_bi.ss_court_task sct
join dwm.dwd_dim_bigClient bc on bc.client_id = sct.client_id and bc.client_name in ('lazada', 'shopee')
left join ph_staging.parcel_info pi on pi.pno = sct.pno
left join dwm.dwd_ex_ph_lazada_pno_period laz on laz.pno = sct.pno
left join dwm.dwd_ex_shopee_lost_pno_period shp on shp.pno = sct.pno
where
    sct.created_at > '2023-12-01'
    and sct.created_at < '2024-01-01'
    and sct.source in (2,3)
    and sct.state in (2,3,5)
    and (case when bc.client_name = 'lazada' then laz.whole_end_date when bc.client_name ='shopee' then shp.end_date end) > sct.created_at
    and (case when bc.client_name = 'lazada' then laz.whole_end_date when bc.client_name ='shopee' then shp.end_date end) < sct.updated_at;
;-- -. . -..- - / . -. - .-. -.--
select
    sct.created_at
    ,sct.pno
    ,case
        when bc.client_name = 'lazada' then laz.whole_end_date
        when bc.client_name = 'shopee' then shp.end_date
    end  超时日期
    ,case sct.source
        when 1 then '网点提交'
        when 2 then '客户提交'
        when 3 then '系统自动抓取'
    end 来源
    ,bc.client_name
    ,if(pi.returned = 1, '退件', '正向') 超时效类型
from ph_bi.ss_court_task sct
join dwm.dwd_dim_bigClient bc on bc.client_id = sct.client_id and bc.client_name in ('lazada', 'shopee')
left join ph_staging.parcel_info pi on pi.pno = sct.pno
left join dwm.dwd_ex_ph_lazada_pno_period laz on laz.pno = sct.pno
left join dwm.dwd_ex_shopee_lost_pno_period shp on shp.pno = sct.pno
where
    sct.created_at > '2023-12-01'
    and sct.created_at < '2024-01-01'
    and sct.source in (2,3)
    and sct.state in (2,3,5)
    and (case when bc.client_name = 'lazada' then laz.whole_end_date when bc.client_name ='shopee' then shp.end_date end) > sct.created_at
    and (case when bc.client_name = 'lazada' then laz.whole_end_date when bc.client_name ='shopee' then shp.end_date end) < sct.updated_at;
;-- -. . -..- - / . -. - .-. -.--
select
    sct.created_at
    ,sct.pno
    ,case
        when bc.client_name = 'lazada' then laz.whole_end_date
        when bc.client_name = 'shopee' then shp.end_date
    end  超时日期
    ,case sct.source
        when 1 then '网点提交'
        when 2 then '客户提交'
        when 3 then '系统自动抓取'
    end 来源
    ,bc.client_name
    ,if(pi.returned = 1, '退件', '正向') 超时效类型
from ph_bi.ss_court_task sct
join dwm.dwd_dim_bigClient bc on bc.client_id = sct.client_id and bc.client_name in ('lazada', 'shopee')
left join ph_staging.parcel_info pi on pi.pno = sct.pno
left join dwm.dwd_ex_ph_lazada_pno_period laz on laz.pno = sct.pno
left join dwm.dwd_ex_shopee_lost_pno_period shp on shp.pno = sct.pno
where
    sct.created_at > '2023-12-01'
    and sct.created_at < '2024-01-01'
    and sct.source in (2,3)
#     and sct.state in (2,3,5)
    and (case when bc.client_name = 'lazada' then laz.whole_end_date when bc.client_name ='shopee' then shp.end_date end) > sct.created_at
    and (case when bc.client_name = 'lazada' then laz.whole_end_date when bc.client_name ='shopee' then shp.end_date end) < if(sct.state in (2,3,5), sct.updated_at, now());
;-- -. . -..- - / . -. - .-. -.--
select
    pi.src_phone 寄件人电话
    ,pi.pno 单号
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
    end as 包裹状态
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
    ,ss.name 目的地网点
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    pi.created_at > '2023-10-31 16:00:00'
    and pi.created_at < '2024-01-01 16:00:00'
    and pi.state < 9
    and pi.src_phone in ('09109699191', '09988454945', '09772111322', '09176331532');
;-- -. . -..- - / . -. - .-. -.--
select
hr.`staff_info_id`
,hr.`identity` 身份证
,hr.mobile 手机号
,hr.`company_name_ef` 外协公司
from  `ph_bi`.`hr_staff_info`  hr
where hr.`staff_info_id` in
(
'394000','393814','393814','393814','386101','394000','394000','393327','393327','390841','394001','394001','394001','394001','394001','391857','391857','394982','394982','393904','393904','393904','391867','391867','391867','391867','391867','391867','392986','392986','392986','392986','392986','392986','392986','392986'
);
;-- -. . -..- - / . -. - .-. -.--
select
hr.`staff_info_id`
,hr.`job_title`
,si.`name`
,case hr.`state`
when 1 then '在职'
when 2 then '离职'
end as state
,hr.`hire_date` 入职日期
from  `ph_bi`.`hr_staff_info`  hr
left join `ph_staging`.`staff_info_job_title` si
on si.`id` = hr.`job_title`
where hr.`staff_info_id` in
(
'136650','136738','136719','136162','136249','136424','136627','136628','136428','136500','136364','136827','136595','136452','136180','136476','136544','136659','136662','136601','136048','136335','136707','136350','136497','136554','136664','135854','136055','136318','136340','136357','136361','136430','136431','136508','136540','136818','135773','136096','136179','136631','136760','135892','136132','136755','135969','136094','136161','136260','136387','136062','136276','135655','135715','136035','136275','136505','131729','134253','136293','136413','136706','136764'
);
;-- -. . -..- - / . -. - .-. -.--
select
hr.`staff_info_id`
,hr.`job_title`
,si.`name`
,case hr.`state`
when 1 then '在职'
when 2 then '离职'
end as state
,hr.`hire_date` 入职日期
from  `ph_bi`.`hr_staff_info`  hr
left join `ph_staging`.`staff_info_job_title` si
on si.`id` = hr.`job_title`
where hr.`staff_info_id` in
('179256','178687','177815','177678','178152','178599','177747','177882','178011','160375','177806');
;-- -. . -..- - / . -. - .-. -.--
select a.id,
date(a.date),
count( a.`pno` )
from
(
select distinct pi.`pno`, sw.ID ,date(sw.`date`) date
from tmpale.tmp_ph_ttime_0104 sw
left join `ph_staging`.`parcel_info`  pi
on pi.`ticket_delivery_staff_info_id` = sw.`id`
and convert_tz(pi.`finished_at`,'+00:00','+08:00') >=from_unixtime(sw.`ttime`)
and convert_tz(pi.`finished_at`,'+00:00','+08:00')<= date_add(sw.date,interval 1 day)
where pi.`state` =5
#and pi.`ticket_delivery_staff_info_id` ='3158683'
#and date(sw.`date` )='2022-12-03'
) a
#where a.id='3158683'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 网点
    ,a1.pr_date 日期
    ,a1.staff_info_id 员工ID
    ,a1.pno_count 交接包裹数
    ,a2.pno_count 妥投包裹数
from
    (
        select
            a.pr_date
            ,a.staff_info_id
            ,count(distinct a.pno) pno_count
        from
            (
                select
                    pr.pno
                    ,pr.staff_info_id
                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+08:00')) order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                where
                    pr.routed_at > '2023-12-20 16:00:00'
                    and pr.routed_at < '2024-01-03 16:00:00'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a
        where
            a.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
            and a.rk = 1
        group by 1,2
    ) a1
left join
    (
        select
            pr.staff_info_id
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-12-20 16:00:00'
           and pr.routed_at < '2024-01-03 16:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
            and pr.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
        group by 1,2
    ) a2 on a2.staff_info_id = a1.staff_info_id and a2.pr_date = a1.pr_date
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 网点
    ,a1.pr_date 日期
    ,a1.staff_info_id 员工ID
    ,a1.pno_count 交接包裹数
    ,a2.pno_count 妥投包裹数
from
    (
        select
            a.pr_date
            ,a.staff_info_id
            ,count(distinct a.pno) pno_count
        from
            (
                select
                    pr.pno
                    ,pr.staff_info_id
                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+08:00')) order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                where
                    pr.routed_at > '2023-12-24 16:00:00'
#                     and pr.routed_at < date_add(curdate(), interval 8 hour)
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a
        where
            a.staff_info_id in ('131667','135063','136805','132944','136805','134125','154000','120396','147274','124324','129173','135063','149330','175532','178346','178348','178519','178521','178601','178602','178833','179178','179720','179815','179948','179952','179954','179956','154645','175871','178314','178317','178318','179908','179912','179913','133717','119873','119887','144948','168673','158001','178244','157222','153171','170843','145153')
            and a.rk = 1
        group by 1,2
    ) a1
left join
    (
        select
            pr.staff_info_id
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-12-24 16:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
            and pr.staff_info_id in ('131667','135063','136805','132944','136805','134125','154000','120396','147274','124324','129173','135063','149330','175532','178346','178348','178519','178521','178601','178602','178833','179178','179720','179815','179948','179952','179954','179956','154645','175871','178314','178317','178318','179908','179912','179913','133717','119873','119887','144948','168673','158001','178244','157222','153171','170843','145153')
        group by 1,2
    ) a2 on a2.staff_info_id = a1.staff_info_id and a2.pr_date = a1.pr_date
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
# left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = a1.staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= a1.pr_date and hsa.employment_end_date >= a1.pr_date
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pssn.van_in_proof_id
    ,pssn.arrival_pack_no
    ,pssn.van_arrived_at
from dw_dmd.parcel_store_stage_new pssn
join
    (
        select
            pr.pno
            ,pr.store_id
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0105 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
    ) ha on ha.store_id = pr.store_id and ha.pno = pr.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pssn.pno
    ,pssn.van_in_proof_id
    ,pssn.arrival_pack_no
    ,pssn.van_arrived_at
from dw_dmd.parcel_store_stage_new pssn
join
    (
        select
            pr.pno
            ,pr.store_id
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0105 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
    ) ha on ha.store_id = pssn.store_id and ha.pno = pssn.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pssn.pno
    ,pssn.van_in_proof_id
    ,pssn.arrival_pack_no
    ,pssn.van_arrived_at
from dw_dmd.parcel_store_stage_new pssn
join
    (
        select
            pr.pno
            ,pr.store_id
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0105 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
        group by 1,2
    ) ha on ha.store_id = pssn.store_id and ha.pno = pssn.pno;
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_id
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0105 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.pno = 'P182039XS5ABM'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    pssn.pno
    ,pssn.van_in_proof_id
    ,pssn.arrival_pack_no
    ,pssn.van_arrived_at
from dw_dmd.parcel_store_stage_new pssn
join
    (
        select
            pr.pno
            ,pr.store_id
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0105 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.pno = 'P182039XS5ABM'
        group by 1,2
    ) ha on ha.store_id = pssn.store_id and ha.pno = pssn.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pssn.pno
    ,pssn.van_in_proof_id
    ,pssn.arrival_pack_no
    ,pssn.van_arrived_at
from dw_dmd.parcel_store_stage_new pssn
join
    (
        select
            pr.pno
            ,pr.store_id
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0105 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
#             and pr.pno = 'P182039XS5ABM'
        group by 1,2
    ) ha on ha.store_id = pssn.store_id and ha.pno = pssn.pno;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10' -- QC不看之前的数据
    and ra.status = 2
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
    and ra.final_approval_time < date_add(curdate(), interval 13 hour )
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area15', 'Area6', 'Area18') then '徐加文'
        when smr.name in ('Area4', 'Area8', 'Area19') then '黄勇'
        when smr.name in ('Area7','Area10', 'Area11','Area14','FHome', 'Area17') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5','Area3','Area9','Area12','Area13','Area16') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on del.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
where
    hsi.sys_department_id not in (126,127) -- 被举报人非HUB，车线
group by 2;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,t.staff
            ,pr.routed_at
            ,pr.pno
            ,row_number() over (partition by date(convert_tz(pr.routed_at, '+00:00', '+08:00')),pr.staff_info_id order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_staff_lj_0109 t on t.staff = pr.staff_info_id
        where
            pr.routed_at > '2023-11-30 16:00:00'
            and pr.routed_at < '2023-12-31 16:00:00'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )

select
    t.staff
    ,t1.pr_date
    ,count(distinct t1.pno) handover_pno_count
from tmpale.tmp_ph_staff_lj_0109 t
left join
    (
        select
            t1.*
        from a t1
        left join a t2 on t2.pr_date = t1.pr_date and t2.staff = t1.staff and t2.rk = 1
        where
            t1.routed_at < date_add(t2.routed_at, interval 2 hour)
    ) t1 on t1.staff = t.staff
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    dmv.pno
    ,dmv.client_id 客户ID
    ,date(dmv.mark_at) 派送日期
    ,dmv.mark_at 标记派送失败的时间
    ,ddd.CN_element 标记原因
    ,case dmv.status
        when 0 then '失败'
        when 1 then '成功'
    end Viber发送消息是否成功
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
    end as 包裹状态
    ,if(pi.state = 5,convert_tz(pi.finished_at, '+00:00', '+08:00'), null) 妥投时间
from nl_production.delivery_mark_viber_msg dmv
left join dwm.dwd_dim_dict ddd on ddd.element = dmv.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join ph_staging.parcel_info pi on pi.pno = dmv.pno
where
    dmv.client_id in ('CA1385','BA0307','BA0609','BA0709','CA1281','AA0140','BA0344','CA1280','BA0300','BA0323','AA0142','BA0441','BA0391','AA0111','CA0548','CA0089','CA3478','AA0076','BA0056','BA0299','BA0258','BA0577','BA0599','BA0379','BA0478','BA0083','BA0184','AA0145','CA0218','CA0658','CA1646','CA0314','CA1644','CA0179','CA102')
    and dmv.created_at > '2023-09-01'
    and dmv.created_at < '2024-01-01';
;-- -. . -..- - / . -. - .-. -.--
select
    count(1)
from
    (
                select
            dmv.pno
            ,dmv.client_id 客户ID
            ,date(dmv.mark_at) 派送日期
            ,dmv.mark_at 标记派送失败的时间
            ,ddd.CN_element 标记原因
            ,case dmv.status
                when 0 then '失败'
                when 1 then '成功'
            end Viber发送消息是否成功
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
            end as 包裹状态
            ,if(pi.state = 5,convert_tz(pi.finished_at, '+00:00', '+08:00'), null) 妥投时间
        from nl_production.delivery_mark_viber_msg dmv
        left join dwm.dwd_dim_dict ddd on ddd.element = dmv.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        left join ph_staging.parcel_info pi on pi.pno = dmv.pno
        where
            dmv.client_id in ('CA1385','BA0307','BA0609','BA0709','CA1281','AA0140','BA0344','CA1280','BA0300','BA0323','AA0142','BA0441','BA0391','AA0111','CA0548','CA0089','CA3478','AA0076','BA0056','BA0299','BA0258','BA0577','BA0599','BA0379','BA0478','BA0083','BA0184','AA0145','CA0218','CA0658','CA1646','CA0314','CA1644','CA0179','CA102')
            and dmv.created_at > '2023-09-01'
            and dmv.created_at < '2024-01-01'
    );
;-- -. . -..- - / . -. - .-. -.--
select
    dmv.pno
    ,dmv.client_id 客户ID
    ,date(dmv.mark_at) 派送日期
    ,dmv.mark_at 标记派送失败的时间
    ,ddd.CN_element 标记原因
    ,case dmv.status
        when 0 then '失败'
        when 1 then '成功'
    end Viber发送消息是否成功
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
    end as 包裹状态
    ,if(pi.state = 5,convert_tz(pi.finished_at, '+00:00', '+08:00'), null) 妥投时间
from nl_production.delivery_mark_viber_msg dmv
left join dwm.dwd_dim_dict ddd on ddd.element = dmv.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join ph_staging.parcel_info pi on pi.pno = dmv.pno
where
    dmv.client_id in ('CA1385','BA0307','BA0609','BA0709','CA1281','AA0140','BA0344','CA1280','BA0300','BA0323','AA0142','BA0441','BA0391','AA0111','CA0548','CA0089','CA3478','AA0076','BA0056','BA0299','BA0258','BA0577','BA0599','BA0379','BA0478','BA0083','BA0184','AA0145','CA0218','CA0658','CA1646','CA0314','CA1644','CA0179','CA102')
    and dmv.created_at > '2023-09-01'
    and dmv.created_at < '2023-11-01';
;-- -. . -..- - / . -. - .-. -.--
select
    dmv.pno
    ,dmv.client_id 客户ID
    ,date(dmv.mark_at) 派送日期
    ,dmv.mark_at 标记派送失败的时间
    ,ddd.CN_element 标记原因
    ,case dmv.status
        when 0 then '失败'
        when 1 then '成功'
    end Viber发送消息是否成功
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
    end as 包裹状态
    ,if(pi.state = 5,convert_tz(pi.finished_at, '+00:00', '+08:00'), null) 妥投时间
from nl_production.delivery_mark_viber_msg dmv
left join dwm.dwd_dim_dict ddd on ddd.element = dmv.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join ph_staging.parcel_info pi on pi.pno = dmv.pno
where
    dmv.client_id in ('CA1385','BA0307','BA0609','BA0709','CA1281','AA0140','BA0344','CA1280','BA0300','BA0323','AA0142','BA0441','BA0391','AA0111','CA0548','CA0089','CA3478','AA0076','BA0056','BA0299','BA0258','BA0577','BA0599','BA0379','BA0478','BA0083','BA0184','AA0145','CA0218','CA0658','CA1646','CA0314','CA1644','CA0179','CA102')
    and dmv.created_at >= '2023-11-01'
    and dmv.created_at < '2024-01-01';
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pct.source
            ,pct.pno
            ,pct.state pct_state
            ,pct.client_id
            ,pct.created_at
        from ph_bi.parcel_claim_task pct
        join ph_staging.parcel_info pi on pct.pno = pi.pno
        where
            pct.created_at >= '2023-11-30 16:00:00'
            and pct.created_at < '2023-12-31 16:00:00'
            and pi.returned = 1
    )
select
    a1.pno
    ,case a1.source
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
    ,pi.cod_amount/100 COD
    ,if(sct.pno is not null, '是', '否') 是否有判责属实
    ,case a1.pct_state
        when 1 then '待协商'
        when 2 then '协商不一致，待重新协商'
        when 3 then '待财务核实'
        when 4 then '核实通过，待财务支付'
        when 5 then '财务驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止'
        when 8 then '异常关闭'
        when 9 then' 待协商（搁置）'
        when 10 then '等待再次联系'
    end 理赔状态
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
from
    (
        select
            a.*
        from
            (
                select
                    pr.state
                    ,t1.*
                    ,row_number() over (partition by t1.pno order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at < date_sub(t1.created_at, interval 8 hour)
            ) a
        where
            a.rk = 1
    ) a1
left join ph_staging.parcel_info pi on pi.returned_pno = a1.pno
left join ph_bi.ss_court_task sct on sct.pno = a1.pno  and sct.state = 3
left join ph_staging.ka_profile kp on kp.id = a1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = a1.client_id
where
    a1.state in (1,2,3,4,6);
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pct.source
            ,pct.pno
            ,pct.state pct_state
            ,pct.client_id
            ,pct.created_at
        from ph_bi.parcel_claim_task pct
        join ph_staging.parcel_info pi on pct.pno = pi.pno
        where
            pct.created_at >= '2023-11-30 16:00:00'
            and pct.created_at < '2023-12-31 16:00:00'
            and pi.returned = 1
    )
select
    a1.pno
    ,case a1.source
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
    ,pi.cod_amount/100 COD
    ,if(sct.pno is not null, '是', '否') 是否有判责属实
    ,case a1.pct_state
        when 1 then '待协商'
        when 2 then '协商不一致，待重新协商'
        when 3 then '待财务核实'
        when 4 then '核实通过，待财务支付'
        when 5 then '财务驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止'
        when 8 then '异常关闭'
        when 9 then' 待协商（搁置）'
        when 10 then '等待再次联系'
    end 理赔状态
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
from
    (
        select
            a.*
        from
            (
                select
                    pr.state
                    ,t1.*
                    ,row_number() over (partition by t1.pno order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at < date_sub(t1.created_at, interval 8 hour)
            ) a
        where
            a.rk = 1
    ) a1
left join ph_staging.parcel_info pi on pi.returned_pno = a1.pno
left join ph_bi.ss_court_task sct on sct.pno = a1.pno  and sct.state = 3
left join ph_staging.ka_profile kp on kp.id = a1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = a1.client_id
where
    a1.state in (1,2,3,4,6);
;-- -. . -..- - / . -. - .-. -.--
select count(1)
from (        select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-09-11 16:00:00'
            and tp.created_at < '2023-11-12 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14);
;-- -. . -..- - / . -. - .-. -.--
select count(1)
from (        select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-09-11 16:00:00'
            and tp.created_at < '2023-11-12 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3);
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-09-11 16:00:00'
            and tp.created_at < '2023-09-18 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14;
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-09-11 16:00:00'
            and tp.created_at < '2023-09-18 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-09-18 16:00:00'
            and tp.created_at < '2023-09-25 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-09-25 16:00:00'
            and tp.created_at < '2023-10-02 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-10-02 16:00:00'
            and tp.created_at < '2023-10-09 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-10-09 16:00:00'
            and tp.created_at < '2023-10-16 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-10-16 16:00:00'
            and tp.created_at < '2023-10-23 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-10-23 16:00:00'
            and tp.created_at < '2023-10-30 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-10-30 16:00:00'
            and tp.created_at < '2023-11-06 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-11-06 16:00:00'
            and tp.created_at < '2023-11-13 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when a.揽收日期 >= '2023-09-12' and a.揽收日期 <= '2023-10-12' then '0912-1012'
        when a.揽收日期 >= '2023-10-13' and a.揽收日期 <= '2023-11-12' then '1013-1112'
    end 时间段
    ,sum(a.完成揽收时间)/count(a.id) 平均时长_min
from
    (
        select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-09-11 16:00:00'
            and tp.created_at < '2023-11-12 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when a.揽收日期 >= '2023-09-12' and a.揽收日期 <= '2023-10-12' then '0912-1012'
        when a.揽收日期 >= '2023-10-13' and a.揽收日期 <= '2023-11-12' then '1013-1112'
    end 时间段
    ,sum(a.完成揽收时间)/count(if(a.opt != 512, a.id, null)) 平均时长_min
from
    (
        select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.opt
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-09-11 16:00:00'
            and tp.created_at < '2023-11-12 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.finished_at, '+00:00', '+08:00')) 日期
    ,ss.name 网点
    ,count(if(hour(convert_tz(pi.finished_at, '+00:00', '+08:00')) < 16, pi.pno, null))/count(pi.pno) 4点前妥投占比
    ,count(if(st_distance_sphere(point(ss.lng,ss.lat), point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat)), pi.pno, null))/count(pi.pno) 100m以内妥投占比
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.finished_at >= '2023-08-25 16:00:00'
    and pi.finished_at < '2023-10-26 16:00:00'
    and pi.state = 5
    and pi.ticket_delivery_store_id in ('PH59020701','PH55030P00','PH53020200','PH53023A00','PH70140F00','PH52060V00','PH57050200','PH58070K00','PH54060H00','PH57010500','PH58010A00','PH58030E00','PH57100100','PH59110600','PH57030800','PH70100400','PH52050800','PH52030B00','PH59090D00','PH53010J00','PH53090700','PH57150B00','PH53022200','PH57060P00','PH53020L01','PH54010H00','PH59030100','PH57040100','PH60110101','PH39070102','PH39070101','PH52010102','PH52010101','PH52080101','PH57040200','PH70060A00','PH52080100','PH60110100','PH56090100','PH54090100','PH39070100','PH53030100','PH52010100')
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.finished_at, '+00:00', '+08:00')) 日期
    ,ss.name 网点
    ,count(pi.pno) 当日妥投包裹数
    ,count(if(hour(convert_tz(pi.finished_at, '+00:00', '+08:00')) < 16, pi.pno, null))/count(pi.pno) 4点前妥投占比
    ,count(if(st_distance_sphere(point(ss.lng,ss.lat), point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat)), pi.pno, null))/count(pi.pno) 100m以内妥投占比
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.finished_at >= '2023-08-25 16:00:00'
    and pi.finished_at < '2023-10-26 16:00:00'
    and pi.state = 5
    and pi.ticket_delivery_store_id in ('PH59020701','PH55030P00','PH53020200','PH53023A00','PH70140F00','PH52060V00','PH57050200','PH58070K00','PH54060H00','PH57010500','PH58010A00','PH58030E00','PH57100100','PH59110600','PH57030800','PH70100400','PH52050800','PH52030B00','PH59090D00','PH53010J00','PH53090700','PH57150B00','PH53022200','PH57060P00','PH53020L01','PH54010H00','PH59030100','PH57040100','PH60110101','PH39070102','PH39070101','PH52010102','PH52010101','PH52080101','PH57040200','PH70060A00','PH52080100','PH60110100','PH56090100','PH54090100','PH39070100','PH53030100','PH52010100')
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.finished_at, '+00:00', '+08:00')) 日期
    ,ss.name 网点
    ,count(pi.pno) 当日妥投包裹数
    ,count(if(hour(convert_tz(pi.finished_at, '+00:00', '+08:00')) < 16, pi.pno, null))/count(pi.pno) 4点前妥投占比
    ,count(if(st_distance_sphere(point(ss.lng,ss.lat), point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat)), pi.pno, null))/count(pi.pno) 100m以内妥投占比
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.finished_at >= '2023-08-25 16:00:00'
    and pi.finished_at < '2023-10-26 16:00:00'
    and pi.state = 5
    and pi.ticket_delivery_store_id in ('PH18040100','PH18040104','PH18040503','PH18060100','PH18060800','PH18061R03','PH18061R04','PH18061R05','PH18061R06','PH19030P02','PH19030P03','PH19040202','PH19240100','PH19241601','PH19241U01','PH19250100')
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.finished_at, '+00:00', '+08:00')) 日期
    ,ss.name 网点
    ,count(pi.pno) 当日妥投包裹数
    ,count(if(hour(convert_tz(pi.finished_at, '+00:00', '+08:00')) < 16, pi.pno, null))/count(pi.pno) 4点前妥投占比
    ,count(if(st_distance_sphere(point(ss.lng,ss.lat), point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat)) < 100, pi.pno, null))/count(pi.pno) 100m以内妥投占比
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.finished_at >= '2023-08-25 16:00:00'
    and pi.finished_at < '2023-10-26 16:00:00'
    and pi.state = 5
    and pi.ticket_delivery_store_id in ('PH18040100','PH18040104','PH18040503','PH18060100','PH18060800','PH18061R03','PH18061R04','PH18061R05','PH18061R06','PH19030P02','PH19030P03','PH19040202','PH19240100','PH19241601','PH19241U01','PH19250100')
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.finished_at, '+00:00', '+08:00')) 日期
    ,ss.name 网点
    ,count(pi.pno) 当日妥投包裹数
    ,count(if(hour(convert_tz(pi.finished_at, '+00:00', '+08:00')) < 16, pi.pno, null))/count(pi.pno) 4点前妥投占比
    ,count(if(st_distance_sphere(point(ss.lng,ss.lat), point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat)) < 100, pi.pno, null))/count(pi.pno) 100m以内妥投占比
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.finished_at >= '2023-08-25 16:00:00'
    and pi.finished_at < '2023-10-26 16:00:00'
    and pi.state = 5
    and pi.ticket_delivery_store_id in ('PH59020701','PH55030P00','PH53020200','PH53023A00','PH70140F00','PH52060V00','PH57050200','PH58070K00','PH54060H00','PH57010500','PH58010A00','PH58030E00','PH57100100','PH59110600','PH57030800','PH70100400','PH52050800','PH52030B00','PH59090D00','PH53010J00','PH53090700','PH57150B00','PH53022200','PH57060P00','PH53020L01','PH54010H00','PH59030100','PH57040100','PH60110101','PH39070102','PH39070101','PH52010102','PH52010101','PH52080101','PH57040200','PH70060A00','PH52080100','PH60110100','PH56090100','PH54090100','PH39070100','PH53030100','PH52010100')
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.finished_at, '+00:00', '+08:00')) 日期
    ,ss.name 网点
    ,count(pi.pno) 当日妥投包裹数
    ,count(if(hour(convert_tz(pi.finished_at, '+00:00', '+08:00')) < 16, pi.pno, null))/count(pi.pno) 4点前妥投占比
    ,count(if(st_distance_sphere(point(ss.lng,ss.lat), point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat)) < 100, pi.pno, null))/count(pi.pno) 100m以内妥投占比
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.finished_at >= '2023-10-08 16:00:00'
    and pi.finished_at < '2023-12-09 16:00:00'
    and pi.state = 5
    and pi.ticket_delivery_store_id in ('PH59020701','PH55030P00','PH53020200','PH53023A00','PH70140F00','PH52060V00','PH57050200','PH58070K00','PH54060H00','PH57010500','PH58010A00','PH58030E00','PH57100100','PH59110600','PH57030800','PH70100400','PH52050800','PH52030B00','PH59090D00','PH53010J00','PH53090700','PH57150B00','PH53022200','PH57060P00','PH53020L01','PH54010H00','PH59030100','PH57040100','PH60110101','PH39070102','PH39070101','PH52010102','PH52010101','PH52080101','PH57040200','PH70060A00','PH52080100','PH60110100','PH56090100','PH54090100','PH39070100','PH53030100','PH52010100')
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.finished_at, '+00:00', '+08:00')) 日期
    ,ss.name 网点
    ,count(pi.pno) 当日妥投包裹数
    ,count(if(hour(convert_tz(pi.finished_at, '+00:00', '+08:00')) < 16, pi.pno, null))/count(pi.pno) 4点前妥投占比
    ,count(if(st_distance_sphere(point(ss.lng,ss.lat), point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat)) < 100, pi.pno, null))/count(pi.pno) 100m以内妥投占比
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.finished_at >= '2023-10-08 16:00:00'
    and pi.finished_at < '2023-12-09 16:00:00'
    and pi.state = 5
    and pi.ticket_delivery_store_id in ('PH18040100','PH18040104','PH18040503','PH18060100','PH18060800','PH18061R03','PH18061R04','PH18061R05','PH18061R06','PH19030P02','PH19030P03','PH19040202','PH19240100','PH19241601','PH19241U01','PH19250100')
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.task_id
    ,case vrv.visit_state
            when 0 then '终态或变更派件标记等无须回访'
            when 1 then '待回访'
            when 2 then '沟通中'
            when 3 then '多次未联系上客户'
            when 4 then '已回访'
            when 5 then '因同包裹生成其他回访任务关闭'
            when 6 then 'VR回访结果=99关闭'
            when 7 then '超回访时效关闭'
        end status
from nl_production.violation_return_visit vrv
join tmpale.tmp_ph_visit_lj_0112 t on t.task_id = vrv.id;
;-- -. . -..- - / . -. - .-. -.--
select
    t.task_id
    ,vrv.link_id pno
    ,case pi.state
        when 1 then 'RECEIVED'
        when 2 then 'IN_TRANSIT'
        when 3 then 'DELIVERING'
        when 4 then 'STRANDED'
        when 5 then 'SIGNED'
        when 6 then 'IN_DIFFICULTY'
        when 7 then 'RETURNED'
        when 8 then 'ABNORMAL_CLOSED'
        when 9 then 'CANCEL'
    end status
from nl_production.violation_return_visit vrv
join tmpale.tmp_ph_visit_lj_0112 t on t.task_id = vrv.id
left join ph_staging.parcel_info pi on pi.pno = vrv.link_id;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pr_date 日期
    ,a.client_id 客户ID
    ,a.pno 单号
    ,case a.marker_category
        when 40 then '联系不上客户'
        when 78 then '收件人电话号码是空号'
        when 75 then '收件人电话号码错误'
    end 标记原因
    ,if(a.state = 5, '是', '否') 最终是否正向妥投成功
from
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149')
    ) a
where
    a.delivery_attempt_num = 3
    and a.pr_date >= '2023-12-01'
    and a.pr_date <= '2023-12-31'
    and a.marker_category in (40,78,75);
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
            ,json_extract(pr.extra_value, '$.deliveryAttempt')  delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'shein'
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149')
#             and json_extract(pr.extra_value, '$.deliveryAttemptNum')
    )
select
    a1.pr_date 第三次派送日期
    ,a1.client_id 客户ID
    ,a1.pno 运单号
    ,dai.delivery_attempt_num 尝试派送次数
    ,if(a1.state = 5, '是', '否') 是否派送成功
    ,group_concat(distinct a2.EN_element) 标记原因
from
    (
        select
            t1.*
        from t t1
        where
            t1.marker_category in (40,78,75)
            and t1.delivery_attempt_num = 3
            and t1.pr_date >= '2023-12-01'
            and t1.pr_date <= '2023-12-31'
            and t1.delivery_attempt = 'true'
    ) a1
left join ph_staging.delivery_attempt_info dai on dai.pno = a1.pno
left join t a2 on a2.pno = a1.pno and a2.route_action = 'DELIVERY_MARKER'
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
            ,json_extract(pr.extra_value, '$.deliveryAttempt')  delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'shein'
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149');
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
            ,json_extract(pr.extra_value, '$.deliveryAttempt')  delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'shein'
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149')
#             and json_extract(pr.extra_value, '$.deliveryAttemptNum')
    )
# select
#     a1.pr_date 第三次派送日期
#     ,a1.client_id 客户ID
#     ,a1.pno 运单号
#     ,dai.delivery_attempt_num 尝试派送次数
#     ,if(a1.state = 5, '是', '否') 是否派送成功
#     ,group_concat(distinct a2.EN_element) 标记原因
# from
    (
        select
            t1.*
        from t t1
        where
            t1.marker_category in (40,78,75)
            and t1.delivery_attempt_num = 3
            and t1.pr_date >= '2023-12-01'
            and t1.pr_date <= '2023-12-31'
            and t1.delivery_attempt = 'true';
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
            ,json_extract(pr.extra_value, '$.deliveryAttempt')  delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'shein'
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149')
#             and json_extract(pr.extra_value, '$.deliveryAttemptNum')
    )
# select
#     a1.pr_date 第三次派送日期
#     ,a1.client_id 客户ID
#     ,a1.pno 运单号
#     ,dai.delivery_attempt_num 尝试派送次数
#     ,if(a1.state = 5, '是', '否') 是否派送成功
#     ,group_concat(distinct a2.EN_element) 标记原因
# from
#     (
        select
            t1.*
        from t t1
        where
            t1.marker_category in (40,78,75)
            and t1.delivery_attempt_num = 3
            and t1.pr_date >= '2023-12-01'
            and t1.pr_date <= '2023-12-31'
            and t1.delivery_attempt = 'true';
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
            ,json_extract(pr.extra_value, '$.deliveryAttempt')  delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149');
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
            ,case json_extract(pr.extra_value, '$.deliveryAttempt')
                when 'true' then 1
                when 'false' then 0
            end delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149');
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_extract(pr.extra_value, '$.deliveryAttemptNum') delivery_attempt_num
            ,case json_unquote(json_extract(pr.extra_value, '$.deliveryAttempt'))
                when 'true' then 1
                when 'false' then 0
            end delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149');
;-- -. . -..- - / . -. - .-. -.--
select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_unquote(json_extract(pr.extra_value, '$.deliveryAttemptNum')) delivery_attempt_num
            ,case json_unquote(json_extract(pr.extra_value, '$.deliveryAttempt'))
                when 'true' then 1
                when 'false' then 0
            end delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149');
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_unquote(json_extract(pr.extra_value, '$.deliveryAttemptNum')) delivery_attempt_num
            ,case json_unquote(json_extract(pr.extra_value, '$.deliveryAttempt'))
                when 'true' then 1
                when 'false' then 0
            end delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149')
#             and json_extract(pr.extra_value, '$.deliveryAttemptNum')
    )
# select
#     a1.pr_date 第三次派送日期
#     ,a1.client_id 客户ID
#     ,a1.pno 运单号
#     ,dai.delivery_attempt_num 尝试派送次数
#     ,if(a1.state = 5, '是', '否') 是否派送成功
#     ,group_concat(distinct a2.EN_element) 标记原因
# from
#     (
        select
            t1.*
        from t t1
        where
            t1.marker_category in (40,78,75)
            and t1.delivery_attempt_num = 3
            and t1.pr_date >= '2023-12-01'
            and t1.pr_date <= '2023-12-31'
            and t1.delivery_attempt = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
            ,pi.client_id
            ,pr.pno
            ,pi.state
            ,pr.route_action
            ,ddd.EN_element
            ,json_unquote(json_extract(pr.extra_value, '$.deliveryAttemptNum')) delivery_attempt_num
            ,case json_unquote(json_extract(pr.extra_value, '$.deliveryAttempt'))
                when 'true' then 1
                when 'false' then 0
            end delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149')
#             and json_extract(pr.extra_value, '$.deliveryAttemptNum')
    )
select
    a1.pr_date 第三次派送日期
    ,a1.client_id 客户ID
    ,a1.pno 运单号
    ,dai.delivery_attempt_num 尝试派送次数
    ,if(a1.state = 5, '是', '否') 是否派送成功
    ,group_concat(distinct a2.EN_element) 标记原因
from
    (
        select
            t1.*
        from t t1
        where
            t1.marker_category in (40,78,75)
            and t1.delivery_attempt_num = 3
            and t1.pr_date >= '2023-12-01'
            and t1.pr_date <= '2023-12-31'
            and t1.delivery_attempt = 1
    ) a1
left join ph_staging.delivery_attempt_info dai on dai.pno = a1.pno
left join t a2 on a2.pno = a1.pno and a2.route_action = 'DELIVERY_MARKER'
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.marker_category
#             ,pi.client_id
            ,pr.pno
#             ,pr.route_action
            ,ddd.CN_element
#             ,json_unquote(json_extract(pr.extra_value, '$.deliveryAttemptNum')) delivery_attempt_num
#             ,case json_unquote(json_extract(pr.extra_value, '$.deliveryAttempt'))
#                 when 'true' then 1
#                 when 'false' then 0
#             end delivery_attempt
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pr.route_action in ('DELIVERY_MARKER')
            and pr.routed_at > '2023-09-01'
            and pi.returned = 0
            and pi.client_id in ('AA0148','AA0149')
#             and json_extract(pr.extra_value, '$.deliveryAttemptNum')
    )
select
    date(convert_tz(dai.last_delivery_attempt_at, '+00:00', '+08:00')) 最后一次派送日期
    ,dai.client_id 客户ID
    ,dai.pno 运单号
    ,dai.delivery_attempt_num 尝试派送次数
    ,if(pi.state = 5, '是', '否') 是否派送成功
    ,group_concat(distinct t1.CN_element) 派件标记
from ph_staging.delivery_attempt_info dai
left join t t1 on t1.pno = dai.pno
left join ph_staging.parcel_info pi on pi.pno = dai.pno
where
    dai.delivery_attempt_num >= 3
    and dai.last_marker_id in (40,29,25)
    and dai.last_delivery_attempt_at >= '2023-11-30 16:00:00'
    and dai.last_delivery_attempt_at < '2023-12-31 16:00:00'
    and dai.client_id in ('AA0148','AA0149')
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from ph_staging.sys_configuration sc
where
    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled';
;-- -. . -..- - / . -. - .-. -.--
select
            *
        from ph_staging.parcel_reject_report_info prr;
;-- -. . -..- - / . -. - .-. -.--
select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    a2.*
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_info pi on pi.pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
              pc.*
              ,store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as store_id

        union all;
;-- -. . -..- - / . -. - .-. -.--
select
            pc.*
            ,ss.store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
            ) pc
        cross join ph_staging.sys_store ss;
;-- -. . -..- - / . -. - .-. -.--
select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
            ) pc
        cross join ph_staging.sys_store ss;
;-- -. . -..- - / . -. - .-. -.--
select
              pc.*
              ,store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as store_id;
;-- -. . -..- - / . -. - .-. -.--
select
              pc.*
              ,store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as store_id

        union all;
;-- -. . -..- - / . -. - .-. -.--
select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from ph_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join ph_staging.sys_store ss;
;-- -. . -..- - / . -. - .-. -.--
select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from ph_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a;
;-- -. . -..- - / . -. - .-. -.--
select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join ph_staging.sys_store ss;
;-- -. . -..- - / . -. - .-. -.--
select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_info pi on pi.pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2

union all

select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_info pi on pi.pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a2.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from ph_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join ph_staging.sys_store ss
    ) a1
cross join
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a2
join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,coalesce(pi.client_id, pi2.client_id) client_id
            ,coalesce(pi.cod_amount, pi2.cod_amount) cod_amount
            ,coalesce(pi.insure_declare_value, pi2.insure_declare_value) insure_declare_value
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_info pi on pi.pno = upper(prr.pno)
        left join ph_staging.parcel_info pi2 on pi2.recent_pno = upper(prr.pno)
        where
            prr.created_at >= '2024-01-14 16:00:00'
    ) a3 on a3.store_id = a1.store_id and a3.client_id = a2.client_id
cross join
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5

union all


select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from ph_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join ph_staging.sys_store ss
    ) a1
cross join
    (
        select
            *
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
cross join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,coalesce(pi.client_id, pi2.client_id) client_id
            ,coalesce(pi.cod_amount, pi2.cod_amount) cod_amount
            ,coalesce(pi.insure_declare_value, pi2.insure_declare_value) insure_declare_value
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_info pi on pi.pno = upper(prr.pno)
        left join ph_staging.parcel_info pi2 on pi2.recent_pno = upper(prr.pno)
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    ppl.replace_pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_pno_log ppl
left join ph_staging.parcel_info pi on pi.pno = ppl.initial_pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
join tmpale.tmp_ph_pno_lj_0115 t on t.pno = ppl.replace_pno
# where
#     ppl.replace_pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')

union all

select
    pi.pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
join tmpale.tmp_ph_pno_lj_0115 t on t.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2

union all

select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a2.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from ph_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join ph_staging.sys_store ss
    ) a1
cross join
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a2
join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
    ) a3 on a3.store_id = a1.store_id and a3.client_id = a2.client_id
cross join
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5

union all


select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from ph_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join ph_staging.sys_store ss
    ) a1
cross join
    (
        select
            *
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
cross join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case pct.source
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
    ,case pct.state
        when 1 then '待协商'
        when 2 then '协商不一致，待重新协商'
        when 3 then '待财务核实'
        when 4 then '核实通过，待财务支付'
        when 5 then '财务驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止'
        when 8 then '异常关闭'
        when 9 then' 待协商（搁置）'
        when 10 then '等待再次联系'
    end 理赔状态
    ,pi.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
    ,case
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) < 24 then '0-24小时内处理'
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) >= 24 and timestampdiff(hour, pct.created_at, pct.updated_at) < 48 then '24-48小时内处理'
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) >= 48 and timestampdiff(hour, pct.created_at, pct.updated_at) < 72 then '48-72小时内处理'
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) >= 72 then '72小时以上处理'
        else null
    end 理赔处理时间
from ph_bi.parcel_claim_task pct
join ph_staging.parcel_info pi on pi.pno = pct.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pct.client_id
left join ph_staging.ka_profile kp on kp.id = pct.client_id
left join ph_staging.parcel_additional_info pai on pai.pno = pct.pno
where
    pct.created_at > '2023-11-01'
    and pct.created_at < '2024-01-16'
    and pi.state = 5;
;-- -. . -..- - / . -. - .-. -.--
select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= date_sub(curdate(), interval 8 hour)
           -- and prr.state = 2
        group by 1
    ) a2

union all

select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= date_sub(curdate(), interval 8 hour)
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a2.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from ph_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join ph_staging.sys_store ss
    ) a1
cross join
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a2
join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= date_sub(curdate(), interval 8 hour)
    ) a3 on a3.store_id = a1.store_id and a3.client_id = a2.client_id
cross join
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5

union all


select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from ph_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join ph_staging.sys_store ss
    ) a1
cross join
    (
        select
            *
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
cross join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= date_sub(curdate(), interval 8 hour)
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,pi.customary_pno 正向单号
    ,pai.cogs_amount/100 cogs
    ,pi.cod_amount/100 cod
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,hsi.name 妥投员工
    ,hsi.hire_date 入职日期
    ,pi.client_id 客户ID
    ,kp.name 客户名称
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离妥投网点距离
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(kw.lng, kw.lat)) 距离仓库距离
    ,if(p1.pno is not null, '是', '否') 是否有拨打电话
    ,if(p2.pno is not null, '是', '否') 是否有播通的电话
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.parcel_additional_info pai on pai.pno = pi.customary_pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.ka_warehouse kw on kw.id = pi2.ka_warehouse_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.diaboloDuration') > 0
        group by 1
    ) p1 on p1.pno = pi.pno
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) p2 on p2.pno = pi.pno
where
    pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,pi.customary_pno 正向单号
    ,pai.cogs_amount/100 cogs
    ,pi2.cod_amount/100 cod
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,hsi.name 妥投员工
    ,hsi.hire_date 入职日期
    ,pi.client_id 客户ID
    ,kp.name 客户名称
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离妥投网点距离
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(kw.lng, kw.lat)) 距离仓库距离
    ,if(p1.pno is not null, '是', '否') 是否有拨打电话
    ,if(p2.pno is not null, '是', '否') 是否有播通的电话
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.parcel_additional_info pai on pai.pno = pi.customary_pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.ka_warehouse kw on kw.id = pi2.ka_warehouse_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.diaboloDuration') > 0
        group by 1
    ) p1 on p1.pno = pi.pno
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) p2 on p2.pno = pi.pno
where
    pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,pi.customary_pno 正向单号
    ,pai.cogs_amount/100 cogs
    ,oi.cogs_amount
    ,pi2.cod_amount/100 cod
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,hsi.name 妥投员工
    ,hsi.hire_date 入职日期
    ,pi.client_id 客户ID
    ,kp.name 客户名称
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离妥投网点距离
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(kw.lng, kw.lat)) 距离仓库距离
    ,if(p1.pno is not null, '是', '否') 是否有拨打电话
    ,if(p2.pno is not null, '是', '否') 是否有播通的电话
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.parcel_additional_info pai on pai.pno = pi.customary_pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.ka_warehouse kw on kw.id = pi2.ka_warehouse_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.diaboloDuration') > 0
        group by 1
    ) p1 on p1.pno = pi.pno
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) p2 on p2.pno = pi.pno
where
    pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,pi.customary_pno 正向单号
    ,pai.cogs_amount/100 cogs
    ,pi2.cod_amount/100 cod
    ,pi2.ka_warehouse_id
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,hsi.name 妥投员工
    ,hsi.hire_date 入职日期
    ,pi.client_id 客户ID
    ,kp.name 客户名称
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离妥投网点距离
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(kw.lng, kw.lat)) 距离仓库距离
    ,if(p1.pno is not null, '是', '否') 是否有拨打电话
    ,if(p2.pno is not null, '是', '否') 是否有播通的电话
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.parcel_additional_info pai on pai.pno = pi.customary_pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.ka_warehouse kw on kw.id = pi2.ka_warehouse_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.diaboloDuration') > 0
        group by 1
    ) p1 on p1.pno = pi.pno
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) p2 on p2.pno = pi.pno
where
    pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,pi.customary_pno 正向单号
    ,pai.cogs_amount/100 cogs
    ,pi2.cod_amount/100 cod
    ,oi.ka_warehouse_id

    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,hsi.name 妥投员工
    ,hsi.hire_date 入职日期
    ,pi.client_id 客户ID
    ,kp.name 客户名称
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离妥投网点距离
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(kw.lng, kw.lat)) 距离仓库距离
    ,if(p1.pno is not null, '是', '否') 是否有拨打电话
    ,if(p2.pno is not null, '是', '否') 是否有播通的电话
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.parcel_additional_info pai on pai.pno = pi.customary_pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.ka_warehouse kw on kw.id = pi2.ka_warehouse_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.diaboloDuration') > 0
        group by 1
    ) p1 on p1.pno = pi.pno
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) p2 on p2.pno = pi.pno
where
    pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,pi.customary_pno 正向单号
    ,pai.cogs_amount/100 cogs
    ,pi2.cod_amount/100 cod
    ,oi.ka_warehouse_id

    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,hsi.name 妥投员工
    ,hsi.hire_date 入职日期
    ,pi.client_id 客户ID
    ,kp.name 客户名称
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离妥投网点距离
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(pi2.ticket_pickup_staff_lng, pi2.ticket_pickup_staff_lat)) 距离仓库距离
    ,if(p1.pno is not null, '是', '否') 是否有拨打电话
    ,if(p2.pno is not null, '是', '否') 是否有播通的电话
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.parcel_additional_info pai on pai.pno = pi.customary_pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.ka_warehouse kw on kw.id = pi2.ka_warehouse_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.diaboloDuration') > 0
        group by 1
    ) p1 on p1.pno = pi.pno
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) p2 on p2.pno = pi.pno
where
    pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY');
;-- -. . -..- - / . -. - .-. -.--
select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 16:00:00'
            and prr.created_at < '2024-01-18 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2

union all

select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 16:00:00'
            and prr.created_at < '2024-01-18 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a2.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from ph_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join ph_staging.sys_store ss
    ) a1
cross join
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a2
join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 16:00:00'
            and prr.created_at < '2024-01-18 16:00:00'
    ) a3 on a3.store_id = a1.store_id and a3.client_id = a2.client_id
cross join
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5

union all


select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from ph_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from ph_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join ph_staging.sys_store ss
    ) a1
cross join
    (
        select
            *
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
cross join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from ph_staging.parcel_reject_report_info prr
        left join ph_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join ph_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 16:00:00'
            and prr.created_at < '2024-01-18 16:00:00'
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,pi.customary_pno 正向单号
    ,ss2.name 正向揽收网点
    ,ss3.name 正向妥投网点
    ,pai.cogs_amount/100 cogs
    ,pi2.cod_amount/100 cod
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,hsi.name 妥投员工
    ,hsi.hire_date 入职日期
    ,pi.client_id 客户ID
    ,kp.name 客户名称
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离妥投网点距离
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(pi2.ticket_pickup_staff_lng, pi2.ticket_pickup_staff_lat)) 距离仓库距离
    ,if(p1.pno is not null, '是', '否') 是否有拨打电话
    ,if(p2.pno is not null, '是', '否') 是否有播通的电话
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.parcel_additional_info pai on pai.pno = pi.customary_pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.ka_warehouse kw on kw.id = pi2.ka_warehouse_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi2.ticket_pickup_store_id
left join ph_staging.sys_store ss3 on ss3.id = pi2.ticket_delivery_store_id
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.diaboloDuration') > 0
        group by 1
    ) p1 on p1.pno = pi.pno
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) p2 on p2.pno = pi.pno
where
    pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,pi.customary_pno 正向单号
    ,ss2.name 正向揽收网点
    ,ss3.name 正向妥投网点
    ,pai.cogs_amount/100 cogs
    ,pi2.cod_amount/100 cod
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,hsi.name 妥投员工
    ,hsi.hire_date 入职日期
    ,pi.client_id 客户ID
    ,kp.name 客户名称
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离妥投网点距离
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(pi2.ticket_pickup_staff_lng, pi2.ticket_pickup_staff_lat)) 距离仓库距离
    ,if(p1.pno is not null, '是', '否') 是否有拨打电话
    ,if(p2.pno is not null, '是', '否') 是否有播通的电话
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.parcel_additional_info pai on pai.pno = pi.customary_pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.ka_warehouse kw on kw.id = pi2.ka_warehouse_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi2.ticket_pickup_store_id
left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.diaboloDuration') > 0
        group by 1
    ) p1 on p1.pno = pi.pno
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) p2 on p2.pno = pi.pno
where
    pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 单号
    ,pi.customary_pno 正向单号
    ,ss2.name 正向揽收网点
    ,ss.name 退件妥投网点
    ,pai.cogs_amount/100 cogs
    ,pi2.cod_amount/100 cod
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,hsi.name 妥投员工
    ,hsi.hire_date 入职日期
    ,pi.client_id 客户ID
    ,kp.name 客户名称
    ,pi.exhibition_weight 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离妥投网点距离
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(pi2.ticket_pickup_staff_lng, pi2.ticket_pickup_staff_lat)) 距离仓库距离
    ,if(p1.pno is not null, '是', '否') 是否有拨打电话
    ,if(p2.pno is not null, '是', '否') 是否有播通的电话
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join ph_staging.parcel_additional_info pai on pai.pno = pi.customary_pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.ka_warehouse kw on kw.id = pi2.ka_warehouse_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi2.ticket_pickup_store_id
# left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.diaboloDuration') > 0
        group by 1
    ) p1 on p1.pno = pi.pno
left join
    (
        select
            pi.pno
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < pi.finished_at
            and pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY')
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) p2 on p2.pno = pi.pno
where
    pi.pno in ('P61012NEHG3FY','P61012NDNC4FY','P61012NEGYYFY','P61012NDBE2FY','P61012NEGK1FY','P61012NDBY1FY','P61012NE4F3FY','P61012MYZFVFY','P61012MX6TBFY','P61012MY2TNFY','P61012KPMZSFY','P61012NDHP6FY','P61012KPMXJFY','P61012KPG2XFY','P61012NE47XFY','P61012KNVAJFY','P61012KNU1PFY','P61012KPW08FY','P61012KNRMBFY','P61012KNND5FY','P61012KNXNAFY','P61012KNBU1FY','P61012KZKY3FY','P61012KMZ5UFY','P61012K45E3FY','P61012JKD61FY','P61012MMX8MFY','P61012K2Z4WFY','P61012K20MUFY','P61012K25GKFY','P61012K2BCEFY','P61012JT0HEFY','P61012MVWDKFY','P61012KQ739FY','P61012KBYFJFY','P61012KACGVFY','P61012KAZVQFY','P61012HGUHCFY','P61012JGP0YFY','P61012H40FRFY','P61012JF6SYFY','P61012H3AZMFY','P61012KMJYJFY','P61012KNBQHFY','P61012MSRXWFY','P61012MAD44FY','P61012MB3PCFY','P61012MA3SZFY','P61012MBYCAFY','P61012MBZV5FY','P61012MACSDFY','P61012MAN9UFY','P61012MAS6CFY','P61012M99W3FY','P61012MBB47FY','P61012MB0W4FY','P61012MBJ0PFY','P61012MAE6HFY','P61012MBA3SFY','P61012MBBZXFY','P61012MB8GNFY','P61012MB1F3FY','P61012MA91AFY','P61012MBG9QFY','P61012MB8ZYFY','P61012MBBEPFY','P61012MAYC0FY','P61012M95TUFY','P61012MB4UHFY','P61012MBE5RFY','P61012MAZZGFY','P61012MBV9UFY','P61012MBAV0FY','P61012KPW9BFY','P61012KAH9DFY','P61012KZZYWFY','P61012KQ2UHFY','P61012KZWEFFY','P61012K2R15FY','P61012JTCVYFY','P61012JG1P3FY','P61012MB449FY','P61012K5G35FY','P61012KP0ZWFY','P61012KZWAHFY','P61012MA2ZFFY','P61012K2ZEEFY','P61012KARPYFY','P61012MAZDMFY','P61012MAFXMFY','P61012JH18EFY','P61012J5UEXFY','P61012HFREZFY','P61012J4SFFFY','P61012HGBQAFY','P61012HJQZ2FY','P61012GKBZYFY','P61012GK2S7FY','P61012H30ZEFY','P61012FXXUEFY','P61012HDMA3FY','P61012K4DV3FY','P61012GN35WFY','P61012GKA8BFY','P61012H29FEFY','P61012GVXQKFY','P61012H5KRXFY','P61012HWUPVFY','P61012KANGYFY','P61012GJM7SFY','P61012GK4HUFY','P61012GK6JVFY','P61012JH9UNFY','P61012G04EMFY','P61012MYNYJFY','P61012MMQ3NFY','P61012H2EXMFY','P61012MMP0SFY','P61012MP1VHFY','P61012MYKEVFY','P61012M96SVFY','P61012KPWHXFY','P61012JGD9ZFY','P61012MN71EFY','P61012J4E16FY','P61012JH1ASFY','P61012JD99KFY','P61012JFC47FY','P61012H3Q9WFY','P61012J7VQ6FY');
;-- -. . -..- - / . -. - .-. -.--
select
    date(a.wo_at) 工单创建日期
    ,datediff(a.wo_at, a.plt_at) 工单发起时任务生成天数
    ,a.created_staff_info_id 工单发起人
    ,count(distinct a.id) 任务数
from
    (
        select
            plt.created_at plt_at
            ,wo.created_at wo_at
            ,plt.id
            ,wo.created_staff_info_id
            ,row_number() over (partition by plt.id order by wo.created_at) rk
        from ph_bi.parcel_lose_task plt
        join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        where
            plt.source = 3
            and plt.created_at >= '2023-11-01'
            and plt.created_at < '2023-12-01'
    ) a
where
    a.rk = 1
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when a1.time_diff/60 <= 24 then '24小时内'
        when a1.time_diff/60 > 24 and a1.time_diff/60 <= 48 then '24-48小时内'
        when a1.time_diff/60 > 48 and a1.time_diff/60 <= 72 then '48-72小时内'
        when a1.time_diff/60 > 72 then '72小时以上'
    end  时间差
    ,count(distinct a1.id) 任务数
from
    (
        select
            timestampdiff(minute, a.plt_at, a.operate_at) time_diff
            ,a.id
        from
            (
                select
                    plt.id
                    ,plt.created_at plt_at
                    ,pcol.action
                    ,pcol.operator_id
                    ,pcol.created_at operate_at
                    ,row_number() over (partition by plt.id order by pcol.created_at) rk
                from ph_bi.parcel_lose_task plt
                join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
                where
                    plt.source = 3
                    and plt.created_at >= '2023-11-01'
                    and plt.created_at < '2023-12-01'
                    and pcol.action in (3,4)
            ) a
        where
            a.rk = 1
            and a.operator_id in (10000,10001)
            and a.action = 3
    ) a1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
                    plt.id
                    ,plt.created_at plt_at
                    ,pcol.action
                    ,pcol.operator_id
                    ,pcol.created_at operate_at
                    ,row_number() over (partition by plt.id order by pcol.created_at) rk
                from ph_bi.parcel_lose_task plt
                join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
                where
                    plt.source = 3
                    and plt.created_at >= '2023-11-01'
                    and plt.created_at < '2023-12-01'
                    and pcol.action in (3,4);
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when a1.time_diff/60 <= 24 then '24小时内'
        when a1.time_diff/60 > 24 and a1.time_diff/60 <= 48 then '24-48小时内'
        when a1.time_diff/60 > 48 and a1.time_diff/60 <= 72 then '48-72小时内'
        when a1.time_diff/60 > 72 then '72小时以上'
    end  时间差
    ,count(distinct a1.id) 任务数
from
    (
        select
            timestampdiff(minute, a.plt_at, a.operate_at) time_diff
            ,a.id
        from
            (
                select
                    plt.id
                    ,plt.created_at plt_at
                    ,pcol.action
                    ,pcol.operator_id
                    ,pcol.created_at operate_at
                    ,row_number() over (partition by plt.id order by pcol.created_at) rk
                from ph_bi.parcel_lose_task plt
                join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
                where
                    plt.source = 3
                    and plt.created_at >= '2023-11-01'
                    and plt.created_at < '2023-12-01'
                    and pcol.action in (3,4)
            ) a
        where
            a.rk = 1
            and a.operator_id in (10000,10001)
            and a.action = 3

        union

        select
            timestampdiff(minute, plt.created_at, plt.updated_at) time_diff
            ,plt.id
        from ph_bi.parcel_lose_task plt
        where
            plt.source = 3
            and plt.created_at >= '2023-11-01'
            and plt.created_at < '2023-12-01'
            and plt.operator_id in (10000,10001)
            and plt.state = 5
    ) a1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from ph_staging.parcel_info pi
left join ph_bi.parcel_detail pd on pd.pno = pi.pno
where
    pi.state = 8
    and pi.discard_enabled = 0
    and pd.last_valid_store_id != 'PH19040F05';
;-- -. . -..- - / . -. - .-. -.--
select
    pud.pno 运单号
    ,pi.pack_no 集包号
    ,convert_tz(pi.seal_at, '+00:00', '+07:00') 集包时间
    ,convert_tz(pi.unseal_at, '+00:00', '+07:00') 拆包时间
    ,pi.seal_staff_info_id 操作集包员工
    ,pi.unseal_staff_info_id 操作拆包员工
    ,pi.seal_store_name 集包始发网点
    ,pi.es_unseal_store_name 集包目的地网点
from ph_staging.pack_info pi
left join ph_staging.pack_unseal_detail pud on pi.pack_no = pud.pack_no
where
    pi.unseal_at < date_sub(curdate(), interval 8 hour )
    and pi.unseal_at >= date_sub(curdate(), interval 32 hour )
    and pi.unseal_count < pi.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.returned_pno
from ph_staging.parcel_info pi
where
    pi.pno in ('Shopee','P190538VU30BO','P190538YTXQBO','P190538P24HAO','P190538P22PAO','P1905382YUAAO','P190538PFCRBO','P450634AZR4BH','P1905390XQKAU','P1217398AX3AD','P011739CPG9AX','P7719323M58AN','P61203862MPGO','P1905399HAABX','P190539PRT7BO','P190539XVBQBW','P18063BE3VKAH','P18063B50UJAH','P47123D6MRKBA','P611035MYAXAX','P122135YHVWBQ','P122136D5XWBM','P611036W6KJBS','P2113372TU6AD','P122137E1D9AP','P030938FJ69AN','P6118397Z5JET','P181839V64XAV','P04303AAN3XAG','P611535KMJWBA','P110435N0B8AZ','P612335Q6YAAK','P6123363T5VAH','P210536ZU65AA','P18083733YNAO','P2105373BGDAA','P011239R9MWAG','P61033BEVQSAP','P1320372A4AAN','P1803372CXNAZ','P041237MJ16AI','P1928381TA1AH','P6116383XMMAB','P122338FHHTAL','P612438Y8XQAK','P21023B4PCUAD','P21023B6DDTAD','P61273BGQ9AAD','P4909340EYMAM','P171037926QAN','P120337MDKBAB','P122137MJ38AP','P121038VJZYBH','P1222391X86BC','P7909372A4BAI','P641137NCAHAD','P610237NGUVAE','P612138U8DZAS','P1210390RBRBD','P1206391X72AA','P03053BCMXABB','P61143BZDFZCT','P351739X8NDBG','P660638BJ8EAH','P6123399DJNAH','P611839DVM0EO','P612339EWR9AH','P120839K98NAF','P271535C1B4AQ','P420435MHV6AB','P242335QCXVBD','P5303360W1GAZ','P5302362A49CS','P3517365V9ZBH','P230336HJFVAT','P230336HJK4AT','P2815370YZ8AB','P800537MDJZAS','P110737MJ35AE','P353037NC9XAV','P33013813AGBX','P3514381DTDAA','P0703382T9JAD','P0619387HE0AG','P353038YTXCBA','P6125399H9GAV','P190539CF8PAK','P151839CSVQAI','P613039DFQKAI','P073139EE3FAV','P210239ET2PAD','P301039ET9BAV','P131239NVDEAM','P081339PW6QAH','P122139QAY9BQ','P190839X7KWAD','P612339XN0BAK','P611839YEP2BO','P611839YEQADR','P61183A5Z1ABK','P12223ARPX1AB','P12123ARPX7AX','P121136CEP9AB','P170535VUWHAD','P200437Y9NWAW','P210536AA5EAA','P230337WJZQAT','P230337WKH2AT','P210532TQF4AC','P500933J4KZAA','P21053525T4AA','P191935VUTWAE','P210234PMTZAF','P210438WCC0BI','P073735D2EEAZ','P242534PMV7AC','P2303399PUAAT','P231038FFEJAN','P0608324A0WAP','P020735A7QCAG','P650435W3JWAD','P64023BSV8GDA','P35263CWSSBAF','P61013CW8KCCR','P640238D161AD','P3521324A09AP','P612536EA35AO','P35373BW6ASAC','P19033CARXNAD','P17052YAHRRBE','P211336M9PJAD','P2105397790AA','P612038D11BBB','P611439PYUNBF','P041139X6GFBV','P210838D14AAE','P6130360PP1AA','P510636APM3AQ','P18063E8CJPAA');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.returned_pno
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
from ph_staging.parcel_info pi
where
    pi.pno in ('Shopee','P190538VU30BO','P190538YTXQBO','P190538P24HAO','P190538P22PAO','P1905382YUAAO','P190538PFCRBO','P450634AZR4BH','P1905390XQKAU','P1217398AX3AD','P011739CPG9AX','P7719323M58AN','P61203862MPGO','P1905399HAABX','P190539PRT7BO','P190539XVBQBW','P18063BE3VKAH','P18063B50UJAH','P47123D6MRKBA','P611035MYAXAX','P122135YHVWBQ','P122136D5XWBM','P611036W6KJBS','P2113372TU6AD','P122137E1D9AP','P030938FJ69AN','P6118397Z5JET','P181839V64XAV','P04303AAN3XAG','P611535KMJWBA','P110435N0B8AZ','P612335Q6YAAK','P6123363T5VAH','P210536ZU65AA','P18083733YNAO','P2105373BGDAA','P011239R9MWAG','P61033BEVQSAP','P1320372A4AAN','P1803372CXNAZ','P041237MJ16AI','P1928381TA1AH','P6116383XMMAB','P122338FHHTAL','P612438Y8XQAK','P21023B4PCUAD','P21023B6DDTAD','P61273BGQ9AAD','P4909340EYMAM','P171037926QAN','P120337MDKBAB','P122137MJ38AP','P121038VJZYBH','P1222391X86BC','P7909372A4BAI','P641137NCAHAD','P610237NGUVAE','P612138U8DZAS','P1210390RBRBD','P1206391X72AA','P03053BCMXABB','P61143BZDFZCT','P351739X8NDBG','P660638BJ8EAH','P6123399DJNAH','P611839DVM0EO','P612339EWR9AH','P120839K98NAF','P271535C1B4AQ','P420435MHV6AB','P242335QCXVBD','P5303360W1GAZ','P5302362A49CS','P3517365V9ZBH','P230336HJFVAT','P230336HJK4AT','P2815370YZ8AB','P800537MDJZAS','P110737MJ35AE','P353037NC9XAV','P33013813AGBX','P3514381DTDAA','P0703382T9JAD','P0619387HE0AG','P353038YTXCBA','P6125399H9GAV','P190539CF8PAK','P151839CSVQAI','P613039DFQKAI','P073139EE3FAV','P210239ET2PAD','P301039ET9BAV','P131239NVDEAM','P081339PW6QAH','P122139QAY9BQ','P190839X7KWAD','P612339XN0BAK','P611839YEP2BO','P611839YEQADR','P61183A5Z1ABK','P12223ARPX1AB','P12123ARPX7AX','P121136CEP9AB','P170535VUWHAD','P200437Y9NWAW','P210536AA5EAA','P230337WJZQAT','P230337WKH2AT','P210532TQF4AC','P500933J4KZAA','P21053525T4AA','P191935VUTWAE','P210234PMTZAF','P210438WCC0BI','P073735D2EEAZ','P242534PMV7AC','P2303399PUAAT','P231038FFEJAN','P0608324A0WAP','P020735A7QCAG','P650435W3JWAD','P64023BSV8GDA','P35263CWSSBAF','P61013CW8KCCR','P640238D161AD','P3521324A09AP','P612536EA35AO','P35373BW6ASAC','P19033CARXNAD','P17052YAHRRBE','P211336M9PJAD','P2105397790AA','P612038D11BBB','P611439PYUNBF','P041139X6GFBV','P210838D14AAE','P6130360PP1AA','P510636APM3AQ','P18063E8CJPAA');
;-- -. . -..- - / . -. - .-. -.--
select
    pud.pno 运单号
    ,pi.pack_no 集包号
    ,convert_tz(pi.seal_at, '+00:00', '+08:00') 集包时间
    ,convert_tz(pi.unseal_at, '+00:00', '+08:00') 拆包时间
    ,pi.seal_staff_info_id 操作集包员工
    ,pi.unseal_staff_info_id 操作拆包员工
    ,pi.seal_store_name 集包始发网点
    ,pi.es_unseal_store_name 集包目的地网点
from ph_staging.pack_info pi
left join ph_staging.pack_unseal_detail pud on pi.pack_no = pud.pack_no
where
    pi.unseal_at < date_sub(curdate(), interval 8 hour )
    and pi.unseal_at >= date_sub(curdate(), interval 32 hour )
    and pi.unseal_count < pi.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno 运单号
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 换单时间
    ,pr.staff_info_id 员工
    ,if(swa.started_at is not null and swa.end_at is not null, '否', '是') 员工是否有打卡记录
    ,if(hst.staff_info_id is not null, '是', '否') 员工近一周是否停职
    ,case
        when hsi.state = 1 and hsi.wait_leave_state = 0 then '在职'
        when hsi.state = 1 and hsi.wait_leave_state = 1 then '待离职'
        when hsi.state = 2 then '离职'
        when hsi.state = 3 then '停职'
    end 员工状态
    ,case
        when bc.client_name = 'lazada' then pi2.insure_declare_value/100
        when bc.client_name is not null and bc.client_name != 'lazada' then pai.cogs_amount/100
        when bc.client_name is null and pai.cogs_amount is not null then pai.cogs_amount/100
        when bc.client_name is null and pai.cogs_amount is null then pi2.cod_amount/100
        else null
    end 包裹价值
from ph_staging.parcel_route pr
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = pr.staff_info_id and swa.attendance_date = date_sub(curdate(), interval 1 day)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1,pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join
    (
        select
            hst.staff_info_id
        from ph_bi.hr_staff_transfer hst
        where
            hst.stat_date <= date_sub(curdate(), interval 1 day )
            and hst.stat_date >= date_sub(curdate(), interval 6 day )
            and hst.state = 3
        group by 1
    ) hst on hst.staff_info_id = pr.staff_info_id
where
    pr.route_action = 'REPLACE_PNO'
    and pr.routed_at < date_sub(curdate(), interval 8 hour )
    and pr.routed_at >= date_sub(curdate(), interval 32 hour )
    and
    (
        (swa.started_at is null and swa.end_at is null)
        or ( hsi.state = 1 and hsi.wait_leave_state = 1)
        or hst.staff_info_id is not null
        or ( if(bc.client_name = 'lazada', pi2.insure_declare_value, pai.cogs_amount)) > 500000
        or pi2.cod_amount > 500000
    );
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
            ,case
                when bc.client_name = 'lazada' then pi2.insure_declare_value/100
                when bc.client_name is not null and bc.client_name != 'lazada' then pai.cogs_amount/100
                when bc.client_name is null and pai.cogs_amount is not null then pai.cogs_amount/100
                when bc.client_name is null and pai.cogs_amount is null then pi2.cod_amount/100
                else null
            end parcel_value
            ,pr.staff_info_id
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') scan_at
            ,pr.store_name
        from ph_staging.parcel_route pr
        left join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1,pi.customary_pno, pi.pno)
        left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        left join ph_staging.parcel_problem_detail ppd on ppd.pno = pr.pno and ppd.created_at >= date_sub(curdate(), interval 32 hour) and ppd.created_at < date_sub(curdate(), interval 8 hour )
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at < date_sub(curdate(), interval 8 hour )
            and pr.routed_at >= date_sub(curdate(), interval 32 hour )
            and (( if(bc.client_name = 'lazada', pi2.insure_declare_value, pai.cogs_amount)) > 500000 or  pi2.cod_amount > 500000)
            and ppd.pno is null
    )
select
    t1.pno 运单号
    ,t1.parcel_value 包裹价值
    ,t1.staff_info_id 交接员工
    ,t1.scan_at 交接时间
    ,t1.store_name 网点
    ,a1.CN_element 最后有效路由
    ,convert_tz(a1.routed_at, '+00:00', '+08:00') 最后有效路由时间
from t t1
left join
    (
        select
            ddd.CN_element
            ,pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join ( select t1.pno from t t1 group by 1) t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 1 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a1 on a1.pno = t1.pno and a1.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    p.pno
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
    end as 包裹状态
    ,p.staff_info_id 最后操作改约的工号
    ,convert_tz(p.routed_at, '+00:00', '+08:00') 操作改约时间
    ,p.store_name  网点
from ph_staging.parcel_info pi
join
    (

        select
            p1.*
            ,row_number() over (partition by p1.pno order by p1.routed_at desc) rk
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.routed_at
                    ,pr.staff_info_id
                from ph_staging.parcel_route pr
                left join ph_staging.parcel_info pi on pi.pno = pr.pno
                left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1,pi.customary_pno, pi.pno)
                left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
                left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                where
                    pr.route_action = 'DELIVERY_MARKER'
                    and pr.routed_at < date_sub(curdate(), interval 8 hour )
                    and pr.routed_at >= date_sub(curdate(), interval 32 hour )
                    and pr.marker_category = 70
                    and ((if(bc.client_name = 'lazada', pi2.insure_declare_value, pai.cogs_amount)) > 500000 or  pi2.cod_amount > 500000)

            ) p1
        join
            (
                select
                    pr.pno
                from ph_staging.parcel_route pr
                where
                    pr.route_action = 'DELIVERY_MARKER'
                    and pr.routed_at < date_sub(curdate(), interval 32 hour )
                    and pr.routed_at >= date_sub(curdate(), interval 56 hour )
                    and pr.marker_category = 70
                group by 1
            ) p2 on p2.pno = p1.pno
        join
            (
                select
                    pr.pno
                from ph_staging.parcel_route pr
                where
                    pr.route_action = 'DELIVERY_MARKER'
                    and pr.routed_at < date_sub(curdate(), interval 56 hour )
                    and pr.routed_at >= date_sub(curdate(), interval 80 hour )
                    and pr.marker_category = 70
                group by 1
            ) p3 on p3.pno = p1.pno
    ) p on p.pno = pi.pno and p.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            a.pno
            ,a.staff_info_id
            ,a.store_name
        from
            (
                select
                    p1.*
                    ,row_number() over (partition by p1.pno order by p1.routed_at desc) rk
                from
                    (
                        select
                            pr.pno
                            ,pr.store_name
                            ,pr.routed_at
                            ,pr.staff_info_id
                        from ph_staging.parcel_route pr
                        left join ph_staging.parcel_info pi on pi.pno = pr.pno
                        left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1,pi.customary_pno, pi.pno)
                        left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                        where
                            pr.route_action = 'INVENTORY'
                            and pr.routed_at < date_sub(curdate(), interval 8 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 32 hour )
                            and ((if(bc.client_name = 'lazada', pi2.insure_declare_value, pai.cogs_amount)) > 500000 or  pi2.cod_amount > 500000)
                    ) p1
                join
                    (
                        select
                            pr.pno
                        from ph_staging.parcel_route pr
                        where
                            pr.route_action = 'INVENTORY'
                            and pr.routed_at < date_sub(curdate(), interval 32 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 56 hour )
                        group by 1
                    ) p2 on p2.pno = p1.pno
                join
                    (
                        select
                            pr.pno
                        from ph_staging.parcel_route pr
                        where
                            pr.route_action = 'INVENTORY'
                            and pr.routed_at < date_sub(curdate(), interval 56 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 80 hour )
                        group by 1
                    ) p3 on p3.pno = p1.pno
                left join
                    (
                        select
                            pr.pno
                        from ph_staging.parcel_route pr
                        where
                            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                            and pr.routed_at < date_sub(curdate(), interval 8 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 80 hour )
                        group by 1
                    ) p on p.pno = p1.pno
                where
                    p.pno is null
            ) a
        where
            a.rk = 1
    )
select
    t1.pno 运单号
    ,t1.staff_info_id 最后操作盘库员工
    ,t1.store_name  最后操作盘库的网点
    ,pr.CN_element 最后有效路由（非盘库）
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后有效路由时间
from t t1
left join
    (
        select
            ddd.CN_element
            ,pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on pr.pno = t1.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(curdate(), interval 1 month)
    ) pr on pr.pno = t1.pno and pr.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pud.pno 运单号
    ,pi.pack_no 集包号
    ,convert_tz(pi.seal_at, '+00:00', '+08:00') 集包时间
    ,convert_tz(pi.unseal_at, '+00:00', '+08:00') 拆包时间
    ,pi.seal_staff_info_id 操作集包员工
    ,pi.unseal_staff_info_id 操作拆包员工
    ,pi.seal_store_name 集包始发网点
    ,pi.es_unseal_store_name 集包目的地网点
from ph_staging.pack_info pi
join ph_staging.pack_unseal_detail pud on pi.pack_no = pud.pack_no
where
    pi.unseal_at < date_sub(curdate(), interval 8 hour )
    and pi.unseal_at >= date_sub(curdate(), interval 32 hour )
    and pi.unseal_count < pi.seal_count;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            a.pno
            ,a.staff_info_id
            ,a.store_name
        from
            (
                select
                    p1.*
                    ,row_number() over (partition by p1.pno order by p1.routed_at desc) rk
                from
                    (
                        select
                            pr.pno
                            ,pr.store_name
                            ,pr.routed_at
                            ,pr.staff_info_id
                        from ph_staging.parcel_route pr
                        left join ph_staging.parcel_info pi on pi.pno = pr.pno
                        left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1,pi.customary_pno, pi.pno)
                        left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                        where
                            pr.route_action = 'INVENTORY'
                            and pr.routed_at < date_sub(curdate(), interval 8 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 32 hour )
                            and ((if(bc.client_name = 'lazada', pi2.insure_declare_value, pai.cogs_amount)) > 500000 or  pi2.cod_amount > 500000)
                    ) p1
                join
                    (
                        select
                            pr.pno
                        from ph_staging.parcel_route pr
                        where
                            pr.route_action = 'INVENTORY'
                            and pr.routed_at < date_sub(curdate(), interval 32 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 56 hour )
                        group by 1
                    ) p2 on p2.pno = p1.pno
                join
                    (
                        select
                            pr.pno
                        from ph_staging.parcel_route pr
                        where
                            pr.route_action = 'INVENTORY'
                            and pr.routed_at < date_sub(curdate(), interval 56 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 80 hour )
                        group by 1
                    ) p3 on p3.pno = p1.pno
                left join
                    (
                        select
                            pr.pno
                        from ph_staging.parcel_route pr
                        where
                            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                            and pr.routed_at < date_sub(curdate(), interval 8 hour )
                            and pr.routed_at >= date_sub(curdate(), interval 80 hour )
                        group by 1
                    ) p on p.pno = p1.pno
                where
                    p.pno is null
            ) a
        where
            a.rk = 1
    )
select
    t1.pno 运单号
    ,t1.staff_info_id 最后操作盘库员工
    ,t1.store_name  最后操作盘库的网点
    ,pr.CN_element 最后有效路由（非盘库）
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后有效路由时间
from t t1
left join
    (
        select
            ddd.CN_element
            ,pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on pr.pno = t1.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(curdate(), interval 1 month)
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on pr.pno = t1.pno
        where
            pr.route_action = 'REFUND_CONFIRM'
            and pr.routed_at > date_sub(curdate(), interval 1 month)
        group by 1
    ) hol on hol.pno = t1.pno
where
    hol.pno is null;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from ph_staging.parcel_info pi
left join ph_staging.parcel_additional_info pai on pai.pno = pi.pno
left join ph_bi.parcel_detail pd on pd.pno = pi.pno
where
    pi.state = 8
    and pai.parcel_miss_enabled = 0
    and pd.last_valid_store_id != 'PH19040F05';