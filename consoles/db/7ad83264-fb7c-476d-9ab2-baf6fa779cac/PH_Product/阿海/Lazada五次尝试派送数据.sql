with t as
    (
        select
            pi.pno
            ,pi.finished_at
            ,pi.created_at
        from ph_staging.parcel_info pi
        where
            pi.state = 5
            and pi.finished_at >= '2023-08-31 16:00:00'
            and pi.finished_at < '2023-09-15 16:00:00'
            and pi.client_id in ('AA0121','AA0139','AA0050','AA0051','AA0080')
    )
select
    a2.pno
    ,a2.days_count
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.pr_date) rk2
            ,count(a.pr_date) over(partition by a.pno) days_count
        from
            (
                select
                    pr.pno
                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                    ,pr.marker_category
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+08:00')) order by pr.routed_at desc ) rk
#                     ,count(distinct date(convert_tz(pr.routed_at, '+00:00', '+08:00'))) over (partition by pr.pno) as del_days
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > date_sub(curdate(), interval 100 day)
                    and pr.route_action = 'DELIVERY_MARKER'
                    and pr.marker_category not in (7,22,5,20,6,21,15,71)
            ) a
        where
            a.rk = 1
    ) a2
where
    a2.rk2 = 5
    and a2.marker_category in (9,14,70)
    and a2.days_count > 5

;


# select
#     pi.pno
#     ,pi.cod_amount/100 cod
#     ,pi.src_name sender_name
# from ph_staging.parcel_route pr
# left join ph_staging.parcel_info pi on pi.pno = pr.pno
# where
#     pr.routed_at > '2023-10-07 16:00:00'
#     and pr.routed_at < '2023-10-08 16:00:00'
#     and pr.staff_info_id = '148531'
#     and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
# group by 1

;


with t as
    (
        select
            pi.pno
            ,de.delievey_end_date
            ,de.whole_end_date
            ,pi.returned_pno
        from ph_staging.parcel_info pi
        left join dwm.dwd_ex_ph_lazada_pno_period de on de.pno = pi.pno
        where
            pi.state = 7
            and pi.created_at >= date_sub(curdate(), interval 60 day)
            and pi.client_id in ('AA0121','AA0139','AA0050','AA0051','AA0080')
            and pi.returned = 0
    )
select
    count(distinct a2.pno ) 总退件量
    ,count(a2.pr_date <= a2.delievey_end_date and a2.fin_date > a2.whole_end_date, a2.pno, null) Overall时效外退件量
    ,count(a2.pr_date <= a2.delievey_end_date and a2.fin_date > a2.whole_end_date, a2.pno, null)/count(distinct a2.pno ) Overall时效外退件占比
from
    (
        select
            a1.*
        from
            (
                select
                    a.pno
                    ,a.pr_date
                    ,a.delievey_end_date
                    ,a.whole_end_date
                    ,if(pi2.state = 5, date(convert_tz(pi2.finished_at, '+00:00', '+08:00')), null) fin_date
                    ,row_number() over (partition by a.pno order by a.pr_date) rk
                from
                    (
                        select
                            pr.pno
                            ,t1.delievey_end_date
                            ,t1.whole_end_date
                            ,t1.returned_pno
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                        from ph_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.routed_at > date_sub(curdate(), interval 100 day)
                            and pr.route_action = 'DELIVERY_MARKER'
                            and pr.marker_category not in (7,22,5,20,6,21,15,71)
                        group by 1,2,3,4,5
                    ) a
                left join ph_staging.parcel_info pi2 on pi2.pno = a.returned_pno
            ) a1
        where
            a1.rk = 4
    ) a2
;

select
    a3.pno
    ,a3.CN_element 第三次尝试派送失败原因
    ,a3.days_count 派送次数
    ,case a3.pi_state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
from
    (
        select
            a2.*
            ,ddd.CN_element
        from
            (
                  select
                    a.*
                    ,count(a.pr_date) over (partition by a.pno) days_count
                    ,row_number() over (partition by a.pno order by a.pr_date) rk2
                from
                    (
                           select
                            pi.pno
                            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                            ,pr.marker_category
                            ,pi.state pi_state
                            ,row_number() over (partition by pr.pno,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) order by pr.routed_at desc) rk
                        from ph_staging.parcel_info pi
                        join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'DELIVERY_MARKER' and pr.routed_at > date_sub(curdate(), interval 60 day) and pr.marker_category not in (7,22,5,20,6,21,15,71)
                        where
                            pi.created_at > date_sub(curdate(), interval 60 day)
                            and pi.client_id in ('AA0121','AA0139','AA0050','AA0051','AA0080')
                            and pi.returned = 0
                    ) a
                where
                    a.rk = 1
            ) a2
        left join dwm.dwd_dim_dict ddd on ddd.element = a2.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            a2.rk2 = 3
    ) a3
where
    a3.pr_date >= '2023-09-04'
    and a3.pr_date < curdate()
    and a3.days_count > 3
