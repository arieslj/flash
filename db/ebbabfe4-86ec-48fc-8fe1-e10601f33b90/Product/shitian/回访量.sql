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
    ,date (vrv.created_at) 创建日期
    ,vrv.client_id 客户ID
    ,case vrv.gain_way
       when 1 then '系统自动判定'
        when 2 then 'Excel批量上传'
        when 3 then '系统自动判定&Excel批量上传'
    end  导入渠道
    ,if(vrv.visit_staff_id = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 ), 'y', 'n') 是否为IVR回访
    ,count(vrv.id) 回访量
from my_nl.violation_return_visit vrv
where
    vrv.created_at > '2024-07-01'
    and vrv.created_at < '2024-08-13'
    and vrv.type in (3,4)
group by 1,2,3,4,5