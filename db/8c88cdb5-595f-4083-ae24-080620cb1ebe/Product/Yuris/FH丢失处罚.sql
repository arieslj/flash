select
    distinct
    plt.pno
    ,ss.name
from bi_pro.parcel_lose_task plt
join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
join fle_staging.sys_store ss on ss.id = plr.store_id
where
    plt.updated_at > '2024-08-01'
    and plt.updated_at < '2024-11-01'
    and plt.state = 6
    and plt.duty_result = 1
    and ss.category = 6

;


