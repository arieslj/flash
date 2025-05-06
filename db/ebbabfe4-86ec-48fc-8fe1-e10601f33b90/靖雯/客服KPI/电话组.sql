select
    coalesce(a.created_staff_info_id, 'TOTAL') 工号
    ,a.ratio 72H工单关闭率
from
    (
        select
            wo.created_staff_info_id
            ,count(if(timestampdiff(hour, wo.created_at, wo.closed_at) < 72, wo.id, null)) / count(wo.id) ratio
        from my_bi.work_order wo
        where
            wo.created_staff_info_id in ('131965', '140482', '147289', '144301', '145033')
            and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
            and wo.created_at < date_format(curdate(), '%Y-%m-01')
            and wo.order_type != 21
            and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
        group by 1
        with rollup
    ) a

;


select
    wo.created_staff_info_id
    ,hsi.name
    ,wo.created_at
    ,wo.closed_at
    ,timestampdiff(hour, wo.created_at, wo.closed_at) diff
from my_bi.work_order wo
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = wo.created_staff_info_id
where
    wo.created_staff_info_id in  ('131965', '140482', '147289', '144301', '145033')
    and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
    and wo.created_at < date_format(curdate(), '%Y-%m-01')



;



 select
    wo.created_staff_info_id
    ,month(wo.created_at) 月份
    ,count(if(timestampdiff(hour, wo.created_at, wo.closed_at) < 72, wo.id, null)) / count(wo.id) ratio
from my_bi.work_order wo
where
    wo.created_staff_info_id in ('131965', '140482', '144300', '144301', '144643', '145033')
#     and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
#     and wo.created_at < date_format(curdate(), '%Y-%m-01')
    and wo.created_at > '2024-12-01'
    and wo.created_at < '2024-12-26'
    and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
group by 1,2
