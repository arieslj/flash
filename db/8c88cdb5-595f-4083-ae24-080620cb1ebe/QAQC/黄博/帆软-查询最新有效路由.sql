select
    pr.pno 运单号
    ,pr.store_name 最后有效路由操作网点
    ,pr.staff_info_id 最后有效路由操作员工
    ,concat(pr.element,'-',pr.CN_element)  路由动作
    ,convert_tz(pr.routed_at, '+00:00', '+07:00')  最后有效路由时间
    ,pct.updated_at 理赔完成时间
from
    (
        select
            *
        from
            (
                select
                    pr.pno
                    ,ddd.CN_element
                    ,ddd.element
                    ,pr.staff_info_id
                    ,pr.store_name
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
                from rot_pro.parcel_route pr
                left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                where
                    pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                    and pr.routed_at > date_sub(curdate(),interval 2 month)
            ) pr
        where
            pr.rk = 1
    ) pr
left join
    (
        select
            pct.pno
            ,pct.updated_at
        from bi_pro.parcel_claim_task pct
        where
            pct.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
            and pct.updated_at > date_sub(curdate(),interval 2 month)
            and pct.state = 6
    ) pct on pct.pno =pr.pno