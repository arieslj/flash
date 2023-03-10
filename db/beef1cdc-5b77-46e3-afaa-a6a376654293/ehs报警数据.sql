-- 正向
select
    t1.created_at `揽收时间`
    ,t1.pno
    ,ss.name `揽收网点`
    ,smr.name `揽收大区`
    ,smp.name  `揽收片区`
    ,t1.ticket_pickup_staff_info_id `揽收员工工号`
    ,si.name  `揽收员工`
    ,sa.id `始发hub_id`
    ,sa.name `始发hub`
    ,t2.store_id `末端网点id`
    ,t2.store_name `末端网点`
    ,t2.staff_info_id `派件员工id`
    ,t2.staff_name `派件员工`
    ,t2.last_hub_id `末端hubid`
    ,t2.last_hub_name `末端hub`
    ,t2.piece_name `末端片区`
    ,t2.region_nmae `末端大区`
    ,pho.routed_at `第一次打电话时间`
    ,sc.routed_at `第一次扫描派送时间`
from
    (
        select
            pi.created_at
            ,pi.pno
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
        from fle_dwd.dwd_fle_parcel_info_di pi
        join test.tmp_th_pno_0310 t on t.pno = pi.pno
        where pi.p_date >= '2022-06-01'
          and pi.p_date < '2022-12-01'
    ) t1
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(current_date(), 1)
    ) ss on ss.id = t1.ticket_pickup_store_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_piece_da smp
        where
            smp.p_date = date_sub(current_date(), 1)
    ) smp on smp.id = ss.manage_piece
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_region_da smr
        where
            smr.p_date = date_sub(current_date(), 1)
    ) smr on smr.id = ss.manage_region
left join
    (
        select
            *
        from fle_dim.dim_fle_staff_info_da si
        where
            si.p_date = date_sub(current_date(), 1)
    ) si on si.id = t1.ticket_pickup_staff_info_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da sa
        where
            sa.p_date = date_sub(current_date(), 1)
    ) sa on sa.id = if(ss.category in ('8','12'), ss.id, split_part(ss.ancestry,'/',1))
left join
    (
        select
            t.pno
            ,mark.staff_info_id
            ,si.name staff_name
            ,mark.store_id
            ,sa.name store_name
            ,smp.name piece_name
            ,smr.name region_nmae
            ,ssa.id last_hub_id
            ,ssa.name last_hub_name
        from test.tmp_th_pno_0310 t
        left join
            (
                select
                    mark.*
                from
                    (
                        select
                            pr.pno
                            ,pr.staff_info_id
                            ,pr.store_id
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
                        from fle_dwd.dwd_rot_parcel_route_di pr
                        join test.tmp_th_pno_0310 t on t.pno = pr.pno
                        where
                            pr.p_date >= '2022-06-01'
                            and pr.p_date < '2023-01-01'
                            and pr.route_action = 'DELIVERY_MARKER'
                    ) mark
                where
                    mark.rn = 1
            ) mark on mark.pno = t.pno
        left join
            (
                select
                    *
                from fle_dim.dim_fle_staff_info_da si
                where
                    si.p_date = date_sub(current_date(), 1)
            ) si on si.id = mark.staff_info_id
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_store_da sa
                where
                    sa.p_date = date_sub(current_date(), 1)
            ) sa on sa.id = mark.store_id
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_manage_piece_da smp
                where
                    smp.p_date = date_sub(current_date(), 1)
            ) smp on smp.id = sa.manage_piece
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_manage_region_da smr
                where
                    smr.p_date = date_sub(current_date(), 1)
            ) smr on smr.id = sa.manage_region
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_store_da sa
                where
                    sa.p_date = date_sub(current_date(), 1)
            ) ssa on ssa.id = if(sa.category in ('8','12'), sa.id, split_part(sa.ancestry,'/',1))
    ) t2 on t2.pno = t1.pno
left join
    (
        select
            pho.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
                from fle_dwd.dwd_rot_parcel_route_di pr
                join test.tmp_th_pno_0310 t on pr.pno = t.pno
                where
                    pr.p_date >= '2022-06-01'
                    and pr.p_date < '2023-01-01'
                    and pr.route_action = 'PHONE'
            ) pho
        where
            pho.rn = 1
    ) pho on pho.pno = t1.pno
left join
    (
        select
            sc.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
                from fle_dwd.dwd_rot_parcel_route_di pr
                join test.tmp_th_pno_0310 t on pr.pno = t.pno
                where
                    pr.p_date >= '2022-06-01'
                    and pr.p_date < '2023-01-01'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) sc
        where
            sc.rn = 1
    ) sc on sc.pno = t1.pno
;

-- 逆向

-- 正向
select
    t1.created_at `揽收时间`
    ,t1.pno
    ,ss.name `揽收网点`
    ,smr.name `揽收大区`
    ,smp.name  `揽收片区`
    ,t1.ticket_pickup_staff_info_id `揽收员工工号`
    ,si.name  `揽收员工`
    ,sa.id `始发hub_id`
    ,sa.name `始发hub`
    ,t2.store_id `末端网点id`
    ,t2.store_name `末端网点`
    ,t2.staff_info_id `派件员工id`
    ,t2.staff_name `派件员工`
    ,t2.last_hub_id `末端hubid`
    ,t2.last_hub_name `末端hub`
    ,t2.piece_name `末端片区`
    ,t2.region_nmae `末端大区`
    ,pho.routed_at `第一次打电话时间`
    ,sc.routed_at `第一次扫描派送时间`
from
    (
        select
            pi.created_at
            ,pi.pno
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
        from fle_dwd.dwd_fle_parcel_info_di pi
        join test.tmp_th_pno_0310 t on t.return_pno = pi.pno
        where pi.p_date >= '2022-06-01'
          and pi.p_date < '2023-02-01'
    ) t1
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(current_date(), 1)
    ) ss on ss.id = t1.ticket_pickup_store_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_piece_da smp
        where
            smp.p_date = date_sub(current_date(), 1)
    ) smp on smp.id = ss.manage_piece
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_manage_region_da smr
        where
            smr.p_date = date_sub(current_date(), 1)
    ) smr on smr.id = ss.manage_region
left join
    (
        select
            *
        from fle_dim.dim_fle_staff_info_da si
        where
            si.p_date = date_sub(current_date(), 1)
    ) si on si.id = t1.ticket_pickup_staff_info_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da sa
        where
            sa.p_date = date_sub(current_date(), 1)
    ) sa on sa.id = if(ss.category in ('8','12'), ss.id, split_part(ss.ancestry,'/',1))
left join
    (
        select
            t.pno
            ,mark.staff_info_id
            ,si.name staff_name
            ,mark.store_id
            ,sa.name store_name
            ,smp.name piece_name
            ,smr.name region_nmae
            ,ssa.id last_hub_id
            ,ssa.name last_hub_name
        from test.tmp_th_pno_0310 t
        left join
            (
                select
                    mark.*
                from
                    (
                        select
                            pr.pno
                            ,pr.staff_info_id
                            ,pr.store_id
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
                        from fle_dwd.dwd_rot_parcel_route_di pr
                        join test.tmp_th_pno_0310 t on t.return_pno = pr.pno
                        where
                            pr.p_date >= '2022-06-01'
                            and pr.p_date < '2023-01-01'
                            and pr.route_action = 'DELIVERY_MARKER'
                    ) mark
                where
                    mark.rn = 1
            ) mark on mark.pno = t.return_pno
        left join
            (
                select
                    *
                from fle_dim.dim_fle_staff_info_da si
                where
                    si.p_date = date_sub(current_date(), 1)
            ) si on si.id = mark.staff_info_id
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_store_da sa
                where
                    sa.p_date = date_sub(current_date(), 1)
            ) sa on sa.id = mark.store_id
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_manage_piece_da smp
                where
                    smp.p_date = date_sub(current_date(), 1)
            ) smp on smp.id = sa.manage_piece
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_manage_region_da smr
                where
                    smr.p_date = date_sub(current_date(), 1)
            ) smr on smr.id = sa.manage_region
        left join
            (
                select
                    *
                from fle_dim.dim_fle_sys_store_da sa
                where
                    sa.p_date = date_sub(current_date(), 1)
            ) ssa on ssa.id = if(sa.category in ('8','12'), sa.id, split_part(sa.ancestry,'/',1))
    ) t2 on t2.pno = t1.pno
left join
    (
        select
            pho.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
                from fle_dwd.dwd_rot_parcel_route_di pr
                join test.tmp_th_pno_0310 t on pr.pno = t.return_pno
                where
                    pr.p_date >= '2022-06-01'
                    and pr.p_date < '2023-01-01'
                    and pr.route_action = 'PHONE'
            ) pho
        where
            pho.rn = 1
    ) pho on pho.pno = t1.pno
left join
    (
        select
            sc.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
                from fle_dwd.dwd_rot_parcel_route_di pr
                join test.tmp_th_pno_0310 t on pr.pno = t.return_pno
                where
                    pr.p_date >= '2022-06-01'
                    and pr.p_date < '2023-01-01'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) sc
        where
            sc.rn = 1
    ) sc on sc.pno = t1.pno
