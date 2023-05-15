with t1 as
(
    select
        a1.*
    from
        (
            select
                pi.pno
                ,pi.customary_pno
                ,pi.returned
                ,pi.cod_amount/100 cod_total
                ,pi.dst_store_id
                ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) chicun
            from fle_dwd.dwd_fle_parcel_info_di pi
            where
                pi.p_date >= '2022-10-28'
        ) a1
    join
        (
            select t.pno from  test.tmp_pno_info0511 t group by 1
        ) a2 on a2.pno = a1.pno
)
select
    t.pno
    ,b3.routed_at `到件入仓时间（目的地网点）`
    ,t1.customary_pno `原单号`
    ,t1.returned
    ,t1.chicun
    ,t1.cod_total
    ,ss.name `目的地网点`
from test.tmp_pno_info0511 t
left join
    (
        select
            b1.pno
            ,b1.routed_at
        from
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,min(pr.routed_at) routed_at
                from fle_dwd.dwd_rot_parcel_route_di pr
                where
                    pr.p_date >= '2022-10-28'
                    and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                group by 1,2
            ) b1
        join t1 on t1.pno = b1.pno and t1.dst_store_id = b1.store_id
    ) b3 on b3.pno = t.pno
left join  t1 on t1.pno = t.pno
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da  ss
        where
            ss.p_date = '2023-05-10'
    ) ss on ss.id = t1.dst_store_id

;





