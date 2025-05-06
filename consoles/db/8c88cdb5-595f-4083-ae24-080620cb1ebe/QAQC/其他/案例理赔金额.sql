select
    pi.pno
    ,oi.cod
    ,oi.cogs
    ,coalesce(if(oi.cod = 0, null, oi.cod), if(oi.cogs = 0, null, oi.cogs), 0) new_value
    ,pr.action
    ,pr.store_name
    ,pr.staff_info_name
    ,pr.staff_info_id
from
    (
        select
            pi.pno
            ,coalesce(pi.customary_pno, pi.pno) new_pno
        from fle_staging.parcel_info  pi
        where
            pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
            and pi.created_at >= date_sub(curdate(), interval 2 month)
    ) pi
join
    (
        select
            oi.pno
            ,oi.cogs_amount/100 cogs
            ,oi.cod_amount/100 cod
        from fle_staging.order_info  oi
        where
            oi.created_at >= date_sub(curdate(), interval 2 month)
    ) oi on oi.pno = pi.new_pno
left join
    (
        select
            pr.*
            ,concat(ddd.cn_element, '-', ddd.en_element) action
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_name
                    ,pr.route_action
                    ,row_number() over(partition by pr.pno order by pr.routed_at desc ) as rk
                from rot_pro.parcel_route  pr
                where
                    pr.routed_at >=  date_sub(curdate(), interval 2 month)
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            ) pr
        left join
            (
                select
                    *
                from dwm.dwd_dim_dict  ddd
                where
                    ddd.db = 'rot_pro'
                    and ddd.tablename = 'parcel_route'
                    and ddd.fieldname = 'route_action'
            ) ddd on ddd.element = pr.route_action
        where
            pr.rk = 1
    ) pr on pr.pno = pi.pno