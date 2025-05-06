select
    distinct
    pr.pno
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
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.routed_at >='2024-01-17 16:00:00'
    and pr.routed_at < '2024-01-18 16:00:00'
    and pr.staff_info_id = 166605