select
    t.*
from
    (SELECT
        smr.staff_info_id
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,smr.mileage_date 里程日期
        ,smr.url 视频链接
        ,(sm.`end_kilometres`-sm.`start_kilometres`)*0.001 里程数
    FROM `backyard_pro`.`staff_mileage_record_attachment` smr
    LEFT JOIN `backyard_pro`.`staff_mileage_record` sm on sm.`staff_info_id` =smr.staff_info_id and smr.mileage_date=sm.mileage_date
    LEFT JOIN `bi_pro`.`hr_staff_info` hr on hr.`staff_info_id` =smr.`staff_info_id`
    LEFT JOIN `fle_staging`.`sys_store` st on sm.`store_id` =st.`id`
    LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
    LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
    where smr.type= 2
    -- 每月1日发上个月16-月末的数据；每月16日发1-15的数据
#     and smr.mileage_date>=if(extract(day from now())=1,date_add(date_sub(CURRENT_date,interval 1 month),interval 15 day),date_sub(CURRENT_date,interval 15 day))
#     and smr.mileage_date<CURRENT_date
    and smr.mileage_date >= '2023-11-01'
    and smr.mileage_date < '2023-12-01'
    and smr.url is not null
    ORDER BY smr.staff_info_id,smr.mileage_date
    )t where t.里程数>=200

;



SELECT
    ss.员工
    ,ss.网点名称
    ,ss.大区
    ,ss.片区
    ,ss.上上月日均里程数
    ,s.上月日均里程数
    ,ss.上上月日均妥投件数
    ,s.上月日均妥投件数
    ,st.网点人数变化幅度
    ,(s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数 人效变化幅度
    ,(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数 里程变化幅度
FROM
    (
    -- 上上月明细
    SELECT
        sm.员工
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id` 员工
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `backyard_pro`.`staff_mileage_record` sm
        LEFT JOIN `backyard_pro`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `bi_pro`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `fle_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `bi_pro`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN dwm.`dwd_hr_staff_info_detail` hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.date_id=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-10-01'
            and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.员工
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id` 员工
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `backyard_pro`.`staff_mileage_record` sm
        LEFT JOIN `backyard_pro`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `bi_pro`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `fle_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `bi_pro`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN dwm.`dwd_hr_staff_info_detail` hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.date_id=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.员工=s.员工
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `backyard_pro`.`staff_mileage_record` sm
            LEFT JOIN `backyard_pro`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `bi_pro`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `fle_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `bi_pro`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN dwm.`dwd_hr_staff_info_detail` hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.date_id=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-10-01'
            and sm.`mileage_date` < '2023-11-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `backyard_pro`.`staff_mileage_record` sm
            LEFT JOIN `backyard_pro`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `bi_pro`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `fle_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `bi_pro`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN dwm.`dwd_hr_staff_info_detail` hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.date_id=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
/*1. 快递员本月的日均里程和上月的日均里程做对比上涨超过30%；
2. 快递员的派件人效对比上月没有上涨超过20%；
3. 快递员所在网点的日均出勤van人数对比上月没有下降或下降不低于20%。
4. 当月里程>100公里*/
GROUP BY 1
;
with staff as
(
SELECT
    ss.staff_info_id

FROM
    (
    -- 上上月明细
    SELECT
        sm.staff_info_id
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id`
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `backyard_pro`.`staff_mileage_record` sm
        LEFT JOIN `backyard_pro`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `bi_pro`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `fle_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `bi_pro`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN dwm.`dwd_hr_staff_info_detail` hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.date_id=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-10-01'
            and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.staff_info_id
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id`
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `backyard_pro`.`staff_mileage_record` sm
        LEFT JOIN `backyard_pro`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `bi_pro`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `fle_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `bi_pro`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN dwm.`dwd_hr_staff_info_detail` hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.date_id=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.staff_info_id=s.staff_info_id
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `backyard_pro`.`staff_mileage_record` sm
            LEFT JOIN `backyard_pro`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `bi_pro`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `fle_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `bi_pro`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN dwm.`dwd_hr_staff_info_detail` hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.date_id=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-10-01'
            and sm.`mileage_date` < '2023-11-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `backyard_pro`.`staff_mileage_record` sm
            LEFT JOIN `backyard_pro`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `bi_pro`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `fle_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `bi_pro`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN dwm.`dwd_hr_staff_info_detail` hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.date_id=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
GROUP BY 1
)
SELECT
    sm.mileage_date 日期
    ,sm.staff_info_id 快递员
    ,st.`name` 网点名称
    ,mr.`name` 大区
    ,mp.`name` 片区
    ,hjt.job_name 职位
    ,convert_tz(sm.started_at,'+00:00','+07:00') 上班汇报时间
    ,sm.start_kilometres/1000 里程表开始数据
    ,sm.end_kilometres/1000 里程表结束数据
    ,sm.end_kilometres/1000-sm.start_kilometres/1000 当日里程数
    ,sd.day_count 妥投件数
    ,sd.pickup_par_cnt 揽收件数

FROM `backyard_pro`.`staff_mileage_record` sm
JOIN staff as s on sm.`staff_info_id`=s.`staff_info_id`
LEFT JOIN `backyard_pro`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
LEFT JOIN `fle_staging`.`sys_store` st on sm.`store_id` =st.`id`
LEFT JOIN `fle_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
LEFT JOIN dwm.`dwd_hr_staff_info_detail` hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.date_id=sm.mileage_date
left join bi_pro.hr_job_title hjt on  hd.job_title=hjt.id
left join dwm.dwd_th_inp_opt_staff_info_d sd on sd.staff_info_id=sm.`staff_info_id` and sm.mileage_date=sd.stat_date
where smr.`state` =1
and sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'