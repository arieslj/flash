select
    pi.pno `单号`
    ,pi.client_id `客户ID`
    ,pi.created_at `揽件时间`
    ,ss1.name `揽件网点`
    ,pi.finished_time `签收时间`
    ,ss2.name `签收网点`
from
    (
        select
            pi.pno
            ,pi.client_id
            ,pi.created_at
            ,pi.ticket_pickup_store_id
            ,`if`(pi.state = '5', pi.finished_at, null) finished_time
            ,`if`(pi.state = '5', pi.ticket_delivery_store_id, null)  ticket_delivery_store
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-10-01'
            and pi.client_id in ('CR4182','169386')
    ) pi
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss1 on ss1.id = pi.ticket_pickup_store_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2 on ss2.id = pi.ticket_delivery_store