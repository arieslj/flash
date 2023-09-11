-------------------- 当日车线情况
drop table test.fleet_real_detail_today;
create table test.fleet_real_detail_today as

-- 当日实际车线情况
with base as
(
	select
	al.store_id
	,al.line_1_latest_name
	,al.line_1_latest_plan_arrive_time
	,al.adjust_line_1_latest_plan_arrive_time
	,al.line_2_latest_name
	,al.line_2_latest_plan_arrive_time
	,case
        when f1.plan_arrive_time is not null and f1.adjust_real_arrive_time is not null and f1.plan_arrive_time > f1.adjust_real_arrive_time then f1.plan_arrive_time
        when f1.plan_arrive_time is not null and f1.adjust_real_arrive_time is not null and f1.plan_arrive_time <= f1.adjust_real_arrive_time then f1.adjust_real_arrive_time
        when f1.plan_arrive_time is not null  then f1.plan_arrive_time
        when f1.adjust_real_arrive_time is not null  then f1.adjust_real_arrive_time else null
	end as schedule_time #分拣扫描的参考考核时间：车考勤时间(车辆到港时间与司机签到时间取小值)与车辆计划到达时间取大值
	,f1.real_arrive_time
	,f1.real_real_arrive_time
	,f1.plan_arrive_time actual_plan_arrive_time
	,f1.sign_time
	,f1.mode_type
	,f1.proof_id

	from dwm.dwm_th_fleet_plan_arrive_time al

	left join
	(
		select
		ft.line_id
		,ft.line_name
		,ft.real_arrive_time
		,ss3.id next_store_id
		,ss3.name next_store_name
		,ft.sign_time
		,ft.plan_arrive_time
		,ft.proof_id
		#车辆到港时间与司机签到时间取小值作为车考勤时间
		,case when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time>ft.sign_time then ft.sign_time
		 when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time<ft.sign_time then ft.real_arrive_time
		 when ft.real_arrive_time is not null then ft.real_arrive_time
		 when ft.real_arrive_time is null then ft.sign_time else null end as adjust_real_arrive_time

		,case when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time<ft.sign_time then ft.real_arrive_time
		 when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time>ft.sign_time then ft.sign_time
		 when ft.real_arrive_time is not null then ft.real_arrive_time
		 when ft.real_arrive_time is null then ft.sign_time else null end as real_real_arrive_time

		,case when ft.line_mode=1 then '常规车'
		 when ft.line_mode=2 then '加班车'
		 when ft.line_mode=3 then '虚拟车线'
		 when ft.line_mode=4 then '常规车' else null end as mode_type

		from fle_staging.fleet_van_line fvl
		join fle_staging.fleet_van_line_timetable fvlt
		on fvl.id=fvlt.line_id and fvlt.deleted=0 and fvlt.order_no>=2
		join bi_pro.fleet_time ft
		on ft.line_id=fvlt.line_id and ft.next_store_id=fvlt.store_id and ft.line_mode in (1,2,4) and ft.fleet_status=1
		and ft.arrive_type in (3,5) #3:经停到达考勤;5:目的地到达考勤
		and ft.line_name not like '%RS2%' #完成
		join fle_staging.sys_store ss
		on fvl.origin_id=ss.id and ss.category in (8,12)
		join fle_staging.sys_store ss1
		on fvl.target_id=ss1.id and ss1.category in (1,10)
		join fle_staging.sys_store ss2
		on fvlt.store_id=ss2.id and ss2.category in (1,10)
		left join fle_staging.sys_store_bdc_bsp sb1
		on sb1.bsp_id=ft.next_store_id
		left join fle_staging.sys_store ss3
		on ss3.id=coalesce(sb1.bdc_id,ft.next_store_id)

		where 1=1
		and date(case when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time<ft.sign_time then ft.real_arrive_time
				when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time>ft.sign_time then ft.sign_time
				when ft.real_arrive_time is not null then ft.real_arrive_time
				when ft.real_arrive_time is null then ft.sign_time else null end)=current_date
		and fvl.deleted=0
		and fvl.mode in (1,2,4)
		and fvl.name not like '%RS2%'
		and ft.next_store_id = 'TH32010101'

		union all

		select
		fvl.id
		,fvl.name
		,dd.first_valid_routed_at as real_arrive_time
		,dd.next_store_id
		,dd.next_store_name
		,' ' as sign_time
		,concat(current_date,' ',substr(sec_to_time(mod(fvlt.estimate_end_time,1440)),4,5),':00') as plan_arrive_time
		,dd.proof_id
		,dd.first_valid_routed_at as adjust_real_arrive_time
		,dd.first_valid_routed_at as real_real_arrive_time
		,case when fvl.mode=1 then '常规车'
		 when fvl.mode=2 then '加班车'
		 when fvl.mode=3 then '虚拟车线'
		 when fvl.mode=4 then '常规车' else null end as mode_type

		from fle_staging.fleet_van_line fvl
		left join fle_staging.sys_store ss
		on fvl.origin_id=ss.id
		join fle_staging.fleet_van_line_timetable fvlt
		on fvl.id=fvlt.line_id and fvlt.deleted=0 and fvlt.order_no>=2
		join fle_staging.sys_store ss1
		on fvlt.store_id=ss1.id and ss1.category in (1,10)
		join fle_staging.fleet_van_proof fvp
		on fvlt.line_id=fvp.van_line_id and fvl.origin_id=fvp.store_id #始发
		left join fle_staging.sys_store_bdc_bsp sb2
		on sb2.bsp_id=fvlt.store_id
		join
		(
			select
			dd.proof_id
			,dd.next_store_id
			,dd.store_name
			,dd.next_store_name
			,dd.relation_no
			,date_add(pr.routed_at,interval 7 hour) first_valid_routed_at
			,row_number()over(partition by pr.store_id,dd.proof_id order by pr.routed_at) as 'rk'
			from fle_staging.fleet_van_proof_parcel_detail dd
			join rot_pro.parcel_route pr
			on pr.store_id=dd.next_store_id and pr.pno=dd.relation_no
			join dwm.dwd_dim_dict dc
			on dc.element=pr.route_action and dc.remark='valid'
			join fle_staging.parcel_info pi
			on pr.pno=pi.pno
			left join fle_staging.sys_store_bdc_bsp sb3
			on sb3.bsp_id=pi.dst_store_id
			where pr.routed_at>=convert_tz(date_sub(CURDATE(),interval 2 day),'+07:00','+00:00')
			and dd.relation_category in (1,3)
			and dd.created_at>convert_tz(date_sub(CURDATE(),interval 2 day),'+07:00','+00:00')
			and pr.store_id=coalesce(sb3.bdc_id,pi.dst_store_id)
		) dd
		on dd.proof_id=fvp.id and dd.next_store_id=coalesce(sb2.bdc_id,fvlt.store_id) and dd.rk=1

		where fvl.mode=3
		and ss.category in (8,12)
		and fvp.created_at>convert_tz(date_sub(CURDATE(),interval 1 day),'+07:00','+00:00')
		and date(dd.first_valid_routed_at)=current_date
	) f1
	on al.store_id=f1.next_store_id
)


# select
#     *
# from base
# where
#     base.store_id = 'TH32010101'
# ;

select
t.*
,t1.min_schedule_time
,t1.max_schedule_time
,t1.proof_counts
,t2.late_proof_counts
,t3.max_real_arrive_time_normal
,t3.max_real_arrive_proof_id
,t3.max_real_arrive_vol
,t4.max_actual_plan_arrive_time_innormal
,t4.max_actual_plan_arrive_innormal_proof_id
,t4.max_actual_plan_arrive_innormal_vol
,t5.max_real_arrive_time_innormal
,t5.max_real_arrive_innormal_proof_id
,t5.max_real_arrive_innormal_vol
,now() datetime

from base t -- 这张表一个网点多条记录，包含所有的实际车线信息

left join
( -- 用一派正班车的卡点时间和车辆实际到港时间比较，看有多少车，为分拣扫描的卡点时间准备
	select
	b.store_id
	,min(b.schedule_time) min_schedule_time
	,max(b.schedule_time) max_schedule_time
	,count(*) proof_counts
	from base b
	where b.real_real_arrive_time<=b.adjust_line_1_latest_plan_arrive_time
	-- schedule_time<=adjust_line_1_latest_plan_arrive_time
	group by b.store_id
) t1
on t.store_id=t1.store_id

left join
(  -- 当天常规车有多少辆车实际到达时间比计划时间晚超过20min_一派前
	select
	b.store_id
	,count(*) as late_proof_counts
	from base b
	where timestampdiff(minute,actual_plan_arrive_time,b.real_real_arrive_time)>=20 and b.mode_type='常规车'
	and b.actual_plan_arrive_time<=b.adjust_line_1_latest_plan_arrive_time
	group by b.store_id
) t2
on t.store_id=t2.store_id

left join
( -- 常规车一派前最晚实际到达时间以及车上包裹数量
	select
	t.store_id
	,t.proof_id max_real_arrive_proof_id
	,t.real_real_arrive_time as  max_real_arrive_time_normal
	,count(ppd.relation_no) max_real_arrive_vol
	from
	(
		select
		b.store_id
		,b.proof_id
		,b.real_real_arrive_time
		,row_number()over(partition by b.store_id order by b.real_real_arrive_time desc) rk
		from base b
		where b.actual_plan_arrive_time<=b.adjust_line_1_latest_plan_arrive_time and b.mode_type='常规车'
	) t
	left join fle_staging.fleet_van_proof_parcel_detail ppd
	on ppd.proof_id=t.proof_id and ppd.relation_category in (1,3) and t.store_id=ppd.next_store_id
	join fle_staging.parcel_info pi
	on pi.pno=ppd.relation_no
	left join fle_staging.sys_store_bdc_bsp sb
	on sb.bsp_id=pi.dst_store_id
	where t.rk=1
	and t.store_id=coalesce(sb.bdc_id,pi.dst_store_id)
	group by 1,2,3
) t3
on t.store_id=t3.store_id

left join
( -- 加班车一派前加班车最晚计划到达时间以及车上包裹数量
	select
	t.store_id
	,t.proof_id as max_actual_plan_arrive_innormal_proof_id
	,t.actual_plan_arrive_time as max_actual_plan_arrive_time_innormal
	,count(ppd.relation_no) as max_actual_plan_arrive_innormal_vol
	from
	(
		select
		b.store_id
		,b.proof_id
		,b.actual_plan_arrive_time
		,row_number()over(partition by b.store_id order by b.actual_plan_arrive_time desc) rk
		from base b
		where b.actual_plan_arrive_time<=b.adjust_line_1_latest_plan_arrive_time and b.mode_type='加班车'
	)t
	left join fle_staging.fleet_van_proof_parcel_detail ppd
	on ppd.proof_id=t.proof_id and ppd.relation_category in (1,3) and t.store_id=ppd.next_store_id
	join fle_staging.parcel_info pi
	on pi.pno=ppd.relation_no
	left join fle_staging.sys_store_bdc_bsp sb
	on sb.bsp_id=pi.dst_store_id
	where t.rk=1
	and t.store_id=coalesce(sb.bdc_id,pi.dst_store_id)
	group by 1,2,3
) t4 on t.store_id=t4.store_id

left join
( -- 加班车一派前最晚实际到达时间
	select
	t.store_id
	,t.proof_id as max_real_arrive_innormal_proof_id
	,t.real_real_arrive_time as max_real_arrive_time_innormal
	,count(ppd.relation_no) as max_real_arrive_innormal_vol
	from
	(
		select
		b.store_id
		,b.proof_id
		,b.real_real_arrive_time
		,row_number()over(partition by b.store_id order by b.real_real_arrive_time desc) rk
		from base b
		where b.actual_plan_arrive_time<=b.adjust_line_1_latest_plan_arrive_time and b.mode_type='加班车'
	) t
	left join fle_staging.fleet_van_proof_parcel_detail ppd
	on ppd.proof_id=t.proof_id and ppd.relation_category in (1,3) and t.store_id=ppd.next_store_id
	join fle_staging.parcel_info pi
	on pi.pno=ppd.relation_no
	left join fle_staging.sys_store_bdc_bsp sb
	on sb.bsp_id=pi.dst_store_id
	where t.rk=1
	and t.store_id=coalesce(sb.bdc_id,pi.dst_store_id)
	group by 1,2,3
) t5
on t.store_id=t5.store_id;














---------------------------------------------------- 加上网点的到车时间，分拣卡点




drop table test.fleet_real_detail_today1;
create table test.fleet_real_detail_today1 as

with base as
(
	select
	*
	-- 该网点当天第几趟车
	,row_number()over(partition by frd.store_id,date(frd.real_real_arrive_time) order by real_real_arrive_time) as rn
	from test.fleet_real_detail_today frd
	where frd.real_real_arrive_time<=frd.adjust_line_1_latest_plan_arrive_time
),
tmp as
(
	select
	*
	,sum(is_break)over(partition by store_id,date(real_real_arrive_time) order by real_real_arrive_time) rowgroup
	from
	(
		select
		t1.*
		-- 下一辆车的时间
		,t2.schedule_time as after_1_schedule_time
		,TIMESTAMPDIFF(second,t1.real_real_arrive_time,t2.real_real_arrive_time)/3600 as l_hour
		,if(TIMESTAMPDIFF(second,t1.real_real_arrive_time,t2.real_real_arrive_time)/3600<=2,0,1) is_break
		from base t1
		left join base t2
		on t1.store_id = t2.store_id and date(t1.real_real_arrive_time)=date(t2.real_real_arrive_time) and t1.rn+1=t2.rn
	)
	order by store_id,real_real_arrive_time
)




select
*
,count(1)over(partition by store_id,date(real_real_arrive_time),new_rowgroup) times
,first_value(schedule_time)over(partition by store_id,date(real_real_arrive_time),new_rowgroup order by real_real_arrive_time desc) last_time
-- 根据连续次数计算扫描考核结束时间
,case
when count(1)over(partition by store_id,date(real_real_arrive_time),new_rowgroup)=1 then date_add(schedule_time,interval 2 hour)
when count(1)over(partition by store_id,date(real_real_arrive_time),new_rowgroup)=2 then date_add(first_value(schedule_time)over(partition by store_id,date(real_real_arrive_time),new_rowgroup order by real_real_arrive_time desc),interval 2 hour)
when count(1)over(partition by store_id,date(real_real_arrive_time),new_rowgroup)>2 then date_add(first_value(schedule_time)over(partition by store_id,date(real_real_arrive_time),new_rowgroup order by real_real_arrive_time desc),interval 3 hour)
end tiaozheng_scan_deadline_time

from
(
	select
	t1.*
	,case
	 when t1.is_break=1 then t1.rowgroup-1
	 else t1.rowgroup
	end new_rowgroup
	from tmp t1
	order by t1.store_id,t1.real_real_arrive_time
)






















-------------------- 包裹维度，加上仓管分拣时间，分拣卡点时间

drop table test.dwd_th_dc_should_be_delivery_sort_scan;
create table test.dwd_th_dc_should_be_delivery_sort_scan as

with daogang_parcel as
( -- 一派包裹，当日到港包裹、关联出车凭证，以及车辆分拣扫描参考考核时间
	select
	*
	from
	(
		select
		dd.relation_no pno
		,dd.proof_id
		,dd.next_store_id store_id
		,base.proof_counts rn
		,base.late_proof_counts
		,base.schedule_time
		,base.actual_plan_arrive_time plan_arrive_time
		,base.max_real_arrive_time_normal
		,base.max_real_arrive_proof_id
		,base.max_real_arrive_vol
		,base.max_actual_plan_arrive_time_innormal
		,base.max_actual_plan_arrive_innormal_proof_id
		,base.max_actual_plan_arrive_innormal_vol
		,base.max_real_arrive_time_innormal
		,base.max_real_arrive_innormal_proof_id
		,base.max_real_arrive_innormal_vol
		,base.max_schedule_time
		,base.min_schedule_time
		,base.line_1_latest_plan_arrive_time
		,base.real_real_arrive_time real_arrive_time
		,base.mode_type
		,row_number()over(partition by dd.relation_no order by base.real_real_arrive_time asc) row_number_asc
		,base.tiaozheng_scan_deadline_time
		,base.times
		,base.last_time

		from fle_staging.fleet_van_proof_parcel_detail dd

		join
		( -- 当日应派网点
			select
			scd.dst_store_id as store_id
			from dwm.dwd_th_dc_should_be_delivery scd
			where scd.should_delevry_type<>'非当日应派'
			-- and scd.p_date=current_date
			group by 1
		)ss
		on dd.next_store_id=ss.store_id

		join test.fleet_real_detail_today1 base -- 当日车线
		on dd.proof_id=base.proof_id and dd.next_store_id=base.store_id

		where dd.relation_category in (1,3)
		and dd.state in (1,2)
		and base.real_real_arrive_time<=base.adjust_line_1_latest_plan_arrive_time
	) tt
	where tt.row_number_asc=1
)





select
yp.p_date
,yp.dst_store_id as store_id
,yp.store_type
,dp.store_name
,dp.piece_name
,dp.region_name
,yp.pno
,yp.should_delevry_type
,yp.parcel_type
,dg.proof_id
,dg.plan_arrive_time
,dg.max_real_arrive_time_normal
,dg.max_actual_plan_arrive_time_innormal
,dg.max_real_arrive_time_innormal
,dg.max_schedule_time
,dg.min_schedule_time
,dg.schedule_time scan_deadline_time
,dg.line_1_latest_plan_arrive_time
,dg.late_proof_counts
,dg.mode_type
,coalesce(
	dg.tiaozheng_scan_deadline_time,
	date_add(dg_1.min_schedule_time,interval 2 hour),
	concat(yp.p_date,' 08:00:00')) tiaozheng_scan_deadline_time
,dg.times
,dg.last_time
,pr.routed_at min_fenjian_scan_time

from
(
	select
	scd.*
	from dwm.dwd_th_dc_should_be_delivery scd
	where 1=1
	-- and scd.p_date=current_date
	and scd.should_delevry_type<>'非当日应派'
) yp

left join daogang_parcel dg
on yp.dst_store_id=dg.store_id and yp.pno=dg.pno -- 当日到港包裹

left join
( -- 当前天一派前有车辆到达，历史包裹考核参考时间=网点最早一趟考核时间
	select
	bl.store_id
	,min(bl.min_schedule_time) as min_schedule_time
	from test.fleet_real_detail_today bl
	group by bl.store_id
) dg_1
on yp.dst_store_id=dg_1.store_id

left join
( -- 分拣扫描
	select
	pr.pno
	,convert_tz(min(pr.routed_at),'+00:00','+07:00') routed_at
	from rot_pro.parcel_route pr
	where pr.routed_at>convert_tz(current_date,'+07:00','+00:00')
	and pr.routed_at<convert_tz(date_add(current_date,interval 1 day),'+07:00','+00:00')
	and pr.route_action='SORTING_SCAN'
	group by pr.pno
) pr
on yp.pno=pr.pno

left join dwm.dim_th_sys_store_rd dp
on dp.store_id = yp.dst_store_id and dp.stat_date=date_sub(curdate(),interval 1 day);




















-------------------- 评级SQL_0801_v3.txt 基于分拣扫描时间、截止扫描时间算评级，以及取一派前常规车最晚实际到达时间等

select -- 基于当日应派取扫描率
tt.store_id 网点ID
,tt.store_name 网点名称
,tt.store_type 网点分类
,case tt.category
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
,if(bsp.bdc_id is not null,'是','否') as 是否bsp
,tt.piece_name 片区
,tt.region_name 大区
,tt.shoud_counts 应派数
-- ,tt.times 连续次数
-- ,tt.last_time 连续最后一个班次时间
,tt.scan_fished_counts 分拣扫描数
,ifnull(concat(round(tt.scan_fished_counts/shoud_counts,4)*100,'%'),0) 分拣扫描率

,tt.youxiao_counts 有效分拣扫描数
,ifnull(concat(round(tt.youxiao_counts/tt.shoud_counts,4)*100,'%'),0) 有效分拣扫描率

,tt.1pai_counts 一派应派数
,tt.1pai_scan_fished_counts 一派分拣扫描数
,ifnull(concat(round(tt.1pai_scan_fished_counts/tt.1pai_counts,4)*100,'%'),0) 一派分拣扫描率

,tt.1pai_youxiao_counts 一派有效分拣扫描数
,ifnull(concat(round(tt.1pai_youxiao_counts/tt.1pai_counts,4)*100,'%'),0) 一派有效分拣扫描率

,case
 when tt.1pai_youxiao_counts/tt.1pai_counts>=0.95 then 'A'
 when tt.1pai_youxiao_counts/tt.1pai_counts>=0.90 then 'B'
 when tt.1pai_youxiao_counts/tt.1pai_counts>=0.85 then 'C'
 when tt.1pai_youxiao_counts/tt.1pai_counts>=0.80 then 'D'
 else 'E'
end 一派有效分拣评级 -- 一派有效分拣

,case
 when tt.1pai_hour_8_fished_counts/tt.1pai_counts>=0.95 then 'A'
 when tt.1pai_hour_8ban_fished_counts/tt.1pai_counts>=0.95 then 'B'
 when tt.1pai_hour_9_fished_counts/tt.1pai_counts>=0.95 then 'C'
 when tt.1pai_hour_9ban_fished_counts/tt.1pai_counts>=0.95 then 'D'
 else 'E'
end 一派分拣评级

,ifnull(concat(round(tt.1pai_hour_8_fished_counts/tt.1pai_counts,4)*100,'%'),0) 一派8点前扫描占比
,ifnull(concat(round(tt.1pai_hour_8ban_fished_counts/tt.1pai_counts,4)*100,'%'),0) 一派8点半前扫描占比
,ifnull(concat(round(tt.1pai_hour_9_fished_counts/tt.1pai_counts,4)*100,'%'),0) 一派9点前扫描占比
,ifnull(concat(round(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,4)*100,'%'),0) 一派9点半前扫描占比

,if(tt2.late_proof_counts>0,'是','否') 一派常规车线实际比计划时间晚20分钟车辆数
,date_format(tt2.max_real_arrive_time_normal,"%m-%d %H:%i") 一派前常规车最晚实际到达时间
-- ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
-- ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
,date_format(tt2.line_1_latest_plan_arrive_time,"%m-%d %H:%i") 一派前常规车最晚规划到达时间
,date_format(tt2.max_real_arrive_time_innormal,"%m-%d %H:%i") 一派前加班车最晚实际到达时间
-- ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
-- ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
,date_format(tt2.max_actual_plan_arrive_time_innormal,"%m-%d %H:%i") 一派前加班车最晚规划到达时间

from
(
	select
	base.store_id
	,base.store_name
	,base.store_type
	,base.piece_name
	,base.region_name
	,base.category
	,base.times
	,base.last_time
	,count(distinct base.pno) shoud_counts
	,count(distinct case when base.min_fenjian_scan_time is not null then base.pno else null end ) scan_fished_counts
	,count(distinct case when base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end) youxiao_counts

	,count(distinct case when base.type='一派' then  base.pno else null end) 1pai_counts
	,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null then  base.pno else null end) 1pai_scan_fished_counts
	,count(distinct case when base.type='一派' and base.min_fenjian_scan_time is not null and base.min_fenjian_scan_time<tiaozheng_scan_deadline_time then base.pno else null end) 1pai_youxiao_counts

	,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then base.pno else null end) 1pai_hour_8_fished_counts
	,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then base.pno else null end) 1pai_hour_8ban_fished_counts
	,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then base.pno else null end) 1pai_hour_9_fished_counts
	,count(distinct case when base.type='一派' and date_format(base.min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then base.pno else null end) 1pai_hour_9ban_fished_counts

	from
	(
		select
		t.*,
		ss.category,
		case when t.should_delevry_type='1派应派包裹' then '一派' else null end 'type'
		from test.dwd_th_dc_should_be_delivery_sort_scan t
		join fle_staging.sys_store ss
		on t.store_id =ss.id
	) base

	group by base.store_id,base.store_name,base.store_type,base.piece_name,base.region_name,base.category
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
	from test.fleet_real_detail_today bl
	group by 1,2,3,4,5,6,7,8,9,10,11
) tt2
on tt.store_id=tt2.store_id

left join fle_staging.sys_store_bdc_bsp bsp on tt.store_id=bsp.bdc_id and bsp.deleted=0

where tt.category in (1,10)




