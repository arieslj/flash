with t as
(
    select
        plt.pno
        ,plt.updated_at
        ,pi.state
    from ph_bi.parcel_lose_task plt
    join ph_staging.parcel_info pi on plt.pno = pi.pno
    where
        plt.state = 6
        and plt.duty_result = 1
        and pi.state not in (5,7,8,9)
)
select
    t1.pno
    ,t1.updated_at 判责时间
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
    ,pr.route_time 最后一次有效路由时间
from  t t1
left join
    (
        select
            pr.pno
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by pr.pno order by  pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t1 on pr.pno = t1.pno
        where
            pr.route_action in ('DELIVERY_PICKUP_STORE_SCAN','SHIPMENT_WAREHOUSE_SCAN','RECEIVE_WAREHOUSE_SCAN','DIFFICULTY_HANDOVER','ARRIVAL_GOODS_VAN_CHECK_SCAN','FLASH_HOME_SCAN','RECEIVED','SEAL','UNSEAL','DISCARD_RETURN_BKK','REFUND_CONFIRM','ARRIVAL_WAREHOUSE_SCAN','DELIVERY_TRANSFER','DELIVERY_CONFIRM','STORE_KEEPER_UPDATE_WEIGHT','REPLACE_PNO','PICKUP_RETURN_RECEIPT','DETAIN_WAREHOUSE','DELIVERY_MARKER','DISTRIBUTION_INVENTORY','PARCEL_HEADLESS_PRINTED','STORE_SORTER_UPDATE_WEIGHT','SORTING_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','DELIVERY_TICKET_CREATION_SCAN','INVENTORY','STAFF_INFO_UPDATE_WEIGHT','ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
where
    pr.route_time < t1.updated_at
