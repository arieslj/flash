with sup as
(
    select
        hsa.store_id
        ,hsa.store_name
        ,hsa.store_piece
        ,hsa.store_region
        ,hsa.staff_info_id
        ,hsa.staff_store_id
        ,hsa.job_title_id
    from ph_backyard.hr_staff_apply_support_store hsa
    where
        hsa.actual_begin_date <= '${date}'
        and coalesce(hsa.actual_end_date, curdate()) >= '${date}'
)
select
    *
from
    ( -- 应派妥投
        select
            ss.store_region
            ,ss.store_piece
            ,ss.store_name
            ,count(distinct ds.pno) today_should_del
            ,count(distinct if(pi.state = 5 and pi.finished_at >= date_sub('${date}', interval 8 hour) and pi.finished_at < date_add('${date}', interval  16 hour), ds.pno, null)) today_already_del
            ,count(distinct if(pi.state != 5 and ( pi.exhibition_weight > 5000 or pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 ), ds.pno, null)) no_del_big_count
        from dwm.dwd_ph_dc_should_be_delivery ds
        left join ph_staging.parcel_info pi on ds.pno = pi.pno
        join
            (
                select
                    sup.store_id
                    ,sup.store_name
                    ,sup.store_piece
                    ,sup.store_region
                from sup
                group by 1,2,3,4
            ) ss on ss.store_id = ds.dst_store_id
        where
            ds.p_date = '${date}'
            and ds.should_delevry_type != '非当日应派'
        group by 1,2,3
    ) a1
left join
    (
        select
            *
        from
    ) a2




















;

   (
        select
            hsi.sys_store_id
            ,count(distinct hsi.staff_info_id) staff_num
        from ph_bi.hr_staff_info hsi
        where
            hsi.formal = 1
            and hsi.state = 1
            and hsi.job_title in (13,110,1000)
        group by 1
    ) hsi on hsi.sys_store_id =