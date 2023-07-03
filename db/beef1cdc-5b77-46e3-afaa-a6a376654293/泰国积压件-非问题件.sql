-- 非疑难件
with p as
(
    select
        pi.pno
        ,pi.returned
        ,pi.client_id
        ,pi.created_at
        ,pi.agent_id
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.dst_store_id
    from fle_dwd.dwd_fle_parcel_info_di pi
    where
        pi.p_date >= '2023-01-01'
        and pi.p_date < '2023-02-01'
        and pi.state not in ('5','6','7','8','9')
),
ss as
(
    select
        ss.id
        ,ss.category
        ,ss.name
    from fle_dim.dim_fle_sys_store_da ss
    where
        ss.p_date = date_sub(`current_date`(), 1)
),
pr as
(
    select
        pr.pno
        ,pr.store_category
        ,pr.store_name
        ,pr.routed_at
        ,pr.store_id
        ,pr.route_action
    from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
    where
        pr.p_date >= '2023-01-01'
        and pr.p_date < '2023-02-01'
        and pr.route_action in ('DELIVERY_PICKUP_STORE_SCAN','SHIPMENT_WAREHOUSE_SCAN','RECEIVE_WAREHOUSE_SCAN','DIFFICULTY_HANDOVER','ARRIVAL_GOODS_VAN_CHECK_SCAN','FLASH_HOME_SCAN','RECEIVED','SEAL','UNSEAL','DISCARD_RETURN_BKK','REFUND_CONFIRM','ARRIVAL_WAREHOUSE_SCAN','DELIVERY_TRANSFER','DELIVERY_CONFIRM','STORE_KEEPER_UPDATE_WEIGHT','REPLACE_PNO','PICKUP_RETURN_RECEIPT','DETAIN_WAREHOUSE','DELIVERY_MARKER','DISTRIBUTION_INVENTORY','PARCEL_HEADLESS_PRINTED','STORE_SORTER_UPDATE_WEIGHT','SORTING_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','DELIVERY_TICKET_CREATION_SCAN','INVENTORY','STAFF_INFO_UPDATE_WEIGHT','ACCEPT_PARCEL')
)
select
    pi.pno
    ,pi.created_at `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `包裹类型`
    ,pi.client_id `客户id`
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as `客户类型`
    ,datediff(`current_date`(), pi.created_at) `揽收至今天数`
    ,case pi.state
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
    ,pr2.store_name `当前滞留网点`
    ,case pr2.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
    ,pr2.store_arr_time `到达网点时间`
    ,datediff(`current_date`(), pr2.store_arr_time) `当前网点滞留天数`
    ,pr2.route_action `最后有效路由`
    ,pr2.routed_at `最后有效路由时间`
    ,datediff(`current_date`(), pr2.routed_at) `最后有效路由至今日期`
    ,s1.name `揽收网点`
    ,s2.name `目的地网点`
    ,case cgk.customer_group_id
        when '6335094827fa4a000728c862' then 'Team BD (Retail Management) Team B'
        when '5ebb8d10374d4f186461c17a' then '์Non-Shipment Thai customer'
        when '5e99c45f8b976a1e1d7d992f' then 'LAZADA'
        when '5cdd5ffcca86ca03b6c60db5' then 'KAM CN'
        when '5c77b2efca86ca58ab45ecbe' then 'FFM'
        when '5dd64b62a0abec422328f2ed' then 'Test Requirement No.3967'
        when '5dc90de5a0abec56702c3ce2' then 'KAM Chinese'
        when '5d3ab3efca86ca4d62134ad6' then 'CTT'
        when '5e44b3288b976a2afb6df05a' then 'KAM Team B'
        when '60b5f7ef4cd0ab0007c22a84' then 'Bulky Project'
        when '5e44b235a0abec725950c140' then 'KAM Team A'
        when '5c77b2a8ca86ca58ab45ea3d' then 'THAI KAM'
        when '632bd544a205600007dc687d' then 'Bulky BD'
        when '5d440a07ca86ca78586a9240' then 'kam testing'
        when '5c77b436ca86ca58ab45f583' then 'ALL '
        when '631b1f43392d5e00078d0e91' then 'Retail Management '
        when '62c5343748647000070736e0' then 'TikTok'
        when '5e44ae8f8b976a2afb6deda8' then 'Shopee'
        when '631ca3e56d6c470007e9cdab' then 'Team BD (Retail Management) Team A'
    end `kamvip客服组`
    ,case
        when pr2.store_category in ('8','12') then 'HUB'
        when pr2.store_category in ('4','5','7') then 'SHOP'
        when pr2.store_category in ('1','10','14') then 'NW'
        when pr2.store_category in ('6') then 'FH'
    end `待处理部门`
from p pi
left join
    (
        select
            kp.id
            ,kp.name
        from fle_dim.dim_fle_ka_profile_da kp
        where
            kp.p_date = date_sub(`current_date`(), 1)
    )  kp  on kp.id = pi.client_id
left join
    (
        select
            bc.client_id
            ,bc.client_name
        from fle_dim.dim_dwm_big_clients_id_detail_da bc
        where
            bc.p_date = date_sub(`current_date`(), 1)
    ) bc on bc.client_id = pi.client_id
left join
    (
        select
            a.*
            ,b.routed_at store_arr_time
        from
            (
                select
                    pr1.*
                from
                    (
                        select
                            pr1.pno
                            ,pr1.store_name
                            ,pr1.store_id
                            ,pr1.store_category
                            ,pr1.route_action
                            ,pr1.routed_at
                            ,row_number() over (partition by pr1.pno order by pr1.routed_at desc ) rk
                        from pr pr1
                        join p p1 on pr1.pno = p1.pno
                    ) pr1
                where
                    pr1.rk = 1
            ) a
        join
            (
                select
                    pr1.pno
                    ,pr1.store_name
                    ,pr1.store_id
                    ,pr1.store_category
                    ,pr1.route_action
                    ,pr1.routed_at
                    ,row_number() over (partition by pr1.pno,pr1.store_id order by pr1.routed_at ) rk
                from pr pr1
                join p p1 on pr1.pno = p1.pno
            ) b on a.pno = b.pno and a.store_id = b.store_id and b.rk = 1
    ) pr2 on pr2.pno = pi.pno
left join ss s1 on s1.id = pi.ticket_pickup_store_id
left join ss s2 on s2.id = pi.dst_store_id
left join
    (
        select
            cgk.ka_id
            ,cgk.customer_group_id
        from fle_dim.dim_fle_customer_group_ka_relation_da cgk
        where
            cgk.p_date = date_sub(`current_date`(), 1)
            and cgk.deleted = '0'
    ) cgk on cgk.ka_id = pi.client_id