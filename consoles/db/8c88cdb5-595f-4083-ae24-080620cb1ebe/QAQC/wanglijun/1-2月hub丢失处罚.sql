select
    *
from bi_pro.abnormal_message am
join
    (
        select
            distinct
            plt.id
        from bi_pro.parcel_lose_task plt
        join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.created_at > date_sub(curdate(), interval 6 month)
            and plr.created_at > date_sub(curdate(), interval 6 month)
            and plt.duty_result = 1
            and plt.state = 6
            and ss.category in (8,12)
    ) plt on plt.id = (am.extra_info, '$.losr_task_id')
where
    am.abnormal_time >= '2025-01-01'
    and am.abnormal_time < '2025-03-01'
    and am.punish_category = 7
;


select
    am.month as 月份
    ,am.name 网点
    ,am.t_value 判责原因
    ,count(distinct am.unique_id) 判责量
    ,count(distinct if(am.appeal_or_not = 'y', am.unique_id, null)) 申诉量
from
    (
        select
            substr(am.abnormal_time, 1, 7) as month
            ,ss.name
            ,t.t_value
            ,if(am.abnormal_object = 1, am.average_merge_key, am.id) unique_id
            ,if(am.isappeal > 1, 'y', 'n') appeal_or_not
        from bi_pro.abnormal_message am
        join bi_pro.parcel_lose_task plt on plt.id = json_extract(am.extra_info, '$.losr_task_id')
        left join fle_staging.sys_store ss on ss.id = am.store_id
        left join bi_pro.translations t on plt.duty_reasons=t.t_key and t.lang = 'zh-CN'
        where
            am.abnormal_time >= '2025-01-01'
            and am.abnormal_time < '2025-03-01'
            and am.punish_category = 7
            and plt.updated_at > '2024-12-01'
            and ss.category in (8,12)
    ) am
group by 1,2,3
