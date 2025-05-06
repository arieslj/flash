with t as
    (
        select
            plt.pno
            ,plt.parcel_created_at
            ,plt.client_id
            ,plt.updated_at
            ,date_sub(plt.updated_at, interval 8 hour)  updated_time
        from my_bi.parcel_lose_task plt
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
        where
            bc.client_id is null
            and plt.parcel_created_at > '2024-01-01'
            and plt.parcel_created_at < '2024-06-01'
            and plt.state = 6
            and plt.duty_result = 1
        group by 1,2,3,4
    )
select
    t1.pno
    ,t1.client_id 客户ID
    ,if(kp.id is not null, 'KA', '小C')  客户类型
    ,case pi.returned
        when 0 then '正向'
        when 1 then '退件'
    end 包裹流向
    ,case pi.cod_enabled
        when 0 then '否'
        when 1 then '是'
    end 是否COD
    ,pi.cod_amount/100 COD金额
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
    ,ss.name 包裹最后目的地网点
    ,t1.parcel_created_at 揽收时间
    ,t1.updated_at 判责时间
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 判责后第一次有有效路由时间
from t t1
join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-12-31'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > t1.updated_time
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join my_staging.parcel_info pi on pi.pno = t1.pno
left join my_staging.sys_store ss on ss.id = pi.dst_store_id
left join my_staging.ka_profile kp on kp.id = t1.client_id