select
    count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 < 24 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-24'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 < 36 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-36'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 < 48 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-48'
    ,count(if(timestampdiff(second, am.created_at, acc.store_callback_at)/3600 < 24 and acc.store_callback_expired = 0, acc.id, null)) '任务发放时间-道歉时间-24'
    ,count(if(timestampdiff(second, am.created_at, acc.store_callback_at)/3600 < 36 and acc.store_callback_expired = 0, acc.id, null)) '任务发放时间-道歉时间-36'
    ,count(if(timestampdiff(second, am.created_at, acc.store_callback_at)/3600 < 48 and acc.store_callback_expired = 0, acc.id, null)) '任务发放时间-道歉时间-48'
    ,count(distinct acc.id) 投诉量
    ,count(if(acc.store_callback_expired = 0 and acc.store_callback_at is not null, acc.id, null)) 有道歉量
    ,count(if(acc.store_callback_expired != 0 or  acc.store_callback_at is null, acc.id, null)) 无道歉量
from bi_pro.abnormal_customer_complaint acc
left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id
where
    acc.created_at >= '2023-11-01'
    and acc.created_at < '2023-12-01'
# group by 1