SELECT
swrd.`统计日期` 统计日期date
,swrd.`staff_info_id` staff_info_id
,swrd.`员工手机号` 员工手机号employee_contact_number
,swrd.`工龄` 工龄length_of_service
,swrd.`当日岗位` 当日岗位position

,ss.name 原网点original_DC
,smr.name 原网点所属大区
,smp.name 原网点所属片区

,swrd.`当日所属网点` 当日所属网点DC_where_the_courier_stay_at_on_that_day
,swrd.`网点类型` 网点类型DC_type
,swrd.`大区` 大区Area
,swrd.`片区` 片区district


,case swrd.`员工属性`
    when '自有员工' then '自有员工 in house courier'
    when '支援员工' then '支援员工 support courier'
    when '外协员工' then '外协员工 outsource courier'
end 员工属性employee_type


,CONCAT(swa.shift_start,"-",swa.shift_end) 考勤时间attendance_record_time
,swa.shift_start  班次开始时间
,swa.shift_end    班次结束时间

,jr.上班打卡时间
,jr.下班打卡时间
,jr.打卡时长
,case when jr.上班打卡时间 > swa.shift_start then '迟到' else '未迟到' end as 是否迟到

,date_format(ft.arrive_time_first,'%Y-%m-%d %H:%i') as 正班车第一趟到达时间
,date_format(ft.arrive_time_last,'%Y-%m-%d %H:%i') as  正班车最后一趟到达时间

,swrd.`最早交接时间` 最早交接时间earlist_handover_time
,swrd.`最近交接时间` 最近交接时间latest_handover_time
,round(timestampdiff(second,jr.上班打卡时间,swrd.最早交接时间) / 60,2) 时长上班_首次交接
,swrd.`最早派件时间` 最早派件时间earlist_successfully_delivered_time
,swrd.`最近派件时间` 最近派件时间latest_successfully_delivered_time
,case when swrd.`最近交接时间` < swrd.`最早派件时间` then '否' else '是' end as 首次妥投之后是否有二次交接


,swrd.`揽件量` 揽件量pickup_volume
,case when  jr.ids is null then 0 else jr.ids end 当日揽收任务

##,jr.delivery_pno 交接量liuxia
##,jr.大件数量 交接大件数量
##,jr.大件占比 交接大件占比
##,jr.小件数量 交接小件数量
##,jr.小件占比 交接小件占比


,nwrd.当日应派  as 网点当日应派包裹量
,nwrd.当日到件入仓量
,nwrd.当日应派交接 as 网点当日应派交接包裹量
,nwrd.当日应派妥投 as 网点当日应派妥投包裹量
,nwrd.应派交接率   as 网点当日应派交接率
,nwrd.妥投率      as 网点当日应派妥投率
,nwrd.积压量
,nwrd.未交接量
,a.avg_decnt 网点人均可交接量

,case when yp.应派 is null then 0 else  yp.应派 end '网点应派量'
,case when yp.今日妥投量 is null then 0 else  yp.今日妥投量 end '网点妥投量'
,case when yp.网点交接包裹量 is null then 0 else  yp.网点交接包裹量 end '网点交接量'
,yp.应派 - yp.网点交接包裹量 网点应派未交接包裹量
,case when yp.网点交接率 is null then 0 else  yp.网点交接率 end '网点应派交接率'
,round((if(yp.今日妥投量 is null,0,yp.今日妥投量)/if(yp.应派 is null,0,yp.应派)),2) 网点应派妥投率

,jc.今日首次妥投时间
,jc.今日倒数第二次妥投时间
,case when jc.今日派件时长 is null then 0 else jc.今日派件时长 end 今日派件时长

,jr.first_pickup_time 第一件揽收时间
,tt.个人妥投量 as 个人妥投量

,swrd.`交接量` 交接量handover_volume
,area_delivery.交接区域数量 交接区域数量number_of_handover_area
,area_delivery.交接情况 交接情况handover_area_details

,sdbsi.三段码绑定数量 三段码绑定数量three_segment_code_binding_quantity
,sdbsi.三段码绑定情况 三段码绑定情况three_segment_code_binding_details
,sdbsi.barangay绑定数量 barangay绑定数量barangay_binding_quantity
,sdbsi.绑定明细情况 绑定明细情况barangay_binding_details

,swrd.`当天派件数` 妥投量successfully_delivered
,area_delivery.妥投区域数量 妥投区域数量number_of_areas_in_where_contains_successfully_delivered_parcels
,area_delivery.妥投情况 妥投情况successfully_delivered_details


,swrd.`拒收包裹数` 拒收包裹数number_of_reject
,swrd.`运力不足包裹数` 运力不足包裹数number_of_manpower_shortage
,swrd.`改约包裹数` 改约包裹数number_of_reschedule
,swrd.`联系不上包裹数` 联系不上包裹数number_of_unable_to_contact_consignee

,swrd.`派件间隔(分钟)` '派件间隔(分钟)time_interval_of_deliveries(min)'
,swrd.`派件/交接` '派件/交接delivered/handovered'
,swrd.`5KG以上` '5KG以上above_5KG'



,swrd.`派件工作时间` 派件时长delivering_time_period

,swrd.`最早揽件时间` 最早揽件时间earliest_pickup_time
,swrd.`最近揽件时间` 最近揽件时间latest_pickup_time
,swrd.`揽件工作时间` 揽件时长picking_up_time_period
,swrd.`网点当日派件人数` 网点当日派件人数number_of_couriers_who_do_delivery
,swrd.`人效排名` 人效排名rank_of_human_efficiency

,case when swrd.网点类型 = 'SP' and swrd.员工属性 in ('自有员工','支援员工') and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and ifnull(swrd.交接量,0) < 40 then '交接不达标 handover volume does not reach the standard' end 交接不达标handover_volume_does_not_reach_the_standard
,case when swrd.网点类型 = 'SP' and swrd.员工属性 in ('自有员工','支援员工') and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and ifnull(swrd.当天派件数,0) < 30 then '妥投不达标 successfully delivered volume does not reach the standard' end 妥投不达标successfully_delivered_volume_dose_not_reach_the_standard
,CASE WHEN swrd.网点类型 = 'SP' and swrd.员工属性 in ('自有员工','支援员工') and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and ifnull(swrd.当天派件数,0)/nwrd.当日人效<0.8  THEN '相对人效低 relatively low human efficiency' END 相对人效低relatively_low_human_efficiency
,CASE WHEN swrd.网点类型 = 'SP' and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and swrd.最早派件时间 IS NULL AND swrd.当天派件数 > 0 THEN '网点50m范围内派送 delivery mark within 50 meters from DC' END 派件地点作弊嫌疑suspect_fake_delivered_location
,CASE WHEN swrd.网点类型 = 'SP' and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and swrd.交接量>ROUND((nwrd.正式快递员交接量+nwrd.支援交接量)/(nwrd.交接的正式快递员数量+nwrd.交接的支援快递员数量))*3 then '超量交接 excessively handover' end 超量交接作弊嫌疑suspect_fake_excessively_handover_
,case when swrd.网点类型 = 'SP' and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and swrd.当天派件数>ROUND((nwrd.正式快递员派件量+nwrd.支援派件量)/(nwrd.派件的正式快递员数量+nwrd.派件的支援员工数量))*3 THEN '超量妥投 excessively successfully delivered' END 超量妥投作弊嫌疑suspect_fake_excessively_successfully_delivered
,CASE WHEN swrd.网点类型 = 'SP' and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and swrd.派件工作时间<GREATEST (6,nwrd.'正式快递员派送时长/h'*0.8) or swrd.派件工作时间 is null THEN '派件时长短 short delivering time period ' END 派件时长短short_delivering_time_period
,CASE WHEN swrd.网点类型 = 'SP' and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and ((ifnull(swrd.拒收包裹数,0)+ifnull(swrd.运力不足包裹数,0)+ifnull(swrd.改约包裹数,0)+ifnull(swrd.联系不上包裹数,0))>10 OR (ifnull(swrd.拒收包裹数,0)+ifnull(swrd.运力不足包裹数,0)+ifnull(swrd.改约包裹数,0)+ifnull(swrd.联系不上包裹数,0))/swrd.交接量>0.1) THEN '问题件数量多 many problematic parcels' END 问题件数量多many_problematic_parcels
,case when swrd.网点类型 = 'SP' and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and swrd.最早派件时间 > nwrd.最晚出门时间 or swrd.最早派件时间 is null then '出门派件时间晚 late depature for delivery' else null  end 出门派件时间晚late_depature_for_delivery
,case when swrd.网点类型 = 'SP' and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and area_delivery.第二区域交接数 > 3 then '交接区域不规范 non-standard handover as per barangay' end 交接区域不规范non_standard_handover_as_per_barangay
,case when swrd.网点类型 in ('SP','PDC') and swrd.当日岗位 in ('Bike','VAN','Boat','Tricycle') and (sum(ifnull(swrd.揽件量,0)+ifnull(swrd.当天派件数,0)) over(partition by swrd.staff_info_id)) = 0 then '旷工absent' end 旷工嫌疑suspect_absent

,ROUND((nwrd.正式快递员交接量+nwrd.支援交接量)/(nwrd.交接的正式快递员数量+nwrd.交接的支援快递员数量))  `网点自有+支援人均交接average_handover_volume_of_in_house_couriers_and_support_couriers`
,ROUND((nwrd.正式快递员派件量+nwrd.支援派件量)/(nwrd.派件的正式快递员数量+nwrd.派件的支援员工数量))  `网点自有+支援人均妥投average_successfully_delivered__volume_of_in_house_couriers_and_support_couriers`
,ROUND((ifnull(nwrd.正式快递员交接量,0)+ifnull(nwrd.支援交接量,0)+ifnull(nwrd.外协交接量,0))/(ifnull(nwrd.交接的正式快递员数量,0)+ifnull(nwrd.交接的支援快递员数量,0)+ifnull(nwrd.交接的外协快递员数量,0)))  `网点自有+支援+外协人均交接average_handover_volume_of_in_house_couriers,_support_couriers_and_outsource_couriers`
,ROUND((ifnull(nwrd.正式快递员派件量,0)+ifnull(nwrd.支援派件量,0)+ifnull(nwrd.外协派件量,0))/(ifnull(nwrd.派件的正式快递员数量,0)+ifnull(nwrd.派件的支援员工数量,0)+ifnull(nwrd.派件的外协员工数量,0)))  `网点自有+支援+外协人均妥投average_successfully_delivered__volume_of_in_house_couriers,_support_couriers_and_outsource_couriers`

,nwrd.正式快递员出勤标准  网点出勤标准attendance_standar_of_DC
,nwrd.当日人效  `网点当日人效(自有human_efficiency_(in_house_courier))`
,nwrd.'正式快递员派送时长/h'  '网点正式快递员派送时长/h in_house_regular_courier_delivering_time_period/h'
,swrd.`数据更新时间/菲律宾` '数据更新时间/菲律宾update_time/Philippines'

FROM tmpale.staff_work_report_daily swrd ## 快递员每日工作情况播报

LEFT JOIN tmpale.network_work_report_daily nwrd ## 网点每日工作情况播报
on swrd.当日所属网点 = nwrd.网点
and swrd.统计日期 = nwrd.统计日期

left join ph_bi.hr_staff_info hsi ##员工表
on swrd.staff_info_id = hsi.staff_info_id

left join ph_staging.sys_store ss ##网点表
on hsi.sys_store_id = ss.id


left join ph_staging.sys_manage_piece smp ##大区
on smp.id=ss.manage_piece

left join ph_staging.sys_manage_region smr ##片区
on smr.id=ss.manage_region

LEFT JOIN ph_backyard.staff_work_attendance swa ##员工考勤表
ON swa.staff_info_id = swrd.staff_info_id
AND swa.attendance_date = DATE(convert_tz(NOW(),'+08:00','+08:00'))


left join
(# 今日信息
    select
        gr.delivery_at              ##交接时间
        ,gr.staff_info_id           ##工号
        ,gr.delivery_pno            ##交接量
        ,gr.大件数量
        ,gr.大件占比
        ,gr.小件数量
        ,gr.小件占比
        ,rw.ids                     ##揽收任务
        ,pp.pnos                    ##今日个人揽收件量
        ,pp.first_pickup_time       ##第一件揽收时间
        ,ad.上班打卡时间
        ,ad.下班打卡时间
        ,ad.打卡时长

    from
    (#交接
        select  date(convert_tz(dt.delivery_at,'+00:00','+08:00')) as delivery_at##交接时间
            ,dt.`store_id` ##网点编号
            ,ss.`name`     ##网点名称
            ,dt.`staff_info_id`##派件员工号
            ,jt.`job_name` ##职位
            ,COUNT(distinct dt.`pno`)  delivery_pno ##交接量
            ,count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dt.pno  ,null)) '大件数量'
            ,concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dt.pno  ,null))/count(distinct dt.pno)*100,2),"%")  大件占比
            ,count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,null,dt.pno )) 小件数量
            ,concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,null,dt.pno ))/count(distinct dt.pno)*100,2),"%") 小件占比
        from `ph_staging`.`ticket_delivery` dt
        left join `ph_staging`.`parcel_info` pi on dt.`pno` = pi.`pno`
        left join `ph_staging`.`sys_store` ss on dt.`store_id`  = ss.`id`
        LEFT JOIN `ph_bi`.`hr_staff_info`  hr on hr.`staff_info_id` =dt.`staff_info_id`
        LEFT JOIN ph_bi.`hr_job_title` jt on jt.`id` =hr.`job_title`
        where 1=1##date(convert_tz(dt.`delivery_at`,'+00:00','+08:00'))= date_sub(CURRENT_DATE,interval 1 day)
            and  date(convert_tz(dt.`delivery_at`,'+00:00','+08:00'))>='${sdate}'
            and  date(convert_tz(dt.`delivery_at`,'+00:00','+08:00'))<='${edate}'
            and dt.`transfered` = 0
            and dt.`state` in (0,1,2)
        GROUP BY 1,2,3,4,5
    )gr



    left join
    (#揽收
        select
            t2.pickup_dt ##揽收时间
            ,t2.ticket_pickup_staff_info_id
            ,p.first_pickup_time ##首次揽收时间
            ,t2.pnos ##揽收量
        from
            (
            select
                date(convert_tz(pi.created_at,'+00:00','+08:00')) as pickup_dt ##揽收时间
                ,pi.ticket_pickup_staff_info_id ##收件员工工号
                ,COUNT(DISTINCT pi.pno) pnos
            from ph_staging.parcel_info pi
            where ##pi.`state` < 9
                  pi.state <> 9 ##（非无效件）
                  and pi.returned = 0 ##（非退件）
                  ##and date(convert_tz(pi.`created_at`,'+00:00','+08:00')) >=date_sub(CURRENT_DATE,interval 1 day)
                  and date(convert_tz(pi.`created_at`,'+00:00','+08:00')) >= '${sdate}'
                  and date(convert_tz(pi.`created_at`,'+00:00','+08:00')) <= '${edate}'
            group by 1,2
            )t2
            left join
            (#第一件揽收时间
            select t1.ticket_pickup_staff_info_id
                ,t1.created_time as first_pickup_time
                ,date(t1.created_time) as first_pickup_dt ##揽收时间
            from
                (
                select pi.ticket_pickup_staff_info_id ##收件员工工号
                    ,convert_tz(pi.created_at,  '+00:00', '+08:00') created_time
                    ##,min(convert_tz(pi.created_at,  '+00:00', '+08:00')) 第一件揽收时间
                    ,row_number() over (partition by pi.ticket_pickup_staff_info_id,date(convert_tz(pi.created_at,'+00:00','+08:00')) order by convert_tz(pi.created_at,  '+00:00', '+08:00') asc) as rn
                from ph_staging.parcel_info pi
                where ##pi.`state` < 9
                    pi.state <> 9 ##（非无效件）
                    and pi.returned = 0 ##（非退件）
                    ##and date(convert_tz(pi.`created_at`,'+00:00','+08:00')) >=date_sub(CURRENT_DATE,interval 1 day)
                    and date(convert_tz(pi.`created_at`,'+00:00','+08:00'))>='${sdate}'
                    and date(convert_tz(pi.`created_at`,'+00:00','+08:00'))<='${edate}'
                )t1
            where t1.rn = 1
            group by 1,2,3
            )p
            on p.ticket_pickup_staff_info_id=t2.ticket_pickup_staff_info_id and p.first_pickup_dt = t2.pickup_dt
        group by 1,2
    )pp
    on pp.ticket_pickup_staff_info_id = gr.staff_info_id and pp.pickup_dt = gr.delivery_at


    LEFT JOIN
    (#今日揽收任务数
        select
            date(convert_tz(tp.created_at,'+00:00','+08:00')) as created_at##任务创建时间
            ,tp.staff_info_id ##工号
            ,COUNT(tp.id) ids ##揽收任务
        from ph_staging.ticket_pickup tp
        where tp.state =2
            and date(convert_tz(tp.created_at,'+00:00','+08:00'))>='${sdate}'
            and date(convert_tz(tp.created_at,'+00:00','+08:00'))<='${edate}'
    group by 1,2
    ) rw
    on rw.staff_info_id = gr.staff_info_id and gr.delivery_at = rw.created_at

    left join
    (#今日出勤
        select
            date(convert_tz(v.stat_date,'+00:00','+08:00')) as stat_dt ##出勤日期
            ,v.`staff_info_id`
            ,v.`attendance_started_at` 上班打卡时间
            ,v.`attendance_end_at` 下班打卡时间
            ,round(timestampdiff(second,v.`attendance_started_at`,v.`attendance_end_at`) / 3600,2) 打卡时长
        from ph_bi.attendance_data_v2 v
        where ##v.`stat_date`  = date_sub(CURRENT_DATE,interval 1 day)
            date(convert_tz(v.stat_date,'+00:00','+08:00'))>='${sdate}'
            and date(convert_tz(v.stat_date,'+00:00','+08:00'))<='${edate}'
        group by 1,2,3,4,5
      )ad
    on ad.staff_info_id=gr.staff_info_id and gr.delivery_at = ad.stat_dt
) jr
on jr.staff_info_id = swrd.staff_info_id and jr.delivery_at = swrd.统计日期

left join
(#今日工作时长
select dc.`staff_info_id`
     ,dc.`store_id`
     ,ss.name
     ,dc.finished_at ##工作日期
     ,round(dc.`duration` / 3600,2) 今日派件时长
     ,dc.`first_delivery_finish_time` 今日首次妥投时间
     ,dc.stat_end 今日倒数第二次妥投时间
from ph_bi.delivery_count_staff dc
left join ph_staging.sys_store ss on dc.`store_id` = ss.`id`
where 1=1##dc.finished_at =date_sub(CURRENT_DATE,interval 1 day)
and dc.finished_at >= '${sdate}'
and dc.finished_at <='${edate}'
and dc.duration <> 0
group by 1,2,3,4,5,6,7
) jc
on jc.staff_info_id = swrd.staff_info_id and jc.finished_at = swrd.统计日期 and swrd.`当日所属网点`  = jc.name

LEFT JOIN
( #今日应派妥投
    select dc.store_id,ss.name,
        date(convert_tz(dc.stat_date,'+00:00','+08:00')) stat_date,
        count(distinct dc.pno) 应派,
        COUNT(DISTINCT(if(date(convert_tz(pi.`finished_at`,"+00:00" ,"+08:00"))= dc.stat_date,dc.`pno` ,null))) 今日妥投量,
        COUNT(distinct if(td.`pno` is not null,dc.pno,null))网点交接包裹量  ,
        round(COUNT(distinct if(td.`pno` is not null,dc.pno,null))/count(distinct dc.pno),2) 网点交接率,
        concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dc.pno  ,null))/count(distinct dc.pno)*100,2),"%")  大件占比
    from ph_bi.dc_should_delivery_today dc
    left join ph_staging.sys_store ss on dc.`store_id` = ss.`id`
    LEFT JOIN ph_staging.parcel_info  pi on dc.`pno` =pi.`pno`
    left join ph_staging.ticket_delivery td
    on td.pno =dc.pno and date(convert_tz(td.delivery_at ,"+00:00","+08:00"))= date(convert_tz(dc.stat_date,'+00:00','+08:00')) and td.`state` in (0,1,2)
    where ##dc.stat_date = date_sub(CURRENT_DATE,interval 1 day)
        date(convert_tz(dc.stat_date,'+00:00','+08:00'))>='${sdate}'##妥投时间
        and date(convert_tz(dc.stat_date,'+00:00','+08:00'))<='${edate}'
        and dc.state<6
    group by 1,2,3
) yp
on yp.name = swrd.`当日所属网点` and yp.stat_date = swrd.统计日期

LEFT JOIN
( #今日妥投
    select date(convert_tz(pi.`finished_at`,'+00:00','+08:00')) as finished_at##日期
        ,pi.`ticket_delivery_staff_info_id`
        ,ss.name
        ,COUNT(DISTINCT pi.`pno`) 个人妥投量
    from ph_staging.parcel_info pi
    LEFT JOIN `ph_bi`.`hr_staff_info`  hr on hr.`staff_info_id` =pi.`ticket_delivery_staff_info_id`
    left join `ph_staging`.`sys_store` ss on hr.`sys_store_id`  = ss.`id`
    where pi.`state` =5
    ##and date(convert_tz(pi.`finished_at`,"+00:00","+08:00"))=date_sub(CURRENT_DATE,interval 1 day)
    and date(convert_tz(pi.`finished_at`,'+00:00','+08:00'))>='${sdate}'##妥投时间
    and date(convert_tz(pi.`finished_at`,'+00:00','+08:00'))<='${edate}'
    GROUP by 1,2,3
) tt
on tt.ticket_delivery_staff_info_id=swrd.staff_info_id and tt.finished_at=swrd.统计日期 and tt.name = swrd.`当日所属网点`

left join
(#网点人均可交接
    select
        date(dc.stat_date) stat_date
        ,dc.store_id
        ,ss.name
        ,COUNT(distinct dc.`pno`)  cnt
        ,round(COUNT(distinct dc.`pno`)/count(distinct td.`staff_info_id` ) ,0) avg_decnt
    FROM dwm.dwd_ph_dc_should_delivery_d dc
    left join `ph_staging`.`ticket_delivery` td
    on td.`pno` =dc.`pno` and dc.`stat_date` =date(convert_tz(td.`delivery_at`,"+00:00","+08:00")) and td.`state`in (0,1,2)
    left join ph_bi.`sys_store` ss on ss.`id` =dc.`store_id`
    where ##dc.`stat_date` =date_sub(CURRENT_DATE ,interval 1 day)
        date(dc.stat_date) >='${sdate}'
        and date(dc.stat_date) <='${edate}'
        and ss.`category` =1
        and dc.`state` <6
    GROUP BY 1,2,3
)a
on a.name = swrd.`当日所属网点` and a.stat_date=swrd.统计日期


left join
(
##网点正班车到达时间
select date(ft.real_arrive_time) as proof_dt##日期
    ,ft.next_store_id
    ,ft.next_store_name
    ,ft11.real_arrive_time as arrive_time_first##正班车第一趟到达时间
    ,ft22.real_arrive_time as arrive_time_last##正班车最后一趟到达时间

from ph_bi.fleet_time ft

left join
(##最早到达时间
    select ft1.next_store_id
        ,ft1.next_store_name
        ,ft1.real_arrive_time
        ,ft1.proof_id
        ,ft1.rn
    from
    (
        select next_store_id
            ,next_store_name
            ,real_arrive_time
            ,proof_id
            ,row_number() over (partition by date(real_arrive_time),next_store_id order by real_arrive_time asc) as rn
        from ph_bi.fleet_time
        where 1=1
            and line_mode =1
            and arrive_type in ('3','5')
            and fleet_status in ('1')
            and date(real_arrive_time) >='${sdate}'
            and date(real_arrive_time) <='${edate}'
    )ft1
    where rn = 1
)ft11
on ft.proof_id = ft11.proof_id
left join (
    ##最晚到达时间
    select ft2.next_store_id
        ,ft2.next_store_name
        ,ft2.real_arrive_time
        ,ft2.proof_id
        ,ft2.rn
    from (
        select next_store_id
            ,next_store_name
            ,real_arrive_time
            ,proof_id
            ,row_number() over (partition by date(real_arrive_time),next_store_id order by real_arrive_time desc) as rn
        from ph_bi.fleet_time
        where 1=1
            and line_mode =1
            and arrive_type in ('3','5')
            and fleet_status in ('1')
            and date(real_arrive_time) >='${sdate}'
            and date(real_arrive_time) <='${edate}'
    )ft2
    where rn = 1
)ft22
on ft.proof_id = ft22.proof_id
where 1=1
    and date(ft.real_arrive_time) >='${sdate}'
    and date(ft.real_arrive_time) <='${edate}'
    and ft11.real_arrive_time is not null
    and ft22.real_arrive_time is not null
group by 1,2,3,4,5
)ft
##日期+网点关联
on ft.next_store_name = swrd.当日所属网点  and ft.proof_dt = swrd.统计日期

left join # 快递员绑定情况

(
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
) sdbsi
on sdbsi.store_id = ss.id
and sdbsi.staff_info_id = swrd.staff_info_id

left join

(
    select
    t1.大区
    ,t1.片区
    ,t1.分拣大区
    ,t1.网点名称
    ,t1.tiktok_area
    ,t1.lazada_area
    ,t1.shopee_area
    ,t1.快递员姓名
    ,t1.员工ID
    ,t1.快递员职位
    ,t1.交接区域数量
    ,t1.交接数
    ,t1.第二区域交接数
    ,t1.交接情况
    ,t2.妥投区域数量
    ,t2.妥投数
    ,t2.妥投情况
    from
    (
        select
        tt.大区
        ,tt.片区
        ,tt.分拣大区
        ,tt.网点名称
        ,tt.tiktok_area
        ,tt.lazada_area
        ,tt.shopee_area
        ,tt.快递员姓名
        ,tt.员工ID
        ,tt.快递员职位
        ,count(distinct tt.三段码) 交接区域数量
        ,sum(tt.交接包裹数) 交接数
        ,group_concat(concat(tt.三段码,':',tt.交接包裹数,'(',tt.当日在仓,')') order by tt.交接包裹数 desc SEPARATOR ' / ') 交接情况
        ,tt.第二区域交接数
        from
        (
            select
            mr.name `大区`
            ,mp.name `片区`
            ,ssd.sorting_no `分拣大区`
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

            join tmpale.parcel_in_warehouse_today dsdt
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
            on dsdt.pno = ddpsci.pno
            and ddpsci.rk = 1

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

            FROM tmpale.parcel_in_warehouse_today dsdt

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
            and dsdt.stat_date = date_sub(current_date(),0)
            and ssd.category in ('1','10')
            GROUP BY 1,2,3,4
            order by 1,2,3,4
            )sdmzc
            on sdmzc.网点名称 = ssd.name
            and sdmzc.区域编码 = ddpsci.third_sorting_code

            where 1=1
            and td.created_at >= convert_tz(date_sub(curdate(),0),'+08:00','+00:00')
            and td.state <> 3
            group by 1,2,3,4,5,6,7,8,9,10,11,12
        ) tt
        group by 1,2,3,4,5,6,7,8,9,10
    ) t1

    left join

    (
        select
        tt.大区
        ,tt.片区
        ,tt.分拣大区
        ,tt.网点名称
        ,tt.tiktok_area
        ,tt.lazada_area
        ,tt.shopee_area
        ,tt.快递员姓名
        ,tt.员工ID
        ,tt.快递员职位
        ,count(distinct tt.三段码) 妥投区域数量
        ,sum(tt.妥投包裹数) 妥投数
        ,group_concat(concat(tt.三段码,':',tt.妥投包裹数) order by tt.妥投包裹数 desc SEPARATOR ' / ') 妥投情况
        from
        (
            select
            mr.name `大区`
            ,mp.name `片区`
            ,ssd.sorting_no `分拣大区`
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

            join tmpale.parcel_in_warehouse_today dsdt
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
            on dsdt.pno = ddpsci.pno
            and ddpsci.rk = 1

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
            and pi.finished_at >= convert_tz(date_sub(curdate(),0),'+08:00','+00:00')
            group by 1,2,3,4,5,6,7,8,9,10,11
        ) tt
        group by 1,2,3,4,5,6,7,8,9,10
    ) t2

    on t1.网点名称 = t2.网点名称
    and t1.员工ID = t2.员工ID
) area_delivery
on swrd.当日所属网点 = area_delivery.网点名称
and swrd.staff_info_id = area_delivery.员工ID
WHERE ##swrd.统计日期 = DATE(convert_tz(NOW(),'+08:00','+08:00'));
date(convert_tz(swrd.统计日期,'+00:00','+08:00'))>='${sdate}'
and date(convert_tz(swrd.统计日期,'+00:00','+08:00'))<='${edate}'















