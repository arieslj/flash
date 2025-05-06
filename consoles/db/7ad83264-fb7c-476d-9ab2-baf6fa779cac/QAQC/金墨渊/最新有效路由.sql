select
    a.pno 运单号
    ,a.CN_element 最后一步有效路由
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 操作时间
    ,a.store_name 操作网点
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
from
    (
        select
            t.pno
            ,ddd.CN_element
            ,pr.routed_at
            ,pr.store_name
            ,row_number() over(partition by t.pno order by pr.routed_at desc) as rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0828 t on t.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > '2024-01-01'
            and pr.route_action in ('ARRIVAL_GOODS_VAN_CHECK_SCAN' ,'RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')

    ) a
left join ph_staging.parcel_info pi on pi.pno = a.pno
where
    a.rk = 1

;

select
    min(ps.arrive_dst_route_at)
from ph_bi.parcel_sub ps
where
    ps.arrive_dst_route_at > '1970-01-01 00:00:00'