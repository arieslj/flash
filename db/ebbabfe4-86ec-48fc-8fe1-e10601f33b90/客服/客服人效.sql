-- 客户是否原谅道歉
select
    acc.sld_date
    ,count(acc.id) 任务量
    ,count(if(crl.created_at < acc.dead_line_time, acc.id, null)) / count(acc.id) 首次回访及时率
    ,count(if(acc.qaqc_callback_at < acc.finish_dead_line_time and acc.callback_state in (2,4),  acc.id, null)) / count(acc.id) 回访完成及时率
from
    (
        select
            acc.pno
            ,acc.id
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
group by 1
order by 1
;


-- 未收到包裹回访

select
    date(date_add(pci.qaqc_created_at, interval 7 hour)) sld_date
    ,count(pci.id) 任务量
    ,count(if(pci.callback_state in (2,4) and pci.qaqc_callback_at < date_add(date(date_add(pci.qaqc_created_at, interval 7 hour)), interval 36 hour), pci.id, null)) / count(pci.id) 回访完成及时率
from my_bi.parcel_complaint_inquiry pci
where
    pci.qaqc_created_at >= date_sub('${start_date}', interval 7 hour )
    and pci.qaqc_created_at < date_add('${end_date}', interval 17 hour)
    and pci.client_type in (1,2,3,4)
group by 1
order by 1


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
    ,count(vrv_1.id) 任务量
    ,count(if(vrv_1.first_visit_time < vrv_1.dead_line_time, vrv_1.id, null)) / count(vrv_1.id) 首次回访及时率
    ,count(if(vrv_1.visit_state not in (1,2) and vrv_1.updated_at < vrv_1.finish_dead_line_time, vrv_1.id, null)) / count(vrv_1.id) 回访完成及时率
from
    (
        select
            date(date_add(vrv.created_at, interval 7 hour)) sld_date
            ,replace(cast(json_extract(extra_value,  '$.visit_log[0].updated_at') as char),'"','') as first_visit_time
            ,replace(cast(json_extract(extra_value,  concat('$.visit_log[',json_length(json_extract(extra_value, '$.visit_log'))-1,'].updated_at')) as char),'"','') as last_visit_time
            ,vrv.visit_state
            ,vrv.updated_at
            ,date_add(date(date_add(vrv.created_at, interval 7 hour)), interval 1 day) dead_line_time
            ,date_add(date(date_add(vrv.created_at, interval 7 hour)), interval 36 hour) finish_dead_line_time
            ,vrv.type
            ,vrv.id
        from my_nl.violation_return_visit vrv
        where
            vrv.created_at >= date_sub('${start_date}', interval 7 hour )
            and vrv.created_at < date_add('${end_date}', interval 17 hour)
            and vrv.visit_staff_id not in (10001, 10002) -- 客服
            and vrv.gain_way = 1 -- 1 系统、2上传、3合并
            and vrv.type in (2,3,4,8)
    ) vrv_1
group by 1,2
order by 1,2
;

-- wrs任务

select
    a.task_type 任务类型
    ,a.sld_date 日期
    ,count(if(a.deal_time < a.dead_line_time, a.id, null)) / count(a.id) WRS审核完成率
from
    (
        select -- 揽收取消审核
            ear.id
            ,'揽收取消审核' task_type
            ,date(date_add(ear.input_begin, interval 14 hour)) sld_date
            ,convert_tz(ear.input_begin, '+00:00', '+08:00') task_created_at
            ,date_add(date_add(date(date_add(ear.input_begin, interval 14 hour)), interval 18 hour), interval 5 minute) dead_line_time
            ,convert_tz(ear.input_end, '+00:00', '+08:00') deal_time
        from my_wrs.epop_audit_record ear
        where
            ear.input_begin > date_sub('${start_date}', interval 14 hour) -- 0 时区
            and  ear.input_begin < date_add('${end_date}', interval 10 hour) -- 18点作为cutoff时间，数据库存储是0时区，时间变化是 18-8 = 0 +10

        union all

        select -- 拒收审核
            ra.id
            ,'拒收审核' task_type
            ,date(date_add(ra.input_begin, interval 14 hour)) sld_date
            ,convert_tz(ra.input_begin, '+00:00', '+08:00') task_created_at
            ,date_add(date_add(date(date_add(ra.input_begin, interval 14 hour)), interval 18 hour), interval 5 minute) dead_line_time
            ,convert_tz(ra.input_end, '+00:00', '+08:00') deal_time
        from my_wrs.reject_audit ra
        where
            ra.input_begin > date_sub('${start_date}', interval 14 hour) -- 0 时区
            and  ra.input_begin < date_add('${end_date}', interval 10 hour) -- 18点作为cutoff时间，数据库存储是0时区，时间变化是 18-8 = 0 +10

        union all

        select -- 留仓审核
            waa.id
            ,'留仓审核' task_type
            ,date(date_add(waa.input_begin, interval 14 hour)) sld_date
            ,convert_tz(waa.input_begin, '+00:00', '+08:00') task_created_at
            ,date_add(date_add(date(date_add(waa.input_begin, interval 14 hour)), interval 18 hour), interval 5 minute) dead_line_time
            ,convert_tz(waa.input_end, '+00:00', '+08:00') deal_time
        from my_wrs.whats_app_audit waa
        where
            waa.input_begin > date_sub('${start_date}', interval 14 hour) -- 0 时区
            and waa.input_begin < date_add('${end_date}', interval 10 hour) -- 18点作为cutoff时间，数据库存储是0时区，时间变化是 18-8 = 0 +10
    ) a
group by 1,2
order by 1,2

;

-- FBI闪速理赔

select
    pct.sld_date
    ,count(pct.id) 任务量
    ,count(if(pcol.created_at < pct.dead_line_time, pct.id, null)) / count(pct.id) 首次回访及时率
from
    (
        select
            pct.id
            ,pct.created_at
            ,date(date_add(pct.created_at, interval 6 hour)) sld_date
            ,date_add(date(date_add(pct.created_at, interval 6 hour)), interval 1 day ) dead_line_time
        from my_bi.parcel_claim_task pct
        where
            pct.created_at >= date_sub('${start_date}', interval 6 hour )
            and pct.created_at < date_add('${end_date}', interval 18 hour)
            and pct.vip_enable = 0 -- 普通客户
            and pct.client_id != 'AFAFOC'
            and pct.client_id not regexp '^AA'
    ) pct
left join
    (
        select
            pct.id
            ,pcol.created_at
            ,row_number() over (partition by pct.id order by pcol.created_at) rk
        from my_bi.parcel_claim_task pct
        join my_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id
        where
            pct.created_at >= date_sub('${start_date}', interval 6 hour )
            and pct.created_at < date_add('${end_date}', interval 18 hour)
            and pct.vip_enable = 0 -- 普通客户
            and pct.client_id != 'AFAFOC'
            and pct.client_id not regexp '^AA'
            and pcol.created_at >= date_sub('${start_date}', interval 6 hour )
            and pcol.type = 2
            and pcol.action in (18,19,20,21)
    ) pcol on pct.id = pcol.id and pcol.rk = 1
group by 1
order by 1

;


-- 闪速判案

select
    date(date_add(sct.created_at, interval 6 hour)) sld_date
    ,count(sct.pno) 任务量
    ,count(if(sct.state in (2,3) and sct.updated_at < date_add(date(date_add(sct.created_at, interval 6 hour)), interval 1 day), sct.pno, null)) / count(sct.pno) 回访完成率
from my_bi.ss_court_task sct
where
    sct.created_at >= date_sub('${start_date}', interval 6 hour )
    and sct.created_at < date_add('${end_date}', interval 18 hour)
group by 1
order by 1

;


-- 部门工单

select
    wo1.sld_date
    ,count(wo1.id) 工单量
    ,count(if(wor.created_at < wo1.dead_line_time, wo1.id, null)) / count(wo1.id) 及时回复率
from
    (
        select
            date(date_add(wo.created_at, interval 6 hour)) sld_date
            ,wo.id
            ,wo.order_no
            ,case
                when wo.speed_level = 1 then date_add(wo.created_at, interval 2 hour)
                when wo.speed_level = 2 then date_add(wo.created_at, interval 24 hour)
            end dead_line_time
        from my_bi.work_order wo
        where
            wo.created_at > date_sub('${start_date}', interval 6 hour )
            and wo.created_at < date_add('${end_date}', interval 18 hour)
            and wo.store_id = 'customer_manger' -- 客服中心受理
    ) wo1
left join
    ( -- 剔除解锁包裹
        select
            wo.id
        from my_bi.work_order wo
        where
            wo.created_at > date_sub('${start_date}', interval 6 hour )
            and wo.created_at < date_add('${end_date}', interval 18 hour)
            and wo.store_id = 'customer_manger' -- 客服中心受理
            and wo.created_staff_info_id = 10001
            and wo.order_type = 21
    ) wo2 on wo1.id = wo2.id
left join
    (
        select
            wo.id
            ,wor.created_at
            ,row_number() over (partition by wo.id order by wor.created_at) rk
        from my_bi.work_order_reply wor
        join my_bi.work_order wo on wo.id = wor.order_id
        where
            wo.created_at > date_sub('${start_date}', interval 6 hour)
            and wo.created_at < date_add('${end_date}', interval 18 hour)
            and wo.store_id = 'customer_manger'
            and wor.created_at > date_sub('${start_date}', interval 6 hour)
    ) wor on wor.id = wo1.id and wor.rk = 1
where
    wo2.id is null
group by 1
order by 1


;

-- 总部客服协商

select
    cdt_1.sld_date
    ,count(cdt_1.diff_info_id) 任务量
    ,count(if(cdt_1.state = 1 and cdt_1.deal_time < cdt_1.dead_line_time, cdt_1.diff_info_id, null)) / count(cdt_1.diff_info_id) 客服协商及时率
from
    (
        select
            date(date_add(cdt.created_at, interval 16 hour)) sld_date
            ,cdt.state
            ,cdt.diff_info_id
            ,convert_tz(dr.created_at, '+00:00', '+08:00') deal_time
            ,case
                when hour(convert_tz(cdt.created_at, '+00:00', '+08:00')) >= 16 then date_add(date(date_add(cdt.created_at, interval 16 hour)), interval 12 hour)
                when hour(convert_tz(cdt.created_at, '+00:00', '+08:00')) < 16 then date_add(date(date_add(cdt.created_at, interval 16 hour)), interval 24 hour)
            end dead_line_time
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
            and prr.id is null
            and cdt.created_at > date_sub('${start_date}', interval 16 hour) -- 0 时区，16点作为cutoff时间，数据库存储是0时区，时间变化是 16-8 = 0 +8 = 24- 16
            and cdt.created_at < date_add('${end_date}', interval 8 hour)
    ) cdt_1
group by 1
order by 1


;

-- KAM问题件协商

select
    cdt.sld_date
    ,count(cdt.diff_info_id) 任务量
    ,count(if(cdt.state = 1 and cdt.deal_time < cdt.dead_line_time, cdt.diff_info_id, null)) / count(cdt.diff_info_id) 客服协商及时率
from
    (
        select
            date(date_add(cdt.created_at, interval 14 hour)) sld_date
            ,cdt.state
            ,convert_tz(dr.created_at, '+00:00', '+08:00') deal_time
            ,cdt.diff_info_id
            ,date_add(date(date_add(cdt.created_at, interval 14 hour)), interval 1 day) dead_line_time
        from my_staging.customer_diff_ticket cdt
        join my_staging.diff_info di on di.id = cdt.diff_info_id
        left join my_staging.diff_route dr on dr.diff_info_id = cdt.diff_info_id and dr.route_action = 'CUSTOMER_NEGOTIATION'
        where
            cdt.organization_type = 2
            and cdt.vip_enable = 1 -- KAM
            and cdt.client_id = 'AA0133'
            and di.diff_marker_category = 39 -- 多次尝试派送失败
            and cdt.created_at > date_sub('${start_date}', interval 14 hour) -- 0 时区，18点作为cutoff时间，数据库存储是0时区，时间变化是 18-8 = 0 +10 = 24- 14
            and cdt.created_at < date_add('${end_date}', interval 10 hour)
    ) cdt
group by 1
order by 1
