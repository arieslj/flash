select
    distinct
    pi.pno
    ,pi.dst_phone `收件人手机号`
    ,if(di.diff_marker_category ='31','是','否') `是否错分件`
    ,if(pi.ticket_delivery_store_id is null,'不确定',if(dif.store_id =pi.ticket_delivery_store_id,'虚假错分','非虚假错分')) `是否虚假错分`
    ,oi.dst_province_code `订单省`
    ,oi.dst_city_code `订单城市`
    ,oi.dst_district_code `订单乡`
    ,oi.dst_postal_code `订单邮编`
    ,pi.dst_province_code `目的地省`
    ,pi.dst_city_code `目的地城市`
    ,pi.dst_district_code `目的地乡`
    ,pi.dst_postal_code `目的地邮编`
    ,dif.store_id `首次上报错分网点ID`
    ,pi.ticket_delivery_store_id `最终派件网点ID`
    ,pi.dst_store_id `目的地网点ID`
    ,oi.`dst_detail_address` `订单详细地址`
    ,pi.dst_detail_address `目的地详细地址`
    ,pi.ticket_delivery_staff_lat `妥投坐标-纬度`
    ,pi.ticket_delivery_staff_lng `妥投坐标-经度`
    ,pi.created_at
    ,pi.finished_at
from
    (
    select * from `parcel_info`
    WHERE `created_at`  >= '2024-03-25' and `created_at` < '2024-03-28'
)pi
LEFT JOIN  `order_info` oi on oi.`pno` = pi.pno
left join (select * from `diff_info`
where  diff_marker_category ='31'
)di on pi.pno=di.pno
JOIN (SELECT * from (select pno, diff_marker_category ,store_id ,created_at ,row_number() over(partition by pno,diff_marker_category order by created_at) as rnf
from `diff_info`
where  diff_marker_category ='31') tmp where rnf=1
) dif on pi.pno=dif.pno

;


select
    pi.pno
    ,pi.client_id
    ,pi.dst_phone `收件人手机号`
    ,if(pi.ticket_delivery_store_id is null,'不确定',if(a1.store_id = pi.ticket_delivery_store_id,'虚假错分','非虚假错分')) `是否虚假错分`
    ,oi.dst_province_code `订单省`
    ,oi.dst_city_code `订单城市`
    ,oi.dst_district_code `订单乡`
    ,oi.dst_postal_code `订单邮编`
    ,pi.dst_province_code `目的地省`
    ,pi.dst_city_code `目的地城市`
    ,pi.dst_district_code `目的地乡`
    ,pi.dst_postal_code `目的地邮编`
    ,a1.store_id `首次上报错分网点ID`
    ,pi.ticket_delivery_store_id `最终派件网点ID`
    ,pi.dst_store_id `目的地网点ID`
    ,oi.`dst_detail_address` `订单详细地址`
    ,pi.dst_detail_address `目的地详细地址`
    ,pi.ticket_delivery_staff_lat `妥投坐标-纬度`
    ,pi.ticket_delivery_staff_lng `妥投坐标-经度`
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null) 妥投时间
    ,di.di_cnt 提交错分次数
from
    (
        select
            a.*
        from
            (
                select
                    di.pno
                    ,diff_marker_category
                    ,di.store_id
                    ,di.created_at
                    ,row_number() over (partition by di.pno order by di.created_at) rk
                from fle_staging.diff_info di
                where
                    di.diff_marker_category = 31
                    and di.created_at > '2024-03-31 17:00:00'
                    and di.created_at < '2024-04-15 17:00:00'
            ) a
        where
            a.rk = 1
    ) a1
left join fle_staging.parcel_info pi on pi.pno = a1.pno
left join fle_staging.order_info oi on oi.pno = a1.pno
left join
    (
        select
            di.pno
            ,count(distinct di.id) di_cnt
        from fle_staging.diff_info di
        where
            di.diff_marker_category = 31
            and di.created_at > '2024-03-31 17:00:00'
            and di.created_at < '2024-04-15 17:00:00'
        group by 1
    ) di on di.pno = a1.pno


;



SELECT *
FROM fle_staging.store_receivable_bill_detail t
WHERE state = 0 and receivable_type_category = 5 and staff_info_id in ('653546','82001','668274','604926','83053','656534','638807','684255','19194','680882','653416','638343','674186','670036','650817','681367','645806','26513','678722','22696','620932','682249','2000318','612897','42013','685613','684000','686070','2000526','679831','674127','681265','684674','647877','686018','4182779','2001134','670867','680965','623556','2000651','633802','4189703','2000690','674663','678822','681166','679569','688510','675133','2000266','683915','4195813','681632','612753','638289','667062','660903','607589','658015','683450','673133','681190','663863','666353','671041','667862','681721','686548','682542','2001845','686409','678402','686302','76096','66657','684894','683709','2001323','681233','684215','686582','657753','684124','685743','680500','2002373','682352','681656','2000729','2002076','674136','685200','2002034','685065','605624','671493','4223970','51837','2002380','2001355','674951','660897','684066','4227186','668875','680615','646892','673906','2003082','638745','653518','688032','2000809','689418','613224','2002894','80980','2002687','2001702','660732','687616','620885','688353','2004812','2002509','2004267','615093','2004265','672989','19079','2004546','2001582','2001239','649613','70515','680913','657422')


;


select
    count(if(oi.cogs_amount > 0, oi.id, null)) total
    ,count(if(oi.cogs_amount > 50000, oi.id, null)) 500_num
    ,count(if(oi.cogs_amount = 0 or oi.cogs_amount is null, oi.id, null)) 双0
from fle_staging.order_info oi
where
    oi.cod_amount is null
    and oi.state = 2
    and oi.created_at > '2024-04-30 16:00:00'

;

select
    hjt.job_name `岗位`
    ,count(distinct mw.id) 数量
from backyard_pro.message_warning mw
left join bi_pro.hr_staff_info  hst on hst.staff_info_id = mw.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hst.job_title
where
    mw.created_at >= '2024-04-01'
    and mw.created_at < '2024-05-01'
    and mw.is_delete = 0
group by 1


;


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
group by 1,2


;



 -- 寄件人
select pi.src_phone, di.diff_marker_category, count(*)
from fle_staging.parcel_info pi
         left join fle_staging.diff_info di on pi.pno = di.pno
         left join fle_staging.customer_diff_ticket cdt on di.id = cdt.diff_info_id
where di.created_at > '2024-03-31 17:00:00'
  and di.created_at <= '2024-04-30 16:59:59'
group by pi.src_phone, di.diff_marker_category
order by count(*) desc;

-- 收件人
select pi.src_phone, di.diff_marker_category, count(*)
from fle_staging.parcel_info pi
         left join fle_staging.diff_info di on pi.pno = di.pno
         left join fle_staging.customer_diff_ticket cdt on di.id = cdt.diff_info_id
where di.created_at > '2024-03-31 17:00:00'
  and di.created_at <= '2024-04-30 16:59:59'
group by pi.src_phone, di.diff_marker_category
order by count(*) desc;


select
    t.pno
    ,pr.staff_info_id 妥投员工工号
    ,pr.store_name 妥投站点
from rot_pro.parcel_route pr
join tmpale.tmp_th_pno_lj_0612 t on t.pno = pr.pno
where
    pr.route_action = 'DELIVERY_CONFIRM'
;

select
    min(pi.created_at)
    ,count(1)
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0612 t on t.pno = pi.pno


;


select
    pr.pno
    ,pr.extra_value
from rot_pro.parcel_route pr
where
    pr.route_action = 'STORE_KEEPER_UPDATE_WEIGHT'
   -- and pr.pno = 'THT5003ZGMJC4Z'
  --  and json_extract(pr.extra_value, '$.routeExtraId') is not null
    and pr.routed_at > '2024-03-01'

;

select
    pr.pno
from rot_pro.parcel_route pr
join tmpale.tmp_th_pno_lj_0617 t on t.pno = pr.pno
where
    pr.routed_at > '2024-04-25 17:00:00'
  --  and pr.routed_at < '2024-05-31 17:00:00'
    and pr.route_action = 'TAKE_PHOTO'
    and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
   -- and json_extract(pr.extra_value, '$.routeExtraId') is not null


;




with t as
    (
        select
            plt.pno
            ,plt.id
            ,plt.client_id
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end as 客户类型
            ,plt.link_type
            ,plt.source
            ,greatest(ifnull(oi.cogs_amount/100, 0), ifnull(oi.cod_amount/100, 0)) parcel_value
            ,coalesce(cast(oi.`ka_warehouse_id` as char),concat(oi.client_id,'-',trim(oi.`src_phone`),'-',trim(oi.src_detail_address))) seller
        from bi_pro.parcel_lose_task plt
        left join fle_staging.parcel_info pi on plt.pno = pi.pno
        left join fle_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join fle_staging.ka_profile kp on kp.id = plt.client_id
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
        where
            plt.updated_at >= '2024-05-01'
            and plt.updated_at < '2024-06-01'
            and plt.state = 6
            and plt.duty_result = 1
            and plt.penalties > 0
    )
, a as
    (
        select
            t1.id
            ,t1.pno
            ,pcol.created_at
            ,date_sub(pcol.created_at, interval 8 hour) route_at
        from bi_pro.parcel_cs_operation_log pcol
        join t t1 on t1.id = pcol.task_id
        where
            pcol.created_at > '2024-04-01'
            and pcol.action = 4
    )
select
    t1.pno
    ,t1.client_id
    ,t1.parcel_value
    ,t1.seller
    ,t1.`客户类型` 平台
    ,case t1.source
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
    ,plr.duty_store 责任网点
    ,case t1.`link_type`
        when 0 then 'ipc计数后丢失'
        when 1 then '揽收网点已揽件，未收件入仓'
        when 2 then '揽收网点已收件入仓，未发件出仓'
        when 3 then '中转已到件入仓扫描，中转未发件出仓'
        when 4 then '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
        when 5 then '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
        when 6 then '分拨发件出仓扫描，目的地未到件入仓(集包)'
        when 7 then '分拨发件出仓扫描，目的地未到件入仓(单件)'
        when 8 then '目的地到件入仓扫描，目的地未交接,当日遗失'
        when 9 then '目的地到件入仓扫描，目的地未交接,次日遗失'
        when 10 then '目的地交接扫描，目的地未妥投'
        when 11 then '目的地妥投后丢失'
        when 12 then '途中破损/短少'
        when 13 then '妥投后破损/短少'
        when 14 then '揽收网点已揽件，未收件入仓'
        when 15 then '揽收网点已收件入仓，未发件出仓'
        when 16 then '揽收网点发件出仓到分拨了'
        when 17 then '目的地到件入仓扫描，目的地未交接'
        when 18 then '目的地交接扫描，目的地未妥投'
        when 19 then '目的地妥投后破损短少'
        when 20 then '分拨已发件出仓，下一站分拨未到件入仓(集包)'
        when 21 then '分拨已发件出仓，下一站分拨未到件入仓(单件)'
        when 22 then 'ipc计数后丢失'
        when 23 then '超时效sla'
        when 24 then '分拨发件出仓到下一站分拨了'
	end 判责环节
    ,a3.ub_cnt 解锁次数
    ,a3.cn_element 解锁路由
    ,pri.reason 打印面单原因次数
from t t1
left join
    (
        select
            a2.pno
            ,count(distinct a2.created_at) ub_cnt
            ,group_concat(distinct ddd.cn_element) cn_element
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            a1.*
                            ,pr.route_action
                            ,pr.routed_at
                            ,row_number() over (partition by a1.pno order by pr.routed_at) rk
                        from rot_pro.parcel_route pr
                        join a a1 on a1.pno = pr.pno
                        where
                            pr.routed_at > '2024-04-30 17:00:00' -- 闪速认定最新有效路由
                            and pr.routed_at > a1.route_at
                            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                    ) a1
                where
                    a1.rk = 1
            ) a2
        left join dwm.dwd_dim_dict ddd on ddd.element = a2.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        group by 1
    ) a3 on a3.pno = t1.pno
left join
    (
        select
            a.pno
            ,group_concat(distinct concat(a.reason, a.pr_cnt)) reason
        from
            (
                select
                    t1.pno
                    ,case
                        when json_extract(extra_value, '$.parcelScanManualImportCategory') = 0 then '面单条码褶皱/破损'
                        when json_extract(extra_value, '$.parcelScanManualImportCategory') = 99 then '其他'
                        else '无'
                    end reason
                    ,count(pr.id) pr_cnt
                from rot_pro.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > '2023-05-31 16:00:00'
                    and pr.route_action = 'PRINTING'
                group by 1,2
            ) a
        group by 1
    ) pri on pri.pno = t1.pno
left join
    (
        select
            t1.id
            ,group_concat(distinct ss.name) duty_store
        from bi_pro.parcel_lose_responsible plr
        join t t1 on t1.id = plr.lose_task_id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plr.created_at > '2024-01-31 16:00:00'
        group by 1
    ) plr on plr.id = t1.id

;



select
    count(distinct di.pno) 上报丢失问题件量
    ,count(distinct if(pr.pno is not null, pr.pno, null)) 解锁量
from fle_staging.diff_info di
left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join rot_pro.parcel_route pr on pr.pno = di.pno and pr.routed_at > '2024-04-30 17:00:00' and pr.route_action = 'CONTINUE_TRANSPORT' and pr.remark = 'SS System operate auto unlock parcel'
where
    di.diff_marker_category = 22
    and di.created_at > '2024-04-30 17:00:00'
    and di.created_at < '2024-05-31 17:00:00'

   -- and cdt.negotiation_result_category = 5



;





with t as
    (
        select
            a.*
        from
            (
                select
                    a2.*
                    ,row_number() over (partition by a2.pno order by a2.result_rank desc ) rk
                from
                    (
                        select
                            a1.pno
                            ,a1.client_id
                            ,case
                                when bc.client_id is not null then bc.client_name
                                when bc.client_id is null and kp.id is not null then 'KA'
                                else 'GE'
                            end client_name
                            ,case
                                when a1.dutyresult = 3 then 3
                                when a1.dutyresult = 1 then 2
                                when a1.dutyresult = 2 then 1
                            end result_rank
                            ,a1.parcel_created_at
                            ,a1.updated_at
                            ,a1.source
                            ,a1.link_type
                            ,a1.duty_reasons
                        from
                            (
                                select
                                    pct.pno
                                    ,pct.client_id
                                    ,pct.parcel_created_at
                                    ,'3' dutyresult
                                    ,pct.updated_at
                                    ,'' link_type
                                    ,pct.source
                                    ,'' duty_reasons
                                from bi_pro.parcel_claim_task pct
                                left join fle_staging.parcel_info pi on pi.pno = pct.pno and pi.created_at > date_sub(curdate(), interval 3 month)
                                left join bi_pro.parcel_claim_task pct2 on pct2.pno = pi.customary_pno and pct.source = 11 and pct2.created_at > date_sub('${sdate}', interval 2 month)
                                where
                                    pct.source = 11
                                    and pct.created_at > '${sdate}'
                                    and pct.created_at < date_add('${edate}', interval 1 day)
                                    and pct2.pno is null

                                union all

                                select
                                    plt.pno
                                    ,plt.client_id
                                    ,plt.parcel_created_at
                                    ,plt.duty_result
                                    ,plt.updated_at
                                    ,plt.link_type
                                    ,plt.source
                                    ,plt.duty_reasons
                                from bi_pro.parcel_lose_task plt
                                where
                                    plt.state = 6
                                    and plt.source != 11
                                    and plt.duty_result in (1,2)
                                    and plt.penalties > 0
                                    and plt.updated_at > '${sdate}'
                                    and plt.updated_at < date_add('${edate}', interval 1 day)
                            ) a1
                        left join fle_staging.ka_profile kp on kp.id = a1.client_id
                        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a1.client_id
                    ) a2
            ) a
        where
            a.rk = 1
    )
, val as
    (
        select
            t1.pno
            ,t1.client_name
            ,t1.client_id
            ,t1.result_rank
            ,p1.state
            ,case
                when t1.client_name = 'tiktok' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 2000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_name = 'tiktok' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 2000 then 2000
                when t1.client_name = 'lazada' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 6000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_name = 'lazada' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 6000 then 6000
                when t1.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0771','AA0731','AA0657','AA0707','AA0736','AA0838') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 3000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0771','AA0731','AA0657','AA0707','AA0736','AA0838') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 3000 then 3000
                when t1.client_id in ('AA0572', 'AA0574', 'AA0606', 'AA0612') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 15000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_id in ('AA0572', 'AA0574', 'AA0606', 'AA0612') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 15000 then 15000
                when t1.client_name = 'shopee' and t1.client_id not in ('AA0572', 'AA0574', 'AA0606', 'AA0612','AA0386','AA0425','AA0427','AA0569','AA0771','AA0731','AA0657','AA0707','AA0736','AA0838') then if(coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) > 2000, 2000, coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100))
                when t1.client_id = 'AA0306' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 5000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_id = 'AA0306' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 5000 then 5000
                when t1.client_name in ('KA','GE') and t1.client_id != 'AA0306'  and greatest(ifnull(coalesce(oi.cogs_amount/100, p2.cod_amount/100), 0), ifnull(oi.insure_declare_value/100, 0)) < 2000 and greatest(ifnull(coalesce(oi.cogs_amount/100, p2.cod_amount/100), 0), ifnull(oi.insure_declare_value/100, 0)) > 0 then greatest(ifnull(coalesce(oi.cogs_amount/100, p2.cod_amount/100), 0), ifnull(oi.insure_declare_value/100, 0))
                else 1018
            end parcel_value
            ,p2.store_total_amount/100 store_total_amount
            ,p2.cod_amount/100 cod
            ,oi.cogs_amount/100 cogs
        from t t1
        left join fle_staging.parcel_info p1 on p1.pno = t1.pno and p1.created_at > date_sub('${sdate}', interval 3 month)
        left join fle_staging.parcel_info p2 on p2.pno = if(p1.returned = 1, p1.customary_pno, p1.pno) and p2.created_at > date_sub('${sdate}', interval 2 month)
        left join fle_staging.order_info oi on oi.pno = if(p1.pno is null, t1.pno, p2.pno)
    )
, cla as
    (
        select
            a1.*
        from
            (
                select
                    pct.pno
                    ,json_extract(pcn.neg_result,'$.money') claim_value
                    ,row_number() over (partition by pcn.task_id order by pcn.created_at desc) rk
                from bi_pro.parcel_claim_task pct
                join t t1 on t1.pno = pct.pno
                left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct.id
                where
                    pct.created_at > date_sub('${sdate}', interval 4 month)
                    and pct.state = 6
            ) a1
        where
            a1.rk = 1
    )
, pcm as
    (
        select
            pct.pno
            ,pct.claims_amount/100 claim_money
        from fle_staging.pickup_claims_ticket pct
        join t t1 on t1.pno = pct.pno
        where
            pct.pickup_at > date_sub('${sdate}', interval 3 month)
            and pct.state = 6
            and pct.claims_type_category = 1
    )
select
    t1.parcel_created_at 揽件时间
    ,t1.pno 运单号
    ,t1.client_name 客户类型
    ,t1.client_id 客户ID
    ,v1.cod COD
    ,v1.cogs COGS
    ,v1.store_total_amount 运费
    ,coalesce(c1.claim_value, pc.claim_money, v1.parcel_value) 预估赔付金额
    ,coalesce(c1.claim_value, pc.claim_money) 实际赔付金额
    ,if(t1.result_rank = 3, sla.updated_at, t1.updated_at) 判责时间
    ,case t1.result_rank
        when 3 then '超时效'
        when 2 then '丢失'
        when 1 then '破损'
    end 判责类型
    ,t.t_value 原因
    ,case t1.source
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
    end 问题来源
    ,case if(t1.result_rank = 3, sla.link_type, t1.link_type)
        when 0 then 'ipc计数后丢失'
        when 1 then '揽收网点已揽件，未收件入仓'
        when 2 then '揽收网点已收件入仓，未发件出仓'
        when 3 then '中转已到件入仓扫描，中转未发件出仓'
        when 4 then '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
        when 5 then '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
        when 6 then '分拨发件出仓扫描，目的地未到件入仓(集包)'
        when 7 then '分拨发件出仓扫描，目的地未到件入仓(单件)'
        when 8 then '目的地到件入仓扫描，目的地未交接,当日遗失'
        when 9 then '目的地到件入仓扫描，目的地未交接,次日遗失'
        when 10 then '目的地交接扫描，目的地未妥投'
        when 11 then '目的地妥投后丢失'
        when 12 then '途中破损/短少'
        when 13 then '妥投后破损/短少'
        when 14 then '揽收网点已揽件，未收件入仓'
        when 15 then '揽收网点已收件入仓，未发件出仓'
        when 16 then '揽收网点发件出仓到分拨了'
        when 17 then '目的地到件入仓扫描，目的地未交接'
        when 18 then '目的地交接扫描，目的地未妥投'
        when 19 then '目的地妥投后破损短少'
        when 20 then '分拨已发件出仓，下一站分拨未到件入仓(集包)'
        when 21 then '分拨已发件出仓，下一站分拨未到件入仓(单件)'
        when 22 then 'ipc计数后丢失'
        when 23 then '超时效sla'
        when 24 then '分拨发件出仓到下一站分拨了'
	end 判责环节
    ,if(t1.result_rank = 3, sla.duty_store, ld.duty_store) 责任网点
    ,if(t1.result_rank = 3, sla.duty_category, ld.duty_category) 责任组织类型
    ,case v1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 包裹状态
    ,case
        when t1.result_rank = 3 and plt.pno is not null then '丢失'
        when t1.result_rank = 3 and plt.pno is null and pi2.state = 8 then '拍卖仓妥投'
        when t1.result_rank = 3 and pi2.state = 5 and pi2.cod_enabled = 1 then 'COD妥投'
        when t1.result_rank = 3 and pi2.state not in (5,7,8,9) then '未达终态'
    end '当前环节（超时效）'
    ,case
        when t1.result_rank = 2 and pct.pno is not null then '寄件人理赔'
        when t1.result_rank = 2 and pct.pno is null then '网点理赔'
        when t1.result_rank = 1 and pct3.source in (4,6) and pct3.claim_target = 2 then '收件人理赔'
        when t1.result_rank = 1 and pct3.source in (4,6) and pct3.claim_target = 1 then '寄件人理赔'
        when t1.result_rank = 1 and pct3.source in (9,10) then '仅外包装破损'
    end '理赔对象'
    ,if(srb.pno is not null, '否', '是') COD是否回款
from t t1
left join val v1 on v1.pno = t1.pno
left join cla c1 on c1.pno = t1.pno
left join pcm pc on pc.pno = t1.pno
left join
    (
        select
            t1.pno
            ,plt.link_type
            ,plt.duty_reasons
            ,plt.updated_at
            ,group_concat(distinct ss.name) duty_store
            ,group_concat(distinct case ss.category when 1 then 'SP' when 2 then 'DC' when 4 then 'SHOP' when 5 then 'SHOP' when 6 then 'FH' when 7 then 'SHOP' when 8 then 'Hub' when 9 then 'Onsite' when 10 then 'BDC' when 11 then 'fulfillment' when 12 then 'B-HUB' when 13 then 'CDC' when 14 then 'PDC' end) duty_category
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno and t1.result_rank = 3
        left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.source = 11
            and plt.state = 6
            and plt.parcel_created_at > date_sub('${sdate}', interval 3 month)
        group by 1,2,3
    ) sla on sla.pno = t1.pno
left join
    (
        select
            t1.pno
            ,group_concat(distinct ss.name) duty_store
            ,group_concat(distinct case ss.category when 1 then 'SP' when 2 then 'DC' when 4 then 'SHOP' when 5 then 'SHOP' when 6 then 'FH' when 7 then 'SHOP' when 8 then 'Hub' when 9 then 'Onsite' when 10 then 'BDC' when 11 then 'fulfillment' when 12 then 'B-HUB' when 13 then 'CDC' when 14 then 'PDC' end) duty_category
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno and t1.result_rank in (1,2)
        left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.source != 11
            and plt.state = 6
            and plt.parcel_created_at > date_sub('${sdate}', interval 3 month)
        group by 1
    ) ld on ld.pno = t1.pno
left join bi_pro.translations t on if(t1.result_rank = 3, sla.duty_reasons, t1.duty_reasons) = t.t_key AND t.`lang` = 'zh-CN'
left join fle_staging.parcel_info pi2 on pi2.pno = t1.pno and pi2.created_at > date_sub('${sdate}', interval 2 month)
left join bi_pro.parcel_lose_task plt on plt.pno = t1.pno and plt.source = 11 and plt.parcel_created_at > date_sub('${sdate}', interval 2 month) and plt.state = 6 and plt.duty_result = 1
left join bi_pro.parcel_claim_task pct on pct.pno = t1.pno and pct.parcel_created_at > date_sub('${sdate}', interval 2 month) and pct.source in (1,2,3,5,7,8,12) and pct.state < 7
left join bi_pro.parcel_claim_task pct3 on pct3.pno = t1.pno and pct3.parcel_created_at > date_sub('${sdate}', interval 2 month) and pct3.source in (4,6,9,10) and pct3.state < 7
left join fle_staging.store_receivable_bill_detail srb on srb.pno = t1.pno and srb.receivable_type_category = 5 and srb.state = 0
left join
    (
        select
            pct.pno
        from bi_pro.parcel_claim_task pct
        join t t1 on t1.pno = pct.pno
        where
            pct.state in (7,8)
        group by 1
    ) p1 on p1.pno = t1.pno
left join
    (
        select
            pct.pno
        from bi_pro.parcel_claim_task pct
        join t t1 on t1.pno = pct.pno
        where
            pct.state < 7
        group by 1
    ) p2 on p2.pno = t1.pno
where
    p1.pno is null
    or (p1.pno is not null and p2.pno is not null)


;



select
    ddd.CN_element
    ,count(pr.id) 动作量
    ,count(distinct pr.pno) 单量
from rot_pro.parcel_route pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.remark and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.routed_at > '2024-05-16 17:00:00'
    and pr.routed_at < '2024-06-17 17:00:00'
    and pr.route_action = 'FORCE_TAKE_PHOTO'
group by ddd.CN_element


;


select
    ss.name
    ,if(awl.store_id is not null, '是', '否') 是否爆仓网点
from fle_staging.sys_store ss
join tmpale.tmp_th_store_lj_0621 t on t.store_name = ss.name
left join nl_production.abnormal_white_list awl on awl.store_id = ss.id and awl.start_date <= '2024-06-19' and awl.end_date >= '2024-06-19' and awl.type = 2



;


select
    *
from fle_staging.login_device_record ldr
where
    ldr.staff_info_id = 607213
    and ldr.created_at > '2024-06-30 17:00:00'
    and ldr.created_at < '2024-07-01 17:00:00'


;


select
    t.*
    ,ss2.name
    ,kw.out_client_id
    ,group_concat(distinct ss.name) 责任网点
from tmpale.tmp_th_plt_lj_0710 t
left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = t.plt_id
left join fle_staging.sys_store ss on ss.id = plr.store_id
left join fle_staging.parcel_info pi on pi.pno  = t.pno
left join fle_staging.ka_warehouse kw on kw.id = pi.ka_warehouse_id
left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
group by 1,2,3,4

;




select
    tt.pno
    ,dp.third_sorting_code '包裹对应三段码'
    ,group_concat(distinct si.id separator '&&') '三段码对应快递员'
    ,group_concat(distinct si1.id separator '&&') '三段码围栏对应快递员'
    ,smr.name '大区'
    ,smp.name '片区'
    ,ss.name '三段码对应网点'
    ,convert_tz(ps.time,'+00:00','+07:00') '最后有效路由时间'
from fle_staging.parcel_info tt
left join
    (
        select
            dp.pno
            ,dp.third_sorting_code
            ,dp.dst_store_id
            ,row_number()over(partition by dp.pno order by dp.created_at desc) rank
        from dwm.drds_parcel_sorting_code_info dp
        where
            dp.created_at>=convert_tz(current_date()-interval 90 day,'+07:00','+00:00')
            and dp.pno in  ('${SUBSTITUTE(SUBSTITUTE(p4,"
        ",","),",","','")}')
    )dp on dp.pno=tt.pno and dp.rank=1
left join fle_staging.sys_three_sorting dd on dd.sorting_code=dp.third_sorting_code and dd.store_id=dp.dst_store_id
left join fle_staging.staff_info si on si.sorting_group_id =dd.sorting_group_id
left join fle_staging.sys_three_fence_sorting st on st.sorting_fence_code=dp.third_sorting_code and st.store_id=dp.dst_store_id
left join fle_staging.staff_info si1 on si1.sorting_group_id =st.sorting_group_id
left join fle_staging.sys_store ss on ss.id=dp.dst_store_id
left join fle_staging.sys_manage_region smr on smr.id=ss.manage_region
left join fle_staging.sys_manage_piece smp on smp.id=ss.manage_piece
left join
    (
        select
            ps.pno
            ,max(last_valid_routed_at) time
        from dw_dmd.parcel_store_stage_new ps
        where
            ps.last_valid_routed_at>=convert_tz(current_date()-interval 90 day,'+07:00','+00:00')
            and ps.pno in ('${SUBSTITUTE(SUBSTITUTE(p4,"
        ",","),",","','")}')
        group by 1
    )ps on ps.pno=tt.pno
where tt.created_at>=convert_tz(current_date()-interval 90 day,'+07:00','+00:00')
and tt.pno in  ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
group by 1


;



select
    distinct
    t.pno
    ,if(pi.returned = 1, '是', '否') 是否退件
    ,case am.punish_category
        when 56 then '物品类型错误（文件）'
        when 63 then '揽派件照片不合格'
        when 27 then '班车发车晚点'
        when 18 then '仓管未交接speed/优先包裹给快递员'
        when 13 then '揽收或中转包裹未及时发出'
        when 2 then '5天以内未妥投，且超24小时未更新 [原来叫法:包裹超过1天没有更新]'
        when 3 then '5天以上未妥投/未中转，且超24小时未更新 [原来叫法:5天未妥投/未中转，且超一天未更新]'
        when 14 then '工单处理不及时 [原来叫法:仓管对工单处理不及时]'
        when 4 then '问题件解决不及时'
        when 15 then '仓管未及时处理问题件包裹'
        when 7 then '包裹丢失'
        when 8 then '包裹破损'
        when 25 then '揽收禁运包裹'
        when 10 then '揽件时称量包裹不准确 [原来叫法:复秤异常]'
        when 19 then 'pri或者speed包裹未妥投'
        when 20 then '虚假妥投'
        when 1 then '虚假问题件/虚假留仓件'
        when 24 then '客户投诉-虚假问题件/虚假留仓件'
        when 21 then '客户投诉'
        when 22 then '快递员公款超时未上缴'
        when 12 then '迟到罚款'
        when 26 then '早退罚款'
        when 17 then '故意不接公司电话'
        when 9 then '其他'
        when 5 then '包裹配送时间超三天'
        when 6 then '未在客户要求的改约时间之前派送包裹'
        when 33 then '揽收任务超时'
        when 28 then '虚假回复工单'
        when 29 then '未妥投包裹没有标记'
        when 30 then '未妥投包裹没有入仓'
        when 34 then '网点应盘点包裹未清零'
        when 35 then '漏揽收'
        when 36 then '包裹外包装不合格'
        when 37 then '超大件'
        when 38 then '多面单'
        when 39 then '不称重包裹未入仓'
        when 40 then '上传虚假照片'
        when 41 then '网点到件漏扫描'
        when 42 then '虚假撤销'
        when 43 then '虚假标记'
        when 44 then '外协员工日交接不满50件包裹'
        when 45 then '超大集包处罚'
        when 46 then '不集包'
        when 47 then '理赔处理不及时'
        when 48 then '面单粘贴不规范'
        when 49 then '未换单'
        when 50 then '集包标签不规范'
        when 51 then '未及时关闭揽件任务'
        when 52 then '虚假上报'
        when 53 then '虚假错分'
        when 54 then '物品类型错误（水果件）'
        when 55 then '虚假上报车辆里程'
        when 57 then '旷工罚款'
        when 58 then '虚假取消揽件任务'
        when 59 then '72h未联系客户道歉  th customer_complaints_timeoutaction'
        when 60 then '虚假标记拒收'
        when 61 then '外协投诉主管未及时道歉'
        when 62 then '外协投诉客户不接受道歉'
        when 64 then '揽件任务未及时分配'
        when 65 then '网点未及时上传回款凭证'
        when 66 then '网点上传虚假回款凭证'
        when 67 then '时效延迟'
        when 68 then '未及时呼叫快递员'
        when 69 then '未及时尝试派送'
        when 70 then '退件包裹未处理'
        when 71 then '不更新包裹状态'
        when 72 then 'pri包裹未及时妥投'
        when 73 then '临近时效包裹未及时妥投'
        when 74 then '暴力分拣'
        when 75 then '上报拒收证据不合格'
        when 76 then '个人代理-不接单未提前通知'
        when 77 then '个人代理-终止合同未提前通知'
        when 78 then '待退件包裹未及时发出'
        when 79 then '工作严重低效'
        when 80 then 'epod拍照不合格'
        when 81 then '虚假标记改约'
        when 82 then '虚假标记错分'
        when 83 then '虚假标记联系不上收件人'
        when 84 then '超24小时未更新'
        when 85 then '72小时未终态'
        when 86 then '尝试揽收及时率不达标'
        when 87 then '揽收未及时发出'
        when 88 then '退件率不达标'
        when 89 then '承包加盟商-未提供服务'
        when 90 then '照片不合格'
        when 91 then 'fh包裹当日发出晚到港'
        when 92 then 'fh包裹未及时发出'
        when 93 then '个人代理-虚假上传人脸扫描'
        else '未知处罚类型'  -- 如果不在上述列举的情况中，返回一个默认值
    end 处罚原因
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0719 t on t.pno = pi.pno
left join bi_pro.abnormal_message am on am.merge_column = t.pno and am.isdel = 0 and am.isappeal < 5

;



select
    a.store
    ,count(a.order_no) 总工单
    ,count(if(timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) < 3, a.order_no, null)) / count(a.order_no) as 3小时内回复占比
    ,count(if(timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) < 6 and timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) >= 3, a.order_no, null)) / count(a.order_no) as 3_6小时内回复占比
    ,count(if(timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) < 9 and timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) >= 6, a.order_no, null)) / count(a.order_no) as 6_9小时内回复占比
    ,count(if(timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) < 12 and timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) >= 9, a.order_no, null)) / count(a.order_no) as 9_12小时内回复占比
    ,count(if(timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) < 15 and timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) >= 12, a.order_no, null)) / count(a.order_no) as 12_15小时内回复占比
    ,count(if(timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) < 18 and timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) >= 15, a.order_no, null)) / count(a.order_no) as 15_18小时内回复占比
    ,count(if(timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) < 21 and timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) >= 18, a.order_no, null)) / count(a.order_no) as 18_21小时内回复占比
    ,count(if(timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) < 24 and timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) >= 21, a.order_no, null)) / count(a.order_no) as 21_24小时内回复占比
    ,count(if(timestampdiff(hour, a.created_at, coalesce(a.reply_at, now())) >= 24, a.order_no, null)) / count(a.order_no) as 24小时以上回复占比
from
    (
        select
            wo.order_no
            ,ss.name store
            ,wo.status
            ,wo.created_at
            ,wor.created_at reply_at
            ,wor.staff_info_id
            ,row_number() over (partition by wo.id order by wor.created_at ) rk
        from bi_pro.work_order wo
        left join bi_pro.work_order_reply wor on wor.order_id = wo.id
        left join fle_staging.sys_store ss on ss.id = wo.store_id
        where
            wo.created_at > '2024-06-01'
            and wo.store_id in ('TH02030204' ,'TH05110400')
    ) a
where
    a.rk = 1
    and a.staff_info_id > 10001
group by 1


;



select
    t.pno
    ,case pvr.judgment_result
        when 1 then
    end
    ,pvr.comments
from bi_pro.parcel_violate_rules pvr
join tmpale.tmp_th_pno_lj_0724 t on t.pno = pvr.pno
;



with t as
    (
        select
            a.*
        from
            (
                select
                    pi.pno
                    ,pi.exhibition_weight
                    ,pi.ticket_pickup_store_id
                    ,pi.exhibition_length
                    ,pi.exhibition_width
                    ,pi.exhibition_height
                    ,dp.mark_parcel_print_category
                    ,dp.created_at
                    ,row_number() over (partition by pi.pno order by dp.created_at desc) rk
                from fle_staging.parcel_info pi
                join dwm.drds_parcel_sorting_code_info dp on dp.pno = pi.pno
                where
                    pi.created_at > '2024-07-01 17:00:00'
                  --  and pi.created_at < '2024-07-29 17:00:00'
            ) a
        where
            a.rk = 1
            and a.mark_parcel_print_category = 1
    )
select
    ss.name 网点
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
    ,count(distinct pr.pno) 发件出仓应集包包裹量
    ,count(distinct if(sl.pno is null, pr.pno, null)) 应集包未集包包裹量
    ,count(distinct if(sl.pno is null, pr.pno, null)) / count(distinct pr.pno) 未集包率
from rot_pro.parcel_route pr
join t t1 on t1.ticket_pickup_store_id = pr.store_id and t1.pno = pr.pno
left join fle_staging.sys_store ss on ss.id = t1.ticket_pickup_store_id
left join
    (
        select
            distinct
            pr.pno
            ,pr.store_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.ticket_pickup_store_id = pr.store_id
        where
            pr.route_action = 'SEAL'
            and pr.routed_at > '2024-07-20'
    ) sl on sl.store_id = t1.ticket_pickup_store_id and sl.pno = t1.pno
where
    pr.routed_at > '2024-07-20 17:00:00'
    and pr.routed_at < '2024-07-30 17:00:00'
    and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
group by 1,2

;


select
    a.last_store
    ,count(if(a.arrival_pack_no is null, a.pno, null)) 单件应扫发件量
    ,count(if(a.shipped_at is not null and a.arrival_pack_no is null, a.pno, null)) 单件已扫发件量
    ,count(if(a.shipped_at is not null and a.arrival_pack_no is null, a.pno, null)) / count(if(a.arrival_pack_no is null, a.pno, null)) 单件扫描率

    ,count(if(a.arrival_pack_no is not null, a.pno, null)) 集包应扫发件量
    ,count(if(a.shipped_at is not null and a.arrival_pack_no is not null, a.pno, null)) 集包已扫发件量
    ,count(if(a.shipped_at is not null and a.arrival_pack_no is not null, a.pno, null)) / count(if(a.arrival_pack_no is not null, a.pno, null)) 集包扫描率

    ,count(a.pno) 汇总应扫发件量
    ,count(if(a.shipped_at is not null , a.pno, null)) 汇总已扫发件量
    ,count(if(a.shipped_at is not null , a.pno, null)) / count(a.pno) 汇总扫描率
from
    (
        select
            pssn.pno
            ,pssn.store_name
            ,pssn.arrival_pack_no
            ,pssn.valid_store_order
            ,p2.store_name as last_store
            ,p2.shipped_at
        from dw_dmd.parcel_store_stage_new pssn
        join dw_dmd.parcel_store_stage_new p2 on p2.pno = pssn.pno and p2.valid_store_order = pssn.valid_store_order - 1
        where
            pssn.first_valid_routed_at > '2024-06-30 17:00:00'
            and pssn.first_valid_routed_at < '2024-07-29 17:00:00'
            and pssn.valid_store_order > 1
            and p2.store_category in  (8,12)
            and pssn.first_valid_route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    ) a
group by 1

;



with t as
    (
        select
            a.*
        from
            (
                select
                    pssn.pno
                    ,pssn.store_name 包裹到达网点
                    ,pssn.arrival_pack_no 包裹网点到件入仓集包号
                    ,p2.store_name as 上游HUB
                    ,p2.store_id
                    ,ddd.CN_element 包裹网点第一条有效路由动作
                    ,convert_tz(pssn.arrived_at, '+00:00', '+07:00') 包裹网点到件入仓时间
                    ,convert_tz(pssn.first_valid_routed_at, '+00:00', '+07:00') 包裹网点第一条有效路由动作时间
                    ,p3.van_out_proof_id
                    ,row_number() over (partition by p2.pno order by p3.shipped_at) rk
                from dw_dmd.parcel_store_stage_new pssn
                left join dwm.dwd_dim_dict ddd on ddd.element = pssn.first_valid_route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                join dw_dmd.parcel_store_stage_new p2 on p2.pno = pssn.pno and p2.valid_store_order = pssn.valid_store_order - 1 and p2.created_at > '2024-07-19'
                left join dw_dmd.parcel_store_stage_new p3 on p3.store_id = p2.store_id  and p3.next_store_id = pssn.store_id and p3.shipped_at > date_add(p2.arrived_at, interval 2 hour) and p3.shipped_at < pssn.first_valid_routed_at  and p3.created_at > '2024-07-19' and p3.van_out_proof_id is not null-- hub到仓1小时候
                where
                    pssn.first_valid_routed_at > '2024-07-20 17:00:00'
                    and pssn.first_valid_routed_at < '2024-07-29 17:00:00'
                    and pssn.valid_store_order > 1
                    and p2.store_category in  (8,12)
                    and p2.shipped_at is null
                    and p2.arrived_at is not null
                    and pssn.first_valid_route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            ) a
        where
            a.rk = 1
    )
, d as
    (
        select
            t1.*
            ,a.staff_info_id
            ,a.scan_cnt
            ,a.store_id hub_id
            ,a.routed_date
        from t t1
        left join
            (
                select
                    a.van_out_proof_id
                    ,a.staff_info_id
                    ,a.routed_date
                    ,a.store_id
                    ,1 / count(a.staff_info_id) over (partition by a.van_out_proof_id) scan_cnt
                from
                    (
                        select
                            distinct
                            t1.van_out_proof_id
                            ,pr.staff_info_id
                            ,pr.store_id
                            ,pr.store_name
                            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) routed_date
                        from rot_pro.parcel_route pr
                        join t t1 on t1.store_id = pr.store_id and  json_extract(pr.extra_value, '$.proofId') = t1.van_out_proof_id
                        where
                            pr.routed_at > '2024-07-19 17:00:00'
                            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
                    ) a
            ) a on a.van_out_proof_id = t1.van_out_proof_id
    )
select
    a1.routed_date
    ,a1.staff_info_id 员工ID
    ,a1.store_name 网点
    ,a2.pno_cnt / ( coalesce(a2.pno_cnt, 0) + a1.pno_cnt ) 漏扫发件率
    ,a2.pno_cnt 漏扫发件量
    ,a1.pno_cnt  应扫件量
from
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+07:00')) routed_date
            ,pr.staff_info_id
            ,pr.store_id
            ,pr.store_name
            ,count(distinct pr.pno) pno_cnt
        from rot_pro.parcel_route pr
        where
            pr.routed_at > '2024-07-20 17:00:00'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.store_category in (8,12)
        group by 1,2
    ) a1
left join
    (
        select
            d1.staff_info_id
            ,d1.routed_date
            ,d1.hub_id
            ,sum(d1.scan_cnt) pno_cnt
        from d d1
        group by 1,2,3
    ) a2 on a1.routed_date = a2.routed_date and a1.staff_info_id = a2.staff_info_id and a1.store_id = a2.hub_id
;
-- 明细
select
    pssn.pno
    ,pssn.store_name 包裹到达网点
    ,pssn.arrival_pack_no 包裹网点到件入仓集包号
    ,p2.store_name as 上游HUB
    ,convert_tz(p2.arrived_at, '+00:00', '+07:00') 上游HUB到件入仓时间
    ,ddd.CN_element 包裹网点第一条有效路由动作
    ,convert_tz(pssn.arrived_at, '+00:00', '+07:00') 包裹网点到件入仓时间
    ,convert_tz(pssn.first_valid_routed_at, '+00:00', '+07:00') 包裹网点第一条有效路由动作时间
from dw_dmd.parcel_store_stage_new pssn
left join dwm.dwd_dim_dict ddd on ddd.element = pssn.first_valid_route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
join dw_dmd.parcel_store_stage_new p2 on p2.pno = pssn.pno and p2.valid_store_order = pssn.valid_store_order - 1
where
    pssn.first_valid_routed_at > '2024-06-30 17:00:00'
    and pssn.first_valid_routed_at < '2024-07-29 17:00:00'
    and pssn.valid_store_order > 1
    and p2.store_category in  (8,12)
    and p2.shipped_at is null
    and p2.arrived_at is not null
;


select
    count(1)
from rot_pro.parcel_route pr
where
    pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    and pr.routed_at > '2024-07-29 17:00:00'
    and json_extract(pr.extra_value, '$.proofId') is null
;
select
    pr.pno
    ,pr.staff_info_id
from rot_pro.parcel_route pr
        -- join t t1 on t1.store_id = pr.store_id and  json_extract(pr.extra_value, '$.proofId') = t1.proof_id
where
    pr.routed_at > '2024-07-27 17:00:00'
    and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and json_extract(pr.extra_value, '$.proofId') = 'KKC12K4P36'
;

with t as
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.exhibition_weight
            ,pi.customary_pno
            ,pi.returned_pno
            ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) size
        from fle_staging.parcel_info pi
        where
            ( pi.returned = 0 and pi.src_phone = '0625942634')
            or (pi.returned = 1 and pi.dst_phone = '0625942634')
            and pi.created_at > '2024-05-31 17:00:00'
            and pi.created_at < '2024-06-30 17:00:00'
    )
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向') 包裹流向
    ,t1.returned_pno 退件单号
    ,t1.customary_pno 原正向单号
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
    ,case plt.duty_result
        when 1 then '丢失'
        when 2 then '破损/短少'
        when 3 then '超时效'
    end  TEAMA判责类型
    ,pct.claim_money 索赔金额
    ,t1.exhibition_weight 包裹重量
    ,t1.size 包裹尺寸
from t t1
left join
    (
        select
            plt.pno
            ,plt.duty_result
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at > '2024-05-31'
            and plt.state = 6
            and plt.penalties > 0
    ) plt on plt.pno = t1.pno
left join
    (
        select
            pct.pno
            ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
            ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) rn
        from bi_pro.parcel_claim_task pct
        join t t1 on t1.pno = pct.pno
        left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.created_at > '2024-05-31'
            and pct.state = 6
    ) pct on pct.pno = t1.pno and pct.rn = 1



;



select
    di.pno
    ,ss.name 协商网点
    ,ddd.CN_element 问题件类型
    ,convert_tz(di.created_at, '+00:00', '+07:00') 问题件生成时间
    ,convert_tz(cdt.updated_at, '+00:00', '+07:00') 问题件协商完成时间
    ,cdt.operator_id 处理员工ID
    ,case cdt.negotiation_result_category # 协商结果
        when 1 then '赔偿' -- 丢弃并赔偿（关闭订单，网点自行处理包裹）
        when 2 then '关闭订单(不赔偿不退货)' -- 丢弃（关闭订单，网点自行处理包裹）
        when 3 then '退货'
        when 4 then '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK' -- 丢弃（包裹发到内部拍卖仓）
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
        when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
        when 13 then 'TT退件新增“holding（15天后丢弃）”协商结果'
        else cdt.negotiation_result_category
    end 协商结果
    ,cdt.remark 问题件协商结果备注
    ,if(dtc.id is not null, '不属实', '属实') 快递员标记核实结果
    ,dtc.false_remark 标记核实备注
    ,case vrv.visit_result
            when 1 then '联系不上'
            when 2 then '取消原因属实、合理'
            when 3 then '快递员虚假标记/违背客户意愿要求取消'
            when 4 then '多次联系不上客户'
            when 5 then '收件人已签收包裹'
            when 6 then '收件人未收到包裹'
            when 7 then '未经收件人允许投放他处/让他人代收'
            when 8 then '快递员没有联系客户，直接标记收件人拒收'
            when 9 then '收件人拒收情况属实'
            when 10 then '快递员服务态度差'
            when 11 then '因快递员未按照收件人地址送货，客户不方便去取货'
            when 12 then '网点派送速度慢，客户不想等'
            when 13 then '非快递员问题，个人原因拒收'
            when 14 then '其它'
            when 15 then '未经客户同意改约派件时间'
            when 16 then '未按约定时间派送'
            when 17 then '派件前未提前联系客户'
            when 18 then '收件人拒收情况不属实'
            when 19 then '快递员联系客户，但未经客户同意标记收件人拒收'
            when 20 then '快递员要求/威胁客户拒收'
            when 21 then '快递员引导客户拒收'
            when 22 then '其他'
            when 23 then '情况不属实，快递员虚假标记'
            when 24 then '情况不属实，快递员诱导客户改约时间'
            when 25 then '情况属实，客户原因改约时间'
            when 26 then '客户退货，不想购买该商品'
            when 27 then '客户未购买商品'
            when 28 then '客户本人/家人对包裹不知情而拒收'
            when 29 then '商家发错商品'
            when 30 then '包裹物流派送慢超时效'
            when 31 then '快递员服务态度差'
            when 32 then '因快递员未按照收件人地址送货，客户不方便去取货'
            when 33 then '货物验收破损'
            when 34 then '无人在家不便签收'
            when 35 then '客户错误拒收包裹'
            when 36 then '快递员按照要求当场扫描揽收'
            when 37 then '快递员未按照要求当场扫描揽收'
            when 38 then '无所谓，客户无要求'
            when 39 then '包裹未准备好 - 情况不属实，快递员虚假标记'
            when 40 then '包裹未准备好 - 情况属实，客户存在未准备好的包裹'
            when 41 then '虚假修改包裹信息'
            when 42 then '修改包裹信息属实'
            when 43 then '客户需要包裹，继续派送'
            when 44 then '客户不需要包裹，操作退件'
            when 45 then '电话号码错误/电话号码是空号'
            else vrv.visit_result
        end as 回访结果
    ,case
        when vrv.type = 3 and vrv.visit_state in (3,7) or json_extract(vrv.extra_value, '$.rejection_delivery_again') = 1 then '退件' -- 多次联系不上、超时效和回访结果是退件
        when vrv.type = 3 and json_extract(vrv.extra_value, '$.rejection_delivery_again') = 2 then '继续派送' -- 继续派送
        when vrv.type = 8 and vrv.visit_state in (3,7) or vrv.visit_result = 44 then '退件' --  多次联系不上和回访结果是退件
        when vrv.type = 8 and  vrv.visit_result = 43 then '继续派送'
        else '异常关闭'
    end 回访是否继续派送
from fle_staging.diff_info di
join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join fle_staging.sys_store ss on ss.id = cdt.organization_id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join nl_production.violation_return_visit vrv on json_extract(vrv.extra_value, '$.diff_id') = di.id
left join fle_staging.diff_ticket_complain_false_info dtc on dtc.customer_diff_id = cdt.id
where
    di.created_at > '2024-07-24 17:00:00'
    and di.created_at < '2024-07-31 17:00:00'
    and di.diff_marker_category in (17,23,39)
    and cdt.organization_id in ('TH01090214', 'TH01050501', 'TH01090202', 'TH01090201', 'TH01470102')

;


select
    date(convert_tz(pr.routed_at, '+00:00', '+07:00')) p_date
    ,pr.route_action
    ,count(pr.pno)
from rot_pro.parcel_route pr
where
    pr.staff_info_id = '687431'
    and pr.routed_at > date_sub(curdate(), interval 1 month)
group by 1,2


;



select
    ss.short_name
    ,ss.id
from fle_staging.sys_store ss
where
    ss.short_name in ('AAA','KTE','2IPN','LMT','TAM','2PYN','PMN','BRK','CPH','POG','2KBI','KHR','LKS','LTS','SME','WOS','BAS','CHL','PIP','2MTP','2TGT','BLG','BMO','GKO','KMT','KPQ','KPW','RM9','TUG','2HKT','BPH','BST','JPN','PKT','PLD','PNSS','SMBB','TLY','2BWN','2KIS','2LMT','2NOK','2TON','BGI','CMB','KTH','MIN','PCS','PKN','PNN','POS','PSD','RAT','RTS','SBN','SPWW','SUL','THM','2BAG','2BLP','2HDY','2KLD','2LKP','2MSO','2NKR','2RAR','2SRA','2SUP','2SWT','2TAI','BCL','BGY','BKD','BKN','BKO','BPM','BUG','DMI','DMK','GOR','HDG','KHSS','KIG','LUN','NMG','NYA','PKS','PLB','PLP','PNA','PSK','PYK','RM2','RNN','RSDD','SLA','SSE','SUN','TLG','TLR','TNR','TTL','WAT','WNP','2BAS','2BBO','2BGK','2BKN','2BKT','2BNJ','2BPY','2BUG','2BYI','2CJM','2JBG','2JTC','2KLN','2KLT','2KNB','2KNY','2KPU','2KSW','2KTE','2MIN','2NAP','2NRE','2OMK','2PHO','2PHT','2PLD','2PTC','2RBN','2SAI','2SBL','2SNA','2SNI','2SPS','2SRC','2TAK','2TLG','5SAP','5SRG','ANG','BAM','BBA','BGG','BGK','BGR','BMI','BNH','BNMM','BSG','BSR','BTE','BTG','BTR','BYL','CEI','CJM','CPG','CUS','DNB','FAH','GAE','GTL','HDK','ISP','JKS','JTR','KCP','KHO','KHTT','KJN','KKH','KKM','KKY','KLL','KLN','KMH','KNA','KNE','KOD','KOK','KPK','KRK','LAK','LDY','LHO','MGT','MHU','MJU','MKA','MPK','MSO','MTP','NHO','NJG','NPK','NVN','NWM','ONN','OSLAS2','PAI','PAN','PAP','PCP','PKP','PLA','PMP','PNB','PNG','PPD','PPN','PRA','PRG','PRO','PTY','PUS','PXI','PYS','PYT','RAH','RSA','RTN','SHI','SKO','SKRR','SKV','SLG','SMAA','SMGG','SMPP','SNB','SPH','SPLL','SRG','SRN','SWI','TBC','TIB','TIN','TKS','TKT','TMS','TND','TNK','TVN','TWNN','URT','WIP','WRM')


;



select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,
from fle_staging.parcel_info pi
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
where
    pi.created_at > '2024-06-30 17:00:00'
    and pi.created_at < '2024-07-31 17:00:00'
    and pi.returned = 0

;



select
    distinct pls.pno '运单号เลขพัสดุ'
    ,c.created_at '首次预警时间'
    ,ds.store_name '网点名称'
    ,pls.created_at '任务生成时间เวลาที่จัดการสำเร็จ'
    ,if(
        TIMESTAMPDIFF(hour,pls.created_at,now())<48,
    concat(cast(TIMESTAMPDIFF(minute,now(),date_add(pls.created_at,interval 2 day))/60 as int),'h ',cast(round(TIMESTAMPDIFF(minute,now(),date_add(pls.created_at,interval 2 day))%60,0)as int),'min'),
    concat('已超时',concat(cast(TIMESTAMPDIFF(minute,date_add(pls.created_at,interval 2 day),now())/60 as int),'h ',cast(round(TIMESTAMPDIFF(minute,date_add(pls.created_at,interval 2 day),now())%60,0)as int),'min'))) '任务处理倒计时เวลาที่สะสม'
    ,pls.pack_no '集包号เลขแบ็กกิ้ง'
#     ,pls.arrival_time '入仓时间เวลาที่เข้าคลัง'
    ,pls.parcel_created_at '揽件时间เวลาที่รับ'
    ,pls.proof_id '出车凭证ใบรับรองปล่อยรถ'
    ,case pls.state
    when 1 then '待处理'
    when 2 then '网点处理'
    when 3 then '超时自动处理'
    when 4 then 'QAQC处理'
    when 5 then '已更新路由(无需处理)'
    end  '状态สถานะ'
    ,case pls.speed
    when 1 then '是'
    when 2 then '否'
    end  'SPEED件มีพัสดุSpeed'
    ,ddd.CN_element '最后有效路由สถานะสุดท้าย'
    ,pls.last_valid_staff_id '最后一步有效路由操作员工ID ไอดีพนักงานที่สแกนล่าสุด'
    ,pls.last_valid_at '最后操作时间เวลาสุดท้ายที่ดำเนินการ'
    ,ds2.store_name '最后有效路由所在网点สาขาสุดท้ายที่ดำเนินการ'
    ,coalesce(ds2.piece_name,fp.piece_no) '片区District'
    ,coalesce(ds2.region_name,fp.region_no) '大区Area'
    ,bc.client_name '客户名称'
    ,if(pi.cod_enabled = 1, 'yes', 'no') '是否是cod เป็นพัสดุcodหรือไม่'
    ,pi.cod_amount/100 COD金额
    ,pls.arrival_time '到达网点时间 เวลาที่ถึงสาขา'
    ,datediff(curdate(), pls.arrival_time) '到达网点时长/day มาถึงสาขาแล้วกี่วัน'
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
    end as '包裹状态 สถานะพัสดุ'
from bi_center.parcel_lose_task_sub_c pls
left join dwm.dwd_dim_dict ddd on ddd.element = pls.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join fle_staging.parcel_info pi on pi.pno = pls.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join dwm.dim_th_sys_store_rd ds on pls.store_id = ds.store_id and ds.stat_date = date_sub(curdate(), interval 2 day )
left join dwm.dim_th_sys_store_rd ds2 on pls.last_valid_store_id = ds2.store_id and ds2.stat_date = date_sub(curdate(), interval 2 day )
left join fle_Staging.sys_store ss on pls.last_valid_store_id =ss.id
left join fle_staging.franchisee_profile fp on ss.franchisee_id=fp.id
left join
    (
        select
            pls.pno
            ,plt.created_at
            ,row_number() over (partition by pls.pno order by plt.created_at) rn
        from bi_center.parcel_lose_task_sub_c pls
        left join bi_pro.parcel_lose_task plt on pls.pno = plt.pno and plt.source = 3
        where
             pls.created_at > date_sub(curdate(), interval 110 day)
            and pls.state= 1
    ) c on c.pno = pls.pno and c.rn = 1
where
    pls.created_at > date_sub(curdate(), interval 110 day)
    and pls.state = 1


;

when hsi2.job_title in (13,110,452,1497) then '快递员'
        when hsi2.job_title in (37,451) then '仓管员' -- 451副主管
        when hsi2.job_title in (16) then '主管'
;
select
    ss.name
    ,group_concat(distinct if(hsi.job_title in (13,110,452,1497), hsi.staff_info_id, null)) 快递员
    ,group_concat(distinct if(hsi.job_title in (37,451), hsi.staff_info_id, null)) 仓管员
    ,group_concat(distinct if(hsi.job_title in (16), hsi.staff_info_id, null)) 主管
from fle_staging.sys_store ss
join bi_pro.hr_staff_info hsi on hsi.sys_store_id = ss.id
where
    hsi.state = 1
    and ss.name in ('PLA_SP-พลา','PCS_SP-ประชาสงเคราะห์','CPH_SP-จอมพล','BYL_SP-บางยี่เรือ','CMB_SP-ชะแมบ','PIP_SP-พิปูน','POG_SP-โป่ง','PPD_SP-พระประแดง','BSG_SP-บางสมัคร','KKM_SP-โคกขาม','SBN_SP-สวนเบญจ์','JPN_SP-จอมพลเหนือ','KMT_SP-ขุมทอง','KTH_SP-คลองตันเหนือ','TKT_SP-เทพกระษัตรี','BLG_SP-บางระกำ','SME_SP-เสม็ด','RM9_SP-พระรามที่9','RSD_SP-รัษฎา','SUL_SP-สวนหลวง','TWN_SP-ทวีวัฒนา','BRK_SP-บางรัก','BMO_SP-บางมด','LTS_SP-ลำตาเสา','WAT_SP-วัฒนา','2SPS_BDC-สะพานสูง','2TAI_BDC-ท่าอิฐ','BPM_SP-บางปลาม้า','BAS_SP-บางซื่อ','RM2_SP-พระรามที่2','2MTP_BDC-ระยอง','BUG_SP-บึง','KTE_SP-คลองเตย','ANG_SP-อ่างทอง','NVN_SP-นวนคร','PNN_SP-พนัสนิคม','PMN_SP-พนม','PYK_SP-พัทยากลาง','KPW_SP-คลองประเวศ','KHO_SP-คลองกุ่ม','CHL_SP-ฉลอง','PRA_SP-ปราจีนบุรี','2PYN_BDC-พัทยาเหนือ','PSD_SP-พระสมุทรเจดีย์','KLL_SP-คลองหลวง','2KBI_BDC-กบินทร์บุรี','BGK_SP-บางจาก','PNS_SP-พันท้ายนรสิงห์','2SAI_BDC-สายไหม','TAM_SP-ตะโหมด','2TON_BDC-ธนบุรี','RTN_SP-รัตนวาปี','SKV_SP-สุขุมวิท','RTS_SP-รัตนาธิเบศร์','POS_SP-โพนพิสัย','BGY_SP-บางกรวย','LMT_SP-ลำปลาทิว','2IPN_BDC-อิปัน','KHT_SP-คลองหนึ่งใต้','2MIN_BDC-มีนบุรี','PRO_SP-บางพรม','BPH_SP-บางไผ่','PKN_SP-พระโขนง','KHR_SP-เคหะร่มเกล้า','TLY_SP-ตลาดใหญ่','BTR_SP-บางโทรัด','THM_SP-ท่าม่วง','KTK_SP-กรุงเทพกรีฑา','WNP_SP-วังตาผิน','LKS_SP-หลักสี่','SUN_SP-สวนหลวงเหนือ','TIN_SP-ไทยธานี','RAT_SP-ราชบุรี','PLB_SP-ปลายบาง','BKO_SP-บางกอกน้อย','LUN_SP-เกาะลันตา','PKT_SP-ปากท่อ','NYA_SP-คลองหนองใหญ่','RSA_SP-ราบ11','WOS_SP-วงศ์สว่าง','2BNJ_BDC-บางน้ำจืด','KJN_SP-คลองจั่น','2BAS_BDC-บางซื่อ','BST_SP-บางเสาธง','2NAP_BDC-นครปฐม','BGI_SP-บางนาใต้','2HDY_BDC-หาดใหญ่','2NOK_BDC-หนองคาย','2SWT_BDC-สามวาตะวันออก','2BKT_BDC-บางขุนเทียน','SMB_SP-สายไหมเหนือ','TUG_SP-ทุ่งตะโก','KHS_SP-คลองสอง','2TLG_BDC-ถลาง','2TGT_BDC-ตะกั่วทุ่ง','TLG_SP-ถลาง','KLN_SP-คลองหนึ่ง','NWM_SP-นวมินทร์','PLD_SP-ปลวกแดง','TLR_SP-ตลาดเหนือ','SRG_SP-สำโรง','2BBO_BDC-บางบ่อ','PLP_SP-พลับพลา','2BWN_BDC-บ่อวิน','2RAR_BDC-รับร่อ','BKD_SP-บึงคำพร้อยใต้','2KSW_BDC-คลองสามวา','KGP_SP-คลองพลู','PNA_SP-พระนคร','TVN_SP-ติวานนท์','2BKN_BDC-บางเขน','2PHO_BDC-พะโต๊ะ','2AMN_BDC-อำนาจเจริญ','MTP_SP-ระยอง','PPN_SP-ภูมิพล','PXI_SP-ภาชี','SPW_SP-สามพร้าว','2LKP_BDC-ลาดกระบัง','PKS_SP-แพรกษา','TIB_SP-ท้ายบ้าน','WRM_SP-วัดละมุด','BAM_SP-บ้านหมอ','2KPU_BDC-กะทู้','LAK_SP-เลาขวัญ','BKN_SP-บางเขน','NMG_SP-นอกเมือง','ONN_SP-อ่อนนุช','PSK_SP-ป่าสัก','2NRE_BDC-หนองรี','2NKR_BDC-เมืองนครราชสีมา','2KTE_BDC-คลองเตย','KMH_SP-โคกหม้อ','PCP_SP-ประชาธิปัตย์','ISP_SP-อิสระภาพ','KNE_SP-พระโขนงเหนือ','GOR_SP-เกาะล้าน','CUS_SP-ชุมแสง','BMG_SP-บางเมือง','HDK_SP-หาดคำ','SWI_SP-สวี','SSE_SP-สามเสนใน','RNN_SP-ระนอง','SHI_SP-เสาไห้','SKR_SP-ศรีนครินทร์','2KIS_BDC-เคียนซา','BTG_SP-บางบัวทอง','DNB_SP-เดิมบางนางบวช','BGG_SP-บางปะกอก','2SUP_BDC-สุพรรณบุรี','GKO_SP-หนองค้อ','KKY_SP-เขาขยาย','2HKT_BDC-ภูเก็ต','2KLN_BDC-คลองหนึ่ง','2LMT_BDC-ลำปลาทิว','SNB_SP-สนามบิน','2CJM_BDC-ชุมพร','PNB_SP-ปราณบุรี','2SRA_BDC-สระแก้ว','SUY_SP-เสือใหญ่','MKA_SP-มาบข่า','KOK_SP-เกาะแก้ว','TTL_SP-เทียนทะเล','PMP_SP-ปางมะผ้า','2MSO_BDC-แม่สอด','KPQ_SP-โคกปี่ฆ้อง','BNH_SP-บึงน้ำรักษ์','BCL_SP-บ้านช่างหล่อ','NPK_SP-หนองไผ่แก้ว','BSR_SP-บางเสร่','DMI_SP-ดอกไม้','2NHO_BDC-หนองขาม','GTL_SP-กระทุ่มราย','JTR_SP-จัตุรัส','WIP_SP-วิภาวดี','2SBL_BDC-ศรีบุญเรือง','5SAP_PDC-สามพราน','2PLD_BDC-ปลวกแดง','CJM_SP-ชุมพร','TND_SP-ท่านัด','PTY_SP-พัทยา','SMG_SP-สี่มุมเมือง','2PHT_BDC-ปทุมธานี','2BUG_BDC-บึง','TMS_SP-ธรรมศาสตร์','MIN_SP-มีนบุรี','2KLD_BDC-คลองด่าน','BON_SP-บางบอน','2PTC_BDC-ปักธงชัย','PAN_SP-พานทอง','SMA_SP-ไทรม้า','TBC_SP-ทับช้าง','2BLP_BDC-บางรักพัฒนา','HDG_SP-หางดง','PYT_SP-พญาไท','2RBN_BDC-ราษฎร์บูรณะ','SPH_SP-สวนผึ้ง','SLG_SP-ศาลากลาง','2SRC_BDC-ศรีราชา','SPL_SP-สวนพริกไทย','CPG_SP-ช้างเผือก')
group by 1

;









SELECT
  JSON_EXTRACT(extra_info, '$.ai_weight') ai_weight,
  JSON_EXTRACT(extra_info, '$.abnormal_balance.after_img') after_img,
  pno,
  `after_weight`
    ,case state
        when 0 then '未处理'
        when 1 then '处罚'
        when 2 then '不处罚'
    end 判责结果
    ,case price_policy_type
        when 3 then '仓管员复称尺寸'
        when 1 then '仓管员复称重量'
        when 2 then '仓管员复称尺寸'
        when 11 then '快递员修改重量'
        when 12 then '快递员修改尺寸'
        when 13 then '快递员修改尺寸'
    end 称重来源
FROM
  nl_production.`abnormal_weight_balance`
WHERE
  `created_at` > '2024-08-07'
    and created_at < '2024-08-14'
  and `extra_info` like '%"ai_weight"%';

;

select
    plt.*
    ,ss.name 最后有效路由网点
from bi_pro.parcel_lose_task plt
left join fle_staging.sys_store ss on ss.id = plt.last_valid_store_id
join fle_staging.parcel_info p1 on p1.pno = plt.pno
join
    (
        select
            pi.src_name
            ,pi.src_phone
            ,pi.src_detail_address
        from fle_staging.parcel_info pi
        where
            pi.pno = 'THT100314CSWT2Z'
    ) t on t.src_phone = p1.src_phone or t.src_name = p1.src_name or t.src_detail_address = p1.src_detail_address
;


select
    a1.部门,
    a1.处理组织,
    a1.CN_element '问题件类型ประเภทคำร้อง',
    a2.总任务量,
    a3.昨日已完成任务量,
    a1.未处理总计,
    a1.D0沟通中ระหว่างเจรจา,
    a1.D0未处理ยังไม่จัดการ,
    a1.D1沟通中ระหว่างเจรจา,
    a1.D1未处理ยังไม่จัดการ,
    a1.D2沟通中ระหว่างเจรจา,
    a1.D2未处理ยังไม่จัดการ,
    a1.D3沟通中ระหว่างเจรจา,
    a1.D3未处理ยังไม่จัดการ,
    a1.D4_7沟通中ระหว่างเจรจา,
    a1.D4_7未处理ยังไม่จัดการ,
    a1.D8_15沟通中ระหว่างเจรจา,
    a1.D8_15未处理ยังไม่จัดการ,
    a1.`D16+沟通中ระหว่างเจรจา`,
    a1.`D16+未处理ยังไม่จัดการ`
from
    (
        select
            case
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer','Team BD VIP (Retail Management) ') then 'Retail Management'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
                    or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
            end 部门
            ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when coalesce(ss.category,ss2.category) in (11) then 'FFM'
              when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
              when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
              when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
              when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
            end as 处理组织
            ,di.CN_element
            ,count(if(di.state = 0,di.id,null)) 未处理总计
            ,count(if(datediff(current_date,date(di.created_at))<=1,di.id,null)) D0任务量
            ,count(if(datediff(current_date,date(di.created_at))<=1 and di.state=1,di.id,null)) D0已完成
            ,count(if(datediff(current_date,date(di.created_at))<=1 and di.state in (2,3,4),di.id,null)) 'D0沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at))<=1 and di.state=0,di.id,null)) 'D0未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at))<=1 and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at))<=1 and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at))<=1,di.id,null))*100
                    ,2),'%') D0未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at))=2,di.id,null)) D1任务量
            ,count(if(datediff(current_date,date(di.created_at))=2 and di.state=1,di.id,null)) D1已完成
            ,count(if(datediff(current_date,date(di.created_at))=2 and di.state in (2,3,4),di.id,null)) 'D1沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at))=2 and di.state=0,di.id,null)) 'D1未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at))=2 and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at))=2 and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at))=2,di.id,null))*100
                    ,2),'%') D1未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at))=3,di.id,null)) D2任务量
            ,count(if(datediff(current_date,date(di.created_at))=3 and di.state=1,di.id,null)) D2已完成
            ,count(if(datediff(current_date,date(di.created_at))=3 and di.state in (2,3,4),di.id,null)) 'D2沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at))=3 and di.state=0,di.id,null)) 'D2未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at))=3 and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at))=3 and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at))=3,di.id,null))*100
                    ,2),'%') D2未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at))=4,di.id,null)) D3任务量
            ,count(if(datediff(current_date,date(di.created_at))=4 and di.state=1,di.id,null)) D3已完成
            ,count(if(datediff(current_date,date(di.created_at))=4 and di.state in (2,3,4),di.id,null)) 'D3沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at))=4 and di.state=0,di.id,null)) 'D3未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at))=4 and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at))=4 and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at))=4,di.id,null))*100
                    ,2),'%') D3未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8),di.id,null)) D4_7任务量
            ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state=1,di.id,null)) D4_7已完成
            ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state in (2,3,4),di.id,null)) 'D4_7沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state=0,di.id,null)) 'D4_7未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8),di.id,null))*100
                    ,2),'%') D4_7未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16),di.id,null)) D8_15任务量
            ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state=1,di.id,null)) D8_15已完成
            ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state in (2,3,4),di.id,null)) 'D8_15沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state=0,di.id,null)) 'D8_15未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16),di.id,null))*100
                    ,2),'%') D8_15未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at))>=17,di.id,null)) 'D16+任务量'
            ,count(if(datediff(current_date,date(di.created_at))>=17 and di.state=1,di.id,null)) 'D16+已完成'
            ,count(if(datediff(current_date,date(di.created_at))>=17 and di.state in (2,3,4),di.id,null)) 'D16+沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at))>=17 and di.state=0,di.id,null)) 'D16+未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at))>=17 and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at))>=17 and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at))>=17,di.id,null))*100
                    ,2),'%') 'D16+未处理完成占比'

        from
            (
                select
                    di.id
                    ,convert_tz(di.created_at,'+00:00','+07:00') created_at
                    ,di.pno
                    ,ddd.cn_element
                    ,pi.ticket_pickup_store_id
                    ,pi.client_id
                    ,cdt.state
                    ,cdt.organization_type
                    ,cdt.organization_id
                    ,cdt.vip_enable
                    ,cdt.service_type
                    ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
                    ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
                from fle_staging.diff_info di
                join fle_staging.parcel_info pi on di.pno=pi.pno
                left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
                join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'
                left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.visit_state in (0,1,2) and vrv.type = 3
                where
                    pi.created_at>=date_sub(current_date,interval 3 month)
                    and di.created_at<=date_sub(current_date,interval 7 hour)
                    and (pi.state=6 or (cdt.state=1 and date(convert_tz(cdt.updated_at,'+00:00','+07:00'))=date_sub(current_date,interval 1 day)))
                    and cdt.state in (0,1,2,3,4)
                    and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
                    and vrv.link_id is null
            ) di
        left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
        left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
        left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
        left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
        group by 1,2,3
    ) a1
left join
    (
        select
            case
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer','Team BD VIP (Retail Management) ') then 'Retail Management'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
                    or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
            end 部门
            ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when coalesce(ss.category,ss2.category) in (11) then 'FFM'
              when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
              when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
              when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
              when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
            end as 处理组织
            ,di.CN_element
            ,count(di.id) 总任务量
        from
            (
                select
                    di.id
                    ,convert_tz(di.created_at,'+00:00','+07:00') created_at
                    ,di.pno
                    ,ddd.cn_element
                    ,pi.ticket_pickup_store_id
                    ,pi.client_id
                    ,cdt.state
                    ,cdt.organization_type
                    ,cdt.organization_id
                    ,cdt.vip_enable
                    ,cdt.service_type
                    ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
                    ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
                from fle_staging.diff_info di
                join fle_staging.parcel_info pi on di.pno=pi.pno
                left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
                join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'
                left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.visit_state in (0,1,2) and vrv.type = 3
                where
                    pi.created_at>=date_sub(current_date,interval 3 month)
                    and di.created_at<=date_sub(current_date,interval 7 hour)
#                     and (pi.state=6 or (cdt.state=1 and date(convert_tz(cdt.updated_at,'+00:00','+07:00'))=date_sub(current_date,interval 1 day)))
#                     and cdt.state = 0
                    and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
                    and vrv.link_id is null
            )di
        left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
        left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
        left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
        left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
        group by 1,2,3
    ) a2 on a1.部门=a2.部门 and a1.处理组织 = a2.处理组织 and a1.CN_element = a2.CN_element
left join
    (
        select
            case
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer','Team BD VIP (Retail Management) ') then 'Retail Management'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
                    or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
            end 部门
            ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when coalesce(ss.category,ss2.category) in (11) then 'FFM'
              when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
              when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
              when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
              when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
            end as 处理组织
            ,di.CN_element
            ,count(di.id) 昨日已完成任务量
        from
            (
                select
                    di.id
                    ,convert_tz(di.created_at,'+00:00','+07:00') created_at
                    ,di.pno
                    ,ddd.cn_element
                    ,pi.ticket_pickup_store_id
                    ,pi.client_id
                    ,cdt.state
                    ,cdt.organization_type
                    ,cdt.organization_id
                    ,cdt.vip_enable
                    ,cdt.service_type
                    ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
                    ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
                from fle_staging.diff_info di
                join fle_staging.parcel_info pi on di.pno=pi.pno
                left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
                join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'
                where
                    pi.created_at>=date_sub(current_date,interval 3 month)
                    and cdt.updated_at <= date_sub(current_date,interval 7 hour)
                    and cdt.updated_at >= date_sub(curdate(), interval 31 hour)
#                     and (pi.state=6 or (cdt.state=1 and date(convert_tz(cdt.updated_at,'+00:00','+07:00'))=date_sub(current_date,interval 1 day)))
#                     and cdt.state in (0,1,2,3,4)
                    and cdt.state = 1
                    and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
            )di
        left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
        left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
        left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
        left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
        group by 1,2,3
    ) a3 on a1.部门=a3.部门 and a1.处理组织 = a3.处理组织 and a1.CN_element = a3.CN_element
;









with t as
    (
        select
            di.id
            ,convert_tz(di.created_at,'+00:00','+07:00') created_at
            ,convert_tz(pi.created_at,'+00:00','+07:00') pi_created_at
            ,di.pno
            ,ddd.cn_element
            ,ddd2.CN_element rejection
            ,pi.ticket_pickup_store_id
            ,pi.client_id
            ,cdt.state
            ,cdt.organization_type
            ,cdt.organization_id
            ,cdt.vip_enable
            ,cdt.service_type
            ,pi.customary_pno
            ,pi.article_category
            ,pd.last_valid_store_id
            ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
            ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
        from fle_staging.diff_info di
        join fle_staging.parcel_info pi on di.pno=pi.pno
        left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
        join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'
        left join dwm.dwd_dim_dict ddd2 on di.rejection_category = ddd2.element and ddd2.db='fle_staging' and ddd2.tablename='diff_info' and ddd2.fieldname='rejection_category'
        left join bi_pro.parcel_detail pd on pd.pno = pi.pno
        left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.visit_state in (0,1,2) and vrv.type = 3
        where
            pi.created_at>=date_sub(current_date,interval 3 month)
            and di.created_at<=date_sub(current_date,interval 7 hour)
            and (pi.state=6 or (cdt.state=1 and date(convert_tz(cdt.updated_at,'+00:00','+07:00'))=date_sub(current_date,interval 1 day)))
            and cdt.state in (0,2,3,4)
            and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
            and vrv.link_id is null
    )

select
    case
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer') then 'Retail Management'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
      when di.organization_type=2 and di.vip_enable=0 then '总部cs'
      when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
            or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
    end '部门แผนกที่จัดการ'
    ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
      when di.organization_type=2 and di.vip_enable=0 then '总部cs'
      when coalesce(ss.category,ss2.category) in (11) then 'FFM'
      when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
      when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
      when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
      when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
    end as '处理组织ทีมที่จัดการ'
    ,ss.name '问题件待处理网点สาขาที่จัดการ'
    ,di.pno '包裹号เลขพัสดุ'
    ,di.client_id
    ,di.pi_created_at '揽收时间เวลารับงาน'
    ,case di.article_category
        when 0 then '文件/document'
        when 1 then '干燥食品/dry food'
        when 2 then '日用品/daily necessities'
        when 3 then '数码产品/digital product'
        when 4 then '衣物/clothes'
        when 5 then '书刊/Books'
        when 6 then '汽车配件/auto parts'
        when 7 then '鞋包/shoe bag'
        when 8 then '体育器材/sports equipment'
        when 9 then '化妆品/cosmetics'
        when 10 then '家居用具/Houseware'
        when 11 then '水果/fruit'
        when 99 then '其它/other'
    end '包裹类型ประเภทพัสดุ'
    ,di.customary_pno '退件前单号'
    ,dt.store_name '当前所处网点'
    ,dt.piece_name '当前所处片区'
    ,dt.region_name '当前所处大区'
    ,di.CN_element  '问题件类型ประเภทคำร้อง'
    ,di.rejection 拒收原因
    ,di.created_at '问题件生成时间เวลาที่ติดปัญหาเข้าระบบ'
    ,case di.state
     when 0 then '客服未处理'
     when 1 then '已处理完毕'
     when 2 then '正在沟通中'
     when 3 then '财务驳回'
     when 4 then '客户未处理'
     when 5 then '转交闪速系统'
     when 6 then '转交QAQC'
     end as '处理状态สถานะจัดการปัจจุบัน'
    ,datediff(current_date,date(di.created_at)) '问题件生成天数'
    ,d2.di_count 问题件提交次数
    ,convert_tz(d3.created_at, '+00:00', '+07:00') 第一次提交问题件时间
    ,datediff(curdate(), di.pi_created_at) 揽收至今天数
from t di
left join
    (
        select
            t1.pno
            ,count(distinct di.id) di_count
        from fle_staging.diff_info di
        join t t1 on t1.pno = di.pno
        where
            di.created_at > date_sub(curdate(), interval 6 month )
        group by 1
    ) d2 on d2.pno = di.pno
left join
    (
        select
            t1.pno
            ,di.created_at
            ,row_number() over (partition by t1.pno order by di.created_at) rk
        from fle_staging.diff_info di
        join t t1 on t1.pno = di.pno
        where
            di.created_at > date_sub(curdate(), interval 6 month )
    ) d3 on d3.pno = di.pno and d3.rk = 1
left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = di.last_valid_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
group by 1,2,3,4,5


;


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
		  else pi.state
      end as '包裹状态'
    ,ddd.CN_element
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0827 t on t.pno = pi.pno
left join fle_staging.diff_info di on di.pno = pi.pno and di.state = 0
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'


;


select
    distinct
    plt.id
    ,plt.pno
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
    ,case plt.duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓7主3套餐(仓管70%主管30%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then  '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then  '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then  'LH全责（LH100%）'
        when 7 then  '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 21 then  '仓7主3套餐(仓管70%主管30%)'
    end 套餐
    ,ss.name 责任网点
    ,t.t_value 原因
from bi_pro.parcel_lose_task plt
left join bi_pro.parcel_lose_responsible plr on plt.id = plr.lose_task_id
left join fle_staging.sys_store ss on ss.id = plr.store_id
left join `bi_pro`.`translations` t on plt.duty_reasons = t.t_key and t.`lang` = 'zh-CN'
where
    plr.store_id = 'TH20050103'
    and plt.updated_at > '2024-07-01'
    and plt.updated_at < '2024-08-01'
    and plt.state = 6
    and plt.penalties > 0


;


select
    count(1)
from bi_pro.parcel_lose_task plt
where
    plt.created_at > '2024-08-01'
    and plt.source = 12

;


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
		  else pi.state
      end as 'สถานะพัสดุ 包裹状态'
    ,pi.returned_pno  `เลขพัสดุตีกลับ 退件单号`
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0902 t on t.pno = pi.pno
# left join
#     (
#         select
#             pr.pno
#             ,count(pr.id) pr_cnt
#         from rot_pro.parcel_route pr
#         join tmpale.tmp_th_pno_lj_0831 t on t.pno = pr.pno
#         where
#             pr.routed_at > '2024-06-01'
#             and pr.route_action = 'DELIVERY_MARKER'
#             and pr.marker_category = 2
#         group by 1
#     ) rj on rj.pno = pi.pno


;


select
    pr.pno
    ,ddd.CN_element 路由
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 操作时间
    ,pr.store_name 操作网点
from rot_pro.parcel_route pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.staff_info_id = 648373
    and pr.routed_at > '2024-09-06 17:00:00'
    and pr.routed_at < '2024-09-07 17:00:00'

;

select
    device_id,
    hub_no,
    hub_name
from
    fle_staging.sorting_info
where
    device_id in ('020101', '040101', '050101', '160101', '160102', '190101')
;



select
    dt.device_id
    ,count(distinct dt.part_off_no) 格口数
from dwm.drds_th_sorting_machines_sort_log_d dt
where
    dt.created_at > date_sub(curdate(), interval 2 month)
group by 1

;


select
    pr.pno
    ,pr.store_name
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 扫描时间
    ,pr.route_action
from rot_pro.parcel_route pr
where
    pr.routed_at > '2024-09-01 06:06:00'
    and pr.routed_at < '2024-09-01 06:13:00'
    and pr.staff_info_id = 56079
    and pr.route_action in ('SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN')

;


select
    pf.status
from wrs_production.pkg_form pf
left join wrs_production.pkg_form_input pfi on pf.id = pfi.pkg_id
where
    pfi.id is null


；
;


select
    *
from fle_staging.parcel_info pi
where
    pi.pno like 'TH680562B%'
    and pi.src_detail_address like '%1317D%'
    and pi.created_at > '2024-07-31'


;

select
    t.pno
    ,pr.staff_info_id
    ,pr.store_name
from rot_pro.parcel_route pr
join tmpale.tmp_th_pno_lj_0909 t on t.pno = pr.pno
where
    pr.route_action = 'DELIVERY_CONFIRM'

;
select * from tmpale.tmp_th_pno_lj_0904
;


select
    distinct
    pf.status
from wrs_production.pkg_form pf


;

select
    date (convert_tz(ph.created_at, '+00:00', '+07:00')) 上报日期
    ,case ph.state
        when 0 then '待认领'
        when 1 then '认领中'
        when 2 then '已认领'
        when 3 then '已失效'
        when 4 then '已删除'
        when 5 then '待登记'
        else ph.state
    end 状态
    ,case ph.final_state
        when 1 then '认领成功'
        when 2 then '认领成功但已进闪速'
        when 3 then '非水果件超期失效'
        when 4 then '水果件超期失效'
        when 5 then '匹配成功'
        when 6 then '匹配成功但已进闪速'
        else ph.final_state
    end 终态方式
    ,count(ph.hno) cnt
from fle_staging.parcel_headless ph
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ph.submit_staff_id
left join bi_pro.hr_job_title hjt on hjt.id= hsi.job_title
where
    ph.created_at > '2024-09-01 17:00:00'
    and ph.created_at  < '2024-09-08 17:00:00'
    and ph.submit_store_id = 'TH05110400'
group by 1,2,3

;

select
    *
from fle_staging.parcel_headless ph
where
    ph.created_at > '2024-09-07 17:00:00'
    and ph.created_at  < '2024-09-08 17:00:00'
    and ph.submit_store_id = 'TH05110400'

;

select
    a1.*
    ,ph.p_date
    ,ph.cnt
from
    (
        select
            hsi.staff_info_id
            ,hjt.job_name
        from bi_pro.hr_staff_info hsi
        left join bi_pro.hr_job_title hjt on hjt.id= hsi.job_title
        where
            hsi.state = 1
            and hsi.sys_store_id = 'TH05110400'
    ) a1
join
    (
        select
            ph.submit_staff_id
            ,date (convert_tz(ph.created_at, '+00:00', '+07:00')) p_date
            ,count(ph.hno) cnt
        from fle_staging.parcel_headless ph
        where
            ph.created_at > '2024-09-01 17:00:00'
            and ph.submit_store_id = 'TH05110400'
        group by 1,2
    ) ph on a1.staff_info_id = ph.submit_staff_id

;



select
    a1.*
    ,a2.cnt 身份证当日进入量
from
    (
        select
            date(convert_tz(cr.`operated_at`,'+00:00','+07:00')) 日期,
            cr.`operator_name` ID,
            date(convert_tz(cr.`operated_at`,'+00:00','+07:00')) 操作时间,
            count(case when cr.`state`=1 then cr.customer_id  end ) 身份证认证审核通过数量,
            count(case when cr.`state`=2 then cr.customer_id  end ) 身份证认证审核驳回数量,
            count(case when cr.`state`=0 then cr.customer_id  end ) 身份证认证待审核数量,
            count(cr.customer_id) 身份证认证审核总数量
        from `fle_staging`.`customer_approve_record` cr
        where
            cr.`credentials_category`=1
            and cr.`deleted`=0
            and cr.`operated_at`>=convert_tz(CURRENT_DATE-interval 7 day,'+07:00','+00:00')
        group by 1,2,3
        order by 1,2
    ) a1
cross join
    (
        select
            date(convert_tz(cr.`operated_at`,'+00:00','+07:00')) 日期
            ,count(cr.id) cnt
        from fle_staging.customer_approve_record cr
        where
            cr.created_at > date_add(curdate(), interval 2 hour)
            and cr.created_at > date_sub(curdate(), interval 11 hour)
            and cr.credentials_category = 1
            and cr.deleted = 0
    ) a2



;


select
    t.pno
    ,pi.client_id 客户id
    ,case
        when bc.client_id is not null then bc.client_name
        when bc.client_id is null and kp.id is not null then '普通KA'
        else '小c'
    end 客户类型
    ,pi.src_name 寄件人姓名
    ,pi.src_phone 寄件人电话
    ,pi.src_detail_address 寄件人地址
    ,case pi.article_category
        when 0 then '文件/document'
        when 1 then '干燥食品/dry food'
        when 2 then '日用品/daily necessities'
        when 3 then '数码产品/digital product'
        when 4 then '衣物/clothes'
        when 5 then '书刊/Books'
        when 6 then '汽车配件/auto parts'
        when 7 then '鞋包/shoe bag'
        when 8 then '体育器材/sports equipment'
        when 9 then '化妆品/cosmetics'
        when 10 then '家居用具/Houseware'
        when 11 then '水果/fruit'
        when 99 then '其它/other'
    end 物品类型
    ,ss.name 揽件网点
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0909 t on t.pno = pi.pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id

;


select
    t.c_sid_fle
    ,t.c_store_id
    ,dt.store_name 网点名称
    ,dt.piece_name 片区
    ,dt.region_name  大区
from dwm.dim_th_sys_store_rd dt
join tmpale.tmp_th_store_lj_0911 t on t.c_store_id = dt.store_id
where
    dt.stat_date = '2024-09-10'


;


select
    *
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi
where
    plt.source in (1,2,4,7,8,12)


;



select
    a1.部门,
    a1.处理组织,
    a1.CN_element '问题件类型ประเภทคำร้อง',
    a2.总任务量,
    a3.昨日已完成任务量,
    a1.未处理总计,
    a1.D0沟通中ระหว่างเจรจา,
    a1.D0未处理ยังไม่จัดการ,
    a1.D1沟通中ระหว่างเจรจา,
    a1.D1未处理ยังไม่จัดการ,
    a1.D2沟通中ระหว่างเจรจา,
    a1.D2未处理ยังไม่จัดการ,
    a1.D3沟通中ระหว่างเจรจา,
    a1.D3未处理ยังไม่จัดการ,
    a1.D4_7沟通中ระหว่างเจรจา,
    a1.D4_7未处理ยังไม่จัดการ,
    a1.D8_15沟通中ระหว่างเจรจา,
    a1.D8_15未处理ยังไม่จัดการ,
    a1.`D16+沟通中ระหว่างเจรจา`,
    a1.`D16+未处理ยังไม่จัดการ`
from
    (
        select
            case
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer','Team BD VIP (Retail Management) ') then 'Retail Management'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
                    or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
            end 部门
            ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when coalesce(ss.category,ss2.category) in (11) then 'FFM'
              when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
              when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
              when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
              when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
            end as 处理组织
            ,di.CN_element
            ,count(if(di.state = 0,di.id,null)) 未处理总计
            ,count(if(datediff(current_date,date(di.created_at))<=1,di.id,null)) D0任务量
            ,count(if(datediff(current_date,date(di.created_at))<=1 and di.state=1,di.id,null)) D0已完成
            ,count(if(datediff(current_date,date(di.created_at))<=1 and di.state in (2,3,4),di.id,null)) 'D0沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at))<=1 and di.state=0,di.id,null)) 'D0未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at))<=1 and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at))<=1 and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at))<=1,di.id,null))*100
                    ,2),'%') D0未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at))=2,di.id,null)) D1任务量
            ,count(if(datediff(current_date,date(di.created_at))=2 and di.state=1,di.id,null)) D1已完成
            ,count(if(datediff(current_date,date(di.created_at))=2 and di.state in (2,3,4),di.id,null)) 'D1沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at))=2 and di.state=0,di.id,null)) 'D1未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at))=2 and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at))=2 and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at))=2,di.id,null))*100
                    ,2),'%') D1未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at))=3,di.id,null)) D2任务量
            ,count(if(datediff(current_date,date(di.created_at))=3 and di.state=1,di.id,null)) D2已完成
            ,count(if(datediff(current_date,date(di.created_at))=3 and di.state in (2,3,4),di.id,null)) 'D2沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at))=3 and di.state=0,di.id,null)) 'D2未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at))=3 and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at))=3 and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at))=3,di.id,null))*100
                    ,2),'%') D2未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at))=4,di.id,null)) D3任务量
            ,count(if(datediff(current_date,date(di.created_at))=4 and di.state=1,di.id,null)) D3已完成
            ,count(if(datediff(current_date,date(di.created_at))=4 and di.state in (2,3,4),di.id,null)) 'D3沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at))=4 and di.state=0,di.id,null)) 'D3未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at))=4 and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at))=4 and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at))=4,di.id,null))*100
                    ,2),'%') D3未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8),di.id,null)) D4_7任务量
            ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state=1,di.id,null)) D4_7已完成
            ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state in (2,3,4),di.id,null)) 'D4_7沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state=0,di.id,null)) 'D4_7未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8),di.id,null))*100
                    ,2),'%') D4_7未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16),di.id,null)) D8_15任务量
            ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state=1,di.id,null)) D8_15已完成
            ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state in (2,3,4),di.id,null)) 'D8_15沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state=0,di.id,null)) 'D8_15未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16),di.id,null))*100
                    ,2),'%') D8_15未处理完成占比

            ,count(if(datediff(current_date,date(di.created_at))>=17,di.id,null)) 'D16+任务量'
            ,count(if(datediff(current_date,date(di.created_at))>=17 and di.state=1,di.id,null)) 'D16+已完成'
            ,count(if(datediff(current_date,date(di.created_at))>=17 and di.state in (2,3,4),di.id,null)) 'D16+沟通中ระหว่างเจรจา'
            ,count(if(datediff(current_date,date(di.created_at))>=17 and di.state=0,di.id,null)) 'D16+未处理ยังไม่จัดการ'
            ,concat(round(
            (
            count(if(datediff(current_date,date(di.created_at))>=17 and di.state in (2,3,4),di.id,null))
            +count(if(datediff(current_date,date(di.created_at))>=17 and di.state=0,di.id,null))
            )/count(if(datediff(current_date,date(di.created_at))>=17,di.id,null))*100
                    ,2),'%') 'D16+未处理完成占比'

        from
            (
                select
                    di.id
                    ,convert_tz(di.created_at,'+00:00','+07:00') created_at
                    ,di.pno
                    ,ddd.cn_element
                    ,pi.ticket_pickup_store_id
                    ,pi.client_id
                    ,cdt.state
                    ,cdt.organization_type
                    ,cdt.organization_id
                    ,cdt.vip_enable
                    ,cdt.service_type
                    ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
                    ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
                from fle_staging.diff_info di
                join fle_staging.parcel_info pi on di.pno=pi.pno
                left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
                join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'
                left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.visit_state in (0,1,2) and vrv.type = 3
                where
                    pi.created_at>=date_sub(current_date,interval 3 month)
                    and di.created_at<=date_sub(current_date,interval 7 hour)
                    and di.created_at > date_sub(curdate(), interval 3 month)

                    and (pi.state=6 or (cdt.state=1 and cdt.updated_at < date_sub(curdate(), interval 7 hour) and cdt.updated_at > date_sub(curdate(), interval 31 hour)))
                    and cdt.state in (0,1,2,3,4)
                    and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
                    and vrv.link_id is null
            ) di
        left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
        left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
        left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
        left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
        group by 1,2,3
    ) a1
left join
    (
        select
            case
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer','Team BD VIP (Retail Management) ') then 'Retail Management'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
                    or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
            end 部门
            ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when coalesce(ss.category,ss2.category) in (11) then 'FFM'
              when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
              when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
              when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
              when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
            end as 处理组织
            ,di.CN_element
            ,count(di.id) 总任务量
        from
            (
                select
                    di.id
                    ,convert_tz(di.created_at,'+00:00','+07:00') created_at
                    ,di.pno
                    ,ddd.cn_element
                    ,pi.ticket_pickup_store_id
                    ,pi.client_id
                    ,cdt.state
                    ,cdt.organization_type
                    ,cdt.organization_id
                    ,cdt.vip_enable
                    ,cdt.service_type
                    ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
                    ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
                from fle_staging.diff_info di
                join fle_staging.parcel_info pi on di.pno=pi.pno
                left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
                join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'
                left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.visit_state in (0,1,2) and vrv.type = 3
                where
                    pi.created_at>=date_sub(current_date,interval 3 month)
                    and di.created_at<=date_sub(current_date,interval 7 hour)
                    and di.created_at > date_sub(curdate(), interval 3 month)
#                     and (pi.state=6 or (cdt.state=1 and date(convert_tz(cdt.updated_at,'+00:00','+07:00'))=date_sub(current_date,interval 1 day)))
#                     and cdt.state = 0
                    and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
                    and vrv.link_id is null
            )di
        left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
        left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
        left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
        left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
        group by 1,2,3
    ) a2 on a1.部门=a2.部门 and a1.处理组织 = a2.处理组织 and a1.CN_element = a2.CN_element
left join
    (
        select
            case
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer','Team BD VIP (Retail Management) ') then 'Retail Management'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
              when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
                    or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
            end 部门
            ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
              when di.organization_type=2 and di.vip_enable=0 then '总部cs'
              when coalesce(ss.category,ss2.category) in (11) then 'FFM'
              when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
              when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
              when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
              when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
            end as 处理组织
            ,di.CN_element
            ,count(di.id) 昨日已完成任务量
        from
            (
                select
                    di.id
                    ,convert_tz(di.created_at,'+00:00','+07:00') created_at
                    ,di.pno
                    ,ddd.cn_element
                    ,pi.ticket_pickup_store_id
                    ,pi.client_id
                    ,cdt.state
                    ,cdt.organization_type
                    ,cdt.organization_id
                    ,cdt.vip_enable
                    ,cdt.service_type
                    ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
                    ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
                from fle_staging.diff_info di
                join fle_staging.parcel_info pi on di.pno=pi.pno
                left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
                join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'
                where
                    pi.created_at>=date_sub(current_date,interval 3 month)
                    and cdt.updated_at <= date_sub(current_date,interval 7 hour)
                    and cdt.updated_at >= date_sub(curdate(), interval 31 hour)
#                     and (pi.state=6 or (cdt.state=1 and date(convert_tz(cdt.updated_at,'+00:00','+07:00'))=date_sub(current_date,interval 1 day)))
#                     and cdt.state in (0,1,2,3,4)
                    and cdt.state = 1
                    and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
            )di
        left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
        left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
        left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
        left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
        group by 1,2,3
    ) a3 on a1.部门=a3.部门 and a1.处理组织 = a3.处理组织 and a1.CN_element = a3.CN_element


;





with t as
    (
        select
            di.id
            ,convert_tz(di.created_at,'+00:00','+07:00') created_at
            ,convert_tz(pi.created_at,'+00:00','+07:00') pi_created_at
            ,di.pno
            ,ddd.cn_element
            ,ddd2.CN_element rejection
            ,pi.ticket_pickup_store_id
            ,pi.client_id
            ,cdt.state
            ,cdt.organization_type
            ,cdt.organization_id
            ,cdt.vip_enable
            ,cdt.service_type
            ,pi.customary_pno
            ,pi.article_category
            ,pd.last_valid_store_id
            ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
            ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
        from fle_staging.diff_info di
        join fle_staging.parcel_info pi on di.pno=pi.pno
        left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
        join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'
        left join dwm.dwd_dim_dict ddd2 on di.rejection_category = ddd2.element and ddd2.db='fle_staging' and ddd2.tablename='diff_info' and ddd2.fieldname='rejection_category'
        left join bi_pro.parcel_detail pd on pd.pno = pi.pno
        left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.visit_state in (0,1,2) and vrv.type = 3
        where
            pi.created_at>=date_sub(current_date,interval 3 month)
            and di.created_at<=date_sub(current_date,interval 7 hour)
            and di.created_at > date_sub(curdate(), interval  3 month)
            and (pi.state=6 or (cdt.state=1 and cdt.updated_at < date_sub(curdate(), interval 7 hour) and cdt.updated_at > date_sub(curdate(), interval 31 hour)))
            and cdt.state in (0,2,3,4)
            and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
            and vrv.link_id is null
    )

select
    case
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer') then 'Retail Management'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
      when di.organization_type=2 and di.vip_enable=0 then '总部cs'
      when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
            or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
    end '部门แผนกที่จัดการ'
    ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
      when di.organization_type=2 and di.vip_enable=0 then '总部cs'
      when coalesce(ss.category,ss2.category) in (11) then 'FFM'
      when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
      when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
      when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
      when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
    end as '处理组织ทีมที่จัดการ'
    ,ss.name '问题件待处理网点สาขาที่จัดการ'
    ,di.pno '包裹号เลขพัสดุ'
    ,di.client_id
    ,di.pi_created_at '揽收时间เวลารับงาน'
    ,case di.article_category
        when 0 then '文件/document'
        when 1 then '干燥食品/dry food'
        when 2 then '日用品/daily necessities'
        when 3 then '数码产品/digital product'
        when 4 then '衣物/clothes'
        when 5 then '书刊/Books'
        when 6 then '汽车配件/auto parts'
        when 7 then '鞋包/shoe bag'
        when 8 then '体育器材/sports equipment'
        when 9 then '化妆品/cosmetics'
        when 10 then '家居用具/Houseware'
        when 11 then '水果/fruit'
        when 99 then '其它/other'
    end '包裹类型ประเภทพัสดุ'
    ,di.customary_pno '退件前单号'
    ,dt.store_name '当前所处网点'
    ,dt.piece_name '当前所处片区'
    ,dt.region_name '当前所处大区'
    ,di.CN_element  '问题件类型ประเภทคำร้อง'
    ,di.rejection 拒收原因
    ,di.created_at '问题件生成时间เวลาที่ติดปัญหาเข้าระบบ'
    ,case di.state
     when 0 then '客服未处理'
     when 1 then '已处理完毕'
     when 2 then '正在沟通中'
     when 3 then '财务驳回'
     when 4 then '客户未处理'
     when 5 then '转交闪速系统'
     when 6 then '转交QAQC'
     end as '处理状态สถานะจัดการปัจจุบัน'
    ,datediff(current_date,date(di.created_at)) '问题件生成天数'
    ,d2.di_count 问题件提交次数
    ,convert_tz(d3.created_at, '+00:00', '+07:00') 第一次提交问题件时间
    ,datediff(curdate(), di.pi_created_at) 揽收至今天数
from t di
left join
    (
        select
            t1.pno
            ,count(distinct di.id) di_count
        from fle_staging.diff_info di
        join t t1 on t1.pno = di.pno
        where
            di.created_at > date_sub(curdate(), interval 6 month )
        group by 1
    ) d2 on d2.pno = di.pno
left join
    (
        select
            t1.pno
            ,di.created_at
            ,row_number() over (partition by t1.pno order by di.created_at) rk
        from fle_staging.diff_info di
        join t t1 on t1.pno = di.pno
        where
            di.created_at > date_sub(curdate(), interval 6 month )
    ) d3 on d3.pno = di.pno and d3.rk = 1
left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = di.last_valid_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
group by 1,2,3,4,5

;


select
    pi.returned_pno
    ,pi.pno
    ,pi.cod_amount/100 cod
from fle_staging.parcel_info pi
where
    pi.returned_pno in ('TH02065VNQWG0C','TH02065VMV6H9C','TH02065VNZES7C','TH02065UPX705C','TH02065UTF0R3C','TH02065UQP619C','TH02065USXPX9C','TH02065UR24K3C','TH02065UT4DE0C','TH02065UT6MG5C','TH02065UT7YN2C','TH02065UT9E00C','TH02065VHTBP5C','TH02065VPK3P4C','TH02065WAABM1C','TH02065W5V3P3C','TH02065WQA0W6C','TH02065WV73G0C','TH02065X99S76C','TH02065XEQ9B7C','TH02065XN2K81C','TH02065VX7C42C','TH02065W2WG81C','TH02065W2S0X3C','TH02065VN0DY9C','TH02065W2ZVG7C','TH02065W2T6B7C','TH02065XQ96P8C','TH02065XTEZ86C','TH02065R678Z9C','TH02065WAKMH7C','TH02065WA4657C','TH02065ZDK9A6C','TH02065ZSQNM4C','TH020360DAEM2A2','TH020360N44Z2A2','TH02065ZDKDY5C','TH02065YHENM0C','TH02065YG4SR2C','TH02065YEXYM1C','TH02065XGD8N2C','TH02065WA80A7C','TH02065URM1S9C','TH02065UTB853C','TH02065UPUSJ3C','TH02065UQ25P6C','TH02065WA00D2C','TH02065W9YYD0C','TH02065W9YZD6C','TH02065WAA855C','TH02065WAB4R9C','TH02065WB8Z90C','TH02065WA8J17C','TH02065WAAHG2C','TH02065WFG0U8C','TH02065WDGQA3C','TH02065WFGKN5C','TH02065WFFCB6C','TH02065WNQXR9C','TH02065WPD4W9C','TH02065WT87C3C','TH02065WR4YQ3C','TH02065X29FS0C','TH02065XEKPB0C','TH02065XGBEG5C','TH02065XGJPE6C','TH02065XK9J38C','TH02065XJZUN7C','TH02065Y44DV2C','TH02065YJP3P6C','TH02065Z25AS3C','TH02065ZAUYQ3C','TH02065W31190C','TH02065W2WVU9C','TH02065W33193C','TH02036158725A2','TH02065ZHJ5M9C','TH02065ZDKHM2C','TH0203614XC12A2','TH02065WUZYS6C')



;


select
    dp.device_id 设备ID
    ,dp.pno
    ,pi.client_id 客户ID
    ,dp.created_at 复称时间
    ,dp.before_weight/1000 复称前重量kg
    ,concat_ws('*', dp.before_length, dp.before_width, dp.before_height) 复称前尺寸
    ,dp.after_weight/1000 复称后重量kg
    ,concat_ws('*', dp.after_length, dp.after_width, dp.after_height) 复称后尺寸
    ,dp.before_parcel_amount/100 复称前运费
    ,dp.after_parcel_amount/100 复称后运费
from dwm.drds_parcel_weight_revise_record_d dp
left join fle_staging.parcel_info pi on pi.pno = dp.pno
where
    dp.device_id in (23010110, 23010111)
    and dp.created_at > '2024-08-01'
    and dp.created_at < '2024-09-01'

;

select
    plt.client_id
    ,plt.pno
from bi_pro.parcel_lose_task plt
where
    plt.state < 5
    and plt.client_id in ('AA0636','BG2222','CAA3709','CAC5925','CAK3170','CAN2192','CAY7719','CAZ2605','CAZ6355','CBC9325','CG1426','CH5857','CJ2579','CR9789','CS5555','CT3945','AA0661','CAV9104','CT3240','CBD1351')


;


select
    t.client 客户ID
    ,t.store
    ,pi.pno
from bi_pro.parcel_claim_task  plt
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
join
    (
        select
            t2.*
            ,ss.id
        from tmpale.tmp_th_store_lj_0918 t2
        left join fle_staging.sys_store ss on ss.name = t2.store
    ) t on t.client = bc.client_name and t.id = pi.dst_store_id
where
    plt.source = 11
    and plt.created_at > '2024-09-01'


;



select
    t.pno
    ,pi.returned_pno 'เลขขาตีกลับ 退件运单号'
    ,ss.name 'สาขาตีกลับ 退件网点'
    ,if(pi2.state = 5, convert_tz(pi2.finished_at, '+00:00', '+07:00'), null) '退件妥投日期วันที่เซ็นรับ '
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0920 t on t.pno = pi.pno
left join fle_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
left join fle_staging.sys_store ss on ss.id = pi2.ticket_pickup_store_id



;


select
    cis.stat_date
    ,count(1)
from bi_pro.cod_info_stat_day_emr cis
where
    cis.stat_date >= '2024-06-01'
group by cis.stat_date

;


select
    pr.staff_info_id 员工
    ,pr.store_name 网点
    ,pr.pno 运单号
    ,ddd.CN_element 动作
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 操作时间
from rot_pro.parcel_route pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.staff_info_id in ('694960', '678414')
    and pr.routed_at > '2024-09-11 17:00:00'
    and pr.routed_at < '2024-09-13 17:00:00'




;





select
    pr.pno
    ,pr.staff_info_id 员工
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
    end 包裹状态
    ,if(pi.state = 5, datediff(convert_tz(pi.finished_at, '+00:00', '+07:00'), pr.pr_date), null)  状态为已妥投的话当天妥投还是几天后妥投
    ,oi.cod_amount/100
    ,pr.pr_date 交接日期
    ,pr.pr_time 交接时间
    ,ad.attendance_end_at 下班时间
from
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,convert_tz(pr.routed_at, '+00:00', '+07:00') pr_time
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,pr.staff_info_id
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from rot_pro.parcel_route pr
                where
                    pr.routed_at > date_sub(curdate(), interval 7 day)
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) pr
        where
            pr.rk = 1
    ) pr
left join backyard_pro.attendance_data_v2 ad on ad.staff_info_id = pr.staff_info_id and ad.stat_date = pr.pr_date
left join fle_staging.parcel_info pi on pi.pno = pr.pno
left join fle_staging.order_info oi on oi.pno = coalesce(pi.customary_pno, pi.pno)
left join backyard_pro.staff_audit sa on sa.staff_info_id = pr.staff_info_id and sa.audit_type = 1 and sa.attendance_type in (2,4) and sa.attendance_date = ad.stat_date
where
    ad.attendance_end_at < pr.pr_time
    and sa.staff_info_id is null


;


select
    t.pno
    ,if(pi.returned = 1, '退件', '正向') 包裹流向
    ,pi.dst_detail_address  收件地址
    ,if(pr.pno is not null, 'y', 'n') 是否使用批量妥投
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0929 t on t.pno = pi.pno
left join rot_pro.parcel_route pr on pr.pno = t.pno and pr.route_action = 'DELIVERY_CONFIRM' and pr.remark in ('ปิดงานหลายรายการ', 'Batch Delivered', '批量妥投') and pr.routed_at > date_sub(curdate(), interval 2 month)



;



select
    pi.pno
    ,oi.cod
    ,oi.cogs
    ,coalesce(if(oi.cod = 0, null, oi.cod), if(oi.cogs = 0, null, oi.cogs), 0) new_value
    ,pr.action
    ,pr.store_name
    ,pr.staff_info_name
    ,pr.staff_info_id
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') route_time
from
    (
        select
            pi.pno
            ,coalesce(pi.customary_pno, pi.pno) new_pno
        from fle_staging.parcel_info  pi
        where
            pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
            and pi.created_at >= date_sub(curdate(), interval 2 month)
    ) pi
join
    (
        select
            oi.pno
            ,oi.cogs_amount/100 cogs
            ,oi.cod_amount/100 cod
        from fle_staging.order_info  oi
        where
            oi.created_at >= date_sub(curdate(), interval 2 month)
			and oi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
    ) oi on oi.pno = pi.new_pno
left join
    (
        select
            pr.*
            ,ddd.cn_element action
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_name
                    ,pr.route_action
                    ,pr.routed_at
                    ,row_number() over(partition by pr.pno order by pr.routed_at desc ) as rk
                from rot_pro.parcel_route  pr
                where
                    pr.routed_at >=  date_sub(curdate(), interval 2 month)
					and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
                    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            ) pr
        left join
            (
                select
                    *
                from dwm.dwd_dim_dict  ddd
                where
                    ddd.db = 'rot_pro'
                    and ddd.tablename = 'parcel_route'
                    and ddd.fieldname = 'route_action'
            ) ddd on ddd.element = pr.route_action
        where
            pr.rk = 1
    ) pr on pr.pno = pi.pno


;




select
    count(1)
from fle_staging.parcel_info pi
join backyard_pro.hr_staff_apply_support_store hsa on hsa.sub_staff_info_id = pi.ticket_pickup_staff_info_id
where
    pi.created_at > '2024-08-31 17:00:00'
    and pi.created_at < '2024-09-30 17:00:00'
    and pi.state < 9
    and hsa.staff_info_id = '700787'


;



select
    hsa.sub_staff_info_id
from backyard_pro.hr_staff_apply_support_store hsa
where
    hsa.staff_info_id = 707990

;


select
    t.staff
    ,hsi.sys_store_id 网点ID
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,hsi.mobile_company 企业号码
    ,hsi.mobile 个人号码
from bi_pro.hr_staff_info hsi
join tmpale.tmp_th_staff_1017 t on t.staff = hsi.staff_info_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = hsi.sys_store_id and dt.stat_date = date_sub(curdate(), 1)


;








with t as
    (
        select
            a.*
        from
            (
                select
                    a2.*
                    ,row_number() over (partition by a2.pno order by a2.result_rank desc ) rk
                from
                    (
                        select
                            a1.pno
                            ,a1.client_id
                            ,case
                                when bc.client_id is not null then bc.client_name
                                when bc.client_id is null and kp.id is not null then 'KA'
                                else 'GE'
                            end client_name
                            ,case
                                when a1.dutyresult = 3 then 3
                                when a1.dutyresult = 1 then 2
                                when a1.dutyresult = 2 then 1
                            end result_rank
                            ,a1.parcel_created_at
                            ,a1.updated_at
                            ,a1.source
                            ,a1.link_type
                            ,a1.duty_reasons
                        from
                            (
                                select
                                    pct.pno
                                    ,pct.client_id
                                    ,pct.parcel_created_at
                                    ,'3' dutyresult
                                    ,pct.updated_at
                                    ,'' link_type
                                    ,pct.source
                                    ,'' duty_reasons
                                from bi_pro.parcel_claim_task pct
                                left join fle_staging.parcel_info pi on pi.pno = pct.pno and pi.created_at > date_sub(curdate(), interval 3 month)
                                left join bi_pro.parcel_claim_task pct2 on pct2.pno = pi.customary_pno and pct.source = 11 and pct2.created_at > date_sub('${sdate}', interval 2 month)
                                where
                                    pct.source = 11
                                    and pct.created_at > '${sdate}'
                                    and pct.created_at < date_add('${edate}', interval 1 day)
                                    and pct2.pno is null

                                union all

                                select
                                    plt.pno
                                    ,plt.client_id
                                    ,plt.parcel_created_at
                                    ,plt.duty_result
                                    ,plt.updated_at
                                    ,plt.link_type
                                    ,plt.source
                                    ,plt.duty_reasons
                                from bi_pro.parcel_lose_task plt
                                where
                                    plt.state = 6
                                    and plt.source != 11
                                    and plt.duty_result in (1,2)
                                    and plt.penalties > 0
                                    and plt.updated_at > '${sdate}'
                                    and plt.updated_at < date_add('${edate}', interval 1 day)
                            ) a1
                        left join fle_staging.ka_profile kp on kp.id = a1.client_id
                        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a1.client_id
                    ) a2
            ) a
        where
            a.rk = 1
    )
, val as
    (
        select
            t1.pno
            ,t1.client_name
            ,t1.client_id
            ,t1.result_rank
            ,p1.state
            ,case
                when t1.client_name = 'tiktok' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 2000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_name = 'tiktok' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 2000 then 2000
                when t1.client_name = 'lazada' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 6000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_name = 'lazada' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 6000 then 6000
                when t1.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0771','AA0731','AA0657','AA0707','AA0736','AA0838') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 3000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0771','AA0731','AA0657','AA0707','AA0736','AA0838') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 3000 then 3000
                when t1.client_id in ('AA0572', 'AA0574', 'AA0606', 'AA0612') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 15000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_id in ('AA0572', 'AA0574', 'AA0606', 'AA0612') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 15000 then 15000
                when t1.client_name = 'shopee' and t1.client_id not in ('AA0572', 'AA0574', 'AA0606', 'AA0612','AA0386','AA0425','AA0427','AA0569','AA0771','AA0731','AA0657','AA0707','AA0736','AA0838') then if(coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) > 2000, 2000, coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100))
                when t1.client_id = 'AA0306' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 5000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_id = 'AA0306' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 5000 then 5000
                when t1.client_name in ('KA','GE') and t1.client_id != 'AA0306'  and greatest(ifnull(coalesce(oi.cogs_amount/100, p2.cod_amount/100), 0), ifnull(oi.insure_declare_value/100, 0)) < 2000 and greatest(ifnull(coalesce(oi.cogs_amount/100, p2.cod_amount/100), 0), ifnull(oi.insure_declare_value/100, 0)) > 0 then greatest(ifnull(coalesce(oi.cogs_amount/100, p2.cod_amount/100), 0), ifnull(oi.insure_declare_value/100, 0))
                else 1018
            end parcel_value
            ,p2.store_total_amount/100 store_total_amount
            ,p2.cod_amount/100 cod
            ,oi.cogs_amount/100 cogs
        from t t1
        left join fle_staging.parcel_info p1 on p1.pno = t1.pno and p1.created_at > date_sub('${sdate}', interval 3 month)
        left join fle_staging.parcel_info p2 on p2.pno = if(p1.returned = 1, p1.customary_pno, p1.pno) and p2.created_at > date_sub('${sdate}', interval 2 month)
        left join fle_staging.order_info oi on oi.pno = if(p1.pno is null, t1.pno, p2.pno)
    )
, cla as
    (
        select
            a1.*
        from
            (
                select
                    pct.pno
                    ,json_extract(pcn.neg_result,'$.money') claim_value
                    ,row_number() over (partition by pcn.task_id order by pcn.created_at desc) rk
                from bi_pro.parcel_claim_task pct
                join t t1 on t1.pno = pct.pno
                left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct.id
                where
                    pct.created_at > date_sub('${sdate}', interval 4 month)
                    and pct.state = 6
            ) a1
        where
            a1.rk = 1
    )
, pcm as
    (
        select
            pct.pno
            ,pct.claims_amount/100 claim_money
        from fle_staging.pickup_claims_ticket pct
        join t t1 on t1.pno = pct.pno
        where
            pct.pickup_at > date_sub('${sdate}', interval 3 month)
            and pct.state = 6
            and pct.claims_type_category = 1
    )
select
    t1.parcel_created_at 揽件时间
    ,t1.pno 运单号
    ,t1.client_name 客户类型
    ,t1.client_id 客户ID
    ,v1.cod COD
    ,v1.cogs COGS
    ,v1.store_total_amount 运费
    ,coalesce(c1.claim_value, pc.claim_money, v1.parcel_value) 预估赔付金额
    ,coalesce(c1.claim_value, pc.claim_money) 实际赔付金额
    ,if(t1.result_rank = 3, sla.updated_at, t1.updated_at) 判责时间
    ,case t1.result_rank
        when 3 then '超时效'
        when 2 then '丢失'
        when 1 then '破损'
    end 判责类型
    ,t.t_value 原因
    ,case t1.source
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
    end 问题来源
    ,case if(t1.result_rank = 3, sla.link_type, t1.link_type)
        when 0 then 'ipc计数后丢失'
        when 1 then '揽收网点已揽件，未收件入仓'
        when 2 then '揽收网点已收件入仓，未发件出仓'
        when 3 then '中转已到件入仓扫描，中转未发件出仓'
        when 4 then '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
        when 5 then '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
        when 6 then '分拨发件出仓扫描，目的地未到件入仓(集包)'
        when 7 then '分拨发件出仓扫描，目的地未到件入仓(单件)'
        when 8 then '目的地到件入仓扫描，目的地未交接,当日遗失'
        when 9 then '目的地到件入仓扫描，目的地未交接,次日遗失'
        when 10 then '目的地交接扫描，目的地未妥投'
        when 11 then '目的地妥投后丢失'
        when 12 then '途中破损/短少'
        when 13 then '妥投后破损/短少'
        when 14 then '揽收网点已揽件，未收件入仓'
        when 15 then '揽收网点已收件入仓，未发件出仓'
        when 16 then '揽收网点发件出仓到分拨了'
        when 17 then '目的地到件入仓扫描，目的地未交接'
        when 18 then '目的地交接扫描，目的地未妥投'
        when 19 then '目的地妥投后破损短少'
        when 20 then '分拨已发件出仓，下一站分拨未到件入仓(集包)'
        when 21 then '分拨已发件出仓，下一站分拨未到件入仓(单件)'
        when 22 then 'ipc计数后丢失'
        when 23 then '超时效sla'
        when 24 then '分拨发件出仓到下一站分拨了'
	end 判责环节
    ,if(t1.result_rank = 3, sla.duty_store, ld.duty_store) 责任网点
    ,if(t1.result_rank = 3, sla.duty_category, ld.duty_category) 责任组织类型
    ,case v1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 包裹状态
    ,case
        when t1.result_rank = 3 and plt.pno is not null then '丢失'
        when t1.result_rank = 3 and plt.pno is null and pi2.state = 8 then '拍卖仓妥投'
        when t1.result_rank = 3 and pi2.state = 5 and pi2.cod_enabled = 1 then 'COD妥投'
        when t1.result_rank = 3 and pi2.state not in (5,7,8,9) then '未达终态'
    end '当前环节（超时效）'
    ,case
        when t1.result_rank = 2 and pct.pno is not null then '寄件人理赔'
        when t1.result_rank = 2 and pct.pno is null then '网点理赔'
        when t1.result_rank = 1 and pct3.source in (4,6) and pct3.claim_target = 2 then '收件人理赔'
        when t1.result_rank = 1 and pct3.source in (4,6) and pct3.claim_target = 1 then '寄件人理赔'
        when t1.result_rank = 1 and pct3.source in (9,10) then '仅外包装破损'
    end '理赔对象'
    ,if(srb.pno is not null, '否', '是') COD是否回款
from t t1
left join val v1 on v1.pno = t1.pno
left join cla c1 on c1.pno = t1.pno
left join pcm pc on pc.pno = t1.pno
left join
    (
        select
            t1.pno
            ,plt.link_type
            ,plt.duty_reasons
            ,plt.updated_at
            ,group_concat(distinct ss.name) duty_store
            ,group_concat(distinct case ss.category when 1 then 'SP' when 2 then 'DC' when 4 then 'SHOP' when 5 then 'SHOP' when 6 then 'FH' when 7 then 'SHOP' when 8 then 'Hub' when 9 then 'Onsite' when 10 then 'BDC' when 11 then 'fulfillment' when 12 then 'B-HUB' when 13 then 'CDC' when 14 then 'PDC' end) duty_category
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno and t1.result_rank = 3
        left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.source = 11
            and plt.state = 6
            and plt.parcel_created_at > date_sub('${sdate}', interval 3 month)
        group by 1,2,3
    ) sla on sla.pno = t1.pno
left join
    (
        select
            t1.pno
            ,group_concat(distinct ss.name) duty_store
            ,group_concat(distinct case ss.category when 1 then 'SP' when 2 then 'DC' when 4 then 'SHOP' when 5 then 'SHOP' when 6 then 'FH' when 7 then 'SHOP' when 8 then 'Hub' when 9 then 'Onsite' when 10 then 'BDC' when 11 then 'fulfillment' when 12 then 'B-HUB' when 13 then 'CDC' when 14 then 'PDC' end) duty_category
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno and t1.result_rank in (1,2)
        left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.source != 11
            and plt.state = 6
            and plt.parcel_created_at > date_sub('${sdate}', interval 3 month)
        group by 1
    ) ld on ld.pno = t1.pno
left join bi_pro.translations t on if(t1.result_rank = 3, sla.duty_reasons, t1.duty_reasons) = t.t_key AND t.`lang` = 'zh-CN'
left join fle_staging.parcel_info pi2 on pi2.pno = t1.pno and pi2.created_at > date_sub('${sdate}', interval 2 month)
left join bi_pro.parcel_lose_task plt on plt.pno = t1.pno and plt.source = 11 and plt.parcel_created_at > date_sub('${sdate}', interval 2 month) and plt.state = 6 and plt.duty_result = 1
left join bi_pro.parcel_claim_task pct on pct.pno = t1.pno and pct.parcel_created_at > date_sub('${sdate}', interval 2 month) and pct.source in (1,2,3,5,7,8,12) and pct.state < 7
left join bi_pro.parcel_claim_task pct3 on pct3.pno = t1.pno and pct3.parcel_created_at > date_sub('${sdate}', interval 2 month) and pct3.source in (4,6,9,10) and pct3.state < 7
left join fle_staging.store_receivable_bill_detail srb on srb.pno = t1.pno and srb.receivable_type_category = 5 and srb.state = 0
left join
    (
        select
            pct.pno
        from bi_pro.parcel_claim_task pct
        join t t1 on t1.pno = pct.pno
        where
            pct.state in (7,8)
        group by 1
    ) p1 on p1.pno = t1.pno
left join
    (
        select
            pct.pno
        from bi_pro.parcel_claim_task pct
        join t t1 on t1.pno = pct.pno
        where
            pct.state < 7
        group by 1
    ) p2 on p2.pno = t1.pno
where
    p1.pno is null
    or (p1.pno is not null and p2.pno is not null)



;




select
    t.pno
    ,pi.ticket_pickup_staff_info_id
    ,ss.name
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_1022 t on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id



;

select
    t.pno
    ,if(sc.store_id is not null or ss.category = 9, '是', '否') 是否OS揽收
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_1106 t on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.scheduling_center_virtual_store sc
    on sc.relate_hash_id = sha2
                            (if(pi.ka_warehouse_id is not null,concat(pi.client_id, pi.ka_warehouse_id),
                            concat(pi.client_id,pi.src_phone,pi.src_province_code,pi.src_city_code,ifnull(pi.src_district_code, ''),pi.src_postal_code,pi.src_detail_address)
                ),'256')




;



select
    'wrs里程审核' 任务类型
    ,'${start_date}' dat
    ,count(distinct if(date(convert_tz(ft.start_at,'+00:00','+07:00')) = '${start_date}',smr.id, null)) 当日新增量
    ,count(distinct if(convert_tz(ft.start_at,'+00:00','+07:00') < '${start_date}' and (date(convert_tz(ft.end_at,'+00:00','+07:00'))>='${start_date}' or ft.input_state=1), smr.id, null)) 历史积压量
    ,max(if(ft.input_state = 1 or (date(convert_tz(ft.end_at,'+00:00','+07:00'))>='${start_date}'), datediff('${start_date}', convert_tz(ft.start_at,'+00:00','+07:00')), 0)) 最长积压天数
    ,count(distinct if(date(convert_tz(ft.start_at,'+00:00','+07:00')) = '${start_date}',smr.id, null))+count(distinct if(convert_tz(ft.start_at,'+00:00','+07:00') < '${start_date}' and (date(convert_tz(ft.end_at,'+00:00','+07:00'))>='${start_date}' or ft.input_state=1), smr.id, null)) 当日待处理总量
    ,count(distinct if(ft.input_state =4 and date(convert_tz(ft.end_at,'+00:00','+07:00')) = '${start_date}', smr.id, null)) 当日已判责的任务量
    ,count(distinct if(ft.input_state =2 and date(convert_tz(ft.end_at,'+00:00','+07:00')) = '${start_date}', smr.id, null)) 当日无需追责的任务量
    ,count(dis)
    ,'0'  当日系统自动处理的量
    ,''  当日已发工单的任务量
    ,''  当日工单待回复的任务量
    ,''  当日已回复工单未判责的任务量
    ,count(distinct if(date(convert_tz(ft.end_at,'+00:00','+07:00')) = '${start_date}', smr.id, null)) 当日已处理总量
    ,count(distinct if(convert_tz(ft.start_at,'+00:00','+07:00') < '${start_date}' and date(convert_tz(ft.end_at,'+00:00','+07:00')) = '${start_date}' , smr.id ,null)) 当日已处理积压量
    ,count(distinct if(date(convert_tz(ft.start_at,'+00:00','+07:00')) = '${start_date}' and date(convert_tz(ft.end_at,'+00:00','+07:00')) = '${start_date}' , smr.id ,null)) 当日已处理新增量
from backyard_pro.staff_mileage_record smr
join wrs_production.fuel_task ft on smr.ft_id =ft.id
where ft.type=1
and ft.input_state !=5 -- 任务回收
group by 1,2

;

select
    month(convert_tz(ft.start_at, '+00:00', '+07:00')) 月份
    ,count(distinct smr.id) 总量
from backyard_pro.staff_mileage_record smr
join wrs_production.fuel_task ft on ft.id = smr.ft_id
where
    ft.start_at > '2024-08-31 17:00:00'
    and ft.start_at < '2024-10-31 17:00:00'
group by 1


;


select
#     count(distinct a1.pno) 包裹量
    a1.pno
from
    (
        select
            a.*
        from
            (
                select
                    pssn.pno
                    ,pssn.store_category
                    ,pssn.last_valid_route_action
                    ,pssn.last_valid_routed_at
                    ,row_number() over (partition by pssn.pno order by pssn.last_valid_routed_at desc) rk
                from dw_dmd.parcel_store_stage_new pssn
                where
                    pssn.created_at > date_sub(curdate(), interval 7 day)
                    and pssn.valid_store_order is not null
            ) a
        where
            a.rk = 1
    ) a1
where
    a1.store_category in (8,12)
    and a1.last_valid_route_action not in ('SHIPMENT_WAREHOUSE_SCAN')
    and timestampdiff(hour, a1.last_valid_routed_at, now()) > 31
    and a1.last_valid_routed_at > '2024-11-12 17:00:00'
    and a1.last_valid_routed_at < '2024-11-13 17:00:00'



;


select
    pr.pno
    ,pr.CN_element 最新有效路由
    ,pr.当前状态
from
    (

        select
            pr.pno
            ,ddd.CN_element
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
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        left join fle_staging.parcel_info pi on pi.pno = pr.pno
        join tmpale.tmp_th_pno_lj_1119 t on t.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr
where
    pr.rk = 1

;

select
    *
from fle_staging.sys_store ss
where
    ss.name = '05 LAS_HUB-ลาซาล'

;
select
    t.pno
    ,pr.store_name 发件网点
    ,if(json_extract(pr.extra_value, '$.packPno') is not null, 'y', 'n') 是否集包
from rot_pro.parcel_route pr
join tmpale.tmp_th_pno_lj_1119 t on t.pno = pr.pno
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.routed_at > date_sub(curdate(), interval 2 month)
    and pr.next_store_id = 'TH02030204' -- LAS


    ;

select
    a.pno
    ,ss.name
    ,ft.plan_arrive_time
from
    (
        select
            t.pno
            ,pr.extra_value
            ,pi.dst_store_id
            ,row_number() over (partition by t.pno order by pr.routed_at desc) rk
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_pno_lj_1119 t on t.pno = pi.pno
        join rot_pro.parcel_route pr on pr.pno = t.pno and pr.store_id = pi.dst_store_id
        where
            pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN'
            and pr.routed_at > '2024-09-01'
            and pi.created_at > '2024-09-01'
    ) a
left join fle_staging.sys_store ss on ss.id = a.dst_store_id
left join bi_pro.fleet_time ft on ft.proof_id = json_extract(a.extra_value, '$.proofId') and a.dst_store_id = ft.next_store_id
where
    a.rk = 1


;


select
    t.pno
    ,ss.name
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
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_1127 t on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id


;



select
    t.pno
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
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_1129 t on t.pno = pi.pno


;




刘章
select
		pi.client_id
		, spco_109.pno
		, pi.returned_pno
		, case when pi.exhibition_length > 35 or pi.exhibition_width > 35 or pi.exhibition_height > 35 then 'bulky' else null end as type
		, ssd.last_en_marker_category as reason_for_rts
		, spco_102.status_update_time as forward_pickup_date
		, spco_109.status_update_time as return_pickup_date
		, ssd.cogs_amount / 100 as cogs_amount
		, spco_last.store_name as current_location
		, pi.exhibition_length as Actual_package_length
		, pi.exhibition_width as Actual_package_width
		, pi.exhibition_height as Actual_package_height
		, round(pi.exhibition_weight/1000,2) as Actual_Weight
		, spco_arrival.store_name as returned_hub_name
		, spco_arrival.status_update_time as returned_hub_arrival_time
		, case when hour(spco_arrival.status_update_time) >= 17 then DATE_ADD(date(spco_arrival.status_update_time),INTERVAL 1 DAY)
				else date(spco_arrival.status_update_time) end as p_date
        , now() as update_at
from
(  -- 109
		select
			 ca.pno
			,min(convert_tz(ca.status_update_time,'+00:00','+08:00')) status_update_time
		from ph_drds.shopee_callback_record ca
		where ca.callback_type=1
		and ca.status_code in ('109')
		and ca.status_update_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
		group by 1
) spco_109
left join
( -- '107','110','126','111','120'
		select
			 ca.pno
			,min(convert_tz(ca.status_update_time,'+00:00','+08:00')) status_update_time
		from ph_drds.shopee_callback_record ca
		where ca.callback_type=1
		and ca.status_code in ('107','110','126','111','120')
		and ca.status_update_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
		group by 1
) spco_final on spco_109.pno = spco_final.pno
left join
(  -- 到达
		select
			 ca.pno
			,SUBSTRING_INDEX(ca.location,",",-1) store_name
			,convert_tz(ca.status_update_time,'+00:00','+08:00') status_update_time
			,ROW_NUMBER() OVER(PARTITION BY ca.pno ORDER BY ca.status_update_time desc) as rn
		from ph_drds.shopee_callback_record ca
		left join
		(  -- 109
				select
					 ca.pno
					,min(convert_tz(ca.status_update_time,'+00:00','+08:00')) status_update_time
				from ph_drds.shopee_callback_record ca
				where ca.callback_type=1
				and ca.status_code in ('109')
				and ca.status_update_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
				group by 1
		) spco_109 on ca.pno = spco_109.pno
		where ca.callback_type=1
				and ca.status_update_time > spco_109.status_update_time
				and SUBSTRING_INDEX(ca.location,",",-1) in ('01 PN1-HUB_Maynila', 'PN5-CS3', 'PN1-CS3')
) spco_arrival on spco_109.pno = spco_arrival.pno and spco_arrival.rn = 1
left join ph_staging.parcel_info pi on spco_109.pno = pi.pno
left join dwm.dwd_ex_ph_shopee_sla_detail ssd on spco_109.pno = ssd.pno
left join
(  -- 109
		select
			 ca.pno
			,min(convert_tz(ca.status_update_time,'+00:00','+08:00')) status_update_time
		from ph_drds.shopee_callback_record ca
		where ca.callback_type=1
		and ca.status_code in ('102')
		and ca.status_update_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
		group by 1
) spco_102 on spco_109.pno = spco_102.pno
left join
(
		select
				ca.*
		from
		(
				select
					 ca.pno
					,SUBSTRING_INDEX(ca.location,",",-1) store_name
					,convert_tz(ca.status_update_time,'+00:00','+08:00') status_update_time
					,ROW_NUMBER() OVER(PARTITION BY ca.pno ORDER BY ca.status_update_time desc) as rn
				from ph_drds.shopee_callback_record ca
				where ca.callback_type=1
				and ca.status_update_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
		) ca
		where rn = 1
) spco_last on spco_109.pno = spco_last.pno
where pi.client_id = 'AA0164'
	and spco_final.pno is null
	and spco_arrival.pno is not null


;


select
    *
from fle_staging.fleet_van_proof_parcel_detail fvp
where
    fvp.proof_id = 'AYU16SVU81'
    and fvp.state < 4



;


select
    hsi.name
    ,hsi.job_title_grade_v2
from bi_pro.hr_staff_info hsi
where
    hsi.job_title_grade_v2 >= 19
    and hsi.state = 1
order by hsi.job_title_grade_v2 desc


;


SELECT
    `apply_no`
     ,COUNT(`apply_no` )
FROM  oa_production.`material_asset_apply_product`
where `this_time_num` != `last_time_num`
and `last_time_num` is not null
GROUP BY `apply_no`

;




select
    hsa.sub_staff_info_id
    ,hsa.staff_info_id 员工号
    ,ss.name 原工号所属网点
    ,case
        when hsi.state = 1 and hsi.wait_leave_state = 0 then '在职'
        when hsi.state = 1 and hsi.wait_leave_state = 1 then '待离职'
        when hsi.state = 2 then '离职'
        when hsi.state = 3 then '停职'
    end 在职状态
from backyard_pro.hr_staff_apply_support_store  hsa
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = hsa.staff_info_id
left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    hsa.sub_staff_info_id in (4870943, 4864842,4840365)



;


select
    hsa.sub_staff_info_id
    ,hsa.staff_info_id
    ,ss.name
from backyard_pro.hr_staff_apply_support_store hsa
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = hsa.staff_info_id
left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    hsa.sub_staff_info_id in (4873718,4873714)


;



select
    hsi.*
from bi_pro.hr_staff_info hsi
where
    hsi.job_title_grade_v2 >= 23
    and hsi.state = 1


;




select
    kp.id
    ,sd.name
from fle_staging.ka_profile kp
left join fle_staging.sys_department sd on sd.id = kp.department_id
where
    sd.name = 'Retail Management'
    and kp.id  = 'CAK2762'


;


select
    pi.pno
    ,ss.name 网点
    ,pr.staff_info_id 操作待退件员工
    ,pr.store_name 操作部门
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 操作时间
    ,'待退件标记未退件' 类型
from rot_pro.parcel_route pr
where
    pr.routed_at > '2024-01-07 '

;


select
    pi.pno
    ,pi.client_id
    ,case pi.cod_enabled
        when 0 then 'n'
        when 1 then 'y'
    end 是否COD
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_250306 t on t.pno = pi.pno


;

select
    t.proof_id
    ,hlt.begin_unloading_at
    ,hlt.end_unloading_at
from tmpale.tmp_th_proof_lj_0312 t
left join hbi.hub_loading_timeline_monitor hlt on hlt.proof_id = t.proof_id and hlt.loading_type = 2



;


select
    wo.order_no
from bi_pro.work_order wo
left join bi_pro.work_order_reply wor on wor.order_id = wo.id
where
    wor.staff_info_id = 79895
    and wor.created_at > '2025-03-18'

;




select
    pr.pno
    ,pr.staff_info_id 操作人员
    ,pr.store_name 网点
    ,pr.route_action 路由动作En
    ,ddd.CN_element 路由动作Cn
    ,convert_tz(pr.routed_at, '+00:00', '+07:00')  操作时间
#     ,pi.exhibition_weight/1000 重量
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
from rot_pro.parcel_route pr
left join fle_staging.parcel_info pi on pi.pno = pr.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.staff_info_id = '721744'
    and pr.routed_at >= '2025-04-22 17:00:00'
    and pr.routed_at <= '2025-04-23 17:00:00'
;



select pi.pno
from fle_staging.parcel_info pi
         join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
where pi.created_at > '2025-04-01 00:00:00'
  and pi.created_at < '2025-04-02 00:00:00'
  and bc.client_name = 'tiktok'
  and pi.cod_enabled = 1
  and pi.state = 7


;

select
    t.*
    ,ss.name 上报网点
    ,case t.submit_channel_category
        when 0 then 'PC小标签'
        when 1 then 'WEB'
        when 2 then 'app'
        when 3 then 'bs'
        when 4 then '巴枪'
        when 5 then 'ms'
        when 6 then '代收点H5'
        when 7 then '代收点APP'
        when 8 then 'Shipsmile_Cplus'
    end 提交渠道
from tmpale.tmp_th_pno_lj_0411 t
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = t.submitter_id
left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id

;


select
    vrv_1.link_id
    ,case vrv_1.visit_result
                when 1 then '联系不上'
                when 2 then '取消原因属实、合理'
                when 3 then '快递员虚假标记/违背客户意愿要求取消'
                when 4 then '多次联系不上客户'
                when 5 then '收件人已签收包裹'
                when 6 then '收件人未收到包裹'
                when 7 then '未经收件人允许投放他处/让他人代收'
                when 8 then '快递员没有联系客户，直接标记收件人拒收'
                when 9 then '收件人拒收情况属实'
                when 10 then '快递员服务态度差'
                when 11 then '因快递员未按照收件人地址送货，客户不方便去取货'
                when 12 then '网点派送速度慢，客户不想等'
                when 13 then '非快递员问题，个人原因拒收'
                when 14 then '其它'
                when 15 then '未经客户同意改约派件时间'
                when 16 then '未按约定时间派送'
                when 17 then '派件前未提前联系客户'
                when 18 then '收件人拒收情况不属实'
                when 19 then '快递员联系客户，但未经客户同意标记收件人拒收'
                when 20 then '快递员要求/威胁客户拒收'
                when 21 then '快递员引导客户拒收'
                when 22 then '其他'
                when 23 then '情况不属实，快递员虚假标记'
                when 24 then '情况不属实，快递员诱导客户改约时间'
                when 25 then '情况属实，客户原因改约时间'
                when 26 then '客户退货，不想购买该商品'
                when 27 then '客户未购买商品'
                when 28 then '客户本人/家人对包裹不知情而拒收'
                when 29 then '商家发错商品'
                when 30 then '包裹物流派送慢超时效'
                when 31 then '快递员服务态度差'
                when 32 then '因快递员未按照收件人地址送货，客户不方便去取货'
                when 33 then '货物验收破损'
                when 34 then '无人在家不便签收'
                when 35 then '客户错误拒收包裹'
                when 36 then '快递员按照要求当场扫描揽收'
                when 37 then '快递员未按照要求当场扫描揽收'
                when 38 then '无所谓，客户无要求'
                when 39 then '包裹未准备好 - 情况不属实，快递员虚假标记'
                when 40 then '包裹未准备好 - 情况属实，客户存在未准备好的包裹'
                when 41 then '虚假修改包裹信息'
                when 42 then '修改包裹信息属实'
                when 43 then '客户需要包裹，继续派送'
                when 44 then '客户不需要包裹，操作退件'
                when 45 then '电话号码错误/电话号码是空号'
                else vrv_1.visit_result
            end as 回访结果
from
    (
                select
            vrv.link_id
            ,vrv.visit_result
            ,row_number() over (partition by vrv.link_id order by vrv.created_at desc) rn
        from nl_production.violation_return_visit vrv
        join tmpale.tmp_th_pno_lj_0421 t on t.pno = vrv.link_id
        where
            vrv.created_at > '2025-01-01'
    ) vrv_1
where
    vrv_1.rn = 1


;




select
    *
from
    (
        select
            pi.dst_name
            ,pi.dst_phone
            ,pi.ticket_delivery_staff_info_id
            ,ft.line_name
            ,pi.pno
            ,count(pi.pno) over (partition by pi.dst_name, pi.dst_phone, pi.ticket_delivery_staff_info_id, ft.line_name) cnt
        from
            (
                select
                    pi.dst_name
                    ,pi.dst_phone
                    ,pi.ticket_delivery_staff_info_id
                    ,pi.ticket_delivery_store_id
                    ,pr.extra_value
                    ,pi.pno
                    ,row_number() over (partition by pi.pno order by pr.routed_at desc) rk
                from fle_staging.parcel_info pi
                left join rot_pro.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > '2025-03-01' and pr.store_id = pi.dst_store_id
                where
                    pi.state = 5
                    and pi.finished_at > '2025-04-22 17:00:00'
                    and pi.finished_at < '2025-04-23 17:00:00'
                         --   and pi.dst_name = ' กัญญา ลามีร'
            ) pi
        left join bi_pro.fleet_time ft on ft.proof_id = json_extract(pi.extra_value, '$.proofId') and pi.ticket_delivery_store_id = ft.next_store_id
        where
            pi.rk = 1
    ) pi
where
    pi.cnt >= 3

;



with t as
    (
        select
            a.*
        from
            (
                select
                    a2.*
                    ,row_number() over (partition by a2.pno order by a2.result_rank desc ) rk
                from
                    (
                        select
                            a1.pno
                            ,a1.client_id
                            ,case
                                when bc.client_id is not null then bc.client_name
                                when bc.client_id is null and kp.id is not null then 'KA'
                                else 'GE'
                            end client_name
                            ,kp.name
                            ,cg.name group_name
                            ,case
                                when a1.dutyresult = 3 then 3
                                when a1.dutyresult = 1 then 2
                                when a1.dutyresult = 2 then 1
                            end result_rank
                            ,a1.parcel_created_at
                            ,a1.updated_at
                            ,a1.source
                            ,a1.link_type
                            ,a1.duty_reasons
                            ,a1.created_at
                        from
                            (
                                select
                                    pct.pno
                                    ,pct.client_id
                                    ,pct.parcel_created_at
                                    ,'3' dutyresult
                                    ,pct.updated_at
                                    ,'' link_type
                                    ,pct.source
                                    ,'' duty_reasons
                                    ,pct.created_at
                                from bi_pro.parcel_claim_task pct
                                left join fle_staging.parcel_info pi on pi.pno = pct.pno and pi.created_at > date_sub(curdate(), interval 3 month)
                                left join bi_pro.parcel_claim_task pct2 on pct2.pno = pi.customary_pno and pct.source = 11 and pct2.created_at > date_sub(date_sub(curdate(), interval 15 day), interval 2 month)
                                where
                                    pct.source = 11
                                    and pct.created_at > date_sub(curdate(), interval 15 day)
                                    and pct.created_at < date_add(date_sub(curdate(), interval 1 day), interval 1 day)
                                    and pct2.pno is null

                                union all

                                select
                                    plt.pno
                                    ,plt.client_id
                                    ,plt.parcel_created_at
                                    ,plt.duty_result
                                    ,plt.updated_at
                                    ,plt.link_type
                                    ,plt.source
                                    ,plt.duty_reasons
                                    ,'' created_at
                                from bi_pro.parcel_lose_task plt
                                where
                                    plt.state = 6
                                    and plt.source != 11
                                    and plt.duty_result in (1,2)
                                    and plt.penalties > 0
                                    and plt.updated_at > date_sub(curdate(), interval 15 day)
                                    and plt.updated_at < date_add(date_sub(curdate(), interval 1 day), interval 1 day)
                            ) a1
                        left join fle_staging.ka_profile kp on kp.id = a1.client_id
                        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a1.client_id
                        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = kp.id
                        left join fle_staging.customer_group cg on cg.id = cgkr.customer_group_id
                    ) a2
            ) a
        where
            a.rk = 1
    )
, val as
    (
        select
            t1.pno
            ,t1.client_name
            ,t1.client_id
            ,t1.result_rank
            ,p1.state
            ,case
                when t1.client_name = 'tiktok' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 2000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_name = 'tiktok' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 2000 then 2000
                when t1.client_name = 'lazada' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 6000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_name = 'lazada' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 6000 then 6000
                when t1.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0771','AA0731','AA0657','AA0707','AA0736','AA0838') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 3000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0771','AA0731','AA0657','AA0707','AA0736','AA0838') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 3000 then 3000
                when t1.client_id in ('AA0572', 'AA0574', 'AA0606', 'AA0612') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 15000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_id in ('AA0572', 'AA0574', 'AA0606', 'AA0612') and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 15000 then 15000
                when t1.client_name = 'shopee' and t1.client_id not in ('AA0572', 'AA0574', 'AA0606', 'AA0612','AA0386','AA0425','AA0427','AA0569','AA0771','AA0731','AA0657','AA0707','AA0736','AA0838') then if(coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) > 2000, 2000, coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100))
                when t1.client_id = 'AA0306' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) < 5000 then coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100)
                when t1.client_id = 'AA0306' and coalesce(if(oi.cogs_amount = 0, null, oi.cogs_amount)/100, p2.cod_amount/100) >= 5000 then 5000
                when t1.client_name in ('KA','GE') and t1.client_id != 'AA0306'  and greatest(ifnull(coalesce(oi.cogs_amount/100, p2.cod_amount/100), 0), ifnull(oi.insure_declare_value/100, 0)) < 2000 and greatest(ifnull(coalesce(oi.cogs_amount/100, p2.cod_amount/100), 0), ifnull(oi.insure_declare_value/100, 0)) > 0 then greatest(ifnull(coalesce(oi.cogs_amount/100, p2.cod_amount/100), 0), ifnull(oi.insure_declare_value/100, 0))
                else 1018
            end parcel_value
            ,p2.store_total_amount/100 store_total_amount
            ,p2.cod_amount/100 cod
            ,oi.cogs_amount/100 cogs
        from t t1
        left join fle_staging.parcel_info p1 on p1.pno = t1.pno and p1.created_at > date_sub(date_sub(curdate(), interval 15 day), interval 3 month)
        left join fle_staging.parcel_info p2 on p2.pno = if(p1.returned = 1, p1.customary_pno, p1.pno) and p2.created_at > date_sub(date_sub(curdate(), interval 15 day), interval 2 month)
        left join fle_staging.order_info oi on oi.pno = if(p1.pno is null, t1.pno, p2.pno)
    )
, cla as
    (
        select
            a1.*
        from
            (
                select
                    pct.pno
                    ,json_extract(pcn.neg_result,'$.money') claim_value
                    ,row_number() over (partition by pcn.task_id order by pcn.created_at desc) rk
                from bi_pro.parcel_claim_task pct
                join t t1 on t1.pno = pct.pno
                left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct.id
                where
                    pct.created_at > date_sub(date_sub(curdate(), interval 15 day), interval 4 month)
                    and pct.state = 6
            ) a1
        where
            a1.rk = 1
    )
, pcm as
    (
        select
            pct.pno
            ,pct.claims_amount/100 claim_money
        from fle_staging.pickup_claims_ticket pct
        join t t1 on t1.pno = pct.pno
        where
            pct.pickup_at > date_sub(date_sub(curdate(), interval 15 day), interval 3 month)
            and pct.state = 6
            and pct.claims_type_category = 1
    )
select
    t1.parcel_created_at 揽件时间
    ,t1.pno 运单号
    ,t1.client_name 客户类型
    ,t1.client_id 客户ID
    ,t1.name 客户名称
    ,t1.group_name 客户分组
    ,v1.cod COD
    ,v1.cogs COGS
    ,v1.store_total_amount 运费
    ,coalesce(c1.claim_value, pc.claim_money, v1.parcel_value) 预估赔付金额
    ,coalesce(c1.claim_value, pc.claim_money) 实际赔付金额
    ,coalesce(if(t1.result_rank = 3, sla.updated_at, t1.updated_at), t1.created_at) 判责时间
    ,case t1.result_rank
        when 3 then '超时效'
        when 2 then '丢失'
        when 1 then '破损'
    end 判责类型
    ,t.t_value 原因
    ,case t1.source
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
    end 问题来源
    ,case if(t1.result_rank = 3, sla.link_type, t1.link_type)
        when 0 then 'ipc计数后丢失'
        when 1 then '揽收网点已揽件，未收件入仓'
        when 2 then '揽收网点已收件入仓，未发件出仓'
        when 3 then '中转已到件入仓扫描，中转未发件出仓'
        when 4 then '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
        when 5 then '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
        when 6 then '分拨发件出仓扫描，目的地未到件入仓(集包)'
        when 7 then '分拨发件出仓扫描，目的地未到件入仓(单件)'
        when 8 then '目的地到件入仓扫描，目的地未交接,当日遗失'
        when 9 then '目的地到件入仓扫描，目的地未交接,次日遗失'
        when 10 then '目的地交接扫描，目的地未妥投'
        when 11 then '目的地妥投后丢失'
        when 12 then '途中破损/短少'
        when 13 then '妥投后破损/短少'
        when 14 then '揽收网点已揽件，未收件入仓'
        when 15 then '揽收网点已收件入仓，未发件出仓'
        when 16 then '揽收网点发件出仓到分拨了'
        when 17 then '目的地到件入仓扫描，目的地未交接'
        when 18 then '目的地交接扫描，目的地未妥投'
        when 19 then '目的地妥投后破损短少'
        when 20 then '分拨已发件出仓，下一站分拨未到件入仓(集包)'
        when 21 then '分拨已发件出仓，下一站分拨未到件入仓(单件)'
        when 22 then 'ipc计数后丢失'
        when 23 then '超时效sla'
        when 24 then '分拨发件出仓到下一站分拨了'
	end 判责环节
    ,if(t1.result_rank = 3, sla.duty_store, ld.duty_store) 责任网点
    ,if(t1.result_rank = 3, sla.duty_category, ld.duty_category) 责任组织类型
    ,case v1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 包裹状态
    ,case
        when t1.result_rank = 3 and plt.pno is not null then '丢失'
        when t1.result_rank = 3 and plt.pno is null and pi2.state = 8 then '拍卖仓妥投'
        when t1.result_rank = 3 and pi2.state = 5 and pi2.cod_enabled = 1 then 'COD妥投'
        when t1.result_rank = 3 and pi2.state not in (5,7,8,9) then '未达终态'
    end '当前环节（超时效）'
    ,case
        when t1.result_rank = 2 and pct.pno is not null then '寄件人理赔'
        when t1.result_rank = 2 and pct.pno is null then '网点理赔'
        when t1.result_rank = 1 and pct3.source in (4,6) and pct3.claim_target = 2 then '收件人理赔'
        when t1.result_rank = 1 and pct3.source in (4,6) and pct3.claim_target = 1 then '寄件人理赔'
        when t1.result_rank = 1 and pct3.source in (9,10) then '仅外包装破损'
    end '理赔对象'
    ,if(srb.pno is not null, '否', '是') COD是否回款
    ,ss2.name 目的地网点
    ,t1.created_at 超时效任务创建时间
from t t1
left join val v1 on v1.pno = t1.pno
left join cla c1 on c1.pno = t1.pno
left join pcm pc on pc.pno = t1.pno
left join
    (
        select
            t1.pno
            ,plt.link_type
            ,plt.duty_reasons
            ,plt.updated_at
            ,group_concat(distinct ss.name) duty_store
            ,group_concat(distinct case ss.category when 1 then 'SP' when 2 then 'DC' when 4 then 'SHOP' when 5 then 'SHOP' when 6 then 'FH' when 7 then 'SHOP' when 8 then 'Hub' when 9 then 'Onsite' when 10 then 'BDC' when 11 then 'fulfillment' when 12 then 'B-HUB' when 13 then 'CDC' when 14 then 'PDC' end) duty_category
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno and t1.result_rank = 3
        left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.source = 11
            and plt.state = 6
            and plt.parcel_created_at > date_sub(date_sub(curdate(), interval 15 day), interval 3 month)
        group by 1,2,3
    ) sla on sla.pno = t1.pno
left join
    (
        select
            t1.pno
            ,group_concat(distinct ss.name) duty_store
            ,group_concat(distinct case ss.category when 1 then 'SP' when 2 then 'DC' when 4 then 'SHOP' when 5 then 'SHOP' when 6 then 'FH' when 7 then 'SHOP' when 8 then 'Hub' when 9 then 'Onsite' when 10 then 'BDC' when 11 then 'fulfillment' when 12 then 'B-HUB' when 13 then 'CDC' when 14 then 'PDC' end) duty_category
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno and t1.result_rank in (1,2)
        left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.source != 11
            and plt.state = 6
            and plt.parcel_created_at > date_sub(date_sub(curdate(), interval 15 day), interval 3 month)
        group by 1
    ) ld on ld.pno = t1.pno
left join bi_pro.translations t on if(t1.result_rank = 3, sla.duty_reasons, t1.duty_reasons) = t.t_key AND t.`lang` = 'zh-CN'
left join fle_staging.parcel_info pi2 on pi2.pno = t1.pno and pi2.created_at > date_sub(date_sub(curdate(), interval 15 day), interval 2 month)
left join fle_staging.sys_store ss2 on ss2.id = pi2.dst_store_id
left join bi_pro.parcel_lose_task plt on plt.pno = t1.pno and plt.source = 11 and plt.parcel_created_at > date_sub(date_sub(curdate(), interval 15 day), interval 2 month) and plt.state = 6 and plt.duty_result = 1
left join bi_pro.parcel_claim_task pct on pct.pno = t1.pno and pct.parcel_created_at > date_sub(date_sub(curdate(), interval 15 day), interval 2 month) and pct.source in (1,2,3,5,7,8,12) and pct.state < 7
left join bi_pro.parcel_claim_task pct3 on pct3.pno = t1.pno and pct3.parcel_created_at > date_sub(date_sub(curdate(), interval 15 day), interval 2 month) and pct3.source in (4,6,9,10) and pct3.state < 7
left join fle_staging.store_receivable_bill_detail srb on srb.pno = t1.pno and srb.receivable_type_category = 5 and srb.state = 0
left join
    (
        select
            pct.pno
        from bi_pro.parcel_claim_task pct
        join t t1 on t1.pno = pct.pno
        where
            pct.state in (7,8)
        group by 1
    ) p1 on p1.pno = t1.pno
left join
    (
        select
            pct.pno
        from bi_pro.parcel_claim_task pct
        join t t1 on t1.pno = pct.pno
        where
            pct.state < 7
        group by 1
    ) p2 on p2.pno = t1.pno
where
    p1.pno is null
    or (p1.pno is not null and p2.pno is not null)

;


select
    count(1)
from rot_pro.parcel_route pr
where
    pr.routed_at > '2025-04-22 17:00:00'
    and pr.routed_at < '2025-04-23 17:00:00'
    and pr.route_action =  'DELIVERY_CONFIRM' -- 妥投

;


select
    swa.staff_info_id
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',swa.started_path) 上班
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',swa.end_path) 下班
from backyard_pro.staff_work_attendance swa
where
    swa.attendance_date = '2025-04-24'
    and swa.staff_info_id = 671332

;


select
    plt.pno
    ,plt.id
    ,plr.staff_id
    ,plr.store_id
from bi_pro.parcel_lose_task plt
left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
where
    plt.pno = 'TH0116696RY32A0'
    and plt.penalties > 0

