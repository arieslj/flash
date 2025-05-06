with t as
    (
        select
            pi.pno
            ,pi.returned
            ,pi.state
            ,plt.duty_result
            ,plt.updated_at
            ,plt.client_id
        from ph_bi.parcel_lose_task plt
        left join ph_staging.parcel_info pi on pi.pno = plt.pno
        where
            plt.state = 6
            and plt.duty_result in (1,2)
            and pi.state not in (5,7,8,9)
    )
select
    t1.pno
    ,if(t1.returned = 0, '正向', '逆向') 包裹流向
    ,t1.client_id 客户ID
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
    ,case t1.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
	end 判责类型
    ,t1.updated_at 判责日期
    ,t2.store_name 最后一次有效路由网点
    ,convert_tz(t2.routed_at, '+00:00', '+08:00')  最后一次有效路由时间
from t t1
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
#         join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
        where
            pr.routed_at >= '2023-01-01'
            and pr.organization_type = 1
            and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                   'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                   'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                   'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                   'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                   'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
    ) t2 on t2.pno = t1.pno and t2.rk = 1