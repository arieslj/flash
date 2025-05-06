select
    plt.pno
    ,ss.name 闪速最后有效路由网点
    ,ddd.CN_element 下游网点第一条有效路由
    ,case plt.state
        when 5 then '无须追责'
        when 6 then '责任人已认定'
    end 闪速任务状态
    ,pr.store_name 下游网点
    ,plt.created_at 进入闪速时间
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') as 到达下游网点时间
    ,datediff(convert_tz(pr.routed_at, '+00:00', '+07:00'), plt.created_at) as 闪速到下游网点耗时
from
    (
        select
            plt.pno
            ,plt.id
            ,plt.last_valid_store_id
            ,plt.created_at
            ,plt.state
        from bi_pro.parcel_lose_task plt
        where
            plt.source = 12
            and plt.created_at > '2025-03-01'
            and plt.state in (5,6)
            and plt.source_id like '%_c_l_%' -- c to L
    ) plt
left join
    (
        select
            distinct
            coalesce(pcd.old_value, pi.dst_store_id) dst_store_id
            ,pi.pno
        from fle_staging.parcel_info pi
        left join fle_staging.parcel_change_detail pcd on pcd.pno = pi.pno and pcd.field_name = 'dst_store_id' and pcd.new_value = 'TH05110303' -- AAA
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
    ) pi on pi.pno = plt.pno
left join
    (
        select
            pr.pno
            ,plt2.id
            ,pr.route_action
            ,pr.routed_at
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join bi_pro.parcel_lose_task plt2 on plt2.pno = pr.pno
        where
            pr.routed_at > '2025-02-28'
            and plt2.source = 12
            and plt2.created_at > '2025-03-01'
            and plt2.state in (5,6)
            and plt2.source_id like '%_c_l_%' -- c to L
            and pr.store_id != plt2.last_valid_store_id
            and pr.routed_at > convert_tz(plt2.created_at, '+07:00', '+00:00')
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr on pr.id = plt.id and pr.rk = 1
left join fle_staging.sys_store ss on ss.id = plt.last_valid_store_id
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    plt.last_valid_store_id != pi.dst_store_id