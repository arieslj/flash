with t as
    (
        select
            a.pno
            ,a.old_value
            ,a.new_value
            ,a.created_at
            ,coalesce(a.next_time, now()) next_created_at
        from
            (
                select
                    pcd.pno
                    ,pcd.old_value
                    ,pcd.new_value
                    ,pcd.created_at
                    ,lead(pcd.created_at, 1) over (partition by pcd.pno order by pcd.created_at) next_time
                from fle_staging.parcel_change_detail pcd
                join tmpale.tmp_th_pno_lj_0702 t on pcd.pno = t.pno
                where
                    pcd.created_at > '2024-04-01'
                    and pcd.field_name = 'dst_store_id'
            ) a
    )
select
    t1.pno
    ,pr.store_name 错分修改后目的地网点
    ,convert_tz(pr.first_valid_routed_at, '+00:00', '+07:00') 网点第一个有效路由时间
from t t1
left join
    (
        select
            pssn.pno
            ,pssn.store_name
            ,pssn.first_valid_routed_at
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno and t1.new_value = pssn.store_id
        where
            pssn.first_valid_routed_at > t1.created_at
            and pssn.first_valid_routed_at <= t1.next_created_at
    ) pr on pr.pno = t1.pno
-- left join fle_staging.sys_store ss on ss.id = t1.new_value
-- left join dwm.dwd_dim_dict ddd on ddd.element = t1.new_value and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'