select
    t.dst_phone
    ,group_concat(distinct ss.name) 揽收网点
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0605 t on  t.dst_phone = pi.dst_phone
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
where
    pi.created_at > '2024-05-14 17:00:00'
    and pi.created_at < '2024-05-31 17:00:00'
group by t.dst_phone