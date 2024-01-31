select
    pi.pno
    ,pi.client_id
    ,pi.cod_amount/100 cod
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) cogs
from my_staging.parcel_info pi
left join my_staging.order_info oi on oi.pno = pi.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
where
    pi.created_at >= '2024-01-22 16:00:00'
    and pi.created_at < '2024-01-23 16:00:00'
    and pi.returned = 0