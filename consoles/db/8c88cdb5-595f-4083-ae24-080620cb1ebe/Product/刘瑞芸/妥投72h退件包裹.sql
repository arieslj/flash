select
    date(date_add(pi.finished_at, interval 79 hour)) stat_date
    ,pi.pno
    ,pi.client_id 客户ID
    ,pi.dst_phone 收件人电话
    ,bc.client_name 平台名称
#     count(1) 包裹量
#     ,count(distinct pi.dst_phone) 电话量
from fle_staging.parcel_info pi
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
where
    pi.returned = 1
    and pi.state = 5
    and pi.finished_at > date_sub('2025-04-22', interval  79 hour)
    and pi.finished_at < date_sub('2025-04-23', interval  79 hour)

