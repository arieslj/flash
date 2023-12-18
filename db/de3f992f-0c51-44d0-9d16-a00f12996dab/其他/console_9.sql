        join
            (
                select
                    sd.store_id
                from fle_staging.sys_district sd
                where
                    sd.deleted = 0
                    and sd.store_id is not null
                group by 1

                union all

                select
                    sd.separation_store_id store_id
                from fle_staging.sys_district sd
                where
                    sd.deleted = 0
                    and sd.separation_store_id is not null
                group by 1
            ) sd on sd.store_id = a.store_id

;

with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from bi_pro.dc_should_delivery_today ds
    where
        ds.stat_date >= '${date1}'
        and ds.stat_date <= '${date2}'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
, b as
(

        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,dp.store_name 网点名称
            ,if(dp.region_name in ('Area1', 'Area2', 'Area3', 'Area4', 'Area5', 'Area6', 'Area7', 'Area8', 'Area9', 'Area11', 'Area12', 'Area13', 'Area14', 'Area15', 'Area16'), 'Normal_Area', 'Bulky_Area') 区域
            ,dp.region_name 大区
            ,dp.piece_name 片区
            ,a.应交接
            ,a.已交接
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
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
                                    ,convert_tz(pr.routed_at, '+00:00', '+07:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from rot_pro.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 7 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 17 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        join
            (
                select
                    sd.store_id
                from fle_staging.sys_district sd
                where
                    sd.deleted = 0
                    and sd.store_id is not null
                group by 1

                union all

                select
                    sd.separation_store_id store_id
                from fle_staging.sys_district sd
                where
                    sd.deleted = 0
                    and sd.separation_store_id is not null
                group by 1
            ) sd on sd.store_id = a.store_id
        left join dwm.dim_th_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            dp.store_category in (1,10,13)
)

select
    b1.日期
    ,b1.区域
    ,b1.大区
    ,count(if(b1.交接评级 regexp 'C|D|E' and b1.交接评级 not regexp 'A|B', b1.网点ID, null))/count(b1.网点ID) 占比
from b b1
group by 1,2,3

union all

select
    b1.日期
    ,b1.区域
    ,'Total' 大区
    ,count(if(b1.交接评级 regexp 'C|D|E' and b1.交接评级 not regexp 'A|B', b1.网点ID, null))/count(b1.网点ID) 占比
from b b1
group by 1,2

union all

select
    b1.日期
    ,'Grand Total' 区域
    ,'Grand Total' 大区
    ,count(if(b1.交接评级 regexp 'C|D|E' and b1.交接评级 not regexp 'A|B', b1.网点ID, null))/count(b1.网点ID) 占比
from b b1
group by 1


;


# 明细

with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from bi_pro.dc_should_delivery_today ds
    where
        ds.stat_date >= '${date1}'
        and ds.stat_date <= '${date2}'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
select
    a.stat_date 日期
    ,a.store_id 网点ID
    ,dp.store_name 网点名称
    ,dp.opening_at 开业时间
    ,if(dp.region_name in ('Area1', 'Area2', 'Area3', 'Area4', 'Area5', 'Area6', 'Area7', 'Area8', 'Area9', 'Area11', 'Area12', 'Area13', 'Area14', 'Area15', 'Area16'), 'Normal_Area', 'Bulky_Area') 区域
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,a.应交接
    ,a.已交接
    ,concat(round(a.交接率*100,2),'%') as 交接率
    ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
    ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
    ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
    ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
    ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
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
                            ,convert_tz(pr.routed_at, '+00:00', '+07:00') route_time
                            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) route_date
                            ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                        from rot_pro.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                           and pr.routed_at >= date_sub(t1.stat_date, interval 7 hour)
                          and pr.routed_at < date_add(t1.stat_date, interval 17 hour )
                    ) sc
                where
                    sc.rk = 1
            ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
        group by 1,2
    ) a
join
    (
        select
            sd.store_id
        from fle_staging.sys_district sd
        where
            sd.deleted = 0
            and sd.store_id is not null
        group by 1

        union all

        select
            sd.separation_store_id store_id
        from fle_staging.sys_district sd
        where
            sd.deleted = 0
            and sd.separation_store_id is not null
        group by 1
    ) sd on sd.store_id = a.store_id
left join dwm.dim_th_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.store_category in (1,10,13)