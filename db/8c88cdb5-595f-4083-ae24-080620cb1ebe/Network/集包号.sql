select
    t.*
    ,s1.name 集包网点
    ,s2.name 应拆包网点
from rot_pro.parcel_route pr
join tmpale.tmp_th_pack_pno_lj_0701 t on t.pno = pr.pno and json_extract(pr.extra_value, '$.packPno') = t.pack_pno
left join fle_staging.pack_info pi on pi.pack_no = t.pack_pno
left join fle_staging.sys_store s1 on s1.id = pi.seal_store_id
left join fle_staging.sys_store s2 on s2.id = pi.es_unseal_store_id
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'


;


select
    t.pno
    ,pi.pack_no
    ,if(pi.exhibition_weight < 3000 and pi.exhibition_length + pi.exhibition_width + pi.exhibition_height < 55 and pi.exhibition_length < 30 and pi.exhibition_width < 30 and pi.exhibition_height < 30, '是', '否') 是否应集包
    ,ss3.name 集包网点
    ,ss.name 拆包网点
    ,ss2.name 应拆包网点
from tmpale.tmp_th_pno_lj_0701 t
left join fle_staging.parcel_info pi on t.pno = pi.pno
left join
    (
        select
            a.*
        from
            (
                select
                    t.pno
                    ,pr.routed_at
                    ,pr.extra_value
                    ,row_number() over (partition by t.pno order by pr.routed_at desc) rk
                from tmpale.tmp_th_pno_lj_0701 t
                left join fle_staging.parcel_info pi on t.pno = pi.pno
                left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                left join rot_pro.parcel_route pr on t.pno = pr.pno and pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'  and pr.routed_at > '2024-05-01'
                where
                    ss.category = 6
            ) a
        where
            a.rk = 1
    ) a1 on a1.pno = t.pno
left join fle_staging.pack_info pi on pi.pack_no = json_extract(a1.extra_value, '$.packPno')
left join fle_staging.sys_store ss on ss.id = pi.unseal_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.es_unseal_store_id
left join fle_staging.sys_store ss3 on ss3.id = pi.seal_store_id

