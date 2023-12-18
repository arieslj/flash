select
    month(date_add(pi.created_at, interval 7 hour)) p_month
    ,count(if(plt.duty_result = 1, pi.pno , null))/count(pi.pno) 丢失率
    ,count(if(plt.duty_result = 2, pi.pno , null))/count(pi.pno) 破损率
from la_staging.parcel_info pi
left join la_bi.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 6
where
    pi.created_at >= '2022-12-31 17:00:00'
    and pi.created_at < '2023-06-30 17:00:00'
    and pi.returned = 0
    and pi.state < 9
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(convert_tz(tp.created_at, '+00:00', '+08:00')) p_month
    ,count(distinct tp.id ) 任务数
    ,count(distinct ac.id) 投诉数
    ,count(distinct ac.id)/count(distinct tp.id )
from la_staging.ticket_pickup tp
left join
    (
        select
            am.merge_column
            ,acc.id
        from la_bi.abnormal_customer_complaint acc
        left join la_bi.abnormal_message am on acc.abnormal_message_id = am.id
        where
            acc.created_at >= '2023-01-01'
#             and acc.created_at < '2023-07-01'
            and am.relative_type = 2
    ) ac on ac.merge_column = tp.id
where
    tp.created_at >= '2022-12-31 17:00:00'
    and tp.created_at < '2023-06-30 17:00:00'
    and tp.state in (0,1,2,4)
    and tp.channel_category in (1,2,3,4,8,12)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(convert_tz(tp.created_at, '+00:00', '+08:00')) p_month
    ,count(distinct tp.id ) 任务数
    ,count(distinct ac.id) 投诉数
    ,count(distinct ac.id)/count(distinct tp.id )
from la_staging.ticket_pickup tp
left join
    (
        select
            am.merge_column
            ,acc.id
        from la_bi.abnormal_customer_complaint acc
        left join la_bi.abnormal_message am on acc.abnormal_message_id = am.id
        where
            acc.created_at >= '2023-01-01'
#             and acc.created_at < '2023-07-01'
            and am.relative_type = 2
    ) ac on ac.merge_column = tp.id
where
    tp.created_at >= '2022-12-31 17:00:00'
    and tp.created_at < '2023-06-30 17:00:00'
    and tp.state in (0,1,2,4)
#     and tp.channel_category in (1,2,3,4,8,12)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(convert_tz(pi.created_at, '+00:00', '+08:00')) p_month
    ,count(distinct pi.pno ) 任务数
    ,count(distinct ac.id) 投诉数
    ,count(distinct ac.id)/count(distinct pi.pno )
from la_staging.parcel_info pi
left join
    (
        select
            am.merge_column
            ,acc.id
        from la_bi.abnormal_customer_complaint acc
        left join la_bi.abnormal_message am on acc.abnormal_message_id = am.id
        where
            acc.created_at >= '2023-01-01'
#             and acc.created_at < '2023-07-01'
            and am.relative_type = 1
    )  ac on ac.merge_column = pi.pno
where
    pi.created_at >= '2022-12-31 16:00:00'
    and pi.created_at < '2023-06-30 16:00:00'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(pct.created_at) p_month
    ,count(pct.id) pct_num
from la_bi.parcel_claim_task pct
where
    pct.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(pct.created_at) p_month
    ,count(pct.id) pct_num
from la_bi.parcel_claim_task pct
where
    pct.state = 6
    and pct.created_at >= '2023-01-01'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.p_month
    ,sum(a.claim_money) money_num
from
    (
        select
            a.*
        from
            (
                select
                    month(pct.created_at) p_month
                    ,pct.id
                    ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                    ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) rn
                from la_bi.parcel_claim_task pct
                left join la_bi.parcel_claim_negotiation pcn on pcn.task_id = pct.id
                where
                    pct.state = 6
                    and pct.created_at >= '2023-01-01'
                    and pct.created_at < '2023-07-01'
            ) a
        where
            a.rn = 1
    ) a
group by 1;