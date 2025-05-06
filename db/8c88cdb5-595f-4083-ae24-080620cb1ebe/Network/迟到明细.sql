with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.BT_Y + ad.AB total
                    from bi_pro.attendance_data_v2 ad
                    join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,452,37,16,451,1497) -- 在职且非待离职,1497 van-feeder
                    where
                        ad.stat_date < '${date}'
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,452,1497) then '快递员'
        when hsi2.job_title in (37,451) then '仓管员' -- 451副主管
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.stat_date 迟到日期
    ,st.late_time 当日迟到分钟
    ,count(st.stat_date) over (partition by st.staff_info_id) 近7应出勤迟到次数
from
    (
        select
            a.staff_info_id
            ,a.stat_date
            ,a.late_time
#             ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#             ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#             ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
                where
                    t1.total = 10
                    or (t1.total =  5 and t1.leave_time_type = 2)

                union all

                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 5 hour), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 5 hour), interval 1 minute ) , timestampdiff(minute , date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 5 hour), t1.attendance_started_at), 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
                where
                    t1.total = 5
                    and t1.leave_time_type = 1 -- 上午请假
            ) a
        where
            a.late_or_not = 'y'
    ) st
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_th_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    hsi2.job_title = 16
order by 2,1
