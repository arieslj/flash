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
group by 1,2


;


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
left join dwm.dwd_ph_network_spill_detl_rd dt on dt.统计日期 = t.妥投时间 and dt.网点名称 = t.妥投网点


;






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
having count(pi.pno) > 20