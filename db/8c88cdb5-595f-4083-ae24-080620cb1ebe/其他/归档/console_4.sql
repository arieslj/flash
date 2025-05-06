select
    a.creat_date
    ,a.submit_store_name
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
    ,count(distinct a.hno) 上报无头件总数
    ,count(distinct if(a.state = 5, a.hno, null)) 撤销数量
    ,count(distinct if(a.head_state in ('认领成功', '认领成功-已失效', '认领失败-已失效'), a.hno, null)) 认领成功数量
    ,count(distinct if(a.head_state in ('未认领-已失效'), a.hno, null)) 失效的数量
    ,count(distinct if(a.state = 3 and a.print_state in (1,2), a.hno, null)) 失效后已处理数量
from
    (
        select
            ph.hno
            ,date(convert_tz(ph.created_at, '+00:00','+08:00')) creat_date
            ,ph.submit_store_name
            ,ph.submit_store_id
            ,ph.pno
            ,case
                when ph.state = 0 then '未认领-待认领'
                when ph.state = 2 then '认领成功'
                when ph.state = 3 and ph.claim_store_id is null then '未认领-已失效'
                when ph.state = 3 and ph.claim_store_id is not null and ph.updated_at < coalesce(sx.claim_time,curdate()) then '认领成功-已失效'
                when ph.state = 3 and ph.claim_store_id is not null and ph.updated_at >= coalesce(sx.claim_time,curdate()) then '认领失败-已失效'
            end head_state
            ,ph.state
            ,ph.created_at
            ,ph.claim_store_id
            ,ph.claim_store_name
            ,ph.claim_at
            ,ph.updated_at
            ,ph.print_state
        from  fle_staging.parcel_headless ph
        left join
            (
                select
                    ph.pno
                    ,min(pct.created_at) claim_time
                from fle_staging.parcel_headless ph
                join bi_pro.parcel_claim_task pct on pct.pno = ph.pno
                where
                    ph.state = 3 -- 失效
                group by 1
            ) sx on sx.pno = ph.pno
        where
#             ph.state < 4
            ph.created_at >= '2023-04-05 17:00:00'
            and ph.created_at < '2023-05-06 17:00:00'
#             and ph.claim_store_id is not null -- 有认领动作
#             and ph.claim_staff_id is not null
    ) a
left join fle_staging.sys_store ss on ss.id = a.submit_store_id
group by 1,2,3;








;

select
    date(convert_tz(ft.`created_at`,'+00:00','+07:00')) 日期,
    ft.`input_by` ID,
    sum(ft.`input_state`=2) 里程审核通过数量,
    sum(ft.`input_state`=3) 模糊数量,
    sum(ft.`input_state`=4) 虚报数量,
    count(*) 里程审核任务总数量
from `wrs_production`.`fuel_task` ft
left join backyard_pro.staff_mileage_record smr on smr.id = ft.smr_id
where
    ft.`created_at` >= convert_tz(CURRENT_DATE-interval 7 day,'+07:00','+00:00')
group by 1,2
order by 2
;

select
    date(convert_tz(smr.`created_at`,'+00:00','+07:00')) 日期
    ,ss.name 网点
    ,smr.staff_info_id 快递员
    ,smr.input_by 审核人员
    ,case smr.input_state
        when 0 then '未审核'
        when 1 then '审核中'
        when 2 then '通过'
        when 3 then '模糊'
        when 4 then '虚假'
    end  审批状态
from  backyard_pro.staff_mileage_record smr
left join fle_staging.sys_store ss on ss.id = smr.store_id
where
#     smr.`created_at` >= convert_tz(CURRENT_DATE-interval 7 day,'+07:00','+00:00')
    smr.created_at >= '2023-05-14 17:00:00'
    and smr.created_at < '2023-05-21 17:00:00'

;





select
    fvp.relation_no
     ,pwr.before_weight
    ,pwr.after_weight
    ,pwr.after_weight - pwr.before_weight chaju
from fle_staging.fleet_van_proof_parcel_detail fvp
left join dwm.drds_parcel_weight_revise_record_d pwr on pwr.pno = fvp.relation_no
where
    fvp.proof_id = 'SAMQQ9A63'

;




select
ss.id 网点ID,
ss.name 网点,
if(ssbb.bdc_id is not null ,'BSP',if(ss.`category`=1,'SP','BDC')) '网点类型',
mp.name 片区,
mr.name 大区 ,
jj.DCO交接量,
jj.DCO今日尝试派送量,
jj.DCO今日妥投量,
jj.DCO回访确认虚假量

from `fle_staging`.`sys_store` ss
LEFT JOIN `fle_staging`.`sys_manage_piece` mp on mp.`id` =ss.`manage_piece`
left join `fle_staging`.`sys_manage_region`mr on mr.id=ss.`manage_region`

left join fle_staging.sys_store_bdc_bsp ssbb on ssbb.bdc_id=ss.id

LEFT JOIN (
select
dt.`store_id` ,
ss.`name` ,
COUNT( distinct dt.`pno` ) 'DCO交接量',
count(distinct if(prlm.pno is not null  ,dt.`pno` ,null))  'DCO今日尝试派送量',
count(distinct if(pi.`state`  =5  and date(convert_tz(dt.delivery_at, '+00:00','+07:00')) = date(convert_tz(pi.finished_at, '+00:00','+07:00')),dt.`pno` ,null))   'DCO今日妥投量',
count(distinct  vrv.link_id) DCO回访确认虚假量
from `fle_staging`.`ticket_delivery` dt
left join `fle_staging`.`parcel_info` pi on dt.`pno` = pi.`pno`
left join dwm.tmp_ex_big_clients_id_detail cd on cd.`client_id` =pi.`client_id`
left join nl_production.violation_return_visit vrv on vrv.link_id = pi.pno and vrv.visit_result in (8,19,20,21,31,32,22,23,24)
left join -- 新增尝试派送
 (
  select
  pr.pno
  ,pr.store_id
  ,pr.staff_info_id
  ,min(pr.routed_at)  first_marker_time
  from rot_pro.parcel_route pr
  where 1=1
  and pr.store_category in (1,10)
  and pr.route_action in ( 'DELIVERY_MARKER','DELIVERY_CONFIRM','PHONE')
  and pr.routed_at >= convert_tz(  '2023-04-01','+07:00','+00:00')
  group by 1,2,3
 ) prlm -- 最早一条派件标记
 on dt.`pno`  = prlm.pno and dt.`store_id` = prlm.store_id and dt.`staff_info_id` = prlm.staff_info_id and date(convert_tz(dt.delivery_at, '+00:00','+07:00')) = date(date(convert_tz(prlm.first_marker_time, '+00:00','+07:00')))

left join `fle_staging`.`sys_store` ss on dt.`store_id`  = ss.`id`
LEFT JOIN `fle_staging`.`staff_info`  si on si.`id`     =dt.`staff_info_id`

where date(convert_tz(dt.delivery_at, '+00:00','+07:00')) >= '2023-04-01'
and dt.`transfered` = 0
and dt.`state` in (0,1,2)
and si.job_title=37  -- 仓管员
GROUP BY 1

) jj on jj.store_id=ss.id

where ss.`category` in (1,10)
and ss.`state` =1
and ss.`opening_at` is not null
and jj.DCO交接量 is not null





















;

with t as
(
        SELECT
        t.*
        from
        (
        SELECT
                di.pno
                ,pi.dst_phone
                ,count(di.pno)over(partition by pi.dst_phone) 拒收量
                ,pi2.总量
        from fle_staging.diff_info di
        left join fle_staging.parcel_info pi
        on di.pno=pi.pno
        left JOIN
        (
                select
                        pi.pno
                        ,pi.dst_phone
                        ,count(pi.pno)over(partition by pi.dst_phone) 总量
                from fle_staging.parcel_info pi
                where pi.created_at>=convert_tz('2023-04-30','+07:00','+00:00')
                group by 1,2
        )pi2 on pi.dst_phone= pi2.dst_phone
        where di.diff_marker_category=17
        and di.created_at>=convert_tz('2023-05-01','+07:00','+00:00')
        and pi2.总量 is not null
        group by 1,2
        )t where t.拒收量/t.总量>0.15
),
di AS
(
SELECT
        t.*
        ,di.created_at
from t
left join
(
        select
                di.pno
                ,max(di.created_at) created_at
        from fle_staging.diff_info di
        where di.created_at>=convert_tz('2023-05-01','+07:00','+00:00')
        and di.diff_marker_category=17
        group by 1
)di on t.pno=di.pno
)
SELECT
        di.pno
        ,convert_tz(di.created_at,'+00:00','+07:00') 最后一次标记时间
        ,pr.ct 最后一次标记拒收前电话次数
        ,pr.callduration '有效通话次数（>=15s）次数'
        ,pr.diaboloduration '响有效通话次数（>=15s）且铃时长为3s\2s\4s的通话次数'
from di
left join
(
        select
       pr.pno
       ,date(pr.routed_at) routed_at
       ,count(pr.diaboloduration)over(partition by pr.pno) ct
       ,count(if(pr.callduration >=15,pr.pno,null))over(partition by pr.pno,date(pr.routed_at)) callduration
       ,count(if(pr.callduration >=15 and pr.diaboloduration in (2,3,4),pr.pno,null))over(partition by pr.pno, date(pr.routed_at)) diaboloduration
    from
    (
                select
                pr.pno
                ,convert_tz(pr.routed_at,'+00:00','+07:00') routed_at
                ,json_extract(pr.extra_value,'$.callDuration') callduration
                ,json_extract(pr.extra_value,'$.diaboloDuration') diaboloduration
            from rot_pro.parcel_route pr
            left join di on di.pno=pr.pno
            where pr.route_action = 'PHONE'
            and pr.routed_at>='2023-04-20'
            and pr.routed_at<di.created_at
          -- and pr.pno='P13261HD7UQAB'
            group by 1,2
         )pr
)pr on di.pno=pr.pno
group by 1


;



with di as
(SELECT
        di.*
        /*,pr.ct
        -- ,convert_tz(cdt.updated_at,'+00:00','+08:00') 协商继续派送时间
        ,pr.callduration '有效通话次数（>=15s）'
    ,pr.diaboloduration '响有效通话次数（>=15s）且铃时长为3s\2s\4s的通话次数'*/
from
(
        select
                di.*
                ,pr.routed_at
                ,pr.remark
        from
        (
                select
                        di.pno
                        ,di.created_at
                        ,row_number()over(partition by di.pno order by di.created_at) rn
                from fle_staging.diff_info di
                left join fle_staging.customer_diff_ticket cdt
                on cdt.diff_info_id =di.id
                where di.diff_marker_category=17
                and cdt.negotiation_result_category=5
                -- and di.pno='P27151JVT29AC'
                and di.created_at>=convert_tz('2023-05-01','+08:00','+00:00')
        )di
        left join
        (
                select
                        pr.pno
                        ,pr.routed_at
                        ,pr.remark
                        ,json_extract(pr.extra_value,'$.deliveryAttemptNum') deliveryAttemptNum
                from rot_pro.parcel_route pr
                where pr.route_action ='DELIVERY_MARKER'
        )pr on di.pno=pr.pno
        where di.rn=1
        and pr.deliveryAttemptNum=1
        and pr.routed_at>di.created_at
)di
)
SELECT
di.pno
,convert_tz(di.created_at,'+00:00','+08:00') 提交疑难时间
,convert_tz(di.routed_at,'+00:00','+08:00') 二次派送失败时间
,di.remark 二次派送后标记原因
,pr.ct 继续派送后电话次数
,pr.callduration '有效通话次数（>=15s）次数'
,pr.diaboloduration '响有效通话次数（>=15s）且铃时长为3s\2s\4s的通话次数'
from di
left join
(
   select
   pr.pno
   ,date(pr.routed_at) routed_at
   ,count(pr.diaboloduration)over(partition by pr.pno) ct
   ,count(if(pr.callduration >=15,pr.pno,null))over(partition by pr.pno) callduration
   ,count(if(pr.callduration >=15 and pr.diaboloduration in (2,3,4),pr.pno,null))over(partition by pr.pno) diaboloduration
   from
   (
    select
        pr.pno
        ,convert_tz(pr.routed_at,'+00:00','+08:00') routed_at
        ,json_extract(pr.extra_value,'$.callDuration') callduration
        ,json_extract(pr.extra_value,'$.diaboloDuration') diaboloduration
    from rot_pro.parcel_route pr
    left join di on pr.pno=di.pno
    where pr.route_action = 'PHONE'
    and pr.routed_at>='2023-04-20'
    -- and pr.pno='P27151JVT29AC'
    and pr.routed_at>di.created_at
    and  pr.routed_at< di.routed_at
    group by 1,2
    )pr
)pr on pr.pno=di.pno
group by 1,2,3,4,5,6,7



;




SELECT
        t.*
from
(
        SELECT
                di.pno
                ,pi2.dst_phone 收件人电话
                ,convert_tz(di.created_at,'+00:00','+08:00') 提交拒收时间
                ,pr.callduration '有效通话次数（>=15s）'
            ,pr.diaboloduration '响有效通话次数（>=15s）且铃时长为3s\2s\4s的通话次数'
            ,count(di.pno)over(partition by pi2.dst_phone) 拒收次数
        FROM fle_staging.diff_info di
        left join fle_staging.parcel_info pi2
        on di.pno =pi2.pno
        left join
        (
           select
           pr.pno
           ,date(pr.routed_at) routed_at
           ,count(if(pr.callduration >=15,pr.pno,null))over(partition by pr.pno,date(pr.routed_at)) callduration
           ,count(if(pr.callduration >=15 and pr.diaboloduration in (2,3,4),pr.pno,null))over(partition by pr.pno, date(pr.routed_at)) diaboloduration
           from
           (
            select
                pr.pno
                ,convert_tz(pr.routed_at,'+00:00','+08:00') routed_at
                ,json_extract(pr.extra_value,'$.callDuration') callduration
                ,json_extract(pr.extra_value,'$.diaboloDuration') diaboloduration
            from rot_pro.parcel_route pr
            where pr.route_action = 'PHONE'
            and pr.routed_at>='2023-04-20'
          -- and pr.pno='P13261HD7UQAB'
            group by 1,2
            )pr

        )pr on pr.pno=di.pno and date(convert_tz(di.created_at,'+00:00','+08:00'))=pr.routed_at

        where pi2.cod_enabled=1
        and di.diff_marker_category=17
        and di.created_at>=convert_tz('2023-05-01','+08:00','+00:00')
 -- and di.pno='P47211HMYR8AW'
        group by 1,2,3,4,5
)t where t.拒收次数>=3
;

select
    pi.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0522 t on t.pno = pi.pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id

union

select
    pi.recent_pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0522 t on t.pno = pi.recent_pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id


;


select
    dt.store_name 网点名称
    ,dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_type 网点类型
    ,if(dd.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,count(distinct coalesce(am.average_merge_key, am.average_merge_key)) 生成处罚总量
    ,count(distinct if(pssn.store_id in ('TH02030121', 'TH46010401', 'TH02030307') or pssn.store_category = 14, pssn.pno, null)) '揽件网点没有收件入仓但包裹发往BAG89、BAG88、BAG99、PDC总量'
    ,count(distinct if(pssn.store_id not in ('TH02030121', 'TH46010401', 'TH02030307') and  pssn.store_category != 14, pssn.pno, null)) '揽件网点没有收件入仓且未发往BAG89、BAG88、BAG99、PDC总量'
    ,count(distinct if(pi.dst_store_id = pi.ticket_pickup_store_id, pi.pno, null)) 自揽自派总量
    ,count(distinct if(am.isappeal in (2,3,4,5), coalesce(am.average_merge_key, am.average_merge_key), null)) 网点申诉总量
    ,count(distinct if(am.state = 1 and am.isdel = 0, coalesce(am.average_merge_key, am.average_merge_key), null)) 实际处罚量
from bi_pro.abnormal_message am
left join fle_staging.parcel_info pi on pi.pno = am.merge_column
left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_th_network_spill_detl_rd dd on dd.统计日期 = am.abnormal_time and dd.网点ID = am.store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = am.merge_column and pssn.valid_store_order = 2
where
    am.punish_category = 39 -- 不揽收包裹未入仓
    and am.created_at >= '2023-04-19'
    and am.created_at < '2023-05-20'
group by 1,2,3,4,5
;

select
    dt.store_name
    ,am.merge_column
from bi_pro.abnormal_message am
left join fle_staging.parcel_info pi on pi.pno = am.merge_column
left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_th_network_spill_detl_rd dd on dd.统计日期 = am.abnormal_time and dd.网点ID = am.store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = am.merge_column and pssn.valid_store_order = 2
where
    am.punish_category = 39 -- 不揽收包裹未入仓
    and am.created_at >= '2023-04-19'
    and am.created_at < '2023-05-20'
    and dt.store_name in ('2LPW_BDC-ลาดพร้าว', '2LLK_BDC-ลำลูกกา', 'TMI_SP-ท่าไม้')
group by 1,2


;


select
    fvp.relation_no
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
    ,de.last_store_name 包裹当前网点
    ,de.last_cn_route_action 最后一条有效路由
    ,de.last_route_time 最后一条有效路由时间
    ,de.last_cn_marker_category 最近一次派送失败原因
    ,de.last_inventory_at 最后一次盘库时间
    ,de.dst_routed_at 目的地网点第一次有效路由时间
from fle_staging.fleet_van_proof_parcel_detail fvp
left join dwm.dwd_ex_th_parcel_details de on de.pno = fvp.relation_no
left join fle_staging.parcel_info pi on pi.recent_pno = fvp.recent_pno
where
    fvp.proof_id = 'BKKQWZF63'
    and fvp.relation_category = 1



;



select
    pi.pno 单号
    ,pi.client_id 客户ID
    ,ss.name 揽收网点
    ,pi.exhibition_weight 揽收重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 揽收尺寸
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_0529 t on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
;


select
    sci.pno
    ,sci.third_sorting_code
    ,sci.sorting_code
from dwm.drds_parcel_sorting_code_info sci
where
    sci.pno in ('TH01163Z321U1B1','THT01168SH8K0Z','THT01168JCBZ6Z','THT01168KH1V3Z','THT01168MMGQ0Z','THT01168G7AZ3Z','TH01163UDK146B0','TH01163YZSKJ3B0','TH01163YJXN05B0','TH011640X70B6B0','TH01163XX6QJ8B0','TH44113ZM9YY7H','TH011641T8K26B0','TH011641MCHR6B0','TH01163WCPTN9B0','THT011695SZF5Z','TH011641TC963B0','TH011641E6FW5B0','TH011641HUT08B0','TH011641ACGA7B0','TH01163ZACAE4B0','SSLT730008335006','THT01169ERA97Z','TH011641HQG02B0','TH011640XBF10B0','TH01163ZNAHK6B1','TH011641G4AF3B0','TH011640RTZ36B0','TH01163Z3X1C6B0','TH014440FU9Z3C','SSLT730007989946','THT01169BSST8Z','TH0116415HE72B0','TH011640XJYC5B0','THT011694NU44Z','TH01163Z4H946B0','TH011641F8X54B0','TH0116412DGJ4B0','THT011693H079Z','TH01163YU4SA2B0','TH0116410AEE2B0','THT0116944XR6Z','TH01163Z8AQ52B0','THT011693C138Z','TH01163U8AS92B1','TH01163V4P9B1B0','TH01163YPJJK1B0','TH01163YFXKU7B0','TH01163VVJEV9B0','TH01163VVG5Z8B0','TH01163W1Z2G0B0','TH01163XECHM9B0','TH01163XEMYM6B0','TH01163WJ3SE5B0','TH01163XPM448B0','TH01163X5R432B0','TH01163XKNPK6B0','TH01163WDM636B0','TH01163X1XU37B0','TH01163XKDJT1B0','TH01163YFNVM9B0','TH01163W1BWH9B0','TH01163TFSU52B0','TH01163YERXH0B0','TH01163ZYV9K2B0','TH01163Y4F6D1B0','TH01163X5CY06B0','TH01163V870R5B1','TH01163ZRNS77B0','TH011640SD2J2B0','TH01163ZSJ6A5B0','TH01163YGPGH9B0','TH01163XMGGD6B0','TH01163XHH8Z6B0','TH01163YK6DV0B0','TH011641A59K8B0','THT011692RHV2Z','TH011640MB5K0B0','TH011641FFXZ5B0','TH01163ZNYRR4B0','TH011641696Q8B0','TH01163YXHA96B0','TH011640ZUWK0B0','TH0116417Y4G6B0','TH011641UVPQ4B0','THT01168M6S30Z','TH01163ZU2009B0','TH0116412NCN2B0','THT011691FUY7Z','TH011640CS7T9B0','TH01163ZRX9P7B0','TH011640HNKB3B0','TH01163Z4Q9Y3B0','TH01163Y03VW4B0','TH011640B07U7B0','TH01163YY4Q26B0','TH011640XBR69B0','TH0116426S4S4B0','TH011640PXDH6B0','TH01163YJTZY2B0','TH011640TVZU2B0','TH011640JYYM4B0','THT011694KBF8Z','TH011640J6KM1B0','TH01163YK04S2B0','TH01163YAFFN1B0','TH011640VJTR6B0','TH01163ZREAK9B0','TH0116401T7A7B0','TH0116428EE16B0','THT01169CVMQ8Z','TH01163YGKDK4B0','TH01163VFVQC4B0','THT01169E7G27Z','THT01169JPCJ9Z','TH01164228NA7B0','TH01163ZVW7D0B0','THT01169AM808Z','TH011642TXUS2B0','THT011696VJM3Z','TH01163Z4EWR5B0','THT01169CH5H2Z','THT01169C2H82Z','TH01163ZFHPA6B0','TH011642M3HJ2B0','TH011642HSP27B0','TH011642HS7P5B0','TH01164269QN5B0','TH01163ZMSW42B0','TH014441F6TH6C','TH011642280Y2B0','TH01163ZZ4FK1B0','TH0116426Z1Z7B0','TH011641NAMW9B0','TH0116421XA09B0','TH01164292EJ0B0','TH0202427TB98A','TH011641SHSE2B0','TH01164293RY1B0','TH01163ZSXPT0B0','TH011641X3CF9B0','TH011641KFEP2B0','TH01163VT71R2B0','TH011642EYYR7B0','TH011641FTUK0B0','TH011641HRX92B0','TH01163Z49Q99B0','TH01163NA6864B0','THT011699E4P5Z','TH011641SQ2M6B0','TH0116415KV91B0','TH011641B7R16B0','TH0116419B5M5B0','TH011641R6NX2B0','TH01163ZGR9T1B0','TH01164213YJ4B0','THT01169617J0Z','TH0116411SNE2B0','TH011640WJQH1B0','TH011641B33Y0B0','TH011641RZ6D0B0','TH0116414MCT8B0','THT01169Y1HE6Z','TH011643NH6Z6B0','TH011640YSG47B1','TH0116436Q271B0','TH01163VUKT30B0','TH011642744Q5B0','THT01169KYFT3Z','TH0116425G4D4B0','TH0116439WQW7B0','TH011643B5SU1B0','TH011643D1WK0B0','TH011642XXJ00B0','TH011643C43V7B0','TH011642U32U0B0','TH011642SXT32B0','TH0116414Z417B0','TH01163Y3ERR3B0','TH01163Y6TZ62B0','TH01163WXE178B0','TH0116416GCT9B0','THT01169M06D7Z','TH011643BPY21B0','TH0116437G3M5B1','TH011642XZ343B0','TH01164093PE1B0','TH0116410VAA8A1','THT01169WR6B1Z','TH011642KNMY2B0','TH01164269567A0','TH01163ZADFQ4B0','TH011642ZTKJ4B0','THT01169JAPN9Z','TH01163Z2GD33B0','TH011642NVB14B0','TH011642VQFB9B0','TH020342BRYB6B0','TH011641Y33E8B0')
;


