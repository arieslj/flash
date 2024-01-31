select
    pct.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
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
    ,case pct.state
        when 1 then '待协商'
        when 2 then '协商不一致，待重新协商'
        when 3 then '待财务核实'
        when 4 then '核实通过，待财务支付'
        when 5 then '财务驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止'
        when 8 then '异常关闭'
        when 9 then' 待协商（搁置）'
        when 10 then '等待再次联系'
    end 理赔状态
    ,pi.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
    ,case
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) < 24 then '0-24小时内处理'
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) >= 24 and timestampdiff(hour, pct.created_at, pct.updated_at) < 48 then '24-48小时内处理'
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) >= 48 and timestampdiff(hour, pct.created_at, pct.updated_at) < 72 then '48-72小时内处理'
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) >= 72 then '72小时以上处理'
        else null
    end 理赔处理时间
from bi_pro.parcel_claim_task pct
join fle_staging.parcel_info pi on pi.pno = pct.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pct.client_id
left join fle_staging.ka_profile kp on kp.id = pct.client_id
left join fle_staging.parcel_additional_info pai on pai.pno = pct.pno
where
    pct.created_at > '2023-11-01'
    and pct.created_at < '2024-01-16'
    and pi.state = 5

;
