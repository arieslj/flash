with t as
    (
        select
            ps.pno
            ,ps.arrive_dst_store_id
            ,datediff(curdate(), ps.arrive_dst_route_at) stay_days
            ,cdt.vip_enable
            ,cdt.client_id
            ,cdt.organization_type
            ,cdt.service_type
        from bi_center.parcel_sub ps
        join fle_staging.diff_info di on di.pno = ps.pno
        join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        where
            datediff(curdate(), ps.arrive_dst_route_at) > 3
            and di.state = 0
            and di.created_at > date_sub(curdate(), interval 2 month)
            and ps.arrive_dst_route_at > '1970-01-01 00:00:00'
)
select
    t1.pno
    ,t1.stay_days 滞留时长
    ,convert_tz(t2.routed_at, '+00:00', '+07:00') 第一次抵达目的地网点时间
    ,convert_tz(t3.routed_at, '+00:00', '+07:00') 最后一次在目的地网点更新有效路由的时间
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
    end as 运单状态
    ,ddd.CN_element 最后有效路由
    ,if(t1.vip_enable = 1, 'y', 'n') 是否KAM客户
    ,t1.client_id 客户ID
    ,oi.cod_amount/100 COD金额
    ,pi.exhibition_weight/1000 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) size
    ,sd.name 客户归属部门
    ,case
        when t1.organization_type = 2 and t1.vip_enable = 0 and t1.service_type != 4 then '总部客服'
        when t1.organization_type = 2 and t1.vip_enable = 1 and t1.service_type = 4 then 'QAQC'
        when t1.organization_type = 2 and t1.vip_enable = 1 then 'KAM'
        when t1.organization_type = 1 and t1.vip_enable = 0 and t1.service_type = 3 then 'FH'
        when t1.organization_type = 1 and (t1.service_type != 3 or t1.service_type is null) and t1.vip_enable = 0 then 'minics'
    end 处理部门
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.arrive_dst_store_id = pr.store_id
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) t2 on t1.pno = t2.pno and t2.rk = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.arrive_dst_store_id = pr.store_id
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) t3 on t1.pno = t3.pno and t3.rk = 1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join fle_staging.ka_profile kp on kp.id = t1.client_id
left join fle_staging.sys_department sd on sd.id = kp.department_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) t4 on t1.pno = t4.pno and t4.rk = 1
left join dwm.dwd_dim_dict ddd on ddd.element = t4.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
