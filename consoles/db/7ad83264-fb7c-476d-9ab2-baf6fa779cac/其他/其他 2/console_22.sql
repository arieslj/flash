with support as
    (# 系统申请支援---1BY申请支援+2HCM批量导入支援'
	    select
		    hsa.store_id
		    ,hsa.store_name
		    ,hsa.staff_info_id
		    ,hsa.staff_store_id
		    ,hsa.job_title_id
		    ,hsa.employment_begin_date
		    ,hsa.employment_end_date
		    ,hsa.actual_begin_date
			,hsa.actual_end_date
			,hsa.shift_start
	        ,swa.started_at
			,hsa.shift_end
	        ,hsa.data_source
		from ph_backyard.hr_staff_apply_support_store hsa
		join  ph_backyard.staff_work_attendance swa on hsa.staff_info_id = swa.staff_info_id and swa.attendance_date =current_date
		join ph_bi.hr_staff_info hsi on hsi.staff_info_id =hsa.staff_info_id
		where
		    hsa.actual_begin_date <=current_date
		    and coalesce(hsa.actual_end_date, curdate())>= current_date
			and hsi.formal=1
		    and hsa.employment_end_date>=current_date
	        and hsa.status = 2
			and (swa.started_at is not null or swa.end_at is not null)
    )





, total as
(
    select
        a.*
    from
        (
            select
                a1.dst_store_id
                ,a1.pno
                ,a1.third_sorting_code
                ,td.created_at td_time
                ,td.staff_info_id
                ,pi.state
                ,pi.finished_at
                ,pi.ticket_delivery_staff_info_id
                ,row_number() over (partition by td.pno order by td.created_at desc ) rn
            from
                (
                    select
                        a.*
                    from
                        (
                            select
                                ds.pno
                                ,ds.dst_store_id
                                ,ps.third_sorting_code
                                ,row_number() over (partition by ps.pno order by ps.created_at desc ) rk
                            from dwm.dwd_ph_dc_should_be_delivery ds
                            join ph_drds.parcel_sorting_code_info ps on ds.pno =  ps.pno and ds.dst_store_id = ps.dst_store_id
                        ) a
                    where
                        a.rk = 1
                ) a1
            join ph_staging.ticket_delivery td on td.pno = a1.pno and td.created_at >=  date_sub(current_date, interval 8 hour) and td.created_at < date_add(current_date, interval 16 hour)
            left join ph_staging.parcel_info pi on pi.pno = a1.pno
        ) a
    where
        a.rn = 1
)



select
        f1.大区
        ,f1.片区
		,f1.网点
        ,f1.支援网点负责人 as 负责人
		,f2.当日应派
        ,f2.当日妥投
        ,f2.未妥投大件数量
        ,f2.自有快递员人数
        ,f2.支援人数
        ,f2.自有仓管
        ,f2.支援仓管
        ,f2.分拣扫描率
        ,f2.自有人效
        ,f2.支援人效
        ,f1.原大区 as 大区
        ,f1.原片区 as 片区
		,f1.原网点 as 网点
        ,f1.原网点负责人 as 负责人
		,f1.参与支援人ID
		,f1.快递员类型
		,f1.上班时间
		,f1.下班时间
     	,f1.揽收量
		,f1.交接量
		,f1.妥投量
		,f1.派送时长
		,f1.交接三段码数量
		,f1.妥投三段码数量
		,f1.未妥投中打电话次数为0的数量
		,f1.未妥投中打电话次数为1的数量

    from
        (
            select
			   sbd.dst_store_id
			    ,sbd.should_delivery_pno as 当日应派
				,sbd.finished_pno as 当日妥投
				,sbd.no_del_big_count as 未妥投大件数量
			    ,hsi.self_courier_count as 自有快递员人数
				,sp.support_courier_count as 支援人数
			    ,hsi.self_dco_count as 自有仓管
				,sp.support_dco_staff_count  as 支援仓管
				,a4.sort_rate as 分拣扫描率
				,a5.self_effect as 自有人效
				,a5.other_effect as 支援人效
			from
				(# 支援网点 当日支援的快递员和仓管数
			        select
			            sp.store_id
						,count(distinct case when sp.job_title_id in(13,110,1000) then sp.staff_info_id else null end) as support_courier_count
						,count(distinct case when sp.job_title_id=37 then sp.staff_info_id else null end) as support_dco_staff_count
			        from support sp
			        group by  sp.store_id
			    ) sp
			join
				(# 应派&当日妥投
			        select
						sbd.dst_store_id
			            ,count(distinct sbd.pno) as should_delivery_pno
			            ,count(distinct case when pi.finished_at is not null and pi.state=5 then pi.pno else null end) as finished_pno
						,count(distinct if(pi.state != 5 and ( pi.exhibition_weight > 5000 or pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 ), pi.pno, null)) no_del_big_count
					from dwm.dwd_ph_dc_should_be_delivery sbd
					join ph_staging.parcel_info pi on sbd.pno=pi.pno
					where sbd.should_delevry_type != '非当日应派'
					group by 1
			    )sbd on sbd.dst_store_id=sp.store_id
			left join
				(# 当日本网点出勤快递员和仓管
					select
					    hsi.sys_store_id
					    ,count(distinct if(hsi.job_title in (13,110,1000) and sup1.staff_info_id is null, hsi.staff_info_id, null)) self_courier_count
					    ,count(distinct if(hsi.job_title in (37) and sup1.staff_info_id is null, hsi.staff_info_id, null)) self_dco_count
					from ph_bi.hr_staff_info hsi
					join ph_backyard.staff_work_attendance swa on swa.staff_info_id = hsi.staff_info_id
					left join support sup1 on sup1.staff_info_id = hsi.staff_info_id
					where swa.attendance_date =current_date
					  and (swa.started_at is not null or swa.end_at is not null)
					group by 1
				)hsi on sbd.dst_store_id=hsi.sys_store_id
			left join
				(# 本网点员工应分拣扫描和实际分拣扫描量
				    select
				        ds.dst_store_id
				        ,count(distinct ds.pno) ds_count
				        ,count(distinct if(pr.pno is not null , ds.pno, null)) sort_count
				        ,count(distinct if(pr.pno is not null , ds.pno, null))/count(distinct ds.pno) sort_rate
				    from dwm.dwd_ph_dc_should_be_delivery ds
				    left join ph_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= date_sub(current_date, interval 8 hour) and pr.routed_at < date_add(current_date, interval 16 hour)
				    group by 1
				) a4 on a4.dst_store_id = sbd.dst_store_id
			left join
			    (# 网点自有员工人效&支援员工人效
			        select
			            ds.dst_store_id
			            ,count(distinct if(hsi.staff_info_id is not null, ds.pno, null))/count(distinct if(hsi.staff_info_id is not null, pi.ticket_delivery_staff_info_id, null)) self_effect #自有员工人效
			            ,count(distinct if(s1.staff_info_id is not null, ds.pno, null))/count(distinct if(s1.staff_info_id is not null, pi.ticket_delivery_staff_info_id, null)) other_effect #支援员工人效
			        from dwm.dwd_ph_dc_should_be_delivery ds
			        join ph_staging.parcel_info pi on pi.pno = ds.pno
			        left join support s1 on s1.store_id = ds.dst_store_id and pi.ticket_delivery_staff_info_id = s1.staff_info_id
			        join ph_bi.hr_staff_info hsi1 on  s1.staff_info_id=hsi1.staff_info_id and hsi1.job_title in (13,110,1000)
			        left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.formal =1  and hsi.sys_store_id = ds.dst_store_id and hsi.job_title in (13,110,1000)
			        where
			            pi.state = 5
			            and pi.finished_at >= date_sub(current_date, interval 8 hour)
			            and pi.finished_at < date_add(current_date, interval 16 hour)
			            and pi.returned = 0
			        group by 1
			    ) a5 on a5.dst_store_id = sbd.dst_store_id
        )f2
    left join
    (
        select
			dp.store_name as 网点
			,dp.piece_name as 片区
			,dp.region_name as 大区
            ,dp1.store_name as 原网点
			,dp1.piece_name as 原片区
			,dp1.region_name as 原大区
		    ,case
			    when dp.region_name in ('Area3', 'Area6') then '彭万松'
			    when dp.region_name in ('Area4') then '韩钥'
			    when dp.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
			    when dp.region_name in ( 'Area8') then '黄勇'
			    when dp.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13', 'Area9') then '李俊'
				end 支援网点负责人
            	,case
			    when dp1.region_name in ('Area3', 'Area6') then '彭万松'
			    when dp1.region_name in ('Area4') then '韩钥'
			    when dp.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
			    when dp1.region_name in ( 'Area8') then '黄勇'
			    when dp1.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13', 'Area9') then '李俊'
				end 原网点负责人
		    ,sp.staff_info_id as 参与支援人ID
            ,sp.store_id
		    ,case when sp.job_title_id=13 then 'bike' when sp.job_title_id=110 then 'van' when sp.job_title_id=10000 then 'Tricycle'  else 'dco' end as 快递员类型
			,ad.attendance_started_at as 上班时间
			,ad.attendance_end_at as 下班时间
			,s2.scan_count 交接量
		    ,s2.del_count 妥投量
		    ,fk.pickup_pno_cn as 揽收量
		    ,timestampdiff(minute ,fir.finished_at, las.finished_at)/60 派送时长
		    ,code.scan_code_count 交接三段码数量
		    ,code.del_code_num 妥投三段码数量
		    ,pho.0_count 未妥投中打电话次数为0的数量
		    ,pho.1_count 未妥投中打电话次数为1的数量
		from support sp
		left join dwm.dim_ph_sys_store_rd dp on dp.store_id = sp.store_id and dp.stat_date =date_sub(current_date,interval 1 day) # 支援网点组织架构
		left join dwm.dim_ph_sys_store_rd dp1 on dp1.store_id = sp.staff_store_id and dp1.stat_date =date_sub(current_date,interval 1 day)# 原网点组织架构
		left join ph_bi.attendance_data_v2 ad on sp.staff_info_id=ad.staff_info_id and ad.stat_date  =current_date
		left join
		    (
		        select
		            t1.staff_info_id
		            ,count(distinct t1.pno) scan_count
		            ,count(if(t1.state = 5, t1.pno, null)) del_count
		        from total t1
		        group by 1
		    ) s2 on s2.staff_info_id =sp.staff_info_id
		left join
		    ( -- 第一次妥投时间
		        select
		            t1.*
		            ,row_number() over (partition by t1.staff_info_id order by t1.finished_at ) rk
		        from total t1
		        where
		            t1.state = 5
		    ) fir on fir.staff_info_id = sp.staff_info_id and fir.rk = 1
		left join
		    (
		        select
		            t1.*
		            ,row_number() over (partition by t1.staff_info_id order by t1.finished_at desc ) rk
		        from total t1
		        where
		            t1.state = 5
		    ) las on las.staff_info_id = sp.staff_info_id and las.rk = 2
		left join
		    (
		        select
		            t1.staff_info_id
		            ,count(distinct t1.third_sorting_code) scan_code_count
		            ,count(distinct if(t1.state = 5, t1.third_sorting_code, null)) del_code_num
		        from total t1
		        where
		            t1.third_sorting_code not in ('XX', 'YY', 'ZZ', '00', '88')
		        group by 1
		    ) code on code.staff_info_id = sp.staff_info_id
		left join
		    (
		        select
		            a.staff_info_id
		            ,count(if(a.call_times = 0, a.pno, null)) 0_count
		            ,count(if(a.call_times = 1, a.pno, null)) 1_count
		        from
		            (
		                select
		                    t.staff_info_id
		                    ,t.pno
		                    ,count(pr.pno) call_times
		                from total t
		                left join ph_staging.parcel_route pr on pr.pno = t.pno and pr.route_action = 'PHONE'  and pr.routed_at >=  date_sub(current_date, interval 8 hour) and pr.routed_at < date_add(current_date, interval 16 hour)
		                where
		                    t.state != 5
		                group by 1,2
		            ) a
		        group by 1
		    ) pho on pho.staff_info_id = sp.staff_info_id
		left join
		    ( #揽收量
		        select
		            pi.ticket_pickup_staff_info_id
		            ,count(distinct pi.pno) as pickup_pno_cn
		        from ph_staging.parcel_info pi
		        where pi.state <9
		        and pi.created_at >=  date_sub(current_date, interval 8 hour)
		        and pi.created_at < date_add(current_date, interval 16 hour)
		    ) fk on fk.ticket_pickup_staff_info_id = sp.staff_info_id
		where sp.job_title_id in(13,110,10000)
    )f1 on f1.store_id=f2.dst_store_id