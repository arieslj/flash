
select
    a.staff_info_id
    ,sum(a.揽件虚假量) 虚假揽件量
    ,sum(a.妥投虚假量) 虚假妥投量
    ,sum(a.派件标记虚假量) 虚假派件标记量
from
    (
        select
        #     case vrv.type
        #         when 1 then '揽件任务异常取消'
        #         when 2 then '虚假妥投'
        #         when 3 then '收件人拒收'
        #         when 4 then '标记客户改约时间'
        #         when 5 then 'KA现场不揽收'
        #         when 6 then '包裹未准备好'
        #         when 7 then '上报错分未妥投'
        #         when 8 then '多次尝试派送失败'
        #     end 回访类型
            vrv.staff_info_id
            ,'回访' type
            ,count(distinct if(vrv.visit_result  in (6), vrv.link_id, null)) 妥投虚假量
            ,count(distinct if(vrv.visit_result in (18,8,19,20,21,31,32,22,23,24), vrv.link_id, null)) 派件标记虚假量
        #     ,count(distinct if(vrv.visit_result in (23,24), vrv.link_id, null)) 虚假改约量
            ,count(distinct if(vrv.visit_result in (37,39,3), vrv.link_id, null)) 揽件虚假量
        #     ,count(distinct if(vrv.visit_result in (39), vrv.link_id, null)) 虚假未准备好标记量
        #     ,count(distinct if(vrv.visit_result in (3), vrv.link_id, null)) 虚假取消揽件任务
        from nl_production.violation_return_visit vrv
        where
            vrv.visit_state = 4
            and vrv.updated_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and vrv.updated_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour) -- 昨天
            and vrv.visit_staff_id not in (10000,10001) -- 非ivr回访
            and vrv.type in (1,2,3,4,5,6)
            and vrv.visit_result in (6,18,8,19,20,21,31,32,22,23,24,37,39,3)
        group by 1

        union all

        select
            am.staff_info_id
            ,'投诉' type
            ,count(distinct if(acc.complaints_type = 2, acc.id, null)) 揽件虚假量
            ,count(distinct if(acc.complaints_type = 1, acc.id, null)) 妥投虚假量
            ,count(distinct if(acc.complaints_type = 3, acc.id, null)) 派件标记虚假量
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on am.id = acc.abnormal_message_id
        where
            acc.state = 1
            and acc.updated_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
            and acc.updated_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour) -- 昨天
            and acc.complaints_type in (1,2,3)
            and acc.qaqc_callback_result in (3,4,5,6)
        group by 1
    ) a
group by 1
