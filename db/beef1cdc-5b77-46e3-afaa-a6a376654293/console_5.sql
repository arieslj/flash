with t as
(
    select
        pi.*
        ,td.store_id
    from
        (
            select
                td.pno
                ,td.store_id
            from fle_dwd.dwd_fle_ticket_delivery_di td
            where
                td.p_date >= date_sub(`current_date`(), 90)
                and td.store_id in ('TH20040247','TH20040268','TH20040248')
            group by 1,2
        ) td
    join
        (
            select
                pi.pno
                ,pi.state
                ,pi.cod_amount
            from fle_dwd.dwd_fle_parcel_info_di pi
            where
                pi.p_date >= date_sub(`current_date`(), 120)
                and  pi.state != '5'
        ) pi on pi.pno = td.pno
)
select
    b.pno
    ,cast(t1.cod_amount as int)/100 cod
    ,case t1.state
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
    ,b.staff_info_id `最后操作人`
    ,t1.store_id
from
    (
                select
            b.*
        from
            (
                select
                    a.*
                    ,row_number() over (partition by a.pno order by a.routed_at desc ) rk
                from
                    (
                        select
                            pr.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.staff_info_id
                                    ,pr.route_action
                                    ,pr.routed_at
                --                     ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
                                from fle_dwd.dwd_rot_parcel_route_di pr
                                where
                                    pr.p_date >= date_sub(`current_date`(), 90)
                                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                            ) pr
                        join
                            (
                                select
                                    t1.pno
                                from t t1
                                group by 1
                            )  t1 on t1.pno = pr.pno
                    ) a
            ) b
        where
            b.rk = 1
    ) b
left join t t1 on t1.pno = b.pno