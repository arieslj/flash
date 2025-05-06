select
    case vrv.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,bc.client_name 客户
    ,vrv.link_id 单号
    ,case vrv.visit_state
        when 1 then '待回访'
        when 2 then '沟通中'
        when 3 then '多次未联系上客户'
        when 4 then '已回访'
        when 5 then '因同包裹生成其他回访任务关闭'
        when 6 then 'VR回访结果=99关闭'
        when 7 then '超回访时效关闭'
    end  回访状态
    ,if(vrv.visit_state in (3,4,5,6,7), '完成', '未完成') 是否完成
    ,vrv.created_at 回访任务创建时间
    ,case
        when vrv.created_at >= date_add('${date}', interval 9 hour) and vrv.created_at < date_add('${date}', interval 17 hour) then '今日9点-今日17点'
        when vrv.created_at >= date_sub('${date}', interval 7 hour) and vrv.created_at < date_add('${date}', interval 9 hour) then '昨日17点-今日9点'
    end 时间段
    ,vrv.visit_num 回访次数
    ,if(vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ), 'IVR', '人工') 应处理人
    ,case cdt.state
        when 0 then '未处理'
        when 1 then '已处理'
        when 2 then '沟通中'
        when 3 then '支付驳回'
        when 4 then '客户未处理'
        when 5 then '转交闪速系统'
        when 6 then '转交QAQC'
    end 绑定疑难件处理状态
    ,case
        when vrv.type = 3 and vrv.visit_state in (3,7) or json_extract(vrv.extra_value, '$.rejection_delivery_again') = 1 then '退件' -- 多次联系不上、超时效和回访结果是退件
        when vrv.type = 3 and json_extract(vrv.extra_value, '$.rejection_delivery_again') = 2 then '继续派送' -- 继续派送
        when vrv.type = 8 and vrv.visit_state in (3,7) or vrv.visit_result = 44 then '退件' --  多次联系不上和回访结果是退件
        when vrv.type = 8 and vrv.visit_result = 43 then '继续派送'
        else '异常关闭'
    end '回访处理结果（回访结果，不代表包裹最终结果）'
#     ,count(vrv.id) 回访任务量
#     ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at >= date_sub('${date}', interval 7 hour), vrv.id, null)) 历史积压处理完成量 -- 查训当日处理完成量
#     ,count(if(vrv.visit_state in (1,2), vrv.id, null )) 历史积压未完成量
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
join tmpale.tmp_ph_client_visit_info t on t.type = vrv.type and bc.client_name = t.client_name
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(vrv.extra_value, '$.diff_id')
where
    vrv.type in (3,8)
#     and vrv.created_at <= date_sub('${date}', interval 7 hour) -- 昨天17点之前
    and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
    and
        (
            (vrv.visit_state in (3,4,5,6,7) and vrv.updated_at > date_sub('${date}', interval 7 hour)) -- 查询日期17点之后处理
            or vrv.visit_state in (1,2) -- 至今也是未处理
        )
    and vrv.created_at >= date_sub('${date}', interval 7 hour)
    and vrv.created_at < date_add('${date}', interval 17 hour) -- 当日17-20

;

select
    vrv.visit_result
    ,count(1)
from nl_production.violation_return_visit vrv
where
    vrv.type = 4
group by vrv.visit_result
;

select
    vrv.type
    ,bc.client_name
    ,count(vrv.id) ticket_count
    ,count(if(vrv.visit_state in (3,4,5,6,7) , vrv.id, null)) done_ticket_count
    ,count(if(vrv.visit_state in (3,4,5,6,7) , vrv.id, null))/count(vrv.id) deal_rate
from nl_production.violation_return_visit vrv
left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
where
    vrv.type in (3,8)
    and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
#     and
#         ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ) )
    and vrv.created_at >= date_add('${date}', interval 9 hour)
    and vrv.created_at < date_add('${date}', interval 17 hour) -- 昨日17至今日9点

    ;



select
    case vrv.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,bc.client_name 客户
    ,vrv.link_id 单号
    ,case vrv.visit_state
        when 1 then '待回访'
        when 2 then '沟通中'
        when 3 then '多次未联系上客户'
        when 4 then '已回访'
        when 5 then '因同包裹生成其他回访任务关闭'
        when 6 then 'VR回访结果=99关闭'
        when 7 then '超回访时效关闭'
    end  回访状态
    ,if(vrv.visit_state in (3,4,5,6,7), '完成', '未完成') 是否完成
    ,vrv.created_at 回访任务创建时间
    ,case
        when vrv.created_at >= date_add('${date}', interval 9 hour) and vrv.created_at < date_add('${date}', interval 17 hour) then '今日9点-今日17点'
        when vrv.created_at >= date_sub('${date}', interval 7 hour) and vrv.created_at < date_add('${date}', interval 9 hour) then '昨日17点-今日9点'
    end 时间段
    ,vrv.visit_num 回访次数
    ,if(vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ), 'IVR', '人工') 应处理人
    ,case cdt.state
        when 0 then '未处理'
        when 1 then '已处理'
        when 2 then '沟通中'
        when 3 then '支付驳回'
        when 4 then '客户未处理'
        when 5 then '转交闪速系统'
        when 6 then '转交QAQC'
    end 绑定疑难件处理状态
    ,case
        when vrv.type = 3 and vrv.visit_state in (3,7) or json_extract(vrv.extra_value, '$.rejection_delivery_again') = 1 then '退件' -- 多次联系不上、超时效和回访结果是退件
        when vrv.type = 3 and json_extract(vrv.extra_value, '$.rejection_delivery_again') = 2 then '继续派送' -- 继续派送
        when vrv.type = 8 and vrv.visit_state in (3,7) or vrv.visit_result = 44 then '退件' --  多次联系不上和回访结果是退件
        when vrv.type = 8 and vrv.visit_result = 43 then '继续派送'
        else '异常关闭'
    end '回访处理结果（回访结果，不代表包裹最终结果）'
#     ,count(vrv.id) 回访任务量
#     ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at >= date_sub('${date}', interval 7 hour), vrv.id, null)) 历史积压处理完成量 -- 查训当日处理完成量
#     ,count(if(vrv.visit_state in (1,2), vrv.id, null )) 历史积压未完成量
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
join tmpale.tmp_ph_client_visit_info t on t.type = vrv.type and bc.client_name = t.client_name
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(vrv.extra_value, '$.diff_id')
where
    vrv.type in (3,8)
    and vrv.visit_state != 0
#     and vrv.created_at <= date_sub('${date}', interval 7 hour) -- 昨天17点之前
    and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
#     and
#         (
#             (vrv.visit_state in (3,4,5,6,7) and vrv.updated_at > date_sub('${date}', interval 7 hour)) -- 查询日期17点之后处理
#             or vrv.visit_state in (1,2) -- 至今也是未处理
#         )
    and vrv.created_at >= date_sub('${date}', interval 7 hour)
    and vrv.created_at < date_add('${date}', interval 17 hour)
