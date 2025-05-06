

with t as
    (
        select
            distinct
            di.pno
            ,pi.dst_store_id
            ,pi.ticket_delivery_store_id
            ,pi.finished_at
        from ph_staging.diff_info di
        join ph_staging.parcel_info pi on pi.pno = di.pno
        where
            di.created_at > '2024-06-17 17:00:00'
            and di.diff_marker_category = 31
    )
select
    count(distinct a1.pno) 错分总量
    ,count(distinct if(pssn.pno is not null, a1.pno, null)) 经过HUB量
    ,count(distinct if(pssn.pno is not null, a1.pno, null)) / count(distinct a1.pno) 占比
from
    (
        select
            distinct
            t1.pno
            ,t1.finished_at
            ,dif.created_at
        from t t1
        left join
            (
                select
                    di.store_id
                    ,di.pno
                    ,di.staff_info_id
                    ,di.created_at
                    ,row_number() over (partition by di.pno order by di.created_at ) as rnf
                from ph_staging.diff_info di
                join t t1 on t1.pno = di.pno
                where
                    di.created_at > date_sub(curdate(), interval 2 month)
                    and di.diff_marker_category = 31
            ) dif on t1.pno = dif.pno and dif.rnf = 1
        left join
            (
                select
                    a.*
                    ,if(a.old_value is not null, a.old_value, a.new_value) as ex_store
                from
                    (
                        select
                            pcd.pno
                            ,pcd.old_value
                            ,pcd.new_value
                            ,pcd.created_at
                            ,row_number() over (partition by pcd.pno order by pcd.created_at) rk
                        from ph_staging.parcel_change_detail pcd
                        join t t1 on t1.pno = pcd.pno
                        where
                            pcd.created_at > date_sub(curdate(), interval 2 month)
                            and pcd.field_name = 'dst_store_id'
                    ) a
                where
                    a.rk = 1
            ) ex on t1.pno = ex.pno
        where
            dif.store_id = t1.ticket_delivery_store_id
            or if(ex.ex_store is not null ,ex.ex_store ,t1.dst_store_id)= t1.ticket_delivery_store_id
    ) a1
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = a1.pno and pssn.valid_store_order is not null and pssn.created_at > a1.created_at and pssn.created_at <= a1.finished_at and pssn.store_category in (8,12)
;






with t as
    (
        select
            distinct
            di.pno
            ,pi.dst_store_id
            ,pi.ticket_delivery_store_id
            ,pi.finished_at
        from ph_staging.diff_info di
        join ph_staging.parcel_info pi on pi.pno = di.pno
        where
            di.created_at > '2024-06-17 17:00:00'
            and di.diff_marker_category = 31
    )
select
   a1.pno
    ,group_concat(distinct pssn.store_name) 经过的HUB
from
    (
        select
            distinct
            t1.pno
            ,t1.finished_at
            ,dif.created_at
        from t t1
        left join
            (
                select
                    di.store_id
                    ,di.pno
                    ,di.staff_info_id
                    ,di.created_at
                    ,row_number() over (partition by di.pno order by di.created_at ) as rnf
                from ph_staging.diff_info di
                join t t1 on t1.pno = di.pno
                where
                    di.created_at > date_sub(curdate(), interval 2 month)
                    and di.diff_marker_category = 31
            ) dif on t1.pno = dif.pno and dif.rnf = 1
        left join
            (
                select
                    a.*
                    ,if(a.old_value is not null, a.old_value, a.new_value) as ex_store
                from
                    (
                        select
                            pcd.pno
                            ,pcd.old_value
                            ,pcd.new_value
                            ,pcd.created_at
                            ,row_number() over (partition by pcd.pno order by pcd.created_at) rk
                        from ph_staging.parcel_change_detail pcd
                        join t t1 on t1.pno = pcd.pno
                        where
                            pcd.created_at > date_sub(curdate(), interval 2 month)
                            and pcd.field_name = 'dst_store_id'
                    ) a
                where
                    a.rk = 1
            ) ex on t1.pno = ex.pno
        where
            dif.store_id != t1.ticket_delivery_store_id
            and  if(ex.ex_store is not null ,ex.ex_store ,t1.dst_store_id) != t1.ticket_delivery_store_id
    ) a1
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = a1.pno and pssn.valid_store_order is not null and pssn.first_valid_routed_at > a1.created_at and pssn.first_valid_routed_at <= a1.finished_at and pssn.store_category in (8,12)
group by 1
;