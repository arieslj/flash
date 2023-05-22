/*=====================================================================+
        表名称：  1115d_ph_transport_parcel
        功能描述： PH 运输环节包裹监控数据

        需求来源：
        编写人员: 马勇
        设计日期：2022/12/03
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================*/
      select
pr1.store_name 发车网点
,pr1.next_store_name 到车网点
,ft1.line_name 线路名称
,ft1.proof_id 出车凭证号
,ft1.plan_leave_time 计划发车时间
,ft1.real_leave_time 实际发车时间
,ft2.plan_arrive_time 计划到车时间
,ft2.real_arrive_time 实际到车时间
,ft1.proof_plate_number 车牌号
,case ft1.line_plate_type
when 100 then '4W'
when 101 then '4WJ'
when 102 then 'PH4WFB'
when 200 then '6W5.5'
when 201 then '6W6.5'
when 203 then '6W7.2'
when 204 then 'PH6W'
when 205 then 'PH6WF'
when 210 then '6W8.8'
when 300 then '10W'
when 400 then '14W'
end 车型
,pr2.解封车时间
,pr1.'装载重量(KG)'
,pr1.'体积(立方米)'
,pr1.应到包裹数
,pr2.实到包裹数
,pr1.应到包裹数 - pr2.实到包裹数 未到包裹数
,pr1.应到集包数
,pr2.实到集包数
,pr1.应到集包数 - pr2.实到集包数 未到集包数

from
(
  select
  pr1.proof_id
  ,pr1.store_name
  ,pr1.next_store_name
  ,count(distinct pr1.pno) 应到包裹数
  ,count(distinct pr1.packpno) 应到集包数
  ,sum(pi.store_weight/1000) '装载重量(KG)'
  ,sum(pi.store_length*pi.store_width*pi.store_height/1000000) '体积(立方米)'
  from
  (
    select distinct
    REPLACE(json_extract(pr.extra_value,'$.proofId'),'\"','') proof_id
    ,pr.store_name
    ,pr.next_store_name
    ,pr.pno
    ,replace(json_extract(pr.extra_value, '$.packPno'),'\"','') packpno
    FROM ph_staging.parcel_route pr
    where pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and  pr.routed_at >= date_sub(curdate(),interval 6 day)
  ) pr1
  left join ph_staging.parcel_info pi
  on pr1.pno = pi.pno
  group by 1,2,3
) pr1

left join

(
  select
  REPLACE(json_extract(pr.extra_value,'$.proofId'),'\"','') proof_id
  ,pr.store_name
  ,count(distinct pr.pno) 实到包裹数
  ,count(distinct replace(json_extract(pr.extra_value, '$.packPno'),'\"',''))  实到集包数
  ,convert_tz(min(pr.routed_at),'+00:00','+08:00') 解封车时间
  FROM ph_staging.parcel_route pr
  where pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
  and  pr.routed_at >= date_sub(curdate(),interval 6 day)
  group by 1,2
) pr2
on pr1.proof_id = pr2.proof_id
and pr1.next_store_name = pr2.store_name

left join ph_bi.fleet_time ft1
on ft1.proof_id = pr1.proof_id
and ft1.store_name = pr1.store_name

left join ph_bi.fleet_time ft2
on ft2.proof_id = pr2.proof_id
and ft2.next_store_name = pr2.store_name

where ft2.real_arrive_time >= date_sub(curdate(),interval 1 day)
and ft2.real_arrive_time < curdate();


SELECT
	pr.pno
    ,ft.`store_name` 始发网点
    ,ft.`next_store_name` 目的网点
    ,ft.line_name 线路名称
    ,pr.proof_id 出车凭证
	,ft.proof_plate_number 车牌号
    ,ft.`real_arrive_time` 实际到车时间
    ,pi.`client_id` 客户ID
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
                     end  '物品类型'
                  ,pi.store_weight/1000 '物品重量'
                  ,pi.store_length*pi.store_width*pi.store_height '体积'
           		  ,pr.store_name 车货关联到港网点
from (-- 最后一条路由是车货关联出港
                                select
                                pr.store_id,
                                pr.routed_at,
                                pr.`pno`,
                                pr.store_name,
                                pr.proof_id

                                from(select
                                     pr.`pno`
                                     ,pr.store_id
                                     ,pr.`routed_at`
                                     ,pr.route_action
                                     ,pr.store_name
                                     ,REPLACE(json_extract(pr.extra_value,'$.proofId'),'\"','') proof_id
                                     ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                                     from ph_staging.`parcel_route`as pr
                                     where convert_tz(pr.routed_at,'+00:00','+08:00')>= date_sub(CURRENT_DATE ,INTERVAL 7 day)

                                     ) pr
                                       where pr.rn = 1
                                      and pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
       )pr
 LEFT JOIN `ph_bi`.`fleet_time` ft on ft.`proof_id` =pr.`proof_id`
 LEFT JOIN `ph_staging`.`parcel_info` pi on pi.pno=pr.pno

 where convert_tz(pr.routed_at,'+00:00','+08:00') >= date_sub(curdate(),interval 7 day)
and convert_tz(pr.routed_at,'+00:00','+08:00') < curdate()
GROUP by 1



;

select
    count(distinct pss.pno) num
from dw_dmd.parcel_store_stage_new pss
where
    pss.van_out_proof_id = 'DMTL23109M3'
;

select distinct
    REPLACE(json_extract(pr.extra_value,'$.proofId'),'\"','') proof_id
    ,pr.store_name
    ,pr.next_store_name
    ,pr.pno
    ,replace(json_extract(pr.extra_value, '$.packPno'),'\"','') packpno
    FROM ph_staging.parcel_route pr
    where pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and  pr.routed_at >= date_sub(curdate(),interval 6 day)
    and pr.store_name = 'DMT_SP'
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
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id


    ;
