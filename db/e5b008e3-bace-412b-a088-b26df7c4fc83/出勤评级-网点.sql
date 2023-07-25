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
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.opening_at 开业时间
    ,case dp.store_category
        when 1 then 'SP'
        when 2 then 'DC'
        when 4 then 'SHOP'
        when 5 then 'SHOP'
        when 6 then 'FH'
        when 7 then 'SHOP'
        when 8 then 'Hub'
        when 9 then 'Onsite'
        when 10 then 'BDC'
        when 11 then 'fulfillment'
        when 12 then 'B-HUB'
        when 13 then 'CDC'
        when 14 then 'PDC'
    end 网点类型
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天人均迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0
    and dp.store_category = 1





