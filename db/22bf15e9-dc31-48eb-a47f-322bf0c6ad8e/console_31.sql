
select
    swm.staff_info_id 员工ID
    ,hjt.job_name 职位
    ,swm.date_at 违规日期
    ,swm.created_at 导入时间
    ,case hsi.state
        when 1 then '在职'
        when 2 then '离职'
        when 3 then '停职'
    end as 员工当前状态
    ,case swm.hr_fix_status
        when 0 then '未处理'
        when 1 then '员工申诉，建议采纳'
        when 2 then '员工申诉，理由不充分'
        when 3 then '员工未申诉，或态度不好'
        when 4 then '态度恶劣，直接开除'
    end QC处理意见
    ,swf2.created_at QC处理时间
    ,swf2.operator_id QC处理人
    ,case swm.data_fix_status
        when 0 then '未处理'
        when 1 then '数据有误，不做后续'
        when 2 then '数据准确，放过'
        when 3 then '数据准确，警告书'
    end 复核结果
    ,swf.operator_id 复核操作人
    ,swf.created_at 复核时间
    ,ss.name 员工所属网点
    ,smp.name 员工所属片区
    ,smr.name 员工所属大区
    ,mw.ct 员工当前警告信次数
from  backyard_pro.staff_warning_message swm
left join
    (
      select
        mw.staff_info_id
        ,count(mw.id) ct
      from backyard_pro.message_warning mw
      where mw.is_delete=0
      group by 1
    )mw on swm.staff_info_id=mw.staff_info_id
left join backyard_pro.`staff_warning_fix_info`  swf on swf.staff_warning_id=swm.id and swf.type=2
left join backyard_pro.`staff_warning_fix_info`  swf2 on swf2.staff_warning_id=swm.id and swf2.type=1
left join backyard_pro.hr_staff_info hsi on hsi.staff_info_id=swm.staff_info_id
left join fle_staging.sys_store ss on ss.id=hsi.sys_store_id
left join fle_staging.`sys_manage_piece`  smp on smp.id=ss.manage_piece
left join fle_staging.`sys_manage_region`  smr on smr.id=ss.manage_region
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
where
    swm.created_at >= '2023-09-19'
    and swm.`operator_id` in ('87189', '607213')