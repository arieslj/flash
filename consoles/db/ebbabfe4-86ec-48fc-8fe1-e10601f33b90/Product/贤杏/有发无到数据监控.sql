with t as
    (
        select
            pr.pno
            ,pr.next_store_id
            ,json_extract(pr.extra_value, '$.proofId') proofId
            ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_no
            ,pr.routed_at
            ,pr.store_id
            ,pr.store_name
            ,ft.store_name ori_store_name
        from my_staging.parcel_route pr
        left join my_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.store_id = ft.next_store_id
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 11 day ), interval 8 hour)
            and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.packPno') is not null
    )
, a as
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at
            ,ddd.cn_element
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk1
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk2
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
            and pr.route_action in ('UNSEAL','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > t1.routed_at
    )
select
    date(convert_tz(t1.routed_at, '+00:00', '+08:00')) 整包到件日期
    ,t1.pno
    ,t1.pack_no 集包号
    ,t1.ori_store_name 上游网点名称
    ,t1.store_name 当前网点名称
    ,if(a2.store_id = t1.store_id, '是', '否') 最后操作网点是否在整包到件网点
    ,a2.cn_element 最后操作路由
    ,timestampdiff(second, b.route_time, a1.routed_at)/3600 时间差
    ,if(c.state = 6, '是', '否') 是否判责丢失
    ,case c.state
        when 6 then '丢失'
        when 5 then '无须追责'
    end  判责结果
    ,c.store 责任网点
    ,if(d.pno is not null , '是', '否') 是否有丢失找回
from t t1
left join a a1 on a1.pno = t1.pno and a1.rk1 = 1
left join a a2 on a2.pno = t1.pno and a2.rk2 = 1
left join
    (
        select
            pr.pno
            ,min(pr.routed_at) route_time
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        where
            pr.route_action in ('UNSEAL_NOT_SCANNED', 'HAVE_HAIR_SCAN_NO_TO')
            and pr.routed_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
        group by 1
    ) b on b.pno = t1.pno
left join
    (
        select
            plt.pno
            ,plt.state
            ,group_concat(plr.store_id) store
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        where
            plt.created_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
        group by 1
    ) c on c.pno = t1.pno
left join
    (
        select
            plt.pno
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 4 -- 责任判定
        left join my_staging.parcel_route pr on pr.pno = t1.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(pcol.created_at, interval 8 hour)
            and pr.routed_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
        group by 1
    ) d on d.pno = t1.pno

where
    timestampdiff(second, t1.routed_at, a1.routed_at) > 10800 -- 3h
;
