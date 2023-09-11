
with t as
(
    select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
        ,pi.ticket_delivery_staff_info_id
        ,pi.state
        ,hs.is_sub_staff
        ,coalesce(hsi.store_id, hs.sys_store_id) hr_store_id
        ,coalesce(hsi.job_title, hs.job_title) job_title
        ,coalesce(hsi.formal, hs.formal) formal
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at) rk1
        ,row_number() over (partition by ds.dst_store_id, pi.ticket_delivery_staff_info_id order by pi.finished_at desc) rk2
    from dwm.dwd_th_dc_should_be_delivery_d ds
    join fle_staging.parcel_info pi on pi.pno = ds.pno
    left join fle_staging.sys_store ss on ss.id = ds.dst_store_id
    left join bi_pro.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '${date}'
    left join bi_pro.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '${date}')
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '${date}'
        and pi.finished_at >= date_sub('${date}', interval 8 hour )
        and pi.finished_at < date_add('${date}', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and ds.dst_store_id = 'TH16020303'
)
select
    dp.store_id 网点ID
    ,dp.store_name 网点
    ,coalesce(dp.opening_at, '未记录') 开业时间
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,coalesce(cour.staf_num, 0) 本网点所属快递员数
    ,coalesce(ds.sd_num, 0) 应派件量
    ,coalesce(del.pno_num, 0) '妥投量(快递员+仓管+主管)'
    ,coalesce(del_cou.self_staff_num, 0) 参与妥投快递员_自有
    ,coalesce(del_cou.other_staff_num, 0) 参与妥投快递员_外协支援
    ,coalesce(del_cou.dco_dcs_num, 0) 参与妥投_仓管主管

    ,coalesce(del_cou.self_effect, 0) 当日人效_自有
    ,coalesce(del_cou.other_effect, 0) 当日人效_外协支援
    ,coalesce(del_cou.dco_dcs_effect, 0) 仓管主管人效
    ,coalesce(del_hour.avg_del_hour, 0) 派件小时数
from
    (
        select
            dp.store_id
            ,dp.store_name
            ,dp.opening_at
            ,dp.piece_name
            ,dp.region_name
        from dwm.dim_th_sys_store_rd dp
        left join fle_staging.sys_store ss on ss.id = dp.store_id
        where
            dp.state_desc = '激活'
            and dp.stat_date = date_sub(curdate(), interval 1 day)
            and ss.category in (1,10)
    ) dp
left join
    (
        select
            hr.sys_store_id sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  bi_pro.hr_staff_info hr
        where
            hr.formal = 1
            and hr.state = 1
            and hr.job_title in (13,110,452)
#             and hr.stat_date = '${date}'
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
            and ds.p_date = '${date}'
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
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,452) and t1.formal = 1 and t1.is_sub_staff = 0, t1.ticket_delivery_staff_info_id, null)) self_staff_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,452) and t1.formal = 1 and t1.is_sub_staff = 0, t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (13,110,452) and t1.formal = 1 and t1.is_sub_staff = 0, t1.ticket_delivery_staff_info_id, null)) self_effect
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1 or t1.is_sub_staff = 1) and t1.job_title in (13,110,452), t1.ticket_delivery_staff_info_id, null)) other_staff_num
            ,count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1 or t1.is_sub_staff = 1) and t1.job_title in (13,110,452), t1.pno, null))/count(distinct if((t1.hr_store_id != t1.store_id or t1.formal != 1 or t1.is_sub_staff = 1) and t1.job_title in (13,110,452), t1.ticket_delivery_staff_info_id, null)) other_effect

            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.pno, null))/count(distinct if(t1.hr_store_id = t1.store_id and t1.job_title in (16,37), t1.ticket_delivery_staff_info_id, null)) dco_dcs_effect
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

;


select
		pi.pno
        ,convert_tz(pi.finished_at, '+00:00', '+07:00') as finished_at
		,pi.ticket_delivery_staff_info_id
		,sd.staff_info_id
		,sd.sub_staff_info_id
		,ss.name
		,ss.id
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on pi.dst_store_id=ss.id
left join backyard_pro.hr_staff_apply_support_store sd on pi.ticket_delivery_staff_info_id=sd.sub_staff_info_id
where ss.name='DID_SP-ดินแดง'
and pi.finished_at>'2023-08-22 17:00:00'
and pi.finished_at<'2023-08-23 17:00:00'

;
select
        ds.dst_store_id store_id
        ,ss.name
        ,ds.pno
        ,convert_tz(pi.finished_at, '+00:00', '+08:00') finished_time
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
    left join bi_pro.hr_staff_transfer hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.stat_date = '${date}'
    left join bi_pro.hr_staff_info hs on hs.staff_info_id = pi.ticket_delivery_staff_info_id and if(hs.leave_date is null, 1 = 1, hs.leave_date >= '${date}')
    left join backyard_pro.hr_staff_apply_support_store hsa on hsa.sub_staff_info_id = pi.ticket_delivery_staff_info_id
#     left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
    where
        pi.state = 5
#         and pi.finished_at >= '2023-08-01 16:00:00'
#         and pi.finished_at < '2023-08-02 16:00:00'
        and ds.p_date = '${date}'
        and pi.finished_at >= date_sub('${date}', interval 8 hour )
        and pi.finished_at < date_add('${date}', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
        and ds.dst_store_id = 'TH01080138'