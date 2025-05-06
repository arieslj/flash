select
    car.mobile
    ,car.credentials_num
    ,concat('https://', sa.bucket_name, '.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) 证件照片
from fle_staging.customer_approve_record car
left join fle_staging.sys_attachment sa on sa.oss_bucket_key = car.id
where
    car.credentials_category = 1
    and car.created_at > '2024-07-31 17:00:00'
    and car.created_at < '2024-08-31 17:00:00'