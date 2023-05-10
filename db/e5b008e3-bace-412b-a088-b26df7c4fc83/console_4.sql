select
    t.*,
    a.avg_decnt 网点人均可交接量
    ,if((t.入职时间 < date_sub(current_date,interval 7 day) and t.今日应派 > 200 and t.网点应派交接率>=0.95 and t.今日个人交接量>15 and t.今日个人交接量>0   and t.今日个人妥投量 <10 and t.今日个人揽收件量 <30  and t.今日派件时长 <3 and t.网点妥投率 <0.9 and sh.员工id is null)
     or ((t.入职时间 < date_sub(current_date,interval 7 day) and t.今日应派 > 200 and t.网点应派交接率<0.95 and t.今日个人交接量>0 and t.今日个人妥投量 <10 and t.今日个人揽收件量 <30  and t.今日派件时长 <3 and t.网点妥投率 <0.9 and sh.员工id is null))
     or((t.入职时间 < date_sub(current_date,interval 7 day) and (t.今日应派-t.网点交接量)>10 and t.今日个人揽收件量 <30 and t.今日个人交接量=0 and sh.员工id is null))
    ,"是","否") "是否低效"
    ,if(sh.员工id is not null,"是","")"通过审批支援"
    from (
    SELECT
    mr.`name`大区 ,
    mp.name 片区,
    hi.`sys_store_id` 网点id,
    ss.name 网点名称,
    hi.`staff_info_id` 员工工号 ,
    hi.`name`  员工姓名,
    case when jr.今日个人交接量 is null then 0 else jr.今日个人交接量 end 今日个人交接量,
    case when tt.个人妥投量 is null then 0 else tt.个人妥投量 end 今日个人妥投量 ,
    case when  jr.今日个人揽收件量 is null then 0 else jr.今日个人揽收件量 end 今日个人揽收件量 ,
    jr.上班打卡时间  '今日上班打卡时间', jr.下班打卡时间  '今日下班打卡时间',
    case when yp.应派 is null then 0 else  yp.应派 end '今日应派',
    case when yp.今日妥投量 is null then 0 else  yp.今日妥投量 end '网点妥投量'  ,
     case when yp.网点交接包裹量 is null then 0 else  yp.网点交接包裹量 end '网点交接量'  ,
       yp.应派 - yp.网点交接包裹量 网点应派未交接包裹量,
     case when yp.网点交接率 is null then 0 else  yp.网点交接率 end '网点应派交接率'  ,
    round((if(yp.今日妥投量 is null,0,yp.今日妥投量)/if(yp.应派 is null,0,yp.应派)),2) 网点妥投率,
    case hi.`state`  when 1 then "在职" when 2 then "离职" when 3 then "停职" end as 在职状态,
    CASE hi.`job_title` when 13 then "Bike" when 110 then "Van" when 1000 then "Tricycle" end as "岗位",
    CASE when hi.`formal` =1 then '正式' when  hi.`formal` =0 then '外协' end as '正式or外协',
    date(hi.`hire_date`) 入职时间,
     v2.`shift_start` ,v2.`shift_end` ,v2.`stat_date` ,
    round(tt.个人妥投量/jr.今日个人交接量,2) as "个人交接妥投率",
    case when  jr.揽收任务 is null then 0 else jr.揽收任务 end '今日揽收任务',
    jr.打卡时长  '今日打卡时长',
    case when jc.今日派件时长 is null then 0 else jc.今日派件时长 end 今日派件时长,
    jc.今日首次妥投时间,jc.今日倒数第二次妥投时间,jr.第一件揽收时间
from  ph_bi.`hr_staff_info` hi
left join `ph_staging`.`sys_store` ss on ss.`id` =hi.`sys_store_id`
left join `ph_staging`.`sys_manage_piece` mp on mp.`id` =ss.`manage_piece`
left join `ph_staging`.`sys_manage_region` mr on mr.id =ss.`manage_region`
left join
    (# 今日信息
select
    hi.`staff_info_id` ,
    gr.今日个人交接量, gr.大件数量, gr.大件占比, gr.小件数量,gr.小件占比,
    pp.今日个人揽收件量,pp.第一件揽收时间,rw.揽收任务,
    ad.上班打卡时间,ad.下班打卡时间,ad.打卡时长
from  ph_bi.`hr_staff_info` hi
left join(#今日个人交接
select
dt.`store_id`,
ss.`name` ,
dt.`staff_info_id`,
jt.`job_name` 职位,
COUNT(distinct dt.`pno`)  今日个人交接量,
count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dt.pno  ,null)) '大件数量',
concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dt.pno  ,null))/count(distinct dt.pno)*100,2),"%")  大件占比,
count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,null,dt.pno )) 小件数量,
concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,null,dt.pno ))/count(distinct dt.pno)*100,2),"%") 小件占比
from `ph_staging`.`ticket_delivery` dt
left join `ph_staging`.`parcel_info` pi on dt.`pno` = pi.`pno`
left join `ph_staging`.`sys_store` ss on dt.`store_id`  = ss.`id`
LEFT JOIN `ph_bi`.`hr_staff_info`  hr on hr.`staff_info_id` =dt.`staff_info_id`
LEFT JOIN ph_bi.`hr_job_title` jt on jt.`id` =hr.`job_title`
where date(convert_tz(dt.`delivery_at`,'+00:00','+08:00'))= date_sub(CURRENT_DATE,interval 1 day)
and dt.`transfered` = 0
and dt.`state` in (0,1,2)
GROUP BY 3
)gr on gr.`staff_info_id`=hi.`staff_info_id`

left join (#今日揽收
        select pi.`ticket_pickup_staff_info_id` ,p.第一件揽收时间,COUNT(DISTINCT(pi.`pno`)) 今日个人揽收件量
        from `ph_staging`.`parcel_info` pi
         left join   (#第一件揽收时间
          select pi.`ticket_pickup_staff_info_id` ,min(convert_tz(pi.`created_at`,  '+00:00', '+08:00')) 第一件揽收时间 from ph_staging.parcel_info pi
        where pi.`state` <9
	and date(convert_tz(pi.`created_at`,'+00:00','+08:00')) >=date_sub(CURRENT_DATE,interval 1 day)

        group by 1) p on p.`ticket_pickup_staff_info_id`=pi.`ticket_pickup_staff_info_id`

        where pi.`state` <9
	and date(convert_tz(pi.`created_at`,'+00:00','+08:00')) >=date_sub(CURRENT_DATE,interval 1 day)

        group by 1)pp  on pp.`ticket_pickup_staff_info_id` =hi.`staff_info_id`

    LEFT JOIN (#今日揽收任务数
select  tp.staff_info_id , COUNT(tp.id) 揽收任务
        from ph_staging.ticket_pickup tp
where date(convert_tz(tp.`created_at`,'+00:00','+08:00'))  >=date_sub(CURRENT_DATE,interval 1 day)

 and tp.`state` =2
group by 1) rw on rw.staff_info_id=hi.`staff_info_id`

left join (#今日出勤
    select v.`staff_info_id`  ,v.`attendance_started_at` 上班打卡时间,v.`attendance_end_at` 下班打卡时间, round(timestampdiff(second,v.`attendance_started_at`,v.`attendance_end_at`) / 3600,2) 打卡时长
    from ph_bi.`attendance_data_v2` v
    where v.`stat_date`  = date_sub(CURRENT_DATE,interval 1 day)
  )ad on ad.`staff_info_id`=hi.`staff_info_id`
) jr on jr.`staff_info_id`=hi.`staff_info_id`


left join ( #今日工作时长
select dc.`staff_info_id` , dc.`store_id` , round(dc.`duration` / 3600,2) 今日派件时长 ,dc.`first_delivery_finish_time` 今日首次妥投时间 ,dc.stat_end 今日倒数第二次妥投时间
from `ph_bi`.`delivery_count_staff` dc
left join `ph_staging`.`sys_store` ss on dc.`store_id` = ss.`id`
where dc.`finished_at` =date_sub(CURRENT_DATE,interval 1 day)
and dc.`duration` <> 0
group by 1) jc on jc.staff_info_id=hi.`staff_info_id`

LEFT JOIN (#今日派送人数
    SELECT case
                   when pi.dst_store_id = 'PH39070101' and pi.duty_store_id in ('PH39070102','PH59030100') THEN pi.duty_store_id
                   else pi.`dst_store_id`
      end 目的地网点id,
       count(DISTINCT pi.`ticket_delivery_staff_info_id`) 参与派送人数,
       count(DISTINCT pi.`pno`) 处理量
  FROM `ph_staging`.`parcel_info` pi
   left join ph_bi.`hr_staff_info` hi on hi.`staff_info_id` =pi.`ticket_delivery_staff_info_id`
 WHERE pi.`finished_at` >=convert_tz(date_sub(CURRENT_DATE,interval 1 day) , '+08:00', '+00:00')
     and  pi.`finished_at` <=convert_tz(CURRENT_DATE , '+08:00', '+00:00')
    and hi.`job_title` in(110,13,1000)
    and pi.`ticket_delivery_staff_info_id` >300000
 GROUP BY 1)ck on ck.目的地网点id=hi.`sys_store_id`
LEFT JOIN ( #今日应派妥投
  select dc.store_id,
count(distinct dc.pno) 应派,
 COUNT(DISTINCT(if(date(convert_tz(pi.`finished_at`,"+00:00" ,"+08:00"))=date_sub(CURRENT_DATE,interval 1 day),dc.`pno` ,null))) 今日妥投量,
 COUNT(distinct if(td.`pno` is not null,dc.pno,null))网点交接包裹量  ,
  COUNT(distinct if(td.`pno` is not null,dc.pno,null))/count(distinct dc.pno) 网点交接率,
concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dc.pno  ,null))/count(distinct dc.pno)*100,2),"%")  大件占比
from  ph_bi.`dc_should_delivery_today` dc
LEFT JOIN `ph_staging`.parcel_info  pi on dc.`pno` =pi.`pno`
left  join `ph_staging`.`ticket_delivery` td on td.`pno` =dc.pno and date(convert_tz(td.`delivery_at` ,"+00:00","+08:00"))= dc.stat_date and td.`state` in (0,1,2)
    where dc.`stat_date` = date_sub(CURRENT_DATE,interval 1 day)
        and dc.state<6
    group by 1
    ) yp  on yp.`store_id`=hi.`sys_store_id`
LEFT JOIN ( #今日妥投
    select
    pi.`ticket_delivery_staff_info_id` ,COUNT(DISTINCT pi.`pno`) 个人妥投量
    from `ph_staging`.parcel_info pi
   LEFT JOIN `ph_bi`.`hr_staff_info`  hr on hr.`staff_info_id` =pi.`ticket_delivery_staff_info_id`
    left join `ph_staging`.`sys_store` ss on hr.`sys_store_id`  = ss.`id`
    where pi.`state` =5
    and  date(convert_tz(pi.`finished_at`,"+00:00","+08:00"))=date_sub(CURRENT_DATE,interval 1 day)
    GROUP by 1) tt on tt.`ticket_delivery_staff_info_id`=hi.`staff_info_id`
left join ph_bi.`attendance_data_v2` v2 on v2.`staff_info_id` =hi.`staff_info_id` and v2.`stat_date` =date_sub(CURRENT_DATE,interval 1 day)
where hi.`state` in (1,3)
and hi.`job_title` in (13,110,1000)
and hi.`is_sub_staff`= 0
and hi.`formal`= 1
and ss.`category`  in (1)
and ss.`state` =1
#and jr.今日个人交接量 is not null
order by 1,2,3,4,5,14
) t
left join (#网点人均可交接
        select
        dc.`stat_date`
        ,dc.`store_id`
        ,ss.`name`
        ,COUNT(distinct dc.`pno`)  cnt
        ,round(COUNT(distinct dc.`pno`)/count(distinct td.`staff_info_id` ) ,0) avg_decnt
        FROM dwm.dwd_ph_dc_should_delivery_d dc
        left join `ph_staging`.`ticket_delivery` td on td.`pno` =dc.`pno` and dc.`stat_date` =date(convert_tz(td.`delivery_at`,"+00:00","+08:00")) and td.`state`in (0,1,2)
        left join ph_bi.`sys_store` ss on ss.`id` =dc.`store_id`
        where dc.`stat_date` =date_sub(CURRENT_DATE ,interval 1 day)
        and ss.`category` =1
         and dc.`state` <6
        GROUP BY 1,2,3 )
        a on a.store_id=t.网点id
left join (# 删掉支援人员
          SELECT
        hrs.`store_id` 被支援网点id
        ,hrs.`store_name` 被支援网点
        ,hrs.`staff_info_id`  员工id
        ,date(hr.`hire_date`) 入职日期
        ,ss.`name`  员工所属网点
        ,date_sub(CURRENT_DATE,interval 1 day) 统计日期
        ,jt.`job_name`  申请支援职位名称
        ,hrs.`employment_begin_date`  支援开始日期
        ,hrs.`employment_end_date`  支援结束日期
        ,hrs.`employment_days`  支援天数
          FROM  `ph_backyard`.`hr_staff_apply_support_store` hrs

        LEFT JOIN  `ph_bi`.`hr_job_title`  jt
        on jt.`id` =hrs.`job_title_id`

        LEFT JOIN  ph_bi.`hr_staff_info` hr
        on hr.`staff_info_id` =hrs.`staff_info_id`

        LEFT JOIN `ph_staging`.`sys_store`  ss
        on ss.`id` =hr.`sys_store_id`
          where hrs.`status` =2
        and hr.`job_title`  in(13,110,1000)
        and date_sub(CURRENT_DATE,interval 1 day)>= hrs.`employment_begin_date`
        and date_sub(CURRENT_DATE,interval 1 day)<= hrs.employment_end_date
   ) sh on sh.员工id=t.员工工号
where (t.今日上班打卡时间 is not null or t.今日下班打卡时间 is not null)

;





;


select
    plt.pno
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
where
    plt.state in (5,6)
    and (pi.dst_phone = '09918919066'
    or pi.src_phone = '09918919066')

;



select
    a.pno
    ,a.cod_num cod金额
    ,a.end_date 派送时效
    ,a.client_id
    ,a.parcel_state_name 包裹状态
    ,a.pickup_time 揽收时间
    ,a.last_cn_route_action 最后一条有效路由
    ,a.last_route_time 最后一条有效路由时间
    ,a.last_store_name 包裹当前网点
    ,a.last_store_id 包裹当前网点ID
    ,a.dst_routed_at 目的地网点的第一次有效路由时间
    ,a.first_cn_marker_category 第一次尝试派送失败原因
    ,a.first_marker_at 第一次尝试派送失败时间
    ,a.dst_store 目的地网点
    ,a.dst_region 目的地网点大区
    ,a.dst_piece 目的地网点片区
    ,if(plt.pno is not null , '是', '否') 是否人工无需追责过
from
    (
        select
            de.*
            ,case bc.client_name
                when 'lazada' then dl.delievey_end_date
                when 'shopee' then ds.end_date
                when 'tiktok' then dt.end_date
            end end_date
            ,pi.cod_amount/100 cod_num
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info pi on pi.pno = de.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
        left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = de.pno
        left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = de.pno
        left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = de.pno
    ) a
left join ph_bi.parcel_lose_task plt on plt.pno = a.pno and plt.state = 5 and plt.operator_id not in (10000,10001)
where
    a.parcel_state not in (5,7,8,9)
    and a.end_date < curdate()
    and a.cod_num > 10000
group by 1


;

select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.state
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > pi.created_at and pr.routed_at > '2023-04-26 16:00:00' and pr.route_action in ('RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
        where
            pi.created_at >= '2023-04-26 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count

;

 select
    pi.pack_no
    ,pi.state
    ,pi.seal_count
    ,psd.pno
    ,pr.pno
from ph_staging.pack_info pi
left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > '2023-04-26 16:00:00' and pr.route_action in ('RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
where
    pi.created_at >= '2023-04-26 16:00:00'
    and pi.created_at < '2023-05-08 16:00:00'
#             and pi.created_at < '2023-04-27 16:00:00'
#             and pr.pno is null
    and pi.pack_no = 'P55500745'
    and pr.pno is not null
