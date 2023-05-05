select
    pct.created_at 任务生成时间
    ,pct.parcel_created_at 包裹揽收时间
    ,concat('SSLP00',pct.id) 任务ID
    ,pct.pno 运单号
    ,pi.returned_pno 退货运单号
    ,case pct.self_claim
        when 1 then '是'
        when 0 then '否'
    end 自主理赔
    ,case pct.vip_enable
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end 客户类型
    ,case pct.vehicle_abnormal_type
        when 0 then '车辆车祸'
        when 1 then '车辆湿损'
        when 2 then '车辆途中故障'
        when 3 then '其他'
    end 车辆异常
    ,case pct.claim_target
        when 1 then  '客户'
        when 2 then '收件人'
        when 3 then 'Drop Point寄件人'
    end 理赔对象
    ,pct.client_id 客户ID
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) cogs
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
    ,t.t_value QAQC判责原因
    ,pi.exhibition_weight 重量
    ,concat_ws('*',pi.exhibition_length,pi.exhibition_width,pi.exhibition_height) 尺寸
    ,case pct.special_claim_category
        when 0 then '否'
        when 1 then '是'
    end 是否符合水果理赔条件
    ,pct.no_claim_reason 不符合理赔条件原因
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
    end 状态
    ,pct.area 区域
    ,hsi.name 处理人
    ,pct.updated_at 处理时间
    ,pco6.created_at 理赔完成时间
    ,pct.id
    ,pcn.task_id
    ,pcn.monkey 客户申请理赔金额
    ,json_extract(pcn2.neg_result,'$.money') 理赔金额
    ,case pct.claim_where
        when 1 then '赔付至账户余额'
        when 2 then '赔付至银行账户'
    end 理赔途径
    ,coalesce(pco1.created_at, convert_tz(ci.created_at, '+00:00', '+07:00')) 客户第一次上传资料时间
    ,pco2.created_at 客户最后上传资料时间
    ,pco3.created_at 客服第一次处理时间
    ,pco4.created_at 客服最后处理时间
    ,pco5.ct 驳回次数
    ,if(pi.state=5,concat(timestampdiff(day, pi.created_at, pi.finished_at),'D', timestampdiff(hour,  pi.created_at, pi.finished_at)%24, 'H'),concat(timestampdiff(day, convert_tz(pi.created_at,'+00:00','+07:00') ,pct.created_at),'D', timestampdiff(hour,  convert_tz(pi.created_at,'+00:00','+07:00') ,pct.created_at)%24, 'H'))运输天数
    ,if(pai.pno is not null , '是', '否') 是否购买外包装破损险
    ,if(pco2.created_at is not null,if(hour(pco2.created_at) >= 14, '否', '是'), null)   '客户是否当天 14:00 提供资料'
    ,timestampdiff(hour, pco1.created_at, pco4.created_at) '客户最后提交资料到客服处理时间（小时）'
    ,if(pct.state = 6, timestampdiff(hour,  pco4.created_at, pct.finance_updated_at), null) '从客服审核到财务打款（小时）'
    ,if(pct.state = 6 ,timestampdiff(hour,  pco2.created_at, pct.finance_updated_at), null) '从客户最后提交理赔资料到财务打款（小时）'
from bi_pro.parcel_claim_task pct
left join fle_staging.parcel_amount_info pai on pai.pno = pct.pno and pai.item = 'OPD_INSURE_AMOUNT'
left join fle_staging.customer_issue ci on pct.source_id = ci.id and pct.source in (2,5,6,7)
left join
(-- 第一次上传资料
    select
    pco.*
    from
    (
    select
        pco.task_id
        ,pco.created_at
        ,row_number()over(partition by pco.task_id order by pco.created_at) rn
    from bi_pro.parcel_cs_operation_log pco
    where pco.action in (5,22,15)
    )pco where pco.rn=1
)pco1
on pco1.task_id=pct.id

left join
(-- 最后一次上传资料
    select
    pco.*
    from
    (
    select
        pco.task_id
        ,pco.created_at
        ,row_number()over(partition by pco.task_id order by pco.created_at desc) rn
    from bi_pro.parcel_cs_operation_log pco
    where pco.action in (5,22)
    )pco where pco.rn=1
)pco2
on pco2.task_id=pct.id
left join
(-- 客服第一次联系
    select
    pco.*
    from
    (
    select
        pco.task_id
        ,pco.created_at
        ,row_number()over(partition by pco.task_id order by pco.created_at) rn
    from bi_pro.parcel_cs_operation_log pco
    where pco.action=21
    )pco where pco.rn=1
)pco3
on pco3.task_id=pct.id

left join
(-- 客服最后一次联系
    select
    pco.*
    from
    (
    select
        pco.task_id
        ,pco.created_at
        ,row_number()over(partition by pco.task_id order by pco.created_at desc) rn
    from bi_pro.parcel_cs_operation_log pco
    where pco.action=21
    )pco where pco.rn=1
)pco4
on pco4.task_id=pct.id

left join
(-- 驳回
    select
       pco.task_id
       ,count(pco.id) ct
    from bi_pro.parcel_cs_operation_log pco
    where pco.action=13 -- 驳回
    group by 1
)pco5
on pco5.task_id=pct.id

left join bi_pro.parcel_cs_operation_log pco6
on pco6.task_id=pct.id and pco6.action=9 -- 理赔完成

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
                    pct.created_at >= '2023-01-01'
                    and pct.created_at < '2023-04-28'
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
                from  bi_pro.parcel_claim_negotiation pcn
                where
                    pcn.created_at >= '2022-10-01'
            ) a
        where
            a.rk = 1
    ) pcn2 on pcn2.task_id = pct.id

left join dwm.tmp_ex_big_clients_id_detail bc
on pct.client_id=bc.client_id

left join fle_staging.order_info oi
on pct.pno=oi.pno

left join bi_pro.parcel_lose_task plt
on plt.pno=pct.pno and plt.penalties > 0


left join bi_pro.translations t
on plt.duty_reasons=t.t_key
and t.lang ='zh-CN'

left join fle_staging.parcel_info pi
on pct.pno=pi.pno

left join bi_pro.hr_staff_info hsi
on hsi.staff_info_id=pct.operator_id

where
    pct.created_at >= '2023-01-01'
    and pct.created_at < '2023-04-28'
    and pi.article_category = 11

;

