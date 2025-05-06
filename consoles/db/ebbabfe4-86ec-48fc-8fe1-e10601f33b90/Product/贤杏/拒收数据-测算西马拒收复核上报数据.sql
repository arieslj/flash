select
    convert_tz(tdm.created_at, '+00:00', '+07:00') 上报拒收时间
    ,td.pno 运单号
    ,td.store_id 网点ID
    ,ss.name 网点
    ,dm.region_name 大区
    ,if(prr.state = 2, 'y', 'n') 是否上报拒收复核上报
#     count(1)
from my_staging.ticket_delivery_marker tdm
left join my_staging.ticket_delivery td on tdm.delivery_id = td.id
left join my_staging.sys_store ss on ss.id = td.store_id
left join dwm.dim_my_sys_store_rd dm on dm.store_id = ss.id and dm.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_reject_report_info prr on prr.mark_info_id = tdm.id
where
    tdm.created_at > '2024-01-31 17:00:00'
    and tdm.created_at < '2024-02-15 17:00:00'
    and tdm.marker_id = 2