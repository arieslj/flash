 with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.hire_date
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,date(t1.hire_date) 入职时间
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区d
    ,t1.mr_name 所属大区
    ,sa5.version 员工kit最新版本
    ,sa6.version 员工backyard最新版本


    ,swa.end_at 0815下班打卡时间
    ,swa.end_clientid 0815下班打卡设备id
    ,if((ad.`shift_start`<>'' or ad.`shift_end`<>''),1,0) 0815是否排班
    ,if((ad.`attendance_started_at` is not null or ad.`attendance_end_at` is not null),1,0) 0815是否出勤
    ,if(length(ad.leave_type ) > 0 , 1, 0) 0815是否请假
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0815下班打卡设备
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-08-15'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id
left join ph_bi.attendance_data_v2 ad on ad.staff_info_id = t1.staff_info_id and ad.stat_date = swa.attendance_date


left join ph_staging.staff_account sa5 on sa5.staff_info_id = t1.staff_info_id and sa5.equipment_type = 1-- kit
left join ph_staging.staff_account sa6 on sa6.staff_info_id = t1.staff_info_id and sa6.equipment_type = 3-- by