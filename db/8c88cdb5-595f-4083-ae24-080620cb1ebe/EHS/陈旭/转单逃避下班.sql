select
    a3.pno 运单号
    ,a3.store_name 操作网点
    ,a3.pr_date 操作日期
    ,a3.last_store 最后有效路由网点
    ,ddd.CN_element 最后有效路由
    ,convert_tz(a3.last_valid_routed_at, '+00:00', '+07:00') 最后有效路由时间
    ,a3.staff_info_id 转单员工
    ,case a3.returned
        when 1 then '退件'
        when 0 then '正向'
    end 包裹流向
    ,a3.cod COD金额
from
    (
        select
            a2.*
            ,oi.cod_amount/100 cod
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,pssn.store_name last_store
            ,row_number() over (partition by a2.pno order by pssn.last_valid_routed_at desc) rk
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            a.pno
                            ,a.store_name
                            ,a.staff_info_id
                            ,a.routed_at
                            ,a.pr_date
                            ,a.customary_pno
                            ,a.returned
                        from
                            (
                                select
                                    pi.pno
                                    ,pr.routed_at
                                    ,pr.staff_info_id
                                    ,pr.store_name
                                    ,pi.returned
                                    ,pi.customary_pno
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
                                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+07:00')) order by pr.routed_at desc) rk
                                from fle_staging.parcel_info pi
                                join rot_pro.parcel_route pr on pr.pno = pi.pno
                                where
                                    pi.state in (1,2,3,4,6)
                                    and pi.created_at > date_sub(curdate(), interval 1 month)
                                    and pr.routed_at < date_sub(curdate(), interval 7 hour)
                                    and pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval 7 hour)
                                    and pr.route_action = 'DELIVERY_TRANSFER'
                            ) a
                        where
                            a.rk = 1
                    ) a1
                left join
                    (
                        select
                            date (convert_tz(ppd.created_at, '+00:00', '+07:00')) ppd_date
                            ,ppd.pno
                            ,count(ppd.id) ppd_cnt
                        from fle_staging.parcel_problem_detail ppd
                        where
                            ppd.created_at > date_sub(curdate(), interval 8 day)
                        group by 1,2
                    ) ppd on ppd.pno = a1.pno and ppd.ppd_date = a1.pr_date
                where
                    ppd.pno is null
            ) a2
        left join fle_staging.order_info oi on oi.pno = coalesce(a2.customary_pno, a2.pno) and oi.created_at > date_sub(curdate(), interval 1 month)
        left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = a2.pno and pssn.created_at > date_sub(curdate(), interval 1 month) and pssn.valid_store_order is not null
    ) a3
left join dwm.dwd_dim_dict ddd on ddd.element = a3.last_valid_route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    a3.rk = 1



;




with t as
    (
        select
            a.pno
            ,a.store_name
            ,a.staff_info_id
            ,a.routed_at
            ,a.pr_date
            ,a.customary_pno
            ,a.returned
            ,a.transfer_cnt
        from
            (
                select
                    pi.pno
                    ,pr.routed_at
                    ,pr.staff_info_id
                    ,pr.store_name
                    ,pi.returned
                    ,pi.customary_pno
                    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
                    ,count(pr.id) over(partition by pr.pno , date(convert_tz(pr.routed_at, '+00:00', '+07:00'))) transfer_cnt
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+07:00')) order by pr.routed_at desc) rk
                from fle_staging.parcel_info pi
                join rot_pro.parcel_route pr on pr.pno = pi.pno
                where
                    pi.state in (1,2,3,4,6)
                    and pi.created_at > date_sub(curdate(), interval 1 month)
                    and pr.routed_at < date_sub(curdate(), interval 7 hour)
                    and pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval 7 hour)
                    and pr.route_action = 'DELIVERY_TRANSFER'
            ) a
        where
            a.rk = 1
    )
select
    a1.pno 运单号
    ,a1.store_name 操作网点
    ,a1.pr_date 操作日期
    ,ps.store_name 最后有效路由网点
    ,ddd.CN_element 最后有效路由
    ,convert_tz(ps.last_valid_routed_at, '+00:00', '+07:00') 最后有效路由时间
    ,a1.staff_info_id 转单员工
    ,a1.transfer_cnt 转单次数
    ,case a1.returned
        when 1 then '退件'
        when 0 then '正向'
    end 包裹流向
    ,oi.cod_amount/100 COD金额
from
    (
        select
            t1.*
        from t t1
        left join fle_staging.parcel_problem_detail ppd on ppd.pno = t1.pno and ppd.created_at > date_sub(t1.pr_date, interval 7 hour) and ppd.created_at < date_add(t1.pr_date, interval 17 hour)
        where
            ppd.pno is null
    ) a1
left join
    (
        select
            oi.pno
            ,oi.cod_amount
        from fle_staging.order_info oi
        where
            oi.created_at > date_sub(curdate(), interval 8 day)
    ) oi on coalesce(a1.customary_pno, a1.pno) = oi.pno
left join
    (
        select
            pssn.pno
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,pssn.store_name
            ,row_number() over (partition by pssn.pno order by pssn.last_valid_routed_at desc) rk
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        where
            pssn.created_at > date_sub(curdate(), interval 10 day)
            and pssn.valid_store_order is not null
    ) ps on ps.pno = a1.pno and ps.rk = 1
left join dwm.dwd_dim_dict ddd on ddd.element = ps.last_valid_route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
