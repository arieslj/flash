select
    a1.pno 运单号
    ,a1.store_name 揽收网点
    ,a1.client_id 客户ID
    ,a1.src_name 寄件人
    ,a1.pr_date 路由操作日期
    ,oi.cod_amount/100 COD
    ,case a1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 当前状态
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) COGS
    ,count(distinct a1.route_action) 同一天内操作次数大于1的路由个数
    ,group_concat(concat( ddd.CN_element, '*', pr_cnt)) 路由备注
from
    (
        select
            pi.pno
            ,pi.client_id
            ,pi.src_name
            ,pr.route_action
            ,pr.store_name
            ,pi.state
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,count(pr.id) pr_cnt
        from ph_staging.parcel_info pi
        join ph_staging.parcel_route pr on pr.pno = pi.pno and pi.ticket_pickup_store_id = pr.store_id
        where
            pi.created_at > '2024-11-26 16:00:00'
            and pr.routed_at > '2024-11-26 16:00:00'
            and pi.returned = 0
            and pi.state < 9
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
        group by 1,2,3,4,5,6,7
        having count(pr.id) > 1
    ) a1
left join ph_staging.order_info oi on oi.pno = a1.pno and oi.created_at > '2024-10-01'
left join dwm.dwd_dim_bigClient bc on bc.client_id = a1.client_id
left join dwm.dwd_dim_dict ddd on ddd.element = a1.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
group by 1,2,3,4,5,6,7,8
having count(distinct a1.route_action) > 1