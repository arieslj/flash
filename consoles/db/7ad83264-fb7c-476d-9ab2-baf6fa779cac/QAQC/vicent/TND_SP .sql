select
    distinct
    plt.pno 'Tracking No'
    ,date (convert_tz(pi.created_at, '+00:00', '+08:00')) 'Pickup date'
    ,concat(hsi.name, '(', hsi.name_en, ')') 'Pickup courier'
    ,plt.last_valid_action 'last operation'
    ,plt.last_valid_routed_at 'last operation time'
from ph_bi.parcel_lose_task plt
left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_pickup_staff_info_id
where
    plt.updated_at > '2024-05-01'
    and plt.state = 6
    and plt.duty_result = 1
    and ss.name = 'TND_PDC'