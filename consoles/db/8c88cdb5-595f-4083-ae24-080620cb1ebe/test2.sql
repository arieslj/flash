
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
