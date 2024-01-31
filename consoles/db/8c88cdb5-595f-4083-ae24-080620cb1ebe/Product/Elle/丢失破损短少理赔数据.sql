select
    pct.pno
    ,pct.client_id 客户ID
    ,if(bc.client_id is not null, bc.client_name, '非平台') 是否平台客户
    ,cg.name 'KAM-VIP客服组'
    ,case pct.self_claim
        when 1 then '是'
        when 0 then '否'
    end 是否自主理赔
    ,case pct.source
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
    ,timestampdiff(minute, pct.created_at, pct.updated_at)/60 处理时长_小时
    ,'理赔完成' 理赔状态
    ,case pct.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
	end 判责结果
    ,case pct.claim_target
        when 1 then  '客户'
        when 2 then '收件人'
        when 3 then 'Drop Point寄件人'
    end 理赔对象
    ,oi.cogs_amount/100 cogs
    ,pcn.monkey 客户申请理赔金额
    ,json_extract(pcn2.neg_result,'$.money') 理赔金额
from bi_pro.parcel_claim_task pct
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pct.client_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = pct.client_id and cgkr.deleted = 0
left join fle_staging.customer_group cg on cg.id = cgkr.customer_group_id
left join fle_staging.order_info oi on oi.pno = pct.pno
left join
    (
        select
            a1.*
        from
            (
                select
                    pcn.task_id
                    ,json_extract(pcn.neg_result,'$.money') monkey
                    ,row_number() over (partition by pcn.task_id order by pcn.created_at ) rk
                from bi_pro.parcel_claim_negotiation pcn
                left join bi_pro.parcel_claim_task pct on pcn.task_id = pct.id
                where
                    pct.updated_at >= '2023-10-01'
                    and pct.updated_at < '2023-12-01'
                    and pct.state = 6
                    and pcn.neg_type in (5,6,7)
                    and json_extract(pcn.neg_result,'$.money') is not null
            ) a1
        where
            a1.rk = 1
    ) pcn on pcn.task_id = pct.id
left join
    (
        select
            a.*
        from
            (
                select
                    pcn.task_id
                    ,pcn.neg_result
                    ,row_number() over (partition by pcn.task_id order by pcn.created_at desc ) rk
                from bi_pro.parcel_claim_negotiation pcn
                left join bi_pro.parcel_claim_task pct on pcn.task_id = pct.id
                where
                    pct.updated_at >= '2023-10-01'
                    and pct.updated_at < '2023-12-01'
                    and pct.state = 6
            ) a
        where
            a.rk = 1
    ) pcn2 on pcn2.task_id = pct.id
where
    pct.state = 6
    and pct.updated_at >= '2023-10-01'
    and pct.updated_at < '2023-12-01'