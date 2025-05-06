-- 客服是否原谅道歉

select
    acc.sld_date
    ,acc.pno
    ,acc.store_callback_at 任务创建时间
    ,crl.created_at 首次回访时间
    ,acc.dead_line_time 首次回访及时deadline
    ,if(acc.callback_state in (2,4), acc.qaqc_callback_at, null) 回访完成时间
    ,acc.finish_dead_line_time 回访完成及时deadline
#     ,count(if(crl.created_at < acc.dead_line_time, acc.id, null)) / count(acc.id) 首次回访及时率
#     ,count(if(acc.qaqc_callback_at < acc.finish_dead_line_time and acc.callback_state in (2,4),  acc.id, null)) / count(acc.id) 回访完成及时率
from
    (
        select
            acc.pno
            ,acc.id
            ,acc.store_callback_at
            ,date (date_add(acc.store_callback_at, interval 7 hour)) sld_date
            ,date_add(date (date_add(acc.store_callback_at, interval 7 hour)), interval 1 day) dead_line_time
            ,date_add(date (date_add(acc.store_callback_at, interval 7 hour)), interval 36 hour) finish_dead_line_time
            ,acc.callback_state
            ,acc.qaqc_callback_at
        from my_bi.abnormal_customer_complaint acc
        where
            acc.store_callback_at >= date_sub('${start_date}', interval 7 hour )
            and acc.store_callback_at < date_sub('${end_date}', interval 17 hour )
    ) acc
left join
    (
        select
            acc.pno
            ,acc.id
            ,crl.created_at
            ,row_number() over (partition by acc.pno order by crl.created_at ) rn
        from my_bi.abnormal_customer_complaint acc
        left join my_bi.complaint_replay_log crl on crl.complaint_id = acc.id
        where
            acc.store_callback_at >= date_sub('${start_date}', interval 7 hour ) -- 17点作为cutoff时间
            and acc.store_callback_at < date_add('${end_date}', interval 17 hour )
    ) crl on acc.id = crl.id and crl.rn = 1

;


-- 未收到包裹回访


select
    date(date_add(pci.qaqc_created_at, interval 7 hour)) sld_date
    ,pci.merge_column pno
    ,pci.qaqc_created_at 回访任务生成时间
    ,if(pci.callback_state in (2,4), pci.qaqc_callback_at, null) 回访完成时间
    ,date_add(date(date_add(pci.qaqc_created_at, interval 7 hour)), interval 36 hour) 回访完成及时deadline
#     ,count(if(pci.callback_state in (2,4) and pci.qaqc_callback_at < date_add(date(date_add(pci.qaqc_created_at, interval 7 hour)), interval 36 hour), pci.id, null)) / count(pci.id) 回访完成及时率
from my_bi.parcel_complaint_inquiry pci
where
    pci.qaqc_created_at >= date_sub('${start_date}', interval 7 hour )
    and pci.qaqc_created_at < date_add('${end_date}', interval 17 hour)



;

-- 疑似违规回访


select
    case vrv_1.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,vrv_1.sld_date
    ,vrv_1.link_id pno
    ,vrv_1.created_at 回访任务创建时间
    ,vrv_1.first_visit_time 首次回访时间
    ,vrv_1.dead_line_time 首次回访及时deadline
    ,if(vrv_1.visit_state not in (1,2), vrv_1.updated_at, null) 回访完成时间
    ,vrv_1.finish_dead_line_time 回访完成及时deadline
#     ,count(vrv_1.id) 任务量
#     ,count(if(vrv_1.first_visit_time < vrv_1.dead_line_time, vrv_1.id, null)) / count(vrv_1.id) 首次回访及时率
#     ,count(if(vrv_1.visit_state in (3,4,5,6,7) and vrv_1.updated_at < vrv_1.finish_dead_line_time, vrv_1.id, null)) / count(vrv_1.id) 回访完成及时率
from
    (
        select
            date(date_add(vrv.created_at, interval 7 hour)) sld_date
            ,replace(cast(json_extract(extra_value,  '$.visit_log[0].updated_at') as char),'"','') as first_visit_time
            ,replace(cast(json_extract(extra_value,  concat('$.visit_log[',json_length(json_extract(extra_value, '$.visit_log'))-1,'].updated_at')) as char),'"','') as last_visit_time
            ,vrv.visit_state
            ,vrv.updated_at
            ,vrv.link_id
            ,vrv.created_at
            ,date_add(date(date_add(vrv.created_at, interval 7 hour)), interval 1 day) dead_line_time
            ,date_add(date(date_add(vrv.created_at, interval 7 hour)), interval 36 hour) finish_dead_line_time
            ,vrv.type
            ,vrv.id
        from my_nl.violation_return_visit vrv
        where
            vrv.created_at >= date_sub('${start_date}', interval 7 hour )
            and vrv.created_at < date_add('${end_date}', interval 17 hour)
            and vrv.visit_staff_id not in (10001, 10002 ) -- 客服
            and vrv.gain_way = 1 -- 1 系统、2上传、3合并
            and vrv.type in (2,3,4,8)
    ) vrv_1


;





-- 总部客服协商

select
    cdt_1.sld_date
    ,cdt_1.operator_id
    ,ddd.cn_element 问题件类型
    ,convert_tz(cdt_1.created_at, '+00:00', '+08:00') 任务创建时间
    ,cdt_1.pno
    ,if(cdt_1.state = 1, cdt_1.deal_time, null) 客服协商完成时间
    ,cdt_1.dead_line_time 客服协商完成deadline
#     ,count(cdt_1.diff_info_id) 任务量
#     ,count(if(cdt_1.state = 1 and cdt_1.deal_time < cdt_1.dead_line_time, cdt_1.diff_info_id, null)) / count(cdt_1.diff_info_id) 客服协商及时率
from
    (
        select
            date(date_add(cdt.created_at, interval 16 hour)) sld_date
            ,cdt.state
            ,di.pno
            ,cdt.diff_info_id
            ,cdt.created_at
            ,di.diff_marker_category
            ,convert_tz(dr.created_at, '+00:00', '+08:00') deal_time
            ,case
                when hour(convert_tz(cdt.created_at, '+00:00', '+08:00')) >= 16 then date_add(date(date_add(cdt.created_at, interval 16 hour)), interval 12 hour)
                when hour(convert_tz(cdt.created_at, '+00:00', '+08:00')) < 16 then date_add(date(date_add(cdt.created_at, interval 16 hour)), interval 24 hour)
            end dead_line_time
            ,cdt.operator_id
        from my_staging.customer_diff_ticket cdt
        join my_staging.diff_info di on di.id = cdt.diff_info_id
        left join my_staging.diff_route dr on dr.diff_info_id = cdt.diff_info_id and dr.route_action = 'CUSTOMER_NEGOTIATION'
        left join my_nl.violation_return_visit vrv on json_extract(vrv.extra_value, '$.diff_id') = cdt.diff_info_id and vrv.created_at > date_sub('${start_date}', interval 1 day)
        left join my_staging.parcel_reject_report_info prr on prr.diff_info_id = di.id -- 剔除拒收复核上报
        join my_bi.hr_staff_info hsi on hsi.staff_info_id = cdt.operator_id and hsi.sys_department_id = 15008 and hsi.state = 1 -- 客服在职
        where
            cdt.organization_type = 2
            and cdt.vip_enable = 0
            and cdt.service_type != 4
            and di.diff_marker_category in (39,29,17,23,25,21)
            and vrv.id is null
            and cdt.created_at > date_sub('${start_date}', interval 16 hour) -- 0 时区，16点作为cutoff时间，数据库存储是0时区，时间变化是 16-8 = 0 +8 = 24- 16
            and cdt.created_at < date_add('${end_date}', interval 8 hour)
    ) cdt_1
left join dwm.dwd_dim_dict ddd on ddd.element = cdt_1.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'



;


-- 问题件协商kam


select
    cdt.sld_date
    ,cdt.pno
    ,convert_tz(cdt.created_at, '+00:00', '+08:00') 任务创建时间
    ,if(cdt.state = 1, cdt.deal_time, null) 客服协商完成时间
    ,cdt.dead_line_time 客服协商完成deadline
#     ,count(cdt.diff_info_id) 任务量
#     ,count(if(cdt.state = 1 and cdt.deal_time < cdt.dead_line_time, cdt.diff_info_id, null)) / count(cdt.diff_info_id) 客服协商及时率
from
    (
        select
            date(date_add(cdt.created_at, interval 14 hour)) sld_date
            ,cdt.state
            ,di.pno
            ,cdt.created_at
            ,convert_tz(dr.created_at, '+00:00', '+08:00') deal_time
            ,cdt.diff_info_id
            ,date_add(date(date_add(cdt.created_at, interval 14 hour)), interval 1 day) dead_line_time
        from my_staging.customer_diff_ticket cdt
        join my_staging.diff_info di on di.id = cdt.diff_info_id
        join my_bi.hr_staff_info hsi on hsi.staff_info_id = cdt.operator_id and hsi.sys_department_id = 15008 and hsi.state = 1 -- 客服在职
        left join my_staging.diff_route dr on dr.diff_info_id = cdt.diff_info_id and dr.route_action = 'CUSTOMER_NEGOTIATION'
        where
            cdt.organization_type = 2
            and cdt.vip_enable = 1 -- KAM
            and cdt.client_id = 'AA0133'
            and di.diff_marker_category = 39 -- 多次尝试派送失败
            and cdt.created_at > date_sub('${start_date}', interval 14 hour) -- 0 时区，18点作为cutoff时间，数据库存储是0时区，时间变化是 18-8 = 0 +10 = 24- 14
            and cdt.created_at < date_add('${end_date}', interval 10 hour)
    ) cdt


;

select
    *
from my_wrs.reweight_record
where
    pno = 'M06011QC1PSHD0'