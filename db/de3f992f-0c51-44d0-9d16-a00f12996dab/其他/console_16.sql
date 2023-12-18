with t as
(

    select
        dt.region_name
        ,dt.piece_name
        ,dt.store_name
        ,hsi.staff_info_id
        ,hsi.name
        ,hjt.job_name
        ,hsi.在职状态
        ,hsi.hire_days
        ,sd.sub_staff_info_id
        ,'y' as is_sub_staff
    from
    (
        select
            hsi.staff_info_id
            ,hsi.sys_store_id
            ,hsi.name
            ,case
	            when hsi.state = 1 and hsi.wait_leave_state = 0 then '在职'
	            when hsi.state = 1 and hsi.wait_leave_state = 1 then '待离职'
	            when hsi.state = 2 then '离职'
	            when hsi.state = 3 then '停职'
	            end 在职状态
            ,hsi.job_title
	        ,datediff(curdate(), hsi.hire_date) hire_days
        from bi_pro.hr_staff_info hsi
		where hsi.is_sub_staff=0 and hsi.formal in(1,4)
		and hsi.state = 1 -- 限制在职
        and hsi.job_title in (13,110,452) -- 限制快递员
    ) hsi #所有在职主账号且有子账号
    join backyard_pro.hr_staff_apply_support_store sd on hsi.staff_info_id=sd.staff_info_id and sd.support_status<4 and sd.sub_staff_info_id>0 #根据主账号找子账号
    left join dwm.dim_th_sys_store_rd dt on dt.store_id = hsi.sys_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
    left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
    union all
    select
        dt.region_name
        ,dt.piece_name
        ,dt.store_name
        ,hsi.staff_info_id
        ,hsi.name
        ,hjt.job_name
        ,hsi.在职状态
        ,hsi.hire_days
        ,hsi.staff_info_id as sub_staff_info_id
        ,'n' as is_sub_staff
    from
    (
        select
            hsi.staff_info_id
            ,hsi.sys_store_id
            ,hsi.name
            ,case
	            when hsi.state = 1 and hsi.wait_leave_state = 0 then '在职'
	            when hsi.state = 1 and hsi.wait_leave_state = 1 then '待离职'
	            when hsi.state = 2 then '离职'
	            when hsi.state = 3 then '停职'
	            end 在职状态
            ,hsi.job_title
	        ,datediff(curdate(), hsi.hire_date) hire_days

        from bi_pro.hr_staff_info hsi
		where hsi.is_sub_staff=0 and hsi.formal in(1,4)
		and hsi.state = 1 -- 限制在职
        and hsi.job_title in (13,110,452) -- 限制快递员
    ) hsi #所有在职主账号
    left join dwm.dim_th_sys_store_rd dt on dt.store_id = hsi.sys_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
    left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
)
select
    t1.region_name 大区
    ,t1.piece_name 片区
    ,t1.store_name 网点
    ,t1.staff_info_id 员工ID
    ,t1.name 姓名
    ,t1.job_name 职位
    ,t1.在职状态
    ,t1.hire_days 入职时长
    ,att7.absent_days 旷工天数_7月
    ,att7.late_days 迟到次数_7月
    ,round(att7.late_times/60,2) 迟到时长_hour_7月
    ,work_day7.workdays 工作天数_7月
    ,pick7.pick_num 揽收量_7月
    ,del7.del_num 妥投量_7月
    ,att8.absent_days 旷工天数_8月
    ,att8.late_days 迟到次数_8月
    ,round(att8.late_times/60,2) 迟到时长_hour_8月
    ,work_day8.workdays 工作天数_8月
    ,pick8.pick_num 揽收量_8月
    ,del8.del_num 妥投量_8月
from
    (
        select
            t1.*
        from t t1
        where
            t1.is_sub_staff = 'n'
    )t1
left join
    ( -- 7月出勤数据
        select
            t1.staff_info_id
            ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
            ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
            ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
        from bi_pro.attendance_data_v2 ad
        join t t1 on t1.staff_info_id = ad.staff_info_id and t1.is_sub_staff='n'
        where
            ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB = 10
            and ad.stat_date >= '2023-07-01'
            and ad.stat_date < '2023-08-01'
        group by 1
    ) att7 on att7.staff_info_id = t1.staff_info_id
left join
    (-- 7月揽收量
        select
            t1.staff_info_id
            ,count(distinct pi.pno) pick_num
        from fle_staging.parcel_info pi
        join t t1 on t1.sub_staff_info_id = pi.ticket_pickup_staff_info_id
        where
            pi.created_at >= '2023-06-30 17:00:00'
            and pi.created_at < '2023-07-31 17:00:00'
            and pi.state < 9
        group by 1
    ) pick7 on pick7.staff_info_id = t1.staff_info_id
left join
    (-- 7月妥投量
        select
            t1.staff_info_id
            ,count(distinct pi.pno) del_num
        from fle_staging.parcel_info pi
        join t t1 on t1.sub_staff_info_id = pi.ticket_pickup_staff_info_id
        where
            pi.finished_at >= '2023-06-30 17:00:00'
            and pi.finished_at < '2023-07-31 17:00:00'
            and pi.state = 5
        group by 1
    ) del7 on del7.staff_info_id = t1.staff_info_id
left join
    (-- 7月工作天数，因为路由和派件任务表都计划保存一个月数据，所以改用张桥中间表
        select
            fn.staff_info_id
            ,count(distinct fn.p_date) as workdays
        from
            (
		        select
		            t1.staff_info_id
		            ,date(convert_tz(pi.created_at,'+00:00','+07:00')) p_date
		            ,count(distinct pi.pno) as pno
		        from fle_staging.parcel_info pi
		        join t t1 on t1.sub_staff_info_id = pi.ticket_pickup_staff_info_id
		        where  pi.created_at >= '2023-06-30 17:00:00'
		        and pi.created_at < '2023-07-31 17:00:00'
		        and pi.state < 9
		        group by 1,2
		        union all
		        select
		            t1.staff_info_id
		            ,date(convert_tz(pi.finished_at,'+00:00','+07:00')) p_date
		            ,count(distinct pi.pno) as pno
		        from fle_staging.parcel_info pi
		        join t t1 on t1.sub_staff_info_id = pi.ticket_delivery_staff_info_id
		        where  pi.finished_at >= '2023-06-30 17:00:00'
		        and pi.finished_at < '2023-07-31 17:00:00'
		        and pi.state=5
		        group by 1,2
            )fn
        group by 1
    ) work_day7 on work_day7.staff_info_id = t1.staff_info_id
left join
    ( -- 8月出勤数据
        select
            t1.staff_info_id
            ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
            ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
            ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
        from bi_pro.attendance_data_v2 ad
        join t t1 on t1.staff_info_id = ad.staff_info_id
        where
            ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB = 10
            and ad.stat_date >= '2023-08-01'
            and ad.stat_date < '2023-09-01'
        group by 1
    ) att8 on att8.staff_info_id = t1.staff_info_id
left join
    (-- 8月揽收量
        select
            t1.staff_info_id
            ,count(distinct pi.pno) pick_num
        from fle_staging.parcel_info pi
        join t t1 on t1.sub_staff_info_id = pi.ticket_pickup_staff_info_id
        where
            pi.created_at >= '2023-07-31 17:00:00'
            and pi.created_at < '2023-08-31 17:00:00'
            and pi.state < 9
        group by 1
    ) pick8 on pick8.staff_info_id = t1.staff_info_id
left join
    (-- 8月妥投量
        select
            t1.staff_info_id
            ,count(distinct pi.pno) del_num
        from fle_staging.parcel_info pi
        join t t1 on t1.sub_staff_info_id = pi.ticket_pickup_staff_info_id
        where
            pi.finished_at >= '2023-07-31 17:00:00'
            and pi.finished_at < '2023-08-31 17:00:00'
            and pi.state = 5
        group by 1
    ) del8 on del8.staff_info_id = t1.staff_info_id
left join
    (-- 8月工作天数，直接按照路由表来，中间表更新频率较慢
        select
            fn.staff_info_id
            ,count(distinct fn.p_date) as workdays
        from
            (
		        select
		            t1.staff_info_id
		            ,date(convert_tz(pi.created_at,'+00:00','+07:00')) p_date
		            ,count(distinct pi.pno) as pno
		        from fle_staging.parcel_info pi
		        join t t1 on t1.sub_staff_info_id = pi.ticket_pickup_staff_info_id
		        where  pi.created_at >= '2023-07-31 17:00:00'
		        and pi.created_at < '2023-08-31 17:00:00'
		        and pi.state < 9
		        group by 1,2
		        union all
		        select
		            t1.staff_info_id
		            ,date(convert_tz(pi.finished_at,'+00:00','+07:00')) p_date
		            ,count(distinct pi.pno) as pno
		        from fle_staging.parcel_info pi
		        join t t1 on t1.sub_staff_info_id = pi.ticket_delivery_staff_info_id
		        where  pi.finished_at >= '2023-07-31 17:00:00'
		        and pi.finished_at < '2023-08-31 17:00:00'
		        and pi.state=5
		        group by 1,2
            )fn
        group by 1
    ) work_day8 on work_day8.staff_info_id = t1.staff_info_id