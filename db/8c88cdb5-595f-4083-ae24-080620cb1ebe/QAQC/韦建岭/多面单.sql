select
    a.pno1
    ,a.pno2
    ,a.pno3
    ,a.pno4
    ,a.store_name 扫描网点
    ,convert_tz(a.routed_at, '+00:00', '+07:00') 扫描时间
    -- 单号1
    ,s1.name 单号1揽收网点
    ,dt.par_par_store_name 上级分拨
    ,convert_tz(p1.created_at, '+00:00', '+07:00') 单号1揽收时间
    ,p1.ticket_delivery_staff_info_id 单号1揽件人员ID
    ,case
        when bc1.`client_id` is not null then bc1.client_name
        when kp1.id is not null and bc1.client_id is null then '普通ka'
        when kp1.`id` is null then '小c'
    end 单号1客户类型
    ,concat(p1.src_name, '-', p1.src_phone, '-', p1.src_detail_address) 单号1发件人信息
    -- 单号2
    ,s2.name 单号2揽收网点
    ,dt2.par_par_store_name 单号2揽收网点上级分拨
    ,convert_tz(p2.created_at, '+00:00', '+07:00') 单号2揽收时间
    ,p2.ticket_delivery_staff_info_id 单号2揽收人员ID
    ,case
        when bc2.`client_id` is not null then bc2.client_name
        when kp2.id is not null and bc2.client_id is null then '普通ka'
        when kp2.`id` is null and p2.pno is not null then '小c'
    end 单号2客户类型
    ,concat(p2.src_name, '-', p2.src_phone, '-', p2.src_detail_address) 单号2发件人信息
    -- 单号3
    ,s3.name 单号3揽收网点
    ,dt3.par_par_store_name 单号3揽收网点上级分拨
    ,convert_tz(p3.created_at, '+00:00', '+07:00') 单号3揽收时间
    ,p3.ticket_delivery_staff_info_id 单号3揽件人员ID
    ,case
        when bc3.`client_id` is not null then bc3.client_name
        when kp3.id is not null and bc3.client_id is null then '普通ka'
        when kp3.`id` is null and p3.pno is not null then '小c'
    end 单号3客户类型
    ,concat(p3.src_name, '-', p3.src_phone, '-', p3.src_detail_address) 单号3发件人信息
    -- 单号4
    ,s4.name 单号4揽收网点
    ,dt4.par_par_store_name 单号4揽收网点上级分拨
    ,convert_tz(p4.created_at, '+00:00', '+07:00') 单号4揽收时间
    ,p4.ticket_delivery_staff_info_id 单号4揽件人员ID
    ,case
        when bc4.`client_id` is not null then bc4.client_name
        when kp4.id is not null and bc4.client_id is null then '普通ka'
        when kp4.`id` is null and p4.pno is not null then '小c'
    end 单号4客户类型
    ,concat(p4.src_name, '-', p4.src_phone, '-', p4.src_detail_address) 单号4发件人信息
from
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.sortingScanPnos') pnos
            ,length(json_extract(pr.extra_value, '$.sortingScanPnos')) - length(replace(json_extract(pr.extra_value, '$.sortingScanPnos'), ',', '')) cnt
            ,substring_index(json_extract(pr.extra_value, '$.sortingScanPnos'), ',', 1) pno1
            ,substring_index(substring_index(json_extract(pr.extra_value, '$.sortingScanPnos'), ',', 2), ',', -1) pno2
             ,case length(json_extract(pr.extra_value, '$.sortingScanPnos')) - length(replace(json_extract(pr.extra_value, '$.sortingScanPnos'), ',', ''))
                 when 1 then null
                 when 2 then substring_index(json_extract(pr.extra_value, '$.sortingScanPnos'), ',', -1)
                 when 3 then substring_index(substring_index(json_extract(pr.extra_value, '$.sortingScanPnos'), ',', -2), ',', 1)
             end pno3
            ,case length(json_extract(pr.extra_value, '$.sortingScanPnos')) - length(replace(json_extract(pr.extra_value, '$.sortingScanPnos'), ',', ''))
                when 1 then null
                when 2 then null
                when 3 then substring_index(json_extract(pr.extra_value, '$.sortingScanPnos'), ',', -1)
            end pno4
        from rot_pro.parcel_route pr
        where
            pr.store_id = 'TH05110404' -- AYU
            and json_extract(pr.extra_value, '$.sortingErrorCode') = 1001
            and pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval 7 hour)
    ) a
left join fle_staging.parcel_info p1 on p1.pno = a.pno1 and p1.created_at > date_sub(curdate(), interval 1 month)
left join fle_staging.sys_store s1 on s1.id = p1.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = p1.ticket_pickup_store_id and dt.stat_date = date_sub(current_date(), 1)
left join fle_staging.ka_profile kp1 on kp1.id = p1.client_id
left join dwm.tmp_ex_big_clients_id_detail bc1 on bc1.client_id = p1.client_id

left join fle_staging.parcel_info p2 on p2.pno = a.pno2 and p2.created_at > date_sub(curdate(), interval 1 month)
left join fle_staging.sys_store s2 on s2.id = p2.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt2 on dt2.store_id = p2.ticket_pickup_store_id and dt2.stat_date = date_sub(current_date(), 1)
left join fle_staging.ka_profile kp2 on kp2.id = p2.client_id
left join dwm.tmp_ex_big_clients_id_detail bc2 on bc2.client_id = p2.client_id

left join fle_staging.parcel_info p3 on p3.pno = a.pno3 and p3.created_at > date_sub(curdate(), interval 1 month)
left join fle_staging.sys_store s3 on s3.id = p3.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt3 on dt3.store_id = p3.ticket_pickup_store_id and dt3.stat_date = date_sub(current_date(), 1)
left join fle_staging.ka_profile kp3 on kp3.id = p3.client_id
left join dwm.tmp_ex_big_clients_id_detail bc3 on bc3.client_id = p3.client_id

left join fle_staging.parcel_info p4 on p4.pno = a.pno4 and p4.created_at > date_sub(curdate(), interval 1 month)
left join fle_staging.sys_store s4 on s4.id = p4.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt4 on dt4.store_id = p4.ticket_pickup_store_id and dt4.stat_date = date_sub(current_date(), 1)
left join fle_staging.ka_profile kp4 on kp4.id = p4.client_id
left join dwm.tmp_ex_big_clients_id_detail bc4 on bc4.client_id = p4.client_id



