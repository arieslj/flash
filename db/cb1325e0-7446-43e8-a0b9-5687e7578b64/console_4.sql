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
            t1.*
            ,ss.name
            ,sc.route_time 第一次交接时间
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
left join my_staging.sys_store ss on ss.id = t1.store_id