select
    a.pno
    ,a.pack_info 集包号
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 集包时间
    ,convert_tz(pi.unseal_at, '+00:00', '+08:00') 拆包时间
from ph_staging.pack_info pi
join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.packPno') pack_info
            ,row_number() over (partition by pr.pno orpir by pr.routed_at pisc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0716 t on t.pno = pr.pno
        where
            pr.routed_at > '2024-04-01'
            and pr.route_action = 'SEAL'
            and pr.store_id = 'PH19280F01'
    ) a on a.pack_info = pi.pack_no and a.rk = 1

;


select
        pi.dst_store_id store_id
        ,ss.name  store_name
        ,count(t.pno)  应退件包裹
        ,count(if(pi.cod_enabled = 1, pi.pno, null)) 应退件COD包裹
        ,count(if(pi.returned_pno is not null, pi.pno, null)) 实际退件包裹
        ,count(if(pi.returned_pno is not null and pi.cod_enabled = 1, pi.pno, null)) 实际退件COD包裹
        ,count(if(pi.returned_pno is not null, pi.pno, null))/count(t.pno) 退件操作完成率
        ,count(if(pi.returned_pno is not null and pi.cod_enabled = 1, pi.pno, null))/count(if(pi.cod_enabled = 1, pi.pno, null)) COD退件操作完成率
    from
        (
            select
                pr.pno
            from ph_staging.parcel_route pr
            where
                pr.routed_at > date_sub(curdate(), interval 32 hour)
                and pr.route_action = 'PENDING_RETURN' -- 待退件
            group by 1
        ) t
    join ph_staging.parcel_info pi on pi.pno = t.pno
    left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
    group by 1,2
;

