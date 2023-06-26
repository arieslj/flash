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

;


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
    ps.pack_pno is null


















;



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
#     ,'普通' type
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
#     ,'物料' type
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
#     ,'fh' type
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
    and ss.category = 6 -- 非FH





;










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
group by 1

;


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
    a.rk = 1









