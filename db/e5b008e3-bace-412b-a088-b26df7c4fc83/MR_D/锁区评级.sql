with t as
(
    select
        ds.dst_store_id as store_id
        ,pr.pno
        ,hst.sys_store_id hr_store_id
        ,hst.formal
        ,pr.staff_info_id
        ,pi.state
        ,hst.job_title
    from dwm.dwd_ph_dc_should_be_delivery ds
    left join ph_staging.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    left join ph_bi.hr_staff_info hst on hst.staff_info_id = pr.staff_info_id
#     left join ph_bi.hr_staff_transfer hst  on hst.staff_info_id = pr.staff_info_id
    where
        ds.p_date = '${date}'
        and pr.routed_at >= date_sub('${date}', interval 8 hour )
        and pr.routed_at < date_add('${date}', interval 16 hour)
        and ds.should_delevry_type != '非当日应派'
#         and hst.stat_date = '${date}'
#         and ds.dst_store_id in ('PH35300N06', 'PH35172804')
)
    select
        dr.store_id 网点ID
        ,dr.store_name 网点
        ,coalesce(dr.opening_at, '未记录') 开业时间
        ,case dr.store_category
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
        ,dr.piece_name 片区
        ,dr.region_name 大区
        ,coalesce(emp_cnt.staf_num, 0) 总快递员人数_在职
        ,coalesce(a3.self_staff_num, 0) 自有快递员出勤数
        ,coalesce(a3.other_staff_num, 0) '外协+支援快递员出勤数'
        ,coalesce(a3.dco_dcs_num, 0) 仓管主管_出勤数

        ,coalesce(a3.avg_scan_num, 0) 快递员平均交接量
        ,coalesce(a3.avg_del_num, 0) 快递员平均妥投量
        ,coalesce(a3.dco_dcs_avg_scan, 0) 仓管主管_平均交接量

        ,coalesce(sdb.code_num, 0) 网点三段码数量
        ,coalesce(a2.self_avg_staff_code, 0) 自有快递员三段码平均交接量
        ,coalesce(a2.other_avg_staff_code, 0) '外协+支援快递员三段码平均交接量'
        ,coalesce(a2.self_avg_staff_del_code, 0) 自有快递员三段码平均妥投量
        ,coalesce(a2.other_avg_staff_del_code, 0) '外协+支援快递员三段码平均妥投量'
        ,coalesce(a2.avg_code_staff, 0) 三段码平均交接快递员数
        ,case
            when a2.avg_code_staff < 2 then 'A'
            when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
            when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
            when a2.avg_code_staff >= 4 then 'D'
        end 评级
        ,a2.code_num
        ,a2.staff_code_num
        ,a2.staff_num
        ,a2.fin_staff_code_num
    from
        (
            select
                a1.store_id
                ,count(distinct if(a1.job_title in (13,110,1000), a1.staff_code, null)) staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1000), a1.third_sorting_code, null)) code_num
                ,count(distinct if(a1.job_title in (13,110,1000), a1.staff_info_id, null)) staff_num
                ,count(distinct if(a1.job_title in (13,110,1000), a1.staff_code, null)) fin_staff_code_num
                ,count(distinct if(a1.job_title in (13,110,1000), a1.staff_code, null))/ count(distinct if(a1.job_title in (13,110,1000), a1.third_sorting_code, null)) avg_code_staff
                ,count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1000), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1000), a1.staff_info_id, null)) self_avg_staff_code
                ,count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1000), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1000), a1.staff_info_id, null)) other_avg_staff_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'y' and a1.job_title in (13,110,1000), a1.staff_code, null))/count(distinct if(a1.is_self = 'y' and a1.job_title in (13,110,1000), a1.staff_info_id, null)) self_avg_staff_del_code
                ,count(distinct if(a1.state = 5 and a1.is_self = 'n' and a1.job_title in (13,110,1000), a1.staff_code, null))/count(distinct if(a1.is_self = 'n' and a1.job_title in (13,110,1000), a1.staff_info_id, null)) other_avg_staff_del_code
            from
                (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,if(t1.formal = 1 and t1.store_id = t1.hr_store_id, 'y', 'n') is_self
                            ,t1.state
                            ,t1.job_title
                            ,ps.third_sorting_code
                            ,rank() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        join ph_drds.parcel_sorting_code_info ps on  ps.pno = t1.pno and ps.dst_store_id = t1.store_id and ps.third_sorting_code != 'XX'
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.state = 1
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
# left join
#     (
#         select
#            ad.sys_store_id
#            ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
#        from ph_bi.attendance_data_v2 ad
#        left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
#        where
#            (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
#             and hr.job_title in (13,110,1000)
# #             and ad.stat_date = curdate()
#             and ad.stat_date = '${date}'
#        group by 1
#     ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(distinct if(t1.hr_store_id = t1.store_id and t1.formal = 1  and t1.job_title in (13,110,1000), t1.staff_info_id, null))  self_staff_num
            ,count(distinct if(t1.job_title in (13,110,1000) and ( t1.hr_store_id != t1.store_id or t1.formal != 1  ), t1.staff_info_id, null )) other_staff_num
            ,count(distinct if(t1.job_title in (13,110,1000), t1.pno, null))/count(distinct if(t1.job_title in (13,110,1000),  t1.staff_info_id, null)) avg_scan_num
            ,count(distinct if(t1.job_title in (13,110,1000) and t1.state = 5, t1.pno, null))/count(distinct if(t1.job_title in (13,110,1000) and t1.state = 5,  t1.staff_info_id, null)) avg_del_num

            ,count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_num
            ,count(distinct if(t1.job_title in (37,16), t1.pno, null))/count(distinct if(t1.job_title in (37,16), t1.staff_info_id, null)) dco_dcs_avg_scan
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id
left join
    (
        select
            sdb.store_id
            ,count(distinct sdb.delivery_code) code_num
        from ph_staging.store_delivery_barangay_group_info sdb
        where
            sdb.deleted = 0
            and sdb.delivery_code != 'XX'
        group by 1
    ) sdb on sdb.store_id = a2.store_id
where
    dr.store_category = 1
    and sdb.store_id is not null