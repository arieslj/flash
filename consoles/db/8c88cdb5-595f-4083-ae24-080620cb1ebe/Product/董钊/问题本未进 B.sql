with t as
    (
         select
            ci.pno
            ,ci.client_id
            ,ci.created_at
            ,ci.submitter_id
            ,hsi.name
            ,ci.id
        from fle_staging.customer_issue ci
        left join bi_pro.parcel_lose_task plt on ci.id = plt.source_id and plt.source = 2
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ci.submitter_id
        where
            ci.created_at > '2023-11-13 17:00:00'
            and ci.request_sup_type = 22
            and plt.id is null
    )

select
    t1.pno
    ,t1.id 问题记录本ID
    ,t1.client_id 客户id
    ,convert_tz(t1.created_at, '+00:00', '+07:00') 上报时间
    ,t1.submitter_id 上报人ID
    ,t1.name 上报人
    ,case a.source
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
    ,case a.duty_result
        when 1 then '丢失'
        when 2 then '破损/短少'
        when 3 then '超时效'
    end  判责类型
    ,case a.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '责任人已认定'
    end 状态
    ,a2.created_at 最后一次进入b来源时间
    ,case a2.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '责任人已认定'
    end b来源判责状态
from t t1
left join
    (
        select
            plt.pno
            ,plt.source
            ,plt.state
            ,plt.duty_result
            ,row_number() over (partition by plt.pno order by plt.created_at desc) rk
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.source != 2
    ) a on a.pno = t1.pno and a.rk = 1
left join
    (
        select
            plt.pno
            ,plt.source
            ,plt.state
            ,plt.duty_result
            ,plt.created_at
            ,row_number() over (partition by plt.pno order by plt.created_at desc) rk
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.source = 2
    ) a2 on a2.pno = t1.pno and a2.rk = 1