select
     case
        when a.del_rate < 0.4 then '<40%'
        when a.del_rate >= 0.4 and a.del_rate < 0.5 then '40%-50%'
        when a.del_rate >= 0.5 and a.del_rate < 0.6 then '50%-60%'
        when a.del_rate >= 0.6 and a.del_rate < 0.7 then '60%-70%'
        when a.del_rate >= 0.7 and a.del_rate < 0.8 then '70%-80%'
        when a.del_rate >= 0.8 and a.del_rate <= 1 then '80%-100%'
    end 妥投率
    ,count(distinct a.网点ID) 总数
    ,count(distinct if(a.一派分拣评级 = 'A', a.网点ID, null))/count(distinct a.网点ID) 评级A
    ,count(distinct if(a.一派分拣评级 = 'B', a.网点ID, null))/count(distinct a.网点ID) 评级B
    ,count(distinct if(a.一派分拣评级 = 'C', a.网点ID, null))/count(distinct a.网点ID) 评级C
    ,count(distinct if(a.一派分拣评级 = 'D', a.网点ID, null))/count(distinct a.网点ID) 评级D
    ,count(distinct if(a.一派分拣评级 = 'E', a.网点ID, null))/count(distinct a.网点ID) 评级E
    ,count(distinct if(a.一派分拣评级 = 'A', a.网点ID, null)) 评级A数量
    ,count(distinct if(a.一派分拣评级 = 'B', a.网点ID, null)) 评级B数量
    ,count(distinct if(a.一派分拣评级 = 'C', a.网点ID, null)) 评级C数量
    ,count(distinct if(a.一派分拣评级 = 'D', a.网点ID, null)) 评级D数量
    ,count(distinct if(a.一派分拣评级 = 'E', a.网点ID, null)) 评级E数量
from
    (
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
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
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
            ) tt2 on tt.store_id=tt2.store_id
        left join fle_staging.sys_store_bdc_bsp bsp on tt.store_id=bsp.bdc_id and bsp.deleted=0
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_th_dc_should_be_delivery ds
                left join fle_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('${date}', interval 7 hour ) and pi.finished_at < date_add('${date}', interval 17 hour)
                where
                    ds.p_date = '${date}'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
        where
            tt.category in (1,10)
    ) a
group by 1

;
-- 0930前分拣扫描占比
select
     case
        when a.一派9点半前扫描占比 < 0.4 then '<40%'
        when a.一派9点半前扫描占比 >= 0.4 and a.一派9点半前扫描占比 < 0.5 then '40%-50%'
        when a.一派9点半前扫描占比 >= 0.5 and a.一派9点半前扫描占比 < 0.6 then '50%-60%'
        when a.一派9点半前扫描占比 >= 0.6 and a.一派9点半前扫描占比 < 0.7 then '60%-70%'
        when a.一派9点半前扫描占比 >= 0.7 and a.一派9点半前扫描占比 < 0.8 then '70%-80%'
        when a.一派9点半前扫描占比 >= 0.8 and a.一派9点半前扫描占比 < 0.9 then '80%-90%'
        when a.一派9点半前扫描占比 >= 0.9 and a.一派9点半前扫描占比 <= 1 then '90%-100%'
#         else a.一派9点半前扫描占比
    end 0930前分拣扫描占比
    ,count(distinct a.网点ID) 总数
    ,sum(a.del_pno_num)/sum(a.pno_num) 妥投率
from
    (
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
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0)*1 一派9点半前扫描占比

            ,if(tt2.late_proof_counts>0,'是','否') 一派常规车线实际比计划时间晚20分钟车辆数
            ,date_format(tt2.max_real_arrive_time_normal,"%m-%d %H:%i") 一派前常规车最晚实际到达时间
            -- ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            -- ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,date_format(tt2.line_1_latest_plan_arrive_time,"%m-%d %H:%i") 一派前常规车最晚规划到达时间
            ,date_format(tt2.max_real_arrive_time_innormal,"%m-%d %H:%i") 一派前加班车最晚实际到达时间
            -- ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            -- ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,date_format(tt2.max_actual_plan_arrive_time_innormal,"%m-%d %H:%i") 一派前加班车最晚规划到达时间
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
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
            ) tt2 on tt.store_id=tt2.store_id
        left join fle_staging.sys_store_bdc_bsp bsp on tt.store_id=bsp.bdc_id and bsp.deleted=0
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_th_dc_should_be_delivery ds
                left join fle_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('${date}', interval 7 hour ) and pi.finished_at < date_add('${date}', interval 17 hour)
                where
                    ds.p_date = '${date}'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
        where
            tt.category in (1,10)
    ) a
group by 1
;

-- 0930前扫描地域80网点分布
select
     a.大区
    ,count(distinct a.网点ID) 总网点数
    ,count(distinct if(a.一派9点半前扫描占比 < 0.8, a.网点ID, null)) 问题网点数
    ,count(distinct if(a.一派9点半前扫描占比 < 0.8, a.网点ID, null))/count(distinct a.网点ID)  问题比例
from
    (
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
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0)*1 一派9点半前扫描占比

            ,if(tt2.late_proof_counts>0,'是','否') 一派常规车线实际比计划时间晚20分钟车辆数
            ,date_format(tt2.max_real_arrive_time_normal,"%m-%d %H:%i") 一派前常规车最晚实际到达时间
            -- ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            -- ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,date_format(tt2.line_1_latest_plan_arrive_time,"%m-%d %H:%i") 一派前常规车最晚规划到达时间
            ,date_format(tt2.max_real_arrive_time_innormal,"%m-%d %H:%i") 一派前加班车最晚实际到达时间
            -- ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            -- ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,date_format(tt2.max_actual_plan_arrive_time_innormal,"%m-%d %H:%i") 一派前加班车最晚规划到达时间
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
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
            ) tt2 on tt.store_id=tt2.store_id
        left join fle_staging.sys_store_bdc_bsp bsp on tt.store_id=bsp.bdc_id and bsp.deleted=0
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_th_dc_should_be_delivery ds
                left join fle_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('${date}', interval 7 hour ) and pi.finished_at < date_add('${date}', interval 17 hour)
                where
                    ds.p_date = '${date}'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
        where
            tt.category in (1,10)
    ) a
group by 1
;


-- 评级为E网点人员分布
select
     a.大区
    ,count(distinct a.网点ID) 总网点数
    ,count(distinct if(a.一派分拣评级 = 'E', a.网点ID, null)) 问题网点数
    ,count(distinct if(a.一派分拣评级 = 'E', a.网点ID, null))/count(distinct a.网点ID)  问题比例
from
    (
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
            ,ifnull(tt.1pai_hour_9ban_fished_counts/tt.1pai_counts,0)*1 一派9点半前扫描占比

            ,if(tt2.late_proof_counts>0,'是','否') 一派常规车线实际比计划时间晚20分钟车辆数
            ,date_format(tt2.max_real_arrive_time_normal,"%m-%d %H:%i") 一派前常规车最晚实际到达时间
            -- ,tt2.max_real_arrive_proof_id 一派前常规车最晚实际到达车线
            -- ,tt2.max_real_arrive_vol 一派前常规车最晚实际到达车线包裹量
            ,date_format(tt2.line_1_latest_plan_arrive_time,"%m-%d %H:%i") 一派前常规车最晚规划到达时间
            ,date_format(tt2.max_real_arrive_time_innormal,"%m-%d %H:%i") 一派前加班车最晚实际到达时间
            -- ,tt2.max_real_arrive_innormal_proof_id 一派前加班车最晚实际到达车线
            -- ,tt2.max_real_arrive_innormal_vol 一派前加班车最晚实际到达车线包裹量
            ,date_format(tt2.max_actual_plan_arrive_time_innormal,"%m-%d %H:%i") 一派前加班车最晚规划到达时间
            ,del.del_rate
            ,del.del_pno_num
            ,del.pno_num
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
            ) tt2 on tt.store_id=tt2.store_id
        left join fle_staging.sys_store_bdc_bsp bsp on tt.store_id=bsp.bdc_id and bsp.deleted=0
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) pno_num
                    ,count(if(pi.pno is not null, ds.pno, null)) del_pno_num
                    ,count(if(pi.pno is not null, ds.pno, null))/count(distinct ds.pno) del_rate
                from dwm.dwd_th_dc_should_be_delivery ds
                left join fle_staging.parcel_info pi on pi.pno = ds.pno and pi.state = 5 and pi.finished_at >= date_sub('${date}', interval 7 hour ) and pi.finished_at < date_add('${date}', interval 17 hour)
                where
                    ds.p_date = '${date}'
                    and ds.should_delevry_type != '非当日应派'
                group by 1
            ) del on del.dst_store_id = tt.store_id
        where
            tt.category in (1,10)
    ) a
group by 1