select
    wo.created_staff_info_id 工号
    ,count(if(timestampdiff(hour, wo.created_at, wo.closed_at) < 72, wo.id, null)) / count(wo.id) 72H工单关闭率
from my_bi.work_order wo
where
    wo.created_staff_info_id in ('136920', '133641')
    and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
    and wo.created_at < date_format(curdate(), '%Y-%m-01')
    and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
group by 1


;

-- 年度总结

select
    wo.created_staff_info_id 工号
    ,month(wo.created_at) 月份
    ,count(if(timestampdiff(hour, wo.created_at, wo.closed_at) < 72, wo.id, null)) / count(wo.id) 72H工单关闭率
from my_bi.work_order wo
where
    wo.created_staff_info_id in ('136920', '133641')
#     and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
#     and wo.created_at < date_format(curdate(), '%Y-%m-01')
    and wo.created_at > '2024-12-01'
    and wo.created_at < '2024-12-06'
    and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
group by 1,2
order by 1,2
;


