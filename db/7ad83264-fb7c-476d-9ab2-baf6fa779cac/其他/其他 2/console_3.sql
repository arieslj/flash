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
                            ,rejection_delivery_again
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



;






 with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10' -- QC不看之前的数据
    and ra.status = 2
    and ra.final_approval_time >= date_sub('2025-04-28', interval 11 hour)
    and ra.final_approval_time < date_add('2025-04-28', interval 13 hour )
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area15', 'Area6', 'Area18') then '徐加文'
        when smr.name in ('Area21','Area4', 'Area8', 'Area19') then '黄勇'
        when smr.name in ('Area7','Area10','Area14','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5','Area3','Area9','Area20','Area16') then '李俊'
        when smr.name in ('Area13','Area11', 'Area12', 'Area17') then '章玉'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on del.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub('2025-04-28', interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub('2025-04-28', interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
where
    hsi.sys_department_id not in (126,127) -- 被举报人非HUB，车线
group by 2