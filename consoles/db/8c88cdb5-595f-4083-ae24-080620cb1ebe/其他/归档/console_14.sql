with t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
        ,ds.state
        ,case when pr1.pno is not null then 'N' when pr2.pno is not null then 'N' when ds1.pno is not null  then 'N'  else 'Y' end as handover_type
    from bi_pro.dc_should_delivery_today ds
    left join
    (
        select
           pr.pno
           ,max(convert_tz(pr.routed_at,'+00:00','+07:00')) remote_marker_time
        from rot_pro.parcel_route pr
        where 1=1
        and pr.routed_at >= convert_tz(DATE(DATE_SUB(NOW(), INTERVAL 1 HOUR)), '+07:00', '+00:00')
        and pr.route_action = 'DETAIN_WAREHOUSE'
        and pr.marker_category in (42,43) ##岛屿,偏远地区
        group by 1
    ) pr1  on ds.pno=pr1.pno#当日留仓标记为偏远地区留待次日派送
    left join
    (
        select
           pr.pno
           ,convert_tz(pr.routed_at,'+00:00','+07:00') reschedule_marker_time
           ,date(date_sub(FROM_UNIXTIME(json_extract(pr.extra_value,'$.desiredAt')),interval 1 hour)) desire_date
           ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        where 1=1
        and pr.routed_at >= date_sub(DATE(DATE_SUB(NOW(), INTERVAL 1 HOUR)),15)
        and pr.routed_at <  date_sub(DATE(DATE_SUB(NOW(), INTERVAL 1 HOUR)),interval 7 hour) #限定当日之前的改约
        and pr.route_action = 'DETAIN_WAREHOUSE'
        and date(date_sub(FROM_UNIXTIME(json_extract(pr.extra_value,'$.desiredAt')),interval 1 hour))>current_date
        and pr.marker_category in (9,14,70) ##客户改约时间
    ) pr2 on ds.pno=pr2.pno and pr2.rk=1 #当日之前客户改约时间
    left join bi_pro.dc_should_delivery_today ds1 on ds.pno=ds1.pno and ds1.state=6 and ds1.stat_date=date_sub(current_date,interval 1 day)
    where ds.stat_date = curdate() and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
    and case when pr1.pno is not null then 'N' when pr2.pno is not null then 'N' when ds1.pno is not null  then 'N'  else 'Y' end = 'Y'
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
/*
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
 */
left join dwm.dim_th_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where dp.store_category in (1,10,13)