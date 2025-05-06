with t as
    (
        select
            a1.pno
        from
            (
                select
                    a.*
                    ,row_number() over (partition by a.pno order by a.result_rank desc) rk
                from
                    (
                        select
                            a1.id
                            ,a1.pno
                            ,case
                                when a1.source = 11 then 3
                                when a1.duty_result = 1 and a1.state = 6 then 2
                                when a1.duty_result = 2 and a1.state = 6 then 1
                            end result_rank
                        from
                            (
                                select
                                    plt.pno
                                    ,plt.id
                                    ,plt.duty_result
                                    ,plt.source
                                    ,plt.state
                                from my_bi.parcel_lose_task plt
                                left join my_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > date_sub('${sdate}', interval 2 month)
                                where
                                    plt.updated_at >= '${sdate}' and plt.updated_at < date_add('${edate}', interval 1 day) and plt.state = 6 and plt.duty_result in (1,2)

                                union all

                                select
                                    plt.pno
                                    ,plt.id
                                    ,plt.duty_result
                                    ,plt.source
                                    ,plt.state
                                from my_bi.parcel_lose_task plt
                                left join my_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > date_sub('${sdate}', interval 2 month)
                                left join my_bi.parcel_lose_task plt2 on plt2.pno = pi.customary_pno and plt2.source = 11 and plt2.created_at > date_sub('${sdate}', interval 2 month)
                                where
                                    plt.source = 11 and plt.created_at >= '${sdate}'
                                    and plt.created_at < date_add('${edate}', interval 1 day)
                                    and plt2.pno is null
                                group by 1
                            ) a1
                    ) a
            ) a1
        where
            a1.rk = 1
    )
select
    count(t1.pno) pno_cnt
    ,sum(pi.parcel_value) value_sum
from t t1
left join
    (
        select
            t1.pno
            ,bc.client_name
#             ,pi2.cod_amount/100 cod
#             ,pai.cogs_amount/100 cogs
#             ,pi2.insure_declare_value/100
            ,case
                when bc.client_name = 'lazada' and pai.cogs_amount/100 >= 1000 then 1000
                when bc.client_name = 'lazada' and pai.cogs_amount/100 < 1000 then pai.cogs_amount/100
                when bc.client_name = 'shopee' and pai.cogs_amount/100 >= 400 then 400
                when bc.client_name = 'shopee' and pai.cogs_amount/100 < 400 then pai.cogs_amount/100
                when bc.client_name = 'tiktok' and pai.cogs_amount/100 >= 400 then 400
                when bc.client_name = 'tiktok' and pai.cogs_amount/100 < 400 then pai.cogs_amount/100
                when bc.client_name = 'shein' and pai.cogs_amount/100 >= 300 then 300
                when bc.client_name = 'shein' and pai.cogs_amount/100 < 300 then pai.cogs_amount/100
                when bc.client_name is null and pi2.cod_enabled = 1 then pi2.cod_amount/100
                when bc.client_name is null and pi2.cod_enabled = 0 then 300
                else 0
            end parcel_value

        from t t1
        left join my_staging.parcel_info pi on t1.pno = pi.pno
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
        left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join my_staging.order_info pai on pai.pno = if(pi.pno is null, t1.pno, pi2.pno)
#         where
#             pi.created_at >  date_sub('${sdate}', interval 4 month)
           -- and pi.created_at < date_add('${edate}', interval 16 hour)
    ) pi on pi.pno = t1.pno

;

-- 判责分类

with t as
    (
        select
            a1.*
        from
            (
                select
                    a.*
                    ,row_number() over (partition by a.pno order by a.result_rank desc) rk
                from
                    (
                        select
                            a1.id
                            ,a1.pno
                            ,case
                                when bc.client_id is not null then bc.client_name
                                when bc.client_id is null and kp.id is not null then 'KA'
                                else 'GE'
                            end client_name
                            ,case
                                when a1.source = 11 then 3
                                when a1.duty_result = 1 and a1.state = 6 then 2
                                when a1.duty_result = 2 and a1.state = 6 then 1
                            end result_rank
                        from
                            (
                                select
                                    plt.pno
                                    ,plt.id
                                    ,plt.duty_result
                                    ,plt.source
                                    ,plt.client_id
                                    ,plt.state
                                from my_bi.parcel_lose_task plt
                              --  left join my_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > date_sub('${sdate}', interval 4 month)
                                where
                                    plt.updated_at >= '${sdate}' and plt.updated_at < date_add('${edate}', interval 1 day) and plt.state = 6 and plt.duty_result in (1,2)

                                union all

                                select
                                    plt.pno
                                    ,plt.id
                                    ,plt.duty_result
                                    ,plt.source
                                    ,plt.client_id
                                    ,plt.state
                                from my_bi.parcel_lose_task plt
                                left join my_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > date_sub('${sdate}', interval 4 month)
                                left join my_bi.parcel_lose_task plt2 on plt2.pno = pi.customary_pno and plt2.source = 11 and plt2.created_at > date_sub('${sdate}', interval 2 month)
                                where
                                    plt.source = 11 and plt.created_at >= '${sdate}'
                                    and plt.created_at < date_add('${edate}', interval 1 day)
                                    and plt2.pno is null
                            ) a1
                        left join my_staging.ka_profile kp on kp.id = a1.client_id
                        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a1.client_id
                    ) a
            ) a1
        where
            a1.rk = 1
    )
, val as
    (
        select
            t1.pno
            ,t1.client_name
            ,t1.result_rank
#             ,pi2.cod_amount/100 cod
#             ,pai.cogs_amount/100 cogs
#             ,pi2.insure_declare_value/100
            ,case
                when t1.client_name = 'lazada' and pai.cogs_amount/100 >= 1000 then 1000
                when t1.client_name = 'lazada' and pai.cogs_amount/100 < 1000 then pai.cogs_amount/100
                when t1.client_name = 'shopee' and pai.cogs_amount/100 >= 400 then 400
                when t1.client_name = 'shopee' and pai.cogs_amount/100 < 400 then pai.cogs_amount/100
                when t1.client_name = 'tiktok' and pai.cogs_amount/100 >= 400 then 400
                when t1.client_name = 'tiktok' and pai.cogs_amount/100 < 400 then pai.cogs_amount/100
                when t1.client_name = 'shein' and pai.cogs_amount/100 >= 300 then 300
                when t1.client_name = 'shein' and pai.cogs_amount/100 < 300 then pai.cogs_amount/100
                when t1.client_name in ('KA','GE') and pi2.cod_enabled = 1 then pi2.cod_amount/100
                when t1.client_name in ('KA','GE') and pi2.cod_enabled = 0 then 300
                else 0
            end parcel_value
            ,pi2.store_total_amount/100 store_total_amount
        from t t1
        left join my_staging.parcel_info pi on t1.pno = pi.pno and pi.created_at >  date_sub('${sdate}', interval 3 month)
        left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join my_staging.order_info pai on pai.pno = if(pi.pno is null, t1.pno, pi2.pno)
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
                from my_bi.parcel_claim_task pct
                join t t1 on t1.pno = pct.pno
                left join my_bi.parcel_claim_negotiation pcn on pcn.task_id = pct.id
                where
                    pct.created_at > date_sub('${sdate}', interval 4 month)
                --    and pct.parcel_created_at < date_add('${edate}', interval 1 day)
                    and pct.state = 6
            ) a1
        where
            a1.rk = 1
    )
select
    t1.client_name
    ,count(distinct if(t1.result_rank = 3, t1.pno, null))  超时效_丢失数量
    ,sum(if(t1.result_rank = 3, v1.store_total_amount, null)) 超时效_运费
    ,sum(if(t1.result_rank = 3, v1.parcel_value, null)) 超时效_超时效预计涉及金额
    ,sum(if(t1.result_rank = 3, c1.claim_value, null)) 超时效_实际赔付金额

    ,count(distinct if(t1.result_rank = 2, t1.pno, null))  遗失_丢失数量
    ,sum(if(t1.result_rank = 2, v1.store_total_amount, null)) 遗失_运费
    ,sum(if(t1.result_rank = 2, v1.parcel_value, null)) 遗失_超时效预计涉及金额
    ,sum(if(t1.result_rank = 2, c1.claim_value, null)) 遗失_实际赔付金额

    ,count(distinct if(t1.result_rank = 1, t1.pno, null))  破损_丢失数量
    ,sum(if(t1.result_rank = 1, v1.store_total_amount, null)) 破损_运费
    ,sum(if(t1.result_rank = 1, v1.parcel_value, null)) 破损_超时效预计涉及金额
    ,sum(if(t1.result_rank = 1, c1.claim_value, null)) 破损_实际赔付金额
from t t1
left join val v1 on v1.pno = t1.pno
left join cla c1 on c1.pno = t1.pno
group by 1
;



-- 明细分类
with t as
    (
         select
            a1.*
        from
            (
                select
                    a.*
                    ,row_number() over (partition by a.pno order by a.result_rank desc) rk
                from
                    (
                        select
                            a1.id
                            ,a1.pno
                            ,case
                                when bc.client_id is not null then bc.client_name
                                when bc.client_id is null and kp.id is not null then 'KA'
                                else 'GE'
                            end client_name
                            ,case
                                when a1.source = 11 then 3
                                when a1.duty_result = 1 and a1.state = 6 then 2
                                when a1.duty_result = 2 and a1.state = 6 then 1
                            end result_rank
                            ,a1.updated_at
                        from
                            (
                                select
                                    plt.pno
                                    ,plt.id
                                    ,plt.duty_result
                                    ,plt.source
                                    ,plt.client_id
                                    ,plt.state
                                    ,plt.updated_at
                                from my_bi.parcel_lose_task plt
                                left join my_staging.parcel_info pi on pi.pno = plt.pno
                                where
                                    plt.updated_at >= '${sdate}' and plt.updated_at < date_add('${edate}', interval 1 day) and plt.state = 6 and plt.duty_result in (1,2)

                                union all

                                select
                                    plt.pno
                                    ,plt.id
                                    ,plt.duty_result
                                    ,plt.source
                                    ,plt.client_id
                                    ,plt.state
                                    ,plt.updated_at
                                from my_bi.parcel_lose_task plt
                                left join my_staging.parcel_info pi on pi.pno = plt.pno
                                left join my_bi.parcel_lose_task plt2 on plt2.pno = pi.customary_pno and plt2.source = 11 and plt2.created_at > date_sub('${sdate}', interval 2 month)
                                where
                                    plt.source = 11 and plt.created_at >= '${sdate}'
                                    and plt.created_at < date_add('${edate}', interval 1 day)
                                    and plt2.pno is null
                            ) a1
                        left join my_staging.ka_profile kp on kp.id = a1.client_id
                        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a1.client_id
                    ) a
            ) a1
        where
            a1.rk = 1
    )
, val as
    (
        select
            t1.pno
            ,t1.client_name
            ,t1.result_rank
#             ,pi2.cod_amount/100 cod
#             ,pai.cogs_amount/100 cogs
#             ,pi2.insure_declare_value/100
            ,case
                when t1.client_name = 'lazada' and pai.cogs_amount/100 >= 1000 then 1000
                when t1.client_name = 'lazada' and pai.cogs_amount/100 < 1000 then pai.cogs_amount/100
                when t1.client_name = 'shopee' and pai.cogs_amount/100 >= 400 then 400
                when t1.client_name = 'shopee' and pai.cogs_amount/100 < 400 then pai.cogs_amount/100
                when t1.client_name = 'tiktok' and pai.cogs_amount/100 >= 400 then 400
                when t1.client_name = 'tiktok' and pai.cogs_amount/100 < 400 then pai.cogs_amount/100
                when t1.client_name = 'shein' and pai.cogs_amount/100 >= 300 then 300
                when t1.client_name = 'shein' and pai.cogs_amount/100 < 300 then pai.cogs_amount/100
                when t1.client_name in ('KA','GE') and pi2.cod_enabled = 1 then pi2.cod_amount/100
                when t1.client_name in ('KA','GE') and pi2.cod_enabled = 0 then 300
                else 0
            end parcel_value
            ,pi2.store_total_amount/100 store_total_amount
            ,t1.updated_at
        from t t1
        left join my_staging.parcel_info pi on t1.pno = pi.pno
        left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join my_staging.order_info  pai on pai.pno = if(pi.pno is null, t1.pno, pi2.pno)
          --   and pi.created_at < date_add('${edate}', interval 16 hour)
    )
select
    t1.client_name
    ,count(distinct if(pi.state = 8 and pi.dst_store_id = 'MY04040319' and t1.result_rank = 3, t1.pno, null)) 拍卖仓妥投成功_超时效 -- MS1(Auction WH)
    ,sum(if(pi.state = 8 and pi.dst_store_id = 'MY04040319' and t1.result_rank = 3, v1.parcel_value, null)) 拍卖仓妥投成功涉及金额_超时效
    ,count(distinct if(pi.state = 8 and pi.dst_store_id != 'MY04040319' and t1.result_rank = 3, t1.pno, null)) 丢失_超时效 -- MS1(Auction WH)
    ,sum(if(pi.state = 8 and pi.dst_store_id != 'MY04040319' and t1.result_rank = 3, v1.parcel_value, null)) 丢失涉及金额_超时效
    ,count(distinct if(pi.state not in (5,7,8,9) and t1.result_rank = 3, t1.pno, null)) 未终态_超时效 -- MS1(Auction WH)
    ,sum(if(pi.state not in (5,7,8,9) and t1.result_rank = 3, v1.parcel_value, null)) 未终态涉及金额_超时效
    ,count(distinct if(pi.state = 5 and pi.cod_enabled = 1 and t1.result_rank = 3, t1.pno, null)) COD妥投_超时效
    ,sum(if(pi.state = 5 and pi.cod_enabled = 1 and t1.result_rank = 3, v1.parcel_value, null)) COD妥投涉及金额_超时效

    ,count(distinct if(pi.pno is null and t1.result_rank = 2, t1.pno, null)) 遗失_揽收前丢失
    ,sum(if(pi.pno is null and t1.result_rank = 2, v1.parcel_value, null)) 遗失涉及金额_揽收前丢失
    ,count(distinct if((t1.updated_at < date_add(pr.routed_at, interval 8 hour) or pr.pno is null) and t1.result_rank = 2 and pi.pno is not null, t1.pno, null)) 遗失_妥投前丢失
    ,sum(if((t1.updated_at < date_add(pr.routed_at, interval 8 hour) or pr.pno is null) and t1.result_rank = 2 and pi.pno is not null, v1.parcel_value, null)) 遗失涉及金额_妥投前丢失
    ,count(distinct if(t1.updated_at >= date_add(pr.routed_at, interval 8 hour) and t1.result_rank = 2 and pi.pno is not null, t1.pno, null)) 遗失_妥投后丢失
    ,sum(if(t1.updated_at >= date_add(pr.routed_at, interval 8 hour) and t1.result_rank = 2 and pi.pno is not null, v1.parcel_value, null)) 遗失涉及金额_妥投后丢失

    ,count(distinct if((t1.updated_at < date_add(pr.routed_at, interval 8 hour) or pr.pno is null) and t1.result_rank = 1, t1.pno, null)) 破损_妥投前丢失
    ,sum(if((t1.updated_at < date_add(pr.routed_at, interval 8 hour) or pr.pno is null) and t1.result_rank = 1, v1.parcel_value, null)) 破损涉及金额_妥投前丢失
    ,count(distinct if(t1.updated_at >= date_add(pr.routed_at, interval 8 hour) and t1.result_rank = 1, t1.pno, null)) 破损_妥投后丢失
    ,sum(if(t1.updated_at >= date_add(pr.routed_at, interval 8 hour) and t1.result_rank = 1, v1.parcel_value, null)) 破损涉及金额_妥投后丢失
from t t1
left join val v1 on v1.pno = t1.pno
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at >= date_sub('${sdate}', interval 3 month)
left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.routed_at > date_sub('${sdate}', interval 3 month) and pr.route_action = 'DELIVERY_CONFIRM'
group by 1

;

-- 明细


with t as
    (
        select
            a1.*
        from
            (
                select
                    a.*
                    ,row_number() over (partition by a.pno order by a.result_rank desc) rk
                from
                    (
                        select
                            a1.id
                            ,a1.pno
                            ,case
                                when bc.client_id is not null then bc.client_name
                                when bc.client_id is null and kp.id is not null then 'KA'
                                else 'GE'
                            end client_name
                            ,case
                                when a1.source = 11 then 3
                                when a1.duty_result = 1 and a1.state = 6 then 2
                                when a1.duty_result = 2 and a1.state = 6 then 1
                            end result_rank
                            ,a1.parcel_created_at
                            ,a1.created_at
                            ,a1.updated_at
                            ,a1.remark
                        from
                            (
                                select
                                    plt.pno
                                    ,plt.id
                                    ,plt.duty_result
                                    ,plt.source
                                    ,plt.client_id
                                    ,plt.state
                                    ,plt.parcel_created_at
                                    ,plt.created_at
                                    ,plt.updated_at
                                    ,plt.remark
                                from my_bi.parcel_lose_task plt
                                left join my_staging.parcel_info pi on pi.pno = plt.pno
                                where
                                    plt.updated_at >= '${sdate}' and plt.updated_at < date_add('${edate}', interval 1 day) and plt.state = 6 and plt.duty_result in (1,2)

                                union all

                                select
                                    plt.pno
                                    ,plt.id
                                    ,plt.duty_result
                                    ,plt.source
                                    ,plt.client_id
                                    ,plt.state
                                    ,plt.parcel_created_at
                                    ,plt.created_at
                                    ,plt.updated_at
                                    ,plt.remark
                                from my_bi.parcel_lose_task plt
                                left join my_staging.parcel_info pi on pi.pno = plt.pno
                                left join my_bi.parcel_lose_task plt2 on plt2.pno = pi.customary_pno and plt2.source = 11 and plt2.created_at > date_sub('${sdate}', interval 2 month)
                                where
                                    plt.source = 11 and plt.created_at >= '${sdate}'
                                    and plt.created_at < date_add('${edate}', interval 1 day)
                                    and plt2.pno is null
                            ) a1
                        left join my_staging.ka_profile kp on kp.id = a1.client_id
                        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a1.client_id
                    ) a
            ) a1
        where
            a1.rk = 1
    )
, val as
    (
        select
            t1.pno
            ,t1.client_name
            ,t1.result_rank
            ,pi2.cod_amount/100 cod
            ,pai.cogs_amount/100 cogs
            ,case
                when t1.client_name = 'lazada' and pai.cogs_amount/100 >= 1000 then 1000
                when t1.client_name = 'lazada' and pai.cogs_amount/100 < 1000 then pai.cogs_amount/100
                when t1.client_name = 'shopee' and pai.cogs_amount/100 >= 400 then 400
                when t1.client_name = 'shopee' and pai.cogs_amount/100 < 400 then pai.cogs_amount/100
                when t1.client_name = 'tiktok' and pai.cogs_amount/100 >= 400 then 400
                when t1.client_name = 'tiktok' and pai.cogs_amount/100 < 400 then pai.cogs_amount/100
                when t1.client_name = 'shein' and pai.cogs_amount/100 >= 300 then 300
                when t1.client_name = 'shein' and pai.cogs_amount/100 < 300 then pai.cogs_amount/100
                when t1.client_name in ('KA','GE') and pi2.cod_enabled = 1 then pi2.cod_amount/100
                when t1.client_name in ('KA','GE') and pi2.cod_enabled = 0 then 300
                else 0
            end parcel_value
            ,pi2.store_total_amount/100 store_total_amount
            ,t1.updated_at
        from t t1
        left join my_staging.parcel_info pi on t1.pno = pi.pno
        left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join my_staging.order_info  pai on pai.pno = if(pi.pno is null, t1.pno, pi2.pno)
#         where
#             pi.created_at >  date_sub('${sdate}', interval 2 month)
          --  and pi.created_at < date_add('${edate}', interval 16 hour)
    )
select
    t1.parcel_created_at 揽件时间
    ,t1.pno 运单号
    ,t1.client_name 客户类型
    ,v1.cogs COGS
    ,v1.cod COD
    ,v1.store_total_amount 运费
    ,cl.claim_value 实际赔付金额
    ,case t1.result_rank
        when 1 then '破损'
        when 2 then '丢失'
        when 3 then '超时效'
    end 判责类型
    ,case
        when pi.state = 8 and pi.dst_store_id = 'MY04040319' and t1.result_rank = 3 then '拍卖仓妥投成功'
        when pi.state = 8 and pi.dst_store_id != 'MY04040319' and t1.result_rank = 3 then '丢失超时效'
        when pi.state not in (5,7,8,9)  and t1.result_rank = 3 then '未终态'
        when pi.state = 5 and t1.result_rank = 3 and pi.cod_enabled = 1 then 'COD妥投'
        else null
    end 超时效后的包裹状态
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
    end as 包裹当前状态
    ,pi.returned_pno 退件单号
    ,case
        when pi.pno is null and t1.result_rank = 2 then '揽收前丢失'
        when (t1.updated_at < date_add(pr.routed_at, interval 8 hour) or pr.pno is null) and t1.result_rank = 2 then '妥投前丢失'
        when t1.updated_at >= date_add(pr.routed_at, interval 8 hour) and t1.result_rank = 2 then '妥投后丢失'
        when (t1.updated_at < date_add(pr.routed_at, interval 8 hour) or pr.pno is null) and t1.result_rank = 1 then '妥投前破损'
        when t1.updated_at >= date_add(pr.routed_at, interval 8 hour) and t1.result_rank = 1 then '妥投后破损'
        else null
    end 环节
    ,t1.updated_at 判责时间
    ,if(t1.result_rank = '3', t1.created_at, null) 超时效时间
    ,if(t1.result_rank = '3', t1.remark, null) 超时效闪速备注
    ,duty.duty_store 责任网点大区
from t t1
left join val v1 on v1.pno = t1.pno
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at >= date_sub('${sdate}', interval 2 month )
left join my_staging.parcel_route pr on pr.pno = pi.pno and pr.routed_at > date_sub('${sdate}', interval 8 hour) and pr.route_action = 'DELIVERY_CONFIRM'
left join
    (
        select
            t1.id
            ,group_concat(distinct concat(ss.name, '-', coalesce(smr.name, '')) ) duty_store
        from my_bi.parcel_lose_responsible plr
        join t t1 on t1.id = plr.lose_task_id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        group by 1
    ) duty on duty.id = t1.id
left join
    (
        select
            pct.pno
            ,json_extract(pcn.neg_result,'$.money') claim_value
            ,row_number() over (partition by pcn.task_id order by pcn.created_at desc) rk
        from my_bi.parcel_claim_task pct
        join t t1 on t1.pno = pct.pno
        left join my_bi.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.created_at > date_sub('${sdate}', interval 4 month)
        --    and pct.parcel_created_at < date_add('${edate}', interval 1 day)
            and pct.state = 6
    ) cl on cl.pno = t1.pno and cl.rk = 1