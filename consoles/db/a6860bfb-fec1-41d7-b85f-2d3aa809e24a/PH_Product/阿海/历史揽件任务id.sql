select
    t.pno
    ,tpor.ticket_pickup_id
    ,tp.store_id
from ph_staging.ticket_pickup_order_relation tpor
left join ph_staging.order_info oi on tpor.order_id = oi.id
join tmpale.tmp_ph_pno_lj_1228 t on t.pno = oi.pno
left join ph_staging.ticket_pickup tp on tp.id = tpor.ticket_pickup_id