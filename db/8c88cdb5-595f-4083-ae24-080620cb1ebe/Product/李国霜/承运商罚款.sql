select
    *
from bi_pro.parcel_claim_task pct
join bi_pro.parcel_lose_task plt on plt.pno = pct.pno
where
    pct.created_at > '2024-03-01'
    and pct.created_at < '2024-04-01'