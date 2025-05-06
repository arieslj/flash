with t as
    (
        select
            a.*
        from
            (
                select
                    pi.pno
                    ,pi.dst_store_id
                    ,pr.routed_at
                    ,pi.returned
                    ,pi.client_id
                    ,pi.ticket_pickup_store_id
                    ,row_number() over (partition by pr.pno order by pr.routed_at) rk
                from my_staging.parcel_route pr
                join my_staging.parcel_info pi on pr.pno = pi.pno and pr.store_id = pi.dst_store_id
                where
                    pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN'
                    and pr.routed_at > '2024-05-31 16:00:00'
                    and pr.routed_at < '2024-06-30 16:00:00'
            ) a
        where
            a.rk = 1
    )
select
    t1.pno
    ,if(t1.returned = 1, 'yes', 'no') 是否退件
    ,t1.client_id 客户ID
    ,dm.store_name 揽收网点
    ,dm.region_name 揽收大区
    ,dm1.store_name 目的地网点
    ,dm1.region_name 目的地大区
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') '到港时间'
    ,va.store_name '到港后的第一个非目的地有效路由网点'
    ,convert_tz(va.routed_at, '+00:00', '+08:00') '到港后的第一个有效路由时间'
    ,ddd.cn_element 到港后的第一个有效路由操作
    ,cd.change_cnt 修改目的地网点次数
    ,cf.di_cnt 提交错分次数
from t t1
left join dwm.dim_my_sys_store_rd dm on dm.store_id = t1.ticket_pickup_store_id and dm.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dim_my_sys_store_rd dm1 on dm1.store_id = t1.dst_store_id and dm1.stat_date = date_sub(curdate(), interval 1 day)
join
    (
        select
            *
        from
            (
                select
                    pr.pno
                    ,pr.route_action
                    ,pr.store_id
                    ,pr.store_name
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at) rk
                from my_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > '2024-05-31 16:00:00'
                   -- and pr.store_id != t1.dst_store_id
                    and pr.routed_at > t1.routed_at
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')

            ) v
        where
            v.rk = 1
    ) va on va.pno = t1.pno
left join dwm.dwd_dim_dict ddd on ddd.element = va.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join
    (
        select
            pcd.pno
            ,count(pcd.id) change_cnt
        from my_staging.parcel_change_detail pcd
        join t t1 on t1.pno = pcd.pno
        where
            pcd.created_at > '2024-05-31 16:00:00'
            and pcd.field_name = 'dst_store_id'
        group by 1
    ) cd on cd.pno = t1.pno
left join
    (
        select
            di.pno
            ,count(distinct di.id) di_cnt
        from my_staging.diff_info di
        join t t1 on t1.pno = di.pno
        where
            di.created_at > '2024-05-31 16:00:00'
            and di.diff_marker_category = 31
        group by 1
    ) cf on cf.pno = t1.pno
where
    va.store_id != t1.dst_store_id