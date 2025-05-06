with t as
    (
        select
            t.p_date
            ,t.staff
            ,t.store
            ,pr.routed_at
            ,pr.pno
            ,row_number() over (partition by t.p_date,t.staff,t.store order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_staff_1124 t on t.staff = pr.staff_info_id and t.store = pr.store_name
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at >= date_sub(t.p_date, interval 8 hour )
            and pr.routed_at < date_add(t.p_date, interval 16 hour)
    )
select
    s.p_date
    ,s.staff
    ,s.store
    ,count(distinct a2.pno) 包裹数
from tmpale.tmp_ph_staff_1124 s
left join

    (
        select
            t1.*
        from  t  t1
        left join t t2 on t1.p_date = t2.p_date and t1.staff = t2.staff and t1.store = t2.store and t2.rk = 1
        where
            t1.routed_at < date_add(t2.routed_at, interval 2 hour)
    ) a2 on a2.p_date = s.p_date and a2.staff = s.staff and a2.store = s.store
group by 1,2,3
;


-- 三段码

select
    *
from
    (
        select
            t.pno
            ,ps.sorting_code
            ,ps.first_sorting_code
            ,ps.second_sorting_code
            ,ps.third_sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc) rk
        from ph_drds.parcel_sorting_code_info ps
        join tmpale.tmp_ph_pno_1129 t on t.pno = ps.pno
    ) a
where
    a.rk = 1

