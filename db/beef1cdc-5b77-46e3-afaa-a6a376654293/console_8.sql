with t as
(
    select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from fle_dwd.dwd_rot_parcel_route_di pr
        where
            pr.p_date >= '2022-12-01'
            and pr.route_action in ('DELIVERY_PICKUP_STORE_SCAN','SHIPMENT_WAREHOUSE_SCAN','RECEIVE_WAREHOUSE_SCAN','DIFFICULTY_HANDOVER','ARRIVAL_GOODS_VAN_CHECK_SCAN','FLASH_HOME_SCAN','RECEIVED','SEAL','UNSEAL','DISCARD_RETURN_BKK','REFUND_CONFIRM','ARRIVAL_WAREHOUSE_SCAN','DELIVERY_TRANSFER','DELIVERY_CONFIRM','STORE_KEEPER_UPDATE_WEIGHT','REPLACE_PNO','PICKUP_RETURN_RECEIPT','DETAIN_WAREHOUSE','DELIVERY_MARKER','DISTRIBUTION_INVENTORY','PARCEL_HEADLESS_PRINTED','STORE_SORTER_UPDATE_WEIGHT','SORTING_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','DELIVERY_TICKET_CREATION_SCAN','INVENTORY','STAFF_INFO_UPDATE_WEIGHT','ACCEPT_PARCEL')
)
select
    plt.pno `运单号`
    ,plt.updated_at `判责时间`
    ,t1.routed_at `最后有效路由时间`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
from
    (
        select
            plt.pno
            ,plt.updated_at
        from fle_dwd.dwd_bi_parcel_lose_task_di plt
        where
            plt.p_date >= '2022-12-01'
            and plt.state = '6'
    ) plt
join
    (
        select
            pi.pno
            ,pi.state
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-12-01'
            and  pi.state not in ('5','7','8','9')
    ) pi on plt.pno = pi.pno
left join t t1 on t1.pno = pi.pno and t1.rk = 1
where
    t1.routed_at < plt.updated_at