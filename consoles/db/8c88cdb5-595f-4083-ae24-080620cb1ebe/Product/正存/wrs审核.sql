select
    case car.credentials_category
        when 1 then '身份证'
        when 2 then '护照'
    end 证件类型
    ,case car.submit_channel_category
        when 1 then 'web'
        when 2 then 'app'
        when 3 then 'bs'
        when 4 then '巴枪'
    end 提交渠道
    ,car.mobile 手机号
    ,car.credentials_num 证件号
    ,if(car.operator_id = 10000 and car.remark = '自动审核通过', 'AI', '人工') 审核类型
    ,car.remark 审核未通过原因
    ,c2.pho_cnt 审核次数
from fle_staging.customer_approve_record car
left join
    (
        select
            car.mobile
            ,car.credentials_num
            ,count(car.id) pho_cnt
        from fle_staging.customer_approve_record car
        where
            car.created_at >= '2023-06-30 17:00:00'
            and car.created_at < '2024-12-31 17:00:00'
        group by  1,2
    ) c2 on c2.mobile = car.mobile and c2.credentials_num = car.credentials_num
where
    car.created_at >= '2024-06-30 17:00:00'
    and car.created_at < '2024-12-31 17:00:00'
    and car.audit_type = 1
    and car.state = 2


;


select
    car.*
    ,concat('https://', sa.bucket_name, '.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) url
from fle_staging.customer_approve_record car
left join fle_staging.sys_attachment sa on if(car.audit_type !=1 and car.relating_key is not null, car.relating_key, car.id) = sa.oss_bucket_key
where
    car.state = 0
    and car.deleted = 0