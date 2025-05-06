with a as
    (
        select
            a1.created_at
            ,a1.pno
            ,a1.last_valid_store_id src_store_id
            ,a1.next_store_id
            ,a1.last_valid_action
        from
            (
                select
                    plt.created_at
                    ,plt.pno
                    ,plt.last_valid_store_id
                    ,pr.next_store_id
                    ,plt.last_valid_action
                    ,row_number() over (partition by plt.pno order by plt.created_at desc) rk
                from bi_pro.parcel_lose_task plt
                join fle_staging.sys_store ss on ss.id = plt.last_valid_store_id
                join rot_pro.parcel_route pr on pr.pno = plt.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 1 month)
                where
                    plt.state < 5
                    and  plt.source = 1
                    and ss.category in (8,12) -- HUB
                    and plt.created_at < date_sub(curdate(), interval 3 day)
                    and plt.last_valid_action = 'SHIPMENT_WAREHOUSE_SCAN'
            ) a1
        where
            a1.rk = 1
    )
, b as
    (
        select
            b.created_at
            ,b.pno
            ,b.store_id src_store_id
            ,b.last_valid_store_id next_store_id
            ,b.last_valid_action
        from
            (
                select
                    plt.created_at
                    ,plt.pno
                    ,pr.store_id
                    ,plt.last_valid_store_id
                    ,plt.last_valid_action
                    ,row_number() over (partition by plt.pno order by pr.routed_at desc) rk
                from bi_pro.parcel_lose_task plt
                left join rot_pro.parcel_route pr on pr.pno = plt.pno
                where
                    plt.state < 5
                    and  plt.source = 1
                    and plt.created_at < date_sub(curdate(), interval 3 day)
                    and plt.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
                    and pr.store_id != plt.last_valid_store_id
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            ) b
        where
            b.rk = 1
    )
select
    t.created_at 进入A来源任务时间
    ,s1.name 发出网点
    ,pc.store_name 路由中最后一次集包网点
    ,pc.dst_name 路由最后一次集包计划目的地
    ,s2.name 接收网点
    ,ddd.CN_element 最后有效路由
    ,src.remark 发出网点举证
    ,pc.remark 集包举证
from
    (
        select
            *
        from a a1

        union

        select
            *
        from b b1
    ) t
left join
    (
        select
            p1.pno
            ,p1.store_id
            ,p1.store_name
            ,p1.dst_name
            ,pr2.remark
        from
            (
                select
                    p.pno
                    ,p.store_id
                    ,p.store_name
                    ,json_extract(p.extra_value, '$.esUnsealStoreName') dst_name
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.extra_value
                            ,pr.store_name
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                        from rot_pro.parcel_route pr
                        join
                            (
                                select * from a a1
                                union
                                select * from b b1
                            ) t on t.pno = pr.pno
                        where
                            pr.route_action = 'SEAL'
                            and pr.routed_at > date_sub(curdate(), interval 30 day)
                    ) p
                where
                    p.rk = 1
            ) p1
        left join rot_pro.parcel_route pr2 on pr2.pno = p1.pno and pr2.store_id = p1.store_id and pr2.route_action = 'MANUAL_REMARK' and pr2.routed_at > date_sub(curdate(), interval 30 day) and pr2.remark regexp 'http'
    ) pc on pc.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.remark
        from rot_pro.parcel_route pr
        join
            (
                select * from a a1 union select * from b b1
            ) t on pr.store_id = t.src_store_id and pr.pno = t.pno
        where
            pr.routed_at > date_sub(curdate(), interval 30 day)
            and pr.route_action = 'MANUAL_REMARK'
            and pr.remark regexp 'http'
    ) src on src.pno = t.pno and src.store_id = t.src_store_id
left join dwm.dwd_dim_dict ddd on ddd.element = t.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join fle_staging.sys_store s1 on s1.id = t.src_store_id
left join fle_staging.sys_store s2 on s2.id = t.next_store_id
# left join
#     (
#         select
#             pr.pno
#             ,pr.store_id
#             ,pr.remark
#         from rot_pro.parcel_route pr
#         join
#             (
#                 select * from a a1 union select * from b b1
#             ) t on pr.store_id = t.next_store_id and pr.pno = t.pno
#         where
#             pr.routed_at > date_sub(curdate(), interval 30 day)
#             and pr.route_action ='MANUAL_REMARK'
#     ) nex on nex.pno = t.pno and nex.store_id = t.next_store_id
