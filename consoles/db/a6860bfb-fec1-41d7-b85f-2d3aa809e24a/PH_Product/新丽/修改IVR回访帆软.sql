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
    ,his.undeal_diff_count 历史处理完包裹中关联的疑难件未解锁的量
    ,his.parcel_diff_count 历史回访任务中包裹处于疑难件处理中状态的量
    ,his.diff_vrv_finish_count 历史拒收回访任务处理完毕包裹仍是疑难件状态量
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
    ,total.parcel_diff_count 回访任务中包裹处于疑难件处理中状态的量
    ,total.diff_vrv_finish_count 拒收回访任务处理完毕包裹仍是疑难件状态量
    ,result.delivery_again_count 继续派送量
    ,result.rts_count 退件量
    ,result.close_count 异常关闭量
from tmpale.tmp_ph_client_visit_info t
left join
    (
        select
            vrv.type
            ,bc.client_name
            ,count(vrv.id) 回访任务量
            ,count(if(vrv.visit_state in (3,4,5,6,7) and vrv.updated_at >= date_sub('${date}', interval 7 hour), vrv.id, null)) 历史积压处理完成量 -- 查训当日处理完成量
            ,count(if(vrv.visit_state in (1,2), vrv.id, null )) 历史积压未完成量
            ,count(if(cdt.state != 1 and vrv.visit_state in (3,4,7) and cdt.id is not null, vrv.id, null)) undeal_diff_count
            ,count(if(pi.state = 6, vrv.id, null)) parcel_diff_count
            ,count(if(vrv.visit_state in (3,4,7,8) and di.diff_marker_category in (17,29,25) and di.state = 0 and pi.state = 6 , vrv.id, null )) diff_vrv_finish_count
        from nl_production.violation_return_visit vrv
        join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(vrv.extra_value, '$.diff_id')
        left join ph_staging.parcel_info pi on pi.pno = vrv.link_id
        left join ph_staging.diff_info di on di.pno = vrv.link_id
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
            and vrv.visit_state != 0
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
            and vrv.visit_state != 0
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
            and vrv.visit_state != 0
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
            ,count(if(pi.state = 6, vrv.id, null)) parcel_diff_count
            ,count(if(vrv.visit_state in (3,4,7,8) and di.diff_marker_category in (17,29,25) and di.state = 0 and pi.state = 6 , vrv.id, null )) diff_vrv_finish_count
        from nl_production.violation_return_visit vrv
        left join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(vrv.extra_value, '$.diff_id')
        left join ph_staging.parcel_info pi on pi.pno = vrv.link_id
        left join ph_staging.diff_info di on di.pno = vrv.link_id
        where
            vrv.type in (3,8)
            and vrv.visit_state != 0
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
                            and vrv.visit_state != 0
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
            and vrv.visit_state != 0
            and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
            and
                ( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ))
            and vrv.created_at >= date_add('${date}', interval 17 hour)
            and vrv.created_at < date_add('${date}', interval 20 hour) -- 当日17-20
        group by 1,2
    ) tod on tod.type = t.type and tod.client_name = t.client_name






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
    ,vrv.created_at 回访任务创建时间
    ,vrv.updated_at 回访任务更新时间
    ,ss.name 目的地网点
    ,vrv.mobile 收件人电话号码
    ,vrv.visit_num 回访次数
    ,if(vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ), 'IVR', '人工') 应处理人
    ,if(cdt.state != 1 and vrv.visit_state in (3,4,7) and cdt.id is not null, 'y', 'n') 处理完成的回访任务关联的疑难件未解锁
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as 包裹当前状态
    ,if(vrv.visit_state in (3,4,7,8) and di.diff_marker_category in (17,29,25) and di.state = 0 and pi.state = 6 , 'y', 'n') 是否回访任务处理完毕包裹仍是疑难件状态
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(vrv.extra_value, '$.diff_id')
left join ph_staging.parcel_info pi on pi.pno = vrv.link_id
left join ph_staging.diff_info di on di.pno = vrv.link_id
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    vrv.type in (3,8)
    and vrv.visit_state != 0
    and vrv.created_at <= date_sub('${date}', interval 7 hour) -- 昨天17点之前
    and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
    and
        (
            (vrv.visit_state in (3,4,5,6,7,8) and vrv.updated_at > date_sub('${date}', interval 7 hour)) -- 查询日期17点之后处理
            or vrv.visit_state in (1,2) -- 至今也是未处理
        )






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
    ,vrv.mobile 收件人电话号码
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
    ,vrv.updated_at 回访任务更新时间
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
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
        ELSE '其他'
	end as 包裹状态
    ,if(cdt.state != 1 and vrv.visit_state in (3,4,7) and cdt.id is not null, 'y', 'n') 处理完成的回访任务关联的疑难件未解锁
    ,if(vrv.visit_state in (3,4,7,8) and di.diff_marker_category in (17,29,25) and di.state = 0 and pi.state = 6 , 'y', 'n') 是否回访任务处理完毕包裹仍是疑难件状态
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
join tmpale.tmp_ph_client_visit_info t on t.type = vrv.type and bc.client_name = t.client_name
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(vrv.extra_value, '$.diff_id')
left join ph_staging.parcel_info pi on pi.pno = vrv.link_id
left join ph_staging.diff_info di on di.pno = vrv.link_id
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    vrv.type in (3,8)
    and vrv.visit_state != 0
#     and vrv.created_at <= date_sub('${date}', interval 7 hour) -- 昨天17点之前
    and vrv.created_at >= date_sub(curdate(), interval 7 day ) -- 回访系统只呈现近7天时间
    and
        (
            (vrv.visit_state in (3,4,5,6,7) and vrv.updated_at > date_sub('${date}', interval 7 hour)) -- 查询日期17点之后处理
            or vrv.visit_state in (1,2) -- 至今也是未处理
        )
    and vrv.created_at >= date_sub('${date}', interval 7 hour)
    and vrv.created_at < date_add('${date}', interval 17 hour)