select
    plt.pno
    ,plt.parcel_created_at pick_date
    ,pi.src_name sneder_name
    ,pi.src_phone sender_number
    ,pi.dst_name receipient_name
    ,pi.dst_phone receipient_number
    ,pi2.cod_amount/100 cod
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.parcel_created_at >= '2023-09-01'
    and plt.parcel_created_at < '2023-12-01'
    and pi.ticket_pickup_staff_info_id = '137371'