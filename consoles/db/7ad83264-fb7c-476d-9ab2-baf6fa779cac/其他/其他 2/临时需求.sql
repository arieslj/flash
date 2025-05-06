select
    pr.pno
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,pi.cod_amount/100 COD
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
    end as 包裹状态
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.staff_info_id = '145395'
    and pr.routed_at >= '2023-07-22 16:00:00'
    and pr.routed_at < '2023-08-04 16:00:00'

;

select
    pr.pno
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,pi.cod_amount/100 COD
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
    end as 包裹状态
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'PRINTING'
    and pr.staff_info_id = '148335'
    and pr.routed_at >= '2023-07-10 16:00:00'
    and pr.routed_at < '2023-07-11 16:00:00'