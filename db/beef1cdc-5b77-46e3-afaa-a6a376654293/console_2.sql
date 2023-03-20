select
    a.pno
    ,case a.cod_enabled
        when '0' then '否'
        when '1' then '是'
    end `是否COD`
    ,case
        when bc.client_id is null and kp.id is null then '小C'
        when bc.client_id is null and kp.id is not null then '普通KA'
        when bc.client_id is not null  then bc.custom_name
    end `客户类型`
    ,b.routed_at `最后一次到件扫描时间`
    ,ss.name `最后一次到件扫描网点`
from
    (
        select
            pi.*
        from
            (
                select
                    pi.pno
                    ,pi.cod_enabled
                    ,pi.client_id
                from fle_dwd.dwd_fle_parcel_info_di pi
                where
                    pi.p_date >= '2022-10-01'
            ) pi
        join
            (
                select
                    *
                from test.tmp_th_pno_ciwei_0319
            ) t on t.pno = pi.pno
    ) a
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.routed_at
                        from fle_dwd.dwd_rot_parcel_route_di pr
                        where
                            pr.p_date >= '2022-10-01'
                            and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                    ) pr
                join
                    (
                        select
                            *
                        from test.tmp_th_pno_ciwei_0319
                    ) t on t.pno = pr.pno
            ) b
        where
            b.rn = 1
    )  b on b.pno = a.pno
left join
    (
        select
            *
        from fle_dim.dim_fle_ka_profile_da kp
        where
            kp.p_date = date_sub(current_date(), 1)
    ) kp on kp.id = a.client_id
left join
    (
        select
            *
        from fle_dim.dim_csv_big_client_conf_info bc
    ) bc on bc.client_id = a.client_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(current_date(), 1)
    ) ss on ss.id = b.store_id
;

select
    a.pno
    ,a.cod_am
from
    (
        select
            pi.pno
            ,pi.cod_amount/100 cod_am
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-01-01'
    ) a
join
    (
        select
            *
        from test.tmp_th_pno_zjq_0319 t
        group by 1
    ) b on a.pno = b.pno