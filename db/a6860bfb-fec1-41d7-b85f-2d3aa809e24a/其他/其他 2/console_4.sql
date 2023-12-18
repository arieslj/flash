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
		                        from ph_staging.parcel_route pr
		                        left join ph_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
		                        left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
		                        where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
		                            and hsi.job_title in(13,110,1000)
		                            and hsi.formal=1
		                    ) pr
		                    where  pr.rnk = 1
		            ) pr
		            join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
		            left join ph_staging.parcel_info pi on pr.pno = pi.pno
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
		                         from ph_staging.parcel_route pr
		                         where
		                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
		                            and pr.routed_at < date_add(curdate(), interval 9 hour)
		                            and pr.route_action in ('PHONE')
		                    )pr
		                group by 1
		            )pr2 on pr.pno = pr2.pno
	        )fn
    )

select
    f1.网点
    ,f1.大区
    ,f1.片区
    ,f1.负责人
    ,f1.员工ID
    ,f1.快递员姓名
	,f1.交接量_非退件
	,f1.交接包裹妥投量_非退件妥投
    ,f1.交接包裹妥投量_退件妥投
    ,f1.交接包裹未拨打电话数
    ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到三次且迟到时间5小时'
         when f5.absent_days>=2  then '最近一周缺勤2次' else null end as 员工出勤信息
    ,f6.finished_at as 18点前快递员结束派件时间
    ,concat(round(f1.交接包裹妥投量_非退件妥投/f1.交接量_非退件*100,2),'%') as 妥投率
    ,f1.交接包裹未拨打电话占比
    ,f5.absent_days as 缺勤天数
    ,f5.late_days as 迟到天数
    ,f5.late_times as 迟到时长_分钟
from
	(# 快递员交接包裹后拨打电话情况
	    select
		    fn.region_name as 大区
		    ,case
			    when fn.region_name in ('Area3', 'Area6') then '彭万松'
			    when fn.region_name in ('Area4', 'Area9') then '韩钥'
			    when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
			    when fn.region_name in ( 'Area8') then '黄勇'
			    when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
				end 负责人
		    ,fn.piece_name as 片区
		    ,fn.store_name as 网点
			,fn.store_id
		    ,fn.staff_info_id as 员工ID
	        ,fn.staff_name as 快递员姓名
	        ,count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end) as 交接包裹未拨打电话数
	        ,concat(round(count(distinct case when  fn.before_17_calltimes is null then fn.pno else null end)/count(distinct fn.pno)*100,2),'%') as 交接包裹未拨打电话占比
	        ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
		    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='正向件' ,fn.pno ,null)) 交接包裹妥投量_非退件妥投
		    ,count(distinct if(fn.pi_state = 5 and fn.pno_type='退件' ,fn.pno ,null)) 交接包裹妥投量_退件妥投
	    from  handover fn
	    group by 1,2,3,4,5,6,7
	)f1
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
	    from ph_bi.attendance_data_v2 ad
	    where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
	        and ad.stat_date>date_sub(current_date,interval 8 day)
	        and ad.stat_date<=date_sub(current_date,interval 1 day)
	    group by 1
	) f5 on f5.staff_info_id = f1.员工ID
left join
	( -- 18点前最后一个妥投包裹时间
        select
             ha.ticket_delivery_staff_info_id
	        ,ha.finished_at
        from
        (
            select
                pi.ticket_delivery_staff_info_id
                ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                ,row_number() over (partition by pi.ticket_delivery_staff_info_id order by pi.finished_at desc) as rk
	        from ph_staging.parcel_info pi
	        where pi.state=5
	        and pi.finished_at>= date_sub(curdate(), interval 8 hour)
		    and pi.finished_at< date_add(curdate(), interval 10 hour)
        )ha
        where ha.rk=1
	) f6 on f6.ticket_delivery_staff_info_id = f1.员工ID