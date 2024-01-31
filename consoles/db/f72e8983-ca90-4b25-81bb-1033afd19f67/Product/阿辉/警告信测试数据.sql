-- 未按要求联系客户
select
    f2.大区
    ,f2.片区
    ,f2.网点
    ,f2.store_id
    ,f2.员工ID
    ,f2.快递员姓名
    ,f2.no_return_parcel_count 非退件交接量
    ,f2.no_return_delivery_parcel_count 非退件妥投量
    ,f2.return_delivery_parcel_count 退件妥投量
    ,f2.hand_no_call_count 交接包裹未拨打电话数
    ,f2.hand_no_call_ratio 交接包裹未拨打电话占比
from
    (
        select
            f1.*
            ,row_number() over (partition by f1.store_id, f1.员工ID order by f1.hand_no_call_ratio desc) rk
        from
            (
                select
                    fn.region_name as 大区
                    ,fn.piece_name as 片区
                    ,fn.store_name as 网点
                    ,fn.store_id
                    ,fn.staff_info_id as 员工ID
                    ,fn.staff_name as 快递员姓名
                    ,count(distinct if(fn.returned = 0, fn.pno, null)) as no_return_parcel_count
                    ,count(distinct if(fn.pi_state = 5 and fn.returned = 0, fn.pno, null)) no_return_delivery_parcel_count
                    ,count(distinct if(fn.pi_state = 5 and fn.returned = 1, fn.pno, null)) return_delivery_parcel_count
                    ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end) as hand_no_call_count
                    ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end)/count(distinct fn.pno) as hand_no_call_ratio
                from
                    (
                         select
                            fn.pno
                            ,fn.pno_type
                            ,fn.store_id
                            ,fn.store_name
                            ,fn.piece_name
                            ,fn.region_name
                            ,fn.staff_info_id
                            ,fn.staff_name
                            ,fn.finished_at
                            ,fn.pi_state
                            ,fn.returned
                            ,fn.before_17_calltimes
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,dp.store_name
                                    ,dp.piece_name
                                    ,dp.region_name
                                    ,pr.staff_info_id
                                    ,pi.state pi_state
                                    ,pi.returned
                                    ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                                    ,if(pi.returned=1,'退件','正向件') as pno_type
                                    ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                                    ,pr.staff_name
                                    ,pr2.before_17_calltimes
                                from
                                    ( # 所有17点前交接包裹找到最后一次交接的人
                                        select
                                            pr.*
                                        from
                                            (
                                                select
                                                    pr.pno
                                                    ,pr.staff_info_id
                                                    ,hsi.name as staff_name
                                                    ,pr.store_id
                                                    ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
                                                from my_staging.parcel_route pr
                                                left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                                                left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                                                where
                                                    pr.routed_at >= date_sub(curdate(), interval 8 hour)
                                                    and pr.routed_at < date_add(curdate(), interval 9 hour)
                                                    and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
                                                    and hsi.job_title in (13,110,1199)
                                                    and hsi.formal = 1
                                            ) pr
                                        where  pr.rnk = 1
                                    ) pr
                                join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category = 1
                                left join my_staging.parcel_info pi on pr.pno = pi.pno
                                left join # 17点前拨打电话次数
                                    (
                                        select
                                            pr.pno
                                            ,count(pr.call_datetime) as before_17_calltimes
                                        from
                                            (
                                                select
                                                        pr.pno
                                                        ,pr.staff_info_id
                                                        ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
                                                 from my_staging.parcel_route pr
                                                 where
                                                    pr.routed_at >= date_sub(curdate(), interval 8 hour)
                                                    and pr.routed_at < date_add(curdate(), interval 9 hour)
                                                    and pr.route_action in ('PHONE')
                                            )pr
                                        group by 1
                                    )pr2 on pr.pno = pr2.pno
                            )fn
                    ) fn
                group by 1,2,3,4,5,6
            ) f1
        where
            f1.hand_no_call_count > 10
            and f1.hand_no_call_ratio > 0.2
    ) f2
where
    f2.rk <= 2

;


-- 低效快递员

SELECT
#     now()
#     ,td.*
#     ,concat( round( ye. 员工当天妥投率*100,2),'%')  AS 员工当天妥投率
#     ,concat( round( ye.`员工昨日妥投率`*100,2),'%') AS 员工昨日妥投率
#     ,concat( round( ye.`员工前日妥投率`*100,2),'%') AS 员工前日妥投率
#     ,concat( round( yp.`网点当天妥投率`*100,2),'%') AS 网点当天妥投率
#     ,concat( round( yp.`网点昨日妥投率`*100,2),'%') AS 网点昨日妥投率
#     ,concat( round( yp.`网点前日妥投率`*100,2),'%') AS 网点前日妥投率
    td.date
    ,td.员工工号
    ,td.交接量
    ,td.妥投包裹量
    ,td.揽收量
    ,td.揽收任务量
    ,td.妥投时长
    ,yp.shl_delivery_par_cnt 当日网点应派
    ,date_format(td.妥投开始时间, '%Y-%m-%d %H:%i:%s')  当日首次妥投时间
    ,round(timestampdiff(second, td.上班打卡时间, td.下班打卡时间)/3600, 2) 当日打卡时长
    ,'xx'violation_criteria
FROM
    (
        select
            yg.`stat_date`  date
            ,yg.`staff_info_id` 员工工号
            ,yg.`staff_name` 员工姓名
            ,yg.`hire_days` 在职天数
            ,if(yg.`wait_leave_state` =0,'否'，'是')  是否待离职
            ,jt.`name`   岗位
            ,yg.`store_name`  网点名称
            ,yg.`region_name`  大区
            ,yg.`piece_name` 片区
            ,case
                when yg.`staff_attr` =1 then '自有'
                WHEN yg.`staff_attr` =2 then '支援'
                WHEN yg.`staff_attr` =3  then '外协'
            end as  员工类型
            ,if(yg.`is_sub_staff`=0,'否','是')  是否支援
            ,yg.`supply_store_name` 支援网点名称
            ,yg.`master_staff_info_id`  主账号
            ,yg.`master_store_name` 主账号网点
            ,smp.`name` 主账号片区
            ,smr.`name` 主账号大区
            ,ss.`name`  打卡网点名称
            ,yg.`started_store_id`
            ,yg.`attendance_started_at` 上班打卡时间
            ,yg.`attendance_end_at` 下班打卡时间
            ,tp.pickup_count  揽收任务量
            ,yg.`pickup_par_cnt` 揽收量
            ,yg.`pickup_big_par_cnt` 揽收大件量
            ,yg.`pickup_sma_par_cnt` 揽收小件量
            ,yg.`handover_par_cnt` 交接量
            ,yg.`handover_big_par_cnt` 交接大件量
            ,yg.`handover_sma_par_cnt` 交接小件量
            ,yg.`handover_cod_par_cnt` 交接cod包裹量
            ,yg.`handover_start_at` 交接开始时间
            ,yg.`handover_hour` 交接时长
            ,yg.`delivery_par_cnt` 妥投包裹量
            ,yg.`delivery_big_par_cnt`  妥投大件量
            ,yg.`delivery_sma_par_cnt` 妥投小件量
            ,yg.`delivery_cod_par_cnt` 妥投cod包裹量
            ,yg.`delivery_start_at`    妥投开始时间
            ,yg.`delivery_end_at2`     妥投结束时间
            ,yg.`delivery_hour2`       妥投时长
            ,yg.coordinate_distance    派送里程
            ,yg.`delivery_staff_cnt`   网点当天派件人数
            ,yg.`rank_delivery_in_store`  在网点派件排名
            ,yg.`mark_par_cnt`   当日派件标记数量
            ,yg.`mark_ret_par_cnt` 当日标记拒收包裹数量
            ,yg.`mark_mdf_par_cnt` 当日改约包裹数量
            ,yg.`mark_par_unen_cnt` 当日运力不足标记数量
            ,yg.`mark_par_uncon_cnt` 当日标记无人接听标记数量

        from dwm.dws_my_staff_wide_s yg
        LEFT JOIN
            (
                SELECT
                    tp.`staff_info_id`
                    ,COUNT(tp.`id`) pickup_count
                from `my_staging`.`ticket_pickup` tp
                where
                    tp.`created_at` >=convert_tz(current_date,'+08:00','+00:00')
                    and tp.`transfered` =0
                    and tp.`state` in (1,2)
                GROUP BY 1
            ) tp on tp.`staff_info_id` =yg.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` ss on ss.`id` =yg.`started_store_id`
        LEFT JOIN `my_staging`.`staff_info_job_title` jt on jt.id=yg.`job_title`
        LEFT JOIN `my_staging`.`sys_store` ss1 on ss1.`id` =yg.`master_store_id`
        LEFT JOIN `my_staging`.`sys_manage_region`  smr on smr.`id` =ss1.`manage_region`
        LEFT JOIN  `my_staging`.`sys_manage_piece`  smp on smp.`id` =ss1.`manage_piece`
        WHERE
            yg.`stat_date` = CURRENT_DATE
            and yg.`delivery_par_cnt` <80
            and (yg.`hire_days` >7 or yg.`staff_attr` in (2,3))
            and yg.`delivery_hour` <5
            and yg.`coordinate_distance` < 100
            and yg.`delivery_cod_par_cnt`< 60
            and tp.pickup_count < 10
    )td
LEFT JOIN
    (
        select stat_date
            ,staff_info_id
            ,delivery_par_cnt/handover_par_cnt as 员工当天妥投率
            ,lag1_delivery_par_cnt/lag1_handover_par_cnt as 员工昨日妥投率
            ,lag2_delivery_par_cnt/lag2_handover_par_cnt as 员工前日妥投率
        from
            (
                select
                    stat_date
                    ,staff_info_id
                    ,delivery_par_cnt
                    ,handover_par_cnt
                    ,lag(delivery_par_cnt,1) over(partition by staff_info_id order by stat_date) as lag1_delivery_par_cnt
                    ,lag(delivery_par_cnt,2) over(partition by staff_info_id order by stat_date) as lag2_delivery_par_cnt
                    ,lag(handover_par_cnt,1) over(partition by staff_info_id order by stat_date) as lag1_handover_par_cnt
                    ,lag(handover_par_cnt,2) over(partition by staff_info_id order by stat_date) as lag2_handover_par_cnt
                from  dwm.dws_my_staff_wide_s yg
                WHERE
                    yg.`stat_date`>=date_sub(CURRENT_DATE, INTERVAL 3 DAY)
             )base
        where
            stat_date=date_sub(CURRENT_DATE, INTERVAL 0 DAY)
            and  coalesce(delivery_par_cnt/handover_par_cnt,0)+coalesce(lag1_delivery_par_cnt/lag1_handover_par_cnt,0)+coalesce(lag2_delivery_par_cnt/lag2_handover_par_cnt,0)<2.7
    )ye on ye.staff_info_id=td.员工工号
join
    (
        select stat_date
            ,store_id
            ,store_name
            ,shl_delivery_par_cnt
            ,shl_delivery_delivery_par_cnt/shl_delivery_par_cnt as 网点当天妥投率
            ,shl1_delivery_delivery_par_cnt/shl1_delivery_par_cnt as 网点昨日妥投率
            ,shl2_delivery_delivery_par_cnt/shl2_delivery_par_cnt as 网点前日妥投率
        from
            (
                select
                    `stat_date`
                    ,`store_id`
                    ,`store_name`
                    ,`shl_delivery_delivery_par_cnt`
                    ,`shl_delivery_par_cnt`
                    ,lag(shl_delivery_delivery_par_cnt,1) over(partition by store_id order by stat_date) as shl1_delivery_delivery_par_cnt
                    ,lag(shl_delivery_delivery_par_cnt,2) over(partition by store_id order by stat_date) as shl2_delivery_delivery_par_cnt
                    ,lag(shl_delivery_par_cnt,1) over(partition by store_id  order by stat_date) as shl1_delivery_par_cnt
                    ,lag(shl_delivery_par_cnt,2) over(partition by store_id  order by stat_date) as shl2_delivery_par_cnt
                from  dwm.dws_my_store_should_delivery_s yp
                WHERE
                    yp.`stat_date`>=date_sub(CURRENT_DATE, INTERVAL 3 DAY)
            )base
            where
                stat_date=date_sub(CURRENT_DATE, INTERVAL 0 DAY)
                and  coalesce(shl_delivery_delivery_par_cnt/shl_delivery_par_cnt,0) +coalesce(shl1_delivery_delivery_par_cnt/shl1_delivery_par_cnt,0) +coalesce(shl2_delivery_delivery_par_cnt/shl2_delivery_par_cnt,0)<2.55
     ) yp on yp.`store_id`  =td.`started_store_id`
;


-- 出勤不达标

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
                        ad.stat_date < curdate()

                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 2
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
    ,st.late_time_sum/60 迟到时长_hour
from
    (
        select
            a.staff_info_id
            ,a.stat_date
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
        group by 1,2
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    st.late_num >= 3
    and st.late_time_sum >= 300
;


select
    ad.staff_info_id
    ,ad.stat_date
    ,concat(date_format(ad.stat_date, '%d/%m/%Y'),'[', ad.shift_start, '-', ad.shift_end, ']', date_format(ad.attendance_started_at, '%H:%i'), ' Lewat ', timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), ' minit' ) late_detail
    ,timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at)  late_minutes
from my_bi.attendance_data_v2 ad
join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
where
    ad.stat_date = curdate()
    and ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB > 0
    and ad.AB > 0
    and ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute )

;


select
    ad.staff_info_id
    ,group_concat(ad.stat_date) absence_date
from my_bi.attendance_data_v2 ad
join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
where
    ad.stat_date <= date_sub(curdate(), interval 3 day)
    and ad.stat_date >= date_sub(curdate(), interval 7 day)
    and ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB > 0
    and ad.attendance_end_at  is null
    and ad.attendance_started_at is null
    and ad.sys_store_id != -1
group by 1

;