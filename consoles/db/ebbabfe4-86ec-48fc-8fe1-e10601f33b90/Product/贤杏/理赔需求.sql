select
    month(pct.created_at) 月份
    ,count(pct.id) 全网理赔量
from my_bi.parcel_claim_task pct
where
    pct.created_at >= '2024-01-01'
    and pct.created_at < '2024-07-01'
    and pct.state < 7
group by 1
;


select
    a.p_month 月份
    ,sum(a.claim_money) 理赔金额
from
    (
        select
            a.p_month
            ,a.id
            ,json_extract(a.neg_result, '$.money') claim_money
        from
            (
                select
                    month(pct.created_at) p_month
                    ,pct.id
                    ,pcn.neg_result
                    ,row_number() over (partition by pcn.task_id order by pcn.created_at desc) rk
                from my_bi.parcel_claim_task pct
                left join my_bi.parcel_claim_negotiation pcn on pcn.task_id = pct.id
                where
                    pct.created_at >= '2024-01-01'
                    and pct.created_at < '2024-07-01'
                    and pct.state = 6
            ) a
        where
            a.rk = 1
    ) a
group by a.p_month

;

select
    a1.p_month
    ,a2.pct_cnt 理赔量
    ,a1.pi_cnt 揽收量
    ,a2.pct_cnt / a1.pi_cnt 超时理赔率
from
    (
        select
            month(convert_tz(pi.created_at, '+00:00', '+08:00')) p_month
            ,count(distinct pi.pno) pi_cnt
        from my_staging.parcel_info pi
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
        where
            pi.returned = 0
            and pi.created_at > '2023-12-31 16:00:00'
            and pi.created_at < '2024-06-30 16:00:00'
        group by 1
    ) a1
left join
    (
        select
            month(pct.created_at) p_month
            ,count(pct.id) pct_cnt
        from my_bi.parcel_claim_task pct
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pct.client_id
        where
            pct.created_at >= '2024-01-01'
            and pct.created_at < '2024-07-01'
            and pct.source = 11
            and pct.state = 6
        group by 1
    ) a2 on a1.p_month = a2.p_month