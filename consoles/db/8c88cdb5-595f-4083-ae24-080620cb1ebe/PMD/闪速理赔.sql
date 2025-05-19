with t as
    (
        select
            pct.id
            ,pct.parcel_created_at
            ,plt.updated_at
            ,pct.client_id
            ,pct.pno
        #     ,case pct.self_claim
        #         when 1 then '是'
        #         when 0 then '否'
        #     end 自主理赔
            ,pct.self_claim
            ,pct.duty_result
        #     ,case plt.duty_result
        #         when 1 then '丢失'
        #         when 2 then '破损'
        #         when 3 then '超时效'
        #     end 判责类型
            ,replace(substring_index(substring_index(substring_index(oi.remark, '，', 1), '：', -1),  'THB', 1), ' ', '') COGS
            ,t2.t_value reasons
            ,pct.area
            ,group_concat(distinct ss.name) duty_stores

        from bi_pro.parcel_claim_task pct
#         join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pct.client_id and bc.client_name = 'shein'
        left join bi_pro.parcel_lose_task plt on plt.id = pct.lose_task_id
        left join fle_staging.parcel_info pi on pi.pno = pct.pno
        left join fle_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = pct.lose_task_id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        left join bi_pro.translations t2 on t2.t_key = plt.duty_reasons and  t2.lang ='zh-CN'
        where
            -- 查询最近一次更新时间在今天之前一天及之后的数据
            plt.updated_at >= date_sub(curdate(), interval 2 month)
            and plt.updated_at < curdate()
            and plt.client_id in ('AA0622','AA0649','AA0650','AA0662')
        group by 1
    )
select
    t1.parcel_created_at 揽收时间
    ,t1.updated_at 判责时间
    ,t1.client_id 客户ID
    ,t1.id task_id
    ,t1.pno 运单号
    ,case t1.self_claim
        when 1 then '是'
        when 0 then '否'
    end 自主理赔
    ,case t1.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 判责类型
    ,t1.COGS
    ,t1.duty_stores 判责网点
    ,t1.reasons 判责原因
    ,t1.area 区域
    ,date(t1.updated_at) p_date
from t t1
;


select
    t.*
    ,a1.money 待理赔金额
from tmpale.tmp_th_qaqc_claim t
left join
    (
        select
            pcn.task_id
            ,json_extract(pcn.neg_result,'$.money') money
            ,row_number() over (partition by pcn.task_id order by pcn.created_at ) rk
        from bi_pro.parcel_claim_negotiation pcn
        join tmpale.tmp_th_qaqc_claim t on t.task_id = pcn.task_id
    ) a1 on a1.task_id = t.task_id and a1.rk = 1

;

/*select  * from tmpale.tmp_th_qaqc_claim*/



;


with t as
    (
        select
            pct.id
            ,pct.parcel_created_at
            ,plt.updated_at
            ,pct.client_id
            ,pct.pno
        #     ,case pct.self_claim
        #         when 1 then '是'
        #         when 0 then '否'
        #     end 自主理赔
            ,pct.self_claim
            ,pct.duty_result
        #     ,case plt.duty_result
        #         when 1 then '丢失'
        #         when 2 then '破损'
        #         when 3 then '超时效'
        #     end 判责类型
            ,replace(substring_index(substring_index(substring_index(oi.remark, '，', 1), '：', -1),  'THB', 1), ' ', '') COGS
            ,t2.t_value reasons
            ,pct.area
            ,group_concat(distinct ss.name) duty_stores

        from bi_pro.parcel_claim_task pct
        # join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pct.client_id and bc.client_name = 'shein'
        left join bi_pro.parcel_lose_task plt on plt.id = pct.lose_task_id
        left join fle_staging.parcel_info pi on pi.pno = pct.pno
        left join fle_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = pct.lose_task_id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        left join bi_pro.translations t2 on t2.t_key = plt.duty_reasons and  t2.lang ='zh-CN'
        where
            plt.updated_at >= '2024-01-01'
            and plt.updated_at < curdate()
            and plt.client_id in ('AA0622','AA0649','AA0650','AA0662')
        group by 1
    )
select
    t1.parcel_created_at 揽收时间
    ,t1.updated_at 判责时间
    ,t1.client_id 客户ID
    ,t1.id task_id
    ,t1.pno 运单号
    ,case t1.self_claim
        when 1 then '是'
        when 0 then '否'
    end 自主理赔
    ,case t1.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 判责类型
    ,t1.COGS
    ,t1.duty_stores 判责网点
    ,t1.reasons 判责原因
    ,t1.area 区域
    ,date(t1.updated_at) p_date
from t t1


;


select
    pct.pno 'Tracking Number'
    ,pct.client_id
    ,pct.created_at 'Task generation time'
    ,case pct.self_claim
        when 1 then 'yes'
        when 0 then 'no'
    end 'Self Claim'
    ,case pct.client_data
        when 1 then 'filled'
        when 0 then 'Unfilled'
    end 'Claim Information'
    ,case pct.check_data
        when 2 then 'fail'
        when 0 then 'To be reviewed'
        when 1 then 'reviewed'
    end 'Review information'
    ,case pct.vip_enable
        when 1 then 'Kam Customer'
        when 0 then 'Common Customer'
    end 'Customer Type'
    ,pct.parcel_created_at 'Receive time'
    ,concat(kp.name, ' ', kp.major_mobile, ' ', kp.email) 'Customer Information'
    ,case pct.source
        WHEN 1 THEN 'A - Problematic Item - Lost'
        WHEN 2 THEN 'B - Processing Record - Lost'
        WHEN 3 THEN 'C - Status not updated'
        WHEN 4 THEN 'D - Problematic Item - Damaged/Short'
        WHEN 5 THEN 'E - Processing Record - Claim - Lost'
        WHEN 6 THEN 'F - Processing Record - Claim  -Damaged/Short'
        WHEN 7 THEN 'G - Processing Record - Claim - Others'
        WHEN 8 THEN 'H-Lost parcel claims without waybill numbe'
        WHEN 9 THEN 'J-problem processing-Packaging damage insurance'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K - Breached Parcel'
        when 12 then 'L-highly suspected lost parcel'
    end 'Source of problem'
    ,pct.updated_at 'Last processing time'
    ,pct.operator_id 'Handler'
    ,pct.area 'Region'
    ,case pct.state
        when 3 then 'Financial verification'
        when 4 then 'Financial payment'
    end Status
from bi_pro.parcel_claim_task pct
left join fle_staging.ka_profile kp on kp.id = pct.client_id
where
    pct.state in (3,4)
   -- and pct.pno = 'TH471543DFCX9G'