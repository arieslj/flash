select
    t.pno
    ,if(oi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,oi.cod_amount/100 cod
from tmpale.tmp_ph_pno_1211 t
join ph_staging.parcel_info pi on pi.pno = t.pno
left join  ph_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)