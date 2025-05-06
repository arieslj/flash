select
    t.pno
    ,pi2.ticket_pickup_staff_info_id  揽收快递员ID
    ,hsi.name 揽收快递员姓名
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0408 t on t.pno = pi.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi2.ticket_pickup_staff_info_id