select
    distinct
    a1.*
    ,datediff(a1.left_at, a1.arrived_at)  detain_days
from
    (
        select
            a.pno
            ,a.client_type
            ,a.dst_store_id
            ,a.returned
            ,a.arrived_at
            ,case
                when a.van_left_at is not null then a.van_left_at
                when a.van_left_at is null and a.next_order is null then now()
                when a.van_left_at is null and a.next_order is not null then a.last_valid_routed_at
                else null
            end  left_at
        from
            (
                select
                    pssn.pno
                    ,case
                        when bc.`client_id` is not null then bc.client_name
                        when kp.id is not null and bc.client_id is null then '普通ka'
                        when kp.`id` is null then '小c'
                    end  client_type
                    ,pi.dst_store_id
                    ,pi.returned
                    ,lead(pssn.valid_store_order, 1) over (partition by pssn.pno order by pssn.valid_store_order ) next_order
                    ,coalesce(pssn.van_arrived_at, pssn.first_valid_routed_at) arrived_at
                    ,pssn.van_left_at
                    ,pssn.last_valid_routed_at
                from dw_dmd.parcel_store_stage_new pssn
                join fle_staging.parcel_info pi on pi.pno = pssn.pno
                left join fle_staging.sys_store_bdc_bsp bsp on bsp.bsp_id = pi.dst_store_id
                left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
                left join fle_staging.ka_profile kp on kp.id = pi.client_id
                where
                    pssn.valid_store_order is not null
                    and coalesce(pssn.van_arrived_at, pssn.first_valid_routed_at) < '2024-04-01'
                    and (pssn.van_left_at > '2024-01-01' or pssn.van_left_at is null)
                    and pi.state in (1,2,3,4,6)
                    and (pssn.store_id = pi.dst_store_id or pssn.store_id  = bsp.bdc_id)
                    and pssn.created_at > '2023-12-01'
                  --  and datediff(coalesce(pssn.van_left_at, now()), coalesce(pssn.van_arrived_at, pssn.first_valid_routed_at)) > 3
            ) a
    ) a1
join dwm.dwd_th_network_spill_detl_rd dt on dt.网点ID = a1.dst_store_id and dt.双重预警 = 'Alert' and dt.统计日期 >= date_add(date(a1.arrived_at), interval 3 day)
# where
#     datediff(a1.left_at, a1.arrived_at) > 3

        ;

select
    *
from
    (
        select
            a2.*
            ,row_number() over (partition by a2.pno order by a2.arrived_at) rk
        from
            (
                select
                    a1.*
                    ,datediff(a1.left_at, a1.arrived_at)  detain_days
                from
                    (

                        select
                            a.pno
                            ,a.client_type
                            ,a.store_id
                            ,a.returned
                            ,a.arrived_at
                            ,case
                                when a.van_left_at is not null then a.van_left_at
                                when a.van_left_at is null and a.next_order is null then now()
                                when a.van_left_at is null and a.next_order is not null then a.last_valid_routed_at
                                else null
                            end  left_at
                        from
                            (
                                select
                                    pssn.pno
                                    ,case
                                        when bc.`client_id` is not null then bc.client_name
                                        when kp.id is not null and bc.client_id is null then '普通ka'
                                        when kp.`id` is null then '小c'
                                    end  client_type
                                    ,pssn.store_id
                                    ,pi.returned
                                    ,pssn.van_left_at
                                    ,pssn.last_valid_routed_at
                                    ,coalesce(pssn.van_arrived_at, pssn.first_valid_routed_at) arrived_at
                                    ,lead(pssn.valid_store_order, 1) over (partition by pssn.pno order by pssn.valid_store_order ) next_order
                                    -- ,datediff(coalesce(pssn.van_left_at, now()), coalesce(pssn.van_arrived_at, pssn.first_valid_routed_at)) detain_days
                                from dw_dmd.parcel_store_stage_new pssn
                                join fle_staging.parcel_info pi on pi.pno = pssn.pno
                                left join fle_staging.sys_store_bdc_bsp bsp on bsp.bsp_id = pi.dst_store_id
                                left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
                                left join fle_staging.ka_profile kp on kp.id = pi.client_id
                                where
                                    pssn.valid_store_order is not null
                                    and coalesce(pssn.van_arrived_at, pssn.first_valid_routed_at) < '2024-04-01'
                                    and (pssn.van_left_at > '2024-01-01' or pssn.van_left_at is null)
                                    and pi.state in (1,2,3,4,6)
                                    and (pssn.store_id != pi.dst_store_id and pssn.store_id  != bsp.bdc_id)
                                    and pssn.created_at > '2023-12-01'
                                    -- and datediff(coalesce(pssn.van_left_at, now()), coalesce(pssn.van_arrived_at, pssn.first_valid_routed_at)) > 3
                            ) a
                    ) a1
            ) a2
        join dwm.dwd_th_network_spill_detl_rd dt on dt.网点ID = a2.store_id and dt.双重预警 = 'Alert' and dt.统计日期 >= date_add(date(a2.arrived_at), interval 3 day)
    ) a3
where
    a3.rk = 1



;
select
    t.pno
    ,t.client_type  客户类型
    ,if(t.returned = 1, '退件', '正向') 是否退货件
    ,ss.name 目的地网点
    ,t.arrived_at 到达目的地网点的日期
    ,t.detain_days 滞留目的地网点天数
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) 强制拍照日期
    ,if(dt2.双重预警 = 'Alert', '是', '否') 强制拍照当日是否爆仓
    ,scan.cnt 交接次数
    ,det.cnt 留仓次数
    ,inv.cnt 盘库次数
    ,dif.cnt 提交问题件次数
    ,mark.cnt 派件标记次数
    ,sor.cnt 分拣扫描次数
    ,pi.cod_amount/100 cod金额
    ,s2.staff_info_id 最后交接快递员
    ,date(pd.last_route_updated) 最后有效路由员工
    ,pd.last_valid_staff_info_id 最后有效路由员工
from tmpale.tmp_th_dst_detain_pno_lj_0308 t
left join fle_staging.parcel_info pi on pi.pno = t.pno
left join fle_staging.sys_store ss on ss.id = t.dst_store_id
left join dwm.dwd_th_network_spill_detl_rd dt on dt.网点ID = t.dst_store_id and dt.统计日期 = date(t.arrived_at)
left join rot_pro.parcel_route pr on pr.pno = t.pno and pr.route_action = 'TAKE_PHOTO'
left join dwm.dwd_th_network_spill_detl_rd dt2 on dt2.统计日期 = date(convert_tz(pr.routed_at, '+00:00', '+07:00')) and pr.store_id = dt2.网点ID
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_dst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) scan on scan.pno = t.pno
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_dst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'DETAIN_WAREHOUSE'
        group by 1
    ) det on det.pno = t.pno
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_dst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'INVENTORY'
        group by 1
    ) inv on inv.pno = t.pno
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_dst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'DIFFICULTY_HANDOVER'
        group by 1
    )  dif on dif.pno = t.pno
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_dst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'DELIVERY_MARKER'
        group by 1
    ) mark on mark.pno = t.pno
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_dst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'SORTING_SCAN'
        group by 1
    ) sor on sor.pno = t.pno
left join
    (
        select
            t.pno
            ,pr.staff_info_id
            ,row_number() over (partition by t.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_dst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    ) s2 on s2.pno = t.pno and s2.rk = 1
left join bi_pro.parcel_detail pd on pd.pno = t.pno


;
-- 非目的地


select
    t.pno
    ,t.client_type  客户类型
    ,if(t.returned = 1, '退件', '正向') 是否退货件
    ,ss.name 目的地网点
    ,t.arrived_at 到达目的地网点的日期
    ,t.detain_days 滞留目的地网点天数
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) 强制拍照日期
    ,if(dt2.双重预警 = 'Alert', '是', '否') 强制拍照当日是否爆仓
    ,scan.cnt 交接次数
    ,det.cnt 留仓次数
    ,inv.cnt 盘库次数
    ,dif.cnt 提交问题件次数
    ,mark.cnt 派件标记次数
    ,sor.cnt 分拣扫描次数
    ,pi.cod_amount/100 cod金额
    ,s2.staff_info_id 最后交接快递员
    ,date(pd.last_route_updated) 最后有效路由员工
    ,pd.last_valid_staff_info_id 最后有效路由员工
from tmpale.tmp_th_nodst_detain_pno_lj_0308 t
left join fle_staging.parcel_info pi on pi.pno = t.pno
left join fle_staging.sys_store ss on ss.id = t.store_id
left join dwm.dwd_th_network_spill_detl_rd dt on dt.网点ID = t.store_id and dt.统计日期 = date(t.arrived_at)
left join rot_pro.parcel_route pr on pr.pno = t.pno and pr.route_action = 'TAKE_PHOTO'
left join dwm.dwd_th_network_spill_detl_rd dt2 on dt2.统计日期 = date(convert_tz(pr.routed_at, '+00:00', '+07:00')) and pr.store_id = dt2.网点ID
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_nodst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) scan on scan.pno = t.pno
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_nodst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'DETAIN_WAREHOUSE'
        group by 1
    ) det on det.pno = t.pno
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_nodst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'INVENTORY'
        group by 1
    ) inv on inv.pno = t.pno
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_nodst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'DIFFICULTY_HANDOVER'
        group by 1
    )  dif on dif.pno = t.pno
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_nodst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'DELIVERY_MARKER'
        group by 1
    ) mark on mark.pno = t.pno
left join
    (
        select
            t.pno
            ,count(pr.id) cnt
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_nodst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'SORTING_SCAN'
        group by 1
    ) sor on sor.pno = t.pno
left join
    (
        select
            t.pno
            ,pr.staff_info_id
            ,row_number() over (partition by t.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_nodst_detain_pno_lj_0308 t on t.pno = pr.pno
        where
            pr.routed_at > '2023-11-01'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    ) s2 on s2.pno = t.pno and s2.rk = 1
left join bi_pro.parcel_detail pd on pd.pno = t.pno