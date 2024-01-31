-- 需求文档：https://flashexpress.feishu.cn/docx/YgzLdAg24oG93qxhMpGcWSKbnZd

select
    date(a.wo_at) 工单创建日期
    ,datediff(a.wo_at, a.plt_at) 工单发起时任务生成天数
    ,a.created_staff_info_id 工单发起人
    ,count(distinct a.id) 任务数
from
    (
        select
            plt.created_at plt_at
            ,wo.created_at wo_at
            ,plt.id
            ,wo.created_staff_info_id
            ,row_number() over (partition by plt.id order by wo.created_at) rk
        from ph_bi.parcel_lose_task plt
        join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        where
            plt.source = 3
            and plt.created_at >= '2023-11-01'
            and plt.created_at < '2023-12-01'
    ) a
where
    a.rk = 1
group by 1,2,3
;



select
    case
        when a1.time_diff/60 <= 24 then '24小时内'
        when a1.time_diff/60 > 24 and a1.time_diff/60 <= 48 then '24-48小时内'
        when a1.time_diff/60 > 48 and a1.time_diff/60 <= 72 then '48-72小时内'
        when a1.time_diff/60 > 72 then '72小时以上'
    end  时间差
    ,count(distinct a1.id) 任务数
from
    (
        select
            timestampdiff(minute, a.plt_at, a.operate_at) time_diff
            ,a.id
        from
            (
                select
                    plt.id
                    ,plt.created_at plt_at
                    ,pcol.action
                    ,pcol.operator_id
                    ,pcol.created_at operate_at
                    ,row_number() over (partition by plt.id order by pcol.created_at) rk
                from ph_bi.parcel_lose_task plt
                join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
                where
                    plt.source = 3
                    and plt.created_at >= '2023-11-01'
                    and plt.created_at < '2023-12-01'
                    and pcol.action in (3,4)
            ) a
        where
            a.rk = 1
            and a.operator_id in (10000,10001)
            and a.action = 3

        union

        select
            timestampdiff(minute, plt.created_at, plt.updated_at) time_diff
            ,plt.id
        from ph_bi.parcel_lose_task plt
        where
            plt.source = 3
            and plt.created_at >= '2023-11-01'
            and plt.created_at < '2023-12-01'
            and plt.operator_id in (10000,10001)
            and plt.state = 5
    ) a1
group by 1



;


select
    pi.pno
from ph_staging.parcel_info pi
left join ph_staging.parcel_additional_info pai on pai.pno = pi.pno
left join ph_bi.parcel_detail pd on pd.pno = pi.pno
where
    pi.state = 8
    and pai.parcel_miss_enabled = 0
    and pd.last_valid_store_id != 'PH19040F05'