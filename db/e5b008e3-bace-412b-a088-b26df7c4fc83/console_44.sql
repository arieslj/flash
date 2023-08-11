
select
    vrv.link_id 运单号
    ,case vrv.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 违规类型
    ,bc.client_name 客户明细
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
    ,if(vrv.visit_state in (3,4,5,6,7), vrv.updated_at, null) 结束时间
    ,if(vrv.visit_state in (3,4,5,6,7), timestampdiff(second , vrv.created_at, vrv.updated_at)/3600, null ) '处理时长/小时'
    ,vrv.visit_num 回访次数
    ,case
        when vrv.visit_state in (4,6) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then '否'
        when vrv.visit_state in (4,6) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then '是'
        when vrv.visit_state in (4,6) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then '否'
        when vrv.visit_state in (4,6) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then '是'

        when vrv.visit_state in (3,5) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then '否'
        when vrv.visit_state in (3,5) and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then '是'
        when vrv.visit_state in (7) then '是'

    end 是否超时

from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id and bc.client_name in ('lazada', 'shopee', 'tiktok')
where
    vrv.created_at >= date_sub('${date1}', interval 4 hour)
    and vrv.created_at < date_add('${date1}', interval 20 hour)
    and vrv.type in (3,8)