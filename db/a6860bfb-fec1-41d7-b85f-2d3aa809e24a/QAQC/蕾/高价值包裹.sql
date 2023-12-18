with t as
    (
        select
            pi.pno
            ,pi.cod_amount/100 cod
            ,pi.created_at
        from ph_staging.parcel_info pi
        where
            pi.created_at > date_sub(curdate(), interval 3 month )
            and pi.state not in (5,7,8,9)
            and pi.cod_amount > 200000
            and pi.returned = 0

        union all

        select
            pi2.pno
            ,pi3.cod_amount/100 cod
            ,pi3.created_at
        from ph_staging.parcel_info pi2
        join ph_staging.parcel_info pi3 on pi3.returned_pno = pi2.pno and pi3.created_at > date_sub(curdate(), interval 100 day)
        where
            pi2.state not in (5,7,8,9)
            and pi2.returned = 1
            and pi3.cod_amount > 200000
            and pi2.created_at > date_sub(curdate(), interval 3 month )
    )
select
    convert_tz(t.created_at, '+00:00', '+08:00') 'Pick up date'
    ,concat(kp.id, '-', kp.name) Customer
    ,t.pno 'Tracking number'
    ,ss_pick.name 'Pickup branch'
    ,pi.ticket_pickup_staff_info_id 'Pickup courier'
    ,ss_dst.name 'Destination branch'
    ,t.cod as 'COD_AMOUNT'
    ,pi.exhibition_weight/1000 'Weight/kg'
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
    end 'Status'
    ,pi.src_name Seller
    ,pi.src_phone 'Seller number'
    ,pi.dst_name Consignee
    ,pi.dst_phone 'Consignee number'
    ,sp.name 'Consignee province'
    ,sc.name 'Consignee city'
    ,sd.name 'Consignee barangay'
    ,datediff(curdate(), ps.first_valid_routed_at) days
    ,las.EN_element 'Last operation'
    ,convert_tz(las.routed_at, '+00:00', '+08:00') 'Operation time'
    ,las.store_name 'Operator hub'
    ,las.staff_info_id 'Operator'
    ,scan.scan_count Handover
    ,res.scan_count Reschedule
    ,if(cal.pno is not null, 'yes', 'no') 'Call record'
from ph_staging.parcel_info pi
join t on t.pno = pi.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join ph_staging.sys_store ss_pick on ss_pick.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss_dst on ss_dst.id = pi.dst_store_id
left join ph_staging.sys_province sp on sp.code = pi.dst_province_code
left join ph_staging.sys_city sc on sc.code = pi.dst_city_code
left join ph_staging.sys_district sd on sd.code = pi.dst_district_code
left join
    (-- 包裹最新网点
        select
            pssn.*
            ,row_number() over (partition by pssn.pno order by pssn.valid_store_order) rk
        from dw_dmd.parcel_store_stage_new pssn
        join t on t.pno = pssn.pno
        where
            pssn.created_at > date_sub(curdate(), interval 3 month )
    ) ps on ps.pno = t.pno and ps.rk = 1
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
    ) las on las.pno = t.pno and las.rk = 1
left join
    (-- 交接扫描次数
        select
            pr.pno
            ,count(pr.id) scan_count
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 3 month )
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
        group by 1
    ) scan on scan.pno = t.pno
left join
    ( -- 改约次数
        select
            pr.pno
            ,count(pr.id) scan_count
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 3 month )
            and pr.route_action = 'DELIVERY_MARKER' -- 派件标记
            and pr.marker_category  in (9,14,70) -- 改约时间
        group by 1
    ) res on res.pno = t.pno
left join
    ( --   电话
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 3 month )
            and pr.route_action in ('PHONE', 'INCOMING_CALL')
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) cal on cal.pno = t.pno
where
    pi.created_at > date_sub(curdate(), interval 3 month )
