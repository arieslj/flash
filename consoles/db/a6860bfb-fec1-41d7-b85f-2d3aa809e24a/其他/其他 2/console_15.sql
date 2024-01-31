select
    pr.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 操作时间
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
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pr.staff_info_id = '149733'
    and pr.routed_at >= '2023-09-07 16:00:00'
    and pr.routed_at < '2023-09-08 16:00:00'
    and pr.route_action = 'PRINTING'