/*=====================================================================+
        表名称：  1261d_ph_ss_month
        功能描述： PH SS判责系统

        需求来源：PH
        编写人员: 马勇
        设计日期：2023/02/08
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================*/
      SELECT
	DATE_FORMAT(plt.`updated_at`, '%Y%m%d') '统计日期 Statistical date'
	,if(plt.`duty_result`=3,pr.store_name,ss.`name`) '网点名称 store name'
	,smp.`name` '片区Area'
	,smr.`name` '大区District'
	,pi.`揽件包裹Qty. of pick up parcel`
	,pi2.`妥投包裹Qty. of delivered parcel`
	,COUNT(DISTINCT(if(plt.`duty_result`=1 and plt.`duty_type` in(4),plt.`pno`,null)))*0.5+COUNT(DISTINCT(if(plt.`duty_result`=1 and plt.`duty_type` not in(4),plt.`pno`,null))) '丢失 Lost'
	,COUNT(DISTINCT(if(plt.`duty_result`=2 and plt.`duty_type` in(4),plt.`pno`,null)))*0.5+COUNT(DISTINCT(if(plt.`duty_result`=2 and plt.`duty_type` not in(4),plt.`pno`,null))) '破损 Dmaged'
	,COUNT(DISTINCT(if(plt.`duty_result`=3 and plt.`duty_type` in(4),plt.`pno`,null)))*0.5+COUNT(DISTINCT(if(plt.`duty_result`=3 and plt.`duty_type` not in(4),plt.`pno`,null))) '超时包裹 Over SLA'
	,sum(if(plt.`duty_result`=1,pcn.claim_money,0)) '丢失理赔金额 Lost claim amount'
	,sum(if(plt.`duty_result`=2,pcn.claim_money,0)) '破损理赔金额 Damage claim amount'
	,sum(if(plt.`duty_result`=3,pcn.claim_money,0)) '超时效理赔金额 Over SLA claim amount'
FROM  `ph_bi`.`parcel_lose_task` plt
LEFT JOIN `ph_bi`.`parcel_lose_responsible` plr on plr.`lose_task_id` =plt.`id`
LEFT JOIN `ph_bi`.`sys_store` ss on ss.`id` = plr.`store_id`
LEFT JOIN `ph_bi`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
LEFT JOIN `ph_bi`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
LEFT JOIN ( SELECT
                    DATE_FORMAT(convert_tz(pi.`created_at`,'+00:00','+08:00'),'%Y%m%d') 揽收日期
                    ,pi.`ticket_pickup_store_id`
           			,COUNT( DISTINCT(pi.pno)) '揽件包裹Qty. of pick up parcel'
             FROM `ph_staging`.`parcel_info` pi
           	 where pi.`state`<9
           	 and DATE_FORMAT(convert_tz(pi.`created_at`,'+00:00','+08:00'),'%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
             GROUP BY 1,2
            ) pi on pi.揽收日期=DATE_FORMAT(plt.`updated_at`, '%Y%m%d') and pi.`ticket_pickup_store_id`= plr.`store_id`
LEFT JOIN ( SELECT
                    DATE_FORMAT(convert_tz(pi.`finished_at`, '+00:00','+08:00'),'%Y%m%d') 妥投日期
                    ,pi.`ticket_delivery_store_id`
           			,COUNT( DISTINCT(if(pi.state=5,pi.pno,null))) '妥投包裹Qty. of delivered parcel'
             FROM `ph_staging`.`parcel_info` pi
           	 where pi.`state`<9
           	 and DATE_FORMAT(convert_tz(pi.`finished_at`, '+00:00','+08:00'),'%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
             GROUP BY 1,2
            ) pi2 on pi2.妥投日期=DATE_FORMAT(plt.`updated_at`, '%Y%m%d') and pi2.`ticket_delivery_store_id`= plr.`store_id`
LEFT JOIN
(

    SELECT *
     FROM
           (
                 SELECT pct.`pno`
                               ,pct.`id`
                    ,pct.`finance_updated_at`
                             ,pct.`state`
                               ,pct.`created_at`
                        ,row_number() over (partition by pct.`pno` order by pct.`created_at` DESC ) row_num
             FROM `ph_bi`.parcel_claim_task pct
             where pct.state=6
           )t0
    WHERE t0.row_num=1
)pct on pct.pno=plt.pno
LEFT  join
        (
            select *
            from
                (
                select
                pcn.`task_id`
                ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) row_num
                from `ph_bi`.parcel_claim_negotiation pcn
                ) t1
            where t1.row_num=1
        )pcn on pcn.task_id =pct.`id`
LEFT JOIN (select pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value
           from (select
         pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value,
         row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
         from `ph_staging`.`parcel_route` pr
         where pr.`routed_at`>= CONVERT_TZ('2022-12-01','+08:00','+00:00')
         and pr.`route_action` in(
             select dd.`element`  from dwm.dwd_dim_dict dd where dd.remark ='valid')
                ) pr
         where pr.rn = 1
        ) pr on pr.pno=plt.`pno`
where plt.`state` in (6)
and plt.`operator_id` not in ('10000','10001')
and DATE_FORMAT(plt.`updated_at`, '%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
and plt.`updated_at` IS NOT NULL
GROUP BY 1,2,3,4
ORDER BY 1,2;





SELECT DISTINCT

	plt.created_at '任务生成时间 Task generation time'
    ,CONCAT('SSRD',plt.`id`) '任务ID Task ID'
	,plt.`pno`  '运单号 Waybill'
	,case plt.`vip_enable`
    when 0 then '普通客户'
    when 1 then 'KAM客户'
    end as '客户类型 Client type'
	,case plt.`duty_result`
	when 1 then '丢失'
	when 2 then '破损'
	when 3 then '超时效'
	end as '判责类型Judgement type'
	,t.`t_value` '原因 Reason'
	,plt.`client_id` '客户ID Client ID'
	,pi.`cod_amount`/100 'COD金额 COD'
	,plt.`parcel_created_at` '揽收时间 Pick up time'
	,cast(pi.exhibition_weight as double)/1000 '重量 Weight'
    ,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) '尺寸 Size'
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
    end  as '包裹品类 Item type'
	,pr.route_action 最后一条有效路由动作
	,wo.`order_no` '工单号 Ticket No.'
	,case  plt.`source`
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
		WHEN 11 THEN 'K-超时效'
		when 12 then 'L-高度疑似丢失'
		END AS '问题件来源渠道 Source channel of issue'
	,case plt.`state`
	when 5 then '无需追责'
	when 6 then '责任人已认定'
	end  as '状态 Status'
    ,plt.`fleet_stores` '异常区间 Abnormal interval'
    ,ft.`line_name`  '异常车线  Abnormal LH'
	,plt.`operator_id` '处理人 Handler'
	,plt.`updated_at` '处理时间 Handle time'
	,plt.`penalty_base` '判罚依据 Basis of penalty'
    ,case plt.`link_type`
    WHEN 0 THEN 'ipc计数后丢失'
    WHEN 1 THEN '揽收网点已揽件，未收件入仓'
    WHEN 2 THEN '揽收网点已收件入仓，未发件出仓'
    WHEN 3 THEN '中转已到件入仓扫描，中转未发件出仓'
    WHEN 4 THEN '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
    WHEN 5 THEN '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
    WHEN 6 THEN '分拨发件出仓扫描，目的地未到件入仓(集包)'
    WHEN 7 THEN '分拨发件出仓扫描，目的地未到件入仓(单件)'
    WHEN 8 THEN '目的地到件入仓扫描，目的地未交接,当日遗失'
    WHEN 9 THEN '目的地到件入仓扫描，目的地未交接,次日遗失'
    WHEN 10 THEN '目的地交接扫描，目的地未妥投'
    WHEN 11 THEN '目的地妥投后丢失'
    WHEN 12 THEN '途中破损/短少'
    WHEN 13 THEN '妥投后破损/短少'
    WHEN 14 THEN '揽收网点已揽件，未收件入仓'
    WHEN 15 THEN '揽收网点已收件入仓，未发件出仓'
    WHEN 16 THEN '揽收网点发件出仓到分拨了'
    WHEN 17 THEN '目的地到件入仓扫描，目的地未交接'
    WHEN 18 THEN '目的地交接扫描，目的地未妥投'
    WHEN 19 THEN '目的地妥投后破损短少'
    WHEN 20 THEN '分拨已发件出仓，下一站分拨未到件入仓(集包)'
    WHEN 21 THEN '分拨已发件出仓，下一站分拨未到件入仓(单件)'
    WHEN 22 THEN 'ipc计数后丢失'
    WHEN 23 THEN '超时效SLA'
    WHEN 24 THEN '分拨发件出仓到下一站分拨了'
	end as '判责环节 Judgement'
    ,case if(plt.state= 6,plt.`duty_type`,null)
	when 1 then '快递员100%套餐'
    when 2 then '仓7主3套餐(仓管70%主管30%)'
 	when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
    when 5 then  '快递员721套餐(快递员70%仓管20%主管10%)'
    when 6 then  '仓管721套餐(仓管70%快递员20%主管10%)'
    when 8 then  'LH全责（LH100%）'
    when 7 then  '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
    when 21 then  '仓7主3套餐(仓管70%主管30%)'
	end as '套餐 Penalty plan'
	,ss3.`name` '责任网点 Resposible DC'
	,case pct.state
                when 1 then '丢失件待协商'
                when 2 then '协商不一致'
                when 3 then '待财务核实'
                when 4 then '待财务支付'
                when 5 then '支付驳回'
                when 6 then '理赔完成'
                when 7 then '理赔终止'
                when 8 then '异常关闭'
                end as '理赔处理状态 Status of claim'
	,if(pct.state=6,pcn.claim_money,0) '理赔金额 Claim amount'
	,timestampdiff( hour ,plt.`created_at` ,plt.`updated_at`) '处理时效 Processing SLA'
	,DATE_FORMAT(plt.`updated_at`,'%Y%m%d') '统计日期 Statistical date'
	,plt.`remark` 备注




FROM  `ph_bi`.`parcel_lose_task` plt
LEFT JOIN `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno
LEFT JOIN `ph_bi`.`sys_store` ss on ss.id = pi.`ticket_pickup_store_id`
LEFT JOIN `ph_bi`.`sys_store` ss1 on ss1.id = pi.`dst_store_id`

LEFT JOIN `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
LEFT JOIN `ph_bi`.`fleet_time` ft on ft.`proof_id` =LEFT (plt.`fleet_routeids`,11)
LEFT JOIN `ph_bi`.`parcel_lose_stat_detail` pld on pld. `lose_task_id`=plt.`id`
LEFT JOIN `ph_bi`.`parcel_lose_responsible` plr on plr.`lose_task_id`=plt.`id`
LEFT JOIN `ph_bi`.`sys_store` ss3 on ss3.id = plr.store_id
LEFT JOIN `ph_bi`.`translations` t ON plt.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'
LEFT JOIN
(

    SELECT *
     FROM
           (
                 SELECT pct.`pno`
                               ,pct.`id`
                    ,pct.`finance_updated_at`
                             ,pct.`state`
                               ,pct.`created_at`
                        ,row_number() over (partition by pct.`pno` order by pct.`created_at` DESC ) row_num
             FROM `ph_bi`.parcel_claim_task pct

           )t0
    WHERE t0.row_num=1
)pct on pct.pno=plt.pno
LEFT  join
        (
            select *
            from
                (
                select
                pcn.`task_id`
                ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) row_num
                from `ph_bi`.parcel_claim_negotiation pcn
                ) t1
            where t1.row_num=1
        )pcn on pcn.task_id =pct.`id`
LEFT JOIN (select pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value
           from (select
         pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value,
         row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
         from `ph_staging`.`parcel_route` pr
         where pr.`routed_at`>= CONVERT_TZ('2022-12-01','+08:00','+00:00')
         and pr.`route_action` in(
             select dd.`element`  from dwm.dwd_dim_dict dd where dd.remark ='valid')
                ) pr
         where pr.rn = 1
        ) pr on pr.pno=plt.`pno`
where 1=1
and plt.`state` in (5,6)
and plt.`operator_id` not in ('10000','10001')
and DATE_FORMAT(plt.`updated_at`, '%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
GROUP BY 2
ORDER BY 2


;



select
    pcd.pno
    ,if(pi.returned = 0, '正向', '逆向') 包裹流向
    ,pi.customary_pno 原单号
    ,oi.cogs_amount/100 cog金额
    ,pi2.store_total_amount 总运费
    ,pi2.cod_amount/100 COD金额
    ,pi2.cod_poundage_amount COD手续费
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
    end as 当前包裹状态
from ph_staging.parcel_change_detail pcd
left join ph_staging.parcel_info pi on pcd.pno = pi.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
where
    pcd.new_value = 'PH19040F05'
    and pcd.created_at >= '2023-01-31 16:00:00' -- 23年1月后数据

;
select
    pi.store_total_amount
    ,pi.store_parcel_amount
    ,pi.cod_poundage_amount
    ,pi.material_amount
    ,pi.insure_amount
    ,pi.freight_insure_amount
    ,pi.label_amount
    ,pi.cod_amount
from ph_staging.parcel_info pi
where
    pi.pno = 'P18031DPPG5BQ'

;


select
    t.dated
    ,t.staff
    ,count(distinct t.pno) num
    ,group_concat(t.pno) pno
from tmpale.tmp_ph_test_0406 t
group by 1,2
;

select
    ss.name
    ,ss2.name name2
    ,count(ph.hno) num
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
left join ph_staging.sys_store ss2 on ss2.id = ph.claim_store_id
where
    ph.claim_store_id is not null
group by 1,2

;


with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
        ,case sh.parcel_type
            when 0 then '1,2'
            when 1 then '2,3'
            when 2 then '3'
        end type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2

                    ,t.type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
            and ph.state = 0
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
#             ,case  sh.parcel_type
#                 when 0 then 'A'
#                 when 1 then 'B'
#                 when 2 then 'C'
#             end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '${date}'
        group by 1,2
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period

;

# select * from ph_nbd.suspected_headless_parcel_detail_v1 sh where  sh.store_id = 'PH19280F01' and sh.arrival_date = '2023-03-29'
#
# ;
# select * from ph_staging.parcel_headless ph where date(convert_tz(ph.created_at,'+00:00', '+08:00')) = '2023-04-02' and ph.submit_store_id = 'PH19280F01';