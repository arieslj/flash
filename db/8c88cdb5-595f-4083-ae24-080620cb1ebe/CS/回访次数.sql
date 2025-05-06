
# case t.type
#         when 1 then '揽件任务异常取消'
#         when 2 then '虚假妥投'
#         when 3 then '收件人拒收'
#         when 4 then '标记客户改约时间'
#         when 5 then 'KA现场不揽收'
#         when 6 then '包裹未准备好'
#         when 7 then '上报错分未妥投'
#         when 8 then '多次尝试派送失败'
#     end 回访类型

# case vrv.visit_state
#         when 1 then '待回访'
#         when 2 then '沟通中'
#         when 3 then '多次未联系上客户'
#         when 4 then '已回访'
#         when 5 then '因同包裹生成其他回访任务关闭'
#         when 6 then 'VR回访结果=99关闭'
#         when 7 then '超回访时效关闭'
#     end  回访状态
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
    ,if(vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ), 'IVR', '人工') 处理人
    ,vrv.visit_num 次数
    ,vrv.link_id '运单号/揽件任务'
from nl_production.violation_return_visit vrv
where
    vrv.created_at > '2025-02-01'
    and vrv.created_at < '2025-03-01'
    and vrv.type in (1,3)
    and vrv.visit_state = 4

;


select
    '未收到包裹回访' 回访类型
    ,pci.qaqc_callback_num  次数
    ,pci.merge_column 运单号
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at > '2025-02-01'
    and pci.created_at < '2025-03-01'
    and pci.callback_state = 2

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
    ,vrv.visit_num 次数
    ,if(vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ), 'IVR', '人工') 处理人
    ,case vrv.visit_state
        when 0 then '因包裹状态、标记等变更需要剔除的回访'
        when 1 then '待回访'
        when 2 then '沟通中'
        when 3 then '多次未联系上客户'
        when 4 then '已回访'
        when 5 then '因同包裹生成其他回访任务关闭'
        when 6 then 'VR回访结果=99关闭'
        when 7 then '超回访时效关闭'
        when 8 then 'TT&PDD收件人拒收回访逻辑兜底任务关闭的'
        when 9 then '回访失败（电话号码错误/电话号码是空号)'
        else vrv.visit_state
    end  回访状态
    ,vrv.link_id '运单号/揽件任务'
from nl_production.violation_return_visit vrv
where
    vrv.created_at > '2025-02-01'
    and vrv.created_at < '2025-03-01'
    and vrv.type in (1,3)

;


select
    '未收到包裹回访' 回访类型
    ,pci.qaqc_callback_num  次数
    ,case pci.callback_state
        when 1 then '待回访'
        when 2 then '已回访'
        when 3 then '沟通中'
        when 4 then '多次未联系上客户'
    end  回访状态
    ,pci.merge_column 运单号
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at > '2025-02-01'
    and pci.created_at < '2025-03-01'
    and pci.callback_state > 0