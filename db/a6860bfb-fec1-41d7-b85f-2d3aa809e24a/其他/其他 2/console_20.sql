with t as
(
    select
        pi.pno
        ,'未打电话' type
        ,pi.ticket_pickup_store_id
        ,pi.finished_at
        ,pi.ticket_delivery_staff_info_id
        ,pi.ticket_delivery_store_id
        ,pi.created_at
        ,pi.dst_store_id
        ,pi.dst_province_code
        ,pi.cod_enabled
        ,pi.returned
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'shein'
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'PHONE' and pr.routed_at < pi.finished_at
    where
        pi.state = 5
        and pi.created_at > '2023-08-01'
        and pr.pno is null

    union all

    select
        pi.pno
        ,'未打通电话' type
        ,pi.ticket_pickup_store_id
        ,pi.finished_at
        ,pi.ticket_delivery_staff_info_id
        ,pi.ticket_delivery_store_id
        ,pi.created_at
        ,pi.dst_store_id
        ,pi.dst_province_code
        ,pi.cod_enabled
        ,pi.returned
#         ,sum(json_extract(pr.extra_value, '$.callDuration')) call_sum
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'shein'
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'PHONE' and pr.routed_at < pi.finished_at
    where
        pi.state = 5
        and pi.created_at > '2023-08-01'
        and pr.pno is not null
    group by 1
    having sum(json_extract(pr.extra_value, '$.callDuration') ) = 0


)
select
    a.pno
    ,a.type 类型
    ,convert_tz(oi.created_at, '+00:00', '+08:00') 下单时间
    ,convert_tz(a.created_at, '+00:00', '+08:00') 揽收时间
    ,convert_tz(a.finished_at, '+00:00', '+08:00') 妥投时间
    ,dp3.area_name 目的地区域
    ,sp.name 目的地省
    ,dp.region_name 目的大区
    ,dp.store_name 目的网点
    ,dp2.store_name 派件网点
    ,dp2.region_name 派件大区
    ,a.ticket_delivery_staff_info_id 派件快递员工号
    ,a.last_action 妥投前路由状态
    ,oi.cogs_amount/100 cogs金额
    ,if(a.cod_enabled = 1, 'y', 'n') 是否COD
    ,if(a.returned = 1, 'y', 'n') 是否退件
from
    (
        select
            t1.*
            ,pr.route_action
            ,lag(pr.route_action, 1) over (partition by pr.pno order by pr.routed_at) last_action
        from t t1
        left join ph_staging.parcel_route pr on pr.pno = t1.pno
        where
            pr.routed_at > '2023-08-01'
    ) a
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = a.ticket_delivery_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join dwm.dim_ph_sys_store_rd dp3 on dp3.store_id = a.dst_store_id and dp3.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on oi.pno = a.pno
left join ph_staging.sys_province sp on sp.code = a.dst_province_code
where
    a.route_action = 'DELIVERY_CONFIRM'
    and a.last_action in ('DELIVERY_TICKET_CREATION_SCAN', 'SORTING_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'UNSEAL', 'SHIPMENT_WAREHOUSE_SCAN', 'INVENTORY', 'DETAIN_WAREHOUSE')