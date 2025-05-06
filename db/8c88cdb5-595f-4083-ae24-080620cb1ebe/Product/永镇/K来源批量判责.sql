select
    *
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.diff_time desc) rk
        from
            (
                select
                    plt.id
                    ,plt.pno
                    ,pssn.store_id
                    ,pssn.store_name
                    ,pssn.valid_store_order
                    ,timestampdiff(minute, coalesce(pssn.van_arrived_at, pssn.first_valid_routed_at), coalesce(pssn.van_left_at, pssn.last_valid_routed_at)) diff_time
                from bi_pro.parcel_lose_task plt
                left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = plt.pno and pssn.valid_store_order is not null and pssn.created_at < plt.created_at
                where
                    plt.source = 11
                    and plt.state < 5
                 --   and plt.pno = 'TH01174VQ72X8B'
            ) a
    ) a1
where
    a1.rk = 1
    or a1.rk is null

;



select
    a2.id
    ,a2.pno
    ,a2.store_name 网点
    ,a2.client_id
    ,bc.client_name
    ,if(pi.returned = 1, '退件', '正向') 包裹流向
    ,if(a2.rk = 1, timestampdiff(hour, a2.begin_time, a2.min_created_at)/24, timestampdiff(hour, a2.begin_time, a2.end_time)/24) 停留时长
from
    (
        select
            a1.id
            ,a1.pno
            ,a1.min_created_at
            ,pssn.store_name
            ,a1.client_id
            ,coalesce(pssn.van_arrived_at, pssn.first_valid_routed_at) begin_time
            ,coalesce(pssn.van_left_at, pssn.last_valid_routed_at) end_time
            ,row_number() over (partition by a1.id order by pssn.valid_store_order desc ) rk
        from
            (
                select
                    plt.pno
                    ,plt.id
                    ,plt.client_id
                    ,min(plt.created_at) min_created_at
                from bi_pro.parcel_lose_task plt
                where
                    plt.source = 11
                    and plt.state < 5
                group by 1,2,3
            ) a1
        left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = a1.pno and pssn.valid_store_order is not null and pssn.first_valid_routed_at < a1.min_created_at
    ) a2
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a2.client_id
left join fle_staging.parcel_info pi on pi.pno = a2.pno

union all

select
    a2.id
    ,a2.plt_pno pno
    ,a2.store_name 网点
    ,a2.client_id
    ,bc.client_name
    ,if(pi.returned = 1, '退件', '正向') 包裹流向
    ,timestampdiff(hour, a2.begin_time, a2.end_time)/24 停留时长
from
    (
        select
            a1.id
            ,a1.pno
            ,a1.plt_pno
            ,a1.min_created_at
            ,pssn.store_name
            ,a1.client_id
            ,coalesce(pssn.van_arrived_at, pssn.first_valid_routed_at) begin_time
            ,coalesce(pssn.van_left_at, pssn.last_valid_routed_at) end_time
            ,row_number() over (partition by a1.id order by pssn.valid_store_order desc ) rk
        from
            (
                select
                    pi.pno
                    ,plt.pno plt_pno
                    ,plt.id
                    ,plt.client_id
                    ,min(plt.created_at) min_created_at
                from bi_pro.parcel_lose_task plt
                join fle_staging.parcel_info pi on pi.returned_pno = plt.pno
                where
                    plt.source = 11
                    and plt.state < 5
                group by 1,2,3
            ) a1
        left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = a1.pno and pssn.valid_store_order is not null and pssn.first_valid_routed_at < a1.min_created_at
    ) a2
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a2.client_id
left join fle_staging.parcel_info pi on pi.pno = a2.pno








; -- 99妥投K来源
select
    plt.id
    ,plt.pno
from rot_pro.parcel_route pr
join bi_pro.parcel_lose_task plt on plt.pno = pr.pno and plt.source = 11 and plt.state in (1,2,3,4)
where
    pr.route_action = 'DELIVERY_CONFIRM'
    and pr.store_id = 'TH02030307'
group by 1,2

;


