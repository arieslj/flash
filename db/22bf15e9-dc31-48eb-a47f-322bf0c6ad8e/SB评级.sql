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
                    from bi_pro.attendance_data_v2 ad
                    join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,452,37,16) -- 在职且非待离职
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
        when hsi2.job_title in (13,110,452) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,hsi2.job_title
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
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_th_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
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
                    from bi_pro.attendance_data_v2 ad
                    join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,452,37,16) -- 在职且非待离职
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
                        when hsi2.job_title in (13,110,452) then '快递员'
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
            ,count(if(hsi3.job_title in (13,110,452,37,16), hsi3.staff_info_id, null)) on_emp_cnt
            ,count(if(hsi3.job_title in (13,110,452), hsi3.staff_info_id, null)) on_dri_cnt
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

-- 交接评级
with d as
(
    select
         ds.dst_store_id store_id
        ,ds.pno
        ,ds.state
        ,ds.p_date stat_date
    from dwm.dwd_th_dc_should_be_delivery ds
    where
        ds.p_date = '${date}'
        and ds.should_delevry_type = '1派应派包裹'
),
t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.state
        ,case when pr1.pno is not null then 'N' when pr2.pno is not null then 'N' when ds1.pno is not null  then 'N'  else 'Y' end as handover_type
    from d ds
    left join
    (
        select
           pr.pno
           ,ds.stat_date
           ,max(convert_tz(pr.routed_at,'+00:00','+07:00')) remote_marker_time
        from rot_pro.parcel_route pr
        join d ds on pr.pno = ds.pno
        where 1=1
        and pr.routed_at >= date_sub(ds.stat_date, interval 7 hour)
        and pr.routed_at < date_add(ds.stat_date, interval 17 hour)
        and pr.route_action = 'DETAIN_WAREHOUSE'
        and pr.marker_category in (42,43) ##岛屿,偏远地区
        group by 1,2
    ) pr1  on ds.pno=pr1.pno#当日留仓标记为偏远地区留待次日派送
    left join
    (
        select
           pr.pno
           ,ds.stat_date
           ,convert_tz(pr.routed_at,'+00:00','+07:00') reschedule_marker_time
           ,date(date_sub(FROM_UNIXTIME(json_extract(pr.extra_value,'$.desiredAt')),interval 1 hour)) desire_date
           ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join d ds on pr.pno = ds.pno
        where 1=1
        and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
        and pr.routed_at <  date_sub(ds.stat_date ,interval 7 hour) #限定当日之前的改约
        and pr.route_action = 'DETAIN_WAREHOUSE'
        and FROM_UNIXTIME(json_extract(pr.extra_value,'$.desiredAt'))> date_add(ds.stat_date, interval 17 hour)
        and pr.marker_category in (9,14,70) ##客户改约时间
    ) pr2 on ds.pno=pr2.pno and pr2.rk=1 #当日之前客户改约时间

    left join bi_pro.dc_should_delivery_today ds1
    on ds.pno = ds1.pno and ds1.state=6
    and ds1.stat_date=date_sub(ds.stat_date,interval 1 day)

    where case when pr1.pno is not null then 'N' when pr2.pno is not null then 'N' when ds1.pno is not null  then 'N'  else 'Y' end = 'Y'
)

select
    a.stat_date 日期
    ,a.store_id 网点ID
    ,dp.store_name 网点名称
    ,dp.opening_at 开业时间
    ,if(dp.region_name in ('Area1', 'Area2', 'Area3', 'Area4', 'Area5', 'Area6', 'Area7', 'Area8', 'Area9', 'Area11', 'Area12', 'Area13', 'Area14', 'Area15', 'Area16'), 'Normal_Area', 'Bulky_Area') 区域
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,a.应交接
    ,a.已交接
    ,concat(round(a.交接率*100,2),'%') as 交接率
    ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
    ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
    ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
    ,concat(round(a.C_rate * 100,2),'%') 'C时段（1200<=X<1600 ）'
    ,concat(round(a.D_rate * 100,2),'%') 'D时段（>=1600）'
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
                            ,convert_tz(pr.routed_at, '+00:00', '+07:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from rot_pro.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 7 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 17 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
        group by 1,2
    ) a
# join
#     (
#         select
#             sd.store_id
#         from fle_staging.sys_district sd
#         where
#             sd.deleted = 0
#             and sd.store_id is not null
#         group by 1
#
#         union all
#
#         select
#             sd.separation_store_id store_id
#         from fle_staging.sys_district sd
#         where
#             sd.deleted = 0
#             and sd.separation_store_id is not null
#         group by 1
#     ) sd on sd.store_id = a.store_id
left join dwm.dim_th_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(a.stat_date, interval 1 day)
where dp.store_category in (1,10,13)

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
    from dwm.dwd_th_dc_should_be_delivery ds
    left join rot_pro.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join fle_staging.parcel_info pi on pi.pno = pr.pno
    left join bi_pro.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
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
                ,count(distinct if(a1.job_title in (13,110,452), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,452), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,452), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,452), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,452), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,452), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,452), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,452), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,452), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,452), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,452), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,452), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,452), a1.staff_info_id, null)) other_avg_staff_del_code
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
                        join dwm.drds_parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code not in  ('XX', 'YY', 'ZZ', '00')
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join fle_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  bi_pro.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,452)
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
left join dwm.dim_th_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join fle_staging.sys_store ss on ss.id = a2.store_id
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,452), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,452) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,452), t1.pno, null))/count(distinct if(t1.job_title in (13,110,452),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,452) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,452) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            a.store_id
            ,count(distinct a.code) code_num
        from
            (
                select
                    sts.store_id
                    ,sts.sorting_code code
                from fle_staging.sys_three_sorting sts
                where
                    sts.deleted = 0

                union all

                select
                    stf.store_id
                    ,stf.sorting_fence_code code
                from fle_staging.sys_three_fence_sorting stf
                where
                    stf.deleted = 0
            ) a
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
    from dwm.dwd_th_dc_should_be_delivery ds
    join fle_staging.parcel_info pi on pi.pno = ds.pno
    left join fle_staging.sys_store ss on ss.id = ds.dst_store_id
    left join bi_pro.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '${date}'
    left join bi_pro.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '${date}')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '${date}'
        and pi.finished_at >= date_sub('${date}', interval 8 hour )
        and pi.finished_at < date_add('${date}', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and ds.dst_store_id = 'TH16020303'
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
        from dwm.dim_th_sys_store_rd dp
        left join fle_staging.sys_store ss on ss.id = dp.store_id
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
        from  bi_pro.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,452)
#             and hr.stat_date = '${date}'
        group by 1
    ) cour on cour.sys_store_id = dp.store_id
left join
    (
        select
            ds.dst_store_id
            ,count(distinct ds.pno) sd_num
        from dwm.dwd_th_dc_should_be_delivery ds
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
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,452) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,452) and t1.formal = 1, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,452) and t1.formal = 1, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,452), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,452), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1) and t1.job_title in (13,110,452), t1.ticket_delivery_staff_info_id, null)) other_effect

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


-- 看下有没有地理围栏和乡编号


select
    a.store_id
    ,count(distinct a.code) code_num
from
    (
        select
            sts.store_id
            ,sts.sorting_code code
        from fle_staging.sys_three_sorting sts
        where
            sts.deleted = 0

        union all

        select
            stf.store_id
            ,stf.sorting_fence_code code
        from fle_staging.sys_three_fence_sorting stf
        where
            stf.deleted = 0
    ) a
where
    a.store_id in ('TH65010808','TH01180135','TH01410223','TH01080144','TH01390232','TH19070136','TH02030523','TH01010127','TH04060232','TH67010525','TH04060162','TH02030432','TH68040618','TH20070230','TH01050214','TH67010432','TH01470132','TH02010234','TH01220311','TH01420113','TH01430144','TH02010631','TH02030329','TH02030132')
group by 1
