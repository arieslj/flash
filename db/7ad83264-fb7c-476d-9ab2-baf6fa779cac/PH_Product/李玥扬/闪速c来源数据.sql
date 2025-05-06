select
    plt.pno
    ,plt.created_at
    ,plt.updated_at
    ,
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2024-03-01'
    and plt.created_at < '2024-05-01'
    and plt.source = 3
    and plt.operator_id not in (10000, 10001)
    and ( (plt.state = 6 and plt.penalties > 0) or plt.state = 5 )