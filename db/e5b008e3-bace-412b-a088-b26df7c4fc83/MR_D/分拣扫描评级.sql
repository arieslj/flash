select -- 基于当日应派取扫描率
    tt.store_id 网点ID
    ,tt.store_name 网点名称
    ,tt.store_type 网点分类
    ,tt.piece_name 片区
    ,tt.region_name 大区
    ,tt.shoud_counts 应派总数
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
	,tt2.late_proof_counts 是否有迟到超过规划时间20分钟的常规车
    ,tt2.max_real_arrive_time_normal 一派常规车最晚实际到达时间
    ,tt2.max_real_arrive_proof_id 一派常规车最晚实际到达车线
    ,tt2.max_real_arrive_vol 一派常规车最晚实际到达车线包裹量
    ,tt2.line_1_latest_plan_arrive_time 一派常规车最晚规划到达时间
    ,tt2.max_real_arrive_time_innormal 一派加班车最晚实际到达时间
    ,tt2.max_real_arrive_innormal_proof_id  一派加班车最晚实际到达车线
    ,tt2.max_real_arrive_innormal_vol  一派加班车最晚实际到达包裹量
    ,tt2.max_actual_plan_arrive_time_innormal 一派加班车最晚规划到达时间


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
       case when t.should_delevry_type='1派应派包裹' then '一派' else null end 'type'
       from dwm.dwd_ph_dc_should_be_delivery_sort_scan t
       join ph_staging.sys_store ss
       on t.store_id =ss.id
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