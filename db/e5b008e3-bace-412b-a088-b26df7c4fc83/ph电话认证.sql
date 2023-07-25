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


    ,swa.end_at 0711下班打卡时间
    ,swa.end_clientid 0711下班打卡设备id
    ,if((ad.`shift_start`<>'' or ad.`shift_end`<>''),1,0) 0711是否排班
    ,if((ad.`attendance_started_at` is not null or ad.`attendance_end_at` is not null),1,0) 0711是否出勤
    ,if(length(ad.leave_type ) > 0 , 1, 0) 0711是否请假
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备

    ,swa2.end_at 0712下班打卡时间
    ,swa2.end_clientid 0712下班打卡设备id
    ,if((ad2.`shift_start`<>'' or ad2.`shift_end`<>''),1,0) 0712是否排班
    ,if((ad2.`attendance_started_at` is not null or ad2.`attendance_end_at` is not null),1,0) 0712是否出勤
    ,if(length(ad2.leave_type ) > 0 , 1, 0)0712是否请假
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备

    ,swa3.end_at 0713下班打卡时间
    ,swa3.end_clientid 0713下班打卡设备id
    ,if((ad3.`shift_start`<>'' or ad3.`shift_end`<>''),1,0) 0713是否排班
    ,if((ad3.`attendance_started_at` is not null or ad3.`attendance_end_at` is not null),1,0) 0713是否出勤
    ,if(length(ad3.leave_type ) > 0 , 1, 0) 0713是否请假
    ,case sa3.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0713下班打卡设备

    ,swa4.end_at 0714下班打卡时间
    ,swa4.end_clientid 0714下班打卡设备id
    ,if((ad4.`shift_start`<>'' or ad4.`shift_end`<>''),1,0) 0714是否排班
    ,if((ad4.`attendance_started_at` is not null or ad4.`attendance_end_at` is not null),1,0) 0714是否出勤
    ,if(length(ad4.leave_type ) > 0 , 1, 0) 0714是否请假
    ,case sa4.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0714下班打卡设备

    ,swa7.end_at 0715下班打卡时间
    ,swa7.end_clientid 0715下班打卡设备id
    ,if((ad7.`shift_start`<>'' or ad7.`shift_end`<>''),1,0) 0715是否排班
    ,if((ad7.`attendance_started_at` is not null or ad7.`attendance_end_at` is not null),1,0) 0715是否出勤
    ,if(length(ad7.leave_type ) > 0 , 1, 0) 0715是否请假
    ,case sa7.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0715下班打卡设备
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id
left join ph_bi.attendance_data_v2 ad on ad.staff_info_id = t1.staff_info_id and ad.stat_date = swa.attendance_date

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id
left join ph_bi.attendance_data_v2 ad2 on ad2.staff_info_id = t1.staff_info_id and ad2.stat_date = swa2.attendance_date

left join ph_backyard.staff_work_attendance swa3 on swa3.staff_info_id = t1.staff_info_id and swa3.attendance_date = '2023-07-13'
left join ph_staging.staff_account sa3 on sa3.clientid = swa3.end_clientid and swa3.staff_info_id = sa3.staff_info_id
left join ph_bi.attendance_data_v2 ad3 on ad3.staff_info_id = t1.staff_info_id and ad3.stat_date = swa3.attendance_date

left join ph_backyard.staff_work_attendance swa4 on swa4.staff_info_id = t1.staff_info_id and swa4.attendance_date = '2023-07-14'
left join ph_staging.staff_account sa4 on sa4.clientid = swa4.end_clientid and swa4.staff_info_id = sa4.staff_info_id
left join ph_bi.attendance_data_v2 ad4 on ad4.staff_info_id = t1.staff_info_id and ad4.stat_date = swa4.attendance_date

left join ph_backyard.staff_work_attendance swa7 on swa7.staff_info_id = t1.staff_info_id and swa7.attendance_date = '2023-07-15'
left join ph_staging.staff_account sa7 on sa7.clientid = swa7.end_clientid and swa7.staff_info_id = sa7.staff_info_id
left join ph_bi.attendance_data_v2 ad7 on ad7.staff_info_id = t1.staff_info_id and ad7.stat_date = swa7.attendance_date

left join ph_staging.staff_account sa5 on sa5.staff_info_id = t1.staff_info_id and sa5.equipment_type = 1-- kit
left join ph_staging.staff_account sa6 on sa6.staff_info_id = t1.staff_info_id and sa6.equipment_type = 3-- by