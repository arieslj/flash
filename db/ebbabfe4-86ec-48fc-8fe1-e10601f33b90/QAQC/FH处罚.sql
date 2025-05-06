select
    am.*
from my_bi.abnormal_message am
join my_bi.parcel_lose_task plt on json_extract(am.extra_info, '$.losr_task_id') = plt.id
where
    plt.updated_at >= '2023-04-01 00:00:00'
    and plt.updated_at < '2023-08-01 00:00:00'
    and plt.state = 6

;

select
    min(created_at)
from my_bi.abnormal_message am