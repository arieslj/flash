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
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                        and hsi.hire_date <= date_sub(curdate(), interval 7 day )
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
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1













;


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
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)

select

    dp.region_name 大区
    ,count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 出勤人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 迟到占比_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 缺勤占比_快递员

    ,count(if(hsi2.job_title in (37), st.staff_info_id, null)) 出勤人次_仓管
    ,count(if(hsi2.job_title in (37) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_仓管
    ,count(if(hsi2.job_title in (37) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_仓管
    ,count(if(hsi2.job_title in (37) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (37), st.staff_info_id, null)) 迟到占比_仓管
    ,count(if(hsi2.job_title in (37) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (37), st.staff_info_id, null)) 缺勤占比_仓管

    ,count(if(hsi2.job_title in (16), st.staff_info_id, null)) 出勤人次_主管
    ,count(if(hsi2.job_title in (16) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_主管
    ,count(if(hsi2.job_title in (16) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_主管
    ,count(if(hsi2.job_title in (16) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (16), st.staff_info_id, null)) 迟到占比_主管
    ,count(if(hsi2.job_title in (16) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (16), st.staff_info_id, null)) 缺勤占比_主管
from
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
group by 1
with rollup
