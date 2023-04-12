select
    pi.created_at `揽件时间`
    ,pi.finished_at `派件时间`
    ,pi.pno `运单号`
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as `运单状态`
    ,concat(pi.ticket_pickup_staff_info_id, hsi.name) `揽件员`
    ,coalesce(concat(ka.id, ka.name), concat(ui.id, ui.name)) `KA`
    ,pi.dst_name `收件人姓名`
    ,pi.dst_phone `收件人电话`
    ,pi.src_name `寄件人姓名`
    ,pi.src_phone `寄件人电话`
    ,s1.name `揽件网点`
    ,s2.name `派件网点`
from
    (
        select
            pi.created_at
            ,pi.finished_at
            ,pi.pno
            ,pi.state
            ,pi.ticket_pickup_staff_info_id
            ,pi.client_id
            ,pi.dst_name
            ,pi.dst_phone
            ,pi.src_name
            ,pi.src_phone
            ,pi.ticket_pickup_store_id
            ,pi.ticket_delivery_store_id
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-08-01'
            and pi.src_phone in ('0929425385','0945513818','022880035')
    ) pi
left join
    (
        select
            *
        from fle_dim.dim_fle_ka_profile_da ka
        where
            ka.p_date = date_sub(`current_date`(), 1)
    ) ka on ka.id = pi.client_id
left join
    (
        select
            *
        from fle_dim.dim_fle_user_info_da ui
        where
            ui.p_date = date_sub(`current_date`(), 1)
    ) ui on ui.id = pi.client_id
left join
    (
       select
           *
       from fle_dim.dim_fle_sys_store_da ss
       where
           ss.p_date = date_sub(`current_date`(), 1)
    ) s1 on s1.id = pi.ticket_pickup_store_id
left join
    (
       select
           *
       from fle_dim.dim_fle_sys_store_da ss
       where
           ss.p_date =  date_sub(`current_date`(), 1)
    ) s2 on s2.id = pi.ticket_delivery_store_id
left join
    (
        select
            *
        from fle_dim.dim_bi_hr_staff_info_da hsi
        where
            hsi.p_date = date_sub(`current_date`(), 1)
    ) hsi on hsi.staff_info_id = pi.ticket_pickup_staff_info_id