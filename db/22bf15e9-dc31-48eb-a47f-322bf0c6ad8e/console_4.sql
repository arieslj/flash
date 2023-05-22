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
            ,date(ph.created_at) creat_date
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
    smr.created_at >= '2023-05-02 17:00:00'
    and smr.created_at < '2023-05-12 17:00:00'

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