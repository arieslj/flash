select
    a1.client_id 客户ID
    ,cg.name 负责部门
    ,a1.pi_ct 发件量
    ,a1.delivered_ct 妥投件量
    ,a2.pno_cnt 多次留仓包裹数量
    ,a3.CN_element 问题件类型
    ,a3.diff_cnt 问题件包裹数量
from
    (
        select
            pi.client_id
            ,count(distinct pi.pno) pi_ct
            ,count(distinct if(pi.state = 5, pi.pno, null)) delivered_ct
        from fle_staging.parcel_info pi
       -- left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
        where
            pi.created_at > '2024-07-31 17:00:00'
                    and pi.created_at < '2024-09-10 17:00:00'
            and pi.returned = 0
            and pi.client_id in ('CT3945','BG2222','AA0636','CR9789','CG1426','CAV9104','CH5857','CBC9325','CAZ6355','CJ2579','CAA3709','CS5555','CAY7719','CAK3170','CAC5925','CT3240','CAZ2605','CAN2192','AA0661','CBD1351')
        group by 1
    ) a1
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = a1.client_id and cgkr.deleted = 0
left join fle_staging.customer_group cg on cg.id = cgkr.customer_group_id
left join
    (
        select
            a2.client_id
            ,count(distinct a2.pno) pno_cnt
        from
            (
                select
                    pi.client_id
                    ,pi.pno
                    ,count(distinct date (convert_tz(ppd.created_at, '+00:00', '+07:00'))) det_days
                from fle_staging.parcel_info pi
             --   left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
                join fle_staging.parcel_problem_detail ppd on ppd.pno = pi.pno and ppd.parcel_problem_type_category = 2
                where
                    pi.created_at > '2024-07-31 17:00:00'
                    and pi.created_at < '2024-09-10 17:00:00'
                 --   and bc.client_id is null
                    and pi.returned = 0
                    and pi.client_id in ('CT3945','BG2222','AA0636','CR9789','CG1426','CAV9104','CH5857','CBC9325','CAZ6355','CJ2579','CAA3709','CS5555','CAY7719','CAK3170','CAC5925','CT3240','CAZ2605','CAN2192','AA0661','CBD1351')
                group by 1,2
            ) a2
        where
            a2.det_days >= 3
        group by 1
    )  a2 on a2.client_id = a1.client_id
left join
    (
        select
            pi.client_id
            ,ddd.CN_element
            ,count(distinct pi.pno) diff_cnt
        from fle_staging.parcel_info pi
    --    left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
        join fle_staging.diff_info di on di.pno = pi.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            pi.created_at > '2024-07-31 17:00:00'
            and pi.created_at < '2024-09-10 17:00:00'
            and pi.client_id in ('CT3945','BG2222','AA0636','CR9789','CG1426','CAV9104','CH5857','CBC9325','CAZ6355','CJ2579','CAA3709','CS5555','CAY7719','CAK3170','CAC5925','CT3240','CAZ2605','CAN2192','AA0661','CBD1351')
          --  and bc.client_id is null
            and pi.returned = 0
            and di.diff_marker_category in (26,23,31,29,19)
        group by 1,2
    ) a3 on a3.client_id = a1.client_id