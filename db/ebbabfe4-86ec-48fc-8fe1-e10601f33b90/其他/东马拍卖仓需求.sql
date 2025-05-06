-- 东马
select
    pr.pno '运单号'
    ,pr.store_name 网点
    ,pr.关闭订单日期
    ,if(pi2.returned=1,pi2.customary_pno,pi2.pno) '原单号'
    ,pi2.client_id '客户ID'
    ,te.client_name '客户类型'
    ,oi.cogs_amount/100 'COGS'
    ,oi.cod_amount/100 'COD金额'
    ,ifnull(pct.money,pct1.money) '理赔金额'
    ,if(pct2.duty_result=1 or pct3.duty_result=1,'是','否') '是否判责丢失'
    ,if(pct2.duty_result=2 or pct3.duty_result=2,'是','否') '是否判责破损'
    ,case
        when te.client_name = 'lazada' and oi.cogs_amount/100 >= 1000 then 1000
        when te.client_name = 'lazada' and oi.cogs_amount/100 < 1000 then oi.cogs_amount/100
        when te.client_name = 'shopee' and oi.cogs_amount/100 >= 400 then 400
        when te.client_name = 'shopee' and oi.cogs_amount/100 < 400 then oi.cogs_amount/100
        when te.client_name = 'tiktok' and oi.cogs_amount/100 >= 400 then 400
        when te.client_name = 'tiktok' and oi.cogs_amount/100 < 400 then oi.cogs_amount/100
        when te.client_name = 'shein' and oi.cogs_amount/100 >= 300 then 300
        when te.client_name = 'shein' and oi.cogs_amount/100 < 300 then oi.cogs_amount/100
        when te.client_name is null and pi.cod_enabled = 1 then pi.cod_amount/100
        when te.client_name is null and pi.cod_enabled = 0 then 300
        else 0
    end 理论理赔上限金额
from
    (
        select
            pr.pno
            ,pr.store_name
            ,date(convert_tz(pr.routed_at,'+00:00','+08:00')) '关闭订单日期'
        from my_staging.parcel_route pr
        where pr.routed_at>=convert_tz('${sdate}','+08:00','+00:00')
        and pr.routed_at <convert_tz(date_add('${edate}',interval 1 day),'+08:00','+00:00')
        and pr.route_action='CHANGE_PARCEL_CLOSE'
        and pr.store_id in ('MY14040300', 'MY15050300')
    )pr
left join my_staging.parcel_info pi2 on pi2.pno=pr.pno and pi2.created_at>convert_tz(date_sub('${sdate}',interval 180 day),'+08:00','+00:00')
left join my_staging.parcel_info pi on pi.pno = if(pi2.returned=1,pi2.customary_pno,pi2.pno) and pi.created_at>convert_tz(date_sub('${sdate}',interval 180 day),'+08:00','+00:00')
left join my_staging.order_info oi on oi.pno=if(pi2.returned=1,pi2.customary_pno,pi2.pno)  and oi.created_at>convert_tz(date_sub('${sdate}',interval 180 day),'+08:00','+00:00')
left join dwm.tmp_ex_big_clients_id_detail te on te.client_id=pi2.client_id
left join
    (
        select
            pct.pno
            ,replace(json_extract(pcn.neg_result,'$.money'),'\"','') money
            ,row_number()over(partition by pct.pno order by pcn.created_at  desc) as rk
        from my_bi.parcel_claim_task pct
        join my_bi.parcel_claim_negotiation pcn on pct.id=pcn.task_id
        where pct.created_at>=date_sub('${sdate}',interval 90 day)
        and pcn.neg_type in (1,5,7)
    )pct on pct.pno=pr.pno and pct.rk =1

left join
    (
        select
            pct.pno
            ,replace(json_extract(pcn.neg_result,'$.money'),'\"','') money
            ,row_number()over(partition by pct.pno order by pcn.created_at  desc) rk
        from my_bi.parcel_claim_task pct
        join my_bi.parcel_claim_negotiation pcn on pct.id=pcn.task_id
        where pct.created_at>=date_sub('${sdate}',interval 90 day)
        and pcn.neg_type in (1,5,7)
    )pct1 on pct1.pno=pi2.customary_pno and pct1.rk=1

left join
    (
        select
            pct.pno
            ,pct.duty_result
            ,row_number()over(partition by pct.pno order by pct.created_at desc) rk
        from my_bi.parcel_claim_task pct
        where pct.created_at>=date_sub('${sdate}',interval 90 day)
        and pct.duty_result in(1,2)
        and pct.state=6
    )pct2 on pct2.pno=pr.pno and pct2.rk=1

left join
    (
        select
            pct.pno
            ,pct.duty_result
            ,row_number()over(partition by pct.pno order by pct.created_at desc) rk
        from my_bi.parcel_claim_task pct
        where pct.created_at>=date_sub('${sdate}',interval 90 day)
        and pct.duty_result in(1,2)
        and pct.state=6
    )pct3 on pct3.pno=pi2.customary_pno and pct3.rk=1
group by 1

;


-- 海运


select
    pr.pno '运单号'
    ,pr.关闭订单日期
    ,if(pi2.returned=1,pi2.customary_pno,pi2.pno) '原单号'
    ,pi2.client_id '客户ID'
    ,te.client_name '客户类型'
    ,oi.cogs_amount/100 'COGS'
    ,oi.cod_amount/100 'COD金额'
    ,ifnull(pct.money,pct1.money) '理赔金额'
    ,if(pct2.duty_result=1 or pct3.duty_result=1,'是','否') '是否判责丢失'
    ,if(pct2.duty_result=2 or pct3.duty_result=2,'是','否') '是否判责破损'
    ,case
        when te.client_name = 'lazada' and oi.cogs_amount/100 >= 1000 then 1000
        when te.client_name = 'lazada' and oi.cogs_amount/100 < 1000 then oi.cogs_amount/100
        when te.client_name = 'shopee' and oi.cogs_amount/100 >= 400 then 400
        when te.client_name = 'shopee' and oi.cogs_amount/100 < 400 then oi.cogs_amount/100
        when te.client_name = 'tiktok' and oi.cogs_amount/100 >= 400 then 400
        when te.client_name = 'tiktok' and oi.cogs_amount/100 < 400 then oi.cogs_amount/100
        when te.client_name = 'shein' and oi.cogs_amount/100 >= 300 then 300
        when te.client_name = 'shein' and oi.cogs_amount/100 < 300 then oi.cogs_amount/100
        when te.client_name is null and pi.cod_enabled = 1 then pi.cod_amount/100
        when te.client_name is null and pi.cod_enabled = 0 then 300
        else 0
    end 理论理赔上限金额
from
    (
        select
            pi.pno
            ,date(convert_tz(pi.finished_at,'+00:00','+08:00')) '关闭订单日期'
        from my_staging.parcel_info pi
        where
            pi.finished_at >=convert_tz('${sdate}','+08:00','+00:00')
            and pi.finished_at <convert_tz(date_add('${edate}',interval 1 day),'+08:00','+00:00')
            and pi.dst_store_id = 'MY04040319' -- MS1
    )pr
left join my_staging.parcel_info pi2 on pi2.pno=pr.pno and pi2.created_at>convert_tz(date_sub('${sdate}',interval 180 day),'+08:00','+00:00')
left join my_staging.parcel_info pi on pi.pno = if(pi2.returned=1,pi2.customary_pno,pi2.pno) and pi.created_at>convert_tz(date_sub('${sdate}',interval 180 day),'+08:00','+00:00')
left join my_staging.order_info oi on oi.pno=if(pi2.returned=1,pi2.customary_pno,pi2.pno)  and oi.created_at>convert_tz(date_sub('${sdate}',interval 180 day),'+08:00','+00:00')
left join dwm.tmp_ex_big_clients_id_detail te on te.client_id=pi2.client_id
left join
    (
        select
            pct.pno
            ,replace(json_extract(pcn.neg_result,'$.money'),'\"','') money
            ,row_number()over(partition by pct.pno order by pcn.created_at  desc) as rk
        from my_bi.parcel_claim_task pct
        join my_bi.parcel_claim_negotiation pcn on pct.id=pcn.task_id
        where pct.created_at>=date_sub('${sdate}',interval 90 day)
        and pcn.neg_type in (1,5,7)
    )pct on pct.pno=pr.pno and pct.rk =1

left join
    (
        select
            pct.pno
            ,replace(json_extract(pcn.neg_result,'$.money'),'\"','') money
            ,row_number()over(partition by pct.pno order by pcn.created_at  desc) rk
        from my_bi.parcel_claim_task pct
        join my_bi.parcel_claim_negotiation pcn on pct.id=pcn.task_id
        where pct.created_at>=date_sub('${sdate}',interval 90 day)
        and pcn.neg_type in (1,5,7)
    )pct1 on pct1.pno=pi2.customary_pno and pct1.rk=1

left join
    (
        select
            pct.pno
            ,pct.duty_result
            ,row_number()over(partition by pct.pno order by pct.created_at desc) rk
        from my_bi.parcel_claim_task pct
        where pct.created_at>=date_sub('${sdate}',interval 90 day)
        and pct.duty_result in(1,2)
        and pct.state=6
    )pct2 on pct2.pno=pr.pno and pct2.rk=1

left join
    (
        select
            pct.pno
            ,pct.duty_result
            ,row_number()over(partition by pct.pno order by pct.created_at desc) rk
        from my_bi.parcel_claim_task pct
        where pct.created_at>=date_sub('${sdate}',interval 90 day)
        and pct.duty_result in(1,2)
        and pct.state=6
    )pct3 on pct3.pno=pi2.customary_pno and pct3.rk=1
group by 1
