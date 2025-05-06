-- 多次尝试派送时效和拒收回访时效
select
    '9-20' 时间段
    ,bc.client_name 客户
    ,count(distinct if(vrv.visit_num = 1, vrv.link_id, null)) 第一次拿到结果包裹量
    ,count(distinct if(vrv.visit_num = 2, vrv.link_id, null)) 第二次拿到结果包裹量
    ,count(distinct if(vrv.visit_num = 3, vrv.link_id, null)) 第三次次拿到结果包裹量
from nl_production.violation_return_visit vrv
left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
where
    vrv.visit_staff_id = 10001 -- IVR回访
    and vrv.type = 8 -- 多次尝试派送回访
    and vrv.visit_state in (3,4) -- 已回访
    and vrv.created_at >= '2023-08-15 09:00:00'
    and vrv.created_at < '2023-08-15 20:00:00'
    and vrv.updated_at < '2023-08-16 00:00:00'
group by 1,2

# union all
#
# select
#     '9-10' 时间段
#     ,bc.client_name 客户
#     ,count(distinct if(vrv.visit_num = 1, vrv.link_id, null)) 第一次拿到结果包裹量
#     ,count(distinct if(vrv.visit_num = 2, vrv.link_id, null)) 第二次拿到结果包裹量
#     ,count(distinct if(vrv.visit_num = 3, vrv.link_id, null)) 第三次次拿到结果包裹量
# from nl_production.violation_return_visit vrv
# left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
# where
#     vrv.visit_staff_id = 10001 -- IVR回访
#     and vrv.type = 8 -- 多次尝试派送回访
#     and vrv.visit_state = 4 -- 已回访
#     and vrv.created_at >= '2023-08-16 09:00:00'
#     and vrv.created_at < '2023-08-16 20:00:00'
# group by 1,2

;

-- 平均时长，9-20

select
    a.client_name
    ,sum(if(a.visit_num = 1, a.diff_time, 0 ))/count(if(a.visit_num = 1, a.id, null)) 第一次拿到结果的平均时长
    ,sum(if(a.visit_num = 2, a.diff_time, 0 ))/count(if(a.visit_num = 2, a.id, null)) 第二次拿到结果的平均时长
    ,sum(if(a.visit_num = 3, a.diff_time, 0 ))/count(if(a.visit_num = 3, a.id, null)) 第三次拿到结果的平均时长
from
    (
        select
            bc.client_name
            ,vrv.visit_num
            ,vrv.id
            ,vrv.updated_at
            ,timestampdiff(second ,vrv.created_at, vrv.updated_at)/3600 diff_time
        from nl_production.violation_return_visit vrv
        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        where
            vrv.visit_staff_id = 10001 -- IVR回访
            and vrv.type = 8 -- 多次尝试派送回访
            and vrv.visit_state in (3,4) -- 已回访
            and vrv.created_at >= '2023-08-15 09:00:00'
            and vrv.created_at < '2023-08-15 20:00:00'
            and vrv.updated_at < '2023-08-16 00:00:00'
            and vrv.visit_num in (1,2,3)
    ) a
group by 1

;
-- 明细

select
    bc.client_name
    ,vrv.visit_num
    ,vrv.id
    ,timestampdiff(second ,vrv.created_at, vrv.updated_at)/3600 diff_time
from nl_production.violation_return_visit vrv
left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
where
    vrv.visit_staff_id = 10001 -- IVR回访
    and vrv.type = 8 -- 多次尝试派送回访
    and vrv.visit_state = 4 -- 已回访
    and vrv.created_at >= '2023-08-15 09:00:00'
    and vrv.created_at < '2023-08-15 20:00:00'
    and vrv.visit_num in (1,2,3)

;


select
    '9-20' 时间段
    ,bc.client_name 客户
    ,vrv.link_id
    ,vrv.visit_state
#     ,count(distinct if(vrv.visit_num = 1, vrv.link_id, null)) 第一次拿到结果包裹量
#     ,count(distinct if(vrv.visit_num = 2, vrv.link_id, null)) 第二次拿到结果包裹量
#     ,count(distinct if(vrv.visit_num = 3, vrv.link_id, null)) 第三次次拿到结果包裹量
from nl_production.violation_return_visit vrv
left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
where
    vrv.visit_staff_id = 10001 -- IVR回访
    and vrv.type = 8 -- 多次尝试派送回访
    and vrv.visit_state in (3,4) -- 已回访
    and vrv.created_at >= '2023-08-15 09:00:00'
    and vrv.created_at < '2023-08-15 20:00:00'
    and vrv.updated_at < '2023-08-16 00:00:00'
    and visit_num = 3
    and bc.client_name = 'shopee'

;

--  时间点测算

select
    count(vrv.id) 任务量
    ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at <  date_add('${date}', interval 1 day), vrv.id, null))/count(vrv.id) 今日完成占比
#     ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at < concat('${date}', ' 18:00:00'), vrv.id, null))/count(vrv.id) 18点前完成占比
#     ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at < concat('${date}', ' 19:00:00'), vrv.id, null))/count(vrv.id) 19点前完成占比
#     ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at < concat('${date}', ' 20:00:00'), vrv.id, null))/count(vrv.id) 20点前完成占比
from nl_production.violation_return_visit vrv
left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
where
    (vrv.visit_staff_id = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 )) -- IVR已回访+ 等待ivr回访
    and vrv.type = 8
    and vrv.created_at >= concat('${date}', ' 09:00:00')
    and vrv.created_at < concat('${date}', ' 19:00:00')

;

-- 次日时间点测算

select
    count(vrv.id) 任务量
    ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at <  date_add('${date}', interval 36 hour), vrv.id, null))/count(vrv.id) 次日12点完成占比
    ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at <  date_add('${date}', interval 37 hour), vrv.id, null))/count(vrv.id) 次日13点完成占比
    ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at <  date_add('${date}', interval 38 hour), vrv.id, null))/count(vrv.id) 次日14点完成占比
    ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at <  date_add('${date}', interval 39 hour), vrv.id, null))/count(vrv.id) 次日15点完成占比
#     ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at < concat('${date}', ' 18:00:00'), vrv.id, null))/count(vrv.id) 18点前完成占比
#     ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at < concat('${date}', ' 19:00:00'), vrv.id, null))/count(vrv.id) 19点前完成占比
#     ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at < concat('${date}', ' 20:00:00'), vrv.id, null))/count(vrv.id) 20点前完成占比
from nl_production.violation_return_visit vrv
left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
where
    (vrv.visit_staff_id = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 )) -- IVR已回访+ 等待ivr回访
    and vrv.type = 8
    and vrv.created_at >= concat('${date}', ' 16:00:00')
    and vrv.created_at < date_add('${date}', interval 34 hour)
;

