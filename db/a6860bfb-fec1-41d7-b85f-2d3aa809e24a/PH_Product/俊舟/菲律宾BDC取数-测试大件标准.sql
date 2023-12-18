
-- 方案 1
select
    date(convert_tz(pi.created_at, '+00:00', '+08:00')) 揽收日期
    ,count(if(pi.exhibition_weight > 3000 or pi.exhibition_height + pi.exhibition_length + pi.exhibition_width > 80, pi.pno, null)) 大件包裹数
from ph_staging.parcel_info pi
where
    pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-11-08 16:00:00'
    and pi.dst_store_id in ('PH18060800','PH18061R03','PH18061R05','PH18061R06','PH18060100','PH18061R04','PH18040104')
group by 1
order by 1 desc

;
-- 方案 2
select
    date(convert_tz(pi.created_at, '+00:00', '+08:00')) 揽收日期
    ,count(if(pi.exhibition_weight > 5000 or pi.exhibition_height + pi.exhibition_length + pi.exhibition_width > 80, pi.pno, null)) 大件包裹数
from ph_staging.parcel_info pi
where
    pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-11-08 16:00:00'
    and pi.dst_store_id in ('PH18060800','PH18061R03','PH18061R05','PH18061R06','PH18060100','PH18061R04','PH18040104')
group by 1
order by 1 desc
;



select
    t.dst_province_code 目的省code
    ,t.dst_city_code 目的市code
    ,t.dst_district_code 目的乡code
    ,t.region_name 目的地网点所属大区
    ,t.piece_name 目的地网点所属片区
    ,t.store_name 目的地网点
    ,t.dst_store_id 目的地网点ID
    ,t3.pno_count '3kg-80cm'
    ,t4.pno_count '4kg-90cm'
    ,t5.pno_count '5kg-95cm'
    ,t6.pno_count '6kg-100cm'
    ,t7.pno_count '7kg-105cm'
    ,t8.pno_count '8kg-110cm'
    ,t9.pno_count '9kg-115cm'
    ,t10.pno_count '10kg-120cm'
from
    (
         select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
        group by 1,2,3,4,5,6,7
    ) t
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80)
                    or pi.exhibition_weight >= 3000
                )
        group by 1,2,3,4,5,6,7
    ) t3 on t3.dst_district_code = t.dst_district_code and t3.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 90)
                     or pi.exhibition_weight >= 4000
                )
        group by 1,2,3,4,5,6,7
    ) t4 on t4.dst_district_code = t.dst_district_code and t4.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 95)
                    or pi.exhibition_weight >= 5000
                )
        group by 1,2,3,4,5,6,7
    ) t5 on t5.dst_district_code = t.dst_district_code and t5.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 100)
                    or pi.exhibition_weight >= 6000
                )
        group by 1,2,3,4,5,6,7
    ) t6 on t6.dst_district_code = t.dst_district_code and t6.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 105)
                    or pi.exhibition_weight >= 7000
                )
        group by 1,2,3,4,5,6,7
    ) t7 on t7.dst_district_code = t.dst_district_code and t7.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 110)
                    or pi.exhibition_weight >= 8000
                )
        group by 1,2,3,4,5,6,7
    ) t8 on t8.dst_district_code = t.dst_district_code and t8.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 115)
                    or pi.exhibition_weight >= 9000
                )
        group by 1,2,3,4,5,6,7
    ) t9 on t9.dst_district_code = t.dst_district_code and t9.dst_store_id = t.dst_store_id
left join
    (
        select
            pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.dst_store_id
            ,count(pi.pno) pno_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 120)
                    or pi.exhibition_weight >= 10000
                )
        group by 1,2,3,4,5,6,7
    ) t10 on t10.dst_district_code = t.dst_district_code and t10.dst_store_id = t.dst_store_id

;


-- 揽收维度

select
    t.src_province_code 揽收省code
    ,t.src_city_code 揽收市code
    ,t.src_district_code 揽收乡code
    ,t.region_name 揽收网点所属大区
    ,t.piece_name 揽收网点所属片区
    ,t.store_name 揽收网点
    ,t.ticket_pickup_store_id 揽收网点ID
    ,t3.pi_count '3kg-60cm'
    ,t4.pi_count '4kg-70cm'
    ,t5.pi_count '5kg-80cm'
    ,t6.pi_count '6kg-85cm'
    ,t7.pi_count '7kg-90cm'
    ,t8.pi_count '8kg-95cm'
    ,t9.pi_count '9kg-100cm'
    ,t10.pi_count '10kg-105cm'
from
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
        group by 1,2,3,4,5,6,7
    ) t
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 60)
                    or pi.exhibition_weight >= 3000
                )
        group by 1,2,3,4,5,6,7
    ) t3 on t3.ticket_pickup_store_id = t.ticket_pickup_store_id and t3.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 70)
                    or pi.exhibition_weight >= 4000
                )
        group by 1,2,3,4,5,6,7
    ) t4 on t4.ticket_pickup_store_id = t.ticket_pickup_store_id and t4.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80)
                    or pi.exhibition_weight >= 5000
                )
        group by 1,2,3,4,5,6,7
    ) t5 on t5.ticket_pickup_store_id = t.ticket_pickup_store_id and t5.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 85)
                    or pi.exhibition_weight >= 6000
                )
        group by 1,2,3,4,5,6,7
    ) t6 on t6.ticket_pickup_store_id = t.ticket_pickup_store_id and t6.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 90)
                    or pi.exhibition_weight >= 7000
                )
        group by 1,2,3,4,5,6,7
    ) t7 on t7.ticket_pickup_store_id = t.ticket_pickup_store_id and t7.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 95)
                    or pi.exhibition_weight >= 8000
                )
        group by 1,2,3,4,5,6,7
    ) t8 on t8.ticket_pickup_store_id = t.ticket_pickup_store_id and t8.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 100)
                    or pi.exhibition_weight >= 9000
                )
        group by 1,2,3,4,5,6,7
    ) t9 on t9.ticket_pickup_store_id = t.ticket_pickup_store_id and t9.src_district_code  = t.src_district_code
left join
    (
        select
            pi.src_province_code
            ,pi.src_city_code
            ,pi.src_district_code
            ,dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,pi.ticket_pickup_store_id
            ,count(pi.pno) pi_count
        from ph_staging.parcel_info pi
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
        where
            pi.created_at > '2023-10-31 16:00:00'
            and pi.state < 9
            and
                (
                    (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 105)
                    or pi.exhibition_weight >= 10000
                )
        group by 1,2,3,4,5,6,7
    ) t10 on t10.ticket_pickup_store_id = t.ticket_pickup_store_id and t10.src_district_code  = t.src_district_code