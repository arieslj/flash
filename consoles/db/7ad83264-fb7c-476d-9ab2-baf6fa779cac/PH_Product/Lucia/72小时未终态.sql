with t as
    (
        select
            ps.pno
            ,ps.arrive_dst_store_id
            ,ps.arrive_dst_route_at
            ,pi.state_change_at
            ,if(pi.state in (5,7,8), convert_tz(pi.state_change_at, '+00:00', '+08:00'), now()) end_at
        from ph_bi.parcel_sub ps
        left join ph_staging.parcel_info pi on pi.pno = ps.pno
        where
            ps.arrive_dst_route_at > '2024-06-01'
            and ps.arrive_dst_route_at < '2024-07-01'
    )
select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 网点
    ,count(distinct if(timestampdiff(hour, t1.arrive_dst_route_at, t1.end_at) > 96, t1.pno, null)) 超96小时未终态包裹数
    ,count(distinct if(timestampdiff(hour, t1.arrive_dst_route_at, t1.end_at) > 120, t1.pno, null)) 超120小时未终态包裹数
    ,count(distinct if(timestampdiff(hour, t1.arrive_dst_route_at, t1.end_at) > 144, t1.pno, null)) 超144小时未终态包裹数
    ,count(distinct if(timestampdiff(hour, t1.arrive_dst_route_at, t1.end_at) > 168, t1.pno, null)) 超168小时未终态包裹数
from t t1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.arrive_dst_store_id and dp.stat_date = curdate()
left join
    (
        select
            distinct
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-05-30'
            and pr.route_action = 'REFUND_CONFIRM'
            and pr.routed_at > date_sub(t1.arrive_dst_route_at, interval 8 hour)
            and pr.routed_at < coalesce(t1.state_change_at, date_sub(now(), interval 8 hour))
    ) pr on pr.pno = t1.pno
left join
    (
        select
            distinct
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-05-30'
            and pr.route_action = 'DETAIN_WAREHOUSE'
            and pr.marker_category = 14
            and pr.routed_at > date_sub(t1.arrive_dst_route_at, interval 8 hour)
            and pr.routed_at < coalesce(t1.state_change_at, date_sub(now(), interval 8 hour))
    ) p2 on p2.pno = t1.pno
where
    pr.pno is null
    and p2.pno is null
group by 1,2,3


;


with t as
    (
        select
            am.merge_column
            ,am.id
            ,am.store_id
            ,ss.name
            ,am.created_at
            ,am.abnormal_time
        from ph_bi.abnormal_message am
        left join ph_staging.sys_store ss on ss.id = am.store_id
        where
            am.abnormal_time >= '2024-06-01'
            and am.abnormal_time < '2024-07-10'
            and am.punish_category = 85
          --  and am.merge_column = 'P121553V17FAJ'
    )
select
    distinct
    a.merge_column
    ,a.name
    ,a.abnormal_time
    ,a.created_at
    ,a.diff_hour
from
    (
        select
            t1.*
            ,t2.routed_time
            ,timestampdiff(hour, t2.routed_time, t1.created_at) diff_hour
        from t t1
        left join
            (
                 select
                    t1.*
                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') routed_time
                    ,row_number() over (partition by t1.merge_column, t1.store_id, t1.abnormal_time order by pr.routed_at ) rk
                from ph_staging.parcel_route pr
                join t t1 on t1.merge_column = pr.pno and t1.store_id = pr.store_id
                where
                    pr.routed_at > '2024-01-01'
                    and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
                    and pr.route_action in ('RECEIVED','REPLACE_PNO', 'RECEIVE_WAREHOUSE_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DIFFICULTY_HANDOVER', 'UNSEAL', 'SEAL', 'SEAL_NUMBER_CHANGE' )
            ) t2 on t1.merge_column = t2.merge_column and t1.store_id = t2.store_id and t1.abnormal_time = t2.abnormal_time and t2.rk=1
    ) a
where
    a.diff_hour < 120