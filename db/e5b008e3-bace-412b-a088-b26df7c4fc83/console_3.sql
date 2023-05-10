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
                 SELECT pct.出勤主管人数`pno`
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
    ,max(b.num) max_num
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
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '${date}'
        group by 1,2
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
group by 1,2,3
;

# select * from ph_nbd.suspected_headless_parcel_detail_v1 sh where  sh.store_id = 'PH19280F01' and sh.arrival_date = '2023-03-29'
#
# ;
# select * from ph_staging.parcel_headless ph where date(convert_tz(ph.created_at,'+00:00', '+08:00')) = '2023-04-02' and ph.submit_store_id = 'PH19280F01';
;










--

select
    acc.id
    ,case acc.`channel_type`
        when 1 then 'APP揽件任务'
        when 2 then 'APP派件任务'
        when 3 then 'APP投诉'
        when 4 then '短信揽件投诉'
        when 5 then '短信派件投诉'
        when 6 then '短信妥投投诉'
        when 7 then 'MS问题记录本'
        when 8 then '新增处罚记录'
        when 9 then 'KA投诉'
        when 10 then '官网投诉'
        when 12 then 'BS问题记录本'
     end as '投诉渠道'
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4   then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6   then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8   then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10   then '未提前电话联系客户'
        when 11   then '包裹破损 没有数据'
        when 12   then '未按照改约时间派件'
        when 13    then '未按订单带包装'
        when 14   then '不找零钱'
        when 15    then '客户通话记录内未看到员工电话'
        when 16    then '未经客户允许取消揽件任务'
        when 17   then '未给客户回执'
        when 18   then '拨打电话时间太短，客户来不及接电话'
        when 19   then '未经客户允许退件'
        when 20    then '没有上门'
        when 21    then '其他'
        when 22   then '未经客户同意改约揽件时间'
        when 23    then '改约的揽件时间和客户要求的时间不一致'
        when 24    then '没有按照改约时间揽件'
        when 25    then '揽件前未提前联系客户'
        when 26    then '答应客户揽件，但最终没有揽'
        when 27    then '很晚才打电话联系客户'
        when 28    then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29    then '因为超过当日截单时间，要求客户取消'
        when 30    then '声称不是自己负责的区域，要求客户取消'
        when 31    then '拨打电话时间太短，客户来不及接电话'
        when 32    then '不接听客户回复的电话'
        when 33    then '答应客户今天上门，但最终没有揽收'
        when 34    then '没有上门揽件，也没有打电话联系客户'
        when 35    then '货物不属于超大件/违禁品'
        when 36    then '没有收到包裹，且快递员没有联系客户'
        when 37    then '快递员拒绝上门派送'
        when 38    then '快递员擅自将包裹放在门口或他处'
        when 39    then '快递员没有按约定的时间派送'
        when 40    then '代替客户签收包裹'
        when   41   then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42    then '说话不礼貌/没有礼貌/不愿意服务'
        when   43    then '快递员抛包裹'
        when   44    then '报复/骚扰客户'
        when 45   then '快递员收错COD金额'
        when   46   then '虚假妥投'
        when   47    then '派件虚假留仓件/问题件'
        when 48   then '虚假揽件改约时间/取消揽件任务'
        when   49   then '抛客户包裹'
        when 50    then '录入客户信息不正确'
        when 51    then '送货前未电话联系'
        when 52    then '未在约定时间上门'
        when   53    then '上门前不电话联系'
        when   54    then '以不礼貌的态度对待客户'
        when   55    then '录入客户信息不正确'
        when   56    then '与客户发生肢体接触'
        when   57    then '辱骂客户'
        when   58    then '威胁客户'
        when   59    then '上门揽件慢'
        when   60    then '快递员拒绝上门揽件'
        when 61    then '未经客户同意标记收件人拒收'
        when 62    then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '投诉原因'
    ,case acc.`qaqc_callback_result`
        when 0 then '待回访'
        when 1 then '多次未联系上客户'
        when 2 then '误投诉'
        when 3 then '真实投诉，后接受道歉'
        when 4 then '真实投诉，后不接受道歉'
        when 5 then '真实投诉，后受到骚扰/威胁'
        when 6 then '没有快递员联系客户道歉'
        when 7 then '客户投诉回访结果'
        when 8 then '确认网点已联系客户道歉'
    end as '回访结果'
    ,case acc.callback_state
        when 0 then '待网点处理'
        when 1 then '待回访'
        when 2 then '已回访'
        when 3 then '沟通中'
        when 4 then '多次未联系上客户'
        when 20 then '未联系上'
    end 回访处理状态
from ph_bi.abnormal_customer_complaint acc
left join ph_bi.abnormal_message am on acc.abnormal_message_id = am.id
left join ph_staging.parcel_info pi on pi.pno = am.merge_column
left join ph_staging.ticket_pickup tp on tp.id = am.merge_column
join dwm.dwd_dim_bigClient bc on bc.client_id = coalesce(pi.client_id, tp.client_id) and bc.client_name = 'tiktok'
where
    acc.created_at >= '2023-03-01'



;


SELECT wo.`order_no` `工单编号`,
case wo.status
     when 1 then '未阅读'
     when 2 then '已经阅读'
     when 3 then '已回复'
     when 4 then '已关闭'
     end '工单状态',
pi.`client_id`  '客户ID',
wo.`pnos` '运单号',
case wo.order_type
          when 1 then '查找运单'
          when 2 then '加快处理'
          when 3 then '调查员工'
          when 4 then '其他'
          when 5 then '网点信息维护提醒'
          when 6 then '培训指导'
          when 7 then '异常业务询问'
          when 8 then '包裹丢失'
          when 9 then '包裹破损'
          when 10 then '货物短少'
          when 11 then '催单'
          when 12 then '有发无到'
          when 13 then '上报包裹不在集包里'
          when 16 then '漏揽收'
          when 50 then '虚假撤销'
          when 17 then '已签收未收到'
          when 18 then '客户投诉'
          when 19 then '修改包裹信息'
          when 20 then '修改 COD 金额'
          when 21 then '解锁包裹'
          when 22 then '申请索赔'
          when 23 then 'MS 问题反馈'
          when 24 then 'FBI 问题反馈'
          when 25 then 'KA System 问题反馈'
          when 26 then 'App 问题反馈'
          when 27 then 'KIT 问题反馈'
          when 28 then 'Backyard 问题反馈'
          when 29 then 'BS/FH 问题反馈'
          when 30 then '系统建议'
          when 31 then '申诉罚款'
          else wo.order_type
          end  '工单类型',
wo.`title` `工单标题`,
wo.`created_at` `工单创建时长`,
wor.`工单回复时间` `工单回复时间`,
wo.`created_staff_info_id` `发起人`,
wo.`closed_at` `工单关闭时间`,
wor.staff_info_id `回复人`,
ss1.name `创建网点名称`,
case
when ss1.`category` in (1,2,10,13) then 'sp'
              when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`created_store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`created_store_id`= '12' then 'QA&QC'
              when wo.`created_store_id`= '18' then 'Flash Home客服中心'
              when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`created_store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `创建网点/部门 `,
ss.name `受理网点名称`,
case when ss.`category` in (1,2,10,13) then 'sp'
              when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`store_id`= '12' then 'QA&QC'
              when wo.`store_id`= '18' then 'Flash Home客服中心'
              when wo.`store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `受理网点/部门 `,
pi. `last_cn_route_action` `最后一步有效路由`,
pi.last_route_time `操作时间`,
pi.last_store_name `操作网点`,
pi.last_staff_info_id `操作人员`

from `ph_bi`.`work_order` wo
left join dwm.dwd_ex_ph_parcel_details pi
on wo.`pnos` =pi.`pno` and  pick_date>=date_sub(curdate(),interval 2 month)
left join
    (select order_id,staff_info_id ,max(created_at) `工单回复时间`
     from `ph_bi`.`work_order_reply`
     group by 1,2) wor
on  wor.`order_id`=wo.`id`

left join   `ph_bi`.`sys_store`  ss on ss.`id` =wo.`store_id`
left join   `ph_bi`.`sys_store`  ss1 on ss1.`id` =wo.`created_store_id`
where wo.`created_at` >= date_sub(curdate() , interval 31 day)

;



SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,v2.出勤收派员人数
    ,v2.出勤仓管人数
    ,v2.出勤主管人数
    ,pr.妥投量
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
    ,dc.应派量
    ,pr3.交接量
    ,concat(round(pr3.交接量/dc.应派量,4)*100,'%') 交接率
    ,pr4.应盘点量
    ,pr5.实际盘点量
    ,pr4.应盘点量- pr5.实际盘点量 未盘点量
    ,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
    ,seal.应该集包包裹量
    ,seal.应集包且实际集包的总包裹量 实际集包量
    ,seal.集包率 集包率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
left join
    (
        select #出勤
            hi.`sys_store_id`
            ,count(distinct(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
            ,count(distinct(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
            ,count(distinct(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
        from `ph_bi`.`attendance_data_v2` v2
        left join `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
        join ph_staging.sys_store ss on ss.id = hi.sys_store_id and ss.category in (8,12)
        where
            v2.`stat_date`=date_sub(curdate(),interval 1 day)
            and
                (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
        group by 1
    )v2 on v2.`sys_store_id`=ss.`id`
left join
    (
        select #妥投
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 妥投量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('DELIVERY_CONFIRM')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr on pr.`store_id`=ss.`id`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            )pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') >= date_sub(curdate(),interval 1 day)
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`
left join
    (
        select #应派
            dc.`store_id`
            ,count(distinct(dc.`pno`)) 应派量
        from `ph_bi`.`dc_should_delivery_today` dc
        join ph_staging.sys_store ss on ss.id = dc.store_id and ss.category in (8,12)
        where
            dc.`stat_date`= date_sub(curdate(),interval 1 day)
        group by 1
    ) dc on dc.`store_id`=ss.`id`
left join
    (
        select #交接
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 交接量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr3 on pr3.`store_id`=ss.`id`
left join
    (
        select #应盘
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应盘点量
        from
            (
                select #最后一条有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`state`
                    ,pr.`routed_at`
                from
                    (
                        select
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`state`
                             ,pr.`routed_at`
                             ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                        from `ph_staging`.`parcel_route` pr
                        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                        where
                            DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
            left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
            left join
                (
                    select #车货关联出港
                        pr.`pno`
                        ,pr.`store_id`
                        ,pr.`routed_at`
                    from `ph_staging`.`parcel_route` pr
                    join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                    where
                        pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
            and pi.state in (1,2,3,4,6)
        group by 1
    )pr4 on pr4.`store_id`=ss.`id`
left join
    (
        select #实际盘点
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际盘点量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        GROUP BY 1
    )pr5 on pr5.`store_id`=ss.`id`
left join
    (
        SELECT
            a.store_id
            ,date(a.van_arrive_phtime) AS '到港日期'
            ,SUM(a.hub_should_seal) AS '应该集包包裹量'
            ,SUM(IF (a.hub_should_seal = 1 AND a.seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
            ,SUM(IF (a.hub_should_seal = 1  AND a.seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
        FROM
            (
                SELECT
                    pi.pno
                    , pss.store_name AS 'hub_name'
                    ,pss.store_id
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                            8 HOUR) AS 'van_arrive_phtime'
                    , pss.arrival_pack_no
                    , pack.es_unseal_store_name
                    ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
            -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                         AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
                    , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
                FROM ph_staging.parcel_info pi
                JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
                    AND pi.pno = pss.pno
                    AND pss.store_category IN (8, 12)
                    AND pss.store_name != '66 BAG_HUB_Maynila'
                    AND pss.store_name NOT REGEXP '^Air|^SEA'
                LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
                WHERE
                    1 = 1
                    AND pi.state < 9
                    AND pi.returned = 0
            ) a
        GROUP BY 1, 2
        ORDER BY 1, 2
    ) seal on seal.store_id = ss.id
group by 1,2,3,4
order by 2;


select
    json_table()
from ph_staging.parcel_route pr
left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
where
    pr.route_action = 'TAKE_PHOTO'
    and pr.routed_at > date_sub(curdate(), interval 10 day)

;
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
)
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
    ) arr on arr.pno = a.pno

;



select
    pi.pno
    ,if(pi.state = 5, ss.name, null) 妥投网点
    ,pi.state
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX')
#     or pi.recent_pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX')

union

select
    pi.recent_pno pno
    ,if(pi.state = 5, ss.name, null) 妥投网点
    ,pi.state
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.recent_pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX')


;

with a as
(
    select
        a.pno
        ,a.pack_no
        ,a.last_valid_store_id
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,plt.last_valid_store_id
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

        select
            a.pno
            ,a2.pack_no
            ,ss.name
            ,a2.ratio
            ,a2.seal_num
        from a
        left join
            (
                select
                    psd.pack_no
                    ,count(psd.pno) seal_num
                    ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
                from ph_staging.pack_seal_detail psd
                join
                    (
                        select
                            a.pack_no
                        from a
                        group by 1
                    ) a1 on a1.pack_no = psd.pack_no
                left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
                group by 1
            ) a2 on a2.pack_no = a.pack_no
        left join ph_staging.sys_store ss on ss.id = a.last_valid_store_id
        where
            a2.ratio = 1
            and a2.seal_num > 1


;



select
    *
from dw_dmd.parcel_store_stage_new pssn
where
    pssn.van_arrived_at >= date_sub(curdate(), interval 32 hour )
    and pssn.van_arrived_at < date_sub(curdate(), interval 8 hour)
    and pssn.arrival_pack_no is not null
    and pssn.van_arrived_at is null
;









with t as
(
    select
        pcol.task_id
        ,pcol.action
        ,pcol.operator_id
        ,pcol.created_at
    from ph_bi.parcel_claim_task pct
    left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
    where
        pct.created_at >= '2023-01-01'
        and pct.state = 6
)

select
    pct.id 理赔任务ID
    ,pct.client_id 客户ID
    ,pct.pno 单号
    ,json_unquote(json_extract(pcn.neg_result,'$.money')) 理赔金额
    ,t4.created_at 电话号码不对时间
    ,t5.created_at 客户不接电话时间
    ,t1.created_at 待重新协商时间
    ,t2.created_at 审核通过时间
    ,t2.operator_id 审核通过员工
    ,t3.created_at 已联系时间
    ,t3.created_at 已联系员工
from ph_bi.parcel_claim_task pct
left join
    (
        select
            pcn.task_id
            ,pcn.neg_result
            ,row_number() over (partition by pcn.task_id order by pcn.created_at desc ) rk
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.created_at >= '2023-01-01'
            and pct.state = 6
    ) pcn on pcn.task_id = pct.id and pcn.rk = 1
left join t t1 on t1.task_id = pct.id and t1.action = 7 -- 待重新协商
left join t t2 on t2.task_id = pct.id and t2.action = 14 -- 审核通过
left join t t3 on t3.task_id = pct.id and t3.action = 21 -- 已联系
left join t t4 on t4.task_id = pct.id and t4.action = 19 -- 电话号码不对
left join t t5 on t5.task_id = pct.id and t5.action = 18 -- 客户不接电话
where
    pct.created_at >= '2023-01-01'
    and pct.state = 6

















;


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
group by 1




;
with t as
    (
        select
            pi.pno
            ,pi.client_id
            ,pi2.ticket_pickup_store_id
            ,ss.name as ticket_pickup_store_name
            ,convert_tz(pi2.created_at, '+00:00', '+08:00') 退件时间
        from ph_staging.parcel_info pi
        join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
        join ph_staging.sys_store ss on ss.id =pi2.ticket_pickup_store_id
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        where
            pi.state = 7
            and pi2.created_at >=date_sub(current_date,interval 37 day)
            and pi2.created_at < current_time
    )

select
    t.pno
    ,t.ticket_pickup_store_name
    ,pr.store_name
    ,pr.staff_info_id
    ,pr.staff_info_name
    ,pr.remark 待退件备注
    ,mark.remark 最后一次包裹备注
    ,job_name 职位
    ,sd.name 部门
    ,case
        when xs.pno is not null then '协商退件'
        when di.pno is not null and xs.pno is null then '拒收直接退回'
#       when xs.pno is null and di.pno is null and (pcr.remark != 'Wait for replace order and return' or dai.pno is not null ) then '三次派送失败退件'
        when xs.pno is null and di.pno is null and sd.name in ('Flash Express Customer Service','Overseas Business Project') then 'MS操作中断运输并退回'
        when xs.pno is null and di.pno is null and pr.staff_info_id in ('10000','10001') then '三次派送失败退件'
        end 退件原因
    ,if(di2.pno is not null , '是', '否') 是否有收件人拒收派件标记
    ,dai.delivery_attempt_num 尝试派送天数
    ,t.退件时间
    ,ssd.sla as 时效天数
    ,ssd.end_date as 包裹普通超时时效截止日_整体
    ,ssd.end_7_date as 包裹严重超时时效截止日_整体
#     ,if(xs.pno is not null, 'y', 'n') 是否协商退件
#     ,if(di.pno is not null and xs.pno is null , 'y', 'n') 是否策略直接退回
#     ,if(xs.pno is null and di.pno is null and (pcr.remark != 'Wait for replace order and return' or dai.pno is not null ), '三次派送失败退件', 'MS操作中断运输并退回') 是否尝试三次派送失败退件
from t
left join
    (
        select
            di.pno
            ,cdt.operator_id
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        where
            cdt.negotiation_result_category in (3,4)
            and cdt.operator_id not in ('10000','10001')
        group by 1
    ) xs on xs.pno = t.pno
left join
    (
        select
            di.pno
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        left join ph_staging.ka_profile kp on kp.id = t.client_id
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        where
            di.diff_marker_category in (2,17)
            and kp.reject_return_strategy_category = 2 -- 退件策略：直接退回
            and cdt.negotiation_result_category in (3,4)
            and cdt.operator_id in ('10000','10001')
        group by 1
    ) di on di.pno = t.pno
# left join
#     (
#         select
#             pcr.pno
#             ,pcr.remark
#         from ph_staging.parcel_change_record pcr
#         join t on t.pno = pcr.pno
#         where
#             pcr.change_type = 0
#     ) pcr on pcr.pno = t.pno
left join
    (
        select
            dai.pno
            ,dai.delivery_attempt_num
        from ph_staging.delivery_attempt_info dai
        join t on dai.pno = t.pno
        where
            dai.delivery_attempt_num >= 3
    ) dai on dai.pno = t.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on ssd.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
             ,pr.store_name
            ,pr.staff_info_name
            ,pr.remark
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.pno
        where
            pr.route_action = 'PENDING_RETURN'
    ) pr on pr.pno = t.pno and pr.rn = 1
left join
    (
        select
            td.pno
        from ph_staging.ticket_delivery_marker tdm
        left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
        join t on td.pno = t.pno
        where
            tdm.marker_id in (2,17)
        group by 1
    ) di2 on di2.pno = t.pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_bi.sys_department sd on sd.id = hsi.sys_department_id
left join
    (
        select
            pr.pno
            ,pr.remark
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn2
        from ph_staging.parcel_route pr
        join t on pr.pno = t.pno
        where
            pr.route_action = 'MANUAL_REMARK'
    ) mark on mark.pno = t.pno and mark.rn2 = 1
;











