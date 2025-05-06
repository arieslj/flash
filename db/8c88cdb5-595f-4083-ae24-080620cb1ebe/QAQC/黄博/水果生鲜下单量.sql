select
    pi.src_name 客户名称
    ,ss.name 揽收网点
    ,count(if(pi.created_at > '2024-11-30 17:00:00' and pi.created_at < '2024-12-31 17:00:00', pi.pno, null)) 12月累计下单量
    ,count(if(pi.created_at > '2024-12-31 17:00:00' and pi.created_at < '2025-01-31 17:00:00', pi.pno, null)) 1月累计下单量
from fle_staging.parcel_info pi
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
where
    pi.returned = 0
    and pi.article_category = 11 -- 水果生鲜
    and pi.created_at > '2024-11-30 17:00:00'
    and pi.created_at < '2025-01-31 17:00:00'
group by pi.src_name, ss.name

;

select
    pi.src_name 客户名称
    ,ss.name 揽收网点
    ,count(distinct if(pi.created_at > '2024-11-30 17:00:00' and pi.created_at < '2024-12-31 17:00:00', pi.pno, null)) 12月累计下单量
    ,count(distinct if(pi.created_at > '2024-12-31 17:00:00' and pi.created_at < '2025-01-31 17:00:00', pi.pno, null)) 1月累计下单量
    ,count(distinct if(pi.created_at > '2024-11-30 17:00:00' and pi.created_at < '2024-12-31 17:00:00' and plt.pno is not null, pi.pno, null)) 12判责破损量
    ,count(distinct if(pi.created_at > '2024-12-31 17:00:00' and pi.created_at < '2025-01-31 17:00:00' and plt.pno is not null, pi.pno, null)) 1月判责破损量
from fle_staging.parcel_info pi
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join bi_pro.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 6 and plt.duty_result = 2
where
    pi.returned = 0
    and pi.article_category = 10 -- 家居用具
    and pi.created_at > '2024-11-30 17:00:00'
    and pi.created_at < '2025-01-31 17:00:00'
group by pi.src_name, ss.name

;


select
    pi.src_name 客户名称
    ,ss.name 揽收网点
    ,count(if(pi.created_at > '2024-11-30 17:00:00' and pi.created_at < '2024-12-31 17:00:00', pi.pno, null)) 12月累计下单量
    ,count(if(pi.created_at > '2024-12-31 17:00:00' and pi.created_at < '2025-01-31 17:00:00', pi.pno, null)) 1月累计下单量
    ,count(distinct if(pi.created_at > '2024-11-30 17:00:00' and pi.created_at < '2024-12-31 17:00:00' and plt.pno is not null, pi.pno, null)) 12判责破损量
    ,count(distinct if(pi.created_at > '2024-12-31 17:00:00' and pi.created_at < '2025-01-31 17:00:00' and plt.pno is not null, pi.pno, null)) 1月判责破损量
from fle_staging.parcel_info pi
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join bi_pro.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 6 and plt.duty_result = 2
where
    pi.returned = 0
    and pi.article_category = 3 -- 数码
    and pi.created_at > '2024-11-30 17:00:00'
    and pi.created_at < '2025-01-31 17:00:00'
group by pi.src_name, ss.name
