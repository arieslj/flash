select
    '${date}' 统计日期
    ,case t.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,t.client_name 平台
    ,coalesce(his.积压_待回访量, 0) + coalesce(his.积压_沟通中量, 0) + coalesce(nw.今日新增_待回访量, 0) + coalesce(nw.今日新增_沟通中量, 0) 当日未处理完成量

    ,his.积压任务量
    ,his.积压_回访失败量
    ,his.积压_多次联系不上量
    ,his.积压_已回访量
    ,his.积压完成率
    ,his.积压_待回访量
    ,his.积压_沟通中量
    ,his.积压_沟通中_拨打一次量
    ,his.积压_沟通中_拨打二次量
    ,his.积压_沟通中_拨打三次及以上量

    ,nw.今日新增任务量
    ,nw.今日新增_回访失败量
    ,nw.今日新增_多次联系不上量
    ,nw.今日新增_已回访量
    ,nw.今日新增完成率
    ,nw.今日新增_待回访量
    ,nw.今日新增_沟通中量
    ,nw.今日新增_沟通中_拨打一次量
    ,nw.今日新增_沟通中_拨打二次量
    ,nw.今日新增_沟通中_拨打三次及以上量
from tmpale.tmp_th_client_visit_info t
left join
    (
        select
            vrv.type
            ,coalesce(bc.client_name, '非平台') as client_name
            ,count(vrv.id) as 积压任务量
            ,count(distinct if(vrv.visit_state not in (1,2,3,4), vrv.id, null)) 积压_回访失败量
            ,count(distinct if(vrv.visit_state = 3, vrv.id, null)) 积压_多次联系不上量
            ,count(distinct if(vrv.visit_state = 4, vrv.id, null)) 积压_已回访量
            ,count(distinct if(vrv.visit_state not in (1,2), vrv.id, null)) / count(vrv.id)  积压完成率
            ,count(distinct if(vrv.visit_state = 1, vrv.id, null)) 积压_待回访量
            ,count(distinct if(vrv.visit_state = 2, vrv.id, null)) 积压_沟通中量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num = 1, vrv.id, null)) 积压_沟通中_拨打一次量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num = 2, vrv.id, null)) 积压_沟通中_拨打二次量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num >= 3, vrv.id, null)) 积压_沟通中_拨打三次及以上量
        from nl_production.violation_return_visit vrv
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.created_at <= date_sub('${date}', interval 9 hour) -- 昨天15点之前
            and vrv.created_at >= date_sub(curdate(), interval 1 month ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id != 10001 and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ) ) -- 应人工处理
            and
                (
                    vrv.visit_state in (1,2) and (vrv.updated_at not in (1,2) and vrv.updated_at >= date_sub('${date}', interval 9 hour))  -- 未终态或者终态时间在昨日15点之后
                )
        group by 1,2
    ) his on his.type = t.type and his.client_name = t.client_name
left join
    (
        select
            vrv.type
            ,coalesce(bc.client_name, '非平台') as client_name

            ,count(vrv.id) as 今日新增任务量
            ,count(distinct if(vrv.visit_state not in (1,2,3,4), vrv.id, null)) 今日新增_回访失败量
            ,count(distinct if(vrv.visit_state = 3, vrv.id, null)) 今日新增_多次联系不上量
            ,count(distinct if(vrv.visit_state = 4, vrv.id, null)) 今日新增_已回访量
            ,count(distinct if(vrv.visit_state not in (1,2), vrv.id, null)) / count(vrv.id)  今日新增完成率

            ,count(distinct if(vrv.visit_state = 1, vrv.id, null)) 今日新增_待回访量

            ,count(distinct if(vrv.visit_state = 2, vrv.id, null)) 今日新增_沟通中量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num = 1, vrv.id, null)) 今日新增_沟通中_拨打一次量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num = 2, vrv.id, null)) 今日新增_沟通中_拨打二次量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num >= 3, vrv.id, null)) 今日新增_沟通中_拨打三次及以上量
        from nl_production.violation_return_visit vrv
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.created_at > date_sub('${date}', interval 9 hour) -- 昨天15点之前
            and vrv.created_at <= date_add('${date}', interval 15 hour) -- 今日15点之前
            and
                ( vrv.visit_staff_id != 10001 and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ) ) -- 应人工处理
         --   and vrv.id  = '20343225'
        group by 1,2
    ) nw on nw.type = t.type and nw.client_name = t.client_name
order by 2,3






;

-- IVR



select
    '${date}' 统计日期
    ,case t.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,t.client_name 平台
    ,coalesce(his.积压_待回访量, 0) + coalesce(his.积压_沟通中量, 0) + coalesce(nw.今日新增_待回访量, 0) + coalesce(nw.今日新增_沟通中量, 0) 当日未处理完成量

    ,his.积压任务量
    ,his.积压_回访失败量
    ,his.积压_多次联系不上量
    ,his.积压_已回访量
    ,his.积压完成率
    ,his.积压_待回访量
    ,his.积压_沟通中量
    ,his.积压_沟通中_拨打一次量
    ,his.积压_沟通中_拨打二次量
    ,his.积压_沟通中_拨打三次及以上量

    ,nw.今日新增任务量
    ,nw.今日新增_回访失败量
    ,nw.今日新增_多次联系不上量
    ,nw.今日新增_已回访量
    ,nw.今日新增完成率
    ,nw.今日新增_待回访量
    ,nw.今日新增_沟通中量
    ,nw.今日新增_沟通中_拨打一次量
    ,nw.今日新增_沟通中_拨打二次量
    ,nw.今日新增_沟通中_拨打三次及以上量
from tmpale.tmp_th_client_visit_info t
left join
    (
        select
            vrv.type
            ,coalesce(bc.client_name, '非平台') as client_name
            ,count(vrv.id) as 积压任务量
            ,count(distinct if(vrv.visit_state not in (1,2,3,4), vrv.id, null)) 积压_回访失败量
            ,count(distinct if(vrv.visit_state = 3, vrv.id, null)) 积压_多次联系不上量
            ,count(distinct if(vrv.visit_state = 4, vrv.id, null)) 积压_已回访量
            ,count(distinct if(vrv.visit_state not in (1,2), vrv.id, null)) / count(vrv.id)  积压完成率
            ,count(distinct if(vrv.visit_state = 1, vrv.id, null)) 积压_待回访量
            ,count(distinct if(vrv.visit_state = 2, vrv.id, null)) 积压_沟通中量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num = 1, vrv.id, null)) 积压_沟通中_拨打一次量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num = 2, vrv.id, null)) 积压_沟通中_拨打二次量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num >= 3, vrv.id, null)) 积压_沟通中_拨打三次及以上量
        from nl_production.violation_return_visit vrv
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.created_at <= date_sub('${date}', interval 9 hour) -- 昨天15点之前
            and vrv.created_at >= date_sub(curdate(), interval 1 month ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ) )-- 应IVR处理
            and
                (
                    vrv.visit_state in (1,2) and (vrv.updated_at not in (1,2) and vrv.updated_at >= date_sub('${date}', interval 9 hour))  -- 未终态或者终态时间在昨日15点之后
                )
        group by 1,2
    ) his on his.type = t.type and his.client_name = t.client_name
left join
    (
        select
            vrv.type
            ,coalesce(bc.client_name, '非平台') as client_name

            ,count(vrv.id) as 今日新增任务量
            ,count(distinct if(vrv.visit_state not in (1,2,3,4), vrv.id, null)) 今日新增_回访失败量
            ,count(distinct if(vrv.visit_state = 3, vrv.id, null)) 今日新增_多次联系不上量
            ,count(distinct if(vrv.visit_state = 4, vrv.id, null)) 今日新增_已回访量
            ,count(distinct if(vrv.visit_state not in (1,2), vrv.id, null)) / count(vrv.id)  今日新增完成率

            ,count(distinct if(vrv.visit_state = 1, vrv.id, null)) 今日新增_待回访量

            ,count(distinct if(vrv.visit_state = 2, vrv.id, null)) 今日新增_沟通中量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num = 1, vrv.id, null)) 今日新增_沟通中_拨打一次量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num = 2, vrv.id, null)) 今日新增_沟通中_拨打二次量
            ,count(distinct if(vrv.visit_state = 2 and vrv.visit_num >= 3, vrv.id, null)) 今日新增_沟通中_拨打三次及以上量
        from nl_production.violation_return_visit vrv
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.created_at > date_sub('${date}', interval 9 hour) -- 昨天15点之前
            and vrv.created_at <= date_add('${date}', interval 15 hour) -- 今日15点之前
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ) ) -- 应人工处理
         --   and vrv.id  = '20343225'
        group by 1,2
    ) nw on nw.type = t.type and nw.client_name = t.client_name
order by 2,3


;


select
    *
from bi_pro.hr_staff_info hsi
where
    hsi.staff_info_id = ''
    and hsi.state = 1 -- 1:在职