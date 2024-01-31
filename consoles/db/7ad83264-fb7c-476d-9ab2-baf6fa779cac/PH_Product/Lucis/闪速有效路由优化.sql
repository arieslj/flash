select
    a.pno 包裹单号
    ,if(a.returned = 0, '正', '逆') 流向
    ,a.created_at 闪速任务时间
    ,a.updated_at 闪速任务处理时间
    ,a.CN_element 有效路由类型
    ,case a.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 现在包裹状态
    ,a.cod COD金额
    ,coalesce(ss.name, sd.name ) '最后操作网点/部门'
    ,ss2.name 目的地网点
from
    (
        select
            plt.pno
            ,pd.returned
            ,plt.created_at
            ,plt.updated_at
            ,ddd.CN_element
            ,pd.state
            ,pd.cod_amount/100 cod
            ,pd.last_valid_store_id
            ,pd.dst_store_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_bi.parcel_lose_task plt
        join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at > '2023-09-14' and pr.route_action in  ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        left join ph_bi.parcel_detail pd on pd.pno = plt.pno
        where
            plt.source = 3
            and plt.state = 5
            and plt.operator_id = 10000
            and plt.created_at > '2023-09-16'
            and plt.created_at < '2023-10-01'
            and pr.routed_at < date_sub(plt.updated_at, interval 8 hour)
    ) a
left join ph_staging.sys_store ss on ss.id = a.last_valid_store_id
left join ph_staging.sys_department sd on sd.id = a.last_valid_store_id
left join ph_staging.sys_store ss2 on ss2.id = a.dst_store_id
where
    a.rk = 1