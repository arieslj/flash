select
    a.store_id
    ,b.pno
    ,a.sort_time
from
    (
        select
            ds.pno
            ,ds.store_id
        from ph_bi.dc_should_delivery_today ds
#         left join ph_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at > '2023-07-24 16:00:00' and pr.routed_at < '2023-07-25 16:00:00'
        where
            ds.stat_date = '2023-07-25'
            and ds.store_id = 'PH61270901'
    ) b
left join
    (
        select
            ds.pno
            ,ds.store_id
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sort_time
            ,row_number() over (partition by ds.pno order by pr.routed_at ) rk
        from ph_bi.dc_should_delivery_today ds
        left join ph_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at > '2023-07-24 16:00:00' and pr.routed_at < '2023-07-25 16:00:00'
        where
            ds.stat_date = '2023-07-25'
            and ds.store_id = 'PH61270901'
    ) a on a.store_id = b.store_id and a.pno = b.pno and a.rk = 1


    ;

select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'sorting.scan.enable.store.ids'

;

select
    ss.id
    ,ss.delivery_frequency
from ph_staging.sys_store ss
where
    ss.state = 1

;


select
	tt.store_id 网点ID,
	tt.store_name 网点名称,
	piece_name 片区,
	region_name 大区,
	shoud_counts 应派总数,
	scan_fished_counts 分拣扫描数,
	scan_fished_counts/shoud_counts 分拣扫描率,

	youxiao_counts 总有效分拣扫描数,
	youxiao_counts/scan_fished_counts 总有效分拣扫描率,

	1pai_counts  一派应派数,
	1pai_scan_fished_counts 一派分拣扫描数,
	1pai_scan_fished_counts/1pai_counts  一派分拣扫描率,

	1pai_youxiao_counts 一派有效分拣扫描数,
	1pai_youxiao_counts/1pai_scan_fished_counts 一派有效分拣扫描率，

	1pai_hour_8_fished_counts/1pai_scan_fished_counts  一派8点前扫描占比,
	1pai_hour_8ban_fished_counts/1pai_scan_fished_counts  一派8点半前扫描占比,
	1pai_hour_9_fished_counts/1pai_scan_fished_counts 一派9点前扫描占比,
	1pai_hour_9ban_fished_counts/1pai_scan_fished_counts 一派9点半前扫描占比,

	case
	   when 1pai_scan_fished_counts/1pai_counts>=0.95 and 1pai_hour_8_fished_counts/1pai_scan_fished_counts>=0.98 then 'A'
	   when 1pai_scan_fished_counts/1pai_counts>=0.95 and 1pai_hour_8ban_fished_counts/1pai_scan_fished_counts>=0.98 then 'B'
	   when 1pai_scan_fished_counts/1pai_counts>=0.95 and 1pai_hour_9_fished_counts/1pai_scan_fished_counts>=0.98 then 'C'
	   when 1pai_scan_fished_counts/1pai_counts>=0.95 and 1pai_hour_9ban_fished_counts/1pai_scan_fished_counts>=0.98 then 'D'
	   else 'E'
	end 一派分拣评级,

	case
	   when 1pai_youxiao_counts/1pai_scan_fished_counts>=0.95 then 'A'
	   when 1pai_youxiao_counts/1pai_scan_fished_counts>=0.90 then 'B'
	   when 1pai_youxiao_counts/1pai_scan_fished_counts>=0.85 then 'C'
	   when 1pai_youxiao_counts/1pai_scan_fished_counts>=0.80 then 'D'
	   else 'E'
	end 一派有效分拣评级, -- 派有效分拣
	tt1.min_real_arrived_at,
	tt1.max_real_arrived_at,
	tt1.real_counts,
	tt2.max_schedule_time
from
(
	select
		store_id,
		store_name,
		piece_name,
		region_name,
		count(pno) shoud_counts,
		count(case when min_fenjian_scan_time is not null then pno else null end ) scan_fished_counts,

		count(case when min_fenjian_scan_time is not null and min_fenjian_scan_time<tiaozheng_scan_deadline_time then pno else null end ) youxiao_counts,

		count(case when type='一派' then  pno else null end ) 1pai_counts,
		count(case when type='一派' and min_fenjian_scan_time is not null then  pno else null end ) 1pai_scan_fished_counts,
		count(case when type='一派' and min_fenjian_scan_time is not null and min_fenjian_scan_time<tiaozheng_scan_deadline_time then  pno else null end ) 1pai_youxiao_counts,

		count(case when type='一派' and date_format(min_fenjian_scan_time,'%H:%i:%s')<='08:00:00' then pno else null end) 1pai_hour_8_fished_counts,
		count(case when type='一派' and date_format(min_fenjian_scan_time,'%H:%i:%s')<='08:30:00' then pno else null end) 1pai_hour_8ban_fished_counts,
		count(case when type='一派' and date_format(min_fenjian_scan_time,'%H:%i:%s')<='09:00:00' then pno else null end) 1pai_hour_9_fished_counts,
		count(case when type='一派' and date_format(min_fenjian_scan_time,'%H:%i:%s')<='09:30:00' then pno else null end) 1pai_hour_9ban_fished_counts
	from
	(
		select
			t.*, case when hour(real_arrived_at)<9 or real_arrived_at is null then '一派'  end type
		from test.fleet_20230720_v2 t
		join ph_staging.sys_store ss
		on t.store_id =ss.id
		where
		ss.category not in (8) and t.store_name not like '%_PDC%'
	) base

	group by store_id,store_name,piece_name,region_name
) tt

left join
(
	select
		dd.next_store_id,
		min(convert_tz(fvr.created_at,'+00:00','+08:00')) min_real_arrived_at,
		max(convert_tz(fvr.created_at,'+00:00','+08:00')) max_real_arrived_at,
		count(distinct dd.proof_id) real_counts
	from  ph_staging.fleet_van_proof_parcel_detail dd

	join ph_staging.fleet_van_route fvr
	on dd.next_store_id=fvr.store_id
	and dd.proof_id=fvr.proof_id
	where
	dd.relation_category in (1,3)
	and dd.state in (1,2)
	and fvr.event =1
	and fvr.created_at >=convert_tz('2023-07-25','+08:00','+00:00')
	and fvr.created_at <convert_tz('2023-07-25 09:00:00','+08:00','+00:00')
	and fvr.deleted =0
	group by next_store_id

) tt1
on tt.store_id=tt1.next_store_id

left join
(
	select next_store_id,max(max_schedule_time) max_schedule_time from test.fleet_base group by next_store_id
) tt2
on tt.store_id=tt2.next_store_id
;