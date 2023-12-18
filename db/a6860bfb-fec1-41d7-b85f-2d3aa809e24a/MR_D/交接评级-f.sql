    with d as
    (
        select
             ds.dst_store_id store_id
            ,ds.pno
            ,ds.p_date stat_date
        from dwm.dwd_ph_dc_should_be_delivery ds
        where
            ds.should_delevry_type = '1派应派包裹'
            and ds.p_date = '${date}'
    )
    , t as
    (
        select
             ds.store_id
            ,ds.pno
            ,ds.stat_date
        from d ds
        left join
            (
                select
                    pr.pno
                    ,ds.stat_date
                    ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
                from ph_staging.parcel_route pr
                join d ds on pr.pno = ds.pno
                where 1=1
                    and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                    and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                    and pr.route_action = 'DETAIN_WAREHOUSE'
                    and pr.marker_category in (42,43) ##岛屿,偏远地区
                group by 1,2
            ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
        left join
            (
                select
                   pr.pno
                    ,ds.stat_date
                   ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
                   ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
                from ph_staging.parcel_route pr
                join d ds on ds.pno = pr.pno
                where 1=1
                    and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                    and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                    and pr.route_action = 'DETAIN_WAREHOUSE'
                    and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                    and pr.marker_category in (9,14,70) ##客户改约时间
            ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
        left join ph_bi.dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
        where
            case
                when pr1.pno is not null then 'N'
                when pr2.pno is not null then 'N'
                when ds1.pno is not null  then 'N'  else 'Y'
            end = 'Y'
    )
    select
        a.stat_date 日期
        ,a.store_id 网点ID
        ,dp.store_name 网点名称
        ,dp.opening_at 开业时间
        ,case
            when dp.region_name in ('Area3', 'Area6') then '彭万松'
            when dp.region_name in ('Area4', 'Area9') then '韩钥'
            when dp.region_name in ('Area7','Area10', 'Area11','FHome') then '张可新'
            when dp.region_name in ( 'Area8') then '黄勇'
            when dp.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
        end 区域
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
                                ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                            from ph_staging.parcel_route pr
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
    join
        (
            select
                sd.store_id
            from ph_staging.sys_district sd
            where
                sd.deleted = 0
                and sd.store_id is not null
            group by 1

            union all

            select
                sd.separation_store_id store_id
            from ph_staging.sys_district sd
            where
                sd.deleted = 0
                and sd.separation_store_id is not null
            group by 1
        ) sd on sd.store_id = a.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
    where
        dp.store_category in (1,10)

    ;

