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

select  * from tmpale.tmp_th_qaqc_claim