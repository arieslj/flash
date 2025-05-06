with t as
    (
        select
            ftp.pno
            ,ftp.created_at
            ,ftp.store_id
        from fle_staging.force_take_photo_record ftp
        where
            ftp.created_at > '2024-07-04 17:00:00'
            and ftp.created_at < '2024-07-05 17:00:00'
            -- and ftp.pno = 'TH20045RSFYY3F'
    )
select
    t1.pno
    ,coalesce(a1.CN_element, fo.CN_element) 路由
    ,if(fo.min_route_at is not null, '是', '否') 是否有强制拍照路由
    ,fo.CN_element 强制拍照原因
    ,if(fo.photo_at is not null, '是', '否') 是否有拍照
    ,f2.CN_element ele
#     ,f2.routed_at
from t t1
left join
    (
        select
            t1.pno
            ,ddd.CN_element
            ,row_number() over (partition by t1.pno order by t1.created_at desc) rk
        from rot_pro.parcel_route pr
        left join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        left join
            (
                select
                    t1.pno
                    ,min(pr.routed_at) min_route_at
                from rot_pro.parcel_route pr
                join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
                where
                    pr.routed_at > '2024-07-04 17:00:00'
                    and pr.routed_at < '2024-07-05 17:00:00'
                    and pr.route_action = 'FORCE_TAKE_PHOTO'
                group by 1
            ) fo on fo.pno = t1.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > '2024-07-04 17:00:00'
            and pr.routed_at < '2024-07-05 17:00:00'
            and pr.routed_at > t1.created_at
            and pr.routed_at < if(fo.min_route_at is null, '2024-07-05 17:00:00', fo.min_route_at)
            and pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN', 'INVENTORY', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'SORTING_SCAN', 'RECEIVE_WAREHOUSE_SCAN', 'UNSEAL', 'PRINTING', 'DIFFICULTY_HANDOVER', 'RECEIVED', 'REPLACE_PNO', 'DELIVERY_MARKER', 'SEAL', 'DELIVERY_TRANSFER', 'STORE_KEEPER_UPDATE_WEIGHT', 'FLASH_HOME_SCAN', 'STORE_SORTER_UPDATE_WEIGHT', 'CANCEL_SHIPMENT_WAREHOUSE', 'DELIVERY_PICKUP_STORE_SCAN', 'DISTRIBUTION_INVENTORY', 'REFUND_CONFIRM')
    ) a1 on a1.pno = t1.pno and a1.rk = 1
left join
    (
        select
            a1.pno
            ,a1.min_route_at
            ,a1.CN_element
            ,min(a2.routed_at) photo_at
        from
            (
                select
                    a.*
                from
                    (
                        select
                            pr.pno
                            ,pr.routed_at min_route_at
                            ,ddd.CN_element
                            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
                        from rot_pro.parcel_route pr
                        join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
                        left join dwm.dwd_dim_dict ddd on ddd.element = pr.remark and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                        where
                            pr.routed_at > '2024-07-04 17:00:00'
                            and pr.routed_at < '2024-07-05 17:00:00'
                            and pr.route_action = 'FORCE_TAKE_PHOTO'
                            and pr.routed_at > t1.created_at
                    ) a
                where
                    a.rk = 1
            ) a1
        left join
            (
                select
                    pr.pno
                    ,pr.routed_at
                from rot_pro.parcel_route pr
                join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
                where
                    pr.routed_at > '2024-07-04 17:00:00'
                    and pr.routed_at < '2024-07-05 17:00:00'
                    and pr.route_action = 'TAKE_PHOTO'
            ) a2 on a2.pno = a1.pno and a2.routed_at > a1.min_route_at
        group by 1,2
    ) fo on fo.pno = t1.pno
left join
    (
        select
            a1.pno
            ,ddd.CN_element
            ,pr.routed_at
            ,row_number() over (partition by a1.pno order by pr.routed_at desc) rk
        from
            (
                select
                    a1.pno
                    ,a1.min_route_at
                    ,a1.CN_element
                    ,min(a2.routed_at) photo_at
                from
                    (
                        select
                            a.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.routed_at min_route_at
                                    ,ddd.CN_element
                                    ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
                                from rot_pro.parcel_route pr
                                join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
                                left join dwm.dwd_dim_dict ddd on ddd.element = pr.remark and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                                where
                                    pr.routed_at > '2024-07-04 17:00:00'
                                    and pr.routed_at < '2024-07-05 17:00:00'
                                    and pr.route_action = 'FORCE_TAKE_PHOTO'
                                    and pr.routed_at > t1.created_at
                            ) a
                        where
                            a.rk = 1
                    ) a1
                left join
                    (
                        select
                            pr.pno
                            ,pr.routed_at
                        from rot_pro.parcel_route pr
                        join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
                        where
                            pr.routed_at > '2024-07-04 17:00:00'
                            and pr.routed_at < '2024-07-05 17:00:00'
                            and pr.route_action = 'TAKE_PHOTO'
                    ) a2 on a2.pno = a1.pno and a2.routed_at > a1.min_route_at
                group by 1,2
            ) a1
        left join rot_pro.parcel_route pr on pr.pno = a1.pno and pr.routed_at < a1.photo_at and pr.route_action = 'FORCE_TAKE_PHOTO'
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.remark and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    ) f2 on f2.pno = t1.pno and f2.rk = 1