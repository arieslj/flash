select
    di.pno
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
    end  运单当前状态
    ,bc.client_name
    ,convert_tz(cdt.created_at, '+00:00', '+08:00') 疑难件创建时间
from ph_staging.customer_diff_ticket cdt
left join ph_staging.diff_info di on cdt.diff_info_id = di.id
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    cdt.state != 1
    and cdt.created_at < date_sub(curdate(), interval 32 hour)
    and di.diff_marker_category in (2,17)