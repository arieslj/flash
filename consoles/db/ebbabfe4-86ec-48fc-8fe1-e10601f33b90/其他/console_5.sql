with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.arrival_scan_route_at
    from my_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '${date1}'
        and ds.stat_date <= '${date2}'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
select
    a2.*
from
    (
        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,ss.name 网点名称
            ,ss.opening_at 开业日期
            ,smr.name 大区
            ,smp.name 片区
            ,a.应交接
            ,a.已交接
            ,date_format(ft.plan_arrive_time, '%Y-%m-%d %H:%i:%s') 计划到达时间
            ,date_format(ft.real_arrive_time, '%Y-%m-%d %H:%i:%s') Kit到港考勤
            ,date_format(ft.sign_time, '%Y-%m-%d %H:%i:%s') fleet签到时间
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
            ,row_number() over (partition by date(ft.real_arrive_time), ft.next_store_id order by ft.real_arrive_time) rk
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
                left join
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
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        left join my_staging.sys_store ss on ss.id = a.store_id
        left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
        left join my_bi.fleet_time ft on ft.next_store_id = ss.id and ft.arrive_type in (3,5) and date(ft.real_arrive_time) = a.stat_date
        where
            ss.category = 1
            and ss.id not in ('MY04040316','MY04040315','MY04070217')
    ) a2
where
    a2.rk = 1