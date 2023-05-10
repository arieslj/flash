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
