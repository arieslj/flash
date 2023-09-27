-- IVR
select
    case t.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,t.client_name 客户名称
    ,his.回访任务量 历史积压量
    ,his.历史积压处理完成量
    ,his.历史积压未完成量
    ,upp.ticket_count '昨日17-今日9点创建量'
    ,upp.done_ticket_count '昨日17-今日9点处理完成量'
    ,upp.deal_rate '昨日17-今日9点完成率'
    ,low.ticket_count '今日9点-今日17点生成量'
    ,low.done_ticket_count '今日9点-今日17点处理完成量'
    ,low.deal_rate '今日9点-今日17点处理完成率'
    ,tod.未开始拨打数量
    ,tod.拨打一次数量
    ,tod.拨打两次数量
    ,tod.拨打完成数量
    ,total.ticket_count  当日总任务量 -- 17-17
    ,total.day_deal_rate 当日处理完成率  -- 17-17
    ,total.undeal_diff_count 处理完包裹中关联的疑难件未解锁的量 -- 17-17
    ,result.delivery_again_count 继续派送量
    ,result.rts_count 退件量
    ,result.close_count 异常关闭量
from tmpale.tmp_ph_client_visit_info t
left join
    (
        select
#             case vrv.type
#                 when 1 then '揽件任务异常取消'
#                 when 2 then '虚假妥投'
#                 when 3 then '收件人拒收'
#                 when 4 then '标记客户改约时间'
#                 when 5 then 'KA现场不揽收'
#                 when 6 then '包裹未准备好'
#                 when 7 then '上报错分未妥投'
#                 when 8 then '多次尝试派送失败'
#             end vrv_type
            vrv.type
            ,bc.client_name
            ,count(vrv.id) 回访任务量
            ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at >= date_sub('${date}', interval 7 hour), vrv.id, null)) 历史积压处理完成量 -- 查训当日处理完成量
            ,count(if(vrv.visit_state in (1,2), vrv.id, null )) 历史积压未完成量
        from nl_production.violation_return_visit vrv
        join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.created_at <= date_sub('${date}', interval 7 hour) -- 昨天17点之前
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                (
                    (vrv.visit_state in (3,4,5,6,7) and vrv.updated_at > date_sub('${date}', interval 7 hour)) -- 查询日期17点之后处理
                    or vrv.visit_state in (1,2) -- 至今也是未处理
                )
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ) ) -- IVR应处理
        group by 1,2
    ) his on his.client_name = t.client_name and his.type = t.type
left join
    (
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
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ) )
            and vrv.created_at >= date_sub('${date}', interval 7 hour)
            and vrv.created_at < date_add('${date}', interval 9 hour) -- 昨日17至今日9点
        group by 1,2
    ) upp on upp.type = t.type and upp.client_name = t.client_name
left join
    (
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
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ) )
            and vrv.created_at >= date_add('${date}', interval 9 hour)
            and vrv.created_at < date_add('${date}', interval 17 hour) -- 昨日17至今日9点
        group by 1,2
    ) low on low.type = t.type and low.client_name = t.client_name
left join
    (
        select
            vrv.type
            ,bc.client_name
            ,count(vrv.id) ticket_count
            ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at < date_add('${date}', interval 1 day), vrv.id, null))/count(vrv.id) day_deal_rate
            ,count(if(cdt.state != 1 and vrv.visit_state in (3,4,7) and cdt.id is not null, vrv.id, null)) undeal_diff_count
        from nl_production.violation_return_visit vrv
        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(vrv.extra_value, '$.diff_id')
        where
            vrv.type in (3,8)
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ))
            and vrv.created_at >= date_sub('${date}', interval 7 hour)
            and vrv.created_at < date_add('${date}', interval 17 hour) -- 17-17
        group by 1,2
    ) total on total.type = t.type and total.client_name = t.client_name
left join
    (
        select
            a1.type
            ,a1.client_name
            ,count(if(a1.result = '退件', a1.id, null)) rts_count
            ,count(if(a1.result = '继续派送', a1.id, null)) delivery_again_count
            ,count(if(a1.result = '异常关闭', a1.id, null)) close_count
        from
            (
                select
                    a.type
                    ,a.client_name
                    ,case
                        when a.type = 3 and a.visit_state in (3,7) or a.rejection_delivery_again = 1 then '退件' -- 多次联系不上、超时效和回访结果是退件
                        when a.type = 3 and a.rejection_delivery_again = 2 then '继续派送' -- 继续派送
                        when a.type = 8 and a.visit_state in (3,7) or a.visit_result = 44 then '退件' --  多次联系不上和回访结果是退件
                        when a.type = 8 and  a.visit_result = 43 then '继续派送'
                        else '异常关闭'
                    end result
                    ,a.id
                from
                    (
                        select
                            vrv.type
                            ,bc.client_name
                            ,vrv.visit_state
                            ,vrv.visit_result
                            ,vrv.id
                            ,json_extract(vrv.extra_value, '$.rejection_delivery_again') rejection_delivery_again
                        from nl_production.violation_return_visit vrv
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
                        where
                            vrv.type in (3,8)
                            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
                            and
                                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ))
                            and vrv.created_at >= date_sub('${date}', interval 7 hour)
                            and vrv.created_at < date_add('${date}', interval 17 hour)
                    ) a
            ) a1
        group by 1,2
    ) result on result.type = t.type and result.client_name = t.client_name
left join
    (
        select
            vrv.type
            ,bc.client_name
            ,count(if(vrv.visit_num = 0 ,vrv.id, null)) 未开始拨打数量
            ,count(if(vrv.visit_num = 1, vrv.id, null)) 拨打一次数量
            ,count(if(vrv.visit_num = 2, vrv.id, null)) 拨打两次数量
            ,count(if(vrv.visit_state in (3,4,5,6,7), vrv.id, null)) 拨打完成数量
        from nl_production.violation_return_visit vrv
        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ))
            and vrv.created_at >= date_add('${date}', interval 17 hour)
            and vrv.created_at < date_add('${date}', interval 20 hour) -- 当日17-20
        group by 1,2
    ) tod on tod.type = t.type and tod.client_name = t.client_name


























;
#
# select
#     vrv.type
#     ,case vrv.visit_state
#             when 0 then '终态或变更派件标记等无须回访'
#             when 1 then '待回访'
#             when 2 then '沟通中'
#             when 3 then '多次未联系上客户'
#             when 4 then '已回访'
#             when 5 then '因同包裹生成其他回访任务关闭'
#             when 6 then 'VR回访结果=99关闭'
#             when 7 then '超回访时效关闭'
#         end 回访状态
#     ,case vrv.visit_result
#         when 1 then '联系不上'
#         when 2 then '取消原因属实、合理'
#         when 3 then '快递员虚假标记/违背客户意愿要求取消'
#         when 4 then '多次联系不上客户'
#         when 5 then '收件人已签收包裹'
#         when 6 then '收件人未收到包裹'
#         when 7 then '未经收件人允许投放他处/让他人代收'
#         when 8 then '快递员没有联系客户，直接标记收件人拒收'
#         when 9 then '收件人拒收情况属实'
#         when 10 then '快递员服务态度差'
#         when 11 then '因快递员未按照收件人地址送货，客户不方便去取货'
#         when 12 then '网点派送速度慢，客户不想等'
#         when 13 then '非快递员问题，个人原因拒收'
#         when 14 then '其它'
#         when 15 then '未经客户同意改约派件时间'
#         when 16 then '未按约定时间派送'
#         when 17 then '派件前未提前联系客户'
#         when 18 then '收件人拒收情况不属实'
#         when 19 then '快递员联系客户，但未经客户同意标记收件人拒收'
#         when 20 then '快递员要求/威胁客户拒收'
#         when 21 then '快递员引导客户拒收'
#         when 22 then '其他'
#         when 23 then '情况不属实，快递员虚假标记'
#         when 24 then '情况不属实，快递员诱导客户改约时间'
#         when 25 then '情况属实，客户原因改约时间'
#         when 26 then '客户退货，不想购买该商品'
#         when 27 then '客户未购买商品'
#         when 28 then '客户本人/家人对包裹不知情而拒收'
#         when 29 then '商家发错商品'
#         when 30 then '包裹物流派送慢超时效'
#         when 31 then '快递员服务态度差'
#         when 32 then '因快递员未按照收件人地址送货，客户不方便去取货'
#         when 33 then '货物验收破损'
#         when 34 then '无人在家不便签收'
#         when 35 then '客户错误拒收包裹'
#         when 36 then '快递员按照要求当场扫描揽收'
#         when 37 then '快递员未按照要求当场扫描揽收'
#         when 38 then '无所谓，客户无要求'
#         when 39 then '包裹未准备好 - 情况不属实，快递员虚假标记'
#         when 40 then '包裹未准备好 - 情况属实，客户存在未准备好的包裹'
#         when 41 then '虚假修改包裹信息'
#         when 42 then '修改包裹信息属实'
#         when 43 then '客户需要包裹，继续派送'
#         when 44 then '客户不需要包裹，操作退件'
#     end as 回访结果
#     ,json_extract(vrv.extra_value, '$.rejection_delivery_again') delivery_again
#     ,count(vrv.id)
# from nl_production.violation_return_visit vrv
# join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id and bc.client_name = 'tiktok'
# where
#     vrv.created_at >= '2023-08-01'
#     and vrv.type in (3)
#     and visit_state in (4)
#     and vrv.created_at >= date_sub(curdate(), interval 7 day)
# group by 1,2,3


-- 应人工回访


select
    case t.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,t.client_name 客户名称
    ,his.回访任务量 历史积压量
    ,his.历史积压处理完成量
    ,his.历史积压未完成量
    ,upp.ticket_count '昨日17-今日9点创建量'
    ,upp.done_ticket_count '昨日17-今日9点处理完成量'
    ,upp.deal_rate '昨日17-今日9点完成率'
    ,low.ticket_count '今日9点-今日17点生成量'
    ,low.done_ticket_count '今日9点-今日17点处理完成量'
    ,low.deal_rate '今日9点-今日17点处理完成率'
    ,tod.未开始拨打数量
    ,tod.拨打一次数量
    ,tod.拨打两次数量
    ,tod.拨打完成数量
    ,total.ticket_count  当日总任务量 -- 17-17
    ,total.day_deal_rate 当日处理完成率  -- 17-17
    ,total.undeal_diff_count 处理完包裹中关联的疑难件未解锁的量 -- 17-17
    ,result.delivery_again_count 继续派送量
    ,result.rts_count 退件量
    ,result.close_count 异常关闭量
from tmpale.tmp_ph_client_visit_info t
left join
    (
        select
#             case vrv.type
#                 when 1 then '揽件任务异常取消'
#                 when 2 then '虚假妥投'
#                 when 3 then '收件人拒收'
#                 when 4 then '标记客户改约时间'
#                 when 5 then 'KA现场不揽收'
#                 when 6 then '包裹未准备好'
#                 when 7 then '上报错分未妥投'
#                 when 8 then '多次尝试派送失败'
#             end vrv_type
            vrv.type
            ,bc.client_name
            ,count(vrv.id) 回访任务量
            ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at >= date_sub('${date}', interval 7 hour), vrv.id, null)) 历史积压处理完成量 -- 查训当日处理完成量
            ,count(if(vrv.visit_state in (1,2), vrv.id, null )) 历史积压未完成量
        from nl_production.violation_return_visit vrv
        join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.created_at <= date_sub('${date}', interval 7 hour) -- 昨天17点之前
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                (
                    (vrv.visit_state in (3,4,5,6,7) and vrv.updated_at > date_sub('${date}', interval 7 hour)) -- 查询日期17点之后处理
                    or vrv.visit_state in (1,2) -- 至今也是未处理
                )
            and
                ( vrv.visit_staff_id != 10001 and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ) ) -- IVR应处理
        group by 1,2
    ) his on his.client_name = t.client_name and his.type = t.type
left join
    (
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
            and
                (vrv.visit_staff_id != 10001 and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ))
            and vrv.created_at >= date_sub('${date}', interval 7 hour)
            and vrv.created_at < date_add('${date}', interval 9 hour) -- 昨日17至今日9点
        group by 1,2
    ) upp on upp.type = t.type and upp.client_name = t.client_name
left join
    (
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
            and
                ( vrv.visit_staff_id != 10001 and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ) )
            and vrv.created_at >= date_add('${date}', interval 9 hour)
            and vrv.created_at < date_add('${date}', interval 17 hour) -- 昨日17至今日9点
        group by 1,2
    ) low on low.type = t.type and low.client_name = t.client_name
left join
    (
        select
            vrv.type
            ,bc.client_name
            ,count(vrv.id) ticket_count
            ,count(if(vrv.visit_state in (3,4,5,6,7) , vrv.id, null))/count(vrv.id) day_deal_rate
            ,count(if(cdt.state != 1 and vrv.visit_state in (3,4,7) and cdt.id is not null, vrv.id, null)) undeal_diff_count
        from nl_production.violation_return_visit vrv
        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(vrv.extra_value, '$.diff_id')
        where
            vrv.type in (3,8)
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id != 10001 and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ))
            and vrv.created_at >= date_sub('${date}', interval 7 hour)
            and vrv.created_at < date_add('${date}', interval 17 hour) -- 17-17
        group by 1,2
    ) total on total.type = t.type and total.client_name = t.client_name
left join
    (
        select
            a1.type
            ,a1.client_name
            ,count(if(a1.result = '退件', a1.id, null)) rts_count
            ,count(if(a1.result = '继续派送', a1.id, null)) delivery_again_count
            ,count(if(a1.result = '异常关闭', a1.id, null)) close_count
        from
            (
                select
                    a.type
                    ,a.client_name
                    ,case
                        when a.type = 3 and a.visit_state in (3,7) or a.rejection_delivery_again = 1 then '退件' -- 多次联系不上、超时效和回访结果是退件
                        when a.type = 3 and a.rejection_delivery_again = 2 then '继续派送' -- 继续派送
                        when a.type = 8 and a.visit_state in (3,7) or a.visit_result = 44 then '退件' --  多次联系不上和回访结果是退件
                        when a.type = 8 and  a.visit_result = 43 then '继续派送'
                        else '异常关闭'
                    end result
                    ,a.id
                from
                    (
                        select
                            vrv.type
                            ,bc.client_name
                            ,vrv.visit_state
                            ,vrv.visit_result
                            ,vrv.id
                            ,json_extract(vrv.extra_value, '$.rejection_delivery_again') rejection_delivery_again
                        from nl_production.violation_return_visit vrv
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
                        where
                            vrv.type in (3,8)
                            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
                            and
                                ( vrv.visit_staff_id != 10001 and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ))
                            and vrv.created_at >= date_sub('${date}', interval 7 hour)
                            and vrv.created_at < date_add('${date}', interval 17 hour)
                    ) a
            ) a1
        group by 1,2
    ) result on result.type = t.type and result.client_name = t.client_name
left join
    (
        select
            vrv.type
            ,bc.client_name
            ,count(if(vrv.visit_num = 0 ,vrv.id, null)) 未开始拨打数量
            ,count(if(vrv.visit_num = 1, vrv.id, null)) 拨打一次数量
            ,count(if(vrv.visit_num = 2, vrv.id, null)) 拨打两次数量
            ,count(if(vrv.visit_state in (3,4,5,6,7), vrv.id, null)) 拨打完成数量
        from nl_production.violation_return_visit vrv
        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        where
            vrv.type in (3,8)
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id != 10001 and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ))
            and vrv.created_at >= date_add('${date}', interval 17 hour)
            and vrv.created_at < date_add('${date}', interval 20 hour) -- 当日17-20
        group by 1,2
    ) tod on tod.type = t.type and tod.client_name = t.client_name


;


select * from tmpale.tmp_ph_client_visit_info