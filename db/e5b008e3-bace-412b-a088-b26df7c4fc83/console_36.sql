with staff_id as (
##快递员当日出勤情况
select
    v2.stat_date              ##日期
    ,v2.staff_info_id         ##工号
    ,mr.name manage_region              #归属大区
    ,mp.name manage_piece               ##归属片区
    ,v2.sys_store_id          ##归属网点id
    ,ss.name                  ##归属网点名称
    ,ss.category              ##网点类型
    ,v2.attendance_started_at ##上班打卡时间
    ,v2.attendance_end_at     ##下班打卡时间
    ,v2.shift_start           ##班次开始时间
    ,v2.shift_end             ##班次结束时间
    ##,case when v2.attendance_time + v2.BT + v2.BT_Y + v2.AB = 10 then '应出勤' else '无需出勤' end as plan##培训假删掉
    ,case when (v2.attendance_time + v2.BT + v2.BT_Y + v2.AB) > 0 then '应出勤' else '无需出勤' end as plan##培训假删掉
    ,v2.shift_id
    ,case when v2.AB = 10 then '缺勤一天'
        when v2.AB = 5 then '缺勤半天'
        when v2.AB = 0 then '全勤'
    else v2.AB end as is_AB
    ,case when (v2.attendance_time + v2.BT + v2.BT_Y + v2.AB) <= 0 then '排休无需打卡'
        when  (v2.attendance_time + v2.BT + v2.BT_Y + v2.AB) > 0 and v2.attendance_started_at is null then '无上班打卡时间'
        when timestampdiff(SECOND,CONCAT(v2.stat_date," ",v2.shift_start),v2.attendance_started_at) <= 59 then '未迟到'
        when timestampdiff(SECOND,CONCAT(v2.stat_date," ",v2.shift_start),v2.attendance_started_at) <= 359 then '迟到5min内'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 659 then '迟到5-10min'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 959 then '迟到10-15min'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 1259 then '迟到15-20min'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 1559 then '迟到20-25min'
        when timestampdiff(SECOND,CONCAT(v2.stat_date," ",v2.shift_start),v2.attendance_started_at) <= 1859 then '迟到5-30min'
    else '迟到30min以上' end as chidao_ty
from ph_bi.attendance_data_v2 v2##研发刘春华，黄华
left join ph_staging.sys_store ss on ss.id = v2.sys_store_id ##网点编码
left join ph_staging.sys_manage_piece mp on mp.id = ss.manage_piece ##管理片区
left join ph_staging.sys_manage_region mr on mr.id = ss.manage_region ##管理大区
where date(v2.stat_date) = date_sub(curdate(),interval 1 day)
group by v2.stat_date
    ,v2.staff_info_id
    ,mr.name                  ##作业大区
    ,mp.name                  ##作业片区
    ,v2.sys_store_id          ##作业网点id
    ,ss.name                  ##作业网点名称
    ,v2.attendance_started_at ##上班打卡时间
    ,v2.attendance_end_at     ##下班打卡时间
    ,v2.shift_start           ##班次开始时间
    ,v2.shift_end             ##班次结束时间
    ,v2.shift_id
    ,case when v2.AB = 10 then '缺勤一天'
        when v2.AB = 5 then '缺勤半天'
        when v2.AB = 0 then '全勤'
    else v2.AB end
    ,case when (v2.attendance_time + v2.BT + v2.BT_Y + v2.AB) <= 0 then '排休无需打卡'
        when  (v2.attendance_time + v2.BT + v2.BT_Y + v2.AB) > 0 and v2.attendance_started_at is null then '无上班打卡时间'
        when timestampdiff(SECOND,CONCAT(v2.stat_date," ",v2.shift_start),v2.attendance_started_at) <= 59 then '未迟到'
        when timestampdiff(SECOND,CONCAT(v2.stat_date," ",v2.shift_start),v2.attendance_started_at) <= 359 then '迟到5min内'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 659 then '迟到5-10min'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 959 then '迟到10-15min'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 1259 then '迟到15-20min'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 1559 then '迟到20-25min'
        when timestampdiff(SECOND,CONCAT(v2.stat_date," ",v2.shift_start),v2.attendance_started_at) <= 1859 then '迟到5-30min'
    else '迟到30min以上' end
)


,staff_absence as (
#近14天排班的一个情况
select t1.staff_info_id
    ,count(distinct if(t1.attendance_type in ('迟到30min以上'), t1.stat_date,null)) as late_30min
    ,count(distinct if(t1.is_AB in ('缺勤一天','缺勤半天'), t1.stat_date,null)) as absence
from (
select
    v2.stat_date              ##日期
    ,v2.staff_info_id         ##工号
    ,mr.name manage_region              #归属大区
    ,mp.name manage_piece               ##归属片区
    ,v2.sys_store_id          ##归属网点id
    ,ss.name                  ##归属网点名称
    ,ss.category              ##网点类型
    ,v2.attendance_started_at ##上班打卡时间
    ,v2.attendance_end_at     ##下班打卡时间
    ,v2.shift_start           ##班次开始时间
    ,v2.shift_end             ##班次结束时间
    ,case when v2.attendance_started_at is null then '无上班打卡时间'
        when timestampdiff(SECOND,CONCAT(v2.stat_date," ",v2.shift_start),v2.attendance_started_at) <= 1859 then '迟到30min以内'
    else '迟到30min以上' end as attendance_type#迟到情况
    ,case when v2.AB = 10 then '缺勤一天'
        when v2.AB = 5 then '缺勤半天'
        when v2.AB = 0 then '全勤'
    else v2.AB end as is_AB
    ,ROW_NUMBER() OVER (PARTITION by v2.staff_info_id order by v2.stat_date desc) as rn
from ph_bi.attendance_data_v2 v2##研发刘春华，黄华
left join ph_staging.sys_store ss on ss.id = v2.sys_store_id ##网点编码
left join ph_staging.sys_manage_piece mp on mp.id = ss.manage_piece ##管理片区
left join ph_staging.sys_manage_region mr on mr.id = ss.manage_region ##管理大区
where date(v2.stat_date) >= date_sub(curdate(),interval 30 day)
    and date(v2.stat_date) <= date_sub(curdate(),interval 1 day)
    ##and v2.attendance_time + v2.BT + v2.BT_Y + v2.AB = 10 ##排班应出勤
    and (v2.attendance_time + v2.BT + v2.BT_Y + v2.AB) > 0
    and v2.job_title in (13,110,1000)
    and v2.state in (1)
    ##and hi.staff_info_id in ('118890','363229')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13
)t1
where t1.rn <= 14
group by 1
)

,ticket_delivery_min5 as (
##前五件的时间
select n1.staff_info_id
    ,max(case when n1.rn = 1 then n1.created_time else null end) as time_one
    ,max(case when n1.rn = 2 then n1.created_time else null end) as time_two
    ,max(case when n1.rn = 3 then n1.created_time else null end) as time_three
    ,max(case when n1.rn = 4 then n1.created_time else null end) as time_four
    ,max(case when n1.rn = 5 then n1.created_time else null end) as time_five
from
(
    select n.staff_info_id
        ,n.created_time
        ,ROW_NUMBER() OVER (PARTITION by n.staff_info_id order by n.created_time asc) as rn
    from (
    select td.staff_info_id,convert_tz(td.created_at,'+00:00','+08:00') as created_time
    from ph_staging.ticket_delivery td
    WHERE 1=1
        and td.created_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
        and td.created_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
        AND td.state <> 3 # stata=3(已关闭)
    GROUP BY 1,2
    )n
    group by 1,2
)n1
group by n1.staff_info_id
)


,delivery_percentage as (
##90%的包裹在两个小时之内交接完
##最早交接时间+2h时间内交接包裹量占总交接量的比例
#员工、交接时间、最早交接时间+2h，pno
#date_format(date_add(ft.arrive_time_first,interval 150 minute),'%H:%i')
select t2.staff_info_id
    ,t2.delivery_min
    ,t2.delivery_max
    ,count(distinct if(t2.created_time <= concat(date_format(date_sub(curdate(), interval 1 day),'%Y-%m-%d'),' 12:00:00'),t2.pno,null)) as 12_pnos
    ,count(distinct if(t2.created_time <= date_format(date_add(t2.delivery_min,interval 180 minute),'%Y-%m-%d %H:%i:%s'),t2.pno,null)) as 2h_pnos
    ,count(distinct t2.pno) as pnos
    ,round(count(distinct if(t2.created_time <= date_format(date_add(t2.delivery_min,interval 180 minute),'%Y-%m-%d %H:%i:%s'),t2.pno,null))/count(distinct t2.pno),2) 2h_percentage
    ,round(count(distinct if(t2.created_time <= concat(date_format(date_sub(curdate(), interval 1 day),'%Y-%m-%d'),' 12:00:00'),t2.pno,null))/count(distinct t2.pno),2) 12_percentage

from (

        select
            td.staff_info_id
            ,date(convert_tz(td.created_at,'+00:00','+08:00')) as created_dt
            ,convert_tz(td.created_at,'+00:00','+08:00') as created_time
            ,td.pno
            ,t1.delivery_min ##最早交接时间
            ,t1.delivery_max ##最晚交接时间

        from ph_staging.ticket_delivery td

        left join (
            select
                td.staff_info_id
                ,MIN(convert_tz(td.created_at,'+00:00','+08:00')) AS delivery_min ##最早交接时间
                ,MAX(convert_tz(td.created_at,'+00:00','+08:00')) AS delivery_max ##最晚交接时间

            from ph_staging.ticket_delivery td
            where 1=1
                and td.created_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
                and td.created_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
                AND td.state <> 3 # stata=3(已关闭)
            group by 1
        )t1
        on td.staff_info_id = t1.staff_info_id

        WHERE 1=1
            and td.created_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
            and td.created_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
            AND td.state <> 3 # stata=3(已关闭)
        GROUP BY 1,2,3,4,5,6
)t2
group by 1,2,3
)


,main as (

SELECT
*
,COUNT(tt.staff_info_id) over (PARTITION by tt.work_store_id) 网点当日派件人数
,ROW_NUMBER() OVER (PARTITION by tt.work_store_id order by tt.当天派件数 desc) 人效排名
from
(
    SELECT
    ##IFNULL(swa.attendance_date,DATE(convert_tz(NOW(),'+08:00','+08:00'))) 统计日期
    swa.stat_date
    ,swa.staff_info_id
    ,swa.staff_name
    ,swa.state_desc #状态描述
    ,case when swa.wait_leave_state in ('0') then '非待离职'
        when swa.wait_leave_state in ('1') then '待离职'
    else swa.wait_leave_state end as wait_leave_state #是否待离职
    ,swa.attendance_started_at #上班打卡时间
    ,swa.attendance_end_at     #下班打卡时间
    ,swa.attendance_hour       #工作时长
    ,ROUND(time_to_sec(timediff(swa.shift_start,date_format(swa.attendance_started_at,"%H:%i:%s"))) /60,2) 迟到时长
    ,case when swa.is_plan_rest = 1 then '排休无需打卡'
        when  swa.is_plan_rest = 0 and swa.attendance_started_at is null then '无上班打卡时间'
        when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 59 then '未迟到'
        when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 359 then '迟到5min内'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 659 then '迟到5-10min'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 959 then '迟到10-15min'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 1259 then '迟到15-20min'
        #when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 1559 then '迟到20-25min'
        when timestampdiff(SECOND,CONCAT(swa.stat_date," ",swa.shift_start),swa.attendance_started_at) <= 1859 then '迟到5-30min'
    else '迟到30min以上' end as 迟到情况
    ,case when swa.is_outsource = 1 then '是' else '否' end as is_outsource#是否外协
    ,case when swa.is_plan_rest = 1 then '是' else '否' end as is_plan_rest#是否排休
    ,swa.hire_days      #在职天数
    ,swa.job_title      #岗位
    ,swa.store_id       #归属网点ID
    ,swa.store_name     #归属网点名称
    ,swa.store_category_desc   #网点类型描述
    ,swa.region_name           #归属大区
    ,swa.piece_name            #归属片区
    ,tiktok_area.area_name tiktok_area
    ,swa.staff_attr
    ,case when swa.supply_store_id is null then swa.store_id else swa.supply_store_id end as work_store_id #当日所属网点
    ,case when swa.supply_store_id is not null then ss.name
        when swa.supply_store_id is null then swa.store_name
    end as work_store_name #当日所属网点

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


    ,swa.handover_par_cnt
    ,swa.handover_start_at
    ,swa.handover_end_at
    ,swa.handover_hour
    ,swa.delivery_par_cnt
    ,swa.delivery_start_at
    ,swa.delivery_end_at
    ,swa.delivery_hour
    ,swa.delivery_end_at2
    ,swa.delivery_hour2


    ##FROM ph_bi.hr_staff_info hsi

    ##left join ph_backyard.staff_work_attendance swa
    ##on swa.staff_info_id=hsi.staff_info_id
    ##and swa.attendance_date = date(convert_tz(now(),'+08:00','+08:00'))


    from dwm.dws_ph_staff_wide_s swa

    left join ph_bi.hr_staff_info hsi
    on swa.staff_info_id=hsi.staff_info_id

    left join ph_staging.sys_store ssd
    on swa.store_id = ssd.id

    left join ph_staging.sys_store ss
    on swa.supply_store_id = ss.id
    #on ss.category in (1,10) and
    ##on swa.started_store_id = ss.id

    left join ph_staging.sys_manage_piece smp
    on smp.id=ss.manage_piece

    left join ph_staging.sys_manage_region smr
    on smr.id=ss.manage_region

    left join
    (
        select distinct
            tiktok_area.dst_province_code province_code
            ,case tiktok_area.dst_area_code
                when 'MM' then 'MM'
                when 'GMA' then 'GMA'
                when 'LUZON 1' then 'Luz 1'
                when 'LUZON 2' then 'Luz 2'
                when 'LUZON 3' then 'Luz 3'
                when 'LUZON 4' then 'Luz 4'
                when 'MINDANAO 1' then 'Min 1'
                when 'MINDANAO 2' then 'Min 2'
                when 'VISAYAS 1' then 'Vis 1'
                when 'VISAYAS 2' then 'Vis 2'
            end area_name
        from dwm.dwd_ph_dict_tiktok_period_rules tiktok_area
    ) tiktok_area
    on ssd.province_code = tiktok_area.province_code

    left join
    (
        select
            td2.staff_info_id
            ,COUNT(DISTINCT td2.pno) '交接量'
            ,COUNT(DISTINCT CASE WHEN (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 OR pi.exhibition_weight > 5000) THEN td2.pno ELSE NULL END)'交接5KG以上'
            ##,MIN(DATE_FORMAT(convert_tz(td2.created_at,'+00:00','+08:00'),'%T')) AS delivery_min ##最早交接时间
            ##,MAX(DATE_FORMAT(convert_tz(td2.created_at,'+00:00','+08:00'),'%T')) AS delivery_max ##最近交接时间
            ,MIN(convert_tz(td2.created_at,'+00:00','+08:00')) AS delivery_min ##最早交接时间
            ,MAX(convert_tz(td2.created_at,'+00:00','+08:00')) AS delivery_max ##最近交接时间

        from ph_staging.ticket_delivery td2
        left join ph_staging.parcel_info pi
        ON pi.pno = td2.pno
        WHERE 1=1
            and td2.created_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
            and td2.created_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
            AND td2.state <> 3 # stata=3(已关闭)
        GROUP BY 1
    ) jiaojie # 交接量
    ON jiaojie.staff_info_id = hsi.staff_info_id

    LEFT JOIN
    (
        SELECT
            pi.ticket_delivery_staff_info_id
            ,date(convert_tz(pi.finished_at,'+00:00','+08:00')) as finished_dt
            ,MIN((convert_tz(pi.finished_at,'+00:00','+08:00')))  AS finished_min ##派件开始时间
            ,MAX((convert_tz(pi.finished_at,'+00:00','+08:00')))  AS finished_max ##派件结束时间
            ,COUNT(DISTINCT if(ROUND(st_distance_sphere(point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat), point(ss.lng,ss.lat)),0) < 50,pi.pno,null))  as tuotou_num_50
            ,IFNULL(COUNT(DISTINCT pi.pno),0) '当天派件数'
            ,COUNT(DISTINCT CASE WHEN (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 OR pi.exhibition_weight > 5000) THEN pi.pno ELSE NULL END) as 妥投5KG以上
            ##,CASE WHEN ROUND(st_distance_sphere(point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat), point(ss.lng,ss.lat)),0) >= 50 THEN MIN((convert_tz(pi.finished_at,'+00:00','+08:00'))) END AS 派件开始时间
            ##,CASE WHEN ROUND(st_distance_sphere(point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat), point(ss.lng,ss.lat)),0) >= 50 THEN MAX((convert_tz(pi.finished_at,'+00:00','+08:00'))) END AS 派件结束时间

        ##FROM tmpale.parcel_in_warehouse_today dsdt  ##在仓表

        from ph_staging.parcel_info pi
        ##ON dsdt.pno = pi.pno

        LEFT JOIN ph_staging.sys_store ss
        on ss.id = pi.dst_store_id

        WHERE  1=1
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
            and pi.finished_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
            and pi.state in ('5')
        GROUP BY 1
    )tuotou # 妥投
    ON tuotou.ticket_delivery_staff_info_id = hsi.staff_info_id

    LEFT JOIN
    (
        SELECT
            pi.ticket_pickup_staff_info_id
            ,date(convert_tz(pi.created_at,'+00:00','+08:00')) as created_at
            ,COUNT(DISTINCT(pi.pno))  '揽件量'
            ,MIN((convert_tz(pi.created_at,'+00:00','+08:00'))) AS created_min ##揽件开始时间
            ,MAX((convert_tz(pi.created_at,'+00:00','+08:00'))) AS created_max ##揽件结束时间

        FROM ph_staging.parcel_info pi

        WHERE 1=1
            and pi.state <> 9
            and pi.returned = 0
            and pi.created_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
            and pi.created_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
        GROUP BY 1
    ) lanshou # 揽收量
    ON lanshou.ticket_pickup_staff_info_id = hsi.staff_info_id

    LEFT JOIN
    (
        SELECT
            pr.staff_info_id
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
            AND pr.route_action = 'DELIVERY_MARKER' #派件标记
            and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
            and pr.routed_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
        GROUP BY 1
    )pp #问题包裹数
    ON pp.staff_info_id = hsi.staff_info_id

    WHERE 1=1
    AND DATE(swa.stat_date) = date_sub(curdate(),interval 1 day)
    AND swa.store_category IN (1,10,14) # 网点类型 1,10
    and hsi.state = 1
    and swa.job_title IN (13,110,1000)

)tt


)


, car_arrive  as (
##网点正班车到达时间
select date(ft.real_arrive_time) as proof_dt##日期
    ,ft.next_store_id
    ,ft.next_store_name
    ,ft33.plan_arrive_dt as plan_arrive_first##正班车第一趟计划到达时间
    ,ft11.real_arrive_time as arrive_time_first##正班车第一趟到达时间
    ,ft22.real_arrive_time as arrive_time_last##正班车最后一趟到达时间
    ,case when ft11.real_arrive_time = ft22.real_arrive_time then '只有一趟正班车' else '多趟正班车' end as proof_num
    ,case when date_format(ft11.real_arrive_time,'%H:%i') is null then '10:00'
          when date_format(ft11.real_arrive_time,'%H:%i') < '07:00' then '09:30'
          when date_format(ft11.real_arrive_time,'%H:%i') between '07:00' and '09:00' then date_format(date_add(ft11.real_arrive_time,interval 150 minute),'%H:%i')
          when date_format(ft11.real_arrive_time,'%H:%i') > '09:00' then '10:00'
    else '其他' end as min_tuotou_time

from (
        select next_store_id
            ,next_store_name
            ,real_arrive_time
            ,date(real_arrive_time) as real_arrive_dt
            ,proof_id
        from ph_bi.fleet_time
        where 1=1
            and line_mode =1##正班车
            and arrive_type in ('3','5')
            and fleet_status in ('1')
            and date(real_arrive_time) = date_sub(curdate(),interval 1 day)

) ft

left join
(##最早到达时间
    select ft1.next_store_id
        ,ft1.next_store_name
        ,ft1.real_arrive_time
        ,ft1.real_arrive_dt
        ,ft1.proof_id
        ,ft1.rn
    from
    (
        select next_store_id
            ,next_store_name
            ,real_arrive_time
            ,date(real_arrive_time) as real_arrive_dt
            ,proof_id
            ,row_number() over (partition by date(real_arrive_time),next_store_id,next_store_name order by real_arrive_time asc) as rn
        from ph_bi.fleet_time
        where 1=1
            and line_mode =1##正班车
            and arrive_type in ('3','5')
            and fleet_status in ('1')
            and date(real_arrive_time) = date_sub(curdate(),interval 1 day)
    )ft1
    where ft1.rn = 1
)ft11
on ft11.next_store_id = ft.next_store_id and ft11.real_arrive_dt = ft.real_arrive_dt
left join (
    ##最晚到达时间
    select ft2.next_store_id
        ,ft2.next_store_name
        ,ft2.real_arrive_time
        ,ft2.real_arrive_dt
        ,ft2.proof_id
        ,ft2.rn
    from (
        select next_store_id
            ,next_store_name
            ,real_arrive_time
            ,date(real_arrive_time) as real_arrive_dt
            ,proof_id
            ,row_number() over (partition by date(real_arrive_time),next_store_id,next_store_name order by real_arrive_time desc) as rn
        from ph_bi.fleet_time
        where 1=1
            and line_mode =1
            and arrive_type in ('3','5')
            and fleet_status in ('1')
            and date(real_arrive_time) = date_sub(curdate(),interval 1 day)
    )ft2
    where ft2.rn = 1
)ft22
on ft22.next_store_id = ft.next_store_id and ft22.real_arrive_dt = ft.real_arrive_dt

left join(
##第一趟正班车计划到达时间
    select ft1.next_store_id
        ,ft1.next_store_name
        ,ft1.plan_arrive_time
        ,ft1.plan_arrive_dt
        ,ft1.proof_id
        ,ft1.rn
    from
    (
        select next_store_id
            ,next_store_name
            ,plan_arrive_time
            ,date(plan_arrive_time) as plan_arrive_dt
            ,proof_id
            ,row_number() over (partition by date(plan_arrive_time),next_store_id,next_store_name order by plan_arrive_time asc) as rn
        from ph_bi.fleet_time
        where 1=1
            and line_mode =1##正班车
            and arrive_type in ('3','5')
            and fleet_status in ('1')
            and date(plan_arrive_time) = date_sub(curdate(),interval 1 day)
    )ft1
    where rn = 1

)ft33
on ft33.next_store_id = ft.next_store_id and ft33.plan_arrive_dt = ft.real_arrive_dt

where 1=1
    and date(ft.real_arrive_time) = date_sub(curdate(),interval 1 day)
    and ft11.real_arrive_time is not null
    and ft22.real_arrive_time is not null
group by 1,2,3,4,5,6,7,8
)


,staff_delivery_code as (
# 快递员绑定情况
select
    t.store_id
    ,t.name
    ,t.staff_info_id
    ,count(distinct t.delivery_code) 三段码绑定数量
    ,group_concat(distinct t.delivery_code SEPARATOR ' / ') 三段码绑定情况
    ,count(distinct t.district_code) barangay绑定数量
    ,group_concat(concat(t.delivery_code,':',t.barangay_name) order by t.delivery_code SEPARATOR ' / ') 绑定明细情况
from
    (
    select
        sdbsi.store_id # 网点id
        ,ss.name # 网点名称
        ,sdbsi.staff_info_id # 员工id
        ,sdbsi.delivery_code # 绑定的三段码
        ,sdbsi.district_code # 绑定的barangayID
        ,sd.name barangay_name # 绑定的barangay名称
    from ph_staging.store_delivery_barangay_staff_info sdbsi
    left join ph_staging.sys_district sd
    on sdbsi.district_code  = sd.code
    left join ph_staging.sys_store ss
    on sdbsi.store_id  = ss.id
    where 1=1
        and sdbsi.deleted = 0 # 非剔除记录
        and ss.category  = 1 # SP网点
    group by 1,2,3,4,5,6
    )t
group by 1,2,3
)


,handover_14days as (
##各区域近14天人均交接量
select m1.area_name
    ,m1.manage_region
    ,round(sum(avg_decnt)/14,0) per_capita_handover
    ,round((sum(avg_decnt)/14)*0.8,0) per_capita_h

from (
select
    date(convert_tz(td.created_at,"+00:00","+08:00")) stat_date
    ##,case when tiktok_area.area_name in ('MM') and mr.name in ('Area1') then 'MM_Area1'
    ##    when tiktok_area.area_name in ('GMA') and mr.name in ('Area1') then 'GMA_Area1'
    ##    when tiktok_area.area_name in ('Luz 3') and mr.name in ('Area1') then 'Luz3_Area1'
    ##else mr.name end as area
    ,tiktok_area.area_name
    ,mr.name manage_region
    ,COUNT(distinct td.pno)  pnos
    #,COUNT(DISTINCT CASE WHEN (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 OR pi.exhibition_weight > 5000) THEN dc.pno ELSE NULL END) delivery_5KG
    ,count(distinct td.staff_info_id ) staff_cut
    ,round(COUNT(distinct td.pno)/count(distinct td.staff_info_id ) ,0) avg_decnt
FROM ph_staging.ticket_delivery td

##left join ph_staging.ticket_delivery td
##on td.pno =dc.pno and dc.stat_date =date(convert_tz(td.delivery_at,"+00:00","+08:00")) and td.state in (0,1,2)

left join ph_staging.parcel_info pi
ON td.pno = pi.pno

left join ph_bi.sys_store ssd
on ssd.id = pi.dst_store_id

left join dwm.dwd_ph_dict_lazada_period_rules lazada_area
on ssd.province_code = lazada_area.province_code

left join ph_staging.shopee_period_limitation_rules_area shopee_area
on ssd.province_code = shopee_area.province_code

left join
(
    select distinct
        tiktok_area.dst_province_code province_code
        ,case tiktok_area.dst_area_code
            when 'MM' then 'MM'
            when 'GMA' then 'GMA'
            when 'LUZON 1' then 'Luz 1'
            when 'LUZON 2' then 'Luz 2'
            when 'LUZON 3' then 'Luz 3'
            when 'LUZON 4' then 'Luz 4'
            when 'MINDANAO 1' then 'Min 1'
            when 'MINDANAO 2' then 'Min 2'
            when 'VISAYAS 1' then 'Vis 1'
            when 'VISAYAS 2' then 'Vis 2'
        end area_name
    from dwm.dwd_ph_dict_tiktok_period_rules tiktok_area
) tiktok_area
on ssd.province_code = tiktok_area.province_code

LEFT JOIN ph_staging.sys_manage_region mr
ON ssd.manage_region = mr.id

LEFT JOIN ph_staging.sys_manage_piece mp
ON ssd.manage_piece = mp.id

left join ph_bi.hr_staff_info hsi
on td.staff_info_id = hsi.staff_info_id

where 1=1
    ##and date(dc.stat_date) >= date_sub(curdate(),interval 14 day)

    and td.created_at >= date_sub(date_sub(curdate(), interval 14 day), interval 8 hour )
    and td.created_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h

    and ssd.category =1 ##sp网点
    and mr.name not in ('FHome')
    and hsi.job_title in ('13','110','452','1000')
GROUP BY 1,2,3
)m1
group by 1,2
)


,finished_14days as (
##各区域近14天人均妥投量
select
    m1.tiktok_area as area_name
    ,m1.manage_region
    ,round(sum(avg_decnt)/14,0) per_capita_finished
    ,round((sum(avg_decnt)/14)*0.8,0) per_capita_f

from (
select
    date(convert_tz(pi.finished_at,'+00:00','+08:00')) as finished_dt
    ,mr.name manage_region
    ,tiktok_area.area_name tiktok_area
    ,count(distinct pi.pno) pnos
    ##,COUNT(DISTINCT CASE WHEN (pi.exhibition_length + pi.exhibition_width + pi.exhibition_height > 80 OR pi.exhibition_weight > 5000) THEN pi.pno ELSE NULL END) finished_5KG
    ,count(distinct pi.ticket_delivery_staff_info_id) staff_info_id
    ,round(COUNT(distinct pi.pno)/count(distinct pi.ticket_delivery_staff_info_id) ,0) avg_decnt

from ph_staging.parcel_info pi

left join ph_staging.sys_store ssd
on pi.dst_store_id = ssd.id

left join dwm.dwd_ph_dict_lazada_period_rules lazada_area
on ssd.province_code = lazada_area.province_code

left join ph_staging.shopee_period_limitation_rules_area shopee_area
on ssd.province_code = shopee_area.province_code

left join
(
    select distinct
        tiktok_area.dst_province_code province_code
        ,case tiktok_area.dst_area_code
            when 'MM' then 'MM'
            when 'GMA' then 'GMA'
            when 'LUZON 1' then 'Luz 1'
            when 'LUZON 2' then 'Luz 2'
            when 'LUZON 3' then 'Luz 3'
            when 'LUZON 4' then 'Luz 4'
            when 'MINDANAO 1' then 'Min 1'
            when 'MINDANAO 2' then 'Min 2'
            when 'VISAYAS 1' then 'Vis 1'
            when 'VISAYAS 2' then 'Vis 2'
        end area_name
    from dwm.dwd_ph_dict_tiktok_period_rules tiktok_area
) tiktok_area
on ssd.province_code = tiktok_area.province_code

LEFT JOIN ph_staging.sys_manage_region mr
ON ssd.manage_region = mr.id

LEFT JOIN ph_staging.sys_manage_piece mp
ON ssd.manage_piece = mp.id

left join ph_bi.hr_staff_info hsi
on pi.ticket_delivery_staff_info_id = hsi.staff_info_id

where 1=1
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 14 day), interval 8 hour )
    and pi.finished_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
    and ssd.category =1 ##sp网点
    and pi.state = 5
    and mr.name not in ('FHome')
    and hsi.job_title in ('13','110','452','1000')
group by 1,2,3
)m1
group by 1,2
)

,should_delivery as
(#网点人均可交接
    select
        date(dc.stat_date) stat_date
        ,dc.store_id
        ,ss.name
        ,COUNT(distinct dc.`pno`)  cnt
        ,count(distinct td.`staff_info_id` ) staff_cut
        ,round(COUNT(distinct dc.`pno`)/count(distinct td.`staff_info_id` ) ,0) avg_decnt
    ##FROM dwm.dwd_ph_dc_should_delivery_d dc
    from ph_bi.dc_should_delivery_today dc
    left join `ph_staging`.`ticket_delivery` td
    on td.`pno` =dc.`pno` and dc.`stat_date` =date(convert_tz(td.`delivery_at`,"+00:00","+08:00")) and td.`state`in (0,1,2)
    left join ph_bi.`sys_store` ss on ss.`id` =dc.`store_id`
    where dc.`stat_date` = date_sub(CURRENT_DATE ,interval 1 day)
        and ss.`category` =1
        and dc.`state` <6
    GROUP BY 1,2,3
)

,area_delivery as (
    select
    t1.员工ID
    ,t1.交接区域数量_all
    ,t1.交接区域数量
    ,t1.交接数_all
    ,t1.交接数
    ,t1.第二区域交接数
    ,t1.交接情况
    ,t2.妥投区域数量
    ,t2.妥投数
    ,t2.妥投情况
    from
    (
        select
            tt.员工ID
            ,count(distinct tt.三段码) 交接区域数量_all
            ,count(distinct if(tt.`交接包裹数` > 3,tt.三段码,null)) 交接区域数量
            ,sum(tt.交接包裹数) 交接数_all
            ,sum(if(tt.`交接包裹数` > 3,tt.交接包裹数,0)) as 交接数
            ,group_concat(concat(tt.网点名称,':',tt.三段码,':',tt.交接包裹数,'(',tt.当日在仓,')') order by tt.交接包裹数 desc SEPARATOR ' / ') 交接情况
            ,tt.第二区域交接数
        from
        (
            select
                date(convert_tz(td.created_at,'+00:00','+08:00')) as delivery_dt
                ,mr.name `大区`
                ,mp.name `片区`
                ,dsdt.dst_store_id
                ,ssd.name `网点名称`
                ,tiktok_area.area_name tiktok_area
                ,lazada_area.area_name lazada_area
                ,case shopee_area.area_id when 1 then 'MM'  when 2 then 'GMA '  when 3 then 'Luz 1'  when 4 then 'Luz 2'  when 5 then 'Luz 3' when 6 then 'Vis 1'  when 7 then 'Vis 2'  when 8 then 'Min 1'  when 9 then 'Min 2'  when 10 then 'Luz 4' end as shopee_area
                ,hsi.name `快递员姓名`
                ,td.staff_info_id `员工ID`
                ,if(hsi.job_title = 13,'BIKE',if(hsi.job_title = 110,'VAN',if(hsi.job_title = 452,'BOAT',if(hsi.job_title = 1000,'Tricycle','other')))) `快递员职位`
                ,ddpsci.third_sorting_code `三段码`
                ,sdmzc.当日在仓
                ,count(distinct td.pno) `交接包裹数`
                ,nth_value(count(distinct td.pno),2) over(partition by ssd.name,td.staff_info_id order by count(distinct td.pno) desc) 第二区域交接数

            from ph_staging.ticket_delivery td

            ##left join ph_staging.parcel_info pi
            ##on pi.pno = td.pno

            left join dwm.dwd_ph_non_end_pno_detl_d dsdt
            on td.pno = dsdt.pno

            left join
            (
                select
                    ddpsci.pno
                    ,ddpsci.third_sorting_code
                    ,row_number() over(partition by ddpsci.pno order by ddpsci.created_at desc) rk
                from ph_drds.parcel_sorting_code_info ddpsci
                where 1=1
                    and ddpsci.created_at >= date_sub(current_date(),91)
            ) ddpsci
            on dsdt.pno = ddpsci.pno and ddpsci.rk = 1

            left join ph_staging.sys_store ssd
            on dsdt.dst_store_id = ssd.id

            left join dwm.dwd_ph_dict_lazada_period_rules lazada_area
            on ssd.province_code = lazada_area.province_code

            left join ph_staging.shopee_period_limitation_rules_area shopee_area
            on ssd.province_code = shopee_area.province_code

            left join

            (
                select distinct
                    tiktok_area.dst_province_code province_code
                    ,case tiktok_area.dst_area_code
                        when 'MM' then 'MM'
                        when 'GMA' then 'GMA'
                        when 'LUZON 1' then 'Luz 1'
                        when 'LUZON 2' then 'Luz 2'
                        when 'LUZON 3' then 'Luz 3'
                        when 'LUZON 4' then 'Luz 4'
                        when 'MINDANAO 1' then 'Min 1'
                        when 'MINDANAO 2' then 'Min 2'
                        when 'VISAYAS 1' then 'Vis 1'
                        when 'VISAYAS 2' then 'Vis 2'
                    end area_name
                from dwm.dwd_ph_dict_tiktok_period_rules tiktok_area
            ) tiktok_area
            on ssd.province_code = tiktok_area.province_code

            LEFT JOIN ph_staging.sys_manage_region mr
            ON ssd.manage_region = mr.id

            LEFT JOIN ph_staging.sys_manage_piece mp
            ON ssd.manage_piece = mp.id

            left join ph_bi.hr_staff_info hsi
            on td.staff_info_id = hsi.staff_info_id

            left join
            (#网点各三段码在仓、已交接、积压
                SELECT
                    dsdt.stat_date
                    ,ssd.id `store_id`
                    ,ssd.name `网点名称`
                    ,ddpsci.third_sorting_code `区域编码`

                    ,count(dsdt.pno) '当日在仓'
                    ,count(case when dsdt.is_handover = 1 then dsdt.pno else null end)  `已交接量`
                    ,count(case when dsdt.state not in ('已签收','疑难件','已退件','异常关闭') then dsdt.pno else null end) `积压件量`

                FROM dwm.dwd_ph_non_end_pno_detl_d dsdt

                left join ph_staging.parcel_info pi
                on dsdt.pno = pi.pno

                left join
                (
                    select
                        ddpsci.pno
                        ,ddpsci.third_sorting_code
                        ,row_number() over(partition by ddpsci.pno order by ddpsci.created_at desc) rk
                    from ph_drds.parcel_sorting_code_info ddpsci
                    where 1=1
                        and ddpsci.created_at >= date_sub(current_date(),91)
                ) ddpsci
                on pi.pno = ddpsci.pno
                and ddpsci.rk = 1

                left join ph_staging.sys_store ssd
                on dsdt.dst_store_id = ssd.id

                where 1=1
                    and dsdt.stat_date  = date_sub(curdate(),interval 1 day)
                    and ssd.category in ('1','10')##SP  网点
                GROUP BY 1,2,3,4
                order by 1,2,3,4
            )sdmzc
            on sdmzc.store_id = ssd.id
            and sdmzc.区域编码 = ddpsci.third_sorting_code

            where 1=1
                and td.created_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
                and td.created_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
                and td.state <> 3
            group by 1,2,3,4,5,6,7,8,9,10,11,12,13
        ) tt
        group by 1
    ) t1

    left join

    (
        select
            tt.员工ID
            ,count(distinct tt.三段码) 妥投区域数量
            ,sum(tt.妥投包裹数) 妥投数
            ,group_concat(concat(tt.网点名称,':',tt.三段码,':',tt.妥投包裹数) order by tt.妥投包裹数 desc SEPARATOR ' / ') 妥投情况
        from
        (
            select date(convert_tz(pi.finished_at,'+00:00','+08:00')) as finished_dt
                ,mr.name `大区`
                ,mp.name `片区`
                ,ssd.sorting_no `分拣大区`
                ,dsdt.dst_store_id
                ,ssd.name `网点名称`
                ,tiktok_area.area_name tiktok_area
                ,lazada_area.area_name lazada_area
                ,case shopee_area.area_id when 1 then 'MM'  when 2 then 'GMA '  when 3 then 'Luz 1'  when 4 then 'Luz 2'  when 5 then 'Luz 3' when 6 then 'Vis 1'  when 7 then 'Vis 2'  when 8 then 'Min 1'  when 9 then 'Min 2'  when 10 then 'Luz 4' end as shopee_area
                ,hsi.name `快递员姓名`
                ,pi.ticket_delivery_staff_info_id `员工ID`
                ,if(hsi.job_title = 13,'BIKE',if(hsi.job_title = 110,'VAN',if(hsi.job_title = 452,'BOAT',if(hsi.job_title = 1000,'Tricycle','other')))) `快递员职位`
                ,ddpsci.third_sorting_code `三段码`
                ,count(distinct pi.pno) `妥投包裹数`

            from ph_staging.parcel_info pi

            left join dwm.dwd_ph_non_end_pno_detl_d dsdt
            on pi.pno = dsdt.pno

            left join
            (
                select
                    ddpsci.pno
                    ,ddpsci.third_sorting_code
                    ,row_number() over(partition by ddpsci.pno order by ddpsci.created_at desc) rk
                from ph_drds.parcel_sorting_code_info ddpsci
                where 1=1
                    and ddpsci.created_at >= date_sub(current_date(),91)
            ) ddpsci
            on dsdt.pno = ddpsci.pno and ddpsci.rk = 1

            left join ph_staging.sys_store ssd
            on dsdt.dst_store_id = ssd.id

            left join dwm.dwd_ph_dict_lazada_period_rules lazada_area
            on ssd.province_code = lazada_area.province_code

            left join ph_staging.shopee_period_limitation_rules_area shopee_area
            on ssd.province_code = shopee_area.province_code

            left join

            (
                select distinct
                    tiktok_area.dst_province_code province_code
                    ,case tiktok_area.dst_area_code
                        when 'MM' then 'MM'
                        when 'GMA' then 'GMA'
                        when 'LUZON 1' then 'Luz 1'
                        when 'LUZON 2' then 'Luz 2'
                        when 'LUZON 3' then 'Luz 3'
                        when 'LUZON 4' then 'Luz 4'
                        when 'MINDANAO 1' then 'Min 1'
                        when 'MINDANAO 2' then 'Min 2'
                        when 'VISAYAS 1' then 'Vis 1'
                        when 'VISAYAS 2' then 'Vis 2'
                    end area_name
                from dwm.dwd_ph_dict_tiktok_period_rules tiktok_area
            ) tiktok_area
            on ssd.province_code = tiktok_area.province_code

            LEFT JOIN ph_staging.sys_manage_region mr
            ON ssd.manage_region = mr.id

            LEFT JOIN ph_staging.sys_manage_piece mp
            ON ssd.manage_piece = mp.id

            left join ph_bi.hr_staff_info hsi
            on pi.ticket_delivery_staff_info_id = hsi.staff_info_id

            where 1=1
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
            and pi.finished_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
            and pi.state = 5
            group by 1,2,3,4,5,6,7,8,9,10,11,12,13
        ) tt
        group by 1
    ) t2

    on t1.员工ID = t2.员工ID
)


,staff_de as (
select
    t1.staff_info_id
    ,count(distinct t1.delivery_code) delivery_delivery_num##交接区域数量
    ,count(distinct t1.pno) delivery_num##交接数量
    ,count(distinct if(t2.pno_code is not null,t1.pno,null)) delivery_pnos_correct#绑定码的交接数量
    ,count(distinct if(t2.pno_code is null, t1.pno,null)) delivery_pnos_wrong #非绑定码的交接数量
    ,round(count(distinct if(t2.pno_code is null, t1.pno,null))/count(distinct t1.pno) ,2) as pnos_wrong_bili


from (
##包裹实际交接情况
select
    td.pno
    ,date(convert_tz(td.created_at,'+00:00','+08:00')) as delivery_dt
    ,mr.name region_name
    ,mp.name piece_name
    ,dsdt.dst_store_id store_id
    ,ssd.name store_name
    ,case when ssd.category = '1' then 'SP' when ssd.category = '10' then 'BDC' end DC_type
    ,tiktok_area.area_name tiktok_area
    ,lazada_area.area_name lazada_area
    ,case shopee_area.area_id when 1 then 'MM'  when 2 then 'GMA '  when 3 then 'Luz 1'  when 4 then 'Luz 2'  when 5 then 'Luz 3' when 6 then 'Vis 1'  when 7 then 'Vis 2'  when 8 then 'Min 1'  when 9 then 'Min 2'  when 10 then 'Luz 4' end as shopee_area
    ,hsi.name staff_name
    ,td.staff_info_id staff_info_id
    ,sd.province_code as province_code
    ,sp.name as province_name
    ,sd.city_code as city_code
    ,sc.name as city_name
    ,sd.code barangay_code
    ,sd.name barangay_name
    ,if(hsi.job_title = 13,'BIKE',if(hsi.job_title = 110,'VAN',if(hsi.job_title = 452,'BOAT',if(hsi.job_title = 1000,'Tricycle','other')))) job_title
    ,ddpsci.third_sorting_code as delivery_code
    ,CONCAT(td.staff_info_id,"-",ddpsci.sorting_code) pno_code
    ##,sdmzc.当日在仓
    ##,count(distinct td.pno) delivery_pnos
    ##,nth_value(count(distinct td.pno),2) over(partition by ssd.name,td.staff_info_id order by count(distinct td.pno) desc) 第二区域交接数

from ph_staging.ticket_delivery td

##left join ph_staging.parcel_info pi
##on pi.pno = td.pno

join dwm.dwd_ph_non_end_pno_detl_d dsdt##在仓表
on td.pno = dsdt.pno and date(convert_tz(td.created_at,'+00:00','+08:00')) = date(dsdt.stat_date)

left join ph_staging.parcel_info pi
on pi.pno = dsdt.pno

left join ph_staging.sys_district sd ##brgy的码
on pi.dst_district_code = sd.code

left join ph_bi.sys_city sc
on sc.code = sd.city_code

left join ph_bi.sys_province sp
on sp.code = sd.province_code

left join
(
    select
        ddpsci.pno
        ,ddpsci.dst_store_id
        ,ddpsci.dst_province_code
        ,ddpsci.dst_city_code
        ,ddpsci.dst_district_code
        ,ddpsci.third_sorting_code
        ,ddpsci.sorting_code
        ,row_number() over(partition by ddpsci.pno order by ddpsci.created_at desc) rk
    from ph_drds.parcel_sorting_code_info ddpsci
    where 1=1
        and ddpsci.created_at >= date_sub(current_date(),91)
) ddpsci
on dsdt.pno = ddpsci.pno and ddpsci.rk = 1


left join ph_staging.sys_store ssd
on dsdt.dst_store_id = ssd.id

left join dwm.dwd_ph_dict_lazada_period_rules lazada_area
on ssd.province_code = lazada_area.province_code

left join ph_staging.shopee_period_limitation_rules_area shopee_area
on ssd.province_code = shopee_area.province_code

left join
(
    select distinct
        tiktok_area.dst_province_code province_code
        ,case tiktok_area.dst_area_code
            when 'MM' then 'MM'
            when 'GMA' then 'GMA'
            when 'LUZON 1' then 'Luz 1'
            when 'LUZON 2' then 'Luz 2'
            when 'LUZON 3' then 'Luz 3'
            when 'LUZON 4' then 'Luz 4'
            when 'MINDANAO 1' then 'Min 1'
            when 'MINDANAO 2' then 'Min 2'
            when 'VISAYAS 1' then 'Vis 1'
            when 'VISAYAS 2' then 'Vis 2'
        end area_name
    from dwm.dwd_ph_dict_tiktok_period_rules tiktok_area
) tiktok_area
on ssd.province_code = tiktok_area.province_code

LEFT JOIN ph_staging.sys_manage_region mr
ON ssd.manage_region = mr.id

LEFT JOIN ph_staging.sys_manage_piece mp
ON ssd.manage_piece = mp.id

left join ph_bi.hr_staff_info hsi
on td.staff_info_id = hsi.staff_info_id

left join
(#网点各三段码在仓、已交接、积压
    SELECT
        dsdt.stat_date
        ,ssd.id `store_id`
        ,ssd.name `网点名称`
        ,ddpsci.third_sorting_code `区域编码`

        ,count(dsdt.pno) '当日在仓'
        ,count(case when dsdt.is_handover = 1 then dsdt.pno else null end)  `已交接量`
        ,count(case when dsdt.state not in ('已签收','疑难件','已退件','异常关闭') then dsdt.pno else null end) `积压件量`

    FROM dwm.dwd_ph_non_end_pno_detl_d dsdt

    left join ph_staging.parcel_info pi
    on dsdt.pno = pi.pno

    left join
    (
        select
            ddpsci.pno
            ,ddpsci.third_sorting_code
            ,row_number() over(partition by ddpsci.pno order by ddpsci.created_at desc) rk
        from ph_drds.parcel_sorting_code_info ddpsci
        where 1=1
            and ddpsci.created_at >= date_sub(current_date(),91)
    ) ddpsci
    on pi.pno = ddpsci.pno
    and ddpsci.rk = 1

    left join ph_staging.sys_store ssd
    on dsdt.dst_store_id = ssd.id

    where 1=1
        and dsdt.stat_date = date_sub(curdate(),interval 1 day)
        and ssd.category in ('1','10')##SP网点
    GROUP BY 1,2,3,4
    order by 1,2,3,4
)sdmzc
on sdmzc.store_id = ssd.id and sdmzc.区域编码 = ddpsci.third_sorting_code

where 1=1
    and td.created_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
    and td.created_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
    and td.state <> 3
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21

)t1

left join
(
#包裹理论交接情况，快递员绑定情况
select td.pno
    ,date(convert_tz(td.created_at,'+00:00','+08:00')) as delivery_dt
    ,dsdt.dst_store_id store_id
    ,ss.name store_name
    ,mr.name region_name
    ,mp.name piece_name
    ,tiktok_area.area_name tiktok_area
    ,lazada_area.area_name lazada_area
    ,case shopee_area.area_id when 1 then 'MM'  when 2 then 'GMA '  when 3 then 'Luz 1'  when 4 then 'Luz 2'  when 5 then 'Luz 3' when 6 then 'Vis 1'  when 7 then 'Vis 2'  when 8 then 'Min 1'  when 9 then 'Min 2'  when 10 then 'Luz 4' end as shopee_area
    ,case when ss.category = '1' then 'SP' when ss.category = '10' then 'BDC' end DC_type
    ,sd.province_code as province_code
    ,sp.name as province_name
    ,sd.city_code as city_code
    ,sc.name as city_name
    ,sd.code barangay_code
    ,sd.name barangay_name
    ,sdbsi.delivery_code delivery_code
    ,sdbsi.staff_info_id as staff_info_id
    ,CONCAT(sdbsi.staff_info_id,"-",ddpsci.sorting_code) pno_code
    ##,count(distinct t.delivery_code) 三段码绑定数量
    ##,group_concat(distinct t.delivery_code SEPARATOR ' / ') 三段码绑定情况
    ##,count(distinct t.district_code) barangay绑定数量
    ##,group_concat(concat(t.delivery_code,':',t.barangay_name) order by t.delivery_code SEPARATOR ' / ') 绑定明细情况

    from ph_staging.ticket_delivery td

    join dwm.dwd_ph_non_end_pno_detl_d dsdt##在仓表
    on td.pno = dsdt.pno and date(convert_tz(td.created_at,'+00:00','+08:00')) = date(dsdt.stat_date)

    ##left join ph_staging.parcel_info pi
    ##on pi.pno = td.pno

    left join
    (
        select
            ddpsci.pno
            ,ddpsci.dst_store_id
            ,ddpsci.dst_province_code
            ,ddpsci.dst_city_code
            ,ddpsci.dst_district_code
            ,ddpsci.third_sorting_code
            ,ddpsci.sorting_code
            ,row_number() over(partition by ddpsci.pno order by ddpsci.created_at desc) rk
        from ph_drds.parcel_sorting_code_info ddpsci
        where 1=1
            and ddpsci.created_at >= date_sub(current_date(),91)
    ) ddpsci
    on dsdt.pno = ddpsci.pno and ddpsci.rk = 1

    left join (
        select
            store_id
            ,delivery_code
            ,district_code
            ,staff_info_id
            ,deleted
        from  ph_staging.store_delivery_barangay_staff_info
        where deleted = 0
        group by
            store_id
            ,delivery_code
            ,district_code
            ,staff_info_id
            ,deleted
        )sdbsi
    on ddpsci.dst_store_id = sdbsi.store_id #网点
    and ddpsci.third_sorting_code = sdbsi.delivery_code #派送码
    and ddpsci.dst_district_code = sdbsi.district_code #barangay code

    left join ph_staging.sys_district sd
    on sdbsi.district_code  = sd.code

    left join ph_bi.sys_city sc
    on sc.code = sd.city_code

    left join ph_bi.sys_province sp
    on sp.code = sd.province_code

    left join ph_staging.sys_store ss
    on sdbsi.store_id  = ss.id

    LEFT JOIN ph_staging.sys_manage_region mr
    ON ss.manage_region = mr.id

    LEFT JOIN ph_staging.sys_manage_piece mp
    ON ss.manage_piece = mp.id

    left join dwm.dwd_ph_dict_lazada_period_rules lazada_area
    on ss.province_code = lazada_area.province_code

    left join ph_staging.shopee_period_limitation_rules_area shopee_area
    on ss.province_code = shopee_area.province_code

    left join

    (
        select distinct
        tiktok_area.dst_province_code province_code
        ,case tiktok_area.dst_area_code
        when 'MM' then 'MM'
        when 'GMA' then 'GMA'
        when 'LUZON 1' then 'Luz 1'
        when 'LUZON 2' then 'Luz 2'
        when 'LUZON 3' then 'Luz 3'
        when 'LUZON 4' then 'Luz 4'
        when 'MINDANAO 1' then 'Min 1'
        when 'MINDANAO 2' then 'Min 2'
        when 'VISAYAS 1' then 'Vis 1'
        when 'VISAYAS 2' then 'Vis 2'
        end area_name
        from dwm.dwd_ph_dict_tiktok_period_rules tiktok_area
    ) tiktok_area
    on ss.province_code = tiktok_area.province_code

where 1=1
    and td.created_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour )
    and td.created_at < date_sub(curdate(), interval 8 hour)##正常的时间剪掉8h
    and td.state <> 3
    and sdbsi.deleted = 0 # 非剔除记录
    and ss.category  = 1 # SP网点
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19

)t2

on t1.pno_code = t2.pno_code

group by 1
)

,prout as (

select p1.staff_info_id
from (
SELECT
    date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )  routed_at #路由日期
    ,convert_tz(pr.routed_at , '+00:00', '+08:00' ) routed_time #路由时间
    ,lead(convert_tz(pr.routed_at , '+00:00', '+08:00' )) over (PARTITION by pr.staff_info_id,date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )    order by convert_tz(pr.routed_at , '+00:00', '+08:00' ))   下一条路由
    ,lead(pr.route_action) over (PARTITION by pr.staff_info_id,date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )    order by convert_tz(pr.routed_at , '+00:00', '+08:00' ))   下一条路由动作
    ,timestampdiff(hour,convert_tz(pr.routed_at , '+00:00', '+08:00' ),lead(convert_tz(pr.routed_at , '+00:00', '+08:00' )) over (PARTITION by pr.staff_info_id,date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )    order by convert_tz(pr.routed_at , '+00:00', '+08:00' )))  路由间隔时间
    ##,pr.pno
    ,pr.route_action
    ,case when route_action='ACCEPT_PARCEL'  then  '接件扫描'
        when route_action='ARRIVAL_GOODS_VAN_CHECK_SCAN'  then  '车货关联到港'
        when route_action='ARRIVAL_WAREHOUSE_SCAN'  then  '到件入仓扫描'
        when route_action='CANCEL_ARRIVAL_WAREHOUSE_SCAN'  then  '取消到件入仓扫描'
        when route_action='CANCEL_PARCEL'  then  '撤销包裹'
        when route_action='CANCEL_SHIPMENT_WAREHOUSE'  then  '取消发件出仓'
        when route_action='CHANGE_PARCEL_CANCEL'  then  '修改包裹为撤销'
        when route_action='CHANGE_PARCEL_CLOSE'  then  '修改包裹为异常关闭'
        when route_action='CHANGE_PARCEL_IN_TRANSIT'  then  '修改包裹为运输中'
        when route_action='CHANGE_PARCEL_INFO'  then  '修改包裹信息'
        when route_action='CHANGE_PARCEL_SIGNED'  then  '修改包裹为签收'
        when route_action='CLAIMS_CLOSE'  then  '理赔关闭'
        when route_action='CLAIMS_COMPLETE'  then  '理赔完成'
        when route_action='CLAIMS_CONTACT'  then  '已联系客户'
        when route_action='CLAIMS_TRANSFER_CS'  then  '转交总部cs处理'
        when route_action='CLOSE_ORDER'  then  '关闭订单'
        when route_action='CONTINUE_TRANSPORT'  then  '疑难件继续配送'
        when route_action='CREATE_WORK_ORDER'  then  '创建工单'
        when route_action='CUSTOMER_CHANGE_PARCEL_INFO'  then  '客户修改包裹信息'
        when route_action='CUSTOMER_OPERATING_RETURN'  then  '客户操作退回寄件人'
        when route_action='DELIVERY_CONFIRM'  then  '确认妥投'
        when route_action='DELIVERY_MARKER'  then  '派件标记'
        when route_action='DELIVERY_PICKUP_STORE_SCAN'  then  '自提取件扫描'
        when route_action='DELIVERY_TICKET_CREATION_SCAN'  then  '交接扫描'
        when route_action='DELIVERY_TRANSFER'  then  '派件转单'
        when route_action='DEPARTURE_GOODS_VAN_CK_SCAN'  then  '车货关联出港'
        when route_action='DETAIN_WAREHOUSE'  then  '货件留仓'
        when route_action='DIFFICULTY_FINISH_INDEMNITY'  then  '疑难件支付赔偿'
        when route_action='DIFFICULTY_HANDOVER'  then  '疑难件交接'
        when route_action='DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE'  then  '疑难件交接货件留仓'
        when route_action='DIFFICULTY_RE_TRANSIT'  then  '疑难件退回区域总部/重启运送'
        when route_action='DIFFICULTY_RETURN'  then  '疑难件退回寄件人'
        when route_action='DIFFICULTY_SEAL'  then  '集包异常'
        when route_action='DISCARD_RETURN_BKK'  then  '丢弃包裹的，换单后寄回BKK'
        when route_action='DISTRIBUTION_INVENTORY'  then  '分拨盘库'
        when route_action='DWS_WEIGHT_IMAGE'  then  'DWS复秤照片'
        when route_action='EXCHANGE_PARCEL'  then  '换货'
        when route_action='FAKE_CANCEL_HANDLE'  then  '虚假撤销判责'
        when route_action='FLASH_HOME_SCAN'  then  'FH交接扫描'
        when route_action='FORCE_TAKE_PHOTO'  then  '强制拍照路由'
        when route_action='HAVE_HAIR_SCAN_NO_TO'  then  '有发无到'
        when route_action='HURRY_PARCEL'  then  '催单'
        when route_action='INCOMING_CALL'  then  '来电接听'
        when route_action='INTERRUPT_PARCEL_AND_RETURN'  then  '中断运输并退回'
        when route_action='INVENTORY'  then  '盘库'
        when route_action='LOSE_PARCEL_TEAM_OPERATION'  then  '丢失件团队处理'
        when route_action='MANUAL_REMARK'  then  '添加备注'
        when route_action='MISS_PICKUP_HANDLE'  then  '漏包裹揽收判责'
        when route_action='MISSING_PARCEL_SCAN'  then  '丢失件包裹操作'
        when route_action='NOTICE_LOST_PARTS_TEAM'  then  '已通知丢失件团队'
        when route_action='PARCEL_HEADLESS_CLAIMED'  then  '无头件包裹已认领'
        when route_action='PARCEL_HEADLESS_PRINTED'  then  '无头件包裹已打单'
        when route_action='PENDING_RETURN'  then  '待退件'
        when route_action='PHONE'  then  '电话联系'
        when route_action='PICK_UP_STORE'  then  '待自提取件'
        when route_action='PICKUP_RETURN_RECEIPT'  then  '签回单揽收'
        when route_action='PRINTING'  then  '打印面单'
        when route_action='QAQC_OPERATION'  then  'QAQC判责'
        when route_action='RECEIVE_WAREHOUSE_SCAN'  then  '收件入仓'
        when route_action='RECEIVED'  then  '已揽收,初始化动作，实际情况并没有作用'
        when route_action='REFUND_CONFIRM'  then  '退件妥投'
        when route_action='REPAIRED'  then  '上报问题修复路由'
        when route_action='REPLACE_PNO'  then  '换单'
        when route_action='REPLY_WORK_ORDER'  then  '回复工单'
        when route_action='REVISION_TIME'  then  '改约时间'
        when route_action='SEAL'  then  '集包'
        when route_action='SEAL_NUMBER_CHANGE'  then  '集包件数变化'
        when route_action='SHIPMENT_WAREHOUSE_SCAN'  then  '发件出仓扫描'
        when route_action='SORTER_WEIGHT_IMAGE'  then  '分拣机复秤照片'
        when route_action='SORTING_SCAN'  then  '分拣扫描'
        when route_action='STAFF_INFO_UPDATE_WEIGHT'  then  '快递员修改重量'
        when route_action='STORE_KEEPER_UPDATE_WEIGHT'  then  '仓管员复秤'
        when route_action='STORE_SORTER_UPDATE_WEIGHT'  then  '分拣机复秤'
        when route_action='SYSTEM_AUTO_RETURN'  then  '系统自动退件'
        when route_action='TAKE_PHOTO'  then  '异常打单拍照'
        when route_action='THIRD_EXPRESS_ROUTE'  then  '第三方公司路由'
        when route_action='THIRD_PARTY_REASON_DETAIN'  then  '第三方原因滞留'
        when route_action='TICKET_WEIGHT_IMAGE'  then  '揽收称重照片'
        when route_action='TRANSFER_LOST_PARTS_TEAM'  then  '已转交丢失件团队'
        when route_action='TRANSFER_QAQC'  then  '转交QAQC处理'
        when route_action='UNSEAL'  then  '拆包'
        when route_action='UNSEAL_NO_PARCEL'  then  '上报包裹不在集包里'
        when route_action='UNSEAL_NOT_SCANNED'  then  '集包已拆包，本包裹未被扫描'
        when route_action='VEHICLE_ACCIDENT_REG'  then  '车辆车祸登记'
        when route_action='VEHICLE_ACCIDENT_REGISTRATION'  then  '车辆车祸登记'
        when route_action='VEHICLE_WET_DAMAGE_REG'  then  '车辆湿损登记'
        when route_action='VEHICLE_WET_DAMAGE_REGISTRATION'  then  '车辆湿损登记'

    end 路由动作
    ,pr.staff_info_id
    ,case WHEN hr.job_title =13 THEN 'Bike'
          WHEN hr.job_title =110 THEN 'Van'
          WHEN hr.job_title =452 THEN 'Boat'
          when hr.job_title=1000 then 'Tricycle'
    end as 岗位
    ,pr.store_id 路由发生网点
    ,hr.store_id 员工归属网点
    ,ss.name 员工归属网点名称
    ,sr.name as 员工归属网点名称area_name -- 大区,
    ,sp.name as 员工归属网点名称region_name -- 片区,

from ph_staging.parcel_route pr

join
(
    SELECT
        hr.`sys_store_id` as store_id,
        hr.staff_info_id,
        hr.job_title
    FROM `ph_bi`.`hr_staff_info` hr
    where hr.`is_sub_staff`= 0
        and hr.`state`= 1
        and  hr.job_title in ( '13', '110','1000')
        and hr.hire_date <= date_sub(CURRENT_DATE,interval 0 day)
) hr
on hr.staff_info_id=pr.staff_info_id

left join ph_staging.sys_store ss
on ss.id=hr.store_id

left join ph_staging.sys_manage_piece sp
on ss.manage_piece= sp.id

left join ph_staging.sys_manage_region sr
on ss.manage_region= sr.id

where pr.routed_at>=DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 1 day),interval 6 hour)  #由于会出现十二点后由路由动作的情况，因此限制为6点过后的路由时间
    and pr.routed_at<date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 0 day)
    and ss.state=1
)p1
where  p1.路由间隔时间 > 5
group by p1.staff_info_id
)



##晚上八点以后操作
,eight_act as (
##快递员、8点后首次联系在距离网点100米内并标记联系不上、拒收、改约、妥投总计包裹量、普遍的响铃时长（众数这个值）

#############求众数
###排序
select
    t1.路由日期
    ,t1.staff_info_id
    ,t1.总响铃包裹数
    ,t1.diaboloDuration
from (
SELECT
*
##,rank() over(PARTITION by 路由日期,staff_info_id  order by  diaboloDuration,次数_diaboloDuration desc )  rk
,row_number() over(PARTITION by 路由日期,staff_info_id  order by  次数_diaboloDuration desc )  rk

from (
###响铃时长计数
select
    temp.路由日期

    ,temp.staff_info_id
    ,temp.diaboloDuration##响铃时长（rk=1,众数）
    ,total_diaboloDuration.总响铃包裹数##晚上八点回网点联系的包裹量
    ,count(1)  次数_diaboloDuration##响铃时长对应的次数
    ,count(distinct temp.pno) 响铃包裹数##对应多少个包裹
    ,sum(count(1)) over(PARTITION  by temp.路由日期,temp.staff_info_id)  总次数_diaboloDuratio##累计联系次数
    #,count(distinct pno)   总响铃包裹数


from (
####半夜操作明细#############
    SELECT
        date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )  路由日期
        ,convert_tz(pr.routed_at , '+00:00', '+08:00' ) 路由时间
        ,st_distance_sphere(point(replace(json_extract(pr.extra_value, '$.lng'),'\"','')+0 ,replace(json_extract(pr.extra_value, '$.lat'),'\"','')+0),point(ss.lng,ss.lat))/1000 as 距离网点_直线距离_公里
        ,replace(json_extract(pr.extra_value, '$.diaboloDuration'),'\"','')  diaboloDuration
        ,replace(json_extract(pr.extra_value, '$.callDuration'),'\"','')   callDuration
        ,pr.pno
        ,pr.route_action
        ,pr.staff_info_id
        ,f_call.路由时间  当天该快递员第一次电话时间
        ,f_call.距离网点_直线距离_公里  当天该快递员第一次电话时间_距离网点_直线距离_公里

        ,case WHEN hr.job_title =13 THEN 'Bike'
            WHEN hr.job_title =110 THEN 'Van'
            WHEN hr.job_title =452 THEN 'Boat'
            when hr.job_title=1000 then 'Tricycle'
            end as 岗位
        ,pr.store_id 路由发生网点
        ,hr.store_id 员工归属网点
        ,ss.name 员工归属网点名称
        ,sr.name as 员工归属网点名称area_name -- 大区,
        ,sp.name as 员工归属网点名称region_name -- 片区,

    from ph_staging.parcel_route pr

     join
    (
     SELECT
          hr.`sys_store_id` as store_id,
          hr.staff_info_id,
          hr.job_title
      FROM `ph_bi`.`hr_staff_info` hr
      where hr.`is_sub_staff`= 0
          and hr.`formal`= 1
          and hr.`state`= 1
          and  hr.job_title in ( '13', '110','1000')
          and hr.hire_date <= date_sub(CURRENT_DATE,interval 0 day)
    ) hr
    on hr.staff_info_id=pr.staff_info_id

    #标记为联系不上客户,八点后标记，且离网点五百米内
    join
    (
        select *
        from (
            SELECT
                pr.staff_info_id
                ,date(convert_tz(pr.routed_at,'+00:00','+08:00')) as routed_at
                ,pr.pno
                ,st_distance_sphere(point(replace(json_extract(pr.extra_value, '$.lng'),'\"','')+0 ,replace(json_extract(pr.extra_value, '$.lat'),'\"','')+0),point(ss.lng,ss.lat))/1000 as 距离网点_直线距离_公里
            from ph_staging.parcel_route pr

            left join ph_staging.parcel_info pi
            ON pi.pno = pr.pno

            left join ph_staging.sys_store ss
            on ss.id=pi.dst_store_id
            WHERE 1=1
              ##AND pr.marker_category IN (2,17,9,14,70,15,71,16,1,40,29,78,25,75,23,73,7,22,6,21,5,20,4,19) # 2 17拒收 9 14 70 改约 15 71 运力不足
              AND pr.route_action = 'DELIVERY_MARKER' #派件标记
              and pr.routed_at>=DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 1 day),interval 20 hour)  #20点过后的路由时间
              and pr.routed_at<DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 0 day) ,interval 1 hour)
              and   pr.marker_category in ('1','2','70','71')##=1  #'联系不上包裹数'
              and ss.state=1
        )temp
        where temp.距离网点_直线距离_公里<0.1
    )  DELIVERY_MARKER
    on DELIVERY_MARKER.pno=pr.pno
    and DELIVERY_MARKER.routed_at=date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )
    and DELIVERY_MARKER.staff_info_id=pr.staff_info_id

    left join ph_staging.sys_store ss
    on ss.id=hr.store_id

    left join ph_staging.sys_manage_piece sp
    on ss.manage_piece= sp.id

    left join ph_staging.sys_manage_region sr
    on ss.manage_region= sr.id

    left join (
    #####包裹第一次电话联系时间
        select *
        from (
            SELECT
                date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )  路由日期
                ,convert_tz(pr.routed_at , '+00:00', '+08:00' ) 路由时间
                ,st_distance_sphere(point(replace(json_extract(pr.extra_value, '$.lng'),'\"','')+0 ,replace(json_extract(pr.extra_value, '$.lat'),'\"','')+0),point(ss.lng,ss.lat))/1000 as 距离网点_直线距离_公里
                ,replace(json_extract(pr.extra_value, '$.diaboloDuration'),'\"','')  diaboloDuration
                ,replace(json_extract(pr.extra_value, '$.callDuration'),'\"','')   callDuration
                ,pr.pno
                ,pr.staff_info_id
                ,case WHEN hr.job_title =13 THEN 'Bike'
                WHEN hr.job_title =110 THEN 'Van'
                WHEN hr.job_title =452 THEN 'Boat'
                when hr.job_title=1000 then 'Tricycle'
                end as 岗位
                ,pr.store_id 路由发生网点
                ,hr.store_id 员工归属网点
                ,ss.name 员工归属网点名称
                ,sr.name as 员工归属网点名称area_name -- 大区,
                ,sp.name as 员工归属网点名称region_name -- 片区,
                ,rank() over(PARTITION by pr.staff_info_id ,pr.pno ,date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )  order by pr.routed_at)  rk
            from ph_staging.parcel_route pr
            join
                (
                 SELECT
                      hr.`sys_store_id` as store_id,
                      hr.staff_info_id,
                      hr.job_title
                  FROM `ph_bi`.`hr_staff_info` hr
                  where hr.`is_sub_staff`= 0
                      and hr.`formal`= 1
                      and hr.`state`= 1
                      and  hr.job_title in ( '13', '110','1000')
                      and hr.hire_date <= date_sub(CURRENT_DATE,interval 0 day)
                ) hr
                on hr.staff_info_id=pr.staff_info_id
            left join ph_staging.sys_store ss
            on ss.id=hr.store_id
            left join ph_staging.sys_manage_piece sp
            on ss.manage_piece= sp.id
            left join ph_staging.sys_manage_region sr
            on ss.manage_region= sr.id
            where pr.routed_at>=DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 1 day),interval 6 hour)  #6点过后的路由时间
              and pr.routed_at<DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 0 day) ,interval 1 hour)
              and ss.state=1
              and pr.route_action='PHONE'
        )pr
        where pr.rk=1
    )  f_call
    on f_call.路由日期=date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )
    and f_call.staff_info_id=pr.staff_info_id
    and f_call.pno=pr.pno


    where pr.routed_at>=DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 1 day),interval 20 hour)  #20点过后的路由时间
      and pr.routed_at<DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 0 day) ,interval 1 hour)
      and ss.state=1
      and pr.route_action="PHONE"
      #第一电话是再网点打的，且八点后
      and  f_call.距离网点_直线距离_公里<0.1
      and hour(f_call.路由时间)>=20
) temp


#总响铃包裹数，第一电话是再网点打的，且八点后
left join (
    ###响铃时长计数
    select
    路由日期
    ,staff_info_id
    ,count(distinct pno) 总响铃包裹数
    from
    (
    ####半夜操作明细#############
    SELECT
        date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )  路由日期
        ,convert_tz(pr.routed_at , '+00:00', '+08:00' ) 路由时间
        ,st_distance_sphere(point(replace(json_extract(pr.extra_value, '$.lng'),'\"','')+0 ,replace(json_extract(pr.extra_value, '$.lat'),'\"','')+0),point(ss.lng,ss.lat))/1000 as 距离网点_直线距离_公里
        ,replace(json_extract(pr.extra_value, '$.diaboloDuration'),'\"','')  diaboloDuration
        ,replace(json_extract(pr.extra_value, '$.callDuration'),'\"','')   callDuration
        ,pr.pno
        ,pr.route_action
        ,pr.staff_info_id
        ,f_call.路由时间  当天该快递员第一次电话时间
        ,f_call.距离网点_直线距离_公里  当天该快递员第一次电话时间_距离网点_直线距离_公里

        ,case WHEN hr.job_title =13 THEN 'Bike'
        WHEN hr.job_title =110 THEN 'Van'
        WHEN hr.job_title =452 THEN 'Boat'
        when hr.job_title=1000 then 'Tricycle'
        end as 岗位
        ,pr.store_id 路由发生网点
        ,hr.store_id 员工归属网点
        ,ss.name 员工归属网点名称

    from ph_staging.parcel_route pr

    join (
        SELECT
            hr.`sys_store_id` as store_id,
            hr.staff_info_id,
            hr.job_title
        FROM `ph_bi`.`hr_staff_info` hr
        where hr.`is_sub_staff`= 0
          and hr.`formal`= 1
          and hr.`state`= 1
          and  hr.job_title in ( '13', '110','1000')
          and hr.hire_date <= date_sub(CURRENT_DATE,interval 0 day)
    ) hr
    on hr.staff_info_id=pr.staff_info_id

    #标记为联系不上客户,八点后标记，且离网点五百米内
    join
    (

        select
        *
        from (

            SELECT

                pr.staff_info_id
                ,date(convert_tz(pr.routed_at,'+00:00','+08:00')) as routed_at
                ,pr.pno
                ,st_distance_sphere(point(replace(json_extract(pr.extra_value, '$.lng'),'\"','')+0 ,replace(json_extract(pr.extra_value, '$.lat'),'\"','')+0),point(ss.lng,ss.lat))/1000 as 距离网点_直线距离_公里

            from ph_staging.parcel_route pr

            left join ph_staging.parcel_info pi
            ON pi.pno = pr.pno

            left join ph_staging.sys_store ss
            on ss.id=pi.dst_store_id

            WHERE 1=1
                ##AND pr.marker_category IN (2,17,9,14,70,15,71,16,1,40,29,78,25,75,23,73,7,22,6,21,5,20,4,19) # 2 17拒收 9 14 70 改约 15 71 运力不足
                AND pr.route_action = 'DELIVERY_MARKER' #派件标记
                and pr.routed_at>=DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 1 day),interval 20 hour)  #20点过后的路由时间
                and pr.routed_at<DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 0 day) ,interval 1 hour)
                and   pr.marker_category in ('1','2','70','71') #=1  #'联系不上包裹数'
                and ss.state=1
            )temp
            where temp.距离网点_直线距离_公里<0.1
    )  DELIVERY_MARKER
    on DELIVERY_MARKER.pno=pr.pno
    and DELIVERY_MARKER.routed_at=date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )
    and DELIVERY_MARKER.staff_info_id=pr.staff_info_id



    left join ph_staging.sys_store ss
    on ss.id=hr.store_id

    left join ph_staging.sys_manage_piece sp
    on ss.manage_piece= sp.id

    left join ph_staging.sys_manage_region sr
    on ss.manage_region= sr.id

    left join (
    #####包裹第一次电话联系时间
    select
    *
    from (
        SELECT
        date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )  路由日期
        ,convert_tz(pr.routed_at , '+00:00', '+08:00' ) 路由时间
        ,st_distance_sphere(point(replace(json_extract(pr.extra_value, '$.lng'),'\"','')+0 ,replace(json_extract(pr.extra_value, '$.lat'),'\"','')+0),point(ss.lng,ss.lat))/1000 as 距离网点_直线距离_公里
        ,replace(json_extract(pr.extra_value, '$.diaboloDuration'),'\"','')  diaboloDuration
        ,replace(json_extract(pr.extra_value, '$.callDuration'),'\"','')   callDuration
        ,pr.pno

        ,pr.staff_info_id
        ,case WHEN hr.job_title =13 THEN 'Bike'
        WHEN hr.job_title =110 THEN 'Van'
        WHEN hr.job_title =452 THEN 'Boat'
        when hr.job_title=1000 then 'Tricycle'
        end as 岗位
        ,pr.store_id 路由发生网点
        ,hr.store_id 员工归属网点
        ,ss.name 员工归属网点名称
        ,sr.name as 员工归属网点名称area_name -- 大区,
        ,sp.name as 员工归属网点名称region_name -- 片区,
        ,rank() over(PARTITION by pr.staff_info_id ,pr.pno ,date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )  order by pr.routed_at)  rk

        from ph_staging.parcel_route pr

         join
        (
         SELECT
                         hr.`sys_store_id` as store_id,
                       hr.staff_info_id,
                       hr.job_title
                   FROM `ph_bi`.`hr_staff_info` hr
                   where hr.`is_sub_staff`= 0
                   and hr.`formal`= 1
                   and hr.`state`= 1
                   and  hr.job_title in ( '13', '110','1000')
                   and hr.hire_date <= date_sub(CURRENT_DATE,interval 0 day)
        ) hr
        on hr.staff_info_id=pr.staff_info_id

        left join ph_staging.sys_store ss
        on ss.id=hr.store_id

        left join ph_staging.sys_manage_piece sp
                on ss.manage_piece= sp.id
                left join ph_staging.sys_manage_region sr
                on ss.manage_region= sr.id

        where

        pr.routed_at>=DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 1 day),interval 6 hour)  #6点过后的路由时间
        and pr.routed_at<DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 0 day) ,interval 1 hour)

        and ss.state=1
        and pr.route_action='PHONE'
        )
        pr
        where pr.rk=1
    )  f_call
    on f_call.路由日期=date(convert_tz(pr.routed_at , '+00:00', '+08:00' ) )
    and f_call.staff_info_id=pr.staff_info_id
    and f_call.pno=pr.pno


    where pr.routed_at>=DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 1 day),interval 20 hour)  #20点过后的路由时间
        and pr.routed_at<DATE_ADD(date_sub(convert_tz(CURRENT_DATE,'+08:00', '+00:00' ), interval 0 day) ,interval 1 hour)

        and ss.state=1
        and pr.route_action="PHONE"
        #第一电话是再网点打的，且八点后
        and  f_call.距离网点_直线距离_公里<0.1
        and hour(f_call.路由时间)>=20
    )
    group by 1,2
) total_diaboloDuration
on total_diaboloDuration.路由日期=temp.路由日期 and total_diaboloDuration.staff_info_id=temp.staff_info_id

group by 1,2,3,4

)temp

)t1
where t1.rk = 1
group by t1.路由日期
    ,t1.staff_info_id
    ,t1.总响铃包裹数
    ,t1.diaboloDuration

)



select m1.*
,if(m1.是否应出勤 in ('应出勤') and m1.近14天排班旷工次数 >= 3 ,0.05,0) as 旷工_系数
,if(m1.是否应出勤 not in ('无需出勤') and m1.迟到情况 in ('迟到30min以上') and m1.近14天排班迟到30min以上次数 >= 3 ,0.05,0) as 迟到_系数
,if(m1.最早交接时间晚 in ('交接晚_第一趟正班车8:30分前到港_最早交接时间晚于10:00','交接晚_第一趟正班车到港后1.5h后未开始交接'),0.1,0) as 最早交接时间晚_系数
,if(m1.交接2h包裹比例 in ('2h内交接包裹量低于90') and m1.截至12点交接包裹比例 < 0.4 ,0.1,0) as 交接时间长_系数
,if(m1.交接量少 in ('低于同级别区域人均交接量的20%') ,0.1,0) as 交接量少_系数
,if(m1.交接非绑定区域包裹量比例  <= 0.2 ,0,0.1) as 乱交接_系数
,if(m1.出门晚 in ('最早妥投时间晚于比武规定时间') ,0.1,0) as 出门晚_系数
,if(m1.派件结束早 in ('15点前结束派件&妥投率低于70%'),0.1,0) as 派件结束早_系数
,if(m1.妥投量少 in ('低于同级别区域人均妥投量的20%'),0.1,0) as 妥投量少_系数
,if(m1.疑似存在偷懒 in ('存在5h以上无路由动作') ,0.05,0) as 疑似存在偷懒_系数
,if(m1.当日标记问题件数量多 in ('当日标记问题件数（拒收、运力不足、改约、联系不上）为交接包裹量的30%以上'),0.1,0) as 标记问题件多_系数
,if(m1.当日20点之后在网点100内进行首次联系的包裹量  > 15 ,0.05,0) as 回网点批量操作_系数

from (

SELECT
swrd.stat_date            统计日期
,swrd.staff_info_id       员工ID
,swrd.staff_name          员工姓名
,swrd.store_id            归属网点ID
,swrd.store_name          归属网点名称
,swrd.store_category_desc 网点类型描述
,swrd.tiktok_area         区域TT
,swrd.region_name         归属大区
,case
    when swrd.region_name in ('Area3', 'Area6') then '彭万松'
    when swrd.region_name in ('Area4', 'Area9') then '韩钥'
    when swrd.region_name in ('Area7','Area10', 'Area11','FHome') then '张可新'
    when swrd.region_name in ( 'Area8') then '黄勇'
    when swrd.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
end                       管理者
,swrd.piece_name          归属片区
,swrd.staff_attr          员工属性
,CASE
        WHEN swrd.job_title = 13  THEN 'Bike'
        WHEN swrd.job_title = 110 THEN 'VAN'
        WHEN swrd.job_title = 452 THEN 'Boat'
        WHEN swrd.job_title = 1000 THEN 'Tricycle'
    END AS      员工岗位
,swrd.hire_days           员工在职天数
,swrd.work_store_id       工作网点ID
,swrd.work_store_name     工作网点名称
,swrd.state_desc                状态描述
,swrd.wait_leave_state          是否待离职
##,swa.shift_start                班次开始时间
##,swa.shift_end                  班次结束时间
,if(swa.shift_start is not null,swa.shift_start,staff_id.shift_start)     班次开始时间
,if(swa.shift_end is not null,swa.shift_end,staff_id.shift_end)           班次结束时间

##,swrd.is_plan_rest              是否排休
,swrd.attendance_started_at     上班打卡时间
,swrd.attendance_end_at         下班打卡时间
,swrd.attendance_hour           打卡时长
,swrd.迟到时长                   迟到时长

,staff_id.plan                  是否应出勤
,staff_id.is_AB                 出勤情况
,if(staff_absence.staff_info_id is not null,staff_absence.absence,null) 近14天排班旷工次数

##,swrd.迟到情况                   迟到情况
,staff_id.chidao_ty             迟到情况
,if(staff_absence.staff_info_id is not null,staff_absence.late_30min,null) 近14天排班迟到30min以上次数

,tdm.time_one                   交接第1件包裹时间
,tdm.time_two                   交接第2件包裹时间
,tdm.time_three                 交接第3件包裹时间
,tdm.time_four                  交接第4件包裹时间
,tdm.time_five                  交接第5件包裹时间
,case when date_format(ft.plan_arrive_first,'%Y-%m-%d %H:%i') is not null and date_format(ft.arrive_time_first,'%Y-%m-%d %H:%i') is null then '规划但无正班车到达'
    when date_format(ft.plan_arrive_first,'%Y-%m-%d %H:%i') is null and date_format(ft.arrive_time_first,'%Y-%m-%d %H:%i') is null then '未规划&无正班车到达'
    when date_format(ft.arrive_time_first,'%Y-%m-%d %H:%i') is null then '无正班车'
    when date_format(ft.arrive_time_first,'%H:%i') <= '08:30' and date_format(swrd.最早交接时间,'%H:%i') > '10:00' then '交接晚_第一趟正班车8:30分前到港_最早交接时间晚于10:00'
    when date_format(ft.arrive_time_first,'%H:%i') > '08:30' and date_format(swrd.最早交接时间,'%H:%i') >  date_format(date_add(ft.arrive_time_first,interval 150 minute),'%H:%i') then '交接晚_第一趟正班车到港后1.5h后未开始交接'
else '其他' end                 最早交接时间晚
,case when dp.2h_percentage = 0 or dp.2h_percentage is null then 'null'
    when dp.2h_percentage < 0.9 then '2h内交接包裹量低于90%'
else '2h内交接包裹量高于90%' end as 交接2h包裹比例
,dp.12_percentage 截至12点交接包裹比例
,swrd.交接量
##,swrd.handover_par_cnt
,area_delivery.交接区域数量_all 交接区域数量
,area_delivery.交接区域数量     交接区域数量_提除交接少于4的区域
,area_delivery.交接情况         交接区域情况
,sde.pnos_wrong_bili      交接非绑定区域包裹量比例

,h14.per_capita_handover      近14天人均交接量
,case when swrd.交接量 < h14.per_capita_h then '低于同级别区域人均交接量的20%' else null end as 交接量少
,sdbsi.三段码绑定数量
,sdbsi.三段码绑定情况
,sdbsi.barangay绑定数量
,sdbsi.绑定明细情况

,swrd.最早派件时间       最早妥投时间
,swrd.delivery_end_at2 倒数第二件妥投时间
,swrd.最近派件时间       最晚妥投时间
,case when time(swrd.最早派件时间) > ft.min_tuotou_time then '最早妥投时间晚于比武规定时间' else null end as 出门晚
,case when swrd.`派件/交接` < 0.7 and date_format(swrd.最近派件时间,'%H:%i') < '15:00' then '15点前结束派件&妥投率低于70%' else null end as 派件结束早
,swrd.当天派件数 as 妥投量
,f14.per_capita_finished 近14天人均妥投量
,case when swrd.当天派件数 < f14.per_capita_f then '低于同级别区域人均妥投量的20%' else null end as 妥投量少


,case when prout.staff_info_id is not null then '存在5h以上无路由动作'  else null end as 疑似存在偷懒
,CASE WHEN (swrd.work_store_name like '%_SP%'
    and ((
        ifnull(swrd.拒收包裹数,0)
        +ifnull(swrd.运力不足包裹数,0)
        +ifnull(swrd.改约包裹数,0)
        +ifnull(swrd.客户不在家_电话无人接听包裹数,0)
        )/swrd.交接量) > 0.3)
    THEN '当日标记问题件数（拒收、运力不足、改约、联系不上）为交接包裹量的30%以上'
    END 当日标记问题件数量多
,ea.总响铃包裹数 当日20点之后在网点100内进行首次联系的包裹量
,ea.diaboloDuration 电话联系响铃时长（众数）

,swrd.拒收包裹数
,swrd.运力不足包裹数
,swrd.改约包裹数
,swrd.客户不在家_电话无人接听包裹数
,swrd.收件人号码空号包裹数
,swrd.收件人号码错误包裹数
,swrd.收件人地址不清晰或不正确包裹数
,swrd.货物丢失包裹数
,swrd.货物短少包裹数
,swrd.货物破损包裹数
,swrd.外包装破损包裹数
,swrd.禁运品包裹数
,swrd.其他派件标记包裹数

,nwrd.当日应派  as 网点当日应派包裹量
,nwrd.当日到件入仓量
,nwrd.当日应派交接 as 网点当日应派交接包裹量
,nwrd.当日应派妥投 as 网点当日应派妥投包裹量
,nwrd.应派交接率   as 网点当日应派交接率
,nwrd.妥投率      as 网点当日应派妥投率
,nwrd.积压量
,nwrd.未交接量
,swrd.`网点当日派件人数`
,a.staff_cut 网点当日交接的快递员人数
,a.avg_decnt 网点人均可交接量


,swrd.`派件间隔(分钟)` '派件间隔(分钟)'
,swrd.`派件/交接` '妥投率'
,swrd.`交接5KG以上`
,swrd.`妥投5KG以上`
,swrd.`网点50米内派件量`
,swrd.`人效排名`



FROM main as swrd ## 快递员每日工作情况播报

LEFT JOIN tmpale.network_work_report_daily nwrd ## 网点每日工作情况播报
on swrd.work_store_name = nwrd.网点

##left join ph_bi.hr_staff_info hsi ##员工表
##on swrd.staff_info_id = hsi.staff_info_id

##left join ph_staging.sys_store ss ##网点表
##on hsi.sys_store_id = ss.id
##left join ph_staging.sys_manage_piece smp ##大区
##on smp.id=ss.manage_piece
##left join ph_staging.sys_manage_region smr ##片区
##on smr.id=ss.manage_region

LEFT JOIN ph_backyard.staff_work_attendance swa ##员工考勤表
ON swa.staff_info_id = swrd.staff_info_id and swa.attendance_date = swrd.stat_date
##AND swa.attendance_date = DATE(convert_tz(NOW(),'+08:00','+08:00'))


left join should_delivery as a
on a.store_id = swrd.work_store_id and a.stat_date=swrd.stat_date


left join car_arrive as ft
##日期+网点关联
on ft.next_store_id = swrd.work_store_id  and ft.proof_dt = swrd.stat_date

left join staff_delivery_code as sdbsi
# 快递员绑定情况
on sdbsi.store_id = swrd.store_id and sdbsi.staff_info_id = swrd.staff_info_id

left join staff_de sde on sde.staff_info_id = swrd.staff_info_id

#left join staff_delivery as m1
#on m1.delivery_dt = swrd.stat_date and m1.staff_info_id = swrd.staff_info_id and m1.store_name = swrd.当日所属网点

left join area_delivery on swrd.staff_info_id = area_delivery.员工ID


left join staff_id on staff_id.stat_date = swrd.stat_date and staff_id.staff_info_id = swrd.staff_info_id

left join staff_absence on staff_absence.staff_info_id = swrd.staff_info_id

left join ticket_delivery_min5 tdm on tdm.staff_info_id = swrd.staff_info_id

left join delivery_percentage dp on dp.staff_info_id = swrd.staff_info_id

left join handover_14days h14 on h14.area_name = swrd.tiktok_area and h14.manage_region = swrd.region_name

left join finished_14days f14 on f14.area_name = swrd.tiktok_area and f14.manage_region = swrd.region_name

left join eight_act as ea on ea.staff_info_id = swrd.staff_info_id and  ea.路由日期 = swrd.stat_date

left join prout on prout.staff_info_id = swrd.staff_info_id

WHERE date(swrd.stat_date) = date_sub(curdate(),interval 1 day)
and date(nwrd.统计日期) = date_sub(curdate(),interval 1 day)
and swrd.job_title in ('13','110','452','1000')

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41
,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81
,82,83,84,85,86,87,88,89
)m1















