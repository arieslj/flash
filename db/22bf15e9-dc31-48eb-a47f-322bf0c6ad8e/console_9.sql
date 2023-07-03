select

    date(plt.parcel_created_at) max_pick
from bi_pro.parcel_lose_task plt
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.updated_at >= '2023-05-01'
    and plt.updated_at < '2023-06-01'
group by 1