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
          ,fn.father_staff_info_id
          ,fn.is_sub_staff
          ,fn.staff_name
          ,fn.finished_at
          ,fn.hire_days
          ,fn.pi_state
          ,fn.job_title
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
                ,pr.father_staff_info_id
                ,pi.state pi_state
                ,hsi.job_title
                ,datediff(curdate(), hsi2.hire_date) as hire_days
                ,pr.is_sub_staff
                ,convert_tz(pi.updated_at,'+00:00','+07:00') as pi_updated_at
                ,if(pi.returned=1,'退件','正向件') as pno_type
                ,convert_tz(pi.finished_at,'+00:00','+07:00') as finished_at
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
                                ,ifnull(sd.staff_info_id,pr.staff_info_id) as father_staff_info_id
                                ,hsi.name as staff_name
                                ,pr.store_id
                                ,if(sd.staff_info_id is not null,'Y','N') as is_sub_staff
                                ,row_number() over(partition by pr.pno order by convert_tz(pr.created_at,'+00:00','+07:00') desc) as rnk
                            from fle_staging.ticket_delivery pr
                            left join bi_pro.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                            left join backyard_pro.hr_staff_apply_support_store sd on hsi.staff_info_id=sd.sub_staff_info_id and sd.support_status<4 and sd.sub_staff_info_id>0 #根据子账号找主账号
                            where
                                pr.created_at >= date_sub(curdate(), interval 7 hour)
                                and pr.created_at < date_add(curdate(), interval 10 hour)
                                and hsi.job_title in(13,110,452,1497)
                                and hsi.formal=1
                        ) pr
                        where  pr.rnk=1
                ) pr
                join bi_pro.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                left join bi_pro.hr_staff_info hsi2 on pr.father_staff_info_id=hsi2.staff_info_id
                join dwm.dim_th_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = curdate() and dp.store_category in (1,10)
                left join fle_staging.parcel_info pi on pr.pno = pi.pno
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
                                    ,convert_tz(pr.routed_at,'+00:00','+07:00')  as call_datetime
                             from rot_pro.parcel_route pr
                             where
                                pr.routed_at >= date_sub(curdate(), interval 7 hour)
                                and pr.routed_at < date_add(curdate(), interval 10 hour)
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
        ,fn.store_category
        ,fn.store_name
        ,fn.piece_name
        ,fn.region_name
        ,fn.staff_info_id
        ,fn.staff_name
        ,fn.finished_at
        ,fn.pi_state
    from
        (
            select
                    pr.pno
                    ,pr.store_id
                    ,dp.store_category
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,pr.staff_info_id
                    ,pi.state pi_state
                    ,convert_tz(pi.updated_at,'+00:00','+07:00') as pi_updated_at
                    ,if(pi.returned=1,'退件','正向件') as pno_type
                    ,convert_tz(pi.finished_at,'+00:00','+07:00') as finished_at
                ,pr.staff_name
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
                                    ,row_number() over(partition by pr.pno order by convert_tz(pr.created_at,'+00:00','+07:00') desc) as rnk
                                from fle_staging.`ticket_delivery`  pr
                                left join bi_pro.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                                left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
                                where
                                    pr.created_at >= date_sub(curdate(), interval 7 hour)
                                    and pr.created_at < date_add(curdate(), interval 15 hour)

                                    and hsi.job_title in(13,110,452,1497)
                                    and hsi.formal=1
             						and pr.mps_delivery_category!=1 -- 非子母单 ，子母单另算
                            ) pr
                            where  pr.rnk=1
                    ) pr
                    join dwm.dim_th_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = curdate() and dp.store_category in (1,10)
                    left join fle_staging.parcel_info pi on pr.pno = pi.pno
        )fn
)


select
    a.*
from
    (

            select
            		current_date p_date
                    ,fn.网点 store
                    ,fn.大区 area
                    ,fn.片区 district
                    ,fn.员工ID staff_id
                    ,fn.快递员姓名 staff_name
                    ,fn.是否支援 support_or_not
                    ,fn.快递员类型 job_title
                    ,fn.在职时长 length_service
                    ,fn.交接量_非退件 hanover_non_refund
                    ,fn.非退件妥投量 deliveried_non_refund
                    ,fn.非退件妥投量_大件折算 deliveried_rate_non_refund_big
                    ,fn.退件妥投量_按地址转换 deliveried_refund
                    ,fn.交接包裹未拨打电话数 hanover_non_phnoe
                    ,fn.员工出勤信息 staff_attendance_info
                    ,fn.22点前快递员结束派件时间 finished_delivered_time_by22
                    ,fn.妥投率 deliveried_rate
                    ,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as a_abnormal
                    ,fn.是否出勤不达标 as b_abnormal
                    ,fn.是否低人效 as c_abnormal
                   ,if(fn.虚假行为>0,'是',null) as d_abnormal
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
                                ,t1.是否支援
                                ,datediff(curdate(), hsi2.hire_date)  在职时长
                                ,t1.快递员类型
                                ,ifnull(f2.交接量_非退件, 0)+ifnull(ff2.ct, 0) 交接量_非退件
                                ,ifnull(f6.非退件妥投量, 0) 非退件妥投量
                                ,ifnull(f6.退件妥投量_按地址转换, 0) 退件妥投量_按地址转换
                                ,ifnull(f6.非退件妥投量_大件折算, 0 ) 非退件妥投量_大件折算
                                ,ifnull(f1.交接包裹未拨打电话数, 0) 交接包裹未拨打电话数
                                ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到至少三次且迟到时间至少5小时'
                                     when f5.absent_days>=2  then '最近一周缺勤>=2次' else null end as 员工出勤信息
                                ,f6.finished_at as 22点前快递员结束派件时间
                                ,if((f2.交接量_非退件+ff2.ct)<>0 and f2.交接量_非退件 is not null,concat(round(f6.非退件妥投量/(f2.交接量_非退件+ff2.ct)*100,2),'%'),0) as 妥投率
                                ,ifnull(f1.交接包裹未拨打电话占比, 0) 交接包裹未拨打电话占比

                                ,f5.absent_days as 缺勤天数
                                ,f5.late_days as 迟到天数
                                ,f5.late_times as 迟到时长_分钟
                                ,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
                                ,case when f5.late_days>=3 and f5.late_times>=300 then '是' when f5.absent_days>=2  then '是' else null end as 是否出勤不达标
                                #,if(f2.交接包裹妥投量_非退件妥投/f2.交接量_非退件<0.7 and f2.交接包裹妥投量_非退件妥投<100 and ( hour(f6.finished_at)<15 or f6.finished_at is null ),'是',null) as 是否低人效
                                ,case when f2.网点类型=1 and spill.滞留件积压预警='' and (f2.交接量_非退件+ff2.ct)<>0 and f2.交接量_非退件 is not null and f6.非退件妥投量/(f2.交接量_非退件+ff2.ct)<0.9 and ((ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<90 ) then '是'
                                    when f2.网点类型=1 and spill.滞留件积压预警='Alert' and (f2.交接量_非退件+ff2.ct)<>0 and f2.交接量_非退件 is not null and f6.非退件妥投量/(f2.交接量_非退件+ff2.ct)<0.7 and ((ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<90 ) then '是'
                                    when f2.网点类型=10 and spill.滞留件积压预警='' and (f2.交接量_非退件+ff2.ct)<>0 and f2.交接量_非退件 is not null and f6.非退件妥投量/(f2.交接量_非退件+ff2.ct)<0.9 and ((ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<70 ) then '是'
                                    when f2.网点类型=10 and spill.滞留件积压预警 ='Alert' and (f2.交接量_非退件+ff2.ct)<>0 and f2.交接量_非退件 is not null and f6.非退件妥投量/(f2.交接量_非退件+ff2.ct)<0.7 and ((ifnull(f6.非退件妥投量_大件折算,0)+ifnull(f6.退件妥投量_按地址转换,0))<70) then '是'
                                else null end as 是否低人效
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
                                        ,case when hsi.job_title=13 then 'bike' when hsi.job_title=110 then 'van' when hsi.job_title=452 then 'boat' when hsi.job_title=1497 then 'Van Feeder'  else '' end as 快递员类型
                                        ,ifnull(sd.staff_info_id,hsi.staff_info_id) as father_staff_info_id
                                        #,datediff(curdate(), hsi.hire_date)  在职时长
                                    from backyard_pro.staff_work_attendance swa
                                    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = swa.staff_info_id
                                    left join dwm.dim_th_sys_store_rd dt on dt.store_id = swa.organization_id and dt.stat_date = curdate()
                                    left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
                                    left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
                                    left join backyard_pro.hr_staff_apply_support_store sd on hsi.staff_info_id=sd.sub_staff_info_id and sd.support_status<4 and sd.sub_staff_info_id>0 #根据子账号找主账号

                                    where
                                        swa.attendance_date = curdate()
                                        and (swa.started_at is not null or swa.end_at is not null)
                                        and ss.category in (1,10)
                                        and hsi.job_title in (13,110,452,1497)
                                ) t1
                           	left join bi_pro.hr_staff_info hsi2 on t1.father_staff_info_id=hsi2.staff_info_id
                            left join
                                (# 快递员交接包裹后拨打电话情况
                                    select
                                        fn.region_name as 大区
                                        ,fn.piece_name as 片区
                                        ,fn.store_name as 网点
                                        ,fn.store_id
                                        ,fn.staff_info_id as 员工ID
                                        ,fn.staff_name as 快递员姓名
                                        ,fn.is_sub_staff as 是否支援
                                        ,fn.hire_days as 在职时长
                                        ,case when fn.job_title=13 then 'bike' when fn.job_title=110 then 'van' when fn.job_title=452 then 'boat' when fn.job_title=1497 then 'Van Feeder'  else '' end as 快递员类型
                                        ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,9) and  (fn.finished_at> date_add(curdate(), interval 10 hour) or fn.finished_at is null) then fn.pno else null end) as 交接包裹未拨打电话数
                                        ,if(count(distinct fn.pno)<>0,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,9) and  (fn.finished_at> date_add(curdate(), interval 10 hour) or fn.finished_at is null) then fn.pno else null end)/count(distinct fn.pno),0) as 交接包裹未拨打电话占比
                                    from  handover fn
                                    group by 1,2,3,4,5,6,7,8
                                )f1 on f1.员工ID = t1.员工ID
                            left join
                                    (
                                        select
                                            fn.staff_info_id as 员工ID
                                            ,fn.staff_name as 快递员姓名
                                            ,fn.store_category as 网点类型
                                            ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
                                        from  handover2 fn
                                        group by 1,2,3
                                    )f2 on f2.员工ID = t1.员工ID
                            left join
	                            (
	                            	select
	                            		ff.staff_info_id
	                                    ,ff.store_id
	                                    ,sum(ff.mps_count) ct
	                            	from
	                            	(
		                            	select
		                            		pr.pno
		                            		,pr.staff_info_id
		                                    ,pr.store_id
											,pim.mps_count
		                            	from fle_staging.`ticket_delivery`  pr
		                                left join bi_pro.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                                left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
		                                left join fle_staging.parcel_info_mps_relation pim on pim.mother_pno =pr.pno -- 子母单关联
		                                left join fle_staging.parcel_info pi on pr.pno=pi.pno
		                                where
		                                    pr.created_at >= date_sub(curdate(), interval 7 hour)
		                                    and pr.created_at < date_add(curdate(), interval 15 hour)
		                                    and hsi.job_title in(13,110,452,1497)
		                                    and hsi.formal=1
		             						and pr.mps_delivery_category=1
		             					#	and pr.pno='TH01124THEGB0A'
		             						and pi.returned=0 -- 非退件
		             					group by 1,2,3
	             					)ff
	             					group by 1,2
	                            )ff2 on ff2.staff_info_id=f2.员工ID
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
                                    from bi_pro.attendance_data_v2 ad
                                    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
                                        and ad.stat_date>date_sub(current_date,interval 8 day)
                                        and ad.stat_date<=date_sub(current_date,interval 1 day)
                                    group by 1
                                ) f5 on f5.staff_info_id = t1.员工ID
                            left join
                                ( -- 22点前最后一个妥投包裹时间
                                    select
                                        pi.ticket_delivery_staff_info_id
                                        ,max(convert_tz(pi.finished_at,'+00:00','+07:00')) as finished_at
                                        ,count(case when pimr.id is null and pi.returned=0 and hour(convert_tz(pi.finished_at,'+00:00','+07:00'))<22 then pi.pno else null end) as 非退件妥投量
                                        ,count(distinct case when pi.returned=1 and hour(convert_tz(pi.finished_at,'+00:00','+07:00'))<22 then pi.dst_detail_address else null end) as 退件妥投量_按地址转换
                                        #,if(floor(pi.weight/10000)=0,1,floor(pi.weight/10000)) as weight # 每10kg为一个系数同时向下取整,小于10kg为1
                                        #,(pi.width+pi.height+pi.length)
                                        #,((pi.width+pi.height+pi.length) DIV 5)*5-5 #三边之和以5为单位向下取整
                                        #,if(floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1<1,1,floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1) as sum_trilateral #三边之和以5为单位向下取整，每50cm为一个系数同时向下取整，小于150cm为1
                                        ,sum(case when if(floor(pi.weight/10000)=0,1,floor(pi.weight/10000))<if(floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1<1,1,floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1)
                                                    then if(floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1<1,1,floor((((pi.width+pi.height+pi.length) DIV 5)*5-5)/50)-1) else if(floor(pi.weight/10000)=0,1,floor(pi.weight/10000)) end) as 非退件妥投量_大件折算
                                    from fle_staging.parcel_info pi
                                    left join fle_staging.parcel_info_mps_relation pimr on pimr.mother_pno =pi.pno
                                    where
                                        pi.state=5
                                        and pi.finished_at>=date_sub(curdate(), interval 7 hour)
                                        and pi.finished_at<date_add(curdate(), interval 15 hour)
                                    group by 1
                                 ) f6 on f6.ticket_delivery_staff_info_id = t1.员工ID
                            left join dwm.dwd_th_network_spill_detl_rd spill on f1.网点=spill.网点名称 and spill.统计日期=date_sub(curdate(),interval 1 day)
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
                                    #     ,count(distinct if(vrv.visit_result in (23,24), vrv.link_id, null)) 虚假改约量
                                        ,count(distinct if(vrv.visit_result in (37,39,3), vrv.link_id, null)) 揽件虚假量
                                    #     ,count(distinct if(vrv.visit_result in (39), vrv.link_id, null)) 虚假未准备好标记量
                                    #     ,count(distinct if(vrv.visit_result in (3), vrv.link_id, null)) 虚假取消揽件任务
                                    from nl_production.violation_return_visit vrv
                                    where
                                        vrv.visit_state = 4
                                        and vrv.updated_at >= date_sub(curdate(), interval 7 hour)
                                        and vrv.updated_at < date_add(curdate(), interval 17 hour) -- 昨天
                                        and vrv.visit_staff_id not in (10000,10001) -- 非ivr回访
                                        and vrv.type in (1,2,3,4,5,6)
                                    group by 1

                                    union all

                                    select
                                        acca.staff_info_id
                                        ,'投诉' type
                                        ,count(distinct if(acca.complaints_type = 2, acca.merge_column, null)) 揽件虚假量
                                        ,count(distinct if(acca.complaints_type = 1, acca.merge_column, null)) 妥投虚假量
                                        ,count(distinct if(acca.complaints_type = 3, acca.merge_column, null)) 派件标记虚假量
                                    from nl_production.abnormal_customer_complaint_authentic acca
                                    where
                                        acca.callback_state = 2
                                        and acca.qaqc_callback_result in (2,3)
                                        and acca.qaqc_callback_at >= date_sub(curdate(), interval 7 hour)
                                        and acca.qaqc_callback_at < date_add(curdate(), interval 17 hour) -- 昨天
                                        and acca.type = 1
                                        and acca.complaints_type in (1,2,3)
                                    group by 1
                                ) a
                            group by 1
                        )fg on fk.员工ID=fg.staff_info_id
                )fn
    ) a
where
    a.a_abnormal is not null
    or a.b_abnormal is not null
    or a.c_abnormal is not null
    or a.d_abnormal is not null
order by a.store