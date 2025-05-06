with t as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from ph_staging.parcel_route pr
            where
                pr.route_action = 'DELIVERY_MARKER'
                and pr.marker_category = 1
                and pr.routed_at >= '2023-07-15 16:00:00'
                and pr.routed_at < '2023-07-16 16:00:00'
        ) a
    where
        a.rk = 1
)
, a1 as
(
    select
        t1.*
        ,pr2.extra_value
        ,pr2.id
        ,pr2.routed_at phone_time
        ,cast(json_extract(pr2.extra_value, '$.callDuration') as int) call_num -- 通话
        ,cast(json_extract(pr2.extra_value, '$.diaboloDuration') as int) diao_num -- 响铃
    from ph_staging.parcel_route pr2
    join t t1 on t1.pno = pr2.pno
    where
        pr2.routed_at >= '2023-07-15 16:00:00'
        and pr2.routed_at < '2023-07-16 16:00:00'
        and pr2.route_action = 'PHONE'
        and pr2.routed_at < t1.routed_at
)
select
    t1.pno
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,t1.staff_info_id 快递员
    ,hsi.hire_date 入职时间
    ,t1.尝试联系次数
    ,t2.diao_num 出现最多的响铃时长
    ,t1.最短响铃时长
    ,t1.最长的响铃时长
    ,t1.最大通话时长
    ,timestampdiff(second, fir.phone_time, las.phone_time)/3600 间隔时间_h
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') 标记时间
from
    (
        select
            a.pno
            ,a.staff_info_id
            ,a.store_id
            ,a.routed_at
            ,count(a.id) 尝试联系次数
            ,max(a.diao_num) 最长的响铃时长
            ,min(a.diao_num) 最短响铃时长
            ,max(a.call_num) 最大通话时长
        from a1 a
        group by 1,2,3,4
    ) t1
left join
    (
        select
            a4.*
        from
            (
                select
                    a3.*
                    ,row_number() over (partition by a3.pno order by a3.num desc ) rk
                from
                    (
                        select
                            a2.pno
                            ,a2.staff_info_id
                            ,a2.store_id
                            ,a2.routed_at
                            ,a2.diao_num
                            ,count(a2.id) num
                        from a1 a2
                        group by 1,2,3,4,5
                    ) a3
            ) a4
        where
            a4.rk = 1
    ) t2 on t2.pno = t1.pno
left join
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.phone_time ) rn
        from a1 a
    ) fir on fir.pno = t1.pno and fir.rn = 1
left join
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.phone_time desc ) rn
        from a1 a
    ) las on las.pno = t1.pno and las.rn = 1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = '2023-07-16'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id
;




select
    ss.name
    ,ds.pno
    ,if(f.pno is not null , '是', '否') 是否有提成
from ph_bi.dc_should_delivery_today ds
left join ph_staging.sys_store ss on ss.id = ds.store_id
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = ds.pno and f.stat_date = ds.stat_date
where
    ds.stat_date = '2023-07-15'
    and ss.name in
;



with t as
(
    select
        pi.pno
        ,pi.ticket_delivery_store_id
    from ph_bi.dc_should_delivery_today ds
    left join ph_staging.parcel_info pi on ds.pno = pi.pno
    left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
    left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = pi.pno and f.store_id = pi.ticket_delivery_store_id and f.type = 2
    where
        pi.state = 5
        and ds.stat_date = '2023-07-15'
        and ss.name in ('ILD_SP', 'CBS_SP', 'PGD_SP')
        and f.pno is null
        and pi.finished_at >= '2023-07-14 16:00:00'
        and pi.finished_at < '2023-07-15 16:00:00'
)
select
    t1.ticket_delivery_store_id
    ,ss2.name
    ,t1.pno
    ,if(aws.routed_at < '2023-07-13 16:00:00', '是', '否') 是否在0714之前到达
    ,if(lx.pno is not null , '是', '否') 是否有正确路由组合排序
from t t1
left join
    (
        select
            t1.ticket_delivery_store_id
            ,t1.pno
        from t t1
        # left join
        #     (
        #         select
        #             pr.pno
        #             ,pr.routed_at
        #         from ph_staging.parcel_route pr
        #         join t t1 on t1.pno = pr.pno
        #         where
        #             pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
        #             and pr.store_id in ('PH35500A00', 'PH32170200', 'PH45140300')
        #     ) aws on aws.pno = t1.pno
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'SORTING_SCAN'
            ) sc on sc.pno = t1.pno and sc.store_id = t1.ticket_delivery_store_id
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) dtc on dtc.pno = t1.pno and dtc.store_id = t1.ticket_delivery_store_id
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_CONFIRM'
            ) dc on dc.pno = t1.pno and dc.store_id = t1.ticket_delivery_store_id
        where
            sc.routed_at < dtc.routed_at
            and dtc.routed_at < dc.routed_at
        group by 1,2
    ) lx on lx.pno = t1.pno and lx.ticket_delivery_store_id = t1.ticket_delivery_store_id
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.routed_at
            ,row_number() over (partition by pr.store_id, pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    ) aws on aws.pno = t1.pno and aws.store_id = t1.ticket_delivery_store_id and aws.rk = 1
left join ph_staging.sys_store ss2 on ss2.id = t1.ticket_delivery_store_id


;


select
    ss.name
    ,count(ds.pno)
from ph_bi.dc_should_delivery_today ds
left join ph_staging.parcel_info pi on ds.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = pi.pno and f.store_id = pi.ticket_delivery_store_id and f.type = 2
where
    pi.state = 5
    and ds.stat_date = '2023-07-15'
    and ss.name in ('ILD_SP', 'CBS_SP', 'PGD_SP')
#     and f.pno is null
#     and pi.finished_at >= '2023-07-14 16:00:00'
#     and pi.finished_at < '2023-07-15 16:00:00'
group by 1