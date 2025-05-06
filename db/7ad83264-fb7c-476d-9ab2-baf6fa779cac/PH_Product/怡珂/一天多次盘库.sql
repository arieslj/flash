with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00'))  inv_date
            ,pr.pno
            ,count(pr.id) inv_cnt
        from ph_staging.parcel_route pr
        where
            pr.route_action = 'INVENTORY'
            and pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour)
        group by 1,2
        having count(pr.id) > 1
    )
, a as
    (
        select
            a.pno
            ,a.inv_cnt
            ,a.inv_date
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.inv_cnt desc) rk
                from t t
            ) a
        where
            a.rk = 1
    )
select
    a1.pno
    ,a1.inv_cnt 一天内盘库次数_最多
    ,p2.inv_cnt_total 近一周盘库次数
    ,p3.store_name 盘库网点
    ,p3.staff_info_id 盘库人工号
from a a1
left join
    (
        select
            t1.pno
            ,sum(t1.inv_cnt) inv_cnt_total
        from t t1
        group by 1
    ) p2 on p2.pno = a1.pno
left join
    (
        select
            a1.pno
            ,a1.inv_date
            ,pr.store_name
            ,pr.staff_info_id
            ,row_number() over (partition by a1.pno, a1.inv_date order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join a a1 on a1.pno = pr.pno
        where
            pr.route_action = 'INVENTORY'
            and pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour)
            and pr.routed_at > date_sub(a1.inv_date, interval 8 hour)
            and pr.routed_at < date_add(a1.inv_date, interval 16 hour)
    ) p3 on p3.pno = a1.pno and p3.rk = 1