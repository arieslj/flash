with t as
(
    select
        pss2.pno
        ,pss2.store_name
        ,pss2.store_category
        ,pss2.store_order
        ,pss2.store_id
        ,pss2.van_arrived_at
        ,pss2.arrived_at
    from dw_dmd.parcel_store_stage_20230105 pss2
    join tmpale.tmp_th_0310_forward t on pss2.pno = t.pno

    union all

    select
        pss.pno
        ,pss.store_name
        ,pss.store_category
        ,pss.store_order
        ,pss.store_id
        ,pss.van_arrived_at
        ,pss.arrived_at
    from dw_dmd.parcel_store_stage_new pss
    join tmpale.tmp_th_0310_forward t on pss.pno = t.pno
)
select
#     count(*)
    t1.揽收时间
    ,t1.揽收网点
    ,t1.揽收大区
    ,t1.揽收片区
    ,t1.揽收员工工号
    ,t1.揽收员工
    ,t1.pno
    ,t2.store_name 末端网点
    ,t2.region_name 末端大区
    ,t2.piece_name 末端片区
    ,t3.store_name 始发hub
    ,t3.van_arrived_at 到达始发hub时间
    ,t4.store_name 末端hub
    ,t4.van_arrived_at 到达末端hub时间
    ,t2.van_arrived_at 到达时间
    ,t2.arrived_at 到件入仓时间
    ,t1.派件员工 派件员工姓名
    ,t1.派件员工id
    ,t1.第一次扫描派送时间
    ,t1.第一次打电话时间
from
    (
        select
            distinct
            t.*
        from tmpale.tmp_th_0310_forward t
    ) t1
left join
    ( -- 末端网点
        select
            t1.*
        from
            (
                select
                    t.*
                    ,dt.piece_name
                    ,dt.region_name
                    ,row_number() over (partition by t.pno order by t.store_order desc ) rk
                from t
                left join dwm.dim_th_sys_store_rd dt on dt.store_id = t.store_id and dt.stat_date = date_sub(curdate(),interval  1 day )
            ) t1
        where
            t1.rk = 1
    ) t2 on t2.pno = t1.pno
left join
    ( -- 始发hub
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order ) rk
                from t
                where
                    t.store_category in (8,12)
            ) t1
        where
            t1.rk = 1
    ) t3 on t3.pno = t1.pno
left join
    ( -- 末端hub
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order desc) rk
                from t
                where
                    t.store_category in (8,12)
            ) t1
        where
            t1.rk = 1
    ) t4 on t4.pno = t1.pno and t4.store_id != t3.store_id
;

with t as
(
    select
        pss2.pno
        ,pss2.store_name
        ,pss2.store_category
        ,pss2.store_order
        ,pss2.store_id
        ,pss2.van_arrived_at
        ,pss2.arrived_at
    from dw_dmd.parcel_store_stage_20230105 pss2
    join tmpale.tmp_th_0310_reverse  t on pss2.pno = t.pno

    union all

    select
        pss.pno
        ,pss.store_name
        ,pss.store_category
        ,pss.store_order
        ,pss.store_id
        ,pss.van_arrived_at
        ,pss.arrived_at
    from dw_dmd.parcel_store_stage_new pss
    join tmpale.tmp_th_0310_reverse t on pss.pno = t.pno
)
select
    t1.揽收网点
    ,t1.揽收大区
    ,t1.揽收片区
    ,t1.揽收员工工号
    ,t1.揽收员工
    ,t1.pno
    ,t1.末端网点
    ,t1.末端大区
    ,t1.末端片区
    ,t3.store_name 始发hub
    ,t3.van_arrived_at 到达始发hub时间
    ,t4.store_name 末端hub
    ,t4.van_arrived_at 到达末端hub时间
    ,t2.van_arrived_at 到达时间
    ,t2.arrived_at 到件入仓时间
from
    (
        select
            distinct
            t.*
        from tmpale.tmp_th_0310_reverse t
    ) t1
left join
    ( -- 末端网点
        select
            t.pno
            ,t.store_id
            ,min(t.van_arrived_at) van_arrived_at
            ,min(t.arrived_at) arrived_at
        from t
        join tmpale.tmp_th_0310_reverse tt on tt.末端网点id = t.store_id
        group by 1,2
    ) t2 on t2.pno = t1.pno
left join
    ( -- 始发hub
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order ) rk
                from t
                where
                    t.store_category in (8,12)
            ) t1
        where
            t1.rk = 1
    ) t3 on t3.pno = t1.pno
left join
    ( -- 末端hub
        select
            t1.*
        from
            (
                select
                    t.*
                    ,row_number() over (partition by t.pno order by t.store_order desc) rk
                from t
                where
                    t.store_category in (8,12)
            ) t1
        where
            t1.rk = 1
    ) t4 on t4.pno = t1.pno and t4.store_id != t3.store_id
;
select
    t1.*
    ,t2.*
from tmpale.tmp_th_0310_t1 t1
left join
    (
        select
            distinct
            t.*
        from tmpale.tmp_th_pno_0310 t
    ) t on t1.pno = t.pno
left join tmpale.tmp_th_0310_t2 t2 on t2.pno = t.return_pno
;

-- 转单
select
    *
from
    (
        select
            t.return_pno
            ,tdt.dst_staff_info_id
            ,row_number() over (partition by t.return_pno order by tdt.created_at desc) rn
        from fle_staging.ticket_delivery_transfer tdt
        join tmpale.tmp_th_delivery_0310 t on t.delivery_id = tdt.src_pickup_id
    ) t
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = t.dst_staff_info_id
where
    t.rn = 1
;
