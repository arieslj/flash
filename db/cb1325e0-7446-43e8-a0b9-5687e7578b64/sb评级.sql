-- 出勤员工表
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
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
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
        when hsi2.job_title in (13,110,1199) then '快递员'
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
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1

;


-- 网点出勤评级

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
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < '${date}'
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
                        when hsi2.job_title in (13,110,1199) then '快递员'
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
                left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
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
            ,count(if(hsi3.job_title in (13,110,1199,37,16), hsi3.staff_info_id, null)) on_emp_cnt
            ,count(if(hsi3.job_title in (13,110,1199), hsi3.staff_info_id, null)) on_dri_cnt
            ,count(if(hsi3.job_title in (37), hsi3.staff_info_id, null)) on_dco_cnt
            ,count(if(hsi3.job_title in (16), hsi3.staff_info_id, null)) on_dcs_cnt
        from my_bi.hr_staff_transfer  hsi3
        left join my_staging.sys_store ss2 on ss2.id = hsi3.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss2.manage_region
        where
            hsi3.state = 1
            and hsi3.formal=1
            and hsi3.stat_date = date_sub(curdate(), interval 1 day)
        group by 1,2,3,4,5,6
    )dp on dp.store_id = ss.store_id
where
    dp.store_category in (1,10)

;

-- 交接评级

with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.p_date stat_date
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.should_delevry_type = '1派应派包裹'
        and ds.p_date =  '${date}'
#         and dst_store_id = 'MY09040318'
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from my_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from my_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join my_bi .dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
#             ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
#             ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
#             ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
#             ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from my_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
#         left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category in (1,10)
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
# where
#     a2.rk = 1


;

-- 锁区评级


with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_my_dc_should_be_delivery ds
    left join my_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join my_staging.parcel_info pi on pi.pno = pr.pno
    left join my_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '${date}'
        and pr.routed_at >= date_sub('${date}', interval 8 hour )
        and pr.routed_at < date_add('${date}', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case ss.category
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
        ,smp.name 片区
        ,smr.name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1 ), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1199), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1199), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1199), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join my_drds_pro.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join my_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1199)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
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
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_my_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.sys_store ss on ss.id = a2.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1199), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1199) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            gl.store_id
            ,count(distinct gl.grid_code) code_num
        from `my-amp`.grid_lib gl
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    ss.category in (1,10)
    and sdb.store_id is not null


;


# 评级总表

with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_my_dc_should_be_delivery ds
    join my_staging.parcel_info pi on pi.pno = ds.pno
    left join my_staging.sys_store ss on ss.id = ds.dst_store_id
    left join my_bi.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '${date}'
    left join my_bi.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '${date}')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '${date}'
        and pi.finished_at >= date_sub('${date}', interval 8 hour )
        and pi.finished_at < date_add('${date}', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_my_sys_store_rd dp
        left join my_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.sys_store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  my_bi.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,1199)
#             and hr.stat_date = '${date}'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_my_dc_should_be_delivery ds
        where
             ds.should_delevry_type != '非当日应派'
            and ds.p_date = '${date}'
        group by 1
    ) ds on ds.dst_store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct t1.pno) pno_num
        from t t1
        group by 1
    ) del on del.store_id = dp.store_id
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,1199) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,1199), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
        from t t1
        group by 1
    ) del_cou on del_cou.store_id = dp.store_id
left join
    (
        select
            a.store_id
            ,a.name
            ,sum(diff_hour)/count(distinct a.ticket_delivery_staff_info_id) avg_del_hour
        from
            (
                select
                    t1.store_id
                    ,t1.name
                    ,t1.ticket_delivery_staff_info_id
                    ,t1.finished_time
                    ,t2.finished_time finished_at_2
                    ,timestampdiff(second, t1.finished_time, t2.finished_time)/3600 diff_hour
                from
                    (
                        select * from t t1 where t1.rk1 = 1
                    ) t1
                join
                    (
                        select * from t t2 where t2.rk2 = 2
                    ) t2 on t2.store_id = t1.store_id and t2.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
            ) a
        group by 1,2
    ) del_hour on del_hour.store_id = dp.store_id

;

select
    *
from `my-amp`.grid_lib gl
where
    gl.store_id in ('MY15050301')
;



select -- 基于当日应派取扫描率
    tt.store_id 网点ID
    ,tt.store_name 网点名称
    ,'一派网点' as  网点分类
    ,tt.piece_name 片区
    ,tt.region_name 大区
    ,tt.shoud_counts 应派数
    ,tt.scan_fished_counts 分拣扫描数
    ,ifnull(tt.scan_fished_counts/shoud_counts,0) 分拣扫描率

    ,tt.youxiao_counts 有效分拣扫描数
    ,ifnull(tt.youxiao_counts/tt.scan_fished_counts,0) 有效分拣扫描率

    ,tt.1pai_counts 一派应派数
    ,tt.1pai_scan_fished_counts 一派分拣扫描数
    ,ifnull(tt.1pai_scan_fished_counts/tt.1pai_counts,0) 一派分拣扫描率

    ,tt.1pai_youxiao_counts 一派有效分拣扫描数
    ,ifnull(tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts,0) 一派有效分拣扫描率
    ,
    case
	    when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.95 then 'A'
	    when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.90 then 'B'
	    when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.85 then 'C'
	    when tt.1pai_youxiao_counts/tt.1pai_scan_fished_counts>=0.80 then 'D'
	    else 'E'
	 end 一派有效分拣评级 -- 一派有效分拣

	 ,case
        when tt.1pai_hour_8_fished_counts/tt.1pai_counts>=0.95  then 'A'
        when tt.1pai_hour_8ban_fished_counts/tt.1pai_counts>=0.95  then 'B'
        when tt.1pai_hour_9_fished_counts/tt.1pai_counts>=0.95  then 'C'
        when tt.1pai_hour_9ban_fished_counts/tt.1pai_counts>=0.95  then 'D'
        else 'E'
       end 一派分拣评级

    ,ifnull(tt.1pai_hour_8_fished_counts/tt.1pai_counts,0) 一派8点前扫描占比
    ,ifnull(tt.1pai_hour_8ban_fished_counts/tt.1pai_counts,0) 一派8点半前扫描占比
    ,ifnull(tt.1pai_hour_9_fished_counts/tt.1pai_counts,0) 一派9点前扫描占比
    ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0) 一派9点半前扫描占比

    ,tt2.max_real_arrive_time_normal 一派前常规车最晚实际到达时间
    ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
    ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
    ,tt2.line_1_latest_plan_arrive_time 一派前常规车最晚规划到达时间
    ,tt2.max_real_arrive_time_innormal 一派前加班车最晚实际到达时间
    ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
    ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
    ,tt2.max_actual_plan_arrive_time_innormal 一派前加班车最晚规划到达时间
	,tt2.late_proof_counts 一派常规车线实际比计划时间晚20分钟车辆数
    ,if(tt2.late_proof_counts > 0, '是', '否' )  是否有一派常规车线实际比计划时间晚20分钟车辆数
from
(
    select
       base.store_id
       ,base.store_name
       ,base.store_type
       ,base.piece_name
       ,base.region_name
       ,count(distinct base.pno) shoud_counts
       ,count(distinct case when base.min_fenjian_scan_time is not null then base.pno else null end ) scan_fished_counts
       ,count(distinct case when base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end ) youxiao_counts

       ,count(distinct case when base.type='一派' then  base.pno else null end ) 1pai_counts
       ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null then  base.pno else null end ) 1pai_scan_fished_counts
       ,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then  base.pno else null end ) 1pai_youxiao_counts

       ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then base.pno else null end) 1pai_hour_8_fished_counts
       ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then base.pno else null end) 1pai_hour_8ban_fished_counts
       ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then base.pno else null end) 1pai_hour_9_fished_counts
       ,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then base.pno else null end) 1pai_hour_9ban_fished_counts

    from
    (
       select
           t.*,
           case
               when t.should_delevry_type='1派应派包裹' then '一派'
               else null
            end 'type'
       from dwm.dwd_my_dc_should_be_delivery_sort_scan t
       join my_staging.sys_store ss on t.store_id =ss.id and ss.category in (1,10)
    ) base
    group by base.store_id,base.store_name,base.store_type,base.piece_name,base.region_name
) tt

left join
(
    select
       bl.store_id
       ,bl.max_real_arrive_time_normal
       ,bl.max_real_arrive_proof_id
       ,bl.max_real_arrive_vol
       ,bl.line_1_latest_plan_arrive_time
       ,bl.max_actual_plan_arrive_time_innormal
       ,bl.max_actual_plan_arrive_innormal_proof_id
       ,bl.max_actual_plan_arrive_innormal_vol
       ,bl.max_real_arrive_time_innormal
       ,bl.max_real_arrive_innormal_proof_id
       ,bl.max_real_arrive_innormal_vol
	   ,late_proof_counts
    from dwm.fleet_real_detail_today bl
    group by 1,2,3,4,5,6,7,8,9,10,11
) tt2 on tt.store_id=tt2.store_id
