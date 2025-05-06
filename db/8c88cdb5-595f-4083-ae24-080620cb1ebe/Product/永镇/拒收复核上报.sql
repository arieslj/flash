
with t as
    (
        select
            prr.pno
            ,prr.diff_info_id
            ,prr.state
            ,tt.end_date
        from fle_staging.parcel_reject_report_info prr
        left join fle_staging.parcel_info pi on pi.pno = prr.pno
        join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
        left join dwm.dwd_ex_th_tiktok_sla_detail tt on tt.pno = prr.pno
        where
            prr.created_at > '2024-04-17 17:00:00'
            and prr.created_at < '2024-04-24 17:00:00'
            and prr.state in (1,2)
    )
, a as
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'PENDING_RETURN'
            and pr.routed_at > '2024-04-16'
            and pr.routed_at > date_sub(t1.end_date, interval 7 hour )
            and pr.routed_at < date_add(t1.end_date, interval 17 hour)
            and t1.state = 1
        group by 1
    )
select
    count(distinct t1.pno) TT一周拒收量
    ,count(distinct a1.pno) '上报了拒收问题件，但无上报拒收复核，正向时效最后一天被打上待退件'
    ,count(distinct if(acc.pno is not null, a1.pno, null)) 'c列中包裹产生投诉的量'
from t t1
left join a a1 on a1.pno = t1.pno
left join bi_pro.abnormal_customer_complaint acc on acc.pno = a1.pno










;


select
    a.client_id
    ,count(distinct a.pno) pno_cnt
    ,sum(a.claim_money) total
from
    (
        select
            pct.client_id
            ,pct.pno
            ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
            ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) rk
        from bi_pro.parcel_claim_task pct
        left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.client_id in ('AA0823', 'AA0661')
            and pct.created_at > '2024-05-01'
            -- and pct.state = 6
    ) a
where
    a.rk = 1
group by a.client_id

;

select
    pi.src_name
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
    ,count(distinct pct.pno) cnt
from bi_pro.parcel_claim_task pct
join fle_staging.parcel_info pi on pi.pno = pct.pno
where
    pi.src_name = 'วรรณ'
    and pct.created_at > '2024-05-01'
group by 1,2

;



select pi.src_name from fle_staging.parcel_info pi where pi.pno = 'THT0139X7HW60Z'