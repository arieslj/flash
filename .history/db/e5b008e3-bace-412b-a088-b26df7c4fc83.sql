with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
, b as
(
    select
        pr2.pno
        ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        ,pr2.staff_info_id
        ,pr2.store_id
    from ph_staging.parcel_route pr2
    join
        (
            select a.pno from a group by 1
        ) b on pr2.pno = b.pno
    where
        pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr2.routed_at >= '2023-03-31 16:00:00'
)
select
    a.pno 包裹
    ,a.date_d 待退件操作日期
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.cod_amount/100 COD金额
    ,group_concat(distinct b2.staff_info_id) 交接员工id
from a
join
    (
        select
            b.pno
            ,b.date_d
            ,b.store_id
        from b
        group by 1,2,3
    ) b on a.pno = b.pno and a.date_d = b.date_d
left join ph_staging.parcel_info pi on pi.pno = a.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join b b2 on b2.pno = a.pno and b2.date_d = a.date_d
where
    pi.state not in (5,7,8,9)
    and a.date_d < curdate()
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    dc.store_id,
    ss.name,
    count(distinct dc.pno) 应派,
    count(distinct(if(date(convert_tz(pi.`finished_at`,'+00:00' ,'+08:00'))=date_sub(current_date,interval 1 day),dc.`pno` ,null))) 今日妥投量,
    count(distinct if(td.`pno` is not null,dc.pno,null))网点交接包裹量  ,
    count(distinct if(td.`pno` is not null,dc.pno,null))/count(distinct dc.pno) 网点交接率
#     concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dc.pno  ,null))/count(distinct dc.pno)*100,2),"%")  大件占比
from  ph_bi.`dc_should_delivery_today` dc
left join `ph_staging`.parcel_info  pi on dc.`pno` =pi.`pno`
left join `ph_staging`.`ticket_delivery` td on td.`pno` =dc.pno and date(convert_tz(td.`delivery_at` ,'+00:00' ,'+08:00'))= dc.stat_date and td.`state` in (0,1,2)
left join ph_staging.sys_store ss on ss.id = dc.store_id
where
    dc.`stat_date` = date_sub(current_date,interval 1 day)
    and dc.state<6
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
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
where (t.今日上班打卡时间 is not null or t.今日下班打卡时间 is not null);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = t.妥投时间
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = t.妥投时间;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,case
        when bc.client_name = 'lazada' then dl.delievey_end_date
        when bc.client_name = 'shopee' then ds.end_date
        when bc.client_name = 'tiktok' then dt.end_date
    else null end 派送时效
    ,case
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) > 0 then '超时效'
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) <= 0 and
            datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) >= -1 then '临近超时效'
        else '未超时效'
    end 时效判断
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = t.运单号
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = t.运单号
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = t.运单号
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,case
        when bc.client_name = 'lazada' then dl.delievey_end_date
        when bc.client_name = 'shopee' then ds.end_date
        when bc.client_name = 'tiktok' then dt.end_date
    else null end 派送时效
    ,case
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) > 0 then '超时效'
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) <= 0 and
            datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) >= -1 then '临近超时效'
        else '未超时效'
    end 时效判断
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = t.运单号
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = t.运单号
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = t.运单号
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间)
left join tmpale.dwd_th_network_spill_detl_rd dt on dt.统计日期 = t.妥投时间 and dt.网点名称 = t.妥投网点;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,case
        when bc.client_name = 'lazada' then dl.delievey_end_date
        when bc.client_name = 'shopee' then ds.end_date
        when bc.client_name = 'tiktok' then dt.end_date
    else null end 派送时效
    ,case
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) > 0 then '超时效'
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) <= 0 and
            datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) >= -1 then '临近超时效'
        else '未超时效'
    end 时效判断
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = t.运单号
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = t.运单号
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = t.运单号
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间)
left join dwm.dwd_th_network_spill_detl_rd dt on dt.统计日期 = t.妥投时间 and dt.网点名称 = t.妥投网点;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,case
        when bc.client_name = 'lazada' then dl.delievey_end_date
        when bc.client_name = 'shopee' then ds.end_date
        when bc.client_name = 'tiktok' then dt.end_date
    else null end 派送时效
    ,case
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) > 0 then '超时效'
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) <= 0 and
            datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) >= -1 then '临近超时效'
        else '未超时效'
    end 时效判断
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = t.运单号
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = t.运单号
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = t.运单号
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间)
left join dwm.dwd_ph_network_spill_detl_rd dt on dt.统计日期 = t.妥投时间 and dt.网点名称 = t.妥投网点;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,case
        when bc.client_name = 'lazada' then dl.delievey_end_date
        when bc.client_name = 'shopee' then ds.end_date
        when bc.client_name = 'tiktok' then dt.end_date
    else null end 派送时效
    ,case
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) > 0 then '超时效'
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) <= 0 and
            datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) >= -1 then '临近超时效'
        else '未超时效'
    end 时效判断
    ,if(dt.爆仓预警 = 'Alert', '是', '否') 当日是否爆仓
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = t.运单号
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = t.运单号
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = t.运单号
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间)
left join dwm.dwd_ph_network_spill_detl_rd dt on dt.统计日期 = t.妥投时间 and dt.网点名称 = t.妥投网点;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pcd.created_at
    from  ph_staging.parcel_info pi
    left join ph_staging.parcel_change_detail pcd  on pi.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and pi.state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
join tmpale.tmp_ph_pno_lj_0516 t on b.pno = t.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pcd.created_at
    from  ph_staging.parcel_info pi
    left join ph_staging.parcel_change_detail pcd  on pi.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and pi.state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join tmpale.tmp_ph_pno_lj_0516 t on de.pno = t.pno
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
#     ,b.type 类型
#     ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,de.last_store_name 最后一条有效路由网点
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join tmpale.tmp_ph_pno_lj_0516 t on de.pno = t.pno
# join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
#     ,b.type 类型
#     ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,de.last_store_name 最后一条有效路由网点
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join tmpale.tmp_ph_pno_lj_0516 t on de.pno = t.pno
# join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = de.last_store_name and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join tmpale.tmp_ph_pno_lj_0516 t on t.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = de.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
#     ,b.type 类型
#     ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,de.last_store_name 最后一条有效路由网点
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join tmpale.tmp_ph_pno_lj_0516 t on de.pno = t.pno
# join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = de.last_store_name and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join tmpale.tmp_ph_pno_lj_0516 t on t.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = de.pno
# where
#     pi.state not in (5,7,8,9)
#     and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,mw.operator_name
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-04-01'
    and mw.created_at < '2023-05-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,mw.operator_name 操作人
        ,case swm.type
            when 1 then '派件低效'
            when 2 then '虚假操作'
            when 3 then '虚假打卡'
        end 违规类型
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_backyard.staff_warning_message swm on swm.id = mw.staff_warning_message_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-04-01'
    and mw.created_at < '2023-05-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,mw.operator_name 操作人
        ,case swm.type
            when 1 then '派件低效'
            when 3 then '虚假操作'
            when 4 then '虚假打卡'
        end 违规类型
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_backyard.staff_warning_message swm on swm.id = mw.staff_warning_message_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-04-01'
    and mw.created_at < '2023-05-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.dst_detail_address 收件人地址
    ,seal.pack_no
    ,case pr.route_action
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一条有效路由
    ,ss.name 最后有效路由操作网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0518 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.store_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0518 t on t.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = pi.pno and pr.rk = 1
left join ph_staging.sys_store ss on ss.id = pr.store_id
left join
    (
        select
            psd.pno
            ,psd.pack_no
            ,row_number() over (partition by psd.pno order by psd.created_at desc ) rk
        from ph_staging.pack_seal_detail psd
        join tmpale.tmp_ph_pno_lj_0518 t on t.pno = psd.pno
    ) seal on seal.pno = pi.pno and seal.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
select
    f1.proof_id 出车凭证
    ,f1.next_store_id 网点ID
    ,f1.next_store_name 网点
    ,sh_not_ar.pno_num 应到未到包裹数
    ,ar_not_sh.pno_num 实到不应到包裹数
    ,pack_sh_not_ar.pack_num 应到未到集包数
    ,pack_ar_not_sh.pack_num 实到不应到集包数
from ft f1
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(sr.pno) pno_num
        from ft f
        left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
        left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
        where
            rr.pno is null
        group by 1,2,3
    ) sh_not_ar on f1.proof_id = sh_not_ar.proof_id and f1.next_store_id = sh_not_ar.store_id
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(rr.pno) pno_num
        from ft f
        left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
        left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
        where
            sr.pno is null
        group by 1,2,3
    ) ar_not_sh on ar_not_sh.proof_id = f1.proof_id and ar_not_sh.store_id = f1.next_store_id
left join
    (
        select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null
        group by 1,2,3
    ) pack_sh_not_ar on pack_sh_not_ar.proof_id = f1.proof_id and pack_sh_not_ar.store_id = f1.next_store_id
left join
    (
        select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is not null
        group by 1,2,3
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,ps.pack_pno
#             ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    f1.proof_id 出车凭证
    ,f1.next_store_id 网点ID
    ,f1.next_store_name 网点
    ,sh_not_ar.pno_num 应到未到包裹数
    ,ar_not_sh.pno_num 实到不应到包裹数
    ,pack_sh_not_ar.pack_num 应到未到集包数
    ,pack_ar_not_sh.pack_num 实到不应到集包数
from ft f1
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(sr.pno) pno_num
        from ft f
        left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
        left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
        where
            rr.pno is null
        group by 1,2,3
    ) sh_not_ar on f1.proof_id = sh_not_ar.proof_id and f1.next_store_id = sh_not_ar.store_id
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(rr.pno) pno_num
        from ft f
        left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
        left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
        where
            sr.pno is null
        group by 1,2,3
    ) ar_not_sh on ar_not_sh.proof_id = f1.proof_id and ar_not_sh.store_id = f1.next_store_id
left join
    (
        select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null
        group by 1,2,3
    ) pack_sh_not_ar on pack_sh_not_ar.proof_id = f1.proof_id and pack_sh_not_ar.store_id = f1.next_store_id
left join
    (
        select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is not null
        group by 1,2,3
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
# ,sh_ar as
# (
#     select
#         ft1.proof_id
#         ,pssn.next_store_id
#         ,pssn.next_store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
#     group by 1,2,3,4
# )
# ,re_ar as
# (
#     select
#         ft2.proof_id
#         ,pssn.store_id
#         ,pssn.store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
#     group by 1,2,3,4
# )
# , pack_sh as
# (
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
# ,sh_ar as
# (
#     select
#         ft1.proof_id
#         ,pssn.next_store_id
#         ,pssn.next_store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
#     group by 1,2,3,4
# )
# ,re_ar as
# (
#     select
#         ft2.proof_id
#         ,pssn.store_id
#         ,pssn.store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
#     group by 1,2,3,4
# )
# , pack_sh as
# (
#     select
#         ft3.proof_id
#         ,pr.next_store_id
#         ,pr.next_store_name
#         ,json_extract(pr.extra_value, '$.packPno') pack_pno
#     from ph_staging.parcel_route pr
#     join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
#     where
#         pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
#         and pr.routed_at > date_sub(curdate(), interval 5 day )
#     group by 1,2,3,4
# )
# , pack_re as
# (
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
# ,sh_ar as
# (
#     select
#         ft1.proof_id
#         ,pssn.next_store_id
#         ,pssn.next_store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
#     group by 1,2,3,4
# )
# ,re_ar as
# (
#     select
#         ft2.proof_id
#         ,pssn.store_id
#         ,pssn.store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
#     group by 1,2,3,4
# )
# , pack_sh as
# (
#     select
#         ft3.proof_id
#         ,pr.next_store_id
#         ,pr.next_store_name
#         ,json_extract(pr.extra_value, '$.packPno') pack_pno
#     from ph_staging.parcel_route pr
#     join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
#     where
#         pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
#         and pr.routed_at > date_sub(curdate(), interval 5 day )
#     group by 1,2,3,4
# )
# , pack_re as
# (
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,json_unquote(json_extract(pr.extra_value, '$.packPno')) pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
# ,sh_ar as
# (
#     select
#         ft1.proof_id
#         ,pssn.next_store_id
#         ,pssn.next_store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
#     group by 1,2,3,4
# )
# ,re_ar as
# (
#     select
#         ft2.proof_id
#         ,pssn.store_id
#         ,pssn.store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
#     group by 1,2,3,4
# )
# , pack_sh as
# (
#     select
#         ft3.proof_id
#         ,pr.next_store_id
#         ,pr.next_store_name
#         ,json_extract(pr.extra_value, '$.packPno') pack_pno
#     from ph_staging.parcel_route pr
#     join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
#     where
#         pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
#         and pr.routed_at > date_sub(curdate(), interval 5 day )
#     group by 1,2,3,4
# )
# , pack_re as
# (
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'),'"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    f1.proof_id 出车凭证
    ,f1.next_store_id 网点ID
    ,f1.next_store_name 网点
    ,sh_not_ar.pno_num 应到未到包裹数
    ,ar_not_sh.pno_num 实到不应到包裹数
    ,pack_sh_not_ar.pack_num 应到未到集包数
    ,pack_ar_not_sh.pack_num 实到不应到集包数
from ft f1
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(sr.pno) pno_num
        from ft f
        left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
        left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
        where
            rr.pno is null
        group by 1,2,3
    ) sh_not_ar on f1.proof_id = sh_not_ar.proof_id and f1.next_store_id = sh_not_ar.store_id
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(rr.pno) pno_num
        from ft f
        left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
        left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
        where
            sr.pno is null
        group by 1,2,3
    ) ar_not_sh on ar_not_sh.proof_id = f1.proof_id and ar_not_sh.store_id = f1.next_store_id
left join
    (
        select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null
        group by 1,2,3
    ) pack_sh_not_ar on pack_sh_not_ar.proof_id = f1.proof_id and pack_sh_not_ar.store_id = f1.next_store_id
left join
    (
        select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is not null
        group by 1,2,3
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is not null;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
            ,ps.pack_pno
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH81161D00'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
            ,ps.pack_pno
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH81161D00'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
            ,ps.pack_pno
            ,f.store_name store
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH19040F00'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
            ,ps.pack_pno
            ,f.store_name store
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH19040F00'
        and ft.proof_id = 'PN4L2310AT2'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
            ,ps.pack_pno
            ,f.store_name store
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.staff_info_id
    ,count(pi.pno) num
from dwm.dwm_ph_staff_wide_s dp
join ph_staging.parcel_info pi on pi.ticket_delivery_staff_info_id = dp.staff_info_id and pi.state = 5
where
    dp.stat_date = date_sub(curdate(), interval 1 day)
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
    and pi.finished_at < convert_tz(dp.attendance_end_at, '+08:00', '+00:00')
    and pi.finished_at > date_sub(convert_tz(dp.attendance_end_at, '+08:00', '+00:00'), interval 30 minute )
group by 1
having count(pi.pno) > 30;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.staff_info_id
    ,count(pi.pno) 下班前半小时妥投包裹数
    ,count(if(st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) < 200, pi.pno, null))  下班前半小时妥投包裹数200米内
from dwm.dwm_ph_staff_wide_s dp
join ph_staging.parcel_info pi on pi.ticket_delivery_staff_info_id = dp.staff_info_id and pi.state = 5
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    dp.stat_date = date_sub(curdate(), interval 1 day)
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
    and pi.finished_at < convert_tz(dp.attendance_end_at, '+08:00', '+00:00')
    and pi.finished_at > date_sub(convert_tz(dp.attendance_end_at, '+08:00', '+00:00'), interval 30 minute )
group by 1
having count(pi.pno) > 30;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.staff_info_id
    ,count(pi.pno) 下班前半小时妥投包裹数
    ,count(if(st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) < 200, pi.pno, null))  下班前半小时妥投包裹数200米内
from dwm.dwm_ph_staff_wide_s dp
join ph_staging.parcel_info pi on pi.ticket_delivery_staff_info_id = dp.staff_info_id and pi.state = 5
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    dp.stat_date = date_sub(curdate(), interval 1 day)
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
    and pi.finished_at < convert_tz(dp.attendance_end_at, '+08:00', '+00:00')
    and pi.finished_at > date_sub(convert_tz(dp.attendance_end_at, '+08:00', '+00:00'), interval 10 minute )
group by 1
having count(pi.pno) > 30;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.staff_info_id
    ,count(pi.pno) 下班前半小时妥投包裹数
    ,count(if(st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) < 200, pi.pno, null))  下班前半小时妥投包裹数200米内
from dwm.dwm_ph_staff_wide_s dp
join ph_staging.parcel_info pi on pi.ticket_delivery_staff_info_id = dp.staff_info_id and pi.state = 5
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    dp.stat_date = date_sub(curdate(), interval 1 day)
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
    and pi.finished_at < convert_tz(dp.attendance_end_at, '+08:00', '+00:00')
    and pi.finished_at > date_sub(convert_tz(dp.attendance_end_at, '+08:00', '+00:00'), interval 10 minute )
group by 1
having count(pi.pno) > 20;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.staff_info_id
    ,count(pi.pno) 下班前10分钟妥投包裹数
    ,count(if(st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) < 200, pi.pno, null))  下班前10分钟妥投包裹数200米内
from dwm.dwm_ph_staff_wide_s dp
join ph_staging.parcel_info pi on pi.ticket_delivery_staff_info_id = dp.staff_info_id and pi.state = 5
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    dp.stat_date = date_sub(curdate(), interval 1 day)
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
    and pi.finished_at < convert_tz(dp.attendance_end_at, '+08:00', '+00:00')
    and pi.finished_at > date_sub(convert_tz(dp.attendance_end_at, '+08:00', '+00:00'), interval 10 minute )
group by 1
having count(pi.pno) > 20;
;-- -. . -..- - / . -. - .-. -.--
select
        fn.end_date as 理论妥投日期
  ,count(distinct fn.pno) as 理论妥投包裹
  ,count(distinct case when fn.latest_created_date<=fn.end_date then fn.pno else null end) as 时效内妥投包裹量
  ,concat(round(count(distinct case when fn.latest_created_date<=fn.end_date then fn.pno else null end)/count(distinct fn.pno)*100,2),'%') as 绝对妥投率
    from
    (
        select
        ssd.pno
        ,ssd.src_area_name
        ,ssd.dst_area_name
     ,ssd.end_date
  ,date(convert_tz(cr.latest_created_at,'+00:00','+08:00')) as latest_created_date
from  dwm.dwd_ex_ph_tiktok_sla_detail ssd
left join
(
 select
     cr.tracking_no
     ,cr.pno
     ,cr.action_code
     ,cr.created_at as latest_created_at
 from dwm.dwd_ph_tiktok_parcel_route_callback_record cr
 where cr.action_code in ( 'signed_personally', 'signed_thirdparty', 'signed_cod', 'unreachable_returned','pkg_damaged','pkg_lost','pkg_scrap')
) cr on ssd.pno=cr.pno
where (cr.action_code is null or cr.action_code in ( 'signed_personally', 'signed_thirdparty', 'signed_cod', 'unreachable_returned'))
and ssd.parcel_state<9
    )fn
where fn.end_date<current_date
and fn.end_date>date_sub(current_date,interval 10 day)
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    km.应揽收日期
 ,count(distinct km.运单号) as 应揽收订单量
 ,count(distinct if(km.揽收订单日期<=km.应揽收日期,km.运单号,null)) as 时效内揽收订单量
 /*,count(distinct if(km.揽收订单日期 is null,km.运单号,null)) as 截止目前历史未揽收订单量*/
 ,concat(round(count(distinct if(km.揽收订单日期<=km.应揽收日期,km.运单号,null))/count(distinct km.运单号)*100,2),'%') as 绝对揽收率
    from
        (
         select
       oi.pno as 运单号
       ,oi.src_name as seller名称
       ,if(hour(convert_tz(oi.confirm_at, '+00:00', '+08:00'))>12,date_add(date(convert_tz(oi.confirm_at, '+00:00', '+08:00')), interval 1 day),  date(convert_tz(oi.confirm_at, '+00:00', '+08:00'))) as 应揽收日期
       ,convert_tz(oi.created_at, '+00:00', '+08:00') as 创建订单时间
       ,convert_tz(oi.confirm_at, '+00:00', '+08:00') as 订单确认时间
       ,date(convert_tz(oi.confirm_at, '+00:00', '+08:00'))as 订单确认日期
       ,convert_tz(pi.created_at, '+00:00', '+08:00') as 揽收订单时间
       ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) as 揽收订单日期
       ,case oi.state
        when 0 then'已确认'
     when 1 then'待揽件'
     when 2 then'已揽收'
     when 3 then'已取消(已终止)'
     when 4 then'已删除(已作废)'
     when 5 then'预下单'
     when 6 then'被标记多次，限制揽收'
        end as 订单状态
    from  ph_staging.order_info oi
   left join ph_staging.parcel_info pi on oi.pno=pi.pno
   where oi.confirm_at>=date_sub(current_date,interval 41 day)
     and oi.client_id in('AA0131')
     and oi.state not in(3,4)
   union
   select
       oi.pno as 运单号
       ,oi.src_name as seller名称
       ,date(convert_tz(oi.confirm_at, '+00:00', '+08:00'))as 应揽收日期
       ,convert_tz(oi.created_at, '+00:00', '+08:00') as 创建订单时间
       ,convert_tz(oi.confirm_at, '+00:00', '+08:00') as 订单确认时间
       ,date(convert_tz(oi.confirm_at, '+00:00', '+08:00'))as 订单确认日期
       ,convert_tz(pi.created_at, '+00:00', '+08:00') as 揽收订单时间
       ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) as 揽收订单日期
       ,case oi.state
        when 0 then'已确认'
     when 1 then'待揽件'
     when 2 then'已揽收'
     when 3 then'已取消(已终止)'
     when 4 then'已删除(已作废)'
     when 5 then'预下单'
     when 6 then'被标记多次，限制揽收'
        end as 订单状态
    from  ph_staging.order_info oi
   left join ph_staging.parcel_info pi on oi.pno=pi.pno
   where oi.confirm_at>=date_sub(current_date,interval 10 day)
     and oi.client_id in('AA0132')
     and oi.state not in(3,4)
        )km
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
  r.pno
 ,r.src_area_name
 ,r.dst_area_name
 ,r.finished_date
 ,r.diff_time_hours
 ,r.cn
from
    (
       select
      ssd.pno
      ,ssd.src_area_name
      ,ssd.dst_area_name
   ,ssd.finished_date
      ,ssd.pickup_time
      ,ssd.finished_time
            ,ssd.dst_hub_name
   ,ssd.returned
            ,ssd.src_store
   ,round(timestampdiff(second,ssd.pickup_time,ssd.finished_time)/3600,2) as diff_time_hours
            ,row_number() over(partition by ssd.src_area_name,ssd.dst_area_name,ssd.finished_date order by round(timestampdiff(second,ssd.pickup_time,ssd.finished_time)/3600,2)) as rn
            ,count(1)over(partition by ssd.src_area_name,ssd.dst_area_name,ssd.finished_date) as cn
            ,round(count(1)over(partition by ssd.src_area_name,ssd.dst_area_name,ssd.finished_date)*0.95,0) as cn_01
      from dwm.dwd_ex_ph_tiktok_sla_detail ssd
  where ssd.finished_date>='2023-05-10'
    and ssd.finished_date<current_date
    and ssd.parcel_state=5
    and ssd.returned=0
    )r
where r.rn=r.cn_01
order by r.src_area_name,r.dst_area_name,r.finished_date;
;-- -. . -..- - / . -. - .-. -.--
select
  r.pno
 ,r.src_area_name
 ,r.dst_area_name
    ,r.dst_hub_name
 ,r.finished_date
 ,r.diff_time_hours
 ,r.cn
from
    (
       select
      ssd.pno
      ,ssd.src_area_name
      ,ssd.dst_area_name
   ,ssd.finished_date
      ,ssd.pickup_time
      ,ssd.finished_time
            ,ssd.dst_hub_name
   ,ssd.returned
            ,ssd.src_store
   ,round(timestampdiff(second,ssd.pickup_time,ssd.finished_time)/3600,2) as diff_time_hours
            ,row_number() over(partition by ssd.dst_hub_name,ssd.finished_date order by round(timestampdiff(second,ssd.pickup_time,ssd.finished_time)/3600,2)) as rn
            ,count(1)over(partition by ssd.dst_hub_name,ssd.finished_date) as cn
            ,round(count(1)over(partition by ssd.dst_hub_name,ssd.finished_date)*0.95,0) as cn_01
      from dwm.dwd_ex_ph_tiktok_sla_detail ssd
  where ssd.finished_date>='2023-05-01'
    and ssd.finished_date<current_date
    and ssd.parcel_state=5
    and ssd.returned=0
    and((ssd.dst_area_name='LUZON 3'and ssd.src_area_name='MM')or (ssd.dst_area_name='VISAYAS 2'and ssd.src_area_name='MM'))
    )r
where r.rn=r.cn_01
order by 2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
  r.pno
 ,r.src_area_name
 ,r.dst_area_name
    ,r.dst_hub_name
 ,r.finished_date
 ,r.diff_time_hours
 ,r.cn
from
    (
       select
      ssd.pno
      ,ssd.src_area_name
      ,ssd.dst_area_name
   ,ssd.finished_date
      ,ssd.pickup_time
      ,ssd.finished_time
            ,ssd.dst_hub_name
   ,ssd.returned
            ,ssd.src_store
   ,round(timestampdiff(second,ssd.pickup_time,ssd.finished_time)/3600,2) as diff_time_hours
            ,row_number() over(partition by ssd.dst_hub_name,ssd.finished_date order by round(timestampdiff(second,ssd.pickup_time,ssd.finished_time)/3600,2)) as rn
            ,count(1)over(partition by ssd.dst_hub_name,ssd.finished_date) as cn
            ,round(count(1)over(partition by ssd.dst_hub_name,ssd.finished_date)*0.95,0) as cn_01
      from dwm.dwd_ex_ph_tiktok_sla_detail ssd
  where ssd.finished_date>='2023-05-01'
    and ssd.finished_date<current_date
    and ssd.parcel_state=5
    and ssd.returned=0
    and(ssd.dst_area_name='VISAYAS 1'and ssd.src_area_name='MM')
    )r
where r.rn=r.cn_01
order by 2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,dp.store_name 妥投网点
    ,dp.region_name 妥投网点大区
    ,dp.piece_name 妥投网点片区
    ,pi.ticket_delivery_staff_info_id 妥投员工ID
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0522 t on t.pno = pi.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_delivery_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,dp.store_name 妥投网点
    ,dp.region_name 妥投网点大区
    ,dp.piece_name 妥投网点片区
    ,pi.ticket_delivery_staff_info_id 妥投员工ID
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0522 t on t.pno = pi.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_delivery_store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    pr.proof_id
    ,pr.store_id
    ,pr.store_name
    ,pr.pack_pno
from ft f
left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
where
    ps.pack_pno is null;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    f1.proof_id 出车凭证
    ,f1.next_store_id 网点ID
    ,f1.next_store_name 网点
    ,sh_not_ar.pno_num 应到未到包裹数
    ,ar_not_sh.pno_num 实到不应到包裹数
    ,pack_sh_not_ar.pack_num 应到未到集包数
    ,pack_ar_not_sh.pack_num 实到不应到集包数
from ft f1
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(sr.pno) pno_num
        from ft f
        left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
        left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
        where
            rr.pno is null
        group by 1,2,3
    ) sh_not_ar on f1.proof_id = sh_not_ar.proof_id and f1.next_store_id = sh_not_ar.store_id
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(rr.pno) pno_num
        from ft f
        left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
        left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
        where
            sr.pno is null
        group by 1,2,3
    ) ar_not_sh on ar_not_sh.proof_id = f1.proof_id and ar_not_sh.store_id = f1.next_store_id
left join
    (
        select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null
        group by 1,2,3
    ) pack_sh_not_ar on pack_sh_not_ar.proof_id = f1.proof_id and pack_sh_not_ar.store_id = f1.next_store_id
left join
    (
        select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is null
        group by 1,2,3
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
select
    f.next_store_id store_id
    ,f.next_store_name store_name
    ,f.proof_id
    ,sr.pno
from ft f
left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
where
    rr.pno is null
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--

        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
select
    f.next_store_id store_id
    ,f.next_store_name store_name
    ,f.proof_id
    ,rr.pno
from ft f
left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
where
    sr.pno is null
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
select
    f.next_store_id store_id
    ,f.next_store_name store_name
    ,f.proof_id
    ,rr.pno
from ft f
left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
where
    sr.pno is null
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,pr.pno
    from ph_staging.parcel_route pr
    join ft ft1 on ft1.store_id = pr.next_store_id and ft1.proof_id = json_extract(pr.extra_value, '$.proofId')
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
select
    f.next_store_id store_id
    ,f.next_store_name store_name
    ,f.proof_id
    ,rr.pno
from ft f
left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
where
    sr.pno is null
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,pr.pno
    from ph_staging.parcel_route pr
    join ft ft1 on ft1.next_store_id = pr.next_store_id and ft1.proof_id = json_extract(pr.extra_value, '$.proofId')
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
select
    f.next_store_id store_id
    ,f.next_store_name store_name
    ,f.proof_id
    ,rr.pno
from ft f
left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
where
    sr.pno is null
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
       select
        ft1.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,pr.pno
    from ph_staging.parcel_route pr
    join ft ft1 on ft1.next_store_id = pr.next_store_id and ft1.proof_id = json_extract(pr.extra_value, '$.proofId')
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    f1.proof_id 出车凭证
    ,f1.next_store_id 网点ID
    ,f1.next_store_name 网点
    ,sh_not_ar.pno_num 应到未到包裹数
    ,ar_not_sh.pno_num 实到不应到包裹数
    ,pack_sh_not_ar.pack_num 应到未到集包数
    ,pack_ar_not_sh.pack_num 实到不应到集包数
from ft f1
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(sr.pno) pno_num
        from ft f
        left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
        left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
        where
            rr.pno is null
        group by 1,2,3
    ) sh_not_ar on f1.proof_id = sh_not_ar.proof_id and f1.next_store_id = sh_not_ar.store_id
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(rr.pno) pno_num
        from ft f
        left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
        left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
        where
            sr.pno is null
        group by 1,2,3
    ) ar_not_sh on ar_not_sh.proof_id = f1.proof_id and ar_not_sh.store_id = f1.next_store_id
left join
    (
        select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null
        group by 1,2,3
    ) pack_sh_not_ar on pack_sh_not_ar.proof_id = f1.proof_id and pack_sh_not_ar.store_id = f1.next_store_id
left join
    (
        select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is null
        group by 1,2,3
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
       select
        ft1.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,pr.pno
    from ph_staging.parcel_route pr
    join ft ft1 on ft1.next_store_id = pr.next_store_id and ft1.proof_id = json_extract(pr.extra_value, '$.proofId')
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
select
    f.next_store_id store_id
    ,f.next_store_name store_name
    ,f.proof_id
    ,sr.pno
from ft f
left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
where
    rr.pno is null
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
       select
        ft1.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,pr.pno
    from ph_staging.parcel_route pr
    join ft ft1 on ft1.next_store_id = pr.next_store_id and ft1.proof_id = json_extract(pr.extra_value, '$.proofId')
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    f1.proof_id 出车凭证
    ,f1.next_store_id 网点ID
    ,f1.next_store_name 网点
    ,sh_not_ar.pno_num 应到未到包裹数
    ,ar_not_sh.pno_num 实到不应到包裹数
    ,pack_sh_not_ar.pack_num 应到未到集包数
    ,pack_ar_not_sh.pack_num 实到不应到集包数
from ft f1
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(sr.pno) pno_num
        from ft f
        left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
        left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
        where
            rr.pno is null
        group by 1,2,3
    ) sh_not_ar on f1.proof_id = sh_not_ar.proof_id and f1.next_store_id = sh_not_ar.store_id
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(rr.pno) pno_num
        from ft f
        left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
        left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
        where
            sr.pno is null
        group by 1,2,3
    ) ar_not_sh on ar_not_sh.proof_id = f1.proof_id and ar_not_sh.store_id = f1.next_store_id
left join
    (
        select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null
        group by 1,2,3
    ) pack_sh_not_ar on pack_sh_not_ar.proof_id = f1.proof_id and pack_sh_not_ar.store_id = f1.next_store_id
left join
    (
        select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is null
        group by 1,2,3
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
       select
        ft1.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,pr.pno
    from ph_staging.parcel_route pr
    join ft ft1 on ft1.next_store_id = pr.next_store_id and ft1.proof_id = json_extract(pr.extra_value, '$.proofId')
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
select
    f.next_store_id store_id
    ,f.next_store_name store_name
    ,f.proof_id
    ,sr.pno
from ft f
left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
where
    rr.pno is null
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,pr.pno
    from ph_staging.parcel_route pr
    join ft ft1 on ft1.next_store_id = pr.next_store_id and ft1.proof_id = json_extract(pr.extra_value, '$.proofId')
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
select
    f.next_store_id store_id
    ,f.next_store_name store_name
    ,f.proof_id
    ,rr.pno
from ft f
left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
where
    sr.pno is null
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    f.proof_id
    ,f.next_store_id store_id
    ,f.next_store_name store_name
    ,ps.pack_pno
from ft f
left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
where
    pr.pack_pno is null
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    pr.proof_id
    ,pr.store_id
    ,pr.store_name
    ,pr.pack_pno
from ft f
left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
where
    ps.pack_pno is null
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dr.area_name 地区
    ,de.pickup_time 揽收时间
    ,convert_tz(coalesce(arr.unseal_time, arr.scan_time), '+00:00', '+08:00') 到达目的地网点时间  --
    ,a.pno
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) '物品价值(cogs)'
    ,oi.cod_amount/100 COD金额
    ,datediff(date_sub(curdate(), interval 1 day), convert_tz(coalesce(arr.unseal_time, arr.scan_time), '+00:00', '+08:00')) 在仓天数
    ,if(pri.pno is null, '否', '是') 是否打印面单
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 拍照路由时间
    ,a.store_name 操作网点
    ,a.staff_info_id 操作员工
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key) 图片地址
from a
left join ph_staging.sys_attachment sa on sa.id = a.link_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_ex_ph_parcel_details de on de.pno = a.pno
left join ph_staging.order_info oi on oi.pno = de.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
left join
    ( -- 目的地网点拍照
        select
            pr.pno
        from ph_staging.parcel_route pr
        join
            (
                select
                    a.pno
                    ,a.store_id
                from a
                group by 1
            ) a1 on a1.pno = pr.pno and a1.store_id = pr.store_id
        where
            pr.route_action = 'PRINTING'
        group by 1
    ) pri on pri.pno = a.pno
left join dwm.dwd_ph_dict_lazada_period_rules dr on dr.province_code = dp.province_code
left join
    (
        select
            pr.pno
            ,max(if(pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN', pr.routed_at, null)) scan_time
            ,max(if(pr.route_action = 'UNSEAL', pr.routed_at, null)) unseal_time
        from ph_staging.parcel_route pr
        join
            (
                select
                    a.pno
                    ,a.store_id
                from a
                group by 1
            ) a1 on a1.pno = pr.pno and a1.store_id = pr.store_id
        where
            pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','UNSEAL')
        group by 1
    ) arr on arr.pno = a.pno;
;-- -. . -..- - / . -. - .-. -.--
select
        a.pno
        ,a.routed_at
        ,a.store_id
        ,a.store_name
        ,a.staff_info_id
        ,link_id
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.store_name
                ,pr.staff_info_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
            from ph_staging.parcel_route pr
            left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
            where
                pr.route_action = 'TAKE_PHOTO'
                and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
                and pr.routed_at >= date_sub(date_sub(curdate() ,interval 1 day), interval 8 hour )
                and pr.routed_at < date_sub(curdate(), interval 8 hour )
        ) a
    lateral view explode(split(a.valu, ',')) id as link_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.routed_at
        ,a.store_id
        ,a.store_name
        ,a.staff_info_id
        ,link_id
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.store_name
                ,pr.staff_info_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
            from ph_staging.parcel_route pr
            left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
            where
                pr.route_action = 'TAKE_PHOTO'
                and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
                and pr.routed_at >= date_sub(date_sub(curdate() ,interval 1 day), interval 8 hour )
                and pr.routed_at < date_sub(curdate(), interval 8 hour )
        ) a
    lateral view explode(split(a.valu, ',')) id as link_id
);
;-- -. . -..- - / . -. - .-. -.--
select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dr.area_name 地区
    ,de.pickup_time 揽收时间
    ,convert_tz(coalesce(arr.unseal_time, arr.scan_time), '+00:00', '+08:00') 到达目的地网点时间
    ,a.pno
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) '物品价值(cogs)'
    ,oi.cod_amount/100 COD金额
    ,datediff(date_sub(curdate(), interval 1 day), convert_tz(coalesce(arr.unseal_time, arr.scan_time), '+00:00', '+08:00')) 在仓天数
    ,if(pri.pno is null, '否', '是') 是否打印面单
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 拍照路由时间
    ,a.store_name 操作网点
    ,a.staff_info_id 操作员工
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key) 图片地址
from a
left join ph_staging.sys_attachment sa on sa.id = a.link_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_ex_ph_parcel_details de on de.pno = a.pno
left join ph_staging.order_info oi on oi.pno = de.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
left join
    ( -- 目的地网点拍照
        select
            pr.pno
        from ph_staging.parcel_route pr
        join
            (
                select
                    a.pno
                    ,a.store_id
                from a
                group by 1
            ) a1 on a1.pno = pr.pno and a1.store_id = pr.store_id
        where
            pr.route_action = 'PRINTING'
        group by 1
    ) pri on pri.pno = a.pno
left join dwm.dwd_ph_dict_lazada_period_rules dr on dr.province_code = dp.province_code
left join
    (
        select
            pr.pno
            ,max(if(pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN', pr.routed_at, null)) scan_time
            ,max(if(pr.route_action = 'UNSEAL', pr.routed_at, null)) unseal_time
        from ph_staging.parcel_route pr
        join
            (
                select
                    a.pno
                    ,a.store_id
                from a
                group by 1
            ) a1 on a1.pno = pr.pno and a1.store_id = pr.store_id
        where
            pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','UNSEAL')
        group by 1
    ) arr on arr.pno = a.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct pi.pno)
from ph_staging.parcel_info pi
left join ph_bi.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 5 and plt.operator_id not in (10000,10001)
left join dwm.dwd_ex_ph_parcel_details de on de.pno = pi.pno
where
    pi.state not in (5,7,8,9)
    and datediff(curdate(), de.last_route_time) > 7;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from ph_staging.parcel_info pi
left join ph_bi.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 5 and plt.operator_id not in (10000,10001)
left join dwm.dwd_ex_ph_parcel_details de on de.pno = pi.pno
where
    pi.state not in (5,7,8,9)
    and datediff(curdate(), de.last_route_time) > 7
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    count(*)
from dwm.dwd_ex_ph_parcel_details de
where
    de.pickup_out_time is null
    and de.pickup_time < curdate();
;-- -. . -..- - / . -. - .-. -.--
select
    count(*)
from dwm.dwd_ex_ph_parcel_details de
where
    de.pickup_out_time is null
    and de.pickup_time < curdate()
    and de.parcel_state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
from dwm.dwd_ex_ph_parcel_details de
where
    de.pickup_out_time is null
    and de.pickup_time < curdate()
    and de.parcel_state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    de.src_store
    ,count(de.pno)
from dwm.dwd_ex_ph_parcel_details de
where
    de.pickup_out_time is null
    and de.pickup_time < curdate()
    and de.parcel_state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
from dwm.dwd_ex_ph_parcel_details de
where
    de.pickup_out_time is null
    and de.pickup_time < curdate()
    and de.parcel_state = 5
#     and de.parcel_state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
from dwm.dwd_ex_ph_parcel_details de
where
    de.pickup_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store
    and de.parcel_state = 5
#     and de.parcel_state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.ticket_pickup_staff_info_id
from dwm.dwd_ex_ph_parcel_details de
where
    de.pickup_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store
    and de.parcel_state = 5
#     and de.parcel_state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.ticket_pickup_staff_info_id
    ,de.returned
from dwm.dwd_ex_ph_parcel_details de
where
    de.pickup_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store
    and de.parcel_state = 5
#     and de.parcel_state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.ticket_pickup_staff_info_id
    ,de.returned
    ,de.client_id
from dwm.dwd_ex_ph_parcel_details de
where
    de.pickup_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store
    and de.parcel_state = 5
#     and de.parcel_state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.src_store
    ,de.ticket_pickup_staff_info_id
    ,de.returned
    ,de.client_id
from dwm.dwd_ex_ph_parcel_details de
where
    de.pickup_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store
    and de.parcel_state = 5
#     and de.parcel_state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    de.pickup_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category != 6;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    pr.routed_at is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category != 6;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    pr.routed_at is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category != 6
    and de.last_store_id = de.src_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
# left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    de.src_hub_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id = 'AA0038' -- 物料仓
    and ss.category != 6;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'普通' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    pr.routed_at is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category != 6
    and de.last_store_id = de.src_store_id

union
-- 物料仓
select
     de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'物料' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
# left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    de.src_hub_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id = 'AA0038' -- 物料仓
    and ss.category != 6 -- 非FH

union all

select
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'fh' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.parcel_route pr2 on pr2.pno = pi.pno and pr.route_action = 'FLASH_HOME_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    coalesce(pr.routed_at, pr2.routed_at) is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category = 6;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'普通' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    pr.routed_at is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category != 6
    and de.last_store_id = de.src_store_id

union
-- 物料仓
select
     de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'物料' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
# left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    de.src_hub_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id = 'AA0038' -- 物料仓
    and ss.category != 6 -- 非FH

union all

select
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'fh' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.parcel_route pr2 on pr2.pno = pi.pno and pr2.route_action = 'FLASH_HOME_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    coalesce(pr.routed_at, pr2.routed_at) is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'fh' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.parcel_route pr2 on pr2.pno = pi.pno and pr2.route_action = 'FLASH_HOME_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    coalesce(pr.routed_at, pr2.routed_at) is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.last_store_id = pi.ticket_pickup_store_id
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category = 6;
;-- -. . -..- - / . -. - .-. -.--
select
     de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'物料' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
# left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    de.src_hub_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id = 'AA0038' -- 物料仓
    and ss.category != 6;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'普通' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    pr.routed_at is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category != 6
    and de.last_store_id = de.src_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
#     de.src_store
#     ,count(de.pno)
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'普通' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    pr.routed_at is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category != 6
    and de.last_store_id = de.src_store_id

union
-- 物料仓
select
     de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'物料' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
# left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    de.src_hub_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id = 'AA0038' -- 物料仓
    and ss.category != 6 -- 非FH

union all

select
    de.pno
    ,de.src_store
    ,de.src_piece
    ,de.src_region
    ,de.client_id
    ,de.pickup_time
    ,de.dst_store
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height volume
    ,de.last_cn_route_action
    ,de.last_route_time
    ,de.last_staff_info_id
    ,'fh' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.parcel_route pr2 on pr2.pno = pi.pno and pr2.route_action = 'FLASH_HOME_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    coalesce(pr.routed_at, pr2.routed_at) is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.last_store_id = pi.ticket_pickup_store_id
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno 运单号
    ,de.src_store 揽件网点
    ,de.src_piece 片区
    ,de.src_region 大区
    ,de.client_id 客户ID
    ,de.pickup_time 揽件时间
    ,de.dst_store 目的网点
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight 物品重量
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height 物品体积
    ,pi.cod_amount/100 COD金额
    ,de.last_cn_route_action 最后一步有效路由
    ,de.last_route_time 操作时间
    ,de.last_staff_info_id 操作ID
    ,'普通' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    pr.routed_at is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category != 6
    and de.last_store_id = de.src_store_id

union
-- 物料仓
select
     de.pno 运单号
    ,de.src_store 揽件网点
    ,de.src_piece 片区
    ,de.src_region 大区
    ,de.client_id 客户ID
    ,de.pickup_time 揽件时间
    ,de.dst_store 目的网点
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight 物品重量
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height 物品体积
    ,pi.cod_amount/100 COD金额
    ,de.last_cn_route_action 最后一步有效路由
    ,de.last_route_time 操作时间
    ,de.last_staff_info_id 操作ID
    ,'物料' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
# left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    de.src_hub_out_time is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.parcel_state not in (5,7,8,9)
    and de.client_id = 'AA0038' -- 物料仓
    and ss.category != 6 -- 非FH

union all

select
    de.pno 运单号
    ,de.src_store 揽件网点
    ,de.src_piece 片区
    ,de.src_region 大区
    ,de.client_id 客户ID
    ,de.pickup_time 揽件时间
    ,de.dst_store 目的网点
    ,case pi.article_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,pi.exhibition_weight 物品重量
    ,pi.exhibition_length*pi.exhibition_width*pi.exhibition_height 物品体积
    ,pi.cod_amount/100 COD金额
    ,de.last_cn_route_action 最后一步有效路由
    ,de.last_route_time 操作时间
    ,de.last_staff_info_id 操作ID
    ,'fh' type
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join ph_staging.parcel_route pr2 on pr2.pno = pi.pno and pr2.route_action = 'FLASH_HOME_SCAN'
left join ph_staging.sys_store ss on ss.id = de.src_store_id
where
    coalesce(pr.routed_at, pr2.routed_at) is null
    and de.pickup_time < curdate()
    and de.dst_store != de.src_store -- 剔除自揽自派
    and de.last_store_id = pi.ticket_pickup_store_id
    and de.parcel_state not in (5,7,8,9)
    and de.client_id != 'AA0038' -- 物料仓
    and ss.category = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.stat_date
    ,dp.staff_info_id
    ,dp.store_name
    ,dp.delivery_par_cnt
    ,dp.delivery_sma_par_cnt
    ,dp.delivery_big_par_cnt
from dwm.dwm_ph_staff_wide_s dp
where
    dp.stat_date >= date_sub(curdate(), interval 30 day );
;-- -. . -..- - / . -. - .-. -.--
select
    t.avg_num
    ,count(distinct t.staff_info_id) staff_num
from
    (
        select
            dp.staff_info_id
            ,sum(dp.delivery_par_cnt)/count(distinct dp.stat_date) avg_num
        from dwm.dwm_ph_staff_wide_s dp
        where
            dp.stat_date >= date_sub(curdate(), interval 30 day )
        group by 1
    ) t
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.stat_date
    ,t.delivery_par_cnt
    ,count(t.staff_info_id)
from
    (
        select
            dp.staff_info_id
            ,dp.stat_date
            ,dp.delivery_par_cnt
        from dwm.dwm_ph_staff_wide_s dp
        where
            dp.stat_date >= date_sub(curdate(), interval 7 day )
    ) t
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.store_name
    ,count(distinct pr.pno) holding包裹数
from
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_id
            ,pr.store_name
        from ph_staging.parcel_route pr
        where
            pr.route_action = 'REFUND_CONFIRM'
            and pr.routed_at >= '2023-04-30 17:00:00'
            and pr.routed_at < '2023-05-31 17:00:00'
    ) pr
# left join fle_staging.parcel_info pi on pi.pno = pr.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    datediff(convert_tz(pi.finished_at, '+00:00', '+07:00'), convert_tz(pr.routed_at, '+00:00', '+07:00')) Hloding到妥投天数
    ,count(pi.pno) 包裹数
from
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_id
            ,pr.store_name
        from ph_staging.parcel_route pr
        where
            pr.route_action = 'REFUND_CONFIRM'
            and pr.routed_at >= '2023-04-30 17:00:00'
            and pr.routed_at < '2023-05-31 17:00:00'
    ) pr
join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pi.state = 5
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            pr.pno
            ,pr2.store_name
            ,row_number() over (pr2.pno order by pr2.routed_at desc) rk
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,pr.store_id
                    ,pr.store_name
                from ph_staging.parcel_route pr
                where
                    pr.route_action = 'REFUND_CONFIRM'
                    and pr.routed_at >= '2023-04-30 17:00:00'
                    and pr.routed_at < '2023-05-31 17:00:00'
            ) pr
        left join ph_staging.parcel_route pr2 on pr2.pno = pr.pno
        where
            pr2.routed_at < pr.routed_at
            and pr2.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                                               'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                                               'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                                               'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                                               'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                                               'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')

    ) a
where
    a.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pr.pno
            ,pr2.store_name
            ,row_number() over (partition by pr2.pno order by pr2.routed_at desc) rk
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,pr.store_id
                    ,pr.store_name
                from ph_staging.parcel_route pr
                where
                    pr.route_action = 'REFUND_CONFIRM'
                    and pr.routed_at >= '2023-04-30 17:00:00'
                    and pr.routed_at < '2023-05-31 17:00:00'
            ) pr
        left join ph_staging.parcel_route pr2 on pr2.pno = pr.pno
        where
            pr2.routed_at < pr.routed_at
            and pr2.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                                               'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                                               'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                                               'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                                               'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                                               'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')

    ) a
where
    a.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    ss.name
    ,ss.detail_address
    ,ss.lat
    ,ss.lng
from ph_staging.sys_store ss
where
    ss.id in  ('PH13210A00','PH13030200','PH13080100');
;-- -. . -..- - / . -. - .-. -.--
SELECT
    ss.name
    ,ss.detail_address
    ,ss.lat
    ,ss.lng
from ph_staging.sys_store ss
where
    ss.id in  ('PH13210A00','PH13080100');
;-- -. . -..- - / . -. - .-. -.--
SELECT
    ss.name 网点名称
    ,ss.id 网点ID
    ,ss.detail_address 网点【表情】
    ,ss.lat 网点经度
    ,ss.lng 网点经纬度
    ,sr.max_time 最晚派件时间
from ph_staging.sys_store ss
left join
    (
        select
            td.store_id
            ,max(convert_tz(td.created_at, '+00:00', '+08:00')) max_time
        from ph_staging.ticket_delivery td
        where
            td.store_id in ('PH13210A00','PH13080100')
        group by 1
    ) sr on sr.store_id = ss.id
where
    ss.id in  ('PH13210A00','PH13080100');
;-- -. . -..- - / . -. - .-. -.--
select
    *
from ph_staging.parcel_info pi
where
    pi.state not in (5,7,8,9)
    and pi.dst_store_id in ('PH13080100')
limit   100;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pi.client_id 客户ID
    ,pr.store_name 妥投DC
    ,pr.staff_info_id 操作人
    ,convert_tz(pr.routed_at, '+00:00', '+08:00')  操作时间
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'DELIVERY_CONFIRM'
    and pr.pno in ('P81161MZENJBU','P61231JR3CAAM','P19061JSRSUAQ','P21011KK19PAD','P61251JD8A8AS','P61201KN93RGP','P19031HFQD0AI','P61201HVBY2BB','P19061HNBK6AH','P35171G4P78BP','P61301NRZNQAT','P18181NWY3TAB','P61201M9DYWGQ','P21081N89D3AC','P61231K7JVSAQ','P61201MJPHTGD','P61181MDSQMBI','PD61181NKC5EEW','P61181NM961FI','P21081NK6Y7AI','P61271MFDTYAG','P17211J6NDPBT','P61201MR676GV','P17241NKS2AAY','P61181FXGHPCC','P19241N9ZW7BR','PD61181KV5Y5AE','P61011HWHKCDO','P61181JF5PFBL','P61181JQWAPAV','P61231MJUJBAP','P61171N0R5QAV','P33131CWU05AA','P61181K9A2QAI','P61181P47W6CF','PD61181NKCC0EW','P61161J02YYAG','P61181JCHYNBJ','P21041HE1JQAZ','P18031K6ABCCO','PD61181NKC90EW','P21081NJVBNAB','PD61011N0XJ6JQ','P21031H95UJAC','P61171MPVX2AO','P61271MZ2X1AI','P53021BBRJ0CE','P21021JZPU8AI','P18061J0KMZCB','P20071HJXF5AK','P21021HJA9QAG','P61151J6HF4AA','P61301MY14HAV','PT203121JVXS1AK','PT611721JNNV4AH','PT470521G7DT2AL','PT172821K51J3AX','PT182321KK500AJ','PT612021MBUW2GK','PT170321JRHF1BH','PT612121JT7J6AU','PT612121K5Y22AH','PT612021GYQC4AN','PT192621JEEQ2AN','PT611421JW3Y7BO','PT611921JMNA7AT','PT193021KRPR5AH','PT612321JTJT2AQ','PT800921M6WA3BK','PT611821HKUD1ET','PT17221YB7J7AG','PT612221JSYM1AH','PT201821JUKR3AP','PT611821N1B08FJ','PT611721JSB44AN','PT181521M0AD3AT','PT611721JC808AO','PT610121J8MH9DP','PT20371Y9JA2AD','PT21021WVD14AD','PT21081X3AS4AI','PT21021WU4R0AF','PT61191XER28AH','PT21021WXHN5AD','PT61031WW8X1AL','PT61181XQV48CZ','PT21131YE2W3AD','PT21121X3EE4AQ','PT61181YM734AJ','PT21111Y5994AC','PT80071WYPR4AP','PT61181X6TF0DX','PT61181YQZ07CN','PT18171YCQX9AK','PT61181YS2F1BN','PT21101XQP80AG','PT190521FCNG6BE','PT61271YJFD3AD','PT19111VEE70AA','PT61171XQD07AK','PT610821G5BF5AH','PT23031Y3900AX','P80031MPB98BE','P19161HM0EPAW','P78031NHDHBAI','P61251MW6SXAB','P19191H4BYJAK','P80111GTUYZAB','P17081JJRPXAO','P19261NPWPWAB','P20011NQK0HAK','P12181KYAQ4AF','P61171M75KGBA','P19261MD1J7AY','P19261NN61UAZ','P61181N971JFI','P61181M76X9EW','P61181MDE8TAK','P19291MKCWNAK','P21051J8FSKAB','P20351JMQBPAG','P79091JA9VDAO','P61181H1CBCEX','P19261MBJQMAB','P19261H34CPAB','P61251N9G1AAI','P61231N2WV1AE','P79101HBFUSAE','P20201FENQMAV','P19051MFFEUAZ','P07331H2781AM','P21081NQN7UAJ','P19281P7ZUAAH','P21051HWMC1AA','P20181H7XC9AZ','P61161H8VGHAL','P18101HP9VWBC','P20031GNVVVAB','P21131P2D5UAB','P61171JZK66BD','P61181JBS4AAJ','P19251K5XDEAE','P61181HWMFAAL','P61231N5PB3AK','P61161H0R0SAB','P17051MFE0GAA','P20231JMTM1AP','P61201KCTBMGF','P61201K99ACAR','P20181HT3QWAS','P61171JKEE1AV','P19241N3N3YCF','P60111CXSK5AD','P18061HJNECAI','P61201KS8E0GC','PT612521G3PD0AV','P02261J6HM0BF','P17221P82P9AJ','P20181N7Y97AZ','P180315NYQWCB');
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pi.client_id 客户ID
            ,pr.store_name 妥投DC
            ,pr.staff_info_id 操作人
            ,convert_tz(pr.routed_at, '+00:00', '+08:00')  操作时间
            ,ss.name 揽收网点
            ,pi.ticket_pickup_staff_info_id 揽收快递员
            ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
        from ph_staging.parcel_info pi
        left join ph_staging.parcel_route pr on pi.pno = pr.pno and pr.route_action = 'DELIVERY_CONFIRM'
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        where
            pi.pno in ('P81161MZENJBU','P61231JR3CAAM','P19061JSRSUAQ','P21011KK19PAD','P61251JD8A8AS','P61201KN93RGP','P19031HFQD0AI','P61201HVBY2BB','P19061HNBK6AH','P35171G4P78BP','P61301NRZNQAT','P18181NWY3TAB','P61201M9DYWGQ','P21081N89D3AC','P61231K7JVSAQ','P61201MJPHTGD','P61181MDSQMBI','PD61181NKC5EEW','P61181NM961FI','P21081NK6Y7AI','P61271MFDTYAG','P17211J6NDPBT','P61201MR676GV','P17241NKS2AAY','P61181FXGHPCC','P19241N9ZW7BR','PD61181KV5Y5AE','P61011HWHKCDO','P61181JF5PFBL','P61181JQWAPAV','P61231MJUJBAP','P61171N0R5QAV','P33131CWU05AA','P61181K9A2QAI','P61181P47W6CF','PD61181NKCC0EW','P61161J02YYAG','P61181JCHYNBJ','P21041HE1JQAZ','P18031K6ABCCO','PD61181NKC90EW','P21081NJVBNAB','PD61011N0XJ6JQ','P21031H95UJAC','P61171MPVX2AO','P61271MZ2X1AI','P53021BBRJ0CE','P21021JZPU8AI','P18061J0KMZCB','P20071HJXF5AK','P21021HJA9QAG','P61151J6HF4AA','P61301MY14HAV','PT203121JVXS1AK','PT611721JNNV4AH','PT470521G7DT2AL','PT172821K51J3AX','PT182321KK500AJ','PT612021MBUW2GK','PT170321JRHF1BH','PT612121JT7J6AU','PT612121K5Y22AH','PT612021GYQC4AN','PT192621JEEQ2AN','PT611421JW3Y7BO','PT611921JMNA7AT','PT193021KRPR5AH','PT612321JTJT2AQ','PT800921M6WA3BK','PT611821HKUD1ET','PT17221YB7J7AG','PT612221JSYM1AH','PT201821JUKR3AP','PT611821N1B08FJ','PT611721JSB44AN','PT181521M0AD3AT','PT611721JC808AO','PT610121J8MH9DP','PT20371Y9JA2AD','PT21021WVD14AD','PT21081X3AS4AI','PT21021WU4R0AF','PT61191XER28AH','PT21021WXHN5AD','PT61031WW8X1AL','PT61181XQV48CZ','PT21131YE2W3AD','PT21121X3EE4AQ','PT61181YM734AJ','PT21111Y5994AC','PT80071WYPR4AP','PT61181X6TF0DX','PT61181YQZ07CN','PT18171YCQX9AK','PT61181YS2F1BN','PT21101XQP80AG','PT190521FCNG6BE','PT61271YJFD3AD','PT19111VEE70AA','PT61171XQD07AK','PT610821G5BF5AH','PT23031Y3900AX','P80031MPB98BE','P19161HM0EPAW','P78031NHDHBAI','P61251MW6SXAB','P19191H4BYJAK','P80111GTUYZAB','P17081JJRPXAO','P19261NPWPWAB','P20011NQK0HAK','P12181KYAQ4AF','P61171M75KGBA','P19261MD1J7AY','P19261NN61UAZ','P61181N971JFI','P61181M76X9EW','P61181MDE8TAK','P19291MKCWNAK','P21051J8FSKAB','P20351JMQBPAG','P79091JA9VDAO','P61181H1CBCEX','P19261MBJQMAB','P19261H34CPAB','P61251N9G1AAI','P61231N2WV1AE','P79101HBFUSAE','P20201FENQMAV','P19051MFFEUAZ','P07331H2781AM','P21081NQN7UAJ','P19281P7ZUAAH','P21051HWMC1AA','P20181H7XC9AZ','P61161H8VGHAL','P18101HP9VWBC','P20031GNVVVAB','P21131P2D5UAB','P61171JZK66BD','P61181JBS4AAJ','P19251K5XDEAE','P61181HWMFAAL','P61231N5PB3AK','P61161H0R0SAB','P17051MFE0GAA','P20231JMTM1AP','P61201KCTBMGF','P61201K99ACAR','P20181HT3QWAS','P61171JKEE1AV','P19241N3N3YCF','P60111CXSK5AD','P18061HJNECAI','P61201KS8E0GC','PT612521G3PD0AV','P02261J6HM0BF','P17221P82P9AJ','P20181N7Y97AZ','P180315NYQWCB');
;-- -. . -..- - / . -. - .-. -.--
select
    *
from dwm.parcel_store_stage_new pssn
where
    pssn.shipped_at >= date_sub(curdate(), interval 7 day)
    and pssn.van_left_at is null;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from dw_dmd.parcel_store_stage_new pssn
where
    pssn.shipped_at >= date_sub(curdate(), interval 7 day)
    and pssn.van_left_at is null;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from dw_dmd.parcel_store_stage_new pssn
where
    pssn.shipped_at >= date_sub(curdate(), interval 7 day)
    and pssn.van_left_at is null
    and pssn.store_category in (8,12)
    and pssn.van_plan_left_at > now();
;-- -. . -..- - / . -. - .-. -.--
select
    *
from dw_dmd.parcel_store_stage_new pssn
where
    pssn.shipped_at >= date_sub(curdate(), interval 7 day)
    and pssn.van_left_at is null
    and pssn.store_category in (8,12);
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pr.pno
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
        from ph_staging.parcel_route pr
        where
            pr.route_action = 'PENDING_RETURN'
            and pr.routed_at >= '2023-03-31 16:00:00'
        group by 1,2
    )
    , b as
    (
        select
            pr2.pno
            ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
            ,pr2.staff_info_id
            ,pr2.store_id
        from ph_staging.parcel_route pr2
        join
            (
                select a.pno from a group by 1
            ) b on pr2.pno = b.pno
        where
            pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr2.routed_at >= '2023-03-31 16:00:00'
    )
    select
        a.pno 包裹
        ,a.date_d 待退件操作日期
        ,dp.store_name 网点
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,pi.cod_amount/100 COD金额
        ,group_concat(distinct b2.staff_info_id) 交接员工id
    from a
    join
        (
            select
                b.pno
                ,b.date_d
                ,b.store_id
            from b
            group by 1,2,3
        ) b on a.pno = b.pno and a.date_d = b.date_d
    left join ph_staging.parcel_info pi on pi.pno = a.pno
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
    left join b b2 on b2.pno = a.pno and b2.date_d = a.date_d
    where
        pi.state not in (5,7,8,9)
        and a.date_d < curdate()
    group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
 de.pno '运单号'
,de.src_store 揽件网点
,de.src_piece 揽收网点片区
,de.src_province 揽收网点大区
 ,de.pick_date '揽收时间'
 ,de.client_id '客户ID'
 ,pi.cod_amount/100 'cod金额'
 ,de.dst_routed_at '到仓时间'
 ,date_diff(CURRENT_DATE(),de.dst_routed_at) '在仓天数'
 ,pi.dst_name '收件人姓名'
 ,pi.dst_phone '收件人电话'
 ,sp.name '收件人省'
 ,sc.name '收件人市'
 ,sd.name '收件人乡'
 ,ss.name '目的地网点'
 ,smr.name '大区'
 ,smp.name '片区'
 ,pr.'交接次数'
 ,pr1.'改约次数'
 ,pr2.'外呼次数(10秒以上)'
 ,pr3.'外呼或来电有接通次数'
 ,if(acc.pno is not null,'被投诉',null) '是否被投诉'
 ,if(plt.pno is not null,'进入过闪速',null) '是否进入过闪速'
 ,pr4.'路由动作'
 ,convert_tz(pr4.routed_at,'+00:00','+08:00') '操作时间'
 ,pr4.staff_info_id '操作员工ID'
 ,pr4.name '操作网点'
 ,case pi.state
when 1 then '已揽收'
when 2 then '运输中'
when 3 then '派送中'
when 4 then '已滞留'
when 5 then '已签收'
when 6 then '疑难件处理中'
when 7 then '已退件'
when 8 then '异常关闭'
when 9 then '已撤销'
ELSE '其他'
end as '包裹状态'
from dwm.dwd_ex_ph_parcel_details de
join ph_staging.parcel_info pi on de.pno=pi.pno
left join ph_bi.sys_province sp on sp.code=pi.dst_province_code
left join ph_bi.sys_city sc on sc.code=pi.dst_city_code
left join ph_bi.sys_district sd on sd.code=pi.dst_district_code
left join ph_bi.sys_store ss on ss.id=pi.dst_store_id
left join ph_bi.sys_manage_region smr on smr.id=ss.manage_region
left join ph_bi.sys_manage_piece smp on smp.id=ss.manage_piece
left join
	(select
	pr.pno
	,count(pr.pno) '交接次数'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action='DELIVERY_TICKET_CREATION_SCAN'
	group by 1)pr on pr.pno=de.pno
left join
    (select
	pr.pno
	,count(pr.pno) '改约次数'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action='DELIVERY_MARKER'
	and pr.marker_category in(9,14,70)
	group by 1)pr1 on pr1.pno=de.pno
left join
  (select
	pr.pno
	,count(pr.pno) '外呼次数(10秒以上)'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action='PHONE'
	and replace(json_extract(pr.extra_value,'$.diaboloDuration'),'\"','')>=10
	group by 1)pr2 on pr2.pno=de.pno
left join
   (select
	pr.pno
	,count(pr.pno) '外呼或来电有接通次数'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action in ('PHONE','INCOMING_CALL')
	and replace(json_extract(pr.extra_value,'$.callDuration'),'\"','')>0
	group by 1)pr3 on pr3.pno=de.pno
left join
	(select
	distinct
	acc.pno
	from ph_bi.abnormal_customer_complaint acc
	where acc.created_at>=CURRENT_DATE()-interval 90 day )acc on acc.pno=de.pno
left join
	(select
	distinct plt.pno
	from ph_bi.parcel_lose_task plt
	where plt.created_at>=CURRENT_DATE()-interval 90 day )plt on plt.pno=de.pno
left join
   (select
   pr.pno
   ,pr.staff_info_id
   ,ss.name
   ,case pr.route_action
when 'ACCEPT_PARCEL'	THEN '接件扫描'
when 'ARRIVAL_GOODS_VAN_CHECK_SCAN'	THEN '车货关联到港'
when 'ARRIVAL_WAREHOUSE_SCAN'	THEN '到件入仓扫描'
when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN'	THEN '取消到件入仓扫描'
when 'CANCEL_PARCEL'	THEN '撤销包裹'
when 'CANCEL_SHIPMENT_WAREHOUSE'	THEN '取消发件出仓'
when 'CHANGE_PARCEL_CANCEL'	THEN '修改包裹为撤销'
when 'CHANGE_PARCEL_CLOSE'	THEN '修改包裹为异常关闭'
when 'CHANGE_PARCEL_IN_TRANSIT'	THEN '修改包裹为运输中'
when 'CHANGE_PARCEL_INFO'	THEN '修改包裹信息'
when 'CHANGE_PARCEL_SIGNED'	THEN '修改包裹为签收'
when 'CLAIMS_CLOSE'	THEN '理赔关闭'
when 'CLAIMS_COMPLETE'	THEN '理赔完成'
when 'CLAIMS_CONTACT'	THEN '已联系客户'
when 'CLAIMS_TRANSFER_CS'	THEN '转交总部cs处理'
when 'CLOSE_ORDER'	THEN '关闭订单'
when 'CONTINUE_TRANSPORT'	THEN '疑难件继续配送'
when 'CREATE_WORK_ORDER'	THEN '创建工单'
when 'CUSTOMER_CHANGE_PARCEL_INFO'	THEN '客户修改包裹信息'
when 'CUSTOMER_OPERATING_RETURN'	THEN '客户操作退回寄件人'
when 'DELIVERY_CONFIRM'	THEN '确认妥投'
when 'DELIVERY_MARKER'	THEN '派件标记'
when 'DELIVERY_PICKUP_STORE_SCAN'	THEN '自提取件扫描'
when 'DELIVERY_TICKET_CREATION_SCAN'	THEN '交接扫描'
when 'DELIVERY_TRANSFER'	THEN '派件转单'
when 'DEPARTURE_GOODS_VAN_CK_SCAN'	THEN '车货关联出港'
when 'DETAIN_WAREHOUSE'	THEN '货件留仓'
when 'DIFFICULTY_FINISH_INDEMNITY'	THEN '疑难件支付赔偿'
when 'DIFFICULTY_HANDOVER'	THEN '疑难件交接'
when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE'	THEN '疑难件交接货件留仓'
when 'DIFFICULTY_RE_TRANSIT'	THEN '疑难件退回区域总部/重启运送'
when 'DIFFICULTY_RETURN'	THEN '疑难件退回寄件人'
when 'DIFFICULTY_SEAL'	THEN '集包异常'
when 'DISCARD_RETURN_BKK'	THEN '丢弃包裹的，换单后寄回BKK'
when 'DISTRIBUTION_INVENTORY'	THEN '分拨盘库'
when 'DWS_WEIGHT_IMAGE'	THEN 'DWS复秤照片'
when 'EXCHANGE_PARCEL'	THEN '换货'
when 'FAKE_CANCEL_HANDLE'	THEN '虚假撤销判责'
when 'FLASH_HOME_SCAN'	THEN 'FH交接扫描'
when 'FORCE_TAKE_PHOTO'	THEN '强制拍照路由'
when 'HAVE_HAIR_SCAN_NO_TO'	THEN '有发无到'
when 'HURRY_PARCEL'	THEN '催单'
when 'INCOMING_CALL'	THEN '来电接听'
when 'INTERRUPT_PARCEL_AND_RETURN'	THEN '中断运输并退回'
when 'INVENTORY'	THEN '盘库'
when 'LOSE_PARCEL_TEAM_OPERATION'	THEN '丢失件团队处理'
when 'MANUAL_REMARK'	THEN '添加备注'
when 'MISS_PICKUP_HANDLE'	THEN '漏包裹揽收判责'
when 'MISSING_PARCEL_SCAN'	THEN '丢失件包裹操作'
when 'NOTICE_LOST_PARTS_TEAM'	THEN '已通知丢失件团队'
when 'PARCEL_HEADLESS_CLAIMED'	THEN '无头件包裹已认领'
when 'PARCEL_HEADLESS_PRINTED'	THEN '无头件包裹已打单'
when 'PENDING_RETURN'	THEN '待退件'
when 'PHONE'	THEN '电话联系'
when 'PICK_UP_STORE'	THEN '待自提取件'
when 'PICKUP_RETURN_RECEIPT'	THEN '签回单揽收'
when 'PRINTING'	THEN '打印面单'
when 'QAQC_OPERATION'	THEN 'QAQC判责'
when 'RECEIVE_WAREHOUSE_SCAN'	THEN '收件入仓'
when 'RECEIVED'	THEN '已揽收,初始化动作，实际情况并没有作用'
when 'REFUND_CONFIRM'	THEN '退件妥投'
when 'REPAIRED'	THEN '上报问题修复路由'
when 'REPLACE_PNO'	THEN '换单'
when 'REPLY_WORK_ORDER'	THEN '回复工单'
when 'REVISION_TIME'	THEN '改约时间'
when 'SEAL'	THEN '集包'
when 'SEAL_NUMBER_CHANGE'	THEN '集包件数变化'
when 'SHIPMENT_WAREHOUSE_SCAN'	THEN '发件出仓扫描'
when 'SORTER_WEIGHT_IMAGE'	THEN '分拣机复秤照片'
when 'SORTING_SCAN'	THEN '分拣扫描'
when 'STAFF_INFO_UPDATE_WEIGHT'	THEN '快递员修改重量'
when 'STORE_KEEPER_UPDATE_WEIGHT'	THEN '仓管员复秤'
when 'STORE_SORTER_UPDATE_WEIGHT'	THEN '分拣机复秤'
when 'SYSTEM_AUTO_RETURN'	THEN '系统自动退件'
when 'TAKE_PHOTO'	THEN '异常打单拍照'
when 'THIRD_EXPRESS_ROUTE'	THEN '第三方公司路由'
when 'THIRD_PARTY_REASON_DETAIN'	THEN '第三方原因滞留'
when 'TICKET_WEIGHT_IMAGE'	THEN '揽收称重照片'
when 'TRANSFER_LOST_PARTS_TEAM'	THEN '已转交丢失件团队'
when 'TRANSFER_QAQC'	THEN '转交QAQC处理'
when 'UNSEAL'	THEN '拆包'
when 'UNSEAL_NOT_SCANNED'	THEN '集包已拆包，本包裹未被扫描'
when 'VEHICLE_ACCIDENT_REG'	THEN '车辆车祸登记'
when 'VEHICLE_ACCIDENT_REGISTRATION'	THEN '车辆车祸登记'
when 'VEHICLE_WET_DAMAGE_REG'	THEN '车辆湿损登记'
when 'VEHICLE_WET_DAMAGE_REGISTRATION'	THEN '车辆湿损登记'
else pr.route_action
end '路由动作'
,pr.routed_at
   ,row_number()over(partition by pr.pno order by pr.routed_at desc) rank
   from ph_staging.parcel_route pr
   left join ph_bi.sys_store ss on ss.id=pr.store_id
   where pr.routed_at>=CURRENT_DATE()-interval 60 day
   and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY'))pr4 on pr4.pno=de.pno and pr4.rank=1
where de.pick_date>='2022-07-01'
and pi.state not in (5,7,8,9)
and de.cod_enabled='YES'
and date_diff(CURRENT_DATE(),de.dst_routed_at)>=3;
;-- -. . -..- - / . -. - .-. -.--
select
 de.pno '运单号'
,de.src_store 揽件网点
,de.src_piece 揽收网点片区
,de.src_region 揽收网点大区
 ,de.pick_date '揽收时间'
 ,de.client_id '客户ID'
 ,pi.cod_amount/100 'cod金额'
 ,de.dst_routed_at '到仓时间'
 ,date_diff(CURRENT_DATE(),de.dst_routed_at) '在仓天数'
 ,pi.dst_name '收件人姓名'
 ,pi.dst_phone '收件人电话'
 ,sp.name '收件人省'
 ,sc.name '收件人市'
 ,sd.name '收件人乡'
 ,ss.name '目的地网点'
 ,smr.name '大区'
 ,smp.name '片区'
 ,pr.'交接次数'
 ,pr1.'改约次数'
 ,pr2.'外呼次数(10秒以上)'
 ,pr3.'外呼或来电有接通次数'
 ,if(acc.pno is not null,'被投诉',null) '是否被投诉'
 ,if(plt.pno is not null,'进入过闪速',null) '是否进入过闪速'
 ,pr4.'路由动作'
 ,convert_tz(pr4.routed_at,'+00:00','+08:00') '操作时间'
 ,pr4.staff_info_id '操作员工ID'
 ,pr4.name '操作网点'
 ,case pi.state
when 1 then '已揽收'
when 2 then '运输中'
when 3 then '派送中'
when 4 then '已滞留'
when 5 then '已签收'
when 6 then '疑难件处理中'
when 7 then '已退件'
when 8 then '异常关闭'
when 9 then '已撤销'
ELSE '其他'
end as '包裹状态'
from dwm.dwd_ex_ph_parcel_details de
join ph_staging.parcel_info pi on de.pno=pi.pno
left join ph_bi.sys_province sp on sp.code=pi.dst_province_code
left join ph_bi.sys_city sc on sc.code=pi.dst_city_code
left join ph_bi.sys_district sd on sd.code=pi.dst_district_code
left join ph_bi.sys_store ss on ss.id=pi.dst_store_id
left join ph_bi.sys_manage_region smr on smr.id=ss.manage_region
left join ph_bi.sys_manage_piece smp on smp.id=ss.manage_piece
left join
	(select
	pr.pno
	,count(pr.pno) '交接次数'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action='DELIVERY_TICKET_CREATION_SCAN'
	group by 1)pr on pr.pno=de.pno
left join
    (select
	pr.pno
	,count(pr.pno) '改约次数'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action='DELIVERY_MARKER'
	and pr.marker_category in(9,14,70)
	group by 1)pr1 on pr1.pno=de.pno
left join
  (select
	pr.pno
	,count(pr.pno) '外呼次数(10秒以上)'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action='PHONE'
	and replace(json_extract(pr.extra_value,'$.diaboloDuration'),'\"','')>=10
	group by 1)pr2 on pr2.pno=de.pno
left join
   (select
	pr.pno
	,count(pr.pno) '外呼或来电有接通次数'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action in ('PHONE','INCOMING_CALL')
	and replace(json_extract(pr.extra_value,'$.callDuration'),'\"','')>0
	group by 1)pr3 on pr3.pno=de.pno
left join
	(select
	distinct
	acc.pno
	from ph_bi.abnormal_customer_complaint acc
	where acc.created_at>=CURRENT_DATE()-interval 90 day )acc on acc.pno=de.pno
left join
	(select
	distinct plt.pno
	from ph_bi.parcel_lose_task plt
	where plt.created_at>=CURRENT_DATE()-interval 90 day )plt on plt.pno=de.pno
left join
   (select
   pr.pno
   ,pr.staff_info_id
   ,ss.name
   ,case pr.route_action
when 'ACCEPT_PARCEL'	THEN '接件扫描'
when 'ARRIVAL_GOODS_VAN_CHECK_SCAN'	THEN '车货关联到港'
when 'ARRIVAL_WAREHOUSE_SCAN'	THEN '到件入仓扫描'
when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN'	THEN '取消到件入仓扫描'
when 'CANCEL_PARCEL'	THEN '撤销包裹'
when 'CANCEL_SHIPMENT_WAREHOUSE'	THEN '取消发件出仓'
when 'CHANGE_PARCEL_CANCEL'	THEN '修改包裹为撤销'
when 'CHANGE_PARCEL_CLOSE'	THEN '修改包裹为异常关闭'
when 'CHANGE_PARCEL_IN_TRANSIT'	THEN '修改包裹为运输中'
when 'CHANGE_PARCEL_INFO'	THEN '修改包裹信息'
when 'CHANGE_PARCEL_SIGNED'	THEN '修改包裹为签收'
when 'CLAIMS_CLOSE'	THEN '理赔关闭'
when 'CLAIMS_COMPLETE'	THEN '理赔完成'
when 'CLAIMS_CONTACT'	THEN '已联系客户'
when 'CLAIMS_TRANSFER_CS'	THEN '转交总部cs处理'
when 'CLOSE_ORDER'	THEN '关闭订单'
when 'CONTINUE_TRANSPORT'	THEN '疑难件继续配送'
when 'CREATE_WORK_ORDER'	THEN '创建工单'
when 'CUSTOMER_CHANGE_PARCEL_INFO'	THEN '客户修改包裹信息'
when 'CUSTOMER_OPERATING_RETURN'	THEN '客户操作退回寄件人'
when 'DELIVERY_CONFIRM'	THEN '确认妥投'
when 'DELIVERY_MARKER'	THEN '派件标记'
when 'DELIVERY_PICKUP_STORE_SCAN'	THEN '自提取件扫描'
when 'DELIVERY_TICKET_CREATION_SCAN'	THEN '交接扫描'
when 'DELIVERY_TRANSFER'	THEN '派件转单'
when 'DEPARTURE_GOODS_VAN_CK_SCAN'	THEN '车货关联出港'
when 'DETAIN_WAREHOUSE'	THEN '货件留仓'
when 'DIFFICULTY_FINISH_INDEMNITY'	THEN '疑难件支付赔偿'
when 'DIFFICULTY_HANDOVER'	THEN '疑难件交接'
when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE'	THEN '疑难件交接货件留仓'
when 'DIFFICULTY_RE_TRANSIT'	THEN '疑难件退回区域总部/重启运送'
when 'DIFFICULTY_RETURN'	THEN '疑难件退回寄件人'
when 'DIFFICULTY_SEAL'	THEN '集包异常'
when 'DISCARD_RETURN_BKK'	THEN '丢弃包裹的，换单后寄回BKK'
when 'DISTRIBUTION_INVENTORY'	THEN '分拨盘库'
when 'DWS_WEIGHT_IMAGE'	THEN 'DWS复秤照片'
when 'EXCHANGE_PARCEL'	THEN '换货'
when 'FAKE_CANCEL_HANDLE'	THEN '虚假撤销判责'
when 'FLASH_HOME_SCAN'	THEN 'FH交接扫描'
when 'FORCE_TAKE_PHOTO'	THEN '强制拍照路由'
when 'HAVE_HAIR_SCAN_NO_TO'	THEN '有发无到'
when 'HURRY_PARCEL'	THEN '催单'
when 'INCOMING_CALL'	THEN '来电接听'
when 'INTERRUPT_PARCEL_AND_RETURN'	THEN '中断运输并退回'
when 'INVENTORY'	THEN '盘库'
when 'LOSE_PARCEL_TEAM_OPERATION'	THEN '丢失件团队处理'
when 'MANUAL_REMARK'	THEN '添加备注'
when 'MISS_PICKUP_HANDLE'	THEN '漏包裹揽收判责'
when 'MISSING_PARCEL_SCAN'	THEN '丢失件包裹操作'
when 'NOTICE_LOST_PARTS_TEAM'	THEN '已通知丢失件团队'
when 'PARCEL_HEADLESS_CLAIMED'	THEN '无头件包裹已认领'
when 'PARCEL_HEADLESS_PRINTED'	THEN '无头件包裹已打单'
when 'PENDING_RETURN'	THEN '待退件'
when 'PHONE'	THEN '电话联系'
when 'PICK_UP_STORE'	THEN '待自提取件'
when 'PICKUP_RETURN_RECEIPT'	THEN '签回单揽收'
when 'PRINTING'	THEN '打印面单'
when 'QAQC_OPERATION'	THEN 'QAQC判责'
when 'RECEIVE_WAREHOUSE_SCAN'	THEN '收件入仓'
when 'RECEIVED'	THEN '已揽收,初始化动作，实际情况并没有作用'
when 'REFUND_CONFIRM'	THEN '退件妥投'
when 'REPAIRED'	THEN '上报问题修复路由'
when 'REPLACE_PNO'	THEN '换单'
when 'REPLY_WORK_ORDER'	THEN '回复工单'
when 'REVISION_TIME'	THEN '改约时间'
when 'SEAL'	THEN '集包'
when 'SEAL_NUMBER_CHANGE'	THEN '集包件数变化'
when 'SHIPMENT_WAREHOUSE_SCAN'	THEN '发件出仓扫描'
when 'SORTER_WEIGHT_IMAGE'	THEN '分拣机复秤照片'
when 'SORTING_SCAN'	THEN '分拣扫描'
when 'STAFF_INFO_UPDATE_WEIGHT'	THEN '快递员修改重量'
when 'STORE_KEEPER_UPDATE_WEIGHT'	THEN '仓管员复秤'
when 'STORE_SORTER_UPDATE_WEIGHT'	THEN '分拣机复秤'
when 'SYSTEM_AUTO_RETURN'	THEN '系统自动退件'
when 'TAKE_PHOTO'	THEN '异常打单拍照'
when 'THIRD_EXPRESS_ROUTE'	THEN '第三方公司路由'
when 'THIRD_PARTY_REASON_DETAIN'	THEN '第三方原因滞留'
when 'TICKET_WEIGHT_IMAGE'	THEN '揽收称重照片'
when 'TRANSFER_LOST_PARTS_TEAM'	THEN '已转交丢失件团队'
when 'TRANSFER_QAQC'	THEN '转交QAQC处理'
when 'UNSEAL'	THEN '拆包'
when 'UNSEAL_NOT_SCANNED'	THEN '集包已拆包，本包裹未被扫描'
when 'VEHICLE_ACCIDENT_REG'	THEN '车辆车祸登记'
when 'VEHICLE_ACCIDENT_REGISTRATION'	THEN '车辆车祸登记'
when 'VEHICLE_WET_DAMAGE_REG'	THEN '车辆湿损登记'
when 'VEHICLE_WET_DAMAGE_REGISTRATION'	THEN '车辆湿损登记'
else pr.route_action
end '路由动作'
,pr.routed_at
   ,row_number()over(partition by pr.pno order by pr.routed_at desc) rank
   from ph_staging.parcel_route pr
   left join ph_bi.sys_store ss on ss.id=pr.store_id
   where pr.routed_at>=CURRENT_DATE()-interval 60 day
   and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY'))pr4 on pr4.pno=de.pno and pr4.rank=1
where de.pick_date>='2022-07-01'
and pi.state not in (5,7,8,9)
and de.cod_enabled='YES'
and date_diff(CURRENT_DATE(),de.dst_routed_at)>=3;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr2.pno is not null, '是', '否') '是否延迟退回'
    , pr.delivery_attempt_num 正向尝试派送次数
    , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code


/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr2 on pr2.pno = tt.pno and pr2.route_action = 'DELAY_RETURN'
where pi.state in(1,2,3,4,6,7,8,9)
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , pr.delivery_attempt_num 正向尝试派送次数
    , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code


/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno 
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
where pi.state in(1,2,3,4,6,7,8,9)
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code


/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date<current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code


/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date<current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    count( di.id)
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
where
    di.state = 0;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,di.diff_marker_category
    ,convert_tz(di.created_at, '+00:00', '+08:00') 进入疑难件时间
    ,now() 当前时间
    ,concat(timestampdiff(day,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'D', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00'), now())%24, 'H') 时间差
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.state = 0;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,di.diff_marker_category
    ,convert_tz(di.created_at, '+00:00', '+08:00') 进入疑难件时间
    ,now() 当前时间
    ,concat(timestampdiff(day,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'D', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00'), now())%24, 'H') 时间差
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.state = 0
    and pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,di.diff_marker_category
    ,convert_tz(di.created_at, '+00:00', '+08:00') 进入疑难件时间
    ,now() 当前时间
    ,if(timestampdiff(day,convert_tz(di.created_at, '+00:00', '+08:00') ,now())/3600 > 24, '是', '否') 是否超24小时
    ,concat(timestampdiff(day,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'D', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00'), now())%24, 'H') 时间差
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.state = 0
    and pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,di.diff_marker_category
    ,convert_tz(di.created_at, '+00:00', '+08:00') 进入疑难件时间
    ,now() 当前时间
    ,if(timestampdiff(second ,convert_tz(di.created_at, '+00:00', '+08:00') ,now())/3600 > 24, '是', '否') 是否超24小时
    ,concat(timestampdiff(day,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'D', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00'), now())%24, 'H') 时间差
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.state = 0
    and pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,di.diff_marker_category
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
        end as 疑难原因
    ,convert_tz(di.created_at, '+00:00', '+08:00') 进入疑难件时间
    ,now() 当前时间
    ,if(timestampdiff(second ,convert_tz(di.created_at, '+00:00', '+08:00') ,now())/3600 > 24, '是', '否') 是否超24小时
    ,concat(timestampdiff(day,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'D', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00'), now())%24, 'H') 时间差
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.state = 0
    and pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,di.id
    ,di.diff_marker_category
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
        end as 疑难原因
    ,convert_tz(di.created_at, '+00:00', '+08:00') 进入疑难件时间
    ,now() 当前时间
    ,if(timestampdiff(second ,convert_tz(di.created_at, '+00:00', '+08:00') ,now())/3600 > 24, '是', '否') 是否超24小时
    ,concat(timestampdiff(day,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'D', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00'), now())%24, 'H') 时间差
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.state = 0
    and pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,cdt.id
    ,di.diff_marker_category
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
        end as 疑难原因
    ,convert_tz(di.created_at, '+00:00', '+08:00') 进入疑难件时间
    ,now() 当前时间
    ,if(timestampdiff(second ,convert_tz(di.created_at, '+00:00', '+08:00') ,now())/3600 > 24, '是', '否') 是否超24小时
    ,concat(timestampdiff(day,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'D', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00'), now())%24, 'H') 时间差
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.state = 0
    and pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select now();
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,pr.routed_at
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'DELAY_RETURN'
        and pr.routed_at > '2023-06-01 16:00:00'
)
select
    pr2.pno
    ,pr2.store_name 网点
    ,convert_tz(pr2.routed_at, '+00:00', '+08:00') 留仓时间
    ,if(a2.pno is not null , '是', '否') 次日之后是否有派件交接
from ph_staging.parcel_route pr2
join t t1 on t1.pno = pr2.pno and date(convert_tz(t1.routed_at, '+00:00', '+08:00')) = date(convert_tz(pr2.routed_at, '+00:00', '+08:00'))
left join
    (
        select
            *
        from ph_staging.parcel_route pr3
        join t t2 on t2.pno = pr3.pno
        where
            pr3.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr3.routed_at > date_sub(date(convert_tz(t2.routed_at, '+00:00', '+08:00')), interval 8 hour )
    ) a2 on a2.pno = pr2.pno
where
    pr2.route_action = 'DETAIN_WAREHOUSE'
    and pr2.routed_at > '2023-06-01 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,pr.routed_at
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'DELAY_RETURN'
        and pr.routed_at > '2023-06-01 16:00:00'
)
select
    pr2.pno
    ,pr2.store_name 网点
    ,convert_tz(pr2.routed_at, '+00:00', '+08:00') 留仓时间
    ,if(a2.pno is not null , '是', '否') 次日之后是否有派件交接
from ph_staging.parcel_route pr2
join t t1 on t1.pno = pr2.pno and date(convert_tz(t1.routed_at, '+00:00', '+08:00')) = date(convert_tz(pr2.routed_at, '+00:00', '+08:00'))
left join
    (
        select
            pr3.pno
        from ph_staging.parcel_route pr3
        join t t2 on t2.pno = pr3.pno
        where
            pr3.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr3.routed_at > date_sub(date(convert_tz(t2.routed_at, '+00:00', '+08:00')), interval 8 hour )
    ) a2 on a2.pno = pr2.pno
where
    pr2.route_action = 'DETAIN_WAREHOUSE'
    and pr2.routed_at > '2023-06-01 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code


/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno =
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date < current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
    , if(ss.category = 6 ,  datediff(convert_tz(pr4.routed_at, '+00:00', '+08:00'), tt.pickup_time), datediff(pssn.shipped_at, tt.pickup_time)) '包裹揽收到运输中消耗天数'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code
left join ph_staging.sys_store ss3 on ss3.id = ssd.src_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = ssd.pno and pssn.last_valid_store_order = 1
/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
left join ph_staging.parcel_route pr4 on pr4.pno = ssd.pno and pr4.route_action = 'FLASH_HOME_SCAN'
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date < current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
    ,convert_tz(pr4.routed_at, '+00:00', '+08:00') fh交接扫描时间
    , if(ss.category = 6 ,  datediff(convert_tz(pr4.routed_at, '+00:00', '+08:00'), tt.pickup_time), datediff(pssn.shipped_at, tt.pickup_time)) '包裹揽收到运输中消耗天数'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code
left join ph_staging.sys_store ss3 on ss3.id = ssd.src_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = ssd.pno and pssn.last_valid_store_order = 1
/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
left join ph_staging.parcel_route pr4 on pr4.pno = ssd.pno and pr4.route_action = 'FLASH_HOME_SCAN'
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date < current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
#     ,convert_tz(pr4.routed_at, '+00:00', '+08:00') fh交接扫描时间
    , if(ss.category = 6 ,  datediff(date(convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00')), tt.pick_date), datediff(pssn.shipped_at, tt.pickup_time)) '包裹揽收到运输中消耗天数'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code
left join ph_staging.sys_store ss3 on ss3.id = ssd.src_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = ssd.pno and pssn.last_valid_store_order = 1
left join dw_dmd.parcel_store_stage_new pssn2 on pssn2.pno = ssd.pno and pssn2.last_valid_store_order = 2
/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date < current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
    , convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00')
    , tt.pick_date
     ,pssn.shipped_at
    , if(ss.category = 6 ,  datediff(date(convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00')), tt.pick_date), datediff(pssn.shipped_at, tt.pickup_time)) '包裹揽收到运输中消耗天数'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code
left join ph_staging.sys_store ss3 on ss3.id = ssd.src_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = ssd.pno and pssn.last_valid_store_order = 1
left join dw_dmd.parcel_store_stage_new pssn2 on pssn2.pno = ssd.pno and pssn2.last_valid_store_order = 2
/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date < current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
    , convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00')
    , tt.pick_date
     ,pssn.shipped_at
    , if(ss3.category = 6 ,  datediff(date(convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00')), tt.pick_date), datediff(pssn.shipped_at, tt.pickup_time)) '包裹揽收到运输中消耗天数'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code
left join ph_staging.sys_store ss3 on ss3.id = ssd.src_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = ssd.pno and pssn.last_valid_store_order = 1
left join dw_dmd.parcel_store_stage_new pssn2 on pssn2.pno = ssd.pno and pssn2.last_valid_store_order = 2
/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date < current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
    , convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00')
    , tt.pick_date
     ,pssn.shipped_at
    , if(ss3.category = 6 ,  datediff(convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00'), tt.pickup_time), datediff(convert_tz(coalesce(pssn.shipped_at, pssn2.first_valid_routed_at), '+00:00', '+08:00'), tt.pickup_time)) '包裹揽收到运输中消耗天数'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code
left join ph_staging.sys_store ss3 on ss3.id = ssd.src_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = ssd.pno and pssn.last_valid_store_order = 1
left join dw_dmd.parcel_store_stage_new pssn2 on pssn2.pno = ssd.pno and pssn2.last_valid_store_order = 2
/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date < current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
    , convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00')
    , tt.pick_date
     ,pssn.shipped_at
    , if(ss3.category = 6 ,  datediff(convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00'), tt.pickup_time), datediff(convert_tz(coalesce(pssn.shipped_at, pssn2.first_valid_routed_at), '+00:00', '+08:00'), tt.pickup_time)) '包裹揽收到运输中消耗天数'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code
left join ph_staging.sys_store ss3 on ss3.id = ssd.src_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = ssd.pno and pssn.store_order = 1
left join dw_dmd.parcel_store_stage_new pssn2 on pssn2.pno = ssd.pno and pssn2.store_order = 2
/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date < current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
    , convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00')
    , tt.pick_date
     ,pssn.shipped_at
    , if(ss3.category = 6 ,  datediff(convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00'), tt.pickup_time), datediff(convert_tz(coalesce(pssn.shipped_at, pssn2.first_valid_routed_at), '+00:00', '+08:00'), tt.pickup_time)) '包裹揽收到运输中消耗天数'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code
left join ph_staging.sys_store ss3 on ss3.id = ssd.src_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = ssd.pno and pssn.valid_store_order = 1
left join dw_dmd.parcel_store_stage_new pssn2 on pssn2.pno = ssd.pno and pssn2.valid_store_order = 2
/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
where
    pi.state in(1,2,3,4,6,7,8,9)
    and ssd.end_date < current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.state
from ph_staging.parcel_info pi
where
    pi.pno in ('PT120721NPFK5AD','PT611821PAGY0EM','PT612021PWDJ2HA','PT611821PZ9S4DS','PT611421P2335BA','PT241621P2MM7AY','PT611821PBHT5AL','PT180621PBQR4CK','PT111021PC0R1AN','PT612321P95B6AM','PT40421PZZH2AU','PT203721PC505BQ','PT170521PP8N1AW','PT23221PDP70AC','PT620321PCR03AE','PT611821PPX67AJ','PT172121PAN24BK','PT21PZBV7','PT21221P8687BD','PT790221PEF16AD','PT110721PCS82AP','PT611821PQTQ6BE','P61281NZYF8CV','PT612221PEWX6AH','PT190321PBM60AV','PT640221P8CP1DN','PT611821PFSJ2AE','PT811521JE6J2AD','PT70221PD1T8BF','PT190521PYBD4AS','PT242821MVSR2AS','PT161121P5GX3AH','PT21PXF16','PT122021PDZC7AG','PT811621JD2K2BZ','PT122121PPX15AM','PT120321PYN12AE','PT811621JA423AA','PT611821PQJ32EP','PT180821PK1Z6AV','PT612721PGCG5AA','PT80321P4FG8AI','PT140621PU0E4AP','PT201321PDP34BI','PT11221P9NC8AP','PT12121P8917AD','PT210821PMFN9AK','PT211121PW6G6AO','PT132621P2TQ1AN','PT190621PWXY9AC','PT611421PN047CM','PT612321PS6G0AK','PT610121PXWK8GR','PT181621PQ626AI','PT210821PAKP3AJ','PT121221PYQ20AZ','PT180921PUY17BA','PT612321PMH29AD','PT610621PRQW6CB','PT43121P8TH9BF','PT62921PAK45BE','PT122021PGCE2BE','PT811621JC3N3CM','PT611821PYKW4BO','PT182221PSC13AJ','PT180321PN6Z5AR','PT611821PAM57AW','PT612521PKYM5AY','PT611721PYGE4AK','PT202121PQ0E4AG','PT192321PZAK2AH','PT61921PN2N5AB','PT181121PZHG8AM','PT811621JE537AB','PT190621PPZN0AE','PT612421PGDE9AO','PT180921PQSH8BW','PT611021P7K42BJ','PT220921NE096AF','PT210221PX3B3AD','PT610621PDBY3HG','PT611021PY2X5BJ','PT611821PNBC0DS','PT611921PN7M2AD','PT801021P7UA1AH','PT211421PZ321AG','PT190621PZ536AK','PT611821PZC57CP','PT122021PAVV3CF','PT811621J8508CN','PT611321PZDJ4AA','PT210821PAU64AI','PT41121P8WG5AA','PT71321PAGT1AG','PT811621J73Q7CM','PT611821PB190BI','PT611821Q0E70DA','PT611821PZXA6BM','PT612621PFZA9AF','PT811621HQFY3AM','PT160921PBYB7AD','PT40921PY6G2AM','PT62921PDKC7BE','PT180621PYR10AE','PT613021PVJS5AM','PT611821PNKD7EQ','PT612321PB292AC','PT190121PBCU0AN','PT201821PBS45AI','PT612021PAGX7AN','PT612321PURT5AE','PT612221PAHW4AL','PT43421P52K7AM','PT170521PHT28BE','PT130421P4AS0AJ','PT41221P7KM6AV','PT610621PBZQ2BI','PT811621J2P77BU','PT611821PS928CR','PT261321MYF11AE','PT180621PR4P1BX','PT180821PZ544AR','PT612021PGAE4FB','PT132121PMQD9AA','PT611521PBZZ4AD','PT811621J9Y03AH','PT611621PXX87AJ','PT612021PUU44HE','PT611721PWUJ0AM','PT192821PXJA4AP','PT610121PZ9H6CC','PT611621PABT5AJ','PT351921N2XT0AR','PT611721PUM02AS','PT160421P5RT9AD','PT121221PPMT3AO','PT210821PYK32AI','PT43121PM1J1BB','PT612321PAMX6BD','PT611921PZB07AR','PT612321NCC69AH','PT611821PDJD1FH','PT612521PWQW9AY','PT40421PRPZ2AN','PT182321PPAU3AP','PT62921PQ024AB','PT43121PS4M3AU','PT90221PAPD0AI','PT122021Q0AD0CF','PT62921PP498AS','PT811621JB1N2CF','PT160921PBX58AL','PT171821PB6X4AA','PT200321P2YX8AD','PT21221P8M74BD','PT790921P9XN5AB','PT170521PNG30DL','PT610121PZMA5EF','PT160921P7ZG9AB');
;-- -. . -..- - / . -. - .-. -.--
select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间
 	, timestampdiff(hour,current_time, convert_tz(tt.last_route_time,'+00:00','+08:00')) as 最后一条有效路由距离今日的小时差
    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
    , tpr.src_area_code as '寄件人所在时效区域 area'
    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    , ssd.dst_store as '目的网点 destination DC'
	, case ss2.category when 1 then 'SP'
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
        when 14 then 'PDC'
        end '目的网点的类型 dst_store_name_catergory'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'
    , tpr.dst_area_code as '收件人所在时效区域 consignee_area'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
    , case when tt.dst_routed_at is not null then '在仓'
        when tt.dst_routed_at is null then '在途'
            else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'
    , ssd.sla as '时效天数 SLA'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    , ssd.end_7_date as '包裹严重超时时效截止日_整体 last day of SLA+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, if(bpt.tracking_no=bpt.pno,delivery_attempt_num,returned_delivery_attempt_num) as '回调尝试次数 callback attempt_times'
	, convert_tz(pr.last_delivery_attempt_at,'+00:00','+08:00') as '回调最后一次尝试时间 last attempt time'
	, if(bpt.tracking_no=bpt.pno,tdt2.cn_element,tdt3.cn_element) as '回调最后一次标记原因 last tagging '
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'

    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'

	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
	, if(prk.DISCARD_RETURN_BKK_num>0,'是','否') as '是否要到丢弃仓 if will send to auction warehouse'
	, if(prk.REPLACE_PNO_num>0,'是','否') as '是否有换单路由 if reprint waybill'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and ssd.end_7_date>=current_date then '普通超时效'
	    when ssd.end_7_date<current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, if(datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00')))>=5,'是','否') as '是否超过4天没有回调路由 if there''s no movement for 4 days'
    , if(pr3.pno is not null, '是', '否') '是否延迟退回'
    , if(di2.pno is not null, '是', '否') '是否上报过错分'
    , if(plt2.pno is not null, '是', '否') '是否在揽收网点进C来源'
    , convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00')
    , tt.pick_date
     ,pssn.shipped_at
    , if(ss3.category = 6 ,  datediff(convert_tz(pssn2.first_valid_routed_at, '+00:00', '+08:00'), tt.pickup_time), datediff(convert_tz(coalesce(pssn.shipped_at, pssn2.first_valid_routed_at), '+00:00', '+08:00'), tt.pickup_time)) '包裹揽收到运输中消耗天数'
#     , pr.delivery_attempt_num 正向尝试派送次数
#     , pr.returned_delivery_attempt_num 退件尝试派送次数
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss2 on ssd.dst_store_id=ss2.id
left join ph_staging.parcel_info pi on bpt.pno=pi.pno

left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code

left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code
left join ph_staging.sys_store ss3 on ss3.id = ssd.src_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = ssd.pno and pssn.valid_store_order = 1
left join dw_dmd.parcel_store_stage_new pssn2 on pssn2.pno = ssd.pno and pssn2.valid_store_order = 2
/*left join ph_staging.sys_store dst_ss2 on pi.dst_store_id=dst_ss2.id*/
/*left join ph_staging.sys_province dst_sp2 on dst_ss2.province_code=dst_sp2.code*/
/*left join ph_staging.sys_store ss2 on ssd.src_store_id=ss2.id*/
/*left join ph_staging.sys_province sp2 on ss2.province_code=sp2.code*/

left join ph_staging.delivery_attempt_info pr on bpt.tracking_no=pr.pno -- 回传给客户的尝试次数以及最后一次尝试对应的标记
left join dwm.dwd_dim_dict tdt2 on pr.last_marker_id = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join dwm.dwd_dim_dict tdt3 on pr.last_returned_marker_id = tdt3.element and tdt3.db = 'ph_staging' and tdt3.tablename = 'diff_info' and tdt3.fieldname = 'diff_marker_category'   -- 标记原因对应的人
left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join ph_staging.sys_store ss on tt.last_store_id=ss.id
left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
left join ph_staging.sys_province sp on ss.province_code=sp.code
left join
	(
	    select
	        pr.pno
	        ,convert_tz(pr.routed_at,'+00:00','+08:00') last_marker_time
	        ,tdt2.element last_element
		    ,tdt2.cn_element last_marker
		    ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
	    from ph_staging.parcel_route pr
        join tmpale.tmp_backlog_parcel_tiktok tt on pr.pno=tt.pno
	    left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	    where 1=1
	    and pr.route_action = 'DELIVERY_MARKER'
	    and date(convert_tz(pr.routed_at,'+00:00','+08:00')) <= CURRENT_DATE
	)prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/

left join
    (
	    select
			di.pno
			,min(convert_tz(di.created_at,'+00:00','+08:00')) as 疑难件上报时间
		from ph_staging.diff_info di
		join tmpale.tmp_backlog_parcel_tiktok tt on di.pno=tt.pno
		where di.state=0
		group by 1
	)di on bpt.pno=di.pno

left join
(
	  select
       distinct
		  tpr.dst_province_code
		 ,tpr.dst_area_code
	     ,tpr.src_province_code
	     ,tpr.src_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
)tpr on pi.dst_province_code=tpr.dst_province_code and tpr.src_province_code=pi.src_province_code

left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         where pr.routed_at>= date_sub(now(),interval 3 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接

left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok   bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码

left join
	(
	    select
	        pr.pno
	        ,count(if(pr.route_action='DISCARD_RETURN_BKK',pr.route_action,null)) as DISCARD_RETURN_BKK_num
	        ,count(if(pr.route_action='REPLACE_PNO',pr.route_action,null) )as REPLACE_PNO_num
	    from ph_staging.parcel_route  pr
	    join tmpale.tmp_backlog_parcel_tiktok   bpt on pr.pno=bpt.pno
	    where pr.route_action in('DISCARD_RETURN_BKK','REPLACE_PNO')
	    group by 1
	) prk on bpt.pno = prk.pno -- 是否有bkk路由&换单
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action = 'PENDING_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join ph_staging.parcel_route pr3 on pr3.pno = tt.pno and pr3.route_action = 'DELAY_RETURN'
left join ph_staging.diff_info di2  on di2.pno = tt.pno and di2.diff_marker_category = '31'
left join ph_bi.parcel_lose_task plt2 on plt2.pno = tt.pno and plt2.source = 3 and plt2.last_valid_store_id = tt.src_store_id
where
    pi.state in(1,2,3,4,6,7,8,9)
#     and ssd.end_date < current_date
group by tt.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
from ph_staging.parcel_route pr
where
    pr.route_action = 'UNSEAL'
    and json_extract(pr.extra_value, '$.packPno') = 'P64091263'
    and pr.routed_at > '2023-06-05'
    and pr.routed_at < '20230-06-08';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
from ph_staging.parcel_route pr
where
    pr.route_action = 'SEAL'
    and json_extract(pr.extra_value, '$.packPno') = 'P64091263'
    and pr.routed_at > '2023-06-03'
    and pr.routed_at < '20230-06-07';
;-- -. . -..- - / . -. - .-. -.--
select
    date(plt.created_at)
    ,count(if(plt.state in (5,6), plt.id, null)) 判责量
    ,count(if(plt.state in (5) and plt.operator_id in (10000,10001,10002), plt.id, null)) 自动无须追责量
    ,count(if(plt.state in (5) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工无须追责量
    ,count(if(plt.state in (6) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工追责量
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-06-01'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(plt.created_at)
    ,count(plt.id) 生成任务量
    ,count(if(plt.state in (5,6), plt.id, null)) 判责量
    ,count(if(plt.state in (5) and plt.operator_id in (10000,10001,10002), plt.id, null)) 自动无须追责量
    ,count(if(plt.state in (5) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工无须追责量
    ,count(if(plt.state in (6) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工追责量
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-06-01'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(plt.created_at)
    ,count(plt.id) 生成任务量
    ,count(if(date(plt.updated_at) = date(plt.created_at) and plt.operator_id not in (10000,10001,10002), plt.id, null )) 当日人工处理量
    ,count(if(plt.state in (5,6), plt.id, null)) 判责量
    ,count(if(plt.state in (5) and plt.operator_id in (10000,10001,10002), plt.id, null)) 自动无须追责量
    ,count(if(plt.state in (5) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工无须追责量
    ,count(if(plt.state in (6) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工追责量
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-06-01'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(plt.created_at)
    ,count(plt.id) 生成任务量
    ,count(if(date(plt.updated_at) = date(plt.created_at) and plt.operator_id not in (10000,10001,10002,10003), plt.id, null )) 当日人工处理量
    ,count(if(plt.state in (5,6), plt.id, null)) 判责量
    ,count(if(plt.state in (5) and plt.operator_id in (10000,10001,10002), plt.id, null)) 自动无须追责量
    ,count(if(plt.state in (5) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工无须追责量
    ,count(if(plt.state in (6) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工追责量
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-06-01'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(plt.created_at)
    ,count(plt.id) 生成任务量
    ,count(if(date(plt.updated_at) = date(plt.created_at) and plt.state in (5,6) and plt.operator_id not in (10000,10001,10002,10003), plt.id, null )) 当日人工处理量
    ,count(if(plt.state in (5,6), plt.id, null)) 判责量
    ,count(if(plt.state in (5) and plt.operator_id in (10000,10001,10002), plt.id, null)) 自动无须追责量
    ,count(if(plt.state in (5) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工无须追责量
    ,count(if(plt.state in (6) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工追责量
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-06-01'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.*
    ,a2.deal_num 当天处理完成量
from
    (
        select
            date(plt.created_at) date_D
            ,count(plt.id) 生成任务量
        #     ,count(if(date(plt.updated_at) = date(plt.created_at) and plt.state in (5,6) and plt.operator_id not in (10000,10001,10002,10003), plt.id, null )) 当日人工处理量
            ,count(if(plt.state in (5,6), plt.id, null)) 判责量
            ,count(if(plt.state in (5) and plt.operator_id in (10000,10001,10002), plt.id, null)) 自动无须追责量
            ,count(if(plt.state in (5) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工无须追责量
            ,count(if(plt.state in (6) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工追责量
        from ph_bi.parcel_lose_task plt
        where
            plt.created_at >= '2023-06-01'
        group by 1
    ) a1
left join
    (
        select
            date(plt2.updated_at) date_D
            ,count(plt2.id) deal_num
        from ph_bi.parcel_lose_task plt2
        where
             plt2.created_at >= '2023-06-01'
            and plt2.state in (5,6)
        group by 1
    ) a2 on a2.date_D = a1.date_D;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.*
    ,a2.deal_num 当天处理完成量
from
    (
        select
            date(plt.created_at) date_D
            ,count(plt.id) 生成任务量
        #     ,count(if(date(plt.updated_at) = date(plt.created_at) and plt.state in (5,6) and plt.operator_id not in (10000,10001,10002,10003), plt.id, null )) 当日人工处理量
            ,count(if(plt.state in (5,6), plt.id, null)) 判责量
            ,count(if(plt.state in (5) and plt.operator_id in (10000,10001,10002), plt.id, null)) 自动无须追责量
            ,count(if(plt.state in (5) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工无须追责量
            ,count(if(plt.state in (6) and plt.operator_id not in (10000,10001,10002), plt.id, null)) 人工追责量
        from ph_bi.parcel_lose_task plt
        where
            plt.created_at >= '2023-06-01'
        group by 1
    ) a1
left join
    (
        select
            date(plt2.updated_at) date_D
            ,count(plt2.id) deal_num
        from ph_bi.parcel_lose_task plt2
        where
             plt2.created_at >= '2023-06-01'
            and plt2.state in (5,6)
            and plt2.operator_id not in (10000,10001,10002)
        group by 1
    ) a2 on a2.date_D = a1.date_D;
;-- -. . -..- - / . -. - .-. -.--
select
    sum(timestampdiff(second , plt.created_at, plt.updated_at))/(count(plt.id) * 3600) 平均处理时效_h
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-06-01'
    and plt.state in (5,6)
    and plt.operator_id not in (10000,10001,10002)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    sum(timestampdiff(second , plt.created_at, plt.updated_at))/(count(plt.id) * 3600) 平均处理时效_h
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-06-01'
    and plt.state in (5,6)
    and plt.operator_id not in (10000,10001,10002);
;-- -. . -..- - / . -. - .-. -.--
select
    case plt.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,sum(timestampdiff(second , plt.created_at, plt.updated_at))/(count(plt.id) * 3600) 平均处理时效_h
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-06-01'
    and plt.state in (5,6)
    and plt.operator_id not in (10000,10001,10002)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,if(pi.state in (5,7,8,9), '是', '否') 包裹是否终态
    ,case plt.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,concat(timestampdiff(day ,plt.created_at  ,curdate()), 'D', timestampdiff(hour ,plt.created_at  ,curdate())%24, 'H') 进入闪速时间
    ,if(timestampdiff(hour ,plt.created_at  ,curdate()) > 24, '是', '否' ) 是否超24小时

from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    plt.state in (1,2,3,4);
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
    ,plt.state
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,if(pi.state in (5,7,8,9), '是', '否') 包裹是否终态
    ,case plt.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,concat(timestampdiff(day ,plt.created_at  ,curdate()), 'D', timestampdiff(hour ,plt.created_at  ,curdate())%24, 'H') 进入闪速时间
    ,if(timestampdiff(hour ,plt.created_at  ,curdate()) > 24, '是', '否' ) 是否超24小时

from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    plt.state in (1,2,3,4);
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
    ,plt.state
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,if(pi.state in (5,7,8,9), '是', '否') 包裹是否终态
    ,if(plt.created_at > convert_tz(pi.finished_at , '+00:00', '+08:00'), '是', '否') 是否终态后进入闪速
    ,case plt.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,concat(timestampdiff(day ,plt.created_at  ,curdate()), 'D', timestampdiff(hour ,plt.created_at  ,curdate())%24, 'H') 进入闪速时间
    ,if(timestampdiff(hour ,plt.created_at  ,curdate()) > 24, '是', '否' ) 是否超24小时
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 闪速认定任务状态
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    plt.state in (1,2,3,4);
;-- -. . -..- - / . -. - .-. -.--
select
    a1.*
from
    (
        select
            plt.pno
            ,plt.state
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end 客户类型
            ,if(pi.state in (5,7,8,9), '是', '否') 包裹是否终态
            ,if(plt.created_at > convert_tz(pi.finished_at , '+00:00', '+08:00'), '是', '否') 是否终态后进入闪速
            ,case plt.source
                WHEN 1 THEN 'A-问题件-丢失'
                WHEN 2 THEN 'B-记录本-丢失'
                WHEN 3 THEN 'C-包裹状态未更新'
                WHEN 4 THEN 'D-问题件-破损/短少'
                WHEN 5 THEN 'E-记录本-索赔-丢失'
                WHEN 6 THEN 'F-记录本-索赔-破损/短少'
                WHEN 7 THEN 'G-记录本-索赔-其他'
                WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
                WHEN 9 THEN 'I-问题件-外包装破损险'
                WHEN 10 THEN 'J-问题记录本-外包装破损险'
                when 11 then 'K-超时效包裹'
                when 12 then 'L-高度疑似丢失'
            end 问题来源渠道
            ,plt.source
            ,concat(timestampdiff(day ,plt.created_at  ,curdate()), 'D', timestampdiff(hour ,plt.created_at  ,curdate())%24, 'H') 进入闪速时间
            ,if(timestampdiff(hour ,plt.created_at  ,curdate()) > 24, '是', '否' ) 是否超24小时
            ,timestampdiff(second ,plt.created_at  ,curdate())/3600 time_diff
            ,case plt.state
                when 1 then '丢失件待处理'
                when 2 then '疑似丢失件待处理'
                when 3 then '待工单回复'
                when 4 then '已工单回复'
                when 5 then '包裹未丢失'
                when 6 then '丢失件处理完成'
            end 闪速认定任务状态
        from ph_bi.parcel_lose_task plt
        left join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            plt.state in (1,2,3,4)
    ) a1
where
    ( a1.source = 3 and a1.time_diff > 24 )
    or a1.source !=3;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.*
from
    (
        select
            plt.pno
            ,plt.state
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end 客户类型
            ,if(pi.state in (5,7,8,9), '是', '否') 包裹是否终态
            ,if(plt.created_at > convert_tz(pi.finished_at , '+00:00', '+08:00'), '是', '否') 是否终态后进入闪速
            ,case plt.source
                WHEN 1 THEN 'A-问题件-丢失'
                WHEN 2 THEN 'B-记录本-丢失'
                WHEN 3 THEN 'C-包裹状态未更新'
                WHEN 4 THEN 'D-问题件-破损/短少'
                WHEN 5 THEN 'E-记录本-索赔-丢失'
                WHEN 6 THEN 'F-记录本-索赔-破损/短少'
                WHEN 7 THEN 'G-记录本-索赔-其他'
                WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
                WHEN 9 THEN 'I-问题件-外包装破损险'
                WHEN 10 THEN 'J-问题记录本-外包装破损险'
                when 11 then 'K-超时效包裹'
                when 12 then 'L-高度疑似丢失'
            end 问题来源渠道
            ,plt.source
            ,concat(timestampdiff(day ,plt.created_at  ,curdate()), 'D', timestampdiff(hour ,plt.created_at  ,curdate())%24, 'H') 进入闪速时间
            ,if(timestampdiff(hour ,plt.created_at  ,now()) > 24, '是', '否' ) 是否超24小时
            ,timestampdiff(second ,plt.created_at  ,now())/3600 time_diff
            ,case plt.state
                when 1 then '丢失件待处理'
                when 2 then '疑似丢失件待处理'
                when 3 then '待工单回复'
                when 4 then '已工单回复'
                when 5 then '包裹未丢失'
                when 6 then '丢失件处理完成'
            end 闪速认定任务状态
        from ph_bi.parcel_lose_task plt
        left join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            plt.state in (1,2,3,4)
    ) a1
where
    ( a1.source = 3 and a1.time_diff > 24 )
    or a1.source !=3;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.*
from
    (
        select
            plt.pno
            ,plt.state
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end 客户类型
            ,if(pi.state in (5,7,8,9), '是', '否') 包裹是否终态
            ,if(plt.created_at > convert_tz(pi.finished_at , '+00:00', '+08:00'), '是', '否') 是否终态后进入闪速
            ,case plt.source
                WHEN 1 THEN 'A-问题件-丢失'
                WHEN 2 THEN 'B-记录本-丢失'
                WHEN 3 THEN 'C-包裹状态未更新'
                WHEN 4 THEN 'D-问题件-破损/短少'
                WHEN 5 THEN 'E-记录本-索赔-丢失'
                WHEN 6 THEN 'F-记录本-索赔-破损/短少'
                WHEN 7 THEN 'G-记录本-索赔-其他'
                WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
                WHEN 9 THEN 'I-问题件-外包装破损险'
                WHEN 10 THEN 'J-问题记录本-外包装破损险'
                when 11 then 'K-超时效包裹'
                when 12 then 'L-高度疑似丢失'
            end 问题来源渠道
            ,plt.source
            ,concat(timestampdiff(day ,plt.created_at  ,now()), 'D', timestampdiff(hour ,plt.created_at  ,curdate())%24, 'H') 进入闪速时间
            ,if(timestampdiff(hour ,plt.created_at  ,now())/3600 > 24, '是', '否' ) 是否超24小时
            ,timestampdiff(second ,plt.created_at  ,now())/3600 time_diff
            ,case plt.state
                when 1 then '丢失件待处理'
                when 2 then '疑似丢失件待处理'
                when 3 then '待工单回复'
                when 4 then '已工单回复'
                when 5 then '包裹未丢失'
                when 6 then '丢失件处理完成'
            end 闪速认定任务状态
        from ph_bi.parcel_lose_task plt
        left join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            plt.state in (1,2,3,4)
    ) a1
where
    ( a1.source = 3 and a1.time_diff > 24 )
    or a1.source !=3;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.*
from
    (
        select
            plt.pno
            ,plt.state
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end 客户类型
            ,if(pi.state in (5,7,8,9), '是', '否') 包裹是否终态
            ,if(plt.created_at > convert_tz(pi.finished_at , '+00:00', '+08:00'), '是', '否') 是否终态后进入闪速
            ,case plt.source
                WHEN 1 THEN 'A-问题件-丢失'
                WHEN 2 THEN 'B-记录本-丢失'
                WHEN 3 THEN 'C-包裹状态未更新'
                WHEN 4 THEN 'D-问题件-破损/短少'
                WHEN 5 THEN 'E-记录本-索赔-丢失'
                WHEN 6 THEN 'F-记录本-索赔-破损/短少'
                WHEN 7 THEN 'G-记录本-索赔-其他'
                WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
                WHEN 9 THEN 'I-问题件-外包装破损险'
                WHEN 10 THEN 'J-问题记录本-外包装破损险'
                when 11 then 'K-超时效包裹'
                when 12 then 'L-高度疑似丢失'
            end 问题来源渠道
            ,plt.source
            ,concat(timestampdiff(day ,plt.created_at  ,now()), 'D', timestampdiff(hour ,plt.created_at  ,curdate())%24, 'H') 进入闪速时间
            ,if(timestampdiff(hour ,plt.created_at  ,now())/3600 > 24, '是', '否' ) 是否超24小时
            ,timestampdiff(second ,plt.created_at  ,now())/3600 time_diff
            ,case plt.state
                when 1 then '丢失件待处理'
                when 2 then '疑似丢失件待处理'
                when 3 then '待工单回复'
                when 4 then '已工单回复'
                when 5 then '包裹未丢失'
                when 6 then '丢失件处理完成'
            end 闪速认定任务状态
        from ph_bi.parcel_lose_task plt
        left join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            plt.state in (1,2,3,4)
    ) a1
where
    ( a1.source = 3 and a1.time_diff > 48 )
    or a1.source !=3;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,cdt.id
    ,di.diff_marker_category
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
        end as 疑难原因
    ,convert_tz(di.created_at, '+00:00', '+08:00') 进入疑难件时间
    ,now() 当前时间
    ,if(plt.id is not null , '是', '否') 是否进入闪速
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 闪速认定任务状态
    ,if(timestampdiff(second ,convert_tz(di.created_at, '+00:00', '+08:00') ,now())/3600 > 24, '是', '否') 是否超24小时
    ,concat(timestampdiff(day,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'D', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00'), now())%24, 'H') 时间差
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
where
    di.state = 0
    and pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    a1.*
from
    (
        select
            plt.pno
            ,plt.state
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end 客户类型
            ,if(pi.state in (5,7,8,9), '是', '否') 包裹是否终态
            ,if(plt.created_at > convert_tz(pi.finished_at , '+00:00', '+08:00'), '是', '否') 是否终态后进入闪速
            ,case plt.source
                WHEN 1 THEN 'A-问题件-丢失'
                WHEN 2 THEN 'B-记录本-丢失'
                WHEN 3 THEN 'C-包裹状态未更新'
                WHEN 4 THEN 'D-问题件-破损/短少'
                WHEN 5 THEN 'E-记录本-索赔-丢失'
                WHEN 6 THEN 'F-记录本-索赔-破损/短少'
                WHEN 7 THEN 'G-记录本-索赔-其他'
                WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
                WHEN 9 THEN 'I-问题件-外包装破损险'
                WHEN 10 THEN 'J-问题记录本-外包装破损险'
                when 11 then 'K-超时效包裹'
                when 12 then 'L-高度疑似丢失'
            end 问题来源渠道
            ,plt.source
            ,concat(timestampdiff(day ,plt.created_at  ,now()), 'D', timestampdiff(hour ,plt.created_at  ,now())%24, 'H') 进入闪速时间
            ,if(timestampdiff(hour ,plt.created_at  ,now())/3600 > 24, '是', '否' ) 是否超24小时
            ,timestampdiff(second ,plt.created_at  ,now())/3600 time_diff
            ,case plt.state
                when 1 then '丢失件待处理'
                when 2 then '疑似丢失件待处理'
                when 3 then '待工单回复'
                when 4 then '已工单回复'
                when 5 then '包裹未丢失'
                when 6 then '丢失件处理完成'
            end 闪速认定任务状态
        from ph_bi.parcel_lose_task plt
        left join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            plt.state in (1,2,3,4)
    ) a1
where
    ( a1.source = 3 and a1.time_diff > 48 )
    or a1.source !=3;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno 运单号
    ,plt.created_at 任务生成时间
    ,concat('SSRD', plt.id) 任务ID
    ,case plt.vip_enable
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end 客户类型
    ,plt.client_id 客户ID
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount COGS
    ,ss.short_name 始发地
    ,ss2.short_name  目的地
    ,convert_tz(pi.created_at , '+00:00', '+07:00') 揽件时间
    ,cast(pi.exhibition_weight as double)/1000 '重量'
    ,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) '尺寸'
    ,case pi.parcel_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,case  plt.last_valid_action
        when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end 最后有效路由
    ,plt.last_valid_routed_at 最后有效路由网点
    ,plt.last_valid_staff_info_id 最后有效路由操作人
    ,ss3.name 最后有效路由网点
    ,case plt.is_abnormal
        when 1 then '是'
        when 0 then '否'
     end 是否异常
    ,group_concat(wo.order_no) 工单编号
    ,'C-包裹状态未更新' 问题来源渠道
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 状态
    ,if(plt.fleet_routeids is null, '一致', '不一致') 解封车是否异常
    ,plt.fleet_stores 异常区间
    ,fvp.van_line_name 异常车线
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join ph_staging.fleet_van_proof fvp on fvp.id = substring_index(plt.fleet_routeids, '/', 1)
left join ph_staging.sys_store ss3 on ss3.id = plt.last_valid_store_id
left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
where
    plt.state < 5
group by plt.id;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno 运单号
    ,plt.created_at 任务生成时间
    ,case plt.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,concat('SSRD', plt.id) 任务ID
    ,case plt.vip_enable
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end 客户类型
    ,plt.client_id 客户ID
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount COGS
    ,ss.short_name 始发地
    ,ss2.short_name  目的地
    ,convert_tz(pi.created_at , '+00:00', '+07:00') 揽件时间
    ,cast(pi.exhibition_weight as double)/1000 '重量'
    ,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) '尺寸'
    ,case pi.parcel_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,case  plt.last_valid_action
        when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end 最后有效路由
    ,plt.last_valid_routed_at 最后有效路由网点
    ,plt.last_valid_staff_info_id 最后有效路由操作人
    ,ss3.name 最后有效路由网点
    ,case plt.is_abnormal
        when 1 then '是'
        when 0 then '否'
     end 是否异常
    ,group_concat(wo.order_no) 工单编号
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 状态
    ,if(plt.fleet_routeids is null, '一致', '不一致') 解封车是否异常
    ,plt.fleet_stores 异常区间
    ,fvp.van_line_name 异常车线
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join ph_staging.fleet_van_proof fvp on fvp.id = substring_index(plt.fleet_routeids, '/', 1)
left join ph_staging.sys_store ss3 on ss3.id = plt.last_valid_store_id
left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
where
    plt.state < 5
group by plt.id;
;-- -. . -..- - / . -. - .-. -.--
select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,plt.should_do
    ,di.sh_do
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then 'ss2.name'
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
    ) di on di.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,plt.should_do
    ,di.sh_do
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
    ) di on di.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case
        when t1.state = 6 then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 then de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case
        when t1.state = 6 then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 then de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
            and di.pno = 'P35231NPHV3BE';
;-- -. . -..- - / . -. - .-. -.--
select
            di.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
#         join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
            and di.pno = 'P35231NPHV3BE';
;-- -. . -..- - / . -. - .-. -.--
select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
        and pi.pno = 'P35231NPHV3BE';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
        and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case
        when t1.state = 6 then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 then de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
            and di.pno = 'P35231NPHV3BE'
    ) di on di.pno = t1.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
        and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case
        when t1.state = 6 then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 then de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
            
    ) di on di.pno = t1.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
        and pi.pno = 'P35231NPHV3BE'
)
# select
#     t1.pno
#     ,case t1.state
#         when 1 then '已揽收'
#         when 2 then '运输中'
#         when 3 then '派送中'
#         when 4 then '已滞留'
#         when 5 then '已签收'
#         when 6 then '疑难件处理中'
#         when 7 then '已退件'
#         when 8 then '异常关闭'
#         when 9 then '已撤销'
#     end as 包裹状态
#     ,case
#         when t1.state = 6 then di.sh_do
#         when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
#         when t1.state != 6 then de.last_store_name
#     end 待处理节点
#     ,de.last_store_name
#     ,de.last_cn_route_action 最新一条有效路由
#     ,de.last_route_time 最新一条有效路由时间
# from t t1
# left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
# left join
#     (
#         select
#             plt.pno
#             ,group_concat(ss.name ) should_do
#         from ph_bi.parcel_lose_task plt
#         join t t1 on t1.pno = plt.pno
#         left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
#         left join ph_staging.sys_store ss on ss.id = wo.store_id
#         where
#             plt.state in (3)
#             and wo.status in (1,2)
#         group by 1
#
#         union  all
#
#         select
#             plt.pno
#             ,'QAQC' should_do
#         from ph_bi.parcel_lose_task plt
#         join t t1 on t1.pno = plt.pno
#         where
#             plt.state in (1,2,4)
#     ) plt on plt.pno = t1.pno
# left join
#     (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
        and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case
        when t1.state = 6 then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 then de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null

    ) di on di.pno = t1.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case
        when t1.state = 6 then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 then de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case
        when t1.state = 6 and di.sh_do not in ('QAQC') then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null then de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case
        when t1.state = 6 and di.sh_do not in ('QAQC') then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.sh_do not in ('QAQC') then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,cdt.negotiation_result_category
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.pno = 'P35171N44BWAP';
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,cdt.*
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.pno = 'P35171N44BWAP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.sh_do not in ('QAQC') then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
group by;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.sh_do not in ('QAQC') then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,de.last_store_name
    ,de.last_cn_route_action 最新一条有效路由
    ,de.last_route_time 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,cdt.*
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.pno = 'P2206126FUVAL';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.sh_do not in ('QAQC') then di.sh_do
        when t1.state = 6 and di.sh_do = 'QAQC' then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'QAQC'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null then '闪速系统沟通处理中'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else de.last_store_name
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null then '闪速系统沟通处理中'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else de.last_store_name
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null then '闪速系统沟通处理中'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else de.last_store_name
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else de.last_store_name
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,t1.returned
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id then '揽件未发出'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,t1.returned
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,t1.returned
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is not null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is not null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,t1.returned
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt2.pno is not null then plt.should_do
        when plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is not null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,t1.returned
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt2.pno is not null then plt.should_do
        when plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,t1.returned
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
from t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct ssp.pno) num
    ,count(ssp.pno) num2
from ph_bi.should_stocktaking_parcel_info_recently ssp
where
    ssp.stat_date = '2023-06-19';
;-- -. . -..- - / . -. - .-. -.--
select
#     count(distinct ssp.pno) num
#     ,count(ssp.pno) num2
    ssp.inventory_class
from ph_bi.should_stocktaking_parcel_info_recently ssp
where
    ssp.stat_date = '2023-06-19'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     count(distinct ssp.pno) num
#     ,count(ssp.pno) num2
    min(ssp.hour)
from ph_bi.should_stocktaking_parcel_info_recently ssp
where
    ssp.stat_date = '2023-06-19';
;-- -. . -..- - / . -. - .-. -.--
select
#     count(distinct ssp.pno) num
#     ,count(ssp.pno) num2
    max(ssp.hour)
from ph_bi.should_stocktaking_parcel_info_recently ssp
where
    ssp.stat_date = '2023-06-18';
;-- -. . -..- - / . -. - .-. -.--
select
#     count(distinct ssp.pno) num
#     ,count(ssp.pno) num2
    max(ssp.hour)
from ph_bi.should_stocktaking_parcel_info_recently ssp
where
    ssp.stat_date = '2023-06-19';
;-- -. . -..- - / . -. - .-. -.--
select
#     count(distinct ssp.pno) num
#     ,count(ssp.pno) num2
    ssp.express_category
from ph_bi.should_stocktaking_parcel_info_recently ssp
where
    ssp.stat_date = '2023-06-19'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select hour(now());
;-- -. . -..- - / . -. - .-. -.--
select
    case  a.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,a.疑难件创建时间段
    ,a.处理时间
    ,a.单量
    ,b.avg_deal_h 平均处理时长_hour
from
    (
        select
            di.diff_marker_category
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 1 then '1小时内'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 >= 1 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 2 then '1-2小时'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 2 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 24 then '2小时-1天'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 24 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 72 then '1-3天'
                else  '3天以上'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
        group by 1,2,3

        union all

        select
            di.diff_marker_category
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.first_operated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16)
        group by 1,2,3
    ) a
left join
    (
        select
            di.diff_marker_category
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
            and cdt.first_operated_at is not null
        group by 1,2

        union all

        select
            di.diff_marker_category
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16)
            and cdt.first_operated_at is not null
        group by 1,2

    ) b on a.diff_marker_category = b.diff_marker_category and a.疑难件创建时间段 = b.疑难件创建时间段;
;-- -. . -..- - / . -. - .-. -.--
select
    case  di.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,case cdt. negotiation_result_category
        when 1 then '赔偿'
        when 2 then '关闭订单(不赔偿不退货)'
        when 3 then '退货'
        when 4 then  '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK'
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
    end AS 协商结果
    ,count(di.id) 单量
from ph_staging.diff_info di
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.created_at >= '2023-05-31 16:00:00'
    and di.created_at < '2023-06-19 16:00:00'
    and bc.client_id is null  -- ka&小c
    and cdt.negotiation_result_category is not null
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            di.pno
            ,di.diff_marker_category
            ,di.id
            ,date(convert_tz(cdt.last_operated_at, '+00:00', '+08:00')) deal_date
            ,pcd.field_name
            ,count(if(pcd.field_name in ('dst_phone', 'dst_home_phone'), di.id, null)) change_phone_num
            ,count(if(pcd.field_name in ('dst_city_code', 'dst_detail_address', 'dst_district_code', 'dst_province_code'), di.id, null)) change_address_num
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        left join ph_staging.parcel_change_detail pcd on pcd.pno = di.pno and pcd.created_at > cdt.last_operated_at
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and cdt.negotiation_result_category = 5
        group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
select
    case a.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,count(if(a.change_phone_num > 0, id, null)) 修改电话量
    ,count(if(a.change_address_num > 0, id, null)) 修改地址量
    ,count(if(a.change_address_num > 0 and a.change_phone_num > 0, id, null)) 修改电话和地址量
    ,count(if(a.change_address_num = 0 and a.change_phone_num = 0, id, null)) 未修改电话和地址量
from
    (
        select
            di.pno
            ,di.diff_marker_category
            ,di.id
            ,date(convert_tz(cdt.last_operated_at, '+00:00', '+08:00')) deal_date
            ,pcd.field_name
            ,count(if(pcd.field_name in ('dst_phone', 'dst_home_phone'), di.id, null)) change_phone_num
            ,count(if(pcd.field_name in ('dst_city_code', 'dst_detail_address', 'dst_district_code', 'dst_province_code'), di.id, null)) change_address_num
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        left join ph_staging.parcel_change_detail pcd on pcd.pno = di.pno and pcd.created_at > cdt.last_operated_at
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and cdt.negotiation_result_category = 5
        group by 1,2,3,4
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.diff_marker_category
    ,count(distinct if(a.sub_num = 2, a.pno, null)) 提交2次_包裹量
    ,count(distinct if(a.sub_num = 3, a.pno, null)) 提交3次_包裹量
    ,count(distinct if(a.sub_num = 4, a.pno, null)) 提交4次_包裹量
    ,count(distinct if(a.sub_num = 5, a.pno, null)) 提交5次_包裹量
    ,count(distinct if(a.sub_num > 5, a.pno, null)) 提交5次以上_包裹量
from
    (
        select
            di.pno
            ,di.diff_marker_category
            ,count(di.id) sub_num
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null
        group by 1,2
    ) a
where
    a.sub_num >= 2
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case a.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,count(distinct if(a.sub_num = 2, a.pno, null)) 提交2次_包裹量
    ,count(distinct if(a.sub_num = 3, a.pno, null)) 提交3次_包裹量
    ,count(distinct if(a.sub_num = 4, a.pno, null)) 提交4次_包裹量
    ,count(distinct if(a.sub_num = 5, a.pno, null)) 提交5次_包裹量
    ,count(distinct if(a.sub_num > 5, a.pno, null)) 提交5次以上_包裹量
from
    (
        select
            di.pno
            ,di.diff_marker_category
            ,count(di.id) sub_num
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null
        group by 1,2
    ) a
where
    a.sub_num >= 2
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,count(di.id) sub_num
from ph_staging.diff_info di
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.created_at >= '2023-05-31 16:00:00'
    and di.created_at < '2023-06-19 16:00:00'
    and bc.client_id is null
group by 1
having count(di.id) >= 3;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when di.updated_at >= '2023-05-31 16:00:00' and di.updated_at < '2023-06-07 16:00:00' then '0601-0607'
        when di.updated_at >= '2023-06-07 16:00:00' and di.updated_at < '2023-06-14 16:00:00' then '0608-0614'
        when di.updated_at >= '2023-06-14 16:00:00' and di.updated_at < '2023-06-21 16:00:00' then '0614-0621'
        when di.updated_at >= '2023-06-07 16:00:00' and di.updated_at < '2023-06-14 16:00:00' then '0608-0614'
    end 周
    ,ss.name 网点
    ,count(di.id) 处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-19 16:00:00'
    and bc.client_id is null
    and di.state = 1
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when di.updated_at >= '2023-05-31 16:00:00' and di.updated_at < '2023-06-07 16:00:00' then '0601-0607'
        when di.updated_at >= '2023-06-07 16:00:00' and di.updated_at < '2023-06-14 16:00:00' then '0608-0614'
        when di.updated_at >= '2023-06-14 16:00:00' and di.updated_at < '2023-06-21 16:00:00' then '0614-0621'
        when di.updated_at >= '2023-06-07 16:00:00' and di.updated_at < '2023-06-14 16:00:00' then '0608-0614'
    end 周
    ,ss.name 网点
    ,count(di.id) 处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-19 16:00:00'
    and bc.client_id is null
    and di.state = 1
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when di.updated_at >= '2023-05-31 16:00:00' and di.updated_at < '2023-06-07 16:00:00' then '0601-0607'
        when di.updated_at >= '2023-06-07 16:00:00' and di.updated_at < '2023-06-14 16:00:00' then '0608-0614'
        when di.updated_at >= '2023-06-14 16:00:00' and di.updated_at < '2023-06-21 16:00:00' then '0614-0621'
        when di.updated_at >= '2023-06-07 16:00:00' and di.updated_at < '2023-06-14 16:00:00' then '0608-0614'
    end 周
    ,case ss.category
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
    ,ss.name 网点
    ,count(di.id) 处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-19 16:00:00'
    and bc.client_id is null
    and di.state = 1
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when di.updated_at >= '2023-05-31 16:00:00' and di.updated_at < '2023-06-07 16:00:00' then '0601-0607'
        when di.updated_at >= '2023-06-07 16:00:00' and di.updated_at < '2023-06-14 16:00:00' then '0608-0614'
        when di.updated_at >= '2023-06-14 16:00:00' and di.updated_at < '2023-06-21 16:00:00' then '0614-0621'
        when di.updated_at >= '2023-06-07 16:00:00' and di.updated_at < '2023-06-14 16:00:00' then '0608-0614'
    end 周
    ,case ss.category
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
    ,ss.name 网点
    ,count(di.id) 处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-19 16:00:00'
    and bc.client_id is null
    and di.state = 1
group by 1,2,3
order by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    case  a.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,a.疑难件创建时间段
    ,a.处理时间
    ,a.单量
    ,b.avg_deal_h 平均处理时长_hour
from
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 1 then '1小时内'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 >= 1 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 2 then '1-2小时'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 2 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 24 then '2小时-1天'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 24 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 72 then '1-3天'
                else  '3天以上'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
        group by 1,2,3,4

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.first_operated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16)
        group by 1,2,3
    ) a
left join
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
            and cdt.first_operated_at is not null
        group by 1,2

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16)
            and cdt.first_operated_at is not null
        group by 1,2

    ) b on a.diff_marker_category = b.diff_marker_category and a.疑难件创建时间段 = b.疑难件创建时间段 and a.类型 = b.类型;
;-- -. . -..- - / . -. - .-. -.--
select
    case  a.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,a.类型
    ,a.疑难件创建时间段
    ,a.处理时间
    ,a.单量
    ,b.avg_deal_h 平均处理时长_hour
from
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 1 then '1小时内'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 >= 1 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 2 then '1-2小时'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 2 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 24 then '2小时-1天'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 24 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 72 then '1-3天'
                else  '3天以上'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
        group by 1,2,3,4

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.first_operated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16)
        group by 1,2,3
    ) a
left join
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
            and cdt.first_operated_at is not null
        group by 1,2

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16)
            and cdt.first_operated_at is not null
        group by 1,2

    ) b on a.diff_marker_category = b.diff_marker_category and a.疑难件创建时间段 = b.疑难件创建时间段 and a.类型 = b.类型;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,if(ss.category = 6, 'FH', '网点') 类型
    ,cdt.first_operator_id
    ,count(di.id)/count(distinct date(convert_tz(di.updated_at, '+00:00', '+08:00'))) 日均处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.state = 1
    and di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-07 16:00:00'
    and bc.client_id is null
group by 1,2,3
order by 4 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,if(ss.category = 6, 'FH', '网点') 类型
    ,count(di.id)/count(distinct date(convert_tz(di.updated_at, '+00:00', '+08:00'))) 日均处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.state = 1
    and di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-07 16:00:00'
    and bc.client_id is null
group by 1,2
order by 3 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when di.updated_at >= '2023-05-31 16:00:00' and di.updated_at < '2023-06-07 16:00:00' then '0601-0607'
        when di.updated_at >= '2023-06-07 16:00:00' and di.updated_at < '2023-06-14 16:00:00' then '0608-0614'
    end 周
    ,case ss.category
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
    ,ss.name 网点
    ,count(di.id) 处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-14 16:00:00'
    and bc.client_id is null
    and di.state = 1
group by 1,2,3
order by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,if(ss.category = 6, 'FH', '网点') 类型
    ,count(di.id)/count(distinct date(convert_tz(di.updated_at, '+00:00', '+08:00'))) 日均处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.state = 1
    and di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-14 16:00:00'
    and bc.client_id is null
group by 1,2
order by 3 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,if(ss.category = 6, 'FH', '网点') 类型
    ,count(di.id)/count(distinct date(convert_tz(di.updated_at, '+00:00', '+08:00'))) 日均处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.state = 1
    and di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-01 16:00:00'
    and bc.client_id is null
group by 1,2
order by 3 desc;
;-- -. . -..- - / . -. - .-. -.--
select
	 di.pno '运单号'
     ,dd.client_name
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
	 ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
	 ,datediff('hour',if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ,CURRENT_TIME()) '未处理当前时间-上报时间/h'
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    date(convert_tz(di.updated_at,'+00:00','+08:00'))=curdate()
and di.state=1;
;-- -. . -..- - / . -. - .-. -.--
select
    case  a.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,a.类型
    ,a.疑难件创建时间段
    ,a.处理时间
    ,a.单量
    ,b.avg_deal_h 平均处理时长_hour
from
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 1 then '1小时内'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 >= 1 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 2 then '1-2小时'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 2 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 24 then '2小时-1天'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 24 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 72 then '1-3天'
                else  '3天以上'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
        group by 1,2,3,4

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.first_operated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) > 16)
        group by 1,2,3
    ) a
left join
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
            and cdt.first_operated_at is not null
        group by 1,2

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) > 16)
            and cdt.first_operated_at is not null
        group by 1,2

    ) b on a.diff_marker_category = b.diff_marker_category and a.疑难件创建时间段 = b.疑难件创建时间段 and a.类型 = b.类型;
;-- -. . -..- - / . -. - .-. -.--
select
	 di.pno '运单号'
     ,dd.client_name
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
	 ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
	 ,datediff('hour',if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ,CURRENT_TIME()) '未处理当前时间-上报时间/h'
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    date(convert_tz(di.updated_at,'+00:00','+08:00'))=curdate()
    and di.diff_marker_category in (23,73,29,78,25,75);
;-- -. . -..- - / . -. - .-. -.--
select
	 di.pno '运单号'
     ,dd.client_name
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
	 ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
	 ,datediff('hour',if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ,CURRENT_TIME()) '未处理当前时间-上报时间/h'
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    date(convert_tz(di.updated_at,'+00:00','+08:00'))=curdate()
    and di.diff_marker_category in (23,73,29,78,25,75)
    and di.state = 1;
;-- -. . -..- - / . -. - .-. -.--
select
	 di.pno '运单号'
     ,
     ,dd.client_name
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
	 ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
	 ,datediff('hour',if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ,CURRENT_TIME()) '未处理当前时间-上报时间/h'
    ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    di.diff_marker_category in (23,73,29,78,25,75)
    and di.state = 0;
;-- -. . -..- - / . -. - .-. -.--
select
	 di.pno '运单号'
     
     ,dd.client_name
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
	 ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
	 ,datediff('hour',if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ,CURRENT_TIME()) '未处理当前时间-上报时间/h'
    ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    di.diff_marker_category in (23,73,29,78,25,75)
    and di.state = 0;
;-- -. . -..- - / . -. - .-. -.--
select
	 di.pno '运单号'

     ,dd.client_name
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
	 ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
# 	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
	 ,datediff(now(),if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ) '未处理当前时间-上报时间/d'
    ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    di.diff_marker_category in (23,73,29,78,25,75)
    and di.state = 0;
;-- -. . -..- - / . -. - .-. -.--
select curdate();
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from ph_staging.parcel_info pi
join ph_bi.parcel_lose_task plt on plt.pno = pi.pno
where
    pi.state not in (5,7,8,9)
    and pi.dst_store_id = 'PH19040F05'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from ph_staging.parcel_info pi
join ph_bi.parcel_lose_task plt on plt.pno = pi.pno and pi.state = 6
where
    pi.state not in (5,7,8,9)
    and pi.dst_store_id = 'PH19040F05'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from ph_staging.parcel_info pi
join ph_bi.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 6
where
    pi.state not in (5,7,8,9)
    and pi.dst_store_id = 'PH19040F05'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from ph_staging.parcel_info pi
join ph_bi.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 6
left join dwm.dwd_ex_ph_parcel_details de on de.pno = pi.pno
where
    pi.state not in (5,7,8,9)
    and pi.dst_store_id = 'PH19040F05'
    and de.last_store_id = 'PH19040F05'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
	 di.pno '运单号'
     ,dd.client_name 客户名称
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
	 ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
# 	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
# 	 ,datediff(now(),if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ) '未处理当前时间-上报时间/d'
#     ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
    ,case
        when di.created_at >= date_add(curdate(), interval 12 hour ) then '当日20点后'
        when di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ) then '积压时间 0 day'
        when di.created_at < date_sub(curdate(), interval 8 hour ) then concat('积压时间', datediff(now(), convert_tz(di.created_at , '+00:00', '+08:00'), ' day'))
    end 积压时长
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    di.diff_marker_category in (23,73,29,78,25,75)
    and di.state = 1
    and di.updated_at >= date_sub(curdate(), interval 8 hour )
    and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理

union all

select
	 di.pno '运单号'
     ,dd.client_name 客户名称
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
	 ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
# 	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
# 	 ,datediff(now(),if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ) '未处理当前时间-上报时间/d'
#     ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
    ,case
        when di.created_at >= date_add(curdate(), interval 12 hour ) then '当日20点后'
        when di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ) then '积压时间 0 day'
        when di.created_at < date_sub(curdate(), interval 8 hour ) then concat('积压时间', datediff(now(), convert_tz(di.created_at , '+00:00', '+08:00'), ' day'))
    end 积压时长
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    di.diff_marker_category in (23,73,29,78,25,75)
    and di.state = 0;
;-- -. . -..- - / . -. - .-. -.--
select
    bc.client_name
    ,tdt2.cn_element 疑难件原因
    ,case cdt.negotiation_result_category
        when 1 then '赔偿'
        when 2 then '关闭订单(不赔偿不退货)'
        when 3 then'退货'
        when 4 then '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK'
        when 9 then '货物找回，继续派送'
        when 10 then  '改包裹状态'
        when 11 then '需客户修改信息'
        when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
    end 处理结果
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.updated_at >= date_sub(curdate(), interval 8 hour )
    and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
    and di.state = 1 -- 已处理
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    bc.client_name
    ,tdt2.cn_element 疑难件原因
    ,case cdt.negotiation_result_category
        when 1 then '赔偿'
        when 2 then '关闭订单(不赔偿不退货)'
        when 3 then'退货'
        when 4 then '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK'
        when 9 then '货物找回，继续派送'
        when 10 then  '改包裹状态'
        when 11 then '需客户修改信息'
        when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
    end 处理结果
    ,count(di.id) 单量
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.updated_at >= date_sub(curdate(), interval 8 hour )
    and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
    and di.state = 1 -- 已处理
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.client_name 客户
    ,a.疑难件原因
    ,max(if(a.处理结果 = '继续配送',a.单量, null)) 继续派送
    ,max(if(a.处理结果 = '退货',a.单量, null)) 退货
from
    (
        select
            bc.client_name
            ,tdt2.cn_element 疑难件原因
            ,case cdt.negotiation_result_category
                when 1 then '赔偿'
                when 2 then '关闭订单(不赔偿不退货)'
                when 3 then'退货'
                when 4 then '退货并赔偿'
                when 5 then '继续配送'
                when 6 then '继续配送并赔偿'
                when 7 then '正在沟通中'
                when 8 then '丢弃包裹的，换单后寄回BKK'
                when 9 then '货物找回，继续派送'
                when 10 then  '改包裹状态'
                when 11 then '需客户修改信息'
                when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
            end 处理结果
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
        left join ph_staging.parcel_info pi on pi.pno = di.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            di.updated_at >= date_sub(curdate(), interval 8 hour )
            and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
            and di.state = 1 -- 已处理
            and di.diff_marker_category in (23,73,29,78,25,75)
        group by 1,2
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.client_name 客户
    ,a.疑难件原因
    ,max(if(a.处理结果 = '继续配送',a.单量, null)) 继续派送
    ,max(if(a.处理结果 = '退货',a.单量, null)) 退货
from
    (
        select
            bc.client_name
            ,tdt2.cn_element 疑难件原因
            ,case cdt.negotiation_result_category
                when 1 then '赔偿'
                when 2 then '关闭订单(不赔偿不退货)'
                when 3 then'退货'
                when 4 then '退货并赔偿'
                when 5 then '继续配送'
                when 6 then '继续配送并赔偿'
                when 7 then '正在沟通中'
                when 8 then '丢弃包裹的，换单后寄回BKK'
                when 9 then '货物找回，继续派送'
                when 10 then  '改包裹状态'
                when 11 then '需客户修改信息'
                when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
            end 处理结果
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
        left join ph_staging.parcel_info pi on pi.pno = di.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            di.updated_at >= date_sub(curdate(), interval 8 hour )
            and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
            and di.state = 1 -- 已处理
            and di.diff_marker_category in (23,73,29,78,25,75)
        group by 1,2
    ) a
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.client_name 客户
    ,a.疑难件原因
    ,max(if(a.处理结果 = '继续配送',a.单量, null)) 继续派送
    ,max(if(a.处理结果 = '退货',a.单量, null)) 退货
from
    (
        select
            bc.client_name
            ,tdt2.cn_element 疑难件原因
            ,case cdt.negotiation_result_category
                when 1 then '赔偿'
                when 2 then '关闭订单(不赔偿不退货)'
                when 3 then'退货'
                when 4 then '退货并赔偿'
                when 5 then '继续配送'
                when 6 then '继续配送并赔偿'
                when 7 then '正在沟通中'
                when 8 then '丢弃包裹的，换单后寄回BKK'
                when 9 then '货物找回，继续派送'
                when 10 then  '改包裹状态'
                when 11 then '需客户修改信息'
                when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
            end 处理结果
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
        left join ph_staging.parcel_info pi on pi.pno = di.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            di.updated_at >= date_sub(curdate(), interval 8 hour )
            and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
            and di.state = 1 -- 已处理
            and di.diff_marker_category in (23,73,29,78,25,75)
        group by 1,2,3
    ) a
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
	 di.pno '运单号'
     ,dd.client_name 客户名称
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
	 ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  else pi.state
      end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
# 	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
# 	 ,datediff(now(),if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ) '未处理当前时间-上报时间/d'
#     ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
    ,case
        when di.created_at >= date_add(curdate(), interval 12 hour ) then '当日20点后'
        when di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ) then '积压时间 0 day'
        when di.created_at < date_sub(curdate(), interval 8 hour ) then concat('积压时间', datediff(now(), convert_tz(di.created_at , '+00:00', '+08:00'), ' day'))
    end 积压时长
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    di.diff_marker_category in (23,73,29,78,25,75)
    and di.state = 1
    and di.updated_at >= date_sub(curdate(), interval 8 hour )
    and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理

union all

select
	 di.pno '运单号'
     ,dd.client_name 客户名称
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
	 ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
# 	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
# 	 ,datediff(now(),if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ) '未处理当前时间-上报时间/d'
#     ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
    ,case
        when di.created_at >= date_add(curdate(), interval 12 hour ) then '当日20点后'
        when di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ) then '积压时间 0 day'
        when di.created_at < date_sub(curdate(), interval 8 hour ) then concat('积压时间', datediff(now(), convert_tz(di.created_at , '+00:00', '+08:00'), ' day'))
    end 积压时长
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    di.diff_marker_category in (23,73,29,78,25,75)
    and di.state = 0;
;-- -. . -..- - / . -. - .-. -.--
select
    case  a.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,a.类型
    ,a.疑难件创建时间段
    ,a.处理时间
    ,a.单量
    ,b.avg_deal_h 平均处理时长_hour
from
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 1 then '1小时内'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 >= 1 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 2 then '1-2小时'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 2 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 24 then '2小时-1天'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 24 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 72 then '1-3天'
                else  '3天以上'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
        group by 1,2,3,4

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.first_operated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
        group by 1,2,3
    ) a
left join
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
            and cdt.first_operated_at is not null
        group by 1,2

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
            and cdt.first_operated_at is not null
        group by 1,2

    ) b on a.diff_marker_category = b.diff_marker_category and a.疑难件创建时间段 = b.疑难件创建时间段 and a.类型 = b.类型;
;-- -. . -..- - / . -. - .-. -.--
select
    case  di.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,case cdt. negotiation_result_category
        when 1 then '赔偿'
        when 2 then '关闭订单(不赔偿不退货)'
        when 3 then '退货'
        when 4 then  '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK'
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
    end AS 协商结果
    ,if(ss.category = 6, 'FH', '网点') 类型
    ,count(di.id) 单量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.created_at >= '2023-05-31 16:00:00'
    and di.created_at < '2023-06-19 16:00:00'
    and bc.client_id is null  -- ka&小c
    and cdt.negotiation_result_category is not null
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    a.client_name 客户
    ,a.疑难件原因
    ,max(if(a.处理结果 = '继续配送',a.单量, 0)) 继续派送
    ,max(if(a.处理结果 = '退货',a.单量, 0)) 退货
from
    (
        select
            bc.client_name
            ,tdt2.cn_element 疑难件原因
            ,case cdt.negotiation_result_category
                when 1 then '赔偿'
                when 2 then '关闭订单(不赔偿不退货)'
                when 3 then'退货'
                when 4 then '退货并赔偿'
                when 5 then '继续配送'
                when 6 then '继续配送并赔偿'
                when 7 then '正在沟通中'
                when 8 then '丢弃包裹的，换单后寄回BKK'
                when 9 then '货物找回，继续派送'
                when 10 then  '改包裹状态'
                when 11 then '需客户修改信息'
                when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
            end 处理结果
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
        left join ph_staging.parcel_info pi on pi.pno = di.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            di.updated_at >= date_sub(curdate(), interval 8 hour )
            and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
            and di.state = 1 -- 已处理
            and di.diff_marker_category in (23,73,29,78,25,75)
        group by 1,2,3
    ) a
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.first_operated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.first_operated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
#             ,count(di.id) 单量
            ,di.id
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16);
;-- -. . -..- - / . -. - .-. -.--
select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.first_operated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
            ,convert_tz(di.created_at, '+00:00', '+08:00') 创建时间
            ,convert_tz(di.created_at, '+00:00', '+08:00') 第一次处理时间
#             ,count(di.id) 单量
            ,di.id
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16);
;-- -. . -..- - / . -. - .-. -.--
select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.first_operated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
            ,convert_tz(di.created_at, '+00:00', '+08:00') 创建时间
            ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00') 第一次处理时间
#             ,count(di.id) 单量
            ,di.id
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,de.src_store 揽收网点
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    bc.client_name
    ,tdt2.cn_element 疑难件原因
#     ,case cdt.negotiation_result_category
#         when 1 then '赔偿'
#         when 2 then '关闭订单(不赔偿不退货)'
#         when 3 then'退货'
#         when 4 then '退货并赔偿'
#         when 5 then '继续配送'
#         when 6 then '继续配送并赔偿'
#         when 7 then '正在沟通中'
#         when 8 then '丢弃包裹的，换单后寄回BKK'
#         when 9 then '货物找回，继续派送'
#         when 10 then  '改包裹状态'
#         when 11 then '需客户修改信息'
#         when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
#     end 处理结果
    ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
    ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
    ,count(di.id) 总疑难件量
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.updated_at >= date_sub(curdate(), interval 8 hour )
    and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
    and di.state = 1 -- 已处理
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.cod_enabled
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,de.src_store 揽收网点
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,pi.src_phone
    ,pi.src_name
    ,pi.dst_phone
    ,pi.dst_name
    ,fp.id
    ,fp.name
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0621 t on t.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.franchisee_profile fp on fp.id = ss.franchisee_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pcd.field_name
from ph_staging.parcel_change_detail pcd
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    bc.client_name
    ,tdt2.cn_element 疑难件原因
    ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
    ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
    ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.state = 0
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    bc.client_name
    ,tdt2.cn_element 疑难件原因
    ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
    ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
    ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.state = 0
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2
order by 1,2
with rollup;
;-- -. . -..- - / . -. - .-. -.--
select
    bc.client_name
    ,tdt2.cn_element 疑难件原因
    ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
    ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
    ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.state = 0
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2
# order by 1,2
with rollup;
;-- -. . -..- - / . -. - .-. -.--
select
    coalesce(bc.client_name, '总计') client_name
    ,coalesce(tdt2.cn_element, '总计') 疑难件原因
    ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
    ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
    ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.state = 0
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2
with rollup
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ifnull(bc.client_name, '总计') client_name
    ,ifnull(tdt2.cn_element, '总计') 疑难件原因
    ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
    ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
    ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.state = 0
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2
with rollup
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ifnull(bc.client_name, '总计') client_name
    ,ifnull(tdt2.cn_element, '总计') 疑难件原因
    ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
    ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
    ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.state = 0
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2
with rollup;
;-- -. . -..- - / . -. - .-. -.--
select
    coalesce(a.client_name, '总计') client_name
    ,coalesce(a.疑难件原因, '总计') 疑难件原因
    ,a.当日20点后
    ,a.积压时间0day
    ,a.积压1天及以上
from
    (
            select
            coalesce(bc.client_name, '总计') client_name
            ,coalesce(tdt2.cn_element, '总计') 疑难件原因
            ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
            ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
            ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
        from ph_staging.diff_info di
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
        left join ph_staging.parcel_info pi on pi.pno = di.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            di.state = 0
            and di.diff_marker_category in (23,73,29,78,25,75)
        group by 1,2
        with rollup
    ) a
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    bc.client_name
    ,tdt2.cn_element 疑难件原因
    ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
    ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
    ,count(di.id) 总疑难件量
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.updated_at >= date_sub(curdate(), interval 8 hour )
    and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
    and di.state = 1 -- 已处理
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    bc.client_name
    ,tdt2.cn_element 疑难件原因
    ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
    ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
    ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
    ,count(di.id) 总疑难件量
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.updated_at >= date_sub(curdate(), interval 8 hour )
    and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
    and di.state = 1 -- 已处理
    and di.diff_marker_category in (23,73,29,78,25,75)
group by 1,2
with rollup;
;-- -. . -..- - / . -. - .-. -.--
select
    coalesce(a.client_name, '总计') client_name
    ,coalesce(a.疑难件原因, '总计') 疑难件原因
    ,a.`0-2小时`
    ,a.`2-4小时`
    ,a.`4-6小时`
    ,a.总疑难件量
    ,a.继续配送
    ,a.退货
from
    (
        select
            bc.client_name
            ,tdt2.cn_element 疑难件原因
            ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
            ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
            ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
            ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
            ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
            ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
            ,count(di.id) 总疑难件量
        from ph_staging.diff_info di
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
        left join ph_staging.parcel_info pi on pi.pno = di.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            di.updated_at >= date_sub(curdate(), interval 8 hour )
            and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
            and di.state = 1 -- 已处理
            and di.diff_marker_category in (23,73,29,78,25,75)
        group by 1,2
        with rollup
    ) a
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            dd.cn_element
        from dwm.dwd_dim_dict dd
        where
            dd.db = 'ph_staging'
            and dd.tablename = 'diff_info'
            and dd.fieldname = 'diff_marker_category'
            and dd.element in (23,73,29,78,25,75)
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            bc.client_name
        from dwm.dwd_dim_bigClient bc
        group by 1
    ) a
cross join
    (
        select
            dd.cn_element
        from dwm.dwd_dim_dict dd
        where
            dd.db = 'ph_staging'
            and dd.tablename = 'diff_info'
            and dd.fieldname = 'diff_marker_category'
            and dd.element in (23,73,29,78,25,75)
        group by 1
    ) b;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            bc.client_name
        from dwm.dwd_dim_bigClient bc
        group by 1
    ) a
cross join
    (
        select
            dd.cn_element
        from dwm.dwd_dim_dict dd
        where
            dd.db = 'ph_staging'
            and dd.tablename = 'diff_info'
            and dd.fieldname = 'diff_marker_category'
            and dd.element in (23,73,29,78,25,75)
        group by 1
    ) b
group by 1,2
with rollup;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        coalesce(a.client_name, '总计') client_name
        ,coalesce(a.疑难件原因, '总计') 疑难件原因
        ,a.`0-2小时`
        ,a.`2-4小时`
        ,a.`4-6小时`
        ,a.总疑难件量
        ,a.继续配送
        ,a.退货
    from
        (
            select
                bc.client_name
                ,tdt2.cn_element 疑难件原因
                ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
                ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
                ,count(di.id) 总疑难件量
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.updated_at >= date_sub(curdate(), interval 8 hour )
                and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
                and di.state = 1 -- 已处理
                and di.diff_marker_category in (23,73,29,78,25,75)
            group by 1,2
            with rollup
        ) a
    order by 1,2
),
b as
(
        select
        coalesce(a.client_name, '总计') client_name
        ,coalesce(a.疑难件原因, '总计') 疑难件原因
        ,a.当日20点后
        ,a.积压时间0day
        ,a.积压1天及以上
    from
        (
                select
                coalesce(bc.client_name, '总计') client_name
                ,coalesce(tdt2.cn_element, '总计') 疑难件原因
                ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
                ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
                ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.state = 0
                and di.diff_marker_category in (23,73,29,78,25,75)
            group by 1,2
            with rollup
        ) a
    order by 1,2
)
select
    t1.client_name
    ,t1.疑难件原因
    ,a1.`0-2小时`
    ,a1.`2-4小时`
    ,a1.`4-6小时`
    ,a1.继续配送
    ,a1.退货
    ,a1.总疑难件量
    ,b1.当日20点后
    ,b1.积压时间0day
    ,b1.积压1天及以上
from
    (
        select
            t1.疑难件原因
            ,t1.client_name
        from
            (
                select
                    a.client_name
                    ,a.疑难件原因
                from a

                union

                select
                    b.client_name
                    ,b.疑难件原因
                from b
            ) t1
        group by 1,2
    ) t1
left join a a1 on t1.client_name = a1.client_name and t1.疑难件原因 = a1.疑难件原因
left join b b1 on t1.client_name = b1.client_name and t1.疑难件原因 = b1.疑难件原因
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        coalesce(a.client_name, '总计') client_name
        ,coalesce(a.疑难件原因, '总计') 疑难件原因
        ,a.`0-2小时`
        ,a.`2-4小时`
        ,a.`4-6小时`
        ,a.`6小时以上`
        ,a.总疑难件量
        ,a.继续配送
        ,a.退货
    from
        (
            select
                bc.client_name
                ,tdt2.cn_element 疑难件原因
                ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
                ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
                ,count(di.id) 总疑难件量
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.updated_at >= date_sub(curdate(), interval 8 hour )
                and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
                and di.state = 1 -- 已处理
                and di.diff_marker_category in (23,73,29,78,25,75)
            group by 1,2
            with rollup
        ) a
    order by 1,2
),
b as
(
        select
        coalesce(a.client_name, '总计') client_name
        ,coalesce(a.疑难件原因, '总计') 疑难件原因
        ,a.当日20点后
        ,a.积压时间0day
        ,a.积压1天及以上
    from
        (
                select
                coalesce(bc.client_name, '总计') client_name
                ,coalesce(tdt2.cn_element, '总计') 疑难件原因
                ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
                ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
                ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.state = 0
                and di.diff_marker_category in (23,73,29,78,25,75)
            group by 1,2
            with rollup
        ) a
    order by 1,2
)
select
    t1.client_name
    ,t1.疑难件原因
    ,a1.`0-2小时`
    ,a1.`2-4小时`
    ,a1.`4-6小时`
    ,a1.`6小时以上`
    ,a1.继续配送
    ,a1.退货
    ,a1.总疑难件量
    ,b1.当日20点后
    ,b1.积压时间0day
    ,b1.积压1天及以上
from
    (
        select
            t1.疑难件原因
            ,t1.client_name
        from
            (
                select
                    a.client_name
                    ,a.疑难件原因
                from a

                union

                select
                    b.client_name
                    ,b.疑难件原因
                from b
            ) t1
        group by 1,2
    ) t1
left join a a1 on t1.client_name = a1.client_name and t1.疑难件原因 = a1.疑难件原因
left join b b1 on t1.client_name = b1.client_name and t1.疑难件原因 = b1.疑难件原因
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        coalesce(a.client_name, '总计') client_name
        ,coalesce(a.疑难件原因, '总计') 疑难件原因
        ,a.`0-2小时`
        ,a.`2-4小时`
        ,a.`4-6小时`
        ,a.`6小时以上`
        ,a.总疑难件量
        ,a.继续配送
        ,a.退货
    from
        (
            select
                bc.client_name
                ,tdt2.cn_element 疑难件原因
                ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
                ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
                ,count(di.id) 总疑难件量
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.updated_at >= date_sub(curdate(), interval 8 hour )
                and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理
                and di.state = 1 -- 已处理
                and di.diff_marker_category in (23,73,29,78,25,75,2,17)
            group by 1,2
            with rollup
        ) a
    order by 1,2
),
b as
(
        select
        coalesce(a.client_name, '总计') client_name
        ,coalesce(a.疑难件原因, '总计') 疑难件原因
        ,a.当日20点后
        ,a.积压时间0day
        ,a.积压1天及以上
    from
        (
                select
                coalesce(bc.client_name, '总计') client_name
                ,coalesce(tdt2.cn_element, '总计') 疑难件原因
                ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
                ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
                ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.state = 0
                and di.diff_marker_category in (23,73,29,78,25,75,2,17)
            group by 1,2
            with rollup
        ) a
    order by 1,2
)
select
    t1.client_name
    ,t1.疑难件原因
    ,a1.`0-2小时`
    ,a1.`2-4小时`
    ,a1.`4-6小时`
    ,a1.`6小时以上`
    ,a1.继续配送
    ,a1.退货
    ,a1.总疑难件量
    ,b1.当日20点后
    ,b1.积压时间0day
    ,b1.积压1天及以上
from
    (
        select
            t1.疑难件原因
            ,t1.client_name
        from
            (
                select
                    a.client_name
                    ,a.疑难件原因
                from a

                union

                select
                    b.client_name
                    ,b.疑难件原因
                from b
            ) t1
        group by 1,2
    ) t1
left join a a1 on t1.client_name = a1.client_name and t1.疑难件原因 = a1.疑难件原因
left join b b1 on t1.client_name = b1.client_name and t1.疑难件原因 = b1.疑难件原因
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
                bc.client_name
                ,tdt2.cn_element 疑难件原因
                ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
                ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
                ,count(di.id) 总疑难件量
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.updated_at >= date_sub('$.date1', interval 8 hour )
                and di.updated_at < date_add('$.date1', interval 16 hour ) -- 今日处理
                and di.state = 1 -- 已处理
                and di.diff_marker_category in (23,73,29,78,25,75,2,17)
            group by 1,2
            with rollup;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        coalesce(a.client_name, '总计') client_name
        ,coalesce(a.疑难件原因, '总计') 疑难件原因
        ,a.`0-2小时`
        ,a.`2-4小时`
        ,a.`4-6小时`
        ,a.`6小时以上`
        ,a.总疑难件量
        ,a.继续配送
        ,a.退货
    from
        (
            select
                bc.client_name
                ,tdt2.cn_element 疑难件原因
                ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
                ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
                ,count(di.id) 总疑难件量
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.updated_at >= date_sub('2023-06-22', interval 8 hour )
                and di.updated_at < date_add('2023-06-22', interval 16 hour ) -- 今日处理
                and di.state = 1 -- 已处理
                and di.diff_marker_category in (23,73,29,78,25,75,2,17)
            group by 1,2
            with rollup
        ) a
    order by 1,2
),
b as
(
        select
        coalesce(a.client_name, '总计') client_name
        ,coalesce(a.疑难件原因, '总计') 疑难件原因
        ,a.当日20点后
        ,a.积压时间0day
        ,a.积压1天及以上
    from
        (
                select
                coalesce(bc.client_name, '总计') client_name
                ,coalesce(tdt2.cn_element, '总计') 疑难件原因
                ,count(if(di.created_at >= date_add(curdate(), interval 12 hour), di.id, null)) 当日20点后
                ,count(if(di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ), di.id, null)) '积压时间0day'
                ,count(if(di.created_at < date_sub(curdate(), interval 8 hour ), di.id, null)) '积压1天及以上'
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.diff_marker_category in (23,73,29,78,25,75,2,17)
                and
                (
                    (di.state = 0 and di.created_at < date_add('2023-06-22', interval  16 hour) )
                    or (di.state = 1 and di.created_at < date_add('2023-06-22', interval  16 hour) and di.updated_at >= date_add('2023-06-22', interval  16 hour))
                )
            group by 1,2
            with rollup
        ) a
    order by 1,2
)
select
    t1.client_name
    ,t1.疑难件原因
    ,a1.`0-2小时`
    ,a1.`2-4小时`
    ,a1.`4-6小时`
    ,a1.`6小时以上`
    ,a1.继续配送
    ,a1.退货
    ,a1.总疑难件量
    ,b1.当日20点后
    ,b1.积压时间0day
    ,b1.积压1天及以上
from
    (
        select
            t1.疑难件原因
            ,t1.client_name
        from
            (
                select
                    a.client_name
                    ,a.疑难件原因
                from a

                union

                select
                    b.client_name
                    ,b.疑难件原因
                from b
            ) t1
        group by 1,2
    ) t1
left join a a1 on t1.client_name = a1.client_name and t1.疑难件原因 = a1.疑难件原因
left join b b1 on t1.client_name = b1.client_name and t1.疑难件原因 = b1.疑难件原因
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
                bc.client_name
                ,tdt2.cn_element 疑难件原因
                ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
                ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
                ,sum(if(cdt.operator_id not in (10000,10001,100002), timestampdiff(second , di.created_at, di.updated_at)/3600, null))/count(if(cdt.operator_id not in (10000,10001,100002), di.id, null)) 平均处理时长_h
                ,count(di.id) 总疑难件量
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.updated_at >= date_sub('2023-06-22', interval 8 hour )
                and di.updated_at < date_add('2023-06-22', interval 16 hour ) -- 今日处理
                and di.state = 1 -- 已处理
                and di.diff_marker_category in (23,73,29,78,25,75,2,17)
            group by 1,2
            with rollup;
;-- -. . -..- - / . -. - .-. -.--
select
    count(di.id)
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
where
    di.diff_marker_category in (2,17)
    and date(convert_tz(di.created_at ,'+00:00', '+08:00')) = '2023-06-22';
;-- -. . -..- - / . -. - .-. -.--
select
    count(di.id)
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
where
    di.diff_marker_category in (2,17)
    and date(convert_tz(di.created_at ,'+00:00', '+08:00')) = '2023-06-21';
;-- -. . -..- - / . -. - .-. -.--
select
    count(di.id)
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
where
    di.diff_marker_category in (2,17)
    and date(convert_tz(di.created_at ,'+00:00', '+08:00')) = '2023-06-20';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.cod_enabled
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,de.src_store 揽收网点
    ,de.pickup_time 揽收时间
    ,de.pick_date 揽收日期
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
        ssp.pno
        ,ssp.inventory_class
    from ph_bi.should_stocktaking_parcel_info_recently ssp
    where
        ssp.stat_date = curdate()
        and ssp.hour = hour(now());
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ssp.pno
        ,ssp.inventory_class
    from ph_bi.should_stocktaking_parcel_info_recently ssp
    where
        ssp.stat_date = curdate()
        and ssp.hour = hour(now())
)
select
    t1.pno
    ,case t1.inventory_class
        when 1 then '今日应到包裹未入仓'
        when 2 then '历史应到包裹未更新'
        when 3 then '今日应盘留仓件'
        when 4 then '今日应盘问题件'
    end 应盘类型
    ,pi.src_name 寄件人姓名
    ,pi.src_detail_address 寄件人地址
    ,pi.dst_name 收件人姓名
    ,pi.dst_detail_address 收件人地址
    ,pi.dst_phone 收件人电话
    ,pi.dst_home_phone 收件人家庭电话
    ,dp.store_name 当前网点
    ,dp.piece_name 当前片区
    ,dp.region_name 当前大区
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 当前状态
    ,if(pi.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,dp2.store_name 揽收网点
    ,dp2.piece_name 揽收片区
    ,dp2.region_name 揽收大区
    ,ss.name 目的地网点
    ,pr.CN_element 最后一条有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一条有效路由时间
    ,if(pi.state = 1, datediff(now(), convert_tz(pi.created_at, '+00:00', '+08:00')), datediff(now(), de.dst_routed_at)) 在仓天数
    ,de.discard_enabled 是否为丢弃
    ,de.inventorys 盘库次数
    ,convert_tz(pr2.routed_at, '+00:00', '+08:00') 最后一次盘库时间
    ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) 最后一次盘库日期
    ,if(pr3.pno is not null, '是', '否') 是否有效盘库
    ,convert_tz(pr3.routed_at, '+00:00', '+08:00') 今日最后一次盘库时间
from  t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join ph_staging.parcel_info pi on pi.pno = t1.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_id
            ,ddd.CN_element
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t2 on t2.pno = pr.pno
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.ticket_pickup_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
#                     and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr2 on pr2.pno = t1.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr3 on pr3.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
        count(ssp.pno) t1
        ,count(distinct ssp.pno) t2
    from ph_bi.should_stocktaking_parcel_info_recently ssp
    where
        ssp.stat_date = curdate()
        and ssp.hour = hour(now());
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,count(distinct date(convert_tz(ppd.created_at, '+00:00', '+08:00'))) 尝试天数
from ph_staging.parcel_problem_detail ppd
join tmpale.tmp_ph_try_pno_0623 t on t.pno = ppd.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,count(distinct date(convert_tz(tdm.created_at, '+00:00', '+08:00')) ) 尝试天数
from ph_staging.ticket_delivery td
join tmpale.tmp_ph_try_pno_0623 t on t.pno = td.pno
left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ssp.pno
        ,ssp.inventory_class
    from ph_bi.should_stocktaking_parcel_info_recently ssp
    where
        ssp.stat_date = curdate()
        and ssp.hour = hour(now())
)
select
    t1.pno
    ,case t1.inventory_class
        when 1 then '今日应到包裹未入仓'
        when 2 then '历史应到包裹未更新'
        when 3 then '今日应盘留仓件'
        when 4 then '今日应盘问题件'
    end 应盘类型
    ,pi.src_name 寄件人姓名
    ,pi.src_detail_address 寄件人地址
    ,pi.dst_name 收件人姓名
    ,pi.dst_detail_address 收件人地址
    ,pi.dst_phone 收件人电话
    ,pi.dst_home_phone 收件人家庭电话
    ,dp.store_name 当前网点
    ,dp.piece_name 当前片区
    ,dp.region_name 当前大区
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 当前状态
    ,if(pi.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,dp2.store_name 揽收网点
    ,dp2.piece_name 揽收片区
    ,dp2.region_name 揽收大区
    ,ss.name 目的地网点
    ,pr.CN_element 最后一条有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一条有效路由时间
    ,if(pi.state = 1, datediff(now(), convert_tz(pi.created_at, '+00:00', '+08:00')), datediff(now(), de.dst_routed_at)) 在仓天数
    ,de.discard_enabled 是否为丢弃
    ,de.inventorys 盘库次数
    ,convert_tz(pr2.routed_at, '+00:00', '+08:00') 最后一次盘库时间
    ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) 最后一次盘库日期
    ,if(pr2.routed_at > date_add(curdate(), interval 8 hour), '是', '否') 是否有效盘库
    ,if(pr2.routed_at > date_sub(curdate(), interval 8 hour), convert_tz(pr2.routed_at, '+00:00', '+08:00'), null) 今日最后一次盘库时间
from  t t1
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join ph_staging.parcel_info pi on pi.pno = t1.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_id
            ,ddd.CN_element
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t2 on t2.pno = pr.pno
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.ticket_pickup_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
#                     and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr2 on pr2.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
SELECT
pr.pno
,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key)) url

from
    (
        select
            pr.pno
            ,json_extract(pr.extra_value,'$.routeExtraId') routeExtraId
        from ph_staging.parcel_route pr
        where
            pr.route_action ='DIFFICULTY_HANDOVER'
            and pr.marker_category in (5,20)
            and pr.created_at > '2023-05-31 16:00:00'
    )pr
left join
    (
        select
            pre.pno
            ,pre.route_extra_id
            ,c
        from
        (
            select
                pre.pno
                ,pre.route_extra_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') value
            from dwm.drds_ph_parcel_route_extra pre
            where
                pre.created_at > '2023-05-31 16:00:00'
#                 and pre.created_at<'2023-04-01'
        )pre
        lateral view explode(split(pre.value, ',')) id as c
    )pre on pr.routeExtraId=pre.route_extra_id
left join ph_staging.sys_attachment sa on sa.id=pre.c
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,mw.operator_name 操作人
        ,case swm.type
            when 1 then '派件低效'
            when 3 then '虚假操作'
            when 4 then '虚假打卡'
        end 违规类型
        ,json_extract(swm.data_bucket, '$.false_type') 虚假类型
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_backyard.staff_warning_message swm on swm.id = mw.staff_warning_message_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-06-01'
#     and mw.created_at < '2023-05-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,de.dst_store
        ,de.dst_piece
        ,de.dst_region
        ,pi.dst_phone
        ,pi.dst_home_phone
    from ph_staging.parcel_info pi
    left join dwm.dwd_ex_ph_parcel_details de on de.pno = pi.pno
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    where
        pi.state not in (5,7,8,9)
        and de.dst_routed_at is not null
        and datediff(curdate(), de.dst_routed_at) >= 7
        and bc.client_id is null
)
select
    t1.pno 运单号
    ,t1.dst_region 目的地大区
    ,t1.dst_piece 目的地片区
    ,t1.dst_store 目的地网点
    ,if(td.de_num = 3, 1, 0) 尝试派送次数3
    ,if(td.de_num = 4, 1, 0) 尝试派送次数4
    ,if(td.de_num = 5, 1, 0) 尝试派送次数5
    ,if(td.de_num = 6, 1, 0) 尝试派送次数6
    ,if(td.de_num = 7, 1, 0) 尝试派送次数7
    ,if(td.de_num >= 8, 1, 0) 尝试派送次数8以上
    ,t1.dst_phone 收件人电话
    ,t1.dst_home_phone 收件人家庭电话
from t t1
left join
    (
        select
            td.pno
            ,count(distinct date(convert_tz(tdm.created_at ,'+00:00', '+08:00'))) de_num
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1
    ) td on td.pno = t1.pno
where
    td.de_num >= 3;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,sdt.pending_handle_category
from ph_staging.diff_info di
left join ph_staging.store_diff_ticket sdt on sdt.diff_info_id = di.id
where
    di.pno = 'P16011S133GAF';
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
from tmpale.tmp_ph_pno_0624 t
left join ph_staging.parcel_info pi on pi.pno = t.pno
where
    pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
from tmpale.tmp_ph_pno_0625 t
left join ph_staging.parcel_info pi on pi.pno = t.pno
where
    pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,pi.dst_phone 收件人电话
    ,pi.dst_home_phone 收件人家庭电话
from tmpale.tmp_ph_pno_0625 t
left join ph_staging.parcel_info pi on pi.pno = t.pno
where
    pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.cod_enabled
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-05-31 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,de.src_store 揽收网点
    ,de.pickup_time 揽收时间
    ,de.pick_date 揽收日期
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
    ,if(pr3.pno is not null, 'yes', 'no') 是否有待退件标记
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
left join
    (
        select
            pr2.pno
        from  ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'PENDING_RETURN'
        group by 1
    ) pr3 on pr3.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,pi.dst_phone 收件人电话
    ,pi.dst_home_phone 收件人家庭电话
from tmpale.tmp_ph_pno_0626 t
left join ph_staging.parcel_info pi on pi.pno = t.pno
where
    pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    case  a.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,a.类型
    ,a.疑难件创建时间段
    ,a.处理时间
    ,a.单量
    ,b.avg_deal_h 平均处理时长_hour
from
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 1 then '1小时内'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 >= 1 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 2 then '1-2小时'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 2 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 24 then '2小时-1天'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 24 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 72 then '1-3天'
                else  '3天以上'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
        group by 1,2,3,4

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.negotiation_result_category is not null  and cdt.updated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.updated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 16:00:00') then '超时12小时以内'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 16:00:00') and cdt.updated_at < concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  1 day), ' 16:00:00') then '超时12-36小时内'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  1 day), ' 16:00:00') and cdt.updated_at < concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  2 day), ' 04:00:00') then '超时36-48小时'
#                 when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
            ,convert_tz(di.created_at, '+00:00', '+08:00') 创建时间
            ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00') 第一次处理时间
#             ,count(di.id) 单量
            ,di.id
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
        group by 1,2,3
    ) a
left join
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
            and cdt.first_operated_at is not null
        group by 1,2

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
            and cdt.first_operated_at is not null
        group by 1,2

    ) b on a.diff_marker_category = b.diff_marker_category and a.疑难件创建时间段 = b.疑难件创建时间段 and a.类型 = b.类型;
;-- -. . -..- - / . -. - .-. -.--
select
    case  a.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,a.类型
    ,a.疑难件创建时间段
    ,a.处理时间
    ,a.单量
    ,b.avg_deal_h 平均处理时长_hour
from
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 1 then '1小时内'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 >= 1 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 2 then '1-2小时'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 2 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 24 then '2小时-1天'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 24 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 72 then '1-3天'
                else  '3天以上'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
        group by 1,2,3,4

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.negotiation_result_category is not null  and cdt.updated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.updated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 16:00:00') then '超时12小时以内'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 16:00:00') and cdt.updated_at < concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  1 day), ' 16:00:00') then '超时12-36小时内'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  1 day), ' 16:00:00') and cdt.updated_at < concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  2 day), ' 04:00:00') then '超时36-48小时'
#                 when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
#             ,convert_tz(di.created_at, '+00:00', '+08:00') 创建时间
#             ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00') 第一次处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
        group by 1,2,3,4
    ) a
left join
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
            and cdt.first_operated_at is not null
        group by 1,2

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.first_operated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
            and cdt.first_operated_at is not null
        group by 1,2

    ) b on a.diff_marker_category = b.diff_marker_category and a.疑难件创建时间段 = b.疑难件创建时间段 and a.类型 = b.类型;
;-- -. . -..- - / . -. - .-. -.--
select
    case  a.diff_marker_category
        when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '客户提供的清单里没有此包裹'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '客户取消寄件/客户实际不想寄此包裹'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收(已停用)'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
         when 118 then 'SHOPEE订单系统自动关闭'
         when 119 then '客户取消包裹'
         when 121 then '地址错误'
         when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,a.类型
    ,a.疑难件创建时间段
    ,a.处理时间
    ,a.单量
    ,b.avg_deal_h 平均处理时长_hour
from
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 1 then '1小时内'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 >= 1 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 2 then '1-2小时'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 2 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 24 then '2小时-1天'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 24 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 72 then '1-3天'
                else  '3天以上'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
        group by 1,2,3,4

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.negotiation_result_category is not null  and cdt.updated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.updated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 16:00:00') then '超时12小时以内'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 16:00:00') and cdt.updated_at < concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  1 day), ' 16:00:00') then '超时12-36小时内'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  1 day), ' 16:00:00') and cdt.updated_at < concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  2 day), ' 04:00:00') then '超时36-48小时'
#                 when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
#             ,convert_tz(di.created_at, '+00:00', '+08:00') 创建时间
#             ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00') 第一次处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
        group by 1,2,3,4
    ) a
left join
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.updated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
            and cdt.negotiation_result_category is not null
        group by 1,2

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.updated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
            and cdt.negotiation_result_category is not null
        group by 1,2

    ) b on a.diff_marker_category = b.diff_marker_category and a.疑难件创建时间段 = b.疑难件创建时间段 and a.类型 = b.类型;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.cod_enabled
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-06-07 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
    ,case
        when t1.state = 6 and di.pno is not null then di.sh_do
        when t1.state = 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is not null then plt.should_do
        when t1.state != 6 and plt.pno is null and pct.pno is not null then 'qaqc-TeamB'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then pr.store_name
        else de.last_store_name
    end 待处理节点
    ,case
        when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
        when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
        when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
        when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
        when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
        when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
        when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
        else null
    end 卡点原因
    ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,de.src_store 揽收网点
    ,de.pickup_time 揽收时间
    ,de.pick_date 揽收日期
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
    ,if(pr3.pno is not null, 'yes', 'no') 是否有待退件标记
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
left join
    (
        select
            pr2.pno
        from  ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'PENDING_RETURN'
        group by 1
    ) pr3 on pr3.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    a.CN_element
    ,count(if(a.rk1 = 1 and a.state = 5, a.pno, null )) 第一次协商为继续派送后妥投
    ,count(if(a.rk1 = 2 and a.state = 5, a.pno, null )) 第二次协商为继续派送后妥投
    ,count(if(a.rk1 = 3 and a.state = 5, a.pno, null )) 第三次协商为继续派送后妥投
    ,count(a.state != 5, a.pno, null)  '进入问题件，协商为继续派送，最终未妥投'
from
    (

        select
            a.pno
            ,a.CN_element
            ,b.rk1
            ,a.state
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            di.pno
                            ,ddd.CN_element
                            ,pi.state
                            ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                        from ph_staging.diff_info di
                        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
                        left join ph_staging.parcel_info pi on di.pno = pi.pno
                        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
                        where
                            di.created_at >= '2023-05-31 16:00:00'
                            and di.created_at < '2023-06-19 16:00:00'
                            and bc.client_id is null  -- ka&小c
                            and cdt.negotiation_result_category in (5,6)
                    ) a1
            ) a
        left join
            (
                select
                    di.pno
                    ,row_number() over (partition by di.pno order by cdt.updated_at) rk1
                    ,row_number() over (partition by di.pno order by cdt.updated_at desc) rk2
                from ph_staging.diff_info di
                left join ph_staging.parcel_info pi on di.pno = pi.pno
                left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
                where
                    di.created_at >= '2023-05-31 16:00:00'
                    and di.created_at < '2023-06-19 16:00:00'
                    and bc.client_id is null  -- ka&小c
                    and cdt.negotiation_result_category in (5,6)
            ) b on b.pno = a.pno and b.rk2 = 1
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.CN_element
    ,count(if(a.rk1 = 1 and a.state = 5, a.pno, null )) 第一次协商为继续派送后妥投
    ,count(if(a.rk1 = 2 and a.state = 5, a.pno, null )) 第二次协商为继续派送后妥投
    ,count(if(a.rk1 = 3 and a.state = 5, a.pno, null )) 第三次协商为继续派送后妥投
    ,count(a.state != 5, a.pno, null)  '进入问题件，协商为继续派送，最终未妥投'
from
    (

        select
            a.pno
            ,a.CN_element
            ,b.rk1
            ,a.state
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            di.pno
                            ,ddd.CN_element
                            ,pi.state
                            ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                        from ph_staging.diff_info di
                        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
                        left join ph_staging.parcel_info pi on di.pno = pi.pno
                        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
                        where
                            di.created_at >= '2023-05-31 16:00:00'
                            and di.created_at < '2023-06-19 16:00:00'
                            and bc.client_id is null  -- ka&小c
                            and cdt.negotiation_result_category in (5,6)
                    ) a1
                where
                    a1.rk = 1
            ) a
        left join
            (
                select
                    di.pno
                    ,row_number() over (partition by di.pno order by cdt.updated_at) rk1
                    ,row_number() over (partition by di.pno order by cdt.updated_at desc) rk2
                from ph_staging.diff_info di
                left join ph_staging.parcel_info pi on di.pno = pi.pno
                left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
                where
                    di.created_at >= '2023-05-31 16:00:00'
                    and di.created_at < '2023-06-19 16:00:00'
                    and bc.client_id is null  -- ka&小c
                    and cdt.negotiation_result_category in (5,6)
            ) b on b.pno = a.pno and b.rk2 = 1
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
            a.pno
            ,a.CN_element
            ,b.rk1
            ,a.state
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            di.pno
                            ,ddd.CN_element
                            ,pi.state
                            ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                        from ph_staging.diff_info di
                        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
                        left join ph_staging.parcel_info pi on di.pno = pi.pno
                        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
                        where
                            di.created_at >= '2023-05-31 16:00:00'
                            and di.created_at < '2023-06-19 16:00:00'
                            and bc.client_id is null  -- ka&小c
                            and cdt.negotiation_result_category in (5,6)
                    ) a1
                where
                    a1.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
                    a1.*
                from
                    (
                        select
                            di.pno
                            ,ddd.CN_element
                            ,pi.state
                            ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                        from ph_staging.diff_info di
                        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
                        left join ph_staging.parcel_info pi on di.pno = pi.pno
                        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
                        where
                            di.created_at >= '2023-05-31 16:00:00'
                            and di.created_at < '2023-06-19 16:00:00'
                            and bc.client_id is null  -- ka&小c
                            and cdt.negotiation_result_category in (5,6)
                    ) a1
                where
                    a1.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.CN_element
    ,count(if(a.rk1 = 1 and a.state = 5, a.pno, null )) 第一次协商为继续派送后妥投
    ,count(if(a.rk1 = 2 and a.state = 5, a.pno, null )) 第二次协商为继续派送后妥投
    ,count(if(a.rk1 = 3 and a.state = 5, a.pno, null )) 第三次协商为继续派送后妥投
    ,count(if(a.state != 5, a.pno, null))  '进入问题件，协商为继续派送，最终未妥投'
from
    (

        select
            a.pno
            ,a.CN_element
            ,b.rk1
            ,a.state
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            di.pno
                            ,ddd.CN_element
                            ,pi.state
                            ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                        from ph_staging.diff_info di
                        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
                        left join ph_staging.parcel_info pi on di.pno = pi.pno
                        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
                        where
                            di.created_at >= '2023-05-31 16:00:00'
                            and di.created_at < '2023-06-19 16:00:00'
                            and bc.client_id is null  -- ka&小c
                            and cdt.negotiation_result_category in (5,6)
                    ) a1
                where
                    a1.rk = 1
            ) a
        left join
            (
                select
                    di.pno
                    ,row_number() over (partition by di.pno order by cdt.updated_at) rk1
                    ,row_number() over (partition by di.pno order by cdt.updated_at desc) rk2
                from ph_staging.diff_info di
                left join ph_staging.parcel_info pi on di.pno = pi.pno
                left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
                where
                    di.created_at >= '2023-05-31 16:00:00'
                    and di.created_at < '2023-06-19 16:00:00'
                    and bc.client_id is null  -- ka&小c
                    and cdt.negotiation_result_category in (5,6)
            ) b on b.pno = a.pno and b.rk2 = 1
    ) a
group by 1;