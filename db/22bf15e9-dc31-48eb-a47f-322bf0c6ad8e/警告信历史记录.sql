

-- 评级总表

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
    left join bi_pro.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '2023-09-16'
    left join bi_pro.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '2023-09-16')
    left join backyard_pro.hr_staff_apply_support_store hsa on hsa.sub_staff_info_id = pi.ticket_delivery_staff_info_id and hsa.store_id = ds.dst_store_id
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '2023-09-16'
        and pi.finished_at >= date_sub('2023-09-16', interval 7 hour )
        and pi.finished_at < date_add('2023-09-16', interval 17 hour)
        and ds.should_delevry_type != '非当日应派'
#         and ds.dst_store_id = 'TH16020303'
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
            and dp.stat_date = date_sub('2023-09-16', interval 1 day)
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
            and ds.p_date = '2023-09-16'
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


;

#/*
case mw.type_code
        when 'warning_01' then '迟到早退'
        when 'warning_02' then '连续旷工'
        when 'warning_03' then '贪污'
        when 'warning_04' then '工作时间或工作地点饮酒'
        when 'warning_05' then '持有或吸食毒品'
        when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
        when 'warning_07' then '通过社会媒体污蔑公司'
        when 'warning_08' then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 'warning_09' then '腐败/滥用职权'
        when 'warning_10' then '玩忽职守'
        when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 'warning_12' then '未告知上级或无故旷工'
        when 'warning_13' then '上级没有同意请假、没有通过系统请假'
        when 'warning_14' then '没有通过系统请假'
        when 'warning_15' then '未按时上下班'
        when 'warning_16' then '不配合公司的吸毒检查'
        when 'warning_17' then '伪造证件'
        when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
        when 'warning_19' then '未按照网点规定的时间回款'
        when 'warning_20' then '谎报里程'
        when 'warning_21' then '煽动/挑衅/损害公司利益'
        when 'warning_22' then '失职'
        when 'warning_23' then '损害公司名誉'
        when 'warning_24' then '不接受或不配合公司的调查'
        when 'warning_25' then 'Fake  Status'
        when 'warning_26' then 'Fake  POD '
        when 'warning_27' then '工作效率未达到公司的标准(KPI)'
        when 'warning_28' then '贪污钱 '
        when 'warning_29' then '贪污包裹'
        when 'warning_30' then '偷盗公司财物'
        when 'warning_31' then '无故连续旷工1天'
        when 'warning_32' then '无故连续旷工2天'
        when 'warning_33' then '迟到/早退 <= 10 分钟超过1次'
        when 'warning_34' then '性骚扰'
        when 'warning_35' then '提供虚假或未更新的个人信息'
        when 'warning_36' then 'Fake scan face - 违法者'
        when 'warning_37' then 'Fake scan face - 帮手'
        when 'warning_111' then 'PH-迟到/经常性迟到'
        when 'warning_112' then 'PH-连续旷工 1-2日'
        when 'warning_113' then 'PH-虚假考勤/假装生病'
        when 'warning_114' then 'PH-休息时间过长/不遵守时间表'
        when 'warning_115' then 'PH-虚假标记/RTS/POD/送达/取消/改期配送以及修改包裹重量'
        when 'warning_116' then 'PH-不服从上级'
        when 'warning_117' then 'PH-盗窃公司财物'
        when 'warning_118' then 'PH-公司设备私人使用/ 利用公司设备去做其他事情'
        when 'warning_119' then 'PH-低效/不满足工作标准'
        when 'warning_120' then 'PH-吵架、打架/ 伤害同事、外部人员、上级或其他人'
        when 'warning_121' then 'PH-不尊重/粗鲁无礼'
        when 'warning_122' then 'PH-粗心大意造成公司重大损失'
        when 'warning_123' then 'PH-酒精中毒/使用毒品或非法物品'
        when 'warning_124' then 'PH-没有穿正确的制服/穿短裤/拖鞋/凉鞋/没有穿衬衫/衣服'
        when 'warning_125' then 'PH-出勤时睡觉'
        when 'warning_126' then 'PH-未按照网点规定时间回款'
        when 'warning_127' then 'PH-工作时间内赌博/在工作区域内赌博'
        when 'warning_128' then 'PH-在工作区域内抽烟（包含电子烟）'
        when 'warning_129' then 'PH-向客户收取额外费用'
        when 'warning_130' then 'PH-替换包裹内物品'
        when 'warning_131' then 'PH-未能按照工作标准行事或执行工作，或未能遵循服务标准'
        when 'warning_132' then 'PH-未经授权使用公司物资、材料、设施、工具或设备'
        when 'warning_133' then 'PH-兼职行为'
        when 'warning_101' then '一月内虚假妥投大于等于4次'
        when 'warning_102' then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 'warning_103' then '虚假扫描'
        when 'warning_104' then '偷盗包裹'
        when 'warning_105' then '仓库内吸烟'
        when 'warning_106' then '辱骂客户'
        when 'warning_107' then '乱扔包裹'
        when 'warning_108' then '一个月内两次及以上虚假取消揽收'
        when 'warning_109' then '未经客户同意私自擅闯客户家'
        when 'warning_110' then '恶意争抢客户'
        else mw.type_code
    end warn_reason
# */
;







with t as
(

    select
        a2.staff_info_id
        ,a2.type_code
        ,a2.type_count
        ,row_number() over (partition by a2.staff_info_id order by a2.type_count) rk
    from
        (
            select
                a.staff_info_id
                ,a.type_code
                ,a.type_count
            from
                (
                    select
                        mw.staff_info_id
                        ,case mw.`warning_type`
                            when 1 then '口述警告'
                            when 2 then '书面警告'
                            when 3 then '末次书面警告'
                        end as 警告类型
                        ,mw.type_code
                        ,count(mw.id) over (partition by mw.staff_info_id, mw.type_code) type_count
                    from backyard_pro.message_warning mw
                    join bi_pro.hr_staff_info hsi on hsi.staff_info_id = mw.staff_info_id and hsi.state = 1
                    where
                        mw.is_delete = 0
                        and mw.send_status = 1
                        and mw.warning_type in (2,3)
                        and mw.date_ats > date_sub(curdate(), interval 1 year )
                ) a
            where
                a.type_count > 1
            group by 1,2,3
        ) a2
)
select
    hsi2.staff_info_id
    ,hjt.job_name 职位
    ,hsi2.hire_date 入职时间
    ,datediff(curdate(), hsi2.hire_date) 入职天数
    ,if(a2.员工 is not null, '是', '否') '是否同一警告原因书面+某次书面2次及以上'
    ,a2.`书面+末次书面警告2次及以上-原因1`
    ,a2.`书面+末次书面警告2次及以上次数-原因1`
    ,a2.`书面+末次书面警告2次及以上-原因2`
    ,a2.`书面+末次书面警告2次及以上次数-原因2`
from bi_pro.hr_staff_info hsi2
left join bi_pro.hr_job_title hjt on hjt.id = hsi2.job_title
left join
    (
                select
            t1.staff_info_id 员工
        #     ,t1.type_code
            ,case t1.type_code
                when 'warning_01' then '迟到早退'
                when 'warning_02' then '连续旷工'
                when 'warning_03' then '贪污'
                when 'warning_04' then '工作时间或工作地点饮酒'
                when 'warning_05' then '持有或吸食毒品'
                when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
                when 'warning_07' then '通过社会媒体污蔑公司'
                when 'warning_08' then '公司设备私人使用 / 利用公司设备去做其他事情'
                when 'warning_09' then '腐败/滥用职权'
                when 'warning_10' then '玩忽职守'
                when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
                when 'warning_12' then '未告知上级或无故旷工'
                when 'warning_13' then '上级没有同意请假、没有通过系统请假'
                when 'warning_14' then '没有通过系统请假'
                when 'warning_15' then '未按时上下班'
                when 'warning_16' then '不配合公司的吸毒检查'
                when 'warning_17' then '伪造证件'
                when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
                when 'warning_19' then '未按照网点规定的时间回款'
                when 'warning_20' then '谎报里程'
                when 'warning_21' then '煽动/挑衅/损害公司利益'
                when 'warning_22' then '失职'
                when 'warning_23' then '损害公司名誉'
                when 'warning_24' then '不接受或不配合公司的调查'
                when 'warning_25' then 'Fake  Status'
                when 'warning_26' then 'Fake  POD '
                when 'warning_27' then '工作效率未达到公司的标准(KPI)'
                when 'warning_28' then '贪污钱 '
                when 'warning_29' then '贪污包裹'
                when 'warning_30' then '偷盗公司财物'
                when 'warning_31' then '无故连续旷工1天'
                when 'warning_32' then '无故连续旷工2天'
                when 'warning_33' then '迟到/早退 <= 10 分钟超过1次'
                when 'warning_34' then '性骚扰'
                when 'warning_35' then '提供虚假或未更新的个人信息'
                when 'warning_36' then 'Fake scan face - 违法者'
                when 'warning_37' then 'Fake scan face - 帮手'
                when 'warning_111' then 'PH-迟到/经常性迟到'
                when 'warning_112' then 'PH-连续旷工 1-2日'
                when 'warning_113' then 'PH-虚假考勤/假装生病'
                when 'warning_114' then 'PH-休息时间过长/不遵守时间表'
                when 'warning_115' then 'PH-虚假标记/RTS/POD/送达/取消/改期配送以及修改包裹重量'
                when 'warning_116' then 'PH-不服从上级'
                when 'warning_117' then 'PH-盗窃公司财物'
                when 'warning_118' then 'PH-公司设备私人使用/ 利用公司设备去做其他事情'
                when 'warning_119' then 'PH-低效/不满足工作标准'
                when 'warning_120' then 'PH-吵架、打架/ 伤害同事、外部人员、上级或其他人'
                when 'warning_121' then 'PH-不尊重/粗鲁无礼'
                when 'warning_122' then 'PH-粗心大意造成公司重大损失'
                when 'warning_123' then 'PH-酒精中毒/使用毒品或非法物品'
                when 'warning_124' then 'PH-没有穿正确的制服/穿短裤/拖鞋/凉鞋/没有穿衬衫/衣服'
                when 'warning_125' then 'PH-出勤时睡觉'
                when 'warning_126' then 'PH-未按照网点规定时间回款'
                when 'warning_127' then 'PH-工作时间内赌博/在工作区域内赌博'
                when 'warning_128' then 'PH-在工作区域内抽烟（包含电子烟）'
                when 'warning_129' then 'PH-向客户收取额外费用'
                when 'warning_130' then 'PH-替换包裹内物品'
                when 'warning_131' then 'PH-未能按照工作标准行事或执行工作，或未能遵循服务标准'
                when 'warning_132' then 'PH-未经授权使用公司物资、材料、设施、工具或设备'
                when 'warning_133' then 'PH-兼职行为'
                when 'warning_101' then '一月内虚假妥投大于等于4次'
                when 'warning_102' then '包裹被网点KIT扫描后遗失（2件及以上）'
                when 'warning_103' then '虚假扫描'
                when 'warning_104' then '偷盗包裹'
                when 'warning_105' then '仓库内吸烟'
                when 'warning_106' then '辱骂客户'
                when 'warning_107' then '乱扔包裹'
                when 'warning_108' then '一个月内两次及以上虚假取消揽收'
                when 'warning_109' then '未经客户同意私自擅闯客户家'
                when 'warning_110' then '恶意争抢客户'
                else t1.type_code
            end '书面+末次书面警告2次及以上-原因1'
            ,t1.type_count '书面+末次书面警告2次及以上次数-原因1'
            ,case t2.type_code
                when 'warning_01' then '迟到早退'
                when 'warning_02' then '连续旷工'
                when 'warning_03' then '贪污'
                when 'warning_04' then '工作时间或工作地点饮酒'
                when 'warning_05' then '持有或吸食毒品'
                when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
                when 'warning_07' then '通过社会媒体污蔑公司'
                when 'warning_08' then '公司设备私人使用 / 利用公司设备去做其他事情'
                when 'warning_09' then '腐败/滥用职权'
                when 'warning_10' then '玩忽职守'
                when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
                when 'warning_12' then '未告知上级或无故旷工'
                when 'warning_13' then '上级没有同意请假、没有通过系统请假'
                when 'warning_14' then '没有通过系统请假'
                when 'warning_15' then '未按时上下班'
                when 'warning_16' then '不配合公司的吸毒检查'
                when 'warning_17' then '伪造证件'
                when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
                when 'warning_19' then '未按照网点规定的时间回款'
                when 'warning_20' then '谎报里程'
                when 'warning_21' then '煽动/挑衅/损害公司利益'
                when 'warning_22' then '失职'
                when 'warning_23' then '损害公司名誉'
                when 'warning_24' then '不接受或不配合公司的调查'
                when 'warning_25' then 'Fake  Status'
                when 'warning_26' then 'Fake  POD '
                when 'warning_27' then '工作效率未达到公司的标准(KPI)'
                when 'warning_28' then '贪污钱 '
                when 'warning_29' then '贪污包裹'
                when 'warning_30' then '偷盗公司财物'
                when 'warning_31' then '无故连续旷工1天'
                when 'warning_32' then '无故连续旷工2天'
                when 'warning_33' then '迟到/早退 <= 10 分钟超过1次'
                when 'warning_34' then '性骚扰'
                when 'warning_35' then '提供虚假或未更新的个人信息'
                when 'warning_36' then 'Fake scan face - 违法者'
                when 'warning_37' then 'Fake scan face - 帮手'
                when 'warning_111' then 'PH-迟到/经常性迟到'
                when 'warning_112' then 'PH-连续旷工 1-2日'
                when 'warning_113' then 'PH-虚假考勤/假装生病'
                when 'warning_114' then 'PH-休息时间过长/不遵守时间表'
                when 'warning_115' then 'PH-虚假标记/RTS/POD/送达/取消/改期配送以及修改包裹重量'
                when 'warning_116' then 'PH-不服从上级'
                when 'warning_117' then 'PH-盗窃公司财物'
                when 'warning_118' then 'PH-公司设备私人使用/ 利用公司设备去做其他事情'
                when 'warning_119' then 'PH-低效/不满足工作标准'
                when 'warning_120' then 'PH-吵架、打架/ 伤害同事、外部人员、上级或其他人'
                when 'warning_121' then 'PH-不尊重/粗鲁无礼'
                when 'warning_122' then 'PH-粗心大意造成公司重大损失'
                when 'warning_123' then 'PH-酒精中毒/使用毒品或非法物品'
                when 'warning_124' then 'PH-没有穿正确的制服/穿短裤/拖鞋/凉鞋/没有穿衬衫/衣服'
                when 'warning_125' then 'PH-出勤时睡觉'
                when 'warning_126' then 'PH-未按照网点规定时间回款'
                when 'warning_127' then 'PH-工作时间内赌博/在工作区域内赌博'
                when 'warning_128' then 'PH-在工作区域内抽烟（包含电子烟）'
                when 'warning_129' then 'PH-向客户收取额外费用'
                when 'warning_130' then 'PH-替换包裹内物品'
                when 'warning_131' then 'PH-未能按照工作标准行事或执行工作，或未能遵循服务标准'
                when 'warning_132' then 'PH-未经授权使用公司物资、材料、设施、工具或设备'
                when 'warning_133' then 'PH-兼职行为'
                when 'warning_101' then '一月内虚假妥投大于等于4次'
                when 'warning_102' then '包裹被网点KIT扫描后遗失（2件及以上）'
                when 'warning_103' then '虚假扫描'
                when 'warning_104' then '偷盗包裹'
                when 'warning_105' then '仓库内吸烟'
                when 'warning_106' then '辱骂客户'
                when 'warning_107' then '乱扔包裹'
                when 'warning_108' then '一个月内两次及以上虚假取消揽收'
                when 'warning_109' then '未经客户同意私自擅闯客户家'
                when 'warning_110' then '恶意争抢客户'
                else t2.type_code
            end '书面+末次书面警告2次及以上-原因2'
            ,t2.type_count '书面+末次书面警告2次及以上次数-原因2'
        from (select * from t t1 where t1.rk = 1) t1
        left join t t2 on t2.staff_info_id = t1.staff_info_id and  t2.rk = 2
        where
            t1.rk = 1
    ) a2 on a2.员工 = hsi2.staff_info_id
where
    hsi2.state = 1
    and hsi2.formal = 1
    and hsi2.is_sub_staff = 0
    and hsi2.sys_store_id != '-1'
#     and hsi2.staff_info_id = '641675'