select
    pi.pno
    ,plt.min_created_at
    ,pr.store_name
    ,if(pr.remark is not null, 1, 0) evidence_or_not
    ,convert_tz(pr.routed_at, '+00:00', '+07:00')  evidence_time
    ,pr.remark
    ,se.store_name as seal_store_name
    ,pr2.store_name as store_name_2
    ,if(pr2.remark is not null, 1, 0) evidence_or_not_2
    ,convert_tz(pr2.routed_at, '+00:00', '+07:00')  evidence_time_2
    ,pr2.remark remark_2
from
    (
        select
            pi.pno
        from fle_staging.parcel_info pi
        where
            pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
            and pi.created_at > date_sub(curdate(), interval 3 month)
    ) pi
left join
    (
        select
            plt.pno
            ,min(plt.created_at) min_created_at
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at > date_sub(curdate(), interval 3 month)
            and plt.source = 1
            and plt.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
        group by 1
    ) plt on plt.pno = pi.pno
left join
    (
        select
            sw.pno
            ,sw.store_name
            ,mr.routed_at
            ,mr.remark
        from
            (
                select
                    sw.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                        from rot_pro.parcel_route pr
                        where
                            pr.routed_at > date_sub(curdate(), interval 3 month)
                            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
                            and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
                    ) sw
                where
                    sw.rk = 1
            ) sw
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.remark
                from rot_pro.parcel_route pr
                where
                    pr.routed_at > date_sub(curdate(), interval 3 month)
                    and pr.route_action in ('MANUAL_REMARK', 'CREATE_WORK_ORDER')
                    and pr.remark regexp 'http'
                    and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
            ) mr on mr.pno = sw.pno and mr.store_id = sw.store_id
    ) pr on pr.pno = pi.pno
left join
    (
        select
            sw.*
        from
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from rot_pro.parcel_route pr
                where
                    pr.routed_at > date_sub(curdate(), interval 3 month)
                    and pr.route_action = 'SEAL'
                    and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
            ) sw
        where
            sw.rk = 1
    ) se on se.pno = pi.pno
left join
    (
        select
            sw.pno
            ,sw.store_name
            ,mr.routed_at
            ,mr.remark
        from
            (
                select
                    sw.*
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.store_name
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                        from rot_pro.parcel_route pr
                        where
                            pr.routed_at > date_sub(curdate(), interval 3 month)
                            and pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN'
                            and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
                    ) sw
                where
                    sw.rk = 1
            ) sw
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.remark
                from rot_pro.parcel_route pr
                where
                    pr.routed_at > date_sub(curdate(), interval 3 month)
                    and pr.route_action in ('MANUAL_REMARK', 'CREATE_WORK_ORDER')
                    and pr.remark regexp 'http'
                    and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
            ) mr on mr.pno = sw.pno and mr.store_id = sw.store_id
    ) pr2 on pr2.pno = pi.pno

