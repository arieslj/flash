-- 已经判责完成

select
    plt.id
    ,plt.pno
from bi_pro.parcel_lose_task plt
join bi_pro.parcel_lose_task plt2 on plt2.pno = plt.pno and plt2.state = 6
where
    plt.source = 2
    and plt.state in (1,2,3,4)
group by 1,2

union

select
    plt.id
    ,plt.pno
from bi_pro.parcel_lose_task plt
join bi_pro.parcel_claim_task pct on pct.pno = plt.pno and pct.state = 6
where
    plt.source = 2
    and plt.state in (1,2,3,4)
group by 1,2