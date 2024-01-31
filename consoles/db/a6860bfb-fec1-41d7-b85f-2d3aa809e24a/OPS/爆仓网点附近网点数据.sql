with t as
(
    select
        a1.*
        ,a2.capacity
        ,a2.backlog_count
    from
        (
            select
                ds.store_id
                ,count(if(pi.state = 5 and pi.finished_at >= date_sub(curdate(), interval 32 hour ) and pi.finished_at < date_sub(curdate(), interval 8 hour ), ds.pno, null))/count(ds.pno) del_rate
            from ph_bi.dc_should_delivery_today ds
            left join ph_staging.parcel_info pi on pi.pno = ds.pno and pi.created_at >= date_sub(curdate(), interval 90 day)
            where
                ds.stat_date = date_sub(curdate(), interval 1 day)
            group by 1
            having count(if(pi.state = 5 and pi.finished_at >= date_sub(curdate(), interval 32 hour ) and pi.finished_at < date_sub(curdate(), interval 8 hour ), ds.pno, null))/count(ds.pno) < 0.7 -- 妥投率低于 70%
        ) a1
    join
        (
            select
                b1.store_id
                ,b1.backlog_count
                ,sc.capacity
            from
                (
                    select
                        ds.store_id
                        ,count(ds.pno) backlog_count
                    from ph_bi.dc_should_delivery_today ds
                    join ph_staging.parcel_info pi on pi.pno = ds.pno
                    where
                        ds.stat_date = curdate()
                        and pi.state not in (5,7,8,9)
                    group by 1
                ) b1
            left join tmpale.tmp_ph_store_capacity sc on sc.store_id = b1.store_id
            where
                b1.backlog_count > sc.capacity*2
        ) a2 on a1.store_id = a2.store_id
)
select
    curdate() 统计日期
    ,t1.id 爆仓网点id
    ,t1.name 爆仓网点
    ,dp2.piece_name 爆仓网点所属片区
    ,dp2.region_name 爆仓网点所属大区
    ,t3.courier_count 爆仓网点在职快递员数
    ,inb.inb_count 爆仓网点近3日日均进港量
    ,t1.capacity 爆仓网点产能
    ,t1.backlog_count 爆仓网点积压量
    ,t1.del_rate 爆仓网点妥投率
    ,t1.ss2_id 爆仓网点相近30km内网点id
    ,t1.ss2_name 爆仓网点相近30km内网点
    ,dp.piece_name  所属片区
    ,dp.region_name 所属大区
    ,t1.ss_distiance_km 距离
    ,t2.courier_count 目前在职快递员数
    ,sce1.inbound_count 昨日进港量
    ,sce2.inbound_count 前日进港量
    ,sce3.inbound_count 2日前进港量
    ,day1.total_should_del 昨日应派
    ,day1.total_fin_count 昨日妥投
    ,day1.total_rate 昨日妥投率
    ,day1.forward_should_del 昨日正向应派
    ,day1.forward_fin_count 昨日正向妥投
    ,day1.forward_rate 昨日正向妥投率
    ,day2.total_should_del 前日应派
    ,day2.total_fin_count 前日妥投
    ,day2.total_rate 前日妥投率
    ,day2.forward_should_del 前日正向应派
    ,day2.forward_fin_count 前日正向妥投
    ,day2.forward_rate 前日正向妥投率
    ,day3.total_should_del 2日前应派
    ,day3.total_fin_count 2日前妥投
    ,day3.total_rate 2日前妥投率
    ,day3.forward_should_del 2日前正向应派
    ,day3.forward_fin_count 2日前正向妥投
    ,day3.forward_rate 2日前正向妥投率
from
    (
        select
            ss.id
            ,ss.name
            ,t1.capacity
            ,t1.backlog_count
            ,t1.del_rate
            ,ss2.id ss2_id
            ,ss2.name ss2_name
            ,st_distance_sphere(point(ss.lng, ss.lat), point(ss2.lng, ss2.lat))/1000  ss_distiance_km
        from ph_staging.sys_store ss
        join t t1 on t1.store_id = ss.id
        left join ph_staging.sys_store ss2 on ss2.id != ss.id and ss2.state = 1
        where
            st_distance_sphere(point(ss.lng, ss.lat), point(ss2.lng, ss2.lat)) < 30000
             and ss2.category = 1
    ) t1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.ss2_id and dp.stat_date =date_sub(curdate(), interval 1 day)
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = t1.id and dp2.stat_date =date_sub(curdate(), interval 1 day)
left join
    (
        select
            hsi.sys_store_id
            ,count(distinct hsi.staff_info_id) courier_count
        from ph_bi.hr_staff_info hsi
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.state = 1
            and hsi.job_title in (13,110,1000)
        group by 1
    ) t2 on t2.sys_store_id = t1.ss2_id
left join
    (
        select
            hsi.sys_store_id
            ,count(distinct hsi.staff_info_id) courier_count
        from ph_bi.hr_staff_info hsi
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.state = 1
            and hsi.job_title in (13,110,1000)
        group by 1
    ) t3 on t3.sys_store_id = t1.id
left join
    (
        select
            sce.store_id
            ,avg(sce.inbound_count) inb_count
        from ph_bi.store_collection_efficiency sce
        where
            stat_date<= date(CURRENT_DATE - interval 1 day)
            and stat_date>= date(CURRENT_DATE - interval 3 day)
        group by 1
    ) inb on inb.store_id = t1.id
left join ph_bi.store_collection_efficiency sce1 on sce1.store_id = t1.ss2_id and sce1.stat_date = date_sub(curdate(), interval 1 day)
left join ph_bi.store_collection_efficiency sce2 on sce2.store_id = t1.ss2_id and sce2.stat_date = date_sub(curdate(), interval 2 day)
left join ph_bi.store_collection_efficiency sce3 on sce3.store_id = t1.ss2_id and sce3.stat_date = date_sub(curdate(), interval 3 day)
left join
    (
        select
            ds.store_id
            ,count(ds.pno) total_should_del
            ,count(if(pi.returned = 0, ds.pno, null)) forward_should_del
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 1 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour), ds.pno, null)) total_fin_count
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 1 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour) and pi.returned = 0, ds.pno, null)) forward_fin_count
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 1 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour), ds.pno, null))/count(ds.pno) total_rate
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 1 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour) and pi.returned = 0, ds.pno, null))/count(if(pi.returned = 0, ds.pno, null)) forward_rate
        from ph_bi.dc_should_delivery_today ds
        left join ph_staging.parcel_info pi on pi.pno = ds.pno and pi.created_at > date_sub(curdate(), interval 90 day)
        where
            ds.stat_date = date_sub(curdate(), interval 1 day)
        group by 1
    ) day1 on day1.store_id = t1.ss2_id
left join
    (
        select
            ds.store_id
            ,count(ds.pno) total_should_del
            ,count(if(pi.returned = 0, ds.pno, null)) forward_should_del
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 2 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 2 day), interval 16 hour), ds.pno, null)) total_fin_count
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 2 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 2 day), interval 16 hour) and pi.returned = 0, ds.pno, null)) forward_fin_count
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 2 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 2 day), interval 16 hour), ds.pno, null))/count(ds.pno) total_rate
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 2 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 2 day), interval 16 hour) and pi.returned = 0, ds.pno, null))/count(if(pi.returned = 0, ds.pno, null)) forward_rate
        from ph_bi.dc_should_delivery_today ds
        left join ph_staging.parcel_info pi on pi.pno = ds.pno and pi.created_at > date_sub(curdate(), interval 90 day)
        where
            ds.stat_date = date_sub(curdate(), interval 2 day)
        group by 1
    ) day2 on day2.store_id = t1.ss2_id
left join
    (
        select
            ds.store_id
            ,count(ds.pno) total_should_del
            ,count(if(pi.returned = 0, ds.pno, null)) forward_should_del
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 3 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 3 day), interval 16 hour), ds.pno, null)) total_fin_count
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 3 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 3 day), interval 16 hour) and pi.returned = 0, ds.pno, null)) forward_fin_count
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 3 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 3 day), interval 16 hour), ds.pno, null))/count(ds.pno) total_rate
            ,count(if(pi.state = 5 and pi.finished_at > date_sub(date_sub(curdate(), interval 3 day), interval 8 hour) and pi.finished_at < date_add(date_sub(curdate(), interval 3 day), interval 16 hour) and pi.returned = 0, ds.pno, null))/count(if(pi.returned = 0, ds.pno, null)) forward_rate
        from ph_bi.dc_should_delivery_today ds
        left join ph_staging.parcel_info pi on pi.pno = ds.pno and pi.created_at > date_sub(curdate(), interval 90 day)
        where
            ds.stat_date = date_sub(curdate(), interval 3 day)
        group by 1
    ) day3 on day3.store_id = t1.ss2_id
left join
    (
        select
            ds.store_id
            ,count(distinct ds.pno) backog_count
        from ph_bi.dc_should_delivery_today ds
        left join ph_staging.parcel_info pi on pi.pno = ds.pno and pi.created_at > date_sub(curdate(), interval 90 day)
        where
            ds.stat_date = curdate()
            and pi.state not in (5,7,8,9)
        group by 1
    ) bac on bac.store_id = t1.ss2_id
order by 2,7