with t as
    (
        select
            awp.pno
            ,pr.store_name
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from my_staging.accum_whatsapp_push_callback_logs awp
        left join my_staging.parcel_route pr on pr.pno = awp.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(curdate(), interval 1 month )
            and awp.created_at > '2024-05-10'
    )
select
    awp.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,pi.client_id
    ,pi.cod_amount/100 COD金额
    ,t1.store_name 包裹当前所在网点
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
    end 当前状态
    ,case awp.btn_type
        when 1 then '丢弃'
        when 0 then '没有点击'
        when 2 then '继续派送'
    end 是否还需要包裹
from my_staging.parcel_info pi
join my_staging.accum_whatsapp_push_callback_logs awp on awp.pno = pi.pno
left join my_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join t t1 on t1.pno = pi.pno and t1.rk = 1
where
    awp.created_at > '2024-05-10'


