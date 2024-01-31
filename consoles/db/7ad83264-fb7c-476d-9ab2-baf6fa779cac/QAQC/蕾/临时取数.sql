select
    pi.pno 单号
    ,'揽' 类型
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno) = pi2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.ticket_pickup_staff_info_id = '153228'
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-11-30 16:00:00'
    and pi.state = 8

union all

select
    pi.pno 单号
    ,'派' 类型
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 揽派时间
    ,if(bc.client_name = 'lazada', pi2.insure_declare_value/100, pi2.cod_amount/100)  COD金额
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pr.routed_at >= '2023-10-31 16:00:00'
    and pr.routed_at < '2023-11-30 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.staff_info_id = '153228'
    and pi.state = 8

;


with t as
    (
        select
            pi.pno
            ,pi.state
            ,ss.name pick_store
            ,ss2.name dst_store
            ,pi.cod_amount
            ,pi.client_id
            ,pi.insure_declare_value
            ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_at
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
        where
            pi.created_at >= '2023-12-31 16:00:00'
            and pi.src_phone = '09218644470'
            and pi.state < 9
    )
select
    t1.pno
    ,t1.pick_at 揽收时间
    ,t1.pick_store 揽收网点
    ,t1.dst_store 目的地网点
    ,if(bc.client_name = 'lazada', t1.insure_declare_value/100, t1.cod_amount/100) cod
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 包裹状态
    ,if(t2.pno is not null, '是', '否') 是否有通话记录
from t t1
left join
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at >= '2023-12-31 16:00:00'
            and pr.route_action = 'PHONE'
            and json_extract(pr.extra_value, '$.callDuration') > 0
        group by 1
    ) t2 on t1.pno = t2.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id

;

select
    pi.pno
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽件时间
    ,pi.src_name 卖家名称
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
    end 包裹状态
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pi.state in (7,8)
    and pi.ticket_pickup_staff_info_id = 153228
    and pi.created_at >= '2023-10-31 16:00:00'

;

