-- 18112 已下线需求

select
    plt.id
    ,plt.pno
from bi_pro.parcel_lose_task plt
where
    plt.source = 2 -- B来源
    and plt.created_at > '2023-10-01'
    and plt.source_id like 'return_visit_2_%'
    and plt.state < 5

union

-- 2. 回访结果为未收到包裹的非虚假妥投-投诉原因
select
    plt.id
    ,plt.pno
from bi_pro.parcel_lose_task plt
left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = substring_index(plt.source_id, '_', -1)
where
    plt.source = 2 -- B来源
    and plt.created_at > '2023-10-01'
    and ( plt.source_id like 'return_visit_1_%' or plt.source_id like'return_visit_3_%')
    and acc.complaints_type != 1 -- 非虚假妥投
    and plt.state < 5

union
-- 3.平台包裹
select
    plt.id
    ,plt.pno
from bi_pro.parcel_lose_task plt
left join bi_pro.parcel_claim_task pct on pct.pno = plt.pno and pct.state = 6
where
    plt.source = 2 -- B来源
    and plt.created_at > '2023-11-01'
    and plt.state < 5
    and pct.pno is null
union

select
    plt.id
    ,plt.pno
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on pi.pno = plt.pno
where
    plt.source = 2 -- B来源
    and plt.created_at > '2023-10-01'
    and pi.state not in (5,7,8)

;

select
    t.*
from bi_pro.parcel_lose_task plt
join tmpale.tmp_th_plt_id_0108 t on t.id = plt.id
where
    plt.created_at >= '2024-01-01'