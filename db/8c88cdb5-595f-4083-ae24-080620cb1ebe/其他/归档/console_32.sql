
with sup as
(
    select
        hsa.staff_info_id
        ,hsa.sub_staff_info_id
        ,hsa.store_id
        ,hsa.store_name
        ,hsa.staff_store_id
        ,hsa.job_title_id
    from backyard_pro.hr_staff_apply_support_store hsa
    left join backyard_pro.staff_work_attendance swa on hsa.sub_staff_info_id = swa.staff_info_id and swa.attendance_date = '${date}' and swa.organization_id = hsa.store_id and ( swa.started_at is not null  or swa.end_at is not null )
    where
#         hsa.actual_begin_date <= '${date}'
#         and coalesce(hsa.actual_end_date, curdate()) >= '${date}'
        hsa.employment_begin_date <= '${date}'
        and coalesce(hsa.employment_end_date, curdate()) >= '${date}'
#         and hsa.store_name = 'PRG_SP-บางปรอก'
        and hsa.status = 2
        and hsa.support_status between 2 and 3
#         and swa.id is not null
        and hsa.job_title_id in (13,110,452,1497,37,451)
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
                ,a1.sorting_code
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
                                ,ps.third_sorting_code sorting_code
                                ,row_number() over (partition by ps.pno order by ps.created_at desc ) rk
                            from dwm.dwd_th_dc_should_be_delivery ds
                            join dwm.drds_parcel_sorting_code_info ps on ds.pno =  ps.pno and ds.dst_store_id = ps.dst_store_id
                        ) a
                    where
                        a.rk = 1
                ) a1
            join fle_staging.ticket_delivery td on td.pno = a1.pno and td.created_at >= date_sub('${date}', interval 7 hour) and td.created_at < date_add('${date}', interval 17 hour)
            left join fle_staging.parcel_info pi on pi.pno = a1.pno
        ) a
    where
        a.rn = 1
#         and a.staff_info_id = '624526'
)
select
    t1.大区, t1.片区, t1.网点, t1.当日应派, t1.当日妥投, t1.未妥投大件数量, t1.自有快递员人数（出勤）, t1.支援快递员人数（出勤）, t1.自有仓管, t1.支援仓管, t1.分拣扫描率, t1.自有人效, t1.支援人效
    ,t2.大区, t2.片区, t2.来源网点, t2.主账号, t2.子账号, t2.原岗位,t2.`van/bike`, t2.上班时间, t2.下班时间, t2.揽收量, t2.交接量, t2.妥投量, t2.派送时长, t2.交接三段码数量, t2.妥投三段码数量, t2.未妥投中打电话次数为0的数量, t2.未妥投中打电话次数为1的数量
from
    (
        select
            dt.region_name 大区
            ,dt.piece_name 片区
            ,dt.store_name 网点
            ,a1.today_should_del 当日应派
            ,a1.today_already_del 当日妥投
            ,a1.no_del_big_count 未妥投大件数量
            ,a2.courier_count 自有快递员人数（出勤）
            ,a3.sup_courier_count 支援快递员人数（出勤）
            ,a2.dco_count 自有仓管
            ,a3.sup_dco_count 支援仓管
            ,a4.sort_rate 分拣扫描率
            ,a5.self_effect 自有人效
            ,a5.other_effect 支援人效
        from
            ( -- 应派妥投
                select
                    ss.store_name
                    ,ss.store_id
                    ,count(distinct ds.pno) today_should_del
                    ,count(distinct if(pi.state = 5 and pi.finished_at >= date_sub('${date}', interval 7 hour) and pi.finished_at < date_add('${date}', interval  17 hour), ds.pno, null)) today_already_del
                    ,count(distinct if(pi.state != 5 and ( pi.exhibition_weight > 5000 or pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 ), ds.pno, null)) no_del_big_count
                from dwm.dwd_th_dc_should_be_delivery ds
                left join fle_staging.parcel_info pi on ds.pno = pi.pno
                join
                    (
                        select
                            sup.store_id
                            ,sup.store_name
                        from sup
                        group by 1,2
                    ) ss on ss.store_id = ds.dst_store_id
                where
                    ds.p_date = '${date}'
                    and ds.should_delevry_type != '非当日应派'
                group by 1,2
            ) a1
        left join
            (
                select
                    hsi.sys_store_id
                    ,count(distinct if(hsi.job_title in (13,110,452,1497) and sup1.staff_info_id is null, hsi.staff_info_id, null)) courier_count
                    ,count(distinct if(hsi.job_title in (37,451) and sup1.staff_info_id is null, hsi.staff_info_id, null)) dco_count
                from bi_pro.hr_staff_info hsi
                join backyard_pro.staff_work_attendance swa on swa.staff_info_id = hsi.staff_info_id and swa.attendance_date = '${date}' and ( swa.started_at is not null or swa.end_at is not null)
                left join sup sup1 on sup1.sub_staff_info_id = hsi.staff_info_id
                group by 1
            ) a2 on a2.sys_store_id = a1.store_id
        left join
            (
                select
                    s1.store_id
                    ,count(if(s1.job_title_id in (13,110,452,1497), s1.staff_info_id, null)) sup_courier_count
                    ,count(if(s1.job_title_id in (37,451), s1.staff_info_id, null)) sup_dco_count
                from sup s1
                group by 1
            ) a3 on a3.store_id = a1.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct ds.pno) ds_count
                    ,count(distinct if(pr.pno is not null , ds.pno, null)) sort_count
                    ,count(distinct if(pr.pno is not null , ds.pno, null))/count(distinct ds.pno) sort_rate
                from dwm.dwd_th_dc_should_be_delivery ds
                left join rot_pro.parcel_route pr on pr.pno = ds.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= date_sub('${date}', interval 7 hour) and pr.routed_at < date_add('${date}', interval 17 hour)
                group by 1
            ) a4 on a4.dst_store_id = a1.store_id
        left join
            (
                select
                    ds.dst_store_id
                    ,count(distinct if(hsi.staff_info_id is not null and hsi.job_title in (13,110,452,1497), ds.pno, null))/count(distinct if(hsi.staff_info_id is not null and hsi.job_title in (13,110,452,1497), pi.ticket_delivery_staff_info_id, null)) self_effect
                    ,count(distinct if(s1.sub_staff_info_id is not null and s1.job_title_id in (13,110,452,1497), ds.pno, null))/count(distinct if(s1.sub_staff_info_id is not null and s1.job_title_id in (13,110,452,1497), pi.ticket_delivery_staff_info_id, null)) other_effect
                from dwm.dwd_th_dc_should_be_delivery ds
                join fle_staging.parcel_info pi on pi.pno = ds.pno
                left join sup s1 on s1.store_id = ds.dst_store_id and pi.ticket_delivery_staff_info_id = s1.sub_staff_info_id
                left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id and hsi.formal = 1 and hsi.is_sub_staff = 0 and hsi.sys_store_id = ds.dst_store_id
                where
                    pi.state = 5
                    and pi.finished_at >= date_sub('${date}', interval 7 hour)
                    and pi.finished_at < date_add('${date}', interval 17 hour)
                    and pi.returned = 0
                group by 1
            ) a5 on a5.dst_store_id = a1.store_id
        left join dwm.dim_th_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
    ) t1
left join
    (
        select
            dt.region_name 大区
            ,dt.piece_name 片区
            ,dt.store_name 来源网点
            ,dt2.store_name 支援网点
            ,s1.staff_info_id 主账号
            ,s1.sub_staff_info_id 子账号
            ,hjt2.job_name 原岗位
            ,hjt.job_name  'van/bike'
            ,convert_tz(swa.started_at, '+00:00', '+07:00') 上班时间
            ,convert_tz(swa.end_at, '+00:00', '+07:00') 下班时间
            ,s3.pick_num 揽收量
            ,s2.scan_count 交接量
            ,s2.del_count 妥投量
            ,timestampdiff(minute , fir.finished_at, las.finished_at )/60 派送时长
            ,code.scan_code_count 交接三段码数量
            ,code.del_code_num 妥投三段码数量
            ,pho.0_count 未妥投中打电话次数为0的数量
            ,pho.1_count 未妥投中打电话次数为1的数量
        from sup s1
        left join dwm.dim_th_sys_store_rd dt on dt.store_id = s1.staff_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.dim_th_sys_store_rd dt2 on dt2.store_id = s1.store_id and dt2.stat_date = date_sub(curdate(), interval 1 day)
        left join bi_pro.hr_job_title hjt on hjt.id = s1.job_title_id
        left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = s1.staff_info_id
        left join bi_pro.hr_job_title hjt2 on hjt2.id = hsi2.job_title
        left join backyard_pro.staff_work_attendance swa on swa.staff_info_id = s1.sub_staff_info_id and swa.attendance_date = '${date}' and swa.organization_id = s1.store_id
        left join
            (
                select
                    t1.staff_info_id
                    ,count(distinct t1.pno) scan_count
                    ,count(if(t1.state = 5, t1.pno, null)) del_count
                from total t1
                group by 1
            ) s2 on s2.staff_info_id = s1.sub_staff_info_id
        left join
            (
                select
                    s1.sub_staff_info_id
                    ,count(distinct pi.pno) pick_num
                from fle_staging.parcel_info pi
                join sup s1 on s1.sub_staff_info_id = pi.ticket_pickup_staff_info_id
                where
                    pi.created_at >= date_sub('${date}', interval 7 hour)
                    and pi.created_at < date_add('${date}', interval 17 hour)
                group by 1
            ) s3 on s3.sub_staff_info_id = s1.sub_staff_info_id
        left join
            ( -- 第一次妥投时间
                select
                    t1.*
                    ,row_number() over (partition by t1.staff_info_id order by t1.finished_at ) rk
                from total t1
                where
                    t1.state = 5
            ) fir on fir.staff_info_id = s1.sub_staff_info_id and fir.rk = 1
        left join
            (
                select
                    t1.*
                    ,row_number() over (partition by t1.staff_info_id order by t1.finished_at desc ) rk
                from total t1
                where
                    t1.state = 5
            ) las on las.staff_info_id = s1.sub_staff_info_id and las.rk = 2
        left join
            (
                select
                    t1.staff_info_id
                    ,count(distinct t1.sorting_code) scan_code_count
                    ,count(distinct if(t1.state = 5, t1.sorting_code, null)) del_code_num
                from total t1
                where
                    t1.sorting_code not in ('XX', 'YY', 'ZZ', '00', '88')
                group by 1
            ) code on code.staff_info_id = s1.sub_staff_info_id
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
                        left join rot_pro.parcel_route pr on pr.pno = t.pno and pr.route_action = 'PHONE' and pr.routed_at >= date_sub('${date}', interval 7 hour) and pr.routed_at < date_add('${date}', interval 17 hour)
                        where
                            t.state != 5
                        group by 1,2
                    ) a
                group by 1
            ) pho on pho.staff_info_id = s1.sub_staff_info_id
    ) t2 on t2.支援网点 = t1.网点