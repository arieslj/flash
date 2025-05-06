with handover as
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
            ,fn.formal
            ,fn.before_17_calltimes
            ,fn.diff_day
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
                   ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                   ,if(pi.returned=1,'退件','正向件') as pno_type
                   ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                   ,pr.staff_name
                   ,pr.formal
                   ,pr.diff_day
                   ,pr2.before_17_calltimes
               from
                   ( # 所有19点前交接包裹找到最后一次交接的人
                       select
                           pr.*
                       from
                           (
                               select
                                   pr.pno
                                   ,pr.staff_info_id
                                   ,hsi.name as staff_name
                                   ,pr.store_id
                                   ,hsi.formal
                                   ,datediff(curdate(),hsi.hire_date) diff_day
                                   ,row_number() over(partition by pr.pno order by pr.created_at desc) as rnk
                               from my_staging.`ticket_delivery`  pr
                               left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                               left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                               where pr.created_at >= date_sub(curdate(), interval 8 hour)
                               and pr.created_at < date_add(curdate(), interval 11 hour)
                               and hsi.job_title in(13,110,1199)
                           ) pr
                           where  pr.rnk=1
                   ) pr
                   join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
                   left join my_staging.parcel_info pi on pr.pno = pi.pno
                   left join # 19点前拨打电话次数
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
                              where pr.routed_at >= date_sub(curdate(), interval 8 hour)
                              and pr.routed_at < date_add(curdate(), interval 11 hour)
                              and pr.route_action in ('PHONE')
                           )pr
                       group by 1
                   )pr2 on pr.pno = pr2.pno
            )fn
    ),

 handover2 as
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
            ,fn.formal
          -- ,fn.before_17_calltimes
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
                   ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                   ,if(pi.returned=1,'退件','正向件') as pno_type
                   ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                   ,pr.staff_name
                   ,pr.formal
                   -- ,pr2.before_17_calltimes
               from
                   ( # 所有22点前交接包裹找到最后一次交接的人
                       select
                           pr.*
                       from
                           (
                               select
                                   pr.pno
                                   ,pr.staff_info_id
                                   ,hsi.name as staff_name
                                   ,pr.store_id
                                   ,hsi.formal
                                   ,row_number() over(partition by pr.pno order by convert_tz(pr.created_at,'+00:00','+08:00') desc) as rnk
                               from my_staging.`ticket_delivery`  pr
                               left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                               left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                               where pr.created_at >= date_sub(curdate(), interval 8 hour)
                               and pr.created_at < date_add(curdate(), interval 14 hour)
                               and hsi.job_title in(13,110,1199)
                           ) pr
                           where  pr.rnk=1
                   ) pr
                   join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
                   left join my_staging.parcel_info pi on pr.pno = pi.pno
            )fn
    )



select
    *
from
    (

        select
                fn.网点
                ,fn.大区
                ,fn.片区
        #       ,fn.负责人
                ,fn.员工ID
                ,fn.快递员姓名
                ,fn.交接量_非退件
                ,fn.非退件妥投量
                ,fn.退件妥投量
                ,fn.交接包裹未拨打电话数 交接包裹未妥投未拨打电话数
                ,fn.员工出勤信息
                ,fn.22点前快递员结束派件时间
                ,fn.妥投率
                ,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as 违反A联系客户
                ,fn.是否出勤不达标 as 违反B出勤
                ,fn.是否低人效 as 违反C人效
                ,if(fn.虚假行为>0,'是',null) as 违反D虚假
            from
            (
                select
                    fk.*
                    ,fg.虚假行为
                    ,row_number() over (partition by fk.网点,fk.未按要求联系客户 order by fk.交接包裹未拨打电话占比 desc) as rk
                    from
                    (
                        select
                            t1.网点
                            ,t1.大区
                            ,t1.片区
        #                   ,f1.负责人
                            ,t1.员工ID
                            ,t1.快递员姓名
                            ,t1.diff_day 快递员在职时长
                            ,f2.交接量_非退件
                            ,f6.非退件妥投量
                            ,f6.退件妥投量
                            ,f1.交接包裹未拨打电话数
                            ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到至少三次且迟到时间至少5小时'
                                  when f5.absent_days>=2  then '最近一周缺勤>=2次'
                                  else null end as 员工出勤信息
                            ,f6.finished_at as 22点前快递员结束派件时间
                            ,concat(round(f6.非退件妥投量/f2.交接量_非退件*100,2),'%') as 妥投率
                            ,f1.交接包裹未拨打电话占比
                            ,f5.absent_days as 缺勤天数
                            ,f5.late_days as 迟到天数
                            ,f5.late_times as 迟到时长_分钟
                            ,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
                            ,case when f5.late_days>=3 and f5.late_times>=300 then '是'
                                  when f5.absent_days>=2  then '是'
                                  else null end as 是否出勤不达标
                            ,if((f6.非退件妥投量/f2.交接量_非退件<0.7 and f6.非退件妥投量<70) or f6.finished_at is null ,'是',null) as 是否低人效

                        from
                            (
                                    select
                                        dt.region_name 大区
                                        ,dt.piece_name 片区
                                        ,dt.store_name 网点
                                        ,dt.store_id
                                        ,swa.staff_info_id 员工ID
                                        ,hsi.name 快递员姓名
                                        ,if(hsi.is_sub_staff = 1, 'y', 'n')  是否支援
                                        ,datediff(curdate(), hsi.hire_date)  diff_day
                                    from my_backyard.staff_work_attendance swa
                                    left join my_bi.hr_staff_info hsi on hsi.staff_info_id = swa.staff_info_id
                                    left join dwm.dim_my_sys_store_rd dt on dt.store_id = swa.organization_id and dt.stat_date = date_sub(curdate(), interval 1 day)
                                    left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                                    left join my_staging.sys_store ss on ss.id = hsi.sys_store_id
                                    where
                                        swa.attendance_date = curdate()
                                        and (swa.started_at is not null or swa.end_at is not null)
                                        and ss.category in (1,10)
                                        and hsi.job_title in (13,110,1199)
                                ) t1
                        left join
                            (# 快递员交接包裹后拨打电话情况
                                select
                                    fn.region_name as 大区
        #                      ,case
        #                         when fn.region_name in ('Area3', 'Area6') then '彭万松'
        #                         when fn.region_name in ('Area4', 'Area9') then '韩钥'
        #                         when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
        #                         when fn.region_name in ( 'Area8') then '黄勇'
        #                         when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
        #                         end 负责人
                                    ,fn.piece_name as 片区
                                    ,fn.store_name as 网点
                                    ,fn.store_id
                                    ,fn.staff_info_id as 员工ID
                                    ,fn.staff_name as 快递员姓名
                                    ,fn.diff_day
                                    ,count(distinct case when  fn.before_17_calltimes is null  and fn.pi_state not in(5,9) and  (fn.finished_at> date_add(curdate(), interval 11 hour) or fn.finished_at is null)  then fn.pno else null end) as 交接包裹未拨打电话数
                                    ,count(distinct case when  fn.before_17_calltimes is null  and fn.pi_state not in(5,9) and  (fn.finished_at> date_add(curdate(), interval 11 hour) or fn.finished_at is null)  then fn.pno else null end)/count(distinct fn.pno) as 交接包裹未拨打电话占比
                                from  handover fn
                                where fn.formal=1
                                group by 1,2,3,4,5,6
                            )f1 on f1.员工ID = t1.员工ID
                        left join
                          ( -- 22点前
                              select
                                  fn.staff_info_id as 员工ID
                                  ,fn.staff_name as 快递员姓名
                                  ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
                              from  handover2 fn
                              group by 1,2
                          )f2 on f2.员工ID = t1.员工ID
                        left join
                            ( -- 最近一周出勤
                                select
                                    ad.staff_info_id
                                    ,sum(case
                                        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
                                        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
                                        when ad.leave_type is not null and ad.leave_time_type=3 then 1
                                        else 0  end) as leave_num
                                    ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
                                    ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
                                    ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
                                from my_bi.attendance_data_v2 ad
                                where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
                                and ad.stat_date>date_sub(current_date,interval 8 day)
                                and ad.stat_date<=date_sub(current_date,interval 1 day)
                                group by 1
                            ) f5 on f5.staff_info_id = t1.员工ID
                           left join
                            ( -- 22点前最后一个妥投包裹时间
                                select
                                       pi.ticket_delivery_staff_info_id
                                       ,max(convert_tz(pi.finished_at,'+00:00','+08:00')) as finished_at
                                       ,count(distinct case when pi.returned=0 and hour(convert_tz(pi.finished_at,'+00:00','+08:00'))<22 then pi.pno else null end) as 非退件妥投量
                                       ,count(distinct case when pi.returned=1 and hour(convert_tz(pi.finished_at,'+00:00','+08:00'))<22 then pi.pno else null end) as 退件妥投量
                                   from my_staging.parcel_info pi
                                   where pi.state=5
                                   and pi.finished_at>=date_sub(curdate(), interval 8 hour)
                                   and pi.finished_at<date_add(curdate(), interval 14 hour)
                                   group by 1
                            ) f6 on f6.ticket_delivery_staff_info_id = t1.员工ID
                    )fk
                left join
                (
                select
                    a.staff_info_id
                    ,sum(a.揽件虚假量) 虚假揽件量
                    ,sum(a.妥投虚假量) 虚假妥投量
                    ,sum(a.派件标记虚假量) 虚假派件标记量
                   ,sum(a.揽件虚假量)+sum(a.妥投虚假量)+sum(a.派件标记虚假量) as 虚假行为
                from
                    (
                        select
                        #     case vrv.type
                        #         when 1 then '揽件任务异常取消'
                        #         when 2 then '虚假妥投'
                        #         when 3 then '收件人拒收'
                        #         when 4 then '标记客户改约时间'
                        #         when 5 then 'KA现场不揽收'
                        #         when 6 then '包裹未准备好'
                        #         when 7 then '上报错分未妥投'
                        #         when 8 then '多次尝试派送失败'
                        #     end 回访类型
                            vrv.staff_info_id
                            ,'回访' type
                            ,count(distinct if(vrv.visit_result  in (6), vrv.link_id, null)) 妥投虚假量
                            ,count(distinct if(vrv.visit_result in (18,8,19,20,21,31,32,22,23,24), vrv.link_id, null)) 派件标记虚假量
                        #   ,count(distinct if(vrv.visit_result in (23,24), vrv.link_id, null)) 虚假改约量
                            ,count(distinct if(vrv.visit_result in (37,39,3), vrv.link_id, null)) 揽件虚假量
                        #   ,count(distinct if(vrv.visit_result in (39), vrv.link_id, null)) 虚假未准备好标记量
                        #   ,count(distinct if(vrv.visit_result in (3), vrv.link_id, null)) 虚假取消揽件任务
                        from my_nl.violation_return_visit vrv
                        where vrv.visit_state = 4
                        and vrv.updated_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
                        and vrv.updated_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour) -- 昨天
                        and vrv.visit_staff_id not in (10000,10001) -- 非ivr回访
                        and vrv.type in (1,2,3,4,5,6)
                        group by 1

                        union all

                        select
                            am.staff_info_id
                            ,'投诉' type
                            ,count(distinct if(acc.complaints_type = 2, acc.id, null)) 揽件虚假量
                            ,count(distinct if(acc.complaints_type = 1, acc.id, null)) 妥投虚假量
                            ,count(distinct if(acc.complaints_type = 3, acc.id, null)) 派件标记虚假量
                        from my_bi.abnormal_customer_complaint acc
                        left join my_bi.abnormal_message am on am.id = acc.abnormal_message_id
                        where acc.state = 1
                        and acc.updated_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
                        and acc.updated_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour) -- 昨天
                        and acc.complaints_type in (1,2,3)
                        and acc.qaqc_callback_result in (3,4,5,6) -- 真实投诉
                        group by 1
                    ) a
                group by 1
                having sum(a.揽件虚假量)+sum(a.妥投虚假量)+sum(a.派件标记虚假量) >0
                )fg on fk.员工ID=fg.staff_info_id
            )fn

    ) a
where
    a.违反A联系客户 is not null
    or a.违反B出勤 is not null
    or a.违反C人效 is not null
    or a.违反D虚假 is not null
