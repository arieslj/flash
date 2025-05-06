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
                    from bi_pro.attendance_data_v2 ad
                    join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and hsi.hire_date <= date_sub(curdate(), interval 7 day )
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
    ,coalesce(dp.opening_at, '未记录') 开业时间
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
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end 出勤评级
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级员工数
    ,dp.on_emp_cnt 在职员工数
    ,dp.on_dcs_cnt 主管数
    ,dp.on_dco_cnt 仓管数
    ,dp.on_dri_cnt 快递员数

    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天迟到人次
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
                                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_th_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join
    (
        select
            hsi3.store_id store_id
            ,ss2.name store_name
            ,smp.name piece_name
            ,smr.name region_name
            ,ss2.category store_category
            ,ss2.opening_at
            ,count(if(hsi3.job_title in (13,110,1000,37,16), hsi3.staff_info_id, null)) on_emp_cnt
            ,count(if(hsi3.job_title in (13,110,1000), hsi3.staff_info_id, null)) on_dri_cnt
            ,count(if(hsi3.job_title in (37), hsi3.staff_info_id, null)) on_dco_cnt
            ,count(if(hsi3.job_title in (16), hsi3.staff_info_id, null)) on_dcs_cnt
        from bi_pro.hr_staff_transfer  hsi3
        left join fle_staging.sys_store ss2 on ss2.id = hsi3.store_id
        left join fle_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
        left join fle_staging.sys_manage_region smr on smr.id = ss2.manage_region
        where
            hsi3.state = 1
            and hsi3.formal=1
            and hsi3.stat_date = date_sub(curdate(), interval 1 day)
        group by 1,2,3,4,5,6
    )dp on dp.store_id = ss.store_id
where
    dp.store_category in (1,10)

;



;
#
#  -- 派件小时数
# with t as
# (
#     select
#         ds.dst_store_id store_id
#         ,ss.name
#         ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
#         ,pi.ticket_delivery_staff_info_id
#         ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
#         ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
#     from dwm.dwd_ph_dc_should_be_delivery ds
#     join ph_staging.parcel_info pi on pi.pno = ds.pno
#     left join ph_staging.sys_store ss on ss.id = ds.dst_store_id
#     where
#         pi.state = 5
#         and pi.finished_at >= '2023-07-31 16:00:00'
#         and pi.finished_at < '2023-08-01 16:00:00'
# #         and ds.store_id = 'PH40010900'
# )
# select
#     a.store_id
#     ,a.name
#     ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
# from
#     (
#         select
#             t1.store_id
#             ,t1.name
#             ,t1.ticket_delivery_staff_info_id
#             ,t1.finished_time
#             ,t2.finished_time finished_at_2
#             ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
#         from
#             (
#                 select * from t t1 where t1.rk1 = 1
#             ) t1
#         join
#             (
#                 select * from t t2 where t2.rk2 = 2
#             ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
#     ) a
# group by 1,2
#
#
# ;
#
#
# select
#     emp_cnt.sys_store_id
#     ,emp_cnt.staf_num
#     ,att.atd_emp_cnt
# from
#     (
#         select
#             hr.sys_store_id
#             ,count(distinct hr.staff_info_id) staf_num
#         from  ph_bi.hr_staff_info  hr
#         where
#             hr.formal = 1
#             and hr.is_sub_staff= 0
#             and hr.state = 1
#             and hr.job_title in (13,110,1000)
#         group by 1
#     ) emp_cnt
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = curdate()
#        group by 1
#     ) att on att.sys_store_id = emp_cnt.sys_store_id
#
#
#
# ;
#
# select
#     ad.sys_store_id
#     ,count(ad.staff_info_id) 应出勤人数
#     ,count(if(ad.attendance_started_at is not null or ad.attendance_end_at is not null , ad.staff_info_id, null)) 出勤人数
# from ph_bi.attendance_data_v2 ad
# where
#     ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB = 10
#     and ad.stat_date = curdate()
# group by 1
#
#
# ;
#
#
# select
#     ds.store_id
#     ,ss.name
#     ,count(ds.pno) 应派包裹量
#     ,count(if(pi.state = 5, ds.pno, null)) 妥投包裹量
#     ,count(distinct if(pi.state = 5, pi.ticket_delivery_staff_info_id, null)) 妥投快递员数
#     ,count(if(pi.state = 5, ds.pno, null))/count(distinct if(pi.state = 5, pi.ticket_delivery_staff_info_id, null)) 当日人效
# from ph_bi.dc_should_delivery_today ds
# left join ph_staging.parcel_info pi on pi.pno = ds.pno
# left join ph_staging.sys_store ss on ss.id = ds.store_id
# where
#     ds.stat_date = '2023-07-25'
# group by 1,2;
