-- lazada，tiktok，10.26之后
with t as
    (
        select
            a.*
        from
            (
                select
                    pi.pno
                    ,pi.state
                    ,bc.client_name
                    ,pr.routed_at first_valid_routed_at
                    ,row_number() over (partition by pi.pno order by pr.routed_at) rn
                from ph_staging.parcel_info pi
                join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id
                where
                    bc.client_name in ('lazada', 'tiktok') -- lazada,tiktok限定第三次
                    and pi.created_at > '2023-09-01' -- 做下时间限定，减少查询量
                    and pi.created_at < '2023-11-06 16:00:00'
            ) a
        where
            a.rn = 1
    )
select
    a1.de_date
    ,a1.client_name
    ,count(distinct a1.pno) total
    ,count(distinct if(a1.state = 5, a1.pno, null)) del_total
    ,count(distinct if(a1.state = 7, a1.pno, null)) return_total
from
    (
        select
            td.pno
            ,t1.state
            ,t1.client_name
            ,date(convert_tz(td.created_at, '+00:00', '+08:00')) de_date
            ,tdm.marker_id
            ,dense_rank() over (partition by td.pno order by date(convert_tz(td.created_at, '+00:00', '+08:00'))) rk
            ,convert_tz(tdm.created_at, '+00:00', '+08:00') mark_time
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        where
            td.created_at > '2023-09-01'
            and td.created_at > t1.first_valid_routed_at
            and tdm.marker_id not in ('3','4','5','6','7','15','18','19','20','21','22','32','41','43','69','71') -- 不算做有效尝试
    ) a1
where
    a1.rk = 3
    and a1.marker_id in (9,14,70)
    and a1.de_date >= '2023-10-26'
    and a1.de_date < '2023-11-07'
group by 1,2
;

-- lazada，tiktok，10.26之前

with t as
    (
        select
            a.*
        from
            (
                select
                    pi.pno
                    ,pi.state
                    ,bc.client_name
                    ,pr.routed_at first_valid_routed_at
                    ,row_number() over (partition by pi.pno order by pr.routed_at) rn
                from ph_staging.parcel_info pi
                join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id
                where
                    bc.client_name in ('lazada', 'tiktok') -- lazada,tiktok限定第三次
                    and pi.created_at > '2023-09-01' -- 做下时间限定，减少查询量
                    and pi.created_at < '2023-11-06 16:00:00'
            ) a
        where
            a.rn = 1
    )
select
    a2.de_date
    ,a2.client_name
    ,count(distinct a2.pno) total
    ,count(distinct if(a2.state = 5, a2.pno, null)) del_total
    ,count(distinct if(a2.state = 7, a2.pno, null)) return_total
#     a2.*
#     ,ppd.diff_marker_category
from  ph_staging.parcel_problem_detail ppd
join
    (
         select
            a1.*
            ,row_number() over (partition by a1.pno order by a1.de_date) rk
        from
            (
                select
                    td.pno
                    ,t1.state
                    ,t1.client_name
                    ,date(convert_tz(td.created_at, '+00:00', '+08:00')) de_date
                from ph_staging.ticket_delivery td
                join t t1 on t1.pno = td.pno
                left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    td.created_at > '2023-09-01'
                    and td.created_at > t1.first_valid_routed_at
                    and tdm.marker_id not in (3,4,5,6,7,15,18,19,20,21,22,32,41,43,69,71) -- 不算做有效尝试
                group by 1,2,3,4
            ) a1
    ) a2 on ppd.pno = a2.pno and a2.rk = 3
where
    ppd.created_at >= '2023-10-18 16:00:00'
    and ppd.created_at < '2023-10-25 16:00:00'
    and ppd.created_at > date_sub(a2.de_date, interval 8 hour)
    and ppd.created_at < date_add(a2.de_date, interval 16 hour)
    and ppd.diff_marker_category in (9,14,70)
group by 1,2

;

-- shopee26之后

with t as
    (
        select
            a.*
        from
            (
                select
                    pi.pno
                    ,pi.state
                    ,bc.client_name
                    ,pr.routed_at first_valid_routed_at
                    ,row_number() over (partition by pi.pno order by pr.routed_at) rn
                from ph_staging.parcel_info pi
                join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id
                where
                    bc.client_name in ('shopee') -- lazada,tiktok限定第三次
                    and pi.created_at > '2023-09-01' -- 做下时间限定，减少查询量
                    and pi.created_at < '2023-11-06 16:00:00'
            ) a
        where
            a.rn = 1
    )
select
    a1.de_date
    ,a1.client_name
    ,count(distinct a1.pno) total
    ,count(distinct if(a1.state = 5, a1.pno, null)) del_total
    ,count(distinct if(a1.state = 7, a1.pno, null)) return_total
from
    (
        select
            a2.*
            ,dense_rank() over (partition by a2.pno order by a2.de_date) rk
        from
            (
                select
                    td.pno
                    ,t1.state
                    ,t1.client_name
                    ,date(convert_tz(td.created_at, '+00:00', '+08:00')) de_date
                    ,weekday(date(convert_tz(td.created_at, '+00:00', '+08:00'))) day_week
                    ,tdm.marker_id
        #             ,dense_rank() over (partition by td.pno order by date(convert_tz(td.created_at, '+00:00', '+08:00'))) rk
                    ,convert_tz(tdm.created_at, '+00:00', '+08:00') mark_time
                from ph_staging.ticket_delivery td
                join t t1 on t1.pno = td.pno
                left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    td.created_at > '2023-09-01'
                    and td.created_at > t1.first_valid_routed_at
                    and tdm.marker_id not in ('3','4','5','6','7','15','18','19','20','21','22','32','41','43','69','71') -- 不算做有效尝试
            ) a2
        left join ph_staging.sys_holiday sh on sh.off_date = a2.de_date and sh.deleted = 0 and sh.company_category = 5 -- shopee 节假日标识
        where
            a2.day_week > 0
            and sh.off_date is null
    ) a1
where
    a1.rk = 2
    and a1.marker_id in (9,14,70)
    and a1.de_date >= '2023-10-26'
    and a1.de_date < '2023-11-07'
group by 1,2

;


-- shopee 26之前
with t as
    (
        select
            a.*
        from
            (
                select
                    pi.pno
                    ,pi.state
                    ,bc.client_name
                    ,pr.routed_at first_valid_routed_at
                    ,row_number() over (partition by pi.pno order by pr.routed_at) rn
                from ph_staging.parcel_info pi
                join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id
                where
                    bc.client_name in ('shopee') -- lazada,tiktok限定第三次
                    and pi.created_at > '2023-09-01' -- 做下时间限定，减少查询量
                    and pi.created_at < '2023-11-06 16:00:00'
            ) a
        where
            a.rn = 1
    )
select
    a2.de_date
    ,a2.client_name
    ,count(distinct a2.pno) total
    ,count(distinct if(a2.state = 5, a2.pno, null)) del_total
    ,count(distinct if(a2.state = 7, a2.pno, null)) return_total
#     a2.*
#     ,ppd.diff_marker_category
from  ph_staging.parcel_problem_detail ppd
join
    (
         select
            a1.*
            ,row_number() over (partition by a1.pno order by a1.de_date) rk
        from
            (
                select
                    td.pno
                    ,t1.state
                    ,t1.client_name
                    ,weekday(date(convert_tz(td.created_at, '+00:00', '+08:00'))) day_week
                    ,date(convert_tz(td.created_at, '+00:00', '+08:00')) de_date
                from ph_staging.ticket_delivery td
                join t t1 on t1.pno = td.pno
                left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    td.created_at > '2023-09-01'
                    and td.created_at > t1.first_valid_routed_at
                    and tdm.marker_id not in (3,4,5,6,7,15,18,19,20,21,22,32,41,43,69,71) -- 不算做有效尝试
                group by 1,2,3,4
            ) a1
        left join ph_staging.sys_holiday sh on sh.off_date = a1.de_date and sh.deleted = 0 and sh.company_category = 5 -- shopee 节假日标识
        where
            sh.off_date is null
            and a1.day_week > 0
    ) a2 on ppd.pno = a2.pno and a2.rk = 2
where
    ppd.created_at >= '2023-10-18 16:00:00'
    and ppd.created_at < '2023-10-25 16:00:00'
    and ppd.created_at > date_sub(a2.de_date, interval 8 hour)
    and ppd.created_at < date_add(a2.de_date, interval 16 hour)
    and ppd.diff_marker_category in (9,14,70)
group by 1,2