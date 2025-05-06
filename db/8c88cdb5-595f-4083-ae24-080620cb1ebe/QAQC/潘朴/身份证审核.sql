select
    count(if(car.state = 1, car.id, null)) / count(car.id) as '通过率'
    ,count(if(car.state = 1, car.id, null)) 人工审核通过量
    ,count(if(car.state = 2, car.id, null)) 人工审核驳回量
from fle_staging.customer_approve_record car
where
    car.created_at > '2024-12-31 17:00:00'
    and car.created_at < '2025-01-31 17:00:00'
   -- and car.credentials_category = 1 -- 身份证
    and car.state in (1,2)
    and car.operator_id not in (10000,10001,9999)
# group by car.state