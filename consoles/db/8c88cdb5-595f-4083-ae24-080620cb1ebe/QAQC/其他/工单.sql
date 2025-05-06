select
    a.order_no 工单编号
    ,a.created_staff_info_id 工单发起人
    ,a.title 工单标题
    ,a.content 工单内容
    ,a.reply_at 最后一次回复时间
    ,a.reply_content 最后一次回复内容
    ,a.staff_info_id 最后一次回复人
from
    (
        select
            wo.order_no
            ,wo.id
            ,wo.created_staff_info_id
            ,wo.title
            ,wo.content
            ,wor.content reply_content
            ,wo.created_at reply_at
            ,wor.staff_info_id
            ,row_number() over (partition by wo.order_no order by wo.created_at desc) rk
        from bi_pro.work_order wo
        left join bi_pro.work_order_reply wor on wor.order_id = wo.id
        where
            wo.created_at >= '2024-02-01'
            and wo.created_at < '2024-03-01'
           -- and wo.latest_reply_at is null
    ) a
where
    a.rk = 1 or a.rk is null