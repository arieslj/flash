select
    a.dst_store_id 网点ID
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,a.third_sorting_code 三段码
    ,a.pno
    ,a.should_delevry_type
    ,a.staff_info_id
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 分拣时间
    ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at) 正向排序
    ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at desc ) 逆向排序
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.routed_at) rk
        from
            (
                select
                    ds.dst_store_id
                    ,dp.third_sorting_code
                    ,ds.pno
                    ,ds.should_delevry_type
                    ,pr.staff_info_id
                    ,pr.routed_at
                    ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                from dwm.dwd_ph_dc_should_be_delivery_d ds
                left join dwm.drds_ph_parcel_sorting_code_info  dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                join ph_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= '2023-08-23 16:00:00' and pr.routed_at < '2023-08-24 16:00:00'
                where
                    ds.p_date = '2023-08-24'
            ) a
        where
            a.rn = 1
    ) a
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = a.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    a.rk = 1
    and dt.store_name in ('JEN_SP','INT_SP','TAD_SP','VER_SP','MBT_SP','RIZ_SP','MSN_SP','NHC_SP','DMS_SP','CAG_SP')


;
select date_sub(curdate(), interval 14 day)
;


with t as
(
    select
        a.*
        ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at) rk1
        ,row_number() over (partition by a.dst_store_id, a.third_sorting_code order by a.routed_at desc ) rk2
    from
        (
            select
                a.*
                ,row_number() over (partition by a.pno order by a.routed_at) rk
            from
                (
                    select
                        ds.dst_store_id
                        ,dp.third_sorting_code
                        ,ds.pno
                        ,ds.should_delevry_type
                        ,pr.staff_info_id
                        ,pr.routed_at
                        ,rank() over (partition by ds.pno order by dp.created_at desc ) rn
                    from dwm.dwd_ph_dc_should_be_delivery_d ds
                    left join dwm.drds_ph_parcel_sorting_code_info dp on ds.pno = dp.pno and ds.dst_store_id = dp.dst_store_id
                    join ph_staging.parcel_route pr on pr.pno = dp.pno and pr.route_action = 'SORTING_SCAN' and pr.routed_at >= '2023-08-23 16:00:00' and pr.routed_at < '2023-08-24 16:00:00'
                    where
                        ds.p_date = '2023-08-24'
#                         and ds.should_delevry_type = '1派应派包裹'
                ) a
            where
                a.rn = 1
        ) a
    where
        a.rk = 1
)
select
    t1.dst_store_id 网点id
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,t1.third_sorting_code 三段码
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') 第一次分拣扫描时间
    ,convert_tz(t2.routed_at, '+00:00', '+08:00') 最后一次分拣扫描时间
#     ,count(distinct t3.pno) 该三段码第一次与最后一次分拣扫描时间之间扫描单量
#     ,count(distinct if(t3.third_sorting_code = t1.third_sorting_code, t3.pno, null))/count(distinct t3.pno) 本三段码扫描占比
    ,t3.pno
    ,convert_tz(t3.routed_at, '+00:00', '+08:00') 分拣时间

from
    (
        select
            t1.*
        from t t1
        where
            t1.rk1 = 1
    ) t1
left join
    (
        select
            t1.*
        from t t1
        where
            t1.rk2 = 1
    ) t2 on t2.dst_store_id = t1.dst_store_id and t2.third_sorting_code = t1.third_sorting_code
left join t t3 on t3.dst_store_id = t1.dst_store_id and t3.routed_at >= t1.routed_at and t3.routed_at <= t2.routed_at
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = t1.dst_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    t1.dst_store_id = 'PH61205504'
group by 1,2,3,4,5,6,7