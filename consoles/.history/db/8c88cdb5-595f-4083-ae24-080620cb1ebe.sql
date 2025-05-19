select
    date(acc.created_at) p_date
    ,date (convert_tz(pi.finished_at, '+00:00', '+07:00')) f_date
    ,count(distinct acc.pno) p_cnt
from bi_pro.abnormal_customer_complaint acc
left join fle_staging.parcel_info pi on pi.pno = acc.pno
left join fle_staging.sys_store ss on ss.id = acc.store_id
where
    acc.complaints_type = 1
    and ss.manage_region = 45 -- A16
    and acc.created_at > '2024-05-04'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
    ,plt.id
    ,plr.staff_id
    ,plr.store_id
from bi_pro.parcel_lose_task plt
left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
where
    plt.pno = 'TH0116696RY32A0'
    and plt.penalties > 0;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from bi_pro.parcel_lose_responsible plr
where
    plr.lose_task_id = 91817581;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
    ,plt.id
    ,plr.staff_id
    ,plr.store_id
from bi_pro.parcel_lose_task plt
left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
where
    plt.pno = 'FLACB02018665737'
    and plt.penalties > 0;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.id
    ,ss.name
    ,ss.short_name
from fle_staging.sys_store ss
where
    ss.short_name in ('KKW','LMS','MAK','PPR','WMI','WSD','CHT','KIG','KWA','KGP','BDC','2PAW','2CHT','2TIM','7KUG');
;-- -. . -..- - / . -. - .-. -.--
select
    ss.id
    ,ss.name
    ,ss.short_name
from fle_staging.sys_store ss
where
    ss.short_name in ('CT1','PTD','EA1','EA2');
;-- -. . -..- - / . -. - .-. -.--
select
    ss.id
    ,ss.name
    ,ss.short_name
from fle_staging.sys_store ss
where
    ss.short_name in ('CT1','PDT','EA1','EA2');
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+07:00')) as 揽件日期
    ,count(distinct if(ss.short_name = 'KKW', pi.pno, null)) as KKW揽收量
    ,count(distinct if(ss.short_name = 'LMS', pi.pno, null)) as LMS揽收量
    ,count(distinct if(ss.short_name = 'MAK', pi.pno, null)) as MAK揽收量
    ,count(distinct if(ss.short_name = 'PPR', pi.pno, null)) as PPR揽收量
    ,count(distinct if(ss.short_name = 'WMI', pi.pno, null)) as WMI揽收量
    ,count(distinct if(ss.short_name = 'WSD', pi.pno, null)) as WSD揽收量
    ,count(distinct if(ss.short_name = 'CHT', pi.pno, null)) as CHT揽收量
    ,count(distinct if(ss.short_name = 'KIG', pi.pno, null)) as KIG揽收量
    ,count(distinct if(ss.short_name = 'KWA', pi.pno, null)) as KWA揽收量
    ,count(distinct if(ss.short_name = 'KGP', pi.pno, null)) as KGP揽收量
    ,count(distinct if(ss.short_name = '2PAW', pi.pno, null)) as 2PAW揽收量
    ,count(distinct if(ss.short_name = '2CHT', pi.pno, null)) as 2CHT揽收量
    ,count(distinct if(ss.short_name = '2TIM', pi.pno, null)) as 2TIM揽收量
    ,count(distinct if(ss.short_name = '7KUG', pi.pno, null)) as 7KUG揽收量
    ,count(distinct pi.pno) as 合计揽收量
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pi.dst_store_id
where
    ss.short_name in ('KKW','LMS','MAK','PPR','WMI','WSD','CHT','KIG','KWA','KGP','2PAW','2CHT','2TIM','7KUG')
    and dt.par_par_store_id in ('TH05110400', 'TH20050103', 'TH02030119', 'TH21011305')
    and pi.returned = 0
    and pi.state < 9
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+07:00')) as 揽件日期
    ,count(distinct if(ss.short_name = 'KKW', pi.pno, null)) as KKW揽收量
    ,count(distinct if(ss.short_name = 'LMS', pi.pno, null)) as LMS揽收量
    ,count(distinct if(ss.short_name = 'MAK', pi.pno, null)) as MAK揽收量
    ,count(distinct if(ss.short_name = 'PPR', pi.pno, null)) as PPR揽收量
    ,count(distinct if(ss.short_name = 'WMI', pi.pno, null)) as WMI揽收量
    ,count(distinct if(ss.short_name = 'WSD', pi.pno, null)) as WSD揽收量
    ,count(distinct if(ss.short_name = 'CHT', pi.pno, null)) as CHT揽收量
    ,count(distinct if(ss.short_name = 'KIG', pi.pno, null)) as KIG揽收量
    ,count(distinct if(ss.short_name = 'KWA', pi.pno, null)) as KWA揽收量
    ,count(distinct if(ss.short_name = 'KGP', pi.pno, null)) as KGP揽收量
    ,count(distinct if(ss.short_name = '2PAW', pi.pno, null)) as 2PAW揽收量
    ,count(distinct if(ss.short_name = '2CHT', pi.pno, null)) as 2CHT揽收量
    ,count(distinct if(ss.short_name = '2TIM', pi.pno, null)) as 2TIM揽收量
    ,count(distinct if(ss.short_name = '7KUG', pi.pno, null)) as 7KUG揽收量
    ,count(distinct pi.pno) as 合计揽收量
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pi.dst_store_id
where
    ss.short_name in ('KKW','LMS','MAK','PPR','WMI','WSD','CHT','KIG','KWA','KGP','2PAW','2CHT','2TIM','7KUG')
    and dt.par_par_store_id in ('TH05110400', 'TH20050103', 'TH02030119', 'TH21011305')
    and pi.returned = 0
    and pi.state < 9
    and pi.created_at >= '2025-04-30 17:00:00'
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+07:00')) as 揽件日期
    ,count(distinct if(ss.short_name = 'KKW', pi.pno, null)) as KKW揽收量
    ,count(distinct if(ss.short_name = 'LMS', pi.pno, null)) as LMS揽收量
    ,count(distinct if(ss.short_name = 'MAK', pi.pno, null)) as MAK揽收量
    ,count(distinct if(ss.short_name = 'PPR', pi.pno, null)) as PPR揽收量
    ,count(distinct if(ss.short_name = 'WMI', pi.pno, null)) as WMI揽收量
    ,count(distinct if(ss.short_name = 'WSD', pi.pno, null)) as WSD揽收量
    ,count(distinct if(ss.short_name = 'CHT', pi.pno, null)) as CHT揽收量
    ,count(distinct if(ss.short_name = 'KIG', pi.pno, null)) as KIG揽收量
    ,count(distinct if(ss.short_name = 'KWA', pi.pno, null)) as KWA揽收量
    ,count(distinct if(ss.short_name = 'KGP', pi.pno, null)) as KGP揽收量
    ,count(distinct if(ss.short_name = '2PAW', pi.pno, null)) as 2PAW揽收量
    ,count(distinct if(ss.short_name = '2CHT', pi.pno, null)) as 2CHT揽收量
    ,count(distinct if(ss.short_name = '2TIM', pi.pno, null)) as 2TIM揽收量
    ,count(distinct if(ss.short_name = '7KUG', pi.pno, null)) as 7KUG揽收量
    ,count(distinct pi.pno) as 合计揽收量
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pi.dst_store_id
where
    ss.short_name in ('KKW','LMS','MAK','PPR','WMI','WSD','CHT','KIG','KWA','KGP','2PAW','2CHT','2TIM','7KUG')
    and dt.par_par_store_id in ('TH05110400', 'TH20050103', 'TH02030119', 'TH21011305')
    and pi.returned = 0
    and pi.state < 9
    and pi.article_category = 11
    and pi.created_at >= '2025-04-30 17:00:00'
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+07:00')) as 揽件日期
    ,count(distinct if(ss.short_name = 'KKW', pi.pno, null)) as KKW揽收量
    ,count(distinct if(ss.short_name = 'LMS', pi.pno, null)) as LMS揽收量
    ,count(distinct if(ss.short_name = 'MAK', pi.pno, null)) as MAK揽收量
    ,count(distinct if(ss.short_name = 'PPR', pi.pno, null)) as PPR揽收量
    ,count(distinct if(ss.short_name = 'WMI', pi.pno, null)) as WMI揽收量
    ,count(distinct if(ss.short_name = 'WSD', pi.pno, null)) as WSD揽收量
    ,count(distinct if(ss.short_name = 'CHT', pi.pno, null)) as CHT揽收量
    ,count(distinct if(ss.short_name = 'KIG', pi.pno, null)) as KIG揽收量
    ,count(distinct if(ss.short_name = 'KWA', pi.pno, null)) as KWA揽收量
    ,count(distinct if(ss.short_name = 'KGP', pi.pno, null)) as KGP揽收量
    ,count(distinct if(ss.short_name = '2PAW', pi.pno, null)) as 2PAW揽收量
    ,count(distinct if(ss.short_name = '2CHT', pi.pno, null)) as 2CHT揽收量
    ,count(distinct if(ss.short_name = '2TIM', pi.pno, null)) as 2TIM揽收量
    ,count(distinct if(ss.short_name = '7KUG', pi.pno, null)) as 7KUG揽收量
    ,count(distinct if(pi.dst_store_id = 'TH05110400', pi.pno, null)) as 目的HUB_CT1量
    ,count(distinct if(pi.dst_store_id = 'TH20050103', pi.pno, null)) as 目的HUB_EA1量
    ,count(distinct if(pi.dst_store_id = 'TH02030119', pi.pno, null)) as 目的HUB_PDT量
    ,count(distinct if(pi.dst_store_id = 'TH21011305', pi.pno, null)) as 目的HUB_EA2量
    ,count(distinct pi.pno) as 合计揽收量
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pi.dst_store_id
where
    ss.short_name in ('KKW','LMS','MAK','PPR','WMI','WSD','CHT','KIG','KWA','KGP','2PAW','2CHT','2TIM','7KUG')
    and dt.par_par_store_id in ('TH05110400', 'TH20050103', 'TH02030119', 'TH21011305')
    and pi.returned = 0
    and pi.state < 9
    and pi.article_category = 11
    and pi.created_at >= '2025-04-30 17:00:00'
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+07:00')) as 揽件日期
    ,count(distinct if(ss.short_name = 'KKW', pi.pno, null)) as KKW揽收量
    ,count(distinct if(ss.short_name = 'LMS', pi.pno, null)) as LMS揽收量
    ,count(distinct if(ss.short_name = 'MAK', pi.pno, null)) as MAK揽收量
    ,count(distinct if(ss.short_name = 'PPR', pi.pno, null)) as PPR揽收量
    ,count(distinct if(ss.short_name = 'WMI', pi.pno, null)) as WMI揽收量
    ,count(distinct if(ss.short_name = 'WSD', pi.pno, null)) as WSD揽收量
    ,count(distinct if(ss.short_name = 'CHT', pi.pno, null)) as CHT揽收量
    ,count(distinct if(ss.short_name = 'KIG', pi.pno, null)) as KIG揽收量
    ,count(distinct if(ss.short_name = 'KWA', pi.pno, null)) as KWA揽收量
    ,count(distinct if(ss.short_name = 'KGP', pi.pno, null)) as KGP揽收量
    ,count(distinct if(ss.short_name = '2PAW', pi.pno, null)) as 2PAW揽收量
    ,count(distinct if(ss.short_name = '2CHT', pi.pno, null)) as 2CHT揽收量
    ,count(distinct if(ss.short_name = '2TIM', pi.pno, null)) as 2TIM揽收量
    ,count(distinct if(ss.short_name = '7KUG', pi.pno, null)) as 7KUG揽收量
    ,count(distinct if(pi.par_par_store_id = 'TH05110400', pi.pno, null)) as 目的HUB_CT1量
    ,count(distinct if(pi.par_par_store_id = 'TH20050103', pi.pno, null)) as 目的HUB_EA1量
    ,count(distinct if(pi.par_par_store_id = 'TH02030119', pi.pno, null)) as 目的HUB_PDT量
    ,count(distinct if(pi.par_par_store_id = 'TH21011305', pi.pno, null)) as 目的HUB_EA2量
    ,count(distinct pi.pno) as 合计揽收量
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pi.dst_store_id
where
    ss.short_name in ('KKW','LMS','MAK','PPR','WMI','WSD','CHT','KIG','KWA','KGP','2PAW','2CHT','2TIM','7KUG')
    and dt.par_par_store_id in ('TH05110400', 'TH20050103', 'TH02030119', 'TH21011305')
    and pi.returned = 0
    and pi.state < 9
    and pi.article_category = 11
    and pi.created_at >= '2025-04-30 17:00:00'
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+07:00')) as 揽件日期
    ,count(distinct if(ss.short_name = 'KKW', pi.pno, null)) as KKW揽收量
    ,count(distinct if(ss.short_name = 'LMS', pi.pno, null)) as LMS揽收量
    ,count(distinct if(ss.short_name = 'MAK', pi.pno, null)) as MAK揽收量
    ,count(distinct if(ss.short_name = 'PPR', pi.pno, null)) as PPR揽收量
    ,count(distinct if(ss.short_name = 'WMI', pi.pno, null)) as WMI揽收量
    ,count(distinct if(ss.short_name = 'WSD', pi.pno, null)) as WSD揽收量
    ,count(distinct if(ss.short_name = 'CHT', pi.pno, null)) as CHT揽收量
    ,count(distinct if(ss.short_name = 'KIG', pi.pno, null)) as KIG揽收量
    ,count(distinct if(ss.short_name = 'KWA', pi.pno, null)) as KWA揽收量
    ,count(distinct if(ss.short_name = 'KGP', pi.pno, null)) as KGP揽收量
    ,count(distinct if(ss.short_name = '2PAW', pi.pno, null)) as 2PAW揽收量
    ,count(distinct if(ss.short_name = '2CHT', pi.pno, null)) as 2CHT揽收量
    ,count(distinct if(ss.short_name = '2TIM', pi.pno, null)) as 2TIM揽收量
    ,count(distinct if(ss.short_name = '7KUG', pi.pno, null)) as 7KUG揽收量
    ,count(distinct if(dt.par_par_store_id = 'TH05110400', pi.pno, null)) as 目的HUB_CT1量
    ,count(distinct if(dt.par_par_store_id = 'TH20050103', pi.pno, null)) as 目的HUB_EA1量
    ,count(distinct if(dt.par_par_store_id = 'TH02030119', pi.pno, null)) as 目的HUB_PDT量
    ,count(distinct if(dt.par_par_store_id = 'TH21011305', pi.pno, null)) as 目的HUB_EA2量
    ,count(distinct pi.pno) as 合计揽收量
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pi.dst_store_id
where
    ss.short_name in ('KKW','LMS','MAK','PPR','WMI','WSD','CHT','KIG','KWA','KGP','2PAW','2CHT','2TIM','7KUG')
    and dt.par_par_store_id in ('TH05110400', 'TH20050103', 'TH02030119', 'TH21011305')
    and pi.returned = 0
    and pi.state < 9
    and pi.article_category = 11
    and pi.created_at >= '2025-04-30 17:00:00'
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.id
    ,substring_index(ss.ancestry, '/', 1) ss_ancestry
from fle_staging.sys_store ss
where
    id = 'TH25030402';
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+07:00')) as 揽件日期
    ,count(distinct if(ss.short_name = 'KKW', pi.pno, null)) as KKW揽收量
    ,count(distinct if(ss.short_name = 'LMS', pi.pno, null)) as LMS揽收量
    ,count(distinct if(ss.short_name = 'MAK', pi.pno, null)) as MAK揽收量
    ,count(distinct if(ss.short_name = 'PPR', pi.pno, null)) as PPR揽收量
    ,count(distinct if(ss.short_name = 'WMI', pi.pno, null)) as WMI揽收量
    ,count(distinct if(ss.short_name = 'WSD', pi.pno, null)) as WSD揽收量
    ,count(distinct if(ss.short_name = 'CHT', pi.pno, null)) as CHT揽收量
    ,count(distinct if(ss.short_name = 'KIG', pi.pno, null)) as KIG揽收量
    ,count(distinct if(ss.short_name = 'KWA', pi.pno, null)) as KWA揽收量
    ,count(distinct if(ss.short_name = 'KGP', pi.pno, null)) as KGP揽收量
    ,count(distinct if(ss.short_name = '2PAW', pi.pno, null)) as 2PAW揽收量
    ,count(distinct if(ss.short_name = '2CHT', pi.pno, null)) as 2CHT揽收量
    ,count(distinct if(ss.short_name = '2TIM', pi.pno, null)) as 2TIM揽收量
    ,count(distinct if(ss.short_name = '7KUG', pi.pno, null)) as 7KUG揽收量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH05110400', pi.pno, null)) as 目的HUB_CT1量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH20050103', pi.pno, null)) as 目的HUB_EA1量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH02030119', pi.pno, null)) as 目的HUB_PDT量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH21011305', pi.pno, null)) as 目的HUB_EA2量
    ,count(distinct pi.pno) as 合计揽收量
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store dt on dt.id = pi.dst_store_id
where
    ss.short_name in ('KKW','LMS','MAK','PPR','WMI','WSD','CHT','KIG','KWA','KGP','2PAW','2CHT','2TIM','7KUG')
    and substring_index(dt.ancestry, '/', 1) in ('TH05110400', 'TH20050103', 'TH02030119', 'TH21011305')
    and pi.returned = 0
    and pi.state < 9
    and pi.article_category = 11
    and pi.created_at >= '2025-04-30 17:00:00'
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pss.pno
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
    ,pss.store_name 网点名称
    ,case pss.store_category
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
    ,pss.valid_store_order 包裹到达网点排序
    ,convert_tz(pss.van_arrived_at, '+00:00', '+07:00') 车辆到达网点时间
    ,convert_tz(pss.first_valid_routed_at, '+00:00', '+07:00') as 包裹到达网点时间
    ,convert_tz(pss.van_left_at, '+00:00', '+07:00') as 车辆离开网点时间
from dw_dmd.parcel_store_stage_new pss
join fle_staging.parcel_info pi on pi.pno = pss.pno
where
    pss.valid_store_order is not null
    and pi.created_at > date_sub(date_sub(curdate(), interval 2 month), interval 7 hour);
;-- -. . -..- - / . -. - .-. -.--
select
    pss.pno
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
    ,pss.store_name 网点名称
    ,case pss.store_category
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
    ,pss.valid_store_order 包裹到达网点排序
    ,convert_tz(pss.van_arrived_at, '+00:00', '+07:00') 车辆到达网点时间
    ,convert_tz(pss.first_valid_routed_at, '+00:00', '+07:00') as 包裹到达网点时间
    ,convert_tz(pss.van_left_at, '+00:00', '+07:00') as 车辆离开网点时间
from dw_dmd.parcel_store_stage_new pss
join fle_staging.parcel_info pi on pi.pno = pss.pno
where
    pss.valid_store_order is not null
    and pi.created_at > date_sub(date_sub(curdate(), interval 7 day ), interval 7 hour);
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+07:00')) as 揽件日期
    ,count(distinct if(ss.short_name = 'KKW', pi.pno, null)) as KKW揽收量
    ,count(distinct if(ss.short_name = 'LMS', pi.pno, null)) as LMS揽收量
    ,count(distinct if(ss.short_name = 'MAK', pi.pno, null)) as MAK揽收量
    ,count(distinct if(ss.short_name = 'PPR', pi.pno, null)) as PPR揽收量
    ,count(distinct if(ss.short_name = 'WMI', pi.pno, null)) as WMI揽收量
    ,count(distinct if(ss.short_name = 'WSD', pi.pno, null)) as WSD揽收量
    ,count(distinct if(ss.short_name = 'CHT', pi.pno, null)) as CHT揽收量
    ,count(distinct if(ss.short_name = 'KIG', pi.pno, null)) as KIG揽收量
    ,count(distinct if(ss.short_name = 'KWA', pi.pno, null)) as KWA揽收量
    ,count(distinct if(ss.short_name = 'KGP', pi.pno, null)) as KGP揽收量
    ,count(distinct if(ss.short_name = '2PAW', pi.pno, null)) as 2PAW揽收量
    ,count(distinct if(ss.short_name = '2CHT', pi.pno, null)) as 2CHT揽收量
    ,count(distinct if(ss.short_name = '2TIM', pi.pno, null)) as 2TIM揽收量
    ,count(distinct if(ss.short_name = '7KUG', pi.pno, null)) as 7KUG揽收量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH05110400', pi.pno, null)) as 目的HUB_CT1量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH20050103', pi.pno, null)) as 目的HUB_EA1量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH02030204', pi.pno, null)) as 目的HUB_LAS量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH21011305', pi.pno, null)) as 目的HUB_EA2量
    ,count(distinct pi.pno) as 合计揽收量
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store dt on dt.id = pi.dst_store_id
where
    ss.short_name in ('KKW','LMS','MAK','PPR','WMI','WSD','CHT','KIG','KWA','KGP','2PAW','2CHT','2TIM','7KUG')
    and substring_index(dt.ancestry, '/', 1) in ('TH05110400', 'TH20050103', 'TH02030204', 'TH21011305')
    and pi.returned = 0
    and pi.state < 9
    and pi.article_category = 11
    and pi.created_at >= '2025-04-30 17:00:00'
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
            '身份证审核' program_zh
             ,'Identification Audit' program_en
             ,'72H' time_limit
             ,os.date 日期
             ,t1.cnt 当日新增案例
             ,t2.cnt 当日处理案例
             ,t4.total_cnt 时间段内累计处理
             ,t3.cnt 时间段内待处理量
             ,t4.delay_cnt 时间段内超时案例
             ,t4.rate 时效
        from
            (
                select
                    os.date
                from tmpale.ods_th_dim_date os
                where
                    os.date >= '${sdate}'
                  and os.date <= '${edate}'
            ) os
                left join
            (
                select
                    date(convert_tz(car.created_at, '+00:00', '+07:00')) p_date
                     ,count(car.id) cnt
                from fle_staging.customer_approve_record car
                where
                    car.created_at > date_sub('${sdate}', interval 7 hour)
                  and car.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1
            ) t1 on t1.p_date = os.date
                left join
            (
                select
                    date(convert_tz(car.operated_at, '+00:00', '+07:00')) p_date
                     ,count(car.id) cnt
                from fle_staging.customer_approve_record car
                where
                    car.operated_at > date_sub('${sdate}', interval 7 hour)
                  and car.operated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                  and car.state in (1,2)
                group by 1
            ) t2 on t2.p_date = os.date
                cross join
            (
                select
                    count(car.id) cnt
                from fle_staging.customer_approve_record car
                where
                    car.created_at > date_sub('${sdate}', interval 7 hour)
                  and car.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                  and car.state in (0)
            ) t3
                cross join
            (
                select
                    count(if(timestampdiff(minute , car.created_at, car.operated_at)/60 >= 72, car.id, null)) delay_cnt
                     ,count(car.id) total_cnt
                     ,count(if(timestampdiff(minute, car.created_at, car.operated_at) /60 < 72, car.id, null)) / count(car.id) rate
                from fle_staging.customer_approve_record car
                where
                    car.created_at > date_sub('${sdate}', interval 7 hour)
                  and car.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                  and car.state in (1,2)
            ) t4;
;-- -. . -..- - / . -. - .-. -.--
select
            '身份证审核' program_zh
             ,'Identification Audit' program_en
             ,'72H' time_limit
             ,os.date 日期
             ,t1.cnt 当日新增案例
             ,t2.cnt 当日处理案例
             ,t4.total_cnt 时间段内累计处理
             ,t3.cnt 时间段内待处理量
             ,t4.delay_cnt 时间段内超时案例
             ,t4.rate 时效
        from
            (
                select
                    os.date
                from tmpale.ods_th_dim_date os
                where
                    os.date >= '2025-05-08'
                  and os.date <= '2025-05-08'
            ) os
                left join
            (
                select
                    date(convert_tz(car.created_at, '+00:00', '+07:00')) p_date
                     ,count(car.id) cnt
                from fle_staging.customer_approve_record car
                where
                    car.created_at > date_sub('2025-05-08', interval 7 hour)
                  and car.created_at < date_add(date_sub('2025-05-08', interval 7 hour), interval 1 day)
                group by 1
            ) t1 on t1.p_date = os.date
                left join
            (
                select
                    date(convert_tz(car.operated_at, '+00:00', '+07:00')) p_date
                     ,count(car.id) cnt
                from fle_staging.customer_approve_record car
                where
                    car.operated_at > date_sub('2025-05-08', interval 7 hour)
                  and car.operated_at < date_add(date_sub('2025-05-08', interval 7 hour), interval 1 day)
                  and car.state in (1,2)
                group by 1
            ) t2 on t2.p_date = os.date
                cross join
            (
                select
                    count(car.id) cnt
                from fle_staging.customer_approve_record car
                where
                    car.created_at > date_sub('2025-05-08', interval 7 hour)
                  and car.created_at < date_add(date_sub('2025-05-08', interval 7 hour), interval 1 day)
                  and car.state in (0)
            ) t3
                cross join
            (
                select
                    count(if(timestampdiff(minute , car.created_at, car.operated_at)/60 >= 72, car.id, null)) delay_cnt
                     ,count(car.id) total_cnt
                     ,count(if(timestampdiff(minute, car.created_at, car.operated_at) /60 < 72, car.id, null)) / count(car.id) rate
                from fle_staging.customer_approve_record car
                where
                    car.created_at > date_sub('2025-05-08', interval 7 hour)
                  and car.created_at < date_add(date_sub('2025-05-08', interval 7 hour), interval 1 day)
                  and car.state in (1,2)
            ) t4;
;-- -. . -..- - / . -. - .-. -.--
select
    swa.staff_info_id
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',swa.started_path) 上班
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',swa.end_path) 下班
from backyard_pro.staff_work_attendance swa
where
    swa.attendance_date = '2025-04-26'
    and swa.staff_info_id = 715830;
;-- -. . -..- - / . -. - .-. -.--
select
    min(parcel_created_at)
from bi_pro.parcel_claim_task;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,json_extract(a.neg_result,'$.money') claim_value
from
    (
        select
            pct.pno
             ,pcn.neg_result
             ,row_number() over (partition by pct.pno order by pct.created_at desc) rk
        from bi_pro.parcel_claim_task pct
         join tmpale.tmp_th_pno_lj_0509 t on t.pno = pct.pno
         left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.state = 6
    ) a
where
    a.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
            pct.pno
             ,pcn.neg_result
             ,row_number() over (partition by pct.pno order by pct.created_at desc) rk
        from bi_pro.parcel_claim_task pct
         join tmpale.tmp_th_pno_lj_0509 t on t.pno = pct.pno
         left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.state = 6;
;-- -. . -..- - / . -. - .-. -.--
select * from tmpale.tmp_th_pno_lj_0509;
;-- -. . -..- - / . -. - .-. -.--
select
    rr.pno 运单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,case
        when rr.reweight_type in (3,4,5,6) then '量方读数审核'
        when rr.reweight_type in (1) then '称重读数审核'
        when rr.reweight_type in (2) then '单号一致性审核'
    end 复称审核类型
    ,convert_tz(rr.created_at, '+00:00', '+07:00') 进入wrs时间
    ,if(rr.status = 2, convert_tz(rr.input_end, '+00:00', '+07:00'), null) 审核时间
    ,case rr.status
        when 0 then '待分配'
        when 1 then '已分配'
        when 2 then '审核完毕'
    end 审核状态
    ,case rr.reweight_result
        when 0 then '待判责'
        when 1 then '准确'
        when 2 then '不规范'
        when 3 then '虚假'
        when 4 then '待判-不规范'
        when 5 then '待判-虚假'
    end 审核结果
    ,rr.input_by 审核人
    ,case
        when timestampdiff(hour, rr.created_at, rr.input_end) >= 24 then '超时'
        when timestampdiff(hour, rr.created_at, rr.input_end) < 24 then '时效内'
        else null
    end 是否超时
from wrs_production.reweight_record rr
left join fle_staging.parcel_info pi on pi.pno = rr.pno and pi.created_at > date_sub(curdate(), interval 2 month)
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
where
    rr.created_at > date_sub(curdate(), interval 31 hour)
    and rr.created_at < date_sub(curdate(), interval 7 hour);
;-- -. . -..- - / . -. - .-. -.--
select
    rr.input_id 审核员工编号
    ,rr.input_by 审核员工姓名
    ,count(if(rr.reweight_result = 1, rr.id, null)) 准确数量
    ,count(if(rr.reweight_result = 2, rr.id, null)) 不规范数量
    ,count(if(rr.reweight_result = 3, rr.id, null)) 虚假数量
    ,count(if(rr.reweight_result in (1,2,3), rr.id, null)) 合计
    ,count(if(timestampdiff(hour, rr.created_at, rr.input_end) < 24, rr.id, null)) 时效内数量
    ,count(if(timestampdiff(hour, rr.created_at, rr.input_end) >= 24, rr.id, null)) 超时数量
    ,count(if(timestampdiff(hour, rr.created_at, rr.input_end) < 24, rr.id, null)) / count(rr.id) 时效内占比
from wrs_production.reweight_record rr
where
    rr.created_at > date_sub(curdate(), interval 31 hour)
    and rr.created_at < date_sub(curdate(), interval 7 hour)
    and rr.input_id not in ('1000000')
    and rr.status = 2
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select min(created_at)  from wrs_production.reweight_record rr;
;-- -. . -..- - / . -. - .-. -.--
select max(created_at)  from wrs_production.reweight_record rr;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.staff_info_id  快递员工号
    ,case pi.returned
        when 0 then '正向'
        when 1 then '退件'
    end 正向_退件
    ,case pi.cod_enabled
        when 0 then '否'
        when 1 then '是'
    end 是否COD
    ,date (convert_tz(pr.routed_at, '+00:00', '+07:00')) 强制拍照日期
    ,bc.client_name 平台_แพลตฟอร์ม
    ,pi.client_id 客户id_idลูกค้า
    ,dt.store_name 网点_สาขา
    ,dt.region_name 大区_area
    ,dt.piece_name 片区_district
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/' ,json_extract(dp.extra_value , '$.deliveryImageAiScore[0].objectKey')) 照片url
    ,if(json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberConsistency') = 0 or ( json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBill') = 0 and json_extract(dp.extra_value, '$.deliveryImageAiScore[0].billAreaRatio') > 0.1 ), 'y', null) 模型是否定义为合格
    ,if(json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBill') > 0.0 or json_extract(dp.extra_value, '$.deliveryImageAiScore[0].simpleColor') = true or json_extract(dp.extra_value, '$.deliveryImageAiScore[0].lowQuality') > 0.0 or ( json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberAvailability') = 0.0 and json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberConsistency') = 1.0 ), 'N', null) 模型是否定义为虚假
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberAvailability') = 1.0 then '否'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberAvailability') = 0.0 then '是'
    end 是否识别到单号
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberConsistency') = 1.0 then '否'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].waybillNumberConsistency') = 0.0 then '是'
    end 单号是否匹配
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBill') > 0.0 then '否'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBill') = 0.0 then '是'
    end 是否识别到面单
    ,concat(json_extract(dp.extra_value, '$.deliveryImageAiScore[0].billAreaRatio') * 100, '%') 识别到的面单面积占比
    ,concat(json_extract(dp.extra_value, '$.deliveryImageAiScore[0].parcelAreaRatio') * 100, '%') 包裹占照片的百分比
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].simpleColor') = true then '是'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].simpleColor') = false then '否'
    end 是否纯色
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].lowQuality') > 0.0 then '是'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].lowQuality') = 0.0 then '否'
    end  是否图像整体质量低
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].lowQualityBackground') > 0.0 then '是'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].lowQualityBackground') = 0.0 then '否'
    end 是否背景质量低
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBackground') > 0.0 then '是'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].noBackground') = 0.0 then '否'
    end 是否识别为无背景
    ,case
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].screenShot') > 0.0 then '是'
        when json_extract(dp.extra_value, '$.deliveryImageAiScore[0].screenShot') = 0.0 then '否'
    end 是否识别为截图
from rot_pro.parcel_route pr
left join dwm.drds_parcel_route_extra dp on dp.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
left join fle_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left  join dwm.dim_th_sys_store_rd dt on dt.store_id = pr.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action = 'TAKE_PHOTO'
    and pr.routed_at > date_sub(curdate(), interval 31 hour)
    and pr.routed_at < date_sub(curdate(), interval 7 hour)
    and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
    and dp.created_at > date_sub(curdate(), interval 60 hour)
    and pi.created_at > date_sub(curdate(), interval 3 month);
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.store_name
    ,pr.src_name
    ,pr.client_id
from
    (
                select
            pi.*
            ,row_number() over (partition by pi.pno order by pr.routed_at ) rn
            ,pr.store_name
        from
            (
                select
                    pi.pno
                    ,pi.src_name
                    ,pi.client_id
                from fle_staging.parcel_info pi
                where
                    pi.returned = 0
                    and pi.created_at > '2025-05-04 17:00:00'
                    and pi.created_at < '2025-05-14 17:00:00'
                    and pi.article_category = 99
                    and pi.exhibition_weight > 2000
                    and pi.exhibition_weight < 10000
            ) pi
        join
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.routed_at
                from rot_pro.parcel_route pr
                where
                    pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                    and pr.routed_at > '2025-05-04 17:00:00'
                    and pr.store_category in (8,12)
            ) pr on pr.pno = pi.pno
    ) pr
where
    pr.rn = 1
    and pr.store_name = '25 EA2_HUB-ระยอง';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,ddd.CN_element 路由
    ,pr.staff_info_id 操作人
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 路由时间
from
    (
                select
            pr.pno
            ,pr.route_action
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from rot_pro.parcel_route pr
        where
            pr.routed_at > '2025-04-01'
            and pr.store_id = 'TH01480142'
            and  pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.pno in ('TH012877G1AJ0B0','TH6602777KA24B','TH014277CXMP6A0','TH1201779TDE0S','THT41081US65K0Z','TH0143779TDD9B','TH131177FPU70C','TH640877ESVM9G','TH421977FS132A','THT30091US9MQ3Z','TH660377HJ029B','TH190177G0VF1E','TH200477FSUM0B6','TH210577FPU75B','TH013977ESVM8F','TH310177FPU62E','TH2004779T5D9B0','TH470977HU7D7A','TH6805777K5Y9C','TH290177FPU71J','TH3312779TBT7C','TH4801777KA23L','TH301277BGMQ4A','TH2205779SS47D','THT45021UTSJB3Z','TH330177FPU84H','TH470177FPU66L','TH131077E8Z67E','TH270277ESX65A','TH370577ESVN4A','TH430177FPU51O','THT20011UTSKJ1Z','THT13081US66J4Z','TH200477FPU86B6','TH270277G1AH8C','THT06041UV9SX3Z','THT62081UTNFW2Z','TH240577CS5P8J','TH470977C4UN5A','TH680677JK3N8I','TH21067790G66A1','TH2004779T5F6B0','TH2505779T312A','TH1505770R3T5A','THT58021UTSHH3Z','TH730277CXMP7G','TH380277E5GF5G','TH010377DUE19A','TH2007779T317D','TH1506779T313N','THT01261US9NJ5Z','THT75011UTYX20Z','THT22011USHHA3Z','TH5214779SVU0G','THT62051US9KU5Z','TH5403779TBT8A','TH681177FQ5E4F','TH160177G8J23I','TH340377ESRS0A','TH5214779SVU1G','TH273077F78U8C','THT31011US9H05Z','THT29051US9NH9Z','THT61021UU2RH1Z','TH610877HRQF2F','TH681477E91U9E','TH110277BTR27E','TH2004779T5D3B0','THT13081UTNEF4Z','THT01021US9JG1Z','THT42061US9NJ7Z','TH2210779T315D','TH560177GWPQ1F','TH2004779T5F0B0','TH2004779T5F4B0','TH7115779TEZ8A','TH740577J9TU9A','TH230177GQPP2J','THT26041US9NH7Z','THT47141US66U6Z','TH015177905Z1C1','TH04017797R38F','TH2004779T5E6B0','TH300377CXMP0A','TH6805777K0U6C','THT20091US64T8Z','TH3818779SS54C','TH440177FPU64A1','THT15051US9KY5Z','THT71031UT4AE9Z','TH040377HRQD3A2','TH121077E5GF7D','THT65051UTSJF1Z','TH050677E8WN7A','TH200477EGVP8C','TH3011779SS44B','TH630577BGN90G','TH0143777KA21C','TH071177E0HM3B','THT26091US9MP7Z','TH210177GSF53K','THT58011UWKFN4Z','TH1904779T311E','TH2004779T5C1B0','THT29161US9KX9Z','THT30031UU2R45Z')
    ) pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,ddd.CN_element 路由
    ,pr.staff_info_id 操作人
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 路由时间
from
    (
                select
            pr.pno
            ,pr.route_action
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from rot_pro.parcel_route pr
        where
            pr.routed_at > '2025-04-01'
            and pr.store_id = 'TH01480142'
           -- and  pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.pno in ('TH012877G1AJ0B0','TH6602777KA24B','TH014277CXMP6A0','TH1201779TDE0S','THT41081US65K0Z','TH0143779TDD9B','TH131177FPU70C','TH640877ESVM9G','TH421977FS132A','THT30091US9MQ3Z','TH660377HJ029B','TH190177G0VF1E','TH200477FSUM0B6','TH210577FPU75B','TH013977ESVM8F','TH310177FPU62E','TH2004779T5D9B0','TH470977HU7D7A','TH6805777K5Y9C','TH290177FPU71J','TH3312779TBT7C','TH4801777KA23L','TH301277BGMQ4A','TH2205779SS47D','THT45021UTSJB3Z','TH330177FPU84H','TH470177FPU66L','TH131077E8Z67E','TH270277ESX65A','TH370577ESVN4A','TH430177FPU51O','THT20011UTSKJ1Z','THT13081US66J4Z','TH200477FPU86B6','TH270277G1AH8C','THT06041UV9SX3Z','THT62081UTNFW2Z','TH240577CS5P8J','TH470977C4UN5A','TH680677JK3N8I','TH21067790G66A1','TH2004779T5F6B0','TH2505779T312A','TH1505770R3T5A','THT58021UTSHH3Z','TH730277CXMP7G','TH380277E5GF5G','TH010377DUE19A','TH2007779T317D','TH1506779T313N','THT01261US9NJ5Z','THT75011UTYX20Z','THT22011USHHA3Z','TH5214779SVU0G','THT62051US9KU5Z','TH5403779TBT8A','TH681177FQ5E4F','TH160177G8J23I','TH340377ESRS0A','TH5214779SVU1G','TH273077F78U8C','THT31011US9H05Z','THT29051US9NH9Z','THT61021UU2RH1Z','TH610877HRQF2F','TH681477E91U9E','TH110277BTR27E','TH2004779T5D3B0','THT13081UTNEF4Z','THT01021US9JG1Z','THT42061US9NJ7Z','TH2210779T315D','TH560177GWPQ1F','TH2004779T5F0B0','TH2004779T5F4B0','TH7115779TEZ8A','TH740577J9TU9A','TH230177GQPP2J','THT26041US9NH7Z','THT47141US66U6Z','TH015177905Z1C1','TH04017797R38F','TH2004779T5E6B0','TH300377CXMP0A','TH6805777K0U6C','THT20091US64T8Z','TH3818779SS54C','TH440177FPU64A1','THT15051US9KY5Z','THT71031UT4AE9Z','TH040377HRQD3A2','TH121077E5GF7D','THT65051UTSJF1Z','TH050677E8WN7A','TH200477EGVP8C','TH3011779SS44B','TH630577BGN90G','TH0143777KA21C','TH071177E0HM3B','THT26091US9MP7Z','TH210177GSF53K','THT58011UWKFN4Z','TH1904779T311E','TH2004779T5C1B0','THT29161US9KX9Z','THT30031UU2R45Z')
    ) pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action';
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,ddd.CN_element 路由
    ,pr.staff_info_id 操作人
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 路由时间
from
    (
                select
            pr.pno
            ,pr.route_action
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from rot_pro.parcel_route pr
        where
            pr.routed_at > '2025-04-01'
            and pr.store_id = 'TH01480142'
           -- and  pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.pno in ('TH012877G1AJ0B0','TH6602777KA24B','TH014277CXMP6A0','TH1201779TDE0S','THT41081US65K0Z','TH0143779TDD9B','TH131177FPU70C','TH640877ESVM9G','TH421977FS132A','THT30091US9MQ3Z','TH660377HJ029B','TH190177G0VF1E','TH200477FSUM0B6','TH210577FPU75B','TH013977ESVM8F','TH310177FPU62E','TH2004779T5D9B0','TH470977HU7D7A','TH6805777K5Y9C','TH290177FPU71J','TH3312779TBT7C','TH4801777KA23L','TH301277BGMQ4A','TH2205779SS47D','THT45021UTSJB3Z','TH330177FPU84H','TH470177FPU66L','TH131077E8Z67E','TH270277ESX65A','TH370577ESVN4A','TH430177FPU51O','THT20011UTSKJ1Z','THT13081US66J4Z','TH200477FPU86B6','TH270277G1AH8C','THT06041UV9SX3Z','THT62081UTNFW2Z','TH240577CS5P8J','TH470977C4UN5A','TH680677JK3N8I','TH21067790G66A1','TH2004779T5F6B0','TH2505779T312A','TH1505770R3T5A','THT58021UTSHH3Z','TH730277CXMP7G','TH380277E5GF5G','TH010377DUE19A','TH2007779T317D','TH1506779T313N','THT01261US9NJ5Z','THT75011UTYX20Z','THT22011USHHA3Z','TH5214779SVU0G','THT62051US9KU5Z','TH5403779TBT8A','TH681177FQ5E4F','TH160177G8J23I','TH340377ESRS0A','TH5214779SVU1G','TH273077F78U8C','THT31011US9H05Z','THT29051US9NH9Z','THT61021UU2RH1Z','TH610877HRQF2F','TH681477E91U9E','TH110277BTR27E','TH2004779T5D3B0','THT13081UTNEF4Z','THT01021US9JG1Z','THT42061US9NJ7Z','TH2210779T315D','TH560177GWPQ1F','TH2004779T5F0B0','TH2004779T5F4B0','TH7115779TEZ8A','TH740577J9TU9A','TH230177GQPP2J','THT26041US9NH7Z','THT47141US66U6Z','TH015177905Z1C1','TH04017797R38F','TH2004779T5E6B0','TH300377CXMP0A','TH6805777K0U6C','THT20091US64T8Z','TH3818779SS54C','TH440177FPU64A1','THT15051US9KY5Z','THT71031UT4AE9Z','TH040377HRQD3A2','TH121077E5GF7D','THT65051UTSJF1Z','TH050677E8WN7A','TH200477EGVP8C','TH3011779SS44B','TH630577BGN90G','TH0143777KA21C','TH071177E0HM3B','THT26091US9MP7Z','TH210177GSF53K','THT58011UWKFN4Z','TH1904779T311E','TH2004779T5C1B0','THT29161US9KX9Z','THT30031UU2R45Z')
    ) pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    p.pno
    ,p.staff_info_id 5NOG操作人
    ,convert_tz(p.routed_at, '+00:00', '+07:00') 5NOG操作時間
    ,p.cn_element 5NOG操作路由
    ,p.staff_info_id_2 2NKH操作人
    ,p.store_name_2 2NKH
    ,convert_tz(p.routed_at_2, '+00:00', '+07:00') 2NKH操作時間
    ,p.cn_element_2 2NKH操作路由
from
    (

        select
            p1.*
            ,p2.store_name store_name_2
            ,p2.staff_info_id staff_info_id_2
            ,p2.routed_at routed_at_2
            ,ddd2.cn_element cn_element_2
            ,row_number() over (partition by p1.pno order by p2.routed_at ) rn
        from
            (
                select
                    pr.pno
                    ,ddd.CN_element
                    ,pr.staff_info_id
                    ,pr.routed_at
                from
                    (
                        select
                            pr.pno
                            ,pr.route_action
                            ,pr.staff_info_id
                            ,pr.routed_at
                            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
                        from rot_pro.parcel_route pr
                        where
                            pr.routed_at > '2025-04-01'
                            and pr.store_id = 'THA0000651'
                           -- and  pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                            and pr.pno in ('TH012877G1AJ0B0','TH6602777KA24B','TH014277CXMP6A0','TH1201779TDE0S','THT41081US65K0Z','TH0143779TDD9B','TH131177FPU70C','TH640877ESVM9G','TH421977FS132A','THT30091US9MQ3Z','TH660377HJ029B','TH190177G0VF1E','TH200477FSUM0B6','TH210577FPU75B','TH013977ESVM8F','TH310177FPU62E','TH2004779T5D9B0','TH470977HU7D7A','TH6805777K5Y9C','TH290177FPU71J','TH3312779TBT7C','TH4801777KA23L','TH301277BGMQ4A','TH2205779SS47D','THT45021UTSJB3Z','TH330177FPU84H','TH470177FPU66L','TH131077E8Z67E','TH270277ESX65A','TH370577ESVN4A','TH430177FPU51O','THT20011UTSKJ1Z','THT13081US66J4Z','TH200477FPU86B6','TH270277G1AH8C','THT06041UV9SX3Z','THT62081UTNFW2Z','TH240577CS5P8J','TH470977C4UN5A','TH680677JK3N8I','TH21067790G66A1','TH2004779T5F6B0','TH2505779T312A','TH1505770R3T5A','THT58021UTSHH3Z','TH730277CXMP7G','TH380277E5GF5G','TH010377DUE19A','TH2007779T317D','TH1506779T313N','THT01261US9NJ5Z','THT75011UTYX20Z','THT22011USHHA3Z','TH5214779SVU0G','THT62051US9KU5Z','TH5403779TBT8A','TH681177FQ5E4F','TH160177G8J23I','TH340377ESRS0A','TH5214779SVU1G','TH273077F78U8C','THT31011US9H05Z','THT29051US9NH9Z','THT61021UU2RH1Z','TH610877HRQF2F','TH681477E91U9E','TH110277BTR27E','TH2004779T5D3B0','THT13081UTNEF4Z','THT01021US9JG1Z','THT42061US9NJ7Z','TH2210779T315D','TH560177GWPQ1F','TH2004779T5F0B0','TH2004779T5F4B0','TH7115779TEZ8A','TH740577J9TU9A','TH230177GQPP2J','THT26041US9NH7Z','THT47141US66U6Z','TH015177905Z1C1','TH04017797R38F','TH2004779T5E6B0','TH300377CXMP0A','TH6805777K0U6C','THT20091US64T8Z','TH3818779SS54C','TH440177FPU64A1','THT15051US9KY5Z','THT71031UT4AE9Z','TH040377HRQD3A2','TH121077E5GF7D','THT65051UTSJF1Z','TH050677E8WN7A','TH200477EGVP8C','TH3011779SS44B','TH630577BGN90G','TH0143777KA21C','TH071177E0HM3B','THT26091US9MP7Z','TH210177GSF53K','THT58011UWKFN4Z','TH1904779T311E','TH2004779T5C1B0','THT29161US9KX9Z','THT30031UU2R45Z')
                    ) pr
                left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                where
                    pr.rn = 1
            ) p1
        left join
            (
                select
                    pr.pno
                    ,pr.route_action
                    ,pr.routed_at
                    ,pr.store_name
                    ,pr.staff_info_id
                from rot_pro.parcel_route pr
                where
                    pr.routed_at > '2025-05-01'
                    and pr.pno in ('TH012877G1AJ0B0','TH6602777KA24B','TH014277CXMP6A0','TH1201779TDE0S','THT41081US65K0Z','TH0143779TDD9B','TH131177FPU70C','TH640877ESVM9G','TH421977FS132A','THT30091US9MQ3Z','TH660377HJ029B','TH190177G0VF1E','TH200477FSUM0B6','TH210577FPU75B','TH013977ESVM8F','TH310177FPU62E','TH2004779T5D9B0','TH470977HU7D7A','TH6805777K5Y9C','TH290177FPU71J','TH3312779TBT7C','TH4801777KA23L','TH301277BGMQ4A','TH2205779SS47D','THT45021UTSJB3Z','TH330177FPU84H','TH470177FPU66L','TH131077E8Z67E','TH270277ESX65A','TH370577ESVN4A','TH430177FPU51O','THT20011UTSKJ1Z','THT13081US66J4Z','TH200477FPU86B6','TH270277G1AH8C','THT06041UV9SX3Z','THT62081UTNFW2Z','TH240577CS5P8J','TH470977C4UN5A','TH680677JK3N8I','TH21067790G66A1','TH2004779T5F6B0','TH2505779T312A','TH1505770R3T5A','THT58021UTSHH3Z','TH730277CXMP7G','TH380277E5GF5G','TH010377DUE19A','TH2007779T317D','TH1506779T313N','THT01261US9NJ5Z','THT75011UTYX20Z','THT22011USHHA3Z','TH5214779SVU0G','THT62051US9KU5Z','TH5403779TBT8A','TH681177FQ5E4F','TH160177G8J23I','TH340377ESRS0A','TH5214779SVU1G','TH273077F78U8C','THT31011US9H05Z','THT29051US9NH9Z','THT61021UU2RH1Z','TH610877HRQF2F','TH681477E91U9E','TH110277BTR27E','TH2004779T5D3B0','THT13081UTNEF4Z','THT01021US9JG1Z','THT42061US9NJ7Z','TH2210779T315D','TH560177GWPQ1F','TH2004779T5F0B0','TH2004779T5F4B0','TH7115779TEZ8A','TH740577J9TU9A','TH230177GQPP2J','THT26041US9NH7Z','THT47141US66U6Z','TH015177905Z1C1','TH04017797R38F','TH2004779T5E6B0','TH300377CXMP0A','TH6805777K0U6C','THT20091US64T8Z','TH3818779SS54C','TH440177FPU64A1','THT15051US9KY5Z','THT71031UT4AE9Z','TH040377HRQD3A2','TH121077E5GF7D','THT65051UTSJF1Z','TH050677E8WN7A','TH200477EGVP8C','TH3011779SS44B','TH630577BGN90G','TH0143777KA21C','TH071177E0HM3B','THT26091US9MP7Z','TH210177GSF53K','THT58011UWKFN4Z','TH1904779T311E','TH2004779T5C1B0','THT29161US9KX9Z','THT30031UU2R45Z')
                    and pr.store_id = 'THA0000651'
            ) p2 on p2.pno = p1.pno and p2.routed_at > p1.routed_at
        left join dwm.dwd_dim_dict ddd2 on ddd2.element = p2.route_action and ddd2.db = 'rot_pro' and ddd2.tablename = 'parcel_route' and ddd2.fieldname = 'route_action'
    ) p
where
    p.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    swa.staff_info_id
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',swa.started_path) 上班
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',swa.end_path) 下班
from backyard_pro.staff_work_attendance swa
where
    swa.attendance_date = '2025-05-10'
    and swa.staff_info_id = 722807;
;-- -. . -..- - / . -. - .-. -.--
select
    swa.staff_info_id
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',swa.started_path) 上班
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',swa.end_path) 下班
from backyard_pro.staff_work_attendance swa
where
    swa.attendance_date = '2025-05-03'
    and swa.staff_info_id = 681288;
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct plt.pno )
from bi_pro.parcel_lose_task plt
join bi_pro.parcel_lose_responsible plr on plt.id = plr.lose_task_id
join fle_staging.sys_store ss on ss.id = plr.store_id
where
    ss.category = 6
    and plt.parcel_created_at > '2024-01-01'
    and plt.parcel_created_at < '2024-05-15';
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct plt.pno )
from bi_pro.parcel_lose_task plt
join bi_pro.parcel_lose_responsible plr on plt.id = plr.lose_task_id
join fle_staging.sys_store ss on ss.id = plr.store_id
where
    ss.category = 6
    and plt.parcel_created_at > '2024-01-01'
    and plt.parcel_created_at < '2024-05-15'
    and plt.state = 6
    and plt.duty_result = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct plt.pno )
from bi_pro.parcel_lose_task plt
join bi_pro.parcel_lose_responsible plr on plt.id = plr.lose_task_id
join fle_staging.sys_store ss on ss.id = plr.store_id
where
    ss.category = 6
    and plt.parcel_created_at > '2025-01-01'
    and plt.parcel_created_at < '2025-05-15'
    and plt.state = 6
    and plt.duty_result = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
                when ss.category in (1,10,14) then 'NW'
                when ss.category in (4,5,7) then 'SHOP'
                when ss.category in (6) then 'FH'
                when ss.category in (8,12) then 'HUB'
            end ss_category
    ,count(distinct plt.pno )
from bi_pro.parcel_lose_task plt
join bi_pro.parcel_lose_responsible plr on plt.id = plr.lose_task_id
join fle_staging.sys_store ss on ss.id = plr.store_id
where
    ss.category = 6
    and plt.parcel_created_at > '2025-01-01'
    and plt.parcel_created_at < '2025-05-15'
    and plt.state = 6
    and plt.duty_result = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
                when ss.category in (1,10,14) then 'NW'
                when ss.category in (4,5,7) then 'SHOP'
                when ss.category in (6) then 'FH'
                when ss.category in (8,12) then 'HUB'
            end ss_category
    ,count(distinct plt.pno )
from bi_pro.parcel_lose_task plt
join bi_pro.parcel_lose_responsible plr on plt.id = plr.lose_task_id
join fle_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.parcel_created_at > '2025-01-01'
    and plt.parcel_created_at < '2025-05-15'
 --   and ss.category = 6
    and plt.duty_result = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
    ,plt.updated_at
#     case
#                 when ss.category in (1,10,14) then 'NW'
#                 when ss.category in (4,5,7) then 'SHOP'
#                 when ss.category in (6) then 'FH'
#                 when ss.category in (8,12) then 'HUB'
#             end ss_category
#     ,count(distinct plt.pno )
from bi_pro.parcel_lose_task plt
join bi_pro.parcel_lose_responsible plr on plt.id = plr.lose_task_id
join fle_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.parcel_created_at > '2025-01-01'
    and plt.parcel_created_at < '2025-05-15'
    and ss.category in (4,5,7)
    and plt.duty_result = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.distance
    ,pr.'距离'
    ,pr.store_id
    ,pr.name
    ,pr.route_action
    ,pr.routed_at
    ,pr.pno
    ,pr2.route_action
from
    (
        select
            case
                when round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0)<=200 then '网点操作'
                when round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0) is null then '网点操作'
            else '仓外操作'
            end as distance
            ,round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0) '距离'
            ,store_id
            ,ss.name name
            ,pr.route_action
            ,convert_tz(pr.routed_at,'+00:00','+07:00') routed_at
            ,pr.pno
            ,pr.id
        from rot_pro.parcel_route pr
        left join fle_staging.sys_store ss on ss.id = pr.store_id
        where
            ss.lng is not null
            and ss.lat is not null
        #     and convert_tz(pr.created_at,'+00:00','+07:00')>='2025-04-09'
        #     and convert_tz(pr.created_at,'+00:00','+07:00')<'2025-04-10'
            and pr.routed_at >= '2025-05-14 17:00:00'
            and pr.routed_at < '2025-05-15 17:00:00'
            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN','DELIVERY_MARKER','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DIFFICULTY_HANDOVER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED')
            and pr.store_id in ('TH02060149','TH01480142','TH03040255','TH71140100','TH02040114','TH02030145','TH15060836','TH01100108','TH04030108','TH04020410')
            and pr.pno = 'THT55021UYDRB0Z'
  ) pr
left join
    (
        select
            pr.pno
            ,'RECEIVE_WAREHOUSE_SCAN' route_action
        from rot_pro.parcel_route pr
        where
            pr.routed_at >= '2025-05-01 17:00:00'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.pno = 'THT55021UYDRB0Z'
            and pr.store_id in ('TH02060149','TH01480142','TH03040255','TH71140100','TH02040114','TH02030145','TH15060836','TH01100108','TH04030108','TH04020410')
    ) pr2 on pr.pno = pr2.pno and pr.route_action = pr2.route_action;
;-- -. . -..- - / . -. - .-. -.--
select
    count(1)
from bi_pro.parcel_claim_task pct
where
    pct.state in (3,4);
;-- -. . -..- - / . -. - .-. -.--
select *
#     pct.pno
#     ,pct.client_id
#     ,pct.created_at
#     ,
from bi_pro.parcel_claim_task pct
where
    pct.state in (3,4)
    and pct.pno = 'TH471543DFCX9G';
;-- -. . -..- - / . -. - .-. -.--
select
    pct.pno 'Tracking Number'
    ,pct.client_id
    ,pct.created_at 'Task generation time'
    ,case pct.self_claim
        when 1 then 'yes'
        when 0 then 'no'
    end 'Self Claim'
    ,case pct.client_data
        when 1 then 'filled'
        when 0 then 'Unfilled'
    end 'Claim Information'
    ,case pct.check_data
        when 2 then 'fail'
        when 0 then 'To be reviewed'
        when 1 then 'reviewed'
    end 'Review information'
    ,case pct.vip_enable
        when 1 then 'Kam Customer'
        when 0 then 'Common Customer'
    end 'Customer Type'
    ,pct.parcel_created_at 'Receive time'
    ,concat(kp.name, ' ', kp.major_mobile, ' ', kp.email) 'Customer Information'
    ,case pct.source
        WHEN 1 THEN 'A - Problematic Item - Lost'
        WHEN 2 THEN 'B - Processing Record - Lost'
        WHEN 3 THEN 'C - Status not updated'
        WHEN 4 THEN 'D - Problematic Item - Damaged/Short'
        WHEN 5 THEN 'E - Processing Record - Claim - Lost'
        WHEN 6 THEN 'F - Processing Record - Claim  -Damaged/Short'
        WHEN 7 THEN 'G - Processing Record - Claim - Others'
        WHEN 8 THEN 'H-Lost parcel claims without waybill numbe'
        WHEN 9 THEN 'J-problem processing-Packaging damage insurance'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K - Breached Parcel'
        when 12 then 'L-highly suspected lost parcel'
    end 'Source of problem'
    ,pct.updated_at 'Last processing time'
    ,pct.operator_id 'Handler'
    ,pct.area 'Region'
    ,case pct.state
        when 3 then 'Financial verification'
        when 4 then 'Financial payment'
    end Status
from bi_pro.parcel_claim_task pct
left join fle_staging.ka_profile kp on kp.id = pct.client_id
where
    pct.state in (3,4);
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name
    ,hsi.staff_info_id
    ,hsi.mobile
from bi_pro.hr_staff_info hsi
left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    hsi.state = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    min(routed_at)
from rot_pro.parcel_route pr;
;-- -. . -..- - / . -. - .-. -.--
select
    distinct pi.pno
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join rot_pro.parcel_route pr on pr.pno = pi.pno
join bi_pro.parcel_lose_task plt on plt.pno = pi.pno
where
    pi.created_at > '2025-02-28 17:00:00'
    and pi.created_at < '2025-04-30 17:00:00'
    and ss.category in (2,14) -- DC,PDC
    and pr.routed_at > '2025-02-28 17:00:00'
    and pr.route_action ='PENDING_RETURN'
    and pr.store_category = 4
    and plt.state = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    distinct pi.pno
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join rot_pro.parcel_route pr on pr.pno = pi.pno
join bi_pro.parcel_lose_task plt on plt.pno = pi.pno
where
    pi.created_at > '2025-02-28 17:00:00'
    and pi.created_at < '2025-04-30 17:00:00'
    and ss.category in (2,14) -- DC,PDC
    and pr.routed_at > '2025-02-28 17:00:00'
    and pr.route_action ='PENDING_RETURN'
    and pr.store_category = 4
    and plt.state = 6
    and plt.parcel_created_at > '2025-02-28 17:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    date (convert_tz(pr.routed_at, '+00:00', '+07:00')) 日期
    ,count(pr.id) cnt
from rot_pro.parcel_route pr
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select now();
;-- -. . -..- - / . -. - .-. -.--
select
    sp.store_name 发件出仓扫描网点
    ,pr.pno 运单号
    ,pi.src_name 寄件人
    ,sp.staff_info_name 发件出仓操作人
    ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
    ,ps.van_in_proof_id 出车凭证
    ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
    ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
    ,ps.store_name 车货关联到港网点
from
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
    ) pr
join
    (
        select
            pssn.pno
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        where
            pssn.valid_store_order is not null
            and pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
    ) ps on ps.pno = pr.pno
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.routed_at > date_sub('2025-05-10', interval 7 hour)
            and pr.routed_at < date_add('2025-05-15', interval 17 hour)
    ) sp on sp.pno = pr.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
left join
    (
        select
            pi.pno
            ,pi.src_name
        from fle_staging.parcel_info pi
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
    ) pi on pi.pno = pr.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id;
;-- -. . -..- - / . -. - .-. -.--
select
            pssn.pno
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        where
            pssn.valid_store_order is not null
            and pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour);
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14;
;-- -. . -..- - / . -. - .-. -.--
select
            pssn.pno
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour);
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.routed_at > date_sub('2025-05-01', interval 7 hour)
            and pr.routed_at < date_add('2025-05-15', interval 17 hour);
;-- -. . -..- - / . -. - .-. -.--
select
            pi.pno
            ,pi.src_name
        from fle_staging.parcel_info pi
        where
            pi.created_at > date_sub(curdate(), interval 3 month);
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN';
;-- -. . -..- - / . -. - .-. -.--
select
    sp.store_name 发件出仓扫描网点
    ,pr.pno 运单号
    ,pi.src_name 寄件人
    ,sp.staff_info_name 发件出仓操作人
    ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
    ,ps.van_in_proof_id 出车凭证
    ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
    ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
    ,ps.store_name 车货关联到港网点
from
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
    ) pr
join
    (
        select
            pssn.pno
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
    ) ps on ps.pno = pr.pno
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.routed_at > date_sub('2025-05-01', interval 7 hour)
            and pr.routed_at < date_add('2025-05-15', interval 17 hour)
    ) sp on sp.pno = pr.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
left join
    (
        select
            pi.pno
            ,pi.src_name
        from fle_staging.parcel_info pi
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
    ) pi on pi.pno = pr.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id;
;-- -. . -..- - / . -. - .-. -.--
select
#     sp.store_name 发件出仓扫描网点
#     ,pr.pno 运单号
#     ,pi.src_name 寄件人
#     ,sp.staff_info_name 发件出仓操作人
#     ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
#     ,ps.van_in_proof_id 出车凭证
#     ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
#     ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
#     ,ps.store_name 车货关联到港网点
    *
from
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
    ) pr
join
    (
        select
            pssn.pno
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
    ) ps on ps.pno = pr.pno;
;-- -. . -..- - / . -. - .-. -.--
select
#     sp.store_name 发件出仓扫描网点
#     ,pr.pno 运单号
#     ,pi.src_name 寄件人
#     ,sp.staff_info_name 发件出仓操作人
#     ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
#     ,ps.van_in_proof_id 出车凭证
#     ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
#     ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
#     ,ps.store_name 车货关联到港网点
    *
from
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
    ) pr
join
    (
        select
            pssn.pno
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month)
    ) ps on ps.pno = pr.pno;
;-- -. . -..- - / . -. - .-. -.--
select
#     sp.store_name 发件出仓扫描网点
#     ,pr.pno 运单号
#     ,pi.src_name 寄件人
#     ,sp.staff_info_name 发件出仓操作人
#     ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
#     ,ps.van_in_proof_id 出车凭证
#     ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
#     ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
#     ,ps.store_name 车货关联到港网点
    *
from
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
    ) pr
join
    (
        select
            pssn.pno
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month)
    ) ps on ps.pno = pr.pno
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.routed_at > date_sub('2025-05-01', interval 7 hour)
            and pr.routed_at < date_add('2025-05-15', interval 17 hour)
    ) sp on sp.pno = pr.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
left join
    (
        select
            pi.pno
            ,pi.src_name
        from fle_staging.parcel_info pi
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
    ) pi on pi.pno = pr.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
    )
select
    sp.store_name 发件出仓扫描网点
    ,sp.store_id 发件出仓扫描网点ID
    ,pr.pno 运单号
    ,pi.src_name 寄件人
    ,sp.staff_info_name 发件出仓操作人
    ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
    ,ps.van_in_proof_id 出车凭证
    ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
    ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
    ,ps.store_name 车货关联到港网点
    ,ps.store_id 车货关联到港网点ID
    ,now() 更新时间
from
    (
        select
            pssn.pno
            ,pssn.store_order
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month)
#             and ${if(len(proof)>0," pssn.van_in_proof_id in ('"+proof+"')",1=1)}
    ) ps
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.routed_at > date_sub('2025-05-01', interval 7 hour)
            and pr.routed_at < date_add('2025-05-15', interval 17 hour)
#             and ${if(len(proof)>0," json_extract(pr.extra_value, '$.proofId') in ('"+proof+"')",1=1)}
#             and ${if(len(store)>0," pr.store_name in ('"+store+"')",1=1)}
    ) sp on sp.pno = ps.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
join
    (
        select
            pi.pno
            ,pi.src_name
        from fle_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.state in ()
    ) pi on pi.pno = ps.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id
left join dw_dmd.parcel_store_stage_new pssn2 on pssn2.pno = ps.pno and pssn2.store_order > ps.store_order
where
    pssn2.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
    )
select
    sp.store_name 发件出仓扫描网点
    ,sp.store_id 发件出仓扫描网点ID
    ,ps.pno 运单号
    ,pi.src_name 寄件人
    ,sp.staff_info_name 发件出仓操作人
    ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
    ,ps.van_in_proof_id 出车凭证
    ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
    ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
    ,ps.store_name 车货关联到港网点
    ,ps.store_id 车货关联到港网点ID
    ,now() 更新时间
from
    (
        select
            pssn.pno
            ,pssn.store_order
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month)
#             and ${if(len(proof)>0," pssn.van_in_proof_id in ('"+proof+"')",1=1)}
    ) ps
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
#             and pr.routed_at > date_sub('${start_date}', interval 7 hour)
#             and pr.routed_at < date_add('${end_date}', interval 17 hour)
#             and ${if(len(proof)>0," json_extract(pr.extra_value, '$.proofId') in ('"+proof+"')",1=1)}
#             and ${if(len(store)>0," pr.store_name in ('"+store+"')",1=1)}
    ) sp on sp.pno = ps.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
join
    (
        select
            pi.pno
            ,pi.src_name
        from fle_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.state in ()
    ) pi on pi.pno = ps.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id
left join dw_dmd.parcel_store_stage_new pssn2 on pssn2.pno = ps.pno and pssn2.store_order > ps.store_order
where
    pssn2.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
    )
select
    sp.store_name 发件出仓扫描网点
    ,sp.store_id 发件出仓扫描网点ID
    ,ps.pno 运单号
    ,pi.src_name 寄件人
    ,sp.staff_info_name 发件出仓操作人
    ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
    ,ps.van_in_proof_id 出车凭证
    ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
    ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
    ,ps.store_name 车货关联到港网点
    ,ps.store_id 车货关联到港网点ID
    ,now() 更新时间
from
    (
        select
            pssn.pno
            ,pssn.store_order
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month)
#             and ${if(len(proof)>0," pssn.van_in_proof_id in ('"+proof+"')",1=1)}
    ) ps
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
#             and pr.routed_at > date_sub('${start_date}', interval 7 hour)
#             and pr.routed_at < date_add('${end_date}', interval 17 hour)
#             and ${if(len(proof)>0," json_extract(pr.extra_value, '$.proofId') in ('"+proof+"')",1=1)}
#             and ${if(len(store)>0," pr.store_name in ('"+store+"')",1=1)}
    ) sp on sp.pno = ps.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
join
    (
        select
            pi.pno
            ,pi.src_name
        from fle_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.state in (1,2,3,4,6)
    ) pi on pi.pno = ps.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id
left join dw_dmd.parcel_store_stage_new pssn2 on pssn2.pno = ps.pno and pssn2.store_order > ps.store_order
where
    pssn2.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
    )
select
    sp.store_name 发件出仓扫描网点
    ,sp.store_id 发件出仓扫描网点ID
    ,ps.pno 运单号
    ,pi.src_name 寄件人
    ,sp.staff_info_name 发件出仓操作人
    ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
    ,ps.van_in_proof_id 出车凭证
    ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
    ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
    ,ps.store_name 车货关联到港网点
    ,ps.store_id 车货关联到港网点ID
    ,now() 更新时间
from
    (
        select
            pssn.pno
            ,pssn.store_order
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month)
#             and ${if(len(proof)>0," pssn.van_in_proof_id in ('"+proof+"')",1=1)}
    ) ps
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
#             and pr.routed_at > date_sub('${start_date}', interval 7 hour)
#             and pr.routed_at < date_add('${end_date}', interval 17 hour)
#             and ${if(len(proof)>0," json_extract(pr.extra_value, '$.proofId') in ('"+proof+"')",1=1)}
#             and ${if(len(store)>0," pr.store_name in ('"+store+"')",1=1)}
    ) sp on sp.pno = ps.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
join
    (
        select
            pi.pno
            ,pi.src_name
        from fle_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.state in (1,2,3,4,6)
    ) pi on pi.pno = ps.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id
left join
    (
        select
            pssn3.pno
            ,pssn3.store_order
        from dw_dmd.parcel_store_stage_new pssn3
        join t t1 on t1.pno = pssn3.pno
        where
            pssn3.first_valid_route_action is not null
    ) p2 on p2.pno = ps.pno and p2.store_order > ps.store_order
where
    p2.pno is null;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.distance
    ,pr.'距离'
    ,pr.store_id
    ,pr.name
    ,pr.route_action
    ,pr.routed_at
    ,pr.pno
    ,pr2.route_action
from
    (
        select
            case
                when round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0)<=200 then '网点操作'
                when round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0) is null then '网点操作'
            else '仓外操作'
            end as distance
            ,round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0) '距离'
            ,store_id
            ,ss.name name
            ,pr.route_action
            ,convert_tz(pr.routed_at,'+00:00','+07:00') routed_at
            ,pr.pno
            ,pr.id
        from rot_pro.parcel_route pr
        left join fle_staging.sys_store ss on ss.id = pr.store_id
        where
            ss.lng is not null
            and ss.lat is not null
        #     and convert_tz(pr.created_at,'+00:00','+07:00')>='2025-04-09'
        #     and convert_tz(pr.created_at,'+00:00','+07:00')<'2025-04-10'
            and pr.routed_at >= '2025-05-14 17:00:00'
            and pr.routed_at < '2025-05-15 17:00:00'
            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN','DELIVERY_MARKER','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DIFFICULTY_HANDOVER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED')
            and pr.store_id in ('TH02060149','TH01480142','TH03040255','TH71140100','TH02040114','TH02030145','TH15060836','TH01100108','TH04030108','TH04020410')
        --    and pr.pno = 'THT55021UYDRB0Z'
  ) pr
left join
    (
        select
            pr.pno
            ,'RECEIVE_WAREHOUSE_SCAN' route_action
        from rot_pro.parcel_route pr
        where
            pr.routed_at >= '2025-05-01 17:00:00'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_id in ('TH02060149','TH01480142','TH03040255','TH71140100','TH02040114','TH02030145','TH15060836','TH01100108','TH04030108','TH04020410')

        union

        select
            pr.pno
            ,'SHIPMENT_WAREHOUSE_SCAN' route_action
        from rot_pro.parcel_route pr
        where
            pr.routed_at >= '2025-05-01 17:00:00'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_id in ('TH02060149','TH01480142','TH03040255','TH71140100','TH02040114','TH02030145','TH15060836','TH01100108','TH04030108','TH04020410')

        union

        select
            pr.pno
            ,'RECEIVED' route_action
        from rot_pro.parcel_route pr
        where
            pr.routed_at >= '2025-05-01 17:00:00'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_id in ('TH02060149','TH01480142','TH03040255','TH71140100','TH02040114','TH02030145','TH15060836','TH01100108','TH04030108','TH04020410')
    ) pr2 on pr.pno = pr2.pno and pr.route_action = pr2.route_action
where
     pr2.pno is null
    and  pr.distance='仓外操作';
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
    )
select
    sp.store_name 发件出仓扫描网点
    ,sp.store_id 发件出仓扫描网点ID
    ,ps.pno 运单号
    ,pi.src_name 寄件人
    ,sp.staff_info_name 发件出仓操作人
    ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
    ,ps.van_in_proof_id 出车凭证
    ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
    ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
    ,ps.store_name 车货关联到港网点
    ,ps.store_id 车货关联到港网点ID
    ,now() 更新时间
from
    (
        select
            pssn.pno
            ,pssn.store_order
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month)
    ) ps
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)

    ) sp on sp.pno = ps.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
join
    (
        select
            pi.pno
            ,pi.src_name
        from fle_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.state in (1,2,3,4,6)
    ) pi on pi.pno = ps.pno
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id
left join
    (
        select
            pssn3.pno
            ,pssn3.store_order
        from dw_dmd.parcel_store_stage_new pssn3
        join t t1 on t1.pno = pssn3.pno
        where
            pssn3.first_valid_route_action is not null
    ) p2 on p2.pno = ps.pno and p2.store_order > ps.store_order
where
    p2.pno is null;
;-- -. . -..- - / . -. - .-. -.--
select
            distinct
            pr.pno
        from rot_pro.parcel_route pr
        join fle_staging.parcel_info pi on pi.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
            and pi.created_at > date_sub(curdate(), interval 2 month)
            and pi.state in (1,2,3,4,6);
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            distinct
            pr.pno
            ,pi.src_name
        from rot_pro.parcel_route pr
        join fle_staging.parcel_info pi on pi.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
            and pi.created_at > date_sub(curdate(), interval 2 month)
            and pi.state in (1,2,3,4,6)
    )
select
    sp.store_name 发件出仓扫描网点
    ,sp.store_id 发件出仓扫描网点ID
    ,ps.pno 运单号
    ,ps.src_name 寄件人
    ,sp.staff_info_name 发件出仓操作人
    ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
    ,ps.van_in_proof_id 出车凭证
    ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
    ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
    ,ps.store_name 车货关联到港网点
    ,ps.store_id 车货关联到港网点ID
    ,now() 更新时间
from
    (
        select
            pssn.pno
            ,pssn.store_order
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
            ,t1.src_name
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        where
            pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month)
    ) ps
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)

    ) sp on sp.pno = ps.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id
left join
    (
        select
            pssn3.pno
            ,pssn3.store_order
        from dw_dmd.parcel_store_stage_new pssn3
        join t t1 on t1.pno = pssn3.pno
        where
            pssn3.first_valid_route_action is not null
    ) p2 on p2.pno = ps.pno and p2.store_order > ps.store_order
where
    p2.pno is null;
;-- -. . -..- - / . -. - .-. -.--
select
            distinct
            pr.pno
            ,pi.src_name
            ,pssn.store_order
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from rot_pro.parcel_route pr
        join fle_staging.parcel_info pi on pi.pno = pr.pno
        join dw_dmd.parcel_store_stage_new pssn on pssn.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
            and pi.created_at > date_sub(curdate(), interval 2 month)
            and pi.state in (1,2,3,4,6)
            and pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month);
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            distinct
            pr.pno
            ,pi.src_name
            ,pssn.store_order
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from rot_pro.parcel_route pr
        join fle_staging.parcel_info pi on pi.pno = pr.pno
        join dw_dmd.parcel_store_stage_new pssn on pssn.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
            and pi.created_at > date_sub(curdate(), interval 2 month)
            and pi.state in (1,2,3,4,6)
            and pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month)
    )
select
    sp.store_name 发件出仓扫描网点
    ,sp.store_id 发件出仓扫描网点ID
    ,ps.pno 运单号
    ,ps.src_name 寄件人
    ,sp.staff_info_name 发件出仓操作人
    ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
    ,ps.van_in_proof_id 出车凭证
    ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
    ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
    ,ps.store_name 车货关联到港网点
    ,ps.store_id 车货关联到港网点ID
    ,now() 更新时间
from t ps
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.next_store_id = t1.store_id and json_extract(pr.extra_value, '$.proofId') = t1.van_in_proof_id
    ) sp on sp.pno = ps.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
            and json_extract(pr.extra_value, '$.proofId') = t1.van_in_proof_id
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id
left join
    (
        select
            pssn3.pno
            ,pssn3.store_order
        from dw_dmd.parcel_store_stage_new pssn3
        join t t1 on t1.pno = pssn3.pno
        where
            pssn3.first_valid_route_action is not null
    ) p2 on p2.pno = ps.pno and p2.store_order > ps.store_order
where
    p2.pno is null;