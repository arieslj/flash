select
    count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 <= 12 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-0-12'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 <= 24 and timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 > 12 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-12-24'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 <= 36 and timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 > 24 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-24-36'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 <= 48 and timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 > 36 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-36-48'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 <= 72 and timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 > 48 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-48-72'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 > 72 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-72以上'
from ph_bi.abnormal_customer_complaint acc
left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
where
    acc.created_at >= '2024-05-01'
    and acc.created_at < '2024-06-01'
;

select
    case acc.qaqc_callback_result
        when 0 then 'init'
       when 1 then '多次未联系上客户'
       when 2 then '误投诉'
       when 3 then '真实投诉，后接受道歉'
       when 4 then '真实投诉，后不接受道歉'
       when 5 then '真实投诉，后受到骚扰/威胁'
       when 6 then '没有快递员联系客户道歉'
       when 7 then '客户投诉回访结果'
       when 8 then '确认网点已联系客户道歉'
    end 客户是否原谅道歉
    ,count(acc.id) 计数
from ph_bi.abnormal_customer_complaint acc
where
    acc.created_at >= '2024-05-01'
    and acc.created_at < '2024-06-01'
    and acc.store_callback_expired = 0
group by 1