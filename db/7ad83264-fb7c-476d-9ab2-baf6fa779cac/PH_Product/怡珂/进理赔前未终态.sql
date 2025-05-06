with t as
    (
        select
            pct.source
            ,pct.pno
            ,pct.state pct_state
            ,pct.client_id
            ,pct.created_at
        from ph_bi.parcel_claim_task pct
        join ph_staging.parcel_info pi on pct.pno = pi.pno
        where
            pct.created_at >= '2023-11-30 16:00:00'
            and pct.created_at < '2023-12-31 16:00:00'
            and pi.returned = 1
    )
select
    a1.pno
    ,case a1.source
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
    ,pi.cod_amount/100 COD
    ,if(sct.pno is not null, '是', '否') 是否有判责属实
    ,case a1.pct_state
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
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
from
    (
        select
            a.*
        from
            (
                select
                    pr.state
                    ,t1.*
                    ,row_number() over (partition by t1.pno order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at < date_sub(t1.created_at, interval 8 hour)
            ) a
        where
            a.rk = 1
    ) a1
left join ph_staging.parcel_info pi on pi.returned_pno = a1.pno
left join ph_bi.ss_court_task sct on sct.pno = a1.pno  and sct.state = 3
left join ph_staging.ka_profile kp on kp.id = a1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = a1.client_id
where
    a1.state in (1,2,3,4,6)