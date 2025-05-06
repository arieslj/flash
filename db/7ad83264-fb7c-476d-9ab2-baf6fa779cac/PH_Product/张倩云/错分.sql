
select
    pi.pno
    ,pi.dst_phone `收件人手机号`
    ,if(pi.ticket_delivery_store_id is null,'不确定',if(a1.store_id = pi.ticket_delivery_store_id,'虚假错分','非虚假错分')) `是否虚假错分`
    ,oi.dst_province_code `订单省`
    ,oi.dst_city_code `订单城市`
    ,oi.dst_district_code `订单乡`
    ,oi.dst_postal_code `订单邮编`
    ,pi.dst_province_code `目的地省`
    ,pi.dst_city_code `目的地城市`
    ,pi.dst_district_code `目的地乡`
    ,pi.dst_postal_code `目的地邮编`
    ,a1.store_id `首次上报错分网点ID`
    ,pi.ticket_delivery_store_id `最终派件网点ID`
    ,pi.dst_store_id `目的地网点ID`
    ,oi.`dst_detail_address` `订单详细地址`
    ,pi.dst_detail_address `目的地详细地址`
    ,pi.ticket_delivery_staff_lat `妥投坐标-纬度`
    ,pi.ticket_delivery_staff_lng `妥投坐标-经度`
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null) 妥投时间
    ,di.di_cnt 提交错分次数
from
    (
        select
            a.*
        from
            (
                select
                    di.pno
                    ,diff_marker_category
                    ,di.store_id
                    ,di.created_at
                    ,row_number() over (partition by di.pno order by di.created_at) rk
                from ph_staging.diff_info di
                where
                    di.diff_marker_category = 31
                    and di.created_at > '2024-03-31 16:00:00'
                    and di.created_at < '2024-04-15 16:00:00'
            ) a
        where
            a.rk = 1
    ) a1
left join ph_staging.parcel_info pi on pi.pno = a1.pno
left join ph_staging.order_info oi on oi.pno = a1.pno
left join
    (
        select
            di.pno
            ,count(distinct di.id) di_cnt
        from ph_staging.diff_info di
        where
            di.diff_marker_category = 31
            and di.created_at > '2024-03-31 16:00:00'
            and di.created_at < '2024-04-15 16:00:00'
        group by 1
    ) di on di.pno = a1.pno