-- 警告信来源

select
    mw.staff_info_id 员工ID
    ,mw.staff_name 姓名
    ,case
        when hsi.state = 1 and hsi.wait_leave_state = 0 then '在职'
        when hsi.state = 1 and hsi.wait_leave_state = 1 then '待离职'
        when hsi.state = 2 then '离职'
        when hsi.state = 3 then '停职'
    end 在职状态
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when swm.id is not null then '回访虚假导入'
        when ral.warning_id is not null  then 'by举报'
        else '电子警告信'
    end 警告信来源
    ,case mw.warning_type
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
    end as 警告信类型
    ,case swm.type
            when 1 then '派件低效'
            when 3 then '虚假操作'
            when 4 then '虚假打卡'
    end 导入HCM违规类型
    ,json_extract(swm.data_bucket, '$.false_type') 虚假类型
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end BY举报原因
    ,case mw.type_code
        when 'warning_01' then '迟到早退'
        when 'warning_02' then '连续旷工'
        when 'warning_03' then '贪污'
        when 'warning_04' then '工作时间或工作地点饮酒'
        when 'warning_05' then '持有或吸食毒品'
        when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
        when 'warning_07' then '通过社会媒体污蔑公司'
        when 'warning_08' then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 'warning_09' then '腐败/滥用职权'
        when 'warning_10' then '玩忽职守'
        when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 'warning_12' then '未告知上级或无故旷工'
        when 'warning_13' then '上级没有同意请假、没有通过系统请假'
        when 'warning_14' then '没有通过系统请假'
        when 'warning_15' then '未按时上下班'
        when 'warning_16' then '不配合公司的吸毒检查'
        when 'warning_17' then '伪造证件'
        when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
        when 'warning_19' then '未按照网点规定的时间回款'
        when 'warning_20' then '谎报里程'
        when 'warning_21' then '煽动/挑衅/损害公司利益'
        when 'warning_22' then '失职'
        when 'warning_23' then '损害公司名誉'
        when 'warning_24' then '不接受或不配合公司的调查'
        when 'warning_25' then 'Fake  Status'
        when 'warning_26' then 'Fake  POD '
        when 'warning_27' then '工作效率未达到公司的标准(KPI)'
        when 'warning_28' then '贪污钱 '
        when 'warning_29' then '贪污包裹'
        when 'warning_30' then '偷盗公司财物'
        when 'warning_31' then '无故连续旷工1天'
        when 'warning_32' then '无故连续旷工2天'
        when 'warning_33' then '迟到/早退 <= 10 分钟超过1次'
        when 'warning_34' then '性骚扰'
        when 'warning_35' then '提供虚假或未更新的个人信息'
        when 'warning_36' then 'Fake scan face - 违法者'
        when 'warning_37' then 'Fake scan face - 帮手'
        when 'warning_101' then '一月内虚假妥投大于等于4次 '
        when 'warning_102' then '包裹被网点KIT扫描后遗失（2件及以上） '
        when 'warning_103' then '虚假扫描 '
        when 'warning_104' then '偷盗包裹 '
        when 'warning_105' then '仓库内吸烟 '
        when 'warning_106' then '辱骂客户 '
        when 'warning_107' then '乱扔包裹 '
        when 'warning_108' then '一个月内两次及以上虚假取消揽收 '
        when 'warning_109' then '未经客户同意私自擅闯客户家 '
        when 'warning_110' then '恶意争抢客户 '
        else type_code
    end 警告原因
    ,swd.warning_count 员工当前警告信次数
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = mw.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_backyard.staff_warning_message swm on mw.staff_warning_message_id = swm.id
left join ph_backyard.report_audit_log ral on ral.warning_id = mw.id
left join ph_backyard.report_audit ra on ral.report_id = ra.id
left join ph_backyard.staff_warning_dismiss swd on swd.staff_info_id = mw.staff_info_id
where
    mw.is_delete = 0
    and mw.created_at >= '2023-06-01'
    and mw.created_at < '2023-07-01'