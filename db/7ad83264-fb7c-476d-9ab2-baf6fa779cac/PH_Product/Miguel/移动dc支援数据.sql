with a as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,t.staff
            ,pr.routed_at
            ,pr.pno
            ,row_number() over (partition by date(convert_tz(pr.routed_at, '+00:00', '+08:00')),pr.staff_info_id order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_staff_lj_0109 t on t.staff = pr.staff_info_id
        where
            pr.routed_at > '2023-11-30 16:00:00'
            and pr.routed_at < '2023-12-31 16:00:00'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )

select
    t.staff
    ,t1.pr_date
    ,count(distinct t1.pno) handover_pno_count
from tmpale.tmp_ph_staff_lj_0109 t
left join
    (
        select
            t1.*
        from a t1
        left join a t2 on t2.pr_date = t1.pr_date and t2.staff = t1.staff and t2.rk = 1
        where
            t1.routed_at < date_add(t2.routed_at, interval 2 hour)
    ) t1 on t1.staff = t.staff
group by 1,2