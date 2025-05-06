with t as
    (
        select
            a.*
        from
            (
                select
                    t.pno
                    ,t.final_date
                    ,pi.returned
                    ,t.client_name
                    ,pi.client_id
                    ,case
                        when pi.state in (1,2,3,4,6) then pd.last_valid_store_id
                        when pi.state = 5 then pi.ticket_delivery_store_id
                        when pi.state = 8 and pi.dst_store_id = 'PH19040F05' then pcd.old_value
                        else pi.dst_store_id
                    end end_store_id
                    ,pi.state
                    ,di.store_id
                    ,di.created_at
                    ,row_number() over (partition by t.pno order by di.created_at ) rk
                from tmpale.tmp_ph_pno_lj_0717 t
                left join ph_staging.parcel_info pi on pi.pno = t.pno
                left join ph_bi.parcel_detail pd on pd.pno = t.pno
                left join ph_staging.parcel_change_detail pcd on pcd.pno = t.pno and pcd.field_name = 'dst_store_id' and pcd.new_value = 'PH19040F05'
                join ph_staging.diff_info di on di.pno = t.pno
                where
                    pi.created_at > '2024-03-01'
                 --  and pi.pno = 'PT6127AN7K85Z'
                    and di.diff_marker_category = 31
            ) a
        where
            a.rk = 1
    )
, las as
    (
        select
            a.*
        from
            (
                select
                    t2.pno
                    ,pssn.store_id
                    ,t2.created_at
                    ,pssn.first_valid_routed_at
                    ,row_number() over (partition by t2.pno order by pssn.first_valid_routed_at desc) rk
                from dw_dmd.parcel_store_stage_new pssn
                join t t2 on t2.pno = pssn.pno and pssn.store_id = t2.end_store_id
                where
                    pssn.created_at > '2024-03-01'
            ) a
        where
            a.rk = 1
    )
select
    t1.pno
    ,t1.final_date 回调终态日期
    ,t1.client_id
    ,t1.client_name 客户名称
    ,if(t1.returned = 1, 'y', 'n') 是否逆向
    ,dp.region_name 第一次操作错分网点大区
    ,dp.piece_name 第一次操作错分网点片区
    ,dp.store_id 第一次操作错分网点ID
    ,dp.store_name 第一次操作错分网点
    ,p1.store_name HUB1_ID
    ,p1.store_name HUB1
    ,p2.store_id HUB2_ID
    ,p2.store_name HUB2
    ,dp2.region_name 最后网点大区
    ,dp2.piece_name 最后网点片区
    ,dp2.store_id 最后网点ID
    ,dp2.store_name 最后网点
    ,if(t1.state = 5, 'y', 'n') 是否妥投
from t t1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = t1.end_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            pssn.pno
            ,pssn.store_id
            ,pssn.store_name
            ,row_number() over (partition by pssn.pno order by pssn.first_valid_routed_at) rk
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on pssn.pno = t1.pno
        where
            pssn.first_valid_routed_at > t1.created_at
            and pssn.store_category in (8,12)
    ) p1 on p1.pno = t1.pno and p1.rk = 1
left join
    (
        select
            pssn.pno
            ,pssn.store_id
            ,pssn.store_name
            ,row_number() over (partition by pssn.pno order by pssn.first_valid_routed_at desc) rk
        from dw_dmd.parcel_store_stage_new pssn
        join las la on la.pno = pssn.pno
        where
            pssn.created_at > '2024-03-01'
            and pssn.first_valid_routed_at < la.first_valid_routed_at
            and pssn.store_category in (8,12)
            and pssn.created_at > la.created_at
    ) p2 on p2.pno = t1.pno and p2.rk = 1





;

select
    count(distinct t.pno)
    ,min(di.created_at)
from tmpale.tmp_ph_pno_lj_0717 t
join ph_staging.diff_info di on di.pno = t.pno and diff_marker_category = 31