

;


select
    pi2.pno 正向单号
    ,pi.pno 退件单号
    ,ss.name 正向揽收网点
    ,pi2.src_detail_address 正向寄件人地址
    ,pi2.client_id 客户ID
    ,pi2.src_name 寄件人姓名
    ,pi.dst_detail_address 退件包裹目的地地址
    ,ss2.name 退件目的地网点
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 退件包裹揽收时间
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi2.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
where
    pi.returned = 1
    and pi.created_at >= date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) -- 近一周退件
    and ss.category = 14
    and ss2.category != 14;