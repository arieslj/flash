with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+07:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,hs.is_sub_staff
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,hsa.id
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_th_dc_should_be_delivery ds
    join fle_staging.parcel_info pi on pi.pno = ds.pno
    left join fle_staging.sys_store ss on ss.id = ds.dst_store_id
    left join bi_pro.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-09-17'
    left join bi_pro.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-09-17')
    left join backyard_pro.hr_staff_apply_support_store hsa on hsa.sub_staff_info_id = pi.ticket_delivery_staff_info_id and hsa.store_id = ds.dst_store_id
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-09-17'
        and pi.finished_at >= date_sub('2023-09-17', interval 7 hour )
        and pi.finished_at < date_add('2023-09-17', interval 17 hour)
        and ds.should_delevry_type != '非当日应派'
        and ds.dst_store_id = 'TH63031400'
)





select
    dp.store_id 网点ID
    ,dp.store_name 网点
	,if(ss_f.store_id is not null,'有服务区','无服务区') '网点有无服务区'
	,substring_index(dp.store_name,'-',1) short_name
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
	,if(bsp.bdc_id is not null,'是','否') as 是否bsp
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
	,coalesce(del_cou.other_staff_apply_num, 0) 参与妥投快递员_外协支援_申请
	,coalesce(del_cou.other_staff_noapply_num, 0) 参与妥投快递员_外协支援_未申请

    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管
    ,coalesce(del_cou.self_effect, 0) 当日人效_自有

    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.other_staff_apply_effect, 0) 当日人效_外协支援_申请
    ,coalesce(del_cou.other_staff_noapply_effect, 0) 当日人效_外协支援_未申请

    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数

	,dd.in_house_count 在仓包裹数
	,dd.big_in_house_count 在仓大件包裹数
	,dd.big_client_count 在仓平台包裹数
	,dd.small_client_count 在仓非平台包裹数
	,dd.`3_within_backlog_bigclient` '在仓3天内平台包裹数（<=3）'
	,dd.`3_5_backlog_bigclient` '在仓3-5天平台包裹数（>3,<=5）'
	,dd.`5_more_backlog_bigclient` '在仓5天以上平台包裹数（>5）'
	,dd.tt_overtime_count 'tt超时包裹数'

from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
			,dp.store_category
        from dwm.dim_th_sys_store_rd dp
        left join fle_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub('2023-09-17', interval 1 day)
            and ss.category in (1,10)
    ) dp
	left join fle_staging.sys_store_bdc_bsp bsp on dp.store_id=bsp.bdc_id and bsp.deleted=0
left join
    (
        select
            hr.sys_store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  bi_pro.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,452,1497)
#             and hr.stat_date = CURRENT_DATE
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
            and ds.p_date = '2023-09-17'
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
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,452,1497) and t1.formal = 1 and t1.is_sub_staff = 0, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,452,1497) and t1.formal = 1 and t1.is_sub_staff = 0, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,452,1497) and t1.formal = 1 and t1.is_sub_staff = 0, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1 or t1.is_sub_staff = 1) and t1.job_title in (13,110,452,1497), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1 or t1.is_sub_staff = 1) and t1.job_title in (13,110,452,1497), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1 or t1.is_sub_staff = 1) and t1.job_title in (13,110,452,1497), t1.ticket_delivery_staff_info_id, null)) other_effect
            ,count(distinct if(t1.id is not null and t1.job_title in (13,110,452,1497), t1.ticket_delivery_staff_info_id, null )) other_staff_apply_num
            ,count(distinct if(t1.id is not null and t1.job_title in (13,110,452,1497), t1.pno, null))/count(distinct if(t1.id is not null and t1.job_title in (13,110,452,1497), t1.ticket_delivery_staff_info_id, null )) other_staff_apply_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1 ) and t1.id is null and t1.job_title in (13,110,452,1497), t1.ticket_delivery_staff_info_id, null)) other_staff_noapply_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1 ) and t1.id is null and t1.job_title in (13,110,452,1497), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1 ) and t1.id is null and t1.job_title in (13,110,452,1497), t1.ticket_delivery_staff_info_id, null)) other_staff_noapply_effect
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37,451), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37,451), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37,451), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
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


left join
(
	select
	ds.dst_store_id
	,count(distinct ds.pno) in_house_count
	,count(distinct if(pi.exhibition_weight>5000 or pi.exhibition_length+pi.exhibition_width+pi.exhibition_height>80,ds.pno,null)) big_in_house_count
	,count(distinct if(bc.client_id is not null,ds.pno,null)) big_client_count
	,count(distinct if(bc.client_id is null,ds.pno,null)) small_client_count
	,count(distinct if(datediff(now(),ds.first_valid_routed_at)<=3 and bc.client_id is not null,ds.pno,null)) `3_within_backlog_bigclient`
	,count(distinct if(datediff(now(),ds.first_valid_routed_at)>3 and datediff(now(),ds.first_valid_routed_at)<=5 and bc.client_id is not null,ds.pno,null)) `3_5_backlog_bigclient`
	,count(distinct if(datediff(now(),ds.first_valid_routed_at)>5 and bc.client_id is not null,ds.pno,null)) `5_more_backlog_bigclient`
	,count(distinct if(tsd.end_date<curdate(),ds.pno,null)) tt_overtime_count

	from dwm.dwd_th_dc_should_be_delivery ds

	join fle_staging.parcel_info pi
	on pi.pno=ds.pno and pi.state not in (5,7,8,9)

	left join dwm.tmp_ex_big_clients_id_detail bc
	on bc.client_id=pi.client_id

	left join dwm.dwd_ex_th_tiktok_sla_detail tsd
	on tsd.pno=ds.pno

	group by 1
) dd
on dd.dst_store_id=dp.store_id

left join
(

select
    sdg.geo_store_id store_id
from fle_staging.sys_district_geo_store sdg
where
    sdg.deleted = 0

union

select
    sd.store_id
from fle_staging.sys_district sd
where
    sd.deleted = 0
    and sd.geo_tag = 0

union

select
    sd.separation_store_id store_id
from fle_staging.sys_district sd
where
    sd.deleted = 0
    and sd.geo_tag = 0
) ss_f
on ss_f.store_id=dp.store_id
