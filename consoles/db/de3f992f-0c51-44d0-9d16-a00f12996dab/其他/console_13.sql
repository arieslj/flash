with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,dp.store_category
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,ds.vehicle_time
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-16 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-16 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-16 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-16 09:00:00' then 2
        end delivery_fre
    from bi_pro.dc_should_delivery_today ds
    left join dwm.dim_th_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-16'
        and if(ds.original_store_id is null , 1 = 1, ds.original_store_id != ds.store_id)
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+07:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from rot_pro.parcel_route pr
            join t t1 on t1.pno = pr.pno and pr.store_id = t1.store_id
            where
                pr.route_action = 'SORTING_SCAN'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id 网点ID
    ,case t1.store_category
      when 1 then 'SP'
      when 2 then 'DC'
      when 4 then 'SHOP'
      when 5 then 'SHOP'
      when 6 then 'FH'
      when 7 then 'SHOP'
      when 8 then 'Hub'
      when 9 then 'Onsite'
      when 10 then 'BDC'
      when 11 then 'fulfillment'
      when 12 then 'B-HUB'
      when 13 then 'CDC'
      when 14 then 'PDC'
    end 网点类型
    ,if(fs.store_id is not null , '是', '否') 是否提成考核
    ,case freq.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总量
    ,count(if(f.pno is not null and s2.rou_time is not null, t1.pno, null)) 总有效分拣扫描数
    ,count(if(s2.rou_time is not null , t1.pno, null))/count(t1.pno) 总分拣扫描率
    ,count(if(f.pno is not null and s2.rou_time is not null, t1.pno, null))/count(t1.pno) 总有效分拣扫描率
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,ve1.max_veh_time 一派最晚到港时间
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and f.pno is not null and s2.rou_time is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派有效分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-16 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-16 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-16 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-16 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-16 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,ve2.max_veh_time 二派最晚到港时间
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.rou_time is not null, t1.pno, null )) 二派有效分拣数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.rou_time is not null, t1.pno, null))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派有效分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join bi_center.finance_keeper_month_parcel_v3_emr f on f.pno = t1.pno and f.store_id = t1.store_id and f.stat_date = '2023-07-16' and f.type = 2
left join nl_production.finance_sort_scan_list fs on fs.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.store_delivery_frequency) store_delivery_frequency
        from t t1
        group by 1
    ) freq on freq.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 1
        group by 1
    ) ve1 on ve1.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 2
        group by 1
    ) ve2 on ve2.store_id = t1.store_id
group by 1,2,3,4