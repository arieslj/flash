select
    t.pno
    ,ss.name 揽收网点
    ,ss2.name 派送网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_1214 t on t.pno = pi.pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 1, pi.customary_pno, pi.pno) = pi2.pno
left join ph_staging.sys_store ss on ss.id = pi2.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi2.ticket_delivery_store_id

;

