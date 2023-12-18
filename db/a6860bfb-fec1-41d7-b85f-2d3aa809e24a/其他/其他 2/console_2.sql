select
    pr.pno
    ,convert_tz(pr1.routed_at, '+00:00', '+08:00') 标记时间
    ,json_extract(pr.extra_value, '$.callDuration') 通话时长
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 通话时间
from ph_staging.parcel_route pr
join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.extra_value
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-08-21 16:00:00'
            and pr.routed_at < '2023-08-22 16:00:00'
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category in (2,17)
    ) pr1 on pr1.pno = pr.pno
where
    pr1.routed_at > '2023-08-21 16:00:00'
    and pr1.routed_at < '2023-08-22 16:00:00'
    and pr1.routed_at > pr.routed_at
    and pr.route_action = 'PHONE'

;

    SELECT
    swa.stat_date
    ,hsi.staff_info_id
    ,swa.state_desc 状态描述
    ,case when swa.wait_leave_state in ('0') then '非待离职'
        when swa.wait_leave_state in ('1') then '待离职'
    else swa.wait_leave_state end as 是否待离职
    ,swa.attendance_started_at
    ,swa.attendance_end_at
    ,swa.attendance_hour   工作时长
    ,ROUND(time_to_sec(timediff(swa.shift_start,date_format(swa.attendance_started_at,"%H:%i:%s"))) /60,2) 迟到时长
    ,case when swa.is_plan_rest = 1 then '排休无需打卡'
        when  swa.is_plan_rest = 0 and swa.attendance_started_at is null then '无上班打卡时间'
        when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 59 then '未迟到'
        when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 359 then '迟到5min内'
        when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 659 then '迟到5-10min'
        when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 959 then '迟到10-15min'
        when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 1259 then '迟到15-20min'
        when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 1559 then '迟到20-25min'
        when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 1859 then '迟到25-30min'
    else '迟到30min以上' end as 迟到情况
    ,case when swa.is_outsource = 1 then '是' else '否' end as 是否外协
    ,case when swa.is_plan_rest = 1 then '是' else '否' end as 是否排休
    ,swa.hire_days 在职天数
    ,swa.job_title_desc 岗位描述
    ,hsi.mobile 员工手机号
    ,DATEDIFF(swa.stat_date,hsi.hire_date) 工龄
    ,swa.store_id as           归属网点ID
    ,swa.store_name as         归属网点名称
    ,swa.store_category_desc as 网点类型描述
    ,swa.region_name as        归属大区
    ,swa.piece_name as          归属片区
    ,swa.formal as             员工的属性
    ,CASE
        WHEN hsi.job_title = 13  THEN 'Bike'
        WHEN hsi.job_title = 110 THEN 'VAN'
        WHEN hsi.job_title = 452 THEN 'Boat'
        WHEN hsi.job_title = 1000 THEN 'Tricycle'
        WHEN hsi.job_title = 37  THEN '仓管'
        WHEN hsi.job_title = 16  THEN '主管'
    END AS 当日岗位
    ,ss.name 当日所属网点
    ,ss.id store_id
    ,CASE
        WHEN ss.category = 1  THEN 'SP'
        WHEN ss.category = 10 THEN 'BDC'
        WHEN ss.category = 14  THEN 'PDC'
    END 网点类型
    ,smr.name 大区
    ,smp.name 片区
    ,CASE WHEN hsi.formal = 0 THEN '外协员工'
          when hsi.sys_store_id = ss.id then '自有员工'
          when hsi.sys_store_id <> ss.id THEN '支援员工'
          END AS 员工属性

    ,lanshou.揽件量
    ,jiaojie.交接量
    ,tuotou.当天派件数
    ,pp.拒收包裹数
    ,pp.运力不足包裹数
    ,pp.改约包裹数
    ,pp.客户不在家_电话无人接听包裹数
    ,pp.收件人号码空号包裹数
    ,pp.收件人号码错误包裹数
    ,pp.收件人地址不清晰或不正确包裹数
    ,pp.货物丢失包裹数
    ,pp.货物短少包裹数
    ,pp.货物破损包裹数
    ,pp.外包装破损包裹数
    ,pp.禁运品包裹数
    ,pp.其他派件标记包裹数

    ,IF(tuotou.当天派件数=1,TIMESTAMPDIFF(MINUTE,tuotou.finished_min,tuotou.finished_max),ROUND(TIMESTAMPDIFF(MINUTE,tuotou.finished_min,tuotou.finished_max) / (tuotou.当天派件数-1),2)) '派件间隔(分钟)'
    ,ROUND(tuotou.当天派件数 / jiaojie.交接量,2) '派件/交接'
    ,jiaojie.'交接5KG以上'
    ,tuotou.'妥投5KG以上'
    ,tuotou.tuotou_num_50 as '网点50米内派件量'
    ,jiaojie.delivery_min 最早交接时间
    ,jiaojie.delivery_max 最近交接时间
    ,ROUND(TIMESTAMPDIFF(MINUTE,jiaojie.delivery_min,jiaojie.delivery_max)/60,2) '交接工作时间'
    ,tuotou.finished_min  最早派件时间
    ,tuotou.finished_max  最近派件时间
    ,ROUND(TIMESTAMPDIFF(MINUTE,tuotou.finished_min,tuotou.finished_max)/60,2) '派件工作时间'
    ,lanshou.created_min  最早揽件时间
    ,lanshou.created_max  最近揽件时间
    ,ROUND(TIMESTAMPDIFF(MINUTE,lanshou.created_min,lanshou.created_max)/60,2) '揽件工作时间'


    FROM ph_bi.hr_staff_info hsi

    ##left join ph_backyard.staff_work_attendance swa
    ##on swa.staff_info_id=hsi.staff_info_id
    ##and swa.attendance_date = date(convert_tz(now(),'+08:00','+08:00'))


    left join dwm.dws_ph_staff_wide_s swa
    on swa.staff_info_id=hsi.staff_info_id

    left join ph_staging.sys_store ss
    on ss.category in (1,10)
    ##on swa.started_store_id = ss.id

    left join ph_staging.sys_manage_piece smp
    on smp.id=ss.manage_piece

    left join ph_staging.sys_manage_region smr
    on smr.id=ss.manage_region

    left join
    (
        select
            pi.dst_store_id ##目的地网点
            ,td2.staff_info_id
            ,date(convert_tz(td2.created_at,'+00:00','+08:00')) as created_dt
            ,COUNT(DISTINCT td2.pno) '交接量'
            ,COUNT(DISTINCT CASE WHEN (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 OR pi.exhibition_weight > 5000) THEN td2.pno ELSE NULL END)'交接5KG以上'
            ##,MIN(DATE_FORMAT(convert_tz(td2.created_at,'+00:00','+08:00'),'%T')) AS delivery_min ##最早交接时间
            ##,MAX(DATE_FORMAT(convert_tz(td2.created_at,'+00:00','+08:00'),'%T')) AS delivery_max ##最近交接时间
            ,MIN(convert_tz(td2.created_at,'+00:00','+08:00')) AS delivery_min ##最早交接时间
            ,MAX(convert_tz(td2.created_at,'+00:00','+08:00')) AS delivery_max ##最近交接时间

        ##FROM tmpale.parcel_in_warehouse_today dsdt
        ##JOIN  ph_staging.ticket_delivery td2
        from ph_staging.ticket_delivery td2
        left join ph_staging.parcel_info pi
        ON pi.pno = td2.pno
        WHERE 1=1
            ##and date(convert_tz(td2.created_at,'+00:00','+08:00')) >='${sdate}'
            ##and date(convert_tz(td2.created_at,'+00:00','+08:00')) <='${edate}'
            and td2.created_at >= date_sub('${sdate}', interval 8 hour )
            and td2.created_at < date_sub(date_add('${edate}', interval 1 day ), interval 8 hour )
            ##td2.delivery_at >= convert_tz(DATE(convert_tz(NOW(),'+08:00','+08:00')),'+08:00','+00:00')
            ##AND td2.created_at < convert_tz(DATE_ADD(DATE(convert_tz(NOW(),'+08:00','+08:00')),INTERVAL 1 DAY),'+08:00','+00:00')
            AND td2.state <> 3 # stata=3(已关闭)
        GROUP BY 1,2,3
    ) jiaojie # 交接量
    ON jiaojie.staff_info_id = hsi.staff_info_id and jiaojie.dst_store_id =  ss.id and swa.stat_date = jiaojie.created_dt

    LEFT JOIN
    (
        SELECT
            pi.dst_store_id
            ,pi.ticket_delivery_staff_info_id
            ,date(convert_tz(pi.finished_at,'+00:00','+08:00')) as finished_dt
            ,MIN((convert_tz(pi.finished_at,'+00:00','+08:00')))  AS finished_min ##派件开始时间
            ,MAX((convert_tz(pi.finished_at,'+00:00','+08:00')))  AS finished_max ##派件结束时间
            ,COUNT(DISTINCT if(ROUND(st_distance_sphere(point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat), point(ss.lng,ss.lat)),0) < 50,pi.pno,null))  as tuotou_num_50
            ,IFNULL(COUNT(DISTINCT pi.pno),0) '当天派件数'
            ,COUNT(DISTINCT CASE WHEN (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 OR pi.exhibition_weight > 5000) THEN pi.pno ELSE NULL END)'妥投5KG以上'
            ##,CASE WHEN ROUND(st_distance_sphere(point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat), point(ss.lng,ss.lat)),0) >= 50 THEN MIN((convert_tz(pi.finished_at,'+00:00','+08:00'))) END AS 派件开始时间
            ##,CASE WHEN ROUND(st_distance_sphere(point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat), point(ss.lng,ss.lat)),0) >= 50 THEN MAX((convert_tz(pi.finished_at,'+00:00','+08:00'))) END AS 派件结束时间

        ##FROM tmpale.parcel_in_warehouse_today dsdt  ##在仓表

        from ph_staging.parcel_info pi
        ##ON dsdt.pno = pi.pno

        LEFT JOIN ph_staging.sys_store ss
        on ss.id = pi.dst_store_id

        WHERE  1=1
            ##and dsdt.stat_date = date(convert_tz(now(),'+08:00','+08:00'))
            ##and date(dsdt.stat_date) >='${sdate}'
            ##and date(dsdt.stat_date) <='${edate}'
            ##and date(convert_tz(pi.finished_at,'+00:00','+08:00')) >='${sdate}'
            ##and date(convert_tz(pi.finished_at,'+00:00','+08:00')) <='${edate}'
            and pi.finished_at >= date_sub('${sdate}', interval 8 hour )
            and pi.finished_at < date_sub(date_add('${edate}', interval 1 day ), interval 8 hour )
            and pi.state in ('5')
        GROUP BY 1,2,3
    )tuotou # 妥投
    ON tuotou.ticket_delivery_staff_info_id = hsi.staff_info_id and tuotou.dst_store_id = ss.id and swa.stat_date = tuotou.finished_dt

    LEFT JOIN
    (
        SELECT
            pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
            ,date(convert_tz(pi.created_at,'+00:00','+08:00')) as created_at
            ,COUNT(DISTINCT(pi.pno))  '揽件量'
            ,MIN((convert_tz(pi.created_at,'+00:00','+08:00'))) AS created_min ##揽件开始时间
            ,MAX((convert_tz(pi.created_at,'+00:00','+08:00'))) AS created_max ##揽件结束时间

        FROM ph_staging.parcel_info pi

        WHERE 1=1
            and pi.state <> 9
            and pi.returned = 0
            ##and pi.created_at >= convert_tz(DATE(convert_tz(NOW(),'+08:00','+08:00')) ,'+08:00','+00:00')
            ##AND pi.created_at < convert_tz(DATE_ADD(DATE(convert_tz(NOW(),'+08:00','+08:00')),INTERVAL 1 DAY) ,'+08:00','+00:00')
            ##and date(convert_tz(pi.created_at,'+00:00','+08:00')) >='${sdate}'
            ##and date(convert_tz(pi.created_at,'+00:00','+08:00')) <='${edate}'
            and pi.created_at >= date_sub('${sdate}', interval 8 hour )
            and pi.created_at < date_sub(date_add('${edate}', interval 1 day ), interval 8 hour )
        GROUP BY 1,2,3
    ) lanshou # 揽收量
    ON lanshou.ticket_pickup_staff_info_id = hsi.staff_info_id and lanshou.ticket_pickup_store_id = ss.id and swa.stat_date = lanshou.created_at

    LEFT JOIN
    (
        SELECT
            pi.dst_store_id
            ,pr.staff_info_id
            ,date(convert_tz(pr.routed_at,'+00:00','+08:00')) as routed_at
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (2)    THEN pr.pno ELSE NULL END)) 拒收包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (70) THEN pr.pno ELSE NULL END)) 改约包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (71)   THEN pr.pno ELSE NULL END)) 运力不足包裹数
            ##,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (8,16)    THEN pr.pno ELSE NULL END)) 联系不上包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (1)    THEN pr.pno ELSE NULL END))  客户不在家_电话无人接听包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (78)   THEN pr.pno ELSE NULL END)) 收件人号码空号包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (75)   THEN pr.pno ELSE NULL END)) 收件人号码错误包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (73)   THEN pr.pno ELSE NULL END)) 收件人地址不清晰或不正确包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (7)    THEN pr.pno ELSE NULL END)) 货物丢失包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (6)    THEN pr.pno ELSE NULL END)) 货物短少包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (5)    THEN pr.pno ELSE NULL END)) 货物破损包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (4)    THEN pr.pno ELSE NULL END)) 外包装破损包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category IN (69)    THEN pr.pno ELSE NULL END)) 禁运品包裹数
            ,COUNT(DISTINCT (CASE WHEN pr.marker_category not IN (1,2,4,5,6,7,69,70,71,73,75,78)    THEN pr.pno ELSE NULL END)) 其他派件标记包裹数


        ##FROM tmpale.parcel_in_warehouse_today dsdt

        from ph_staging.parcel_route pr
        left join ph_staging.parcel_info pi
        ON pi.pno = pr.pno

        WHERE 1=1
            ##AND pr.marker_category IN (2,17,9,14,70,15,71,16,1,40,29,78,25,75,23,73,7,22,6,21,5,20,4,19) # 2 17拒收 9 14 70 改约 15 71 运力不足
            AND pr.route_action = 'DELIVERY_MARKER' #派件标记
            ##and date(convert_tz(pr.routed_at,'+00:00','+08:00')) >='${sdate}'
            ##and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <='${edate}'
            and pr.routed_at >= date_sub('${sdate}', interval 8 hour )
            and pr.routed_at < date_sub(date_add('${edate}', interval 1 day ), interval 8 hour )
            ##AND pr.routed_at >= convert_tz(DATE(convert_tz(NOW(),'+08:00','+08:00')),'+08:00','+00:00')
            ##AND pr.routed_at < convert_tz(DATE_ADD(DATE(convert_tz(NOW(),'+08:00','+08:00')),INTERVAL 1 DAY),'+08:00','+00:00')
        GROUP BY 1,2,3
    )pp #问题包裹数
    ON pp.staff_info_id = hsi.staff_info_id and pp.dst_store_id = ss.id and pp.routed_at = swa.stat_date

    WHERE 1=1
    AND (
            (
            DATE(swa.stat_date) between '${sdate}' and '${edate}' and hsi.sys_store_id = ss.id
            )
            or lanshou.揽件量 is not null
            or jiaojie.交接量 is not null
        )
    AND hsi.state = 1
    AND hsi.job_title IN (13,110,1000)
    AND ss.category IN (1,10,14) # 网点类型 1,10
    and swa.job_title IN (13,110,1000)


    ;









select
    a.pno
    ,convert_tz(a.min_route_time, '+00:00', '+08:00') 第一次标记成功时间
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 电话时间
    ,json_extract(pr.extra_value, '$.callDuration') 通话时长
    ,count(pr.routed_at) over (partition by a.pno) 该单号尝试拨打次数
from ph_staging.parcel_route pr
join
    (
        select
            pr.pno
            ,min(pr.routed_at) min_route_time
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-08-21 16:00:00'
            and pr.routed_at < '2023-08-22 16:00:00'
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category in (2,17)
        group by 1
    ) a on pr.pno = a.pno
where
    pr.route_action = 'PHONE'
    and pr.routed_at > '2023-08-21 16:00:00'
    and pr.routed_at < '2023-08-22 16:00:00'
    and pr.routed_at < a.min_route_time