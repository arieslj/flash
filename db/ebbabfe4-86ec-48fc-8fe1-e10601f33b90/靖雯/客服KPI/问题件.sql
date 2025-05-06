-- 问题件处理完成率

select
    count(a.id) total_count
    ,count(if(a.deal_time < a.dead_line_time, a.id, null)) in_time_count
    ,count(if(a.deal_time < a.dead_line_time, a.id, null)) / count(a.id) as call_rate
from
    (
        select
            cdt.id
            ,convert_tz(cdt.created_at, '+00:00', '+08:00') task_created_at
            ,date_add(date(date_add(cdt.created_at, interval 16 hour)), interval 1 day) dead_line_time
            ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00') deal_time
        from my_staging.customer_diff_ticket cdt
        left join my_staging.diff_info di on di.id = cdt.diff_info_id
        where
            cdt.organization_type = 2
            and cdt.vip_enable = 0 -- 总部客服
            and di.diff_marker_category not in (31) -- 剔除错分
            and cdt.created_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 8 hour)
            and cdt.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 8 hour)
    ) a

;

-- MS工单

with t as
    (
        select
            wo.id
            ,wo.created_at
            ,case
                when wo.speed_level = 2 then date_add(wo.created_at, interval 24 hour)
                when wo.speed_level = 1 and wo.created_at <= date_add(date(wo.created_at), interval 8 hour) then date_add(date(wo.created_at), interval 12 hour)
                when wo.speed_level = 1 and wo.created_at > date_add(date(wo.created_at), interval 8 hour) and wo.created_at <= date_add(date(wo.created_at), interval 16 hour) then date_add(wo.created_at, interval 2 hour)
                when wo.speed_level = 1 and wo.created_at > date_add(date(wo.created_at), interval 16 hour) then date_add(date(date_add(wo.created_at, interval 1 day)), interval 12 hour)
            end dead_line_time
        from my_bi.work_order wo
        where
            wo.store_id = 'customer_manger' -- 客服中心受理
           -- and wo.speed_level = 2
            and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
            and wo.created_at < date_format(curdate(), '%Y-%m-01')
            and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
    )
select
    count(a.id) total_count
    ,count(if(a.fir_reply_time < a.dead_line_time, a.id, null)) in_time_count
    ,count(if(a.fir_reply_time < a.dead_line_time, a.id, null)) / count(a.id) as call_rate
from
    (
        select
            t1.id
            ,t1.created_at
            ,t1.dead_line_time
            ,wor.created_at fir_reply_time
        from t t1
        left join
            (
                select
                    t1.id
                    ,wor.created_at
                    ,row_number() over (partition by t1.id order by wor.created_at) rk
                from my_bi.work_order_reply wor
                join t t1 on t1.id = wor.order_id
                where
                    wor.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
            ) wor on wor.id = t1.id and wor.rk = 1
    ) a


;

-- 72小时工单关闭率

select
    wo.created_staff_info_id 工号
    ,count(if(timestampdiff(hour, wo.created_at, wo.closed_at) < 72, wo.id, null)) / count(wo.id) 72H工单关闭率
from my_bi.work_order wo
where
    wo.created_staff_info_id in ('132191', '147207')
    and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
    and wo.created_at < date_format(curdate(), '%Y-%m-01')
    and wo.order_type != 21
    and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
group by 1


;


-- 理赔首次处理时长


select
    sum(coalesce(timestampdiff(hour, a.created_at, a.first_operated_at), 0)) / count(a.id)  理赔首次处理时长_h
from
    (
        select
            pct.id
            ,pct.created_at
            ,pcol.created_at first_operated_at
            ,row_number() over (partition by pct.id order by pcol.created_at) rk
        from my_bi.parcel_claim_task pct
        left join my_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.action in (18,19,20,21)
        where
            pct.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
            and pct.created_at < date_format(curdate(), '%Y-%m-01')
            and pct.vip_enable = 0
    ) a
where
    a.rk = 1

;




select
    wo.created_staff_info_id 工号
    ,month(wo.created_at) 月份
    ,count(if(timestampdiff(hour, wo.created_at, wo.closed_at) < 72, wo.id, null)) / count(wo.id) 72H工单关闭率
from my_bi.work_order wo
where
    wo.created_staff_info_id in ('132191', '147207')
#     and wo.created_at > date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01')
#     and wo.created_at < date_format(curdate(), '%Y-%m-01')
    and wo.created_at > '2024-12-01'
    and wo.created_at < '2024-12-26'
    and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
group by 1,2
order by 1,2


;












with t as
    (
        select
            wo.id
            ,wo.created_at
            ,case
                when wo.speed_level = 2 then date_add(wo.created_at, interval 24 hour)
                when wo.speed_level = 1 and wo.created_at <= date_add(date(wo.created_at), interval 8 hour) then date_add(date(wo.created_at), interval 12 hour)
                when wo.speed_level = 1 and wo.created_at > date_add(date(wo.created_at), interval 8 hour) and wo.created_at <= date_add(date(wo.created_at), interval 16 hour) then date_add(wo.created_at, interval 2 hour)
                when wo.speed_level = 1 and wo.created_at > date_add(date(wo.created_at), interval 16 hour) then date_add(date(date_add(wo.created_at, interval 1 day)), interval 12 hour)
            end dead_line_time
        from my_bi.work_order wo
        where
            wo.store_id = 'customer_manger' -- 客服中心受理
            and wo.order_type != 21
           -- and wo.speed_level = 2
            and wo.created_at > '2024-12-01'
            and wo.created_at < '2024-12-06'
            and ( wo.status in (1,2,3) or ( wo.status = 4 and wo.closed_at is not null ))
    )
select
    month(a.created_at) 月份
    ,count(a.id) total_count
    ,count(if(a.fir_reply_time < a.dead_line_time, a.id, null)) in_time_count
    ,count(if(a.fir_reply_time < a.dead_line_time, a.id, null)) / count(a.id) as call_rate
from
    (
        select
            t1.id
            ,t1.created_at
            ,t1.dead_line_time
            ,wor.created_at fir_reply_time
        from t t1
        left join
            (
                select
                    t1.id
                    ,wor.created_at
                    ,row_number() over (partition by t1.id order by wor.created_at) rk
                from my_bi.work_order_reply wor
                join t t1 on t1.id = wor.order_id
                where
                    wor.created_at > '2024-10-01'
            ) wor on wor.id = t1.id and wor.rk = 1
    ) a
group by 1



-- 测试

;


select
    cdt.id
    ,di.pno
    ,ddd.cn_element 问题件类型
    ,convert_tz(cdt.created_at, '+00:00', '+08:00') task_created_at
    ,date_add(date(date_add(cdt.created_at, interval 16 hour)), interval 1 day) dead_line_time
    ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00') deal_time
from my_staging.customer_diff_ticket cdt
left join my_staging.diff_info di on di.id = cdt.diff_info_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    cdt.organization_type = 2
    and cdt.vip_enable = 0 -- 总部客服
    and di.diff_marker_category not in (31) -- 剔除错分
    and cdt.created_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 8 hour)
    and cdt.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 8 hour)