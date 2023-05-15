with t as
(
    select
        hsi.staff_info_id
        ,case
        when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
        when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
        when hsi.`state`=2 then '离职'
        when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') created_at
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
        ,ROW_NUMBER ()over(partition by hsi.staff_info_id order by mw.created_at ) rn
        ,count(mw.id) over (partition by hsi.staff_info_id) ct
    from
    (
             select
                mw.staff_info_id
            from ph_backyard.message_warning mw
            where
                mw.type_code = 'warning_27'
                and mw.operator_id = 87166
                and mw.is_delete = 0
#             and mw.created_at >=convert_tz('2023-04-13','+08:00','+00:00')
            group by 1
    )ws
    join ph_bi.hr_staff_info hsi  on ws.staff_info_id=hsi.staff_info_id
    left join  ph_backyard.message_warning mw on hsi.staff_info_id =mw.staff_info_id and  mw.is_delete =0
    left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
    left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
    left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
    where
        hsi.state <> 2
)

select 
    t.staff_info_id 员工id
    ,t. 在职状态
    ,t.所属网点
    ,t.大区
    ,t.片区
    ,t.ct 警告次数
    ,t.created_at 第一次警告信时间
    ,t.警告原因 第一次警告原因
    ,t.警告类型 第一次警告类型
    ,t2.created_at 第二次警告信时间
    ,t2.警告原因 第二次警告原因
    ,t2.警告类型 第二次警告类型
    ,t3.created_at 第三次警告信时间
    ,t3.警告原因 第三次警告原因
    ,t3.警告类型 第三次警告类型
    ,t4.created_at 第四次警告信时间
    ,t4.警告原因 第四次警告原因
    ,t4.警告类型 第四次警告类型
    ,t5.created_at 第五次警告信时间
    ,t5.警告原因 第五次警告原因
    ,t5.警告类型 第五次警告类型
from t 
left join t t2 on t.staff_info_id=t2.staff_info_id and t2.rn=2
left join t t3 on t.staff_info_id=t3.staff_info_id and t3.rn=3
left join t t4 on t.staff_info_id=t4.staff_info_id and t4.rn=4
left join t t5 on t.staff_info_id=t5.staff_info_id and t5.rn=5
where
    t.rn=1
;

select
    date(swm.created_at) 录入日期
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct if(swm.hr_fix_status = 0, swm.id, null)) HRBP未处理量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1
order by 1
;



select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-04-01'
    and mw.created_at < '2023-05-01'
    and mw.is_delete = 0
