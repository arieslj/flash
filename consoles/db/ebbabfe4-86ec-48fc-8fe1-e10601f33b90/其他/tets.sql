select
    a.*
    ,a.工号 '工号/Employee ID'
    ,a.日期 '违规日期/Violation date'
    ,4 '违规类型/Violation type'
    ,json_object('late_detail', a.late_detail, 'late_minutes', a.late_minutes) '违规详情/Violation details'
from
    (
                select
        adv.stat_date '日期'
        ,hsi.staff_info_id '工号'
        ,hsi.name '姓名'
        ,hsi.mobile '电话号码'
        ,case when hsi.formal=1 and hsi.hire_type=13 and hsi.is_sub_staff=0 then '个人代理'
        when hsi.formal=1 and hsi.is_sub_staff=0 then '正式员工'
        when hsi.formal=1 and hsi.is_sub_staff=1 then '子账号支援'
        when hsi.formal=0 then '非正式员工'
        else hsi.formal
        end '员工类型'
        ,hjt.job_name '职位'
        ,case  when hsi.`state`=1  then '在职'
              when hsi.`state`=2 then '离职'
              when hsi.`state`=3 then '停职'
              end as '在职状态'
        ,ifnull(smr.name,smr1.name,smr2.name) '大区'
        ,ifnull(smp.name,smp1.name) '片区'
        ,ss.name '网点'
        ,adv.attendance_started_at '上班打卡时间'
        ,adv.shift_start '应上班打卡时间'
        ,round(datediff('second',adv.shift_start,adv.attendance_started_at)/60,1) '迟到分钟数'
        ,dd.num '累计(10min内)迟到次数'
        ,hsi.hire_date '入职日期'
        ,date_diff(current_date(),hsi.hire_date) '入职天数'
        ,concat(date_format(adv.stat_date, '%d/%m/%Y'),'[', adv.shift_start1, '-', adv.shift_end1, ']', date_format(adv.attendance_started_at, '%H:%i'), ' Lewat ', timestampdiff(minute , concat(adv.stat_date, ' ', adv.shift_start1), adv.attendance_started_at), ' minit' ) late_detail
            ,timestampdiff(minute , concat(adv.stat_date, ' ', adv.shift_start1), adv.attendance_started_at)  late_minutes
        from
        (select
        adv.stat_date
        ,staff_info_id
        ,adv.attendance_time
        ,adv.attendance_started_at
        ,adv.attendance_end_at
        ,adv.shift_start as shift_start1
        ,adv.shift_end as shift_end1
        ,concat(stat_date,' ',adv.shift_start)  'shift_start'
        ,concat(stat_date,' ',adv.shift_end)  'shift_end'
        from my_bi.attendance_data_v2 adv
        where adv.stat_date =current_date()-interval 1 day
        and adv.display_data<>'REST'
        )adv
        join my_bi.hr_staff_info hsi on hsi.staff_info_id=adv.staff_info_id
        and  hsi.sys_department_id in ('320','316','15084')
        and hsi.state=1
        and hsi.formal<>4

        left join my_bi.hr_job_title hjt on hjt.id=hsi.job_title
        left join my_staging.sys_store ss on ss.id=hsi.sys_store_id
        left join my_staging.sys_manage_region smr on smr.id=ss.manage_region
        left join my_staging.sys_manage_piece smp on smp.id=ss.manage_piece
        left join my_staging.sys_manage_region smr1 on smr1.manager_id=hsi.staff_info_id
        left join my_staging.sys_manage_piece smp1 on smp1.manager_id=hsi.staff_info_id
        left join my_staging.sys_manage_region smr2 on smr2.id=smp1.manage_region_id
        left join
        (select  adv.staff_info_id
        ,count(*) num
        from my_bi.attendance_data_v2 adv
        where adv.stat_date>= date_sub(current_date()-interval 1 day,interval weekday(current_date()-interval 1 day) day)
        and adv.stat_date<current_date()
        and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)>60 and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)<600
        group by 1
        having count(*)>=3
        )dd on dd.staff_info_id=adv.staff_info_id
        left join
        (select  adv.staff_info_id
        from my_bi.attendance_data_v2 adv
        where adv.stat_date=current_date()-interval 1 day
        and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)>60 and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)<600
        )dd1 on dd1.staff_info_id=adv.staff_info_id
        left join
                (# 剔除排休快递员
                    select
                        hw.date_at
                        ,hw.staff_info_id
                    from my_backyard.hr_staff_work_days hw
                    where hw.date_at=date_sub(current_date,interval 1 day)
                )f3 on f3.staff_info_id=adv.staff_info_id
        left join
        (select
        dd.staff_info_id
        ,dd.leave_start_time
        ,dd. leave_end_time
        from my_backyard.staff_audit dd
        WHERE `audit_type` = 2
        and status =2
        and dd.leave_start_time<=current_date()-interval 1 day
        and dd.leave_end_time>=current_date()-interval 1 day
        )dd2 on dd2.staff_info_id=adv.staff_info_id


        where ((datediff('second',adv.shift_start,adv.attendance_started_at)/60>=10)
        or (dd.num>=3 and dd1.staff_info_id is not null))
        and f3.staff_info_id is null
        and dd2.staff_info_id is null
    ) a