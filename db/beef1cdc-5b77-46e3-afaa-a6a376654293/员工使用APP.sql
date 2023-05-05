SET hive.execution.engine=tez;
with t as
(
        SELECT
            *
           ,to_date(start_use_time) start_date
        FROM fle_dwd.dwd_drds_courier_equipment_di
        WHERE p_date>='2023-04-01' and p_date<'2023-05-01'
            AND
                (
                    LOWER(name) LIKE '%driver%'
        --               OR LOWER(name) LIKE '%kerry%'
                    OR  (lower(name) LIKE '%j&t%' and  lower(package_name) not LIKE '%client%')
                    OR LOWER(package_name) LIKE '%driver%'
                    OR LOWER(package_name) LIKE 'texpress%'
                    OR LOWER(package_name) LIKE '%kerry.logistics.kerryme%'
                    OR LOWER(name) LIKE 'grab driver'
                    OR LOWER(name) LIKE 'joyride x happy move driver'
                    OR LOWER(name) LIKE 'lalamove driver'
                    OR package_name = 'com.logistics.rider.foodpanda'
                    OR package_name = 'com.pickaroo.android'
                    OR package_name = 'com.habaltransport.habal'
                    OR LOWER(name) LIKE 'toktok driver'
                    OR LOWER(name) LIKE 'mrspeedy'
                    OR LOWER(name) LIKE '%habal%'
                )
--             and staff_info_id = '619414'
    )
SELECT
    t.staff_info_id,
    t0.job_name,
    t.device_code,
    t.device_model_number,
    t.name,
    t.package_name,
    t.version,
    cast(t.use_time as bigint)/60000 use_time_minute,
    t.start_use_time,
    t.end_use_time,
    t.start_date,
    t3.store_name,
    t3.piece_name,
    t3.region_name,
    t4.started_at,
    t4.end_at,
    case t4.working_day
        when '1' then '是'
        when '0' then '否'
    end workingday_or_not,
    if(t.start_use_time > t4.started_at and t.start_use_time < t4.end_at ,'考勤时间内', null) working_time_usingapp
    ,(unix_timestamp(t4.end_at) - unix_timestamp(t4.started_at) )/3600 working_time
    ,coalesce(t5.pick_num,0) pick_num
    ,coalesce(t6.del_num,0) del_num
    ,coalesce(t5.pick_num,0) + coalesce(t6.del_num,0) total_num
    ,useday.use_day
FROM t
JOIN
    (
        SELECT *
        FROM fle_dim.dim_backyard_hr_staff_info_da
        WHERE p_date='2023-04-30'
            AND is_sub_staff='0'
            AND formal='1'
    ) t2
    ON t.staff_info_id=t2.staff_info_id
left join
    (
        select
            *
        from fle_dim.dim_bi_hr_job_title_da  hjt
        where
            hjt.p_date = '2023-04-30'
    ) t0
    on t2.job_title = t0.id
LEFT JOIN
    (
        SELECT
            tt1.id,
            tt1.name AS store_name,
            tt1.manage_piece,
            tt2.name AS piece_name,
            tt1.manage_region,
            tt3.name AS region_name
        FROM
            (
                SELECT *
                FROM fle_dim.dim_fle_sys_store_da
                WHERE p_date='2023-04-30'
            )tt1
        LEFT JOIN
            (
                SELECT *
                FROM fle_dim.dim_fle_sys_manage_piece_da
                WHERE p_date='2023-04-30'
            ) tt2
            ON tt1.manage_piece=tt2.id
       LEFT JOIN
            (
                SELECT *
                FROM fle_dim.dim_fle_sys_manage_region_da
                WHERE p_date='2023-04-30'
            ) tt3
            ON tt1.manage_region=tt3.id
    )t3 ON t2.sys_store_id=t3.id
left join
    (
        select
            swa.staff_info_id
            ,swa.started_at
            ,swa.end_at
            ,swa.attendance_date
            ,swa.working_day
        from fle_dwd.dwd_backyard_staff_work_attendance_di swa
        where
            swa.p_date between '2023-04-01' and '2023-04-30'
    )t4 on t.start_date = t4.attendance_date and t.staff_info_id = t4.staff_info_id
left join
    (
        select
            to_date(pi.created_at) pick_date
            ,pi.ticket_pickup_staff_info_id
            ,count(pi.pno)  pick_num
        from fle_dwd.dwd_fle_parcel_info_di pi
        join
            (
                select
                    t.staff_info_id
                from t
                group by t.staff_info_id
            ) b
            on pi.ticket_pickup_staff_info_id = b.staff_info_id
        where
            pi.p_date between '2023-04-01' and '2023-04-30'
        group by
            to_date(pi.created_at)
            ,pi.ticket_pickup_staff_info_id
    ) t5 on t.start_date = t5.pick_date and t.staff_info_id = t5.ticket_pickup_staff_info_id
left join
    (
        select
            to_date(pi.finished_at) fin_date
            ,pi.ticket_delivery_staff_info_id
            ,count(pi.pno)  del_num
        from fle_dwd.dwd_fle_parcel_info_di pi
        join
            (
                select
                    t.staff_info_id
                from t
                group by t.staff_info_id
            ) b
            on pi.ticket_delivery_staff_info_id = b.staff_info_id
        where
            pi.p_date > '2022-12-01'
            and pi.state = '5'
            and pi.finished_at >= '2023-04-01'
            and pi.finished_at < '2023-05-01'
        group by
            to_date(pi.finished_at)
            ,pi.ticket_delivery_staff_info_id
    ) t6 on t.start_date = t6.fin_date and t.staff_info_id = t6.ticket_delivery_staff_info_id
left join
    (
        select
            t.staff_info_id
            ,count(distinct t.start_date) use_day
        from t
        group by t.staff_info_id
    ) useday
    on t.staff_info_id = useday.staff_info_id

