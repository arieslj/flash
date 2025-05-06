with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
#         ds.stat_date >= '${date1}'
#         and ds.stat_date <= '${date2}'
        ds.stat_date = curdate()
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
, s as
(
    select
        sc.*
    from
        (
            select
                pr.pno
                ,pr.store_id
                ,pr.store_name
                ,t1.stat_date
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
            from my_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
               and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
              and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
        ) sc
    where
        sc.rk = 1
)
select
    s2.stat_date 日期
    ,s2.store_name 网点
    ,s2.staff_info_id 员工ID
    ,a1.交接评级
    ,s2.pno 运单号
    ,s2.route_time 第一次交接时间
from
    (
        select
            a.stat_date 日期
            ,a.store_id
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率

                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join s sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_bi.fleet_time ft on ft.next_store_id = a.store_id and a.stat_date = date(ft.plan_arrive_time) and ft.arrive_type in (3,5)
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a1
join s s2 on s2.store_id = a1.store_id
where
    a1.交接评级 regexp 'C|D|E'
    and a1.交接评级 not regexp 'A|B'
