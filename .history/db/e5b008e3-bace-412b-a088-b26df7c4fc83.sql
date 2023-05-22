select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = pi.pno and pr.store_id = pss.next_store_id
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = pi.pno and pr.store_id = pss.next_store_id
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
        a.next_store_id store_id
        ,a.next_store_name store_name
        ,count(distinct a.pno) 应到退件包裹
        ,count(distinct (a.cod_enabled = 1, a.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , a.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) 实到退件COD包裹
        ,count(distinct if(a.state = 5, a.pno, null)) 退件妥投包裹
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno , null)) 退件妥投COD包裹
        ,count(distinct if(a.state = 5, a.pno, null))/count(distinct if(pr.pno is not null , a.pno, null)) 退件妥投完成率
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno, null))/count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) COD退件妥投完成率
    from
        (
            select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null
        ) a
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = a.pno and pr.store_id = a.next_store_id
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        a.next_store_id store_id
        ,a.next_store_name store_name
        ,count(distinct a.pno) 应到退件包裹
        ,count(distinct (a.cod_enabled = 1, a.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , a.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) 实到退件COD包裹
        ,count(distinct if(a.state = 5, a.pno, null)) 退件妥投包裹
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno , null)) 退件妥投COD包裹
        ,count(distinct if(a.state = 5, a.pno, null))/count(distinct if(pr.pno is not null , a.pno, null)) 退件妥投完成率
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno, null))/count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) COD退件妥投完成率
    from
        (
            select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null
        ) a
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = a.pno and pr.store_id = coalesce(a.next_store_id, 0)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
select
        a.next_store_id store_id
        ,a.next_store_name store_name
        ,count(distinct a.pno) 应到退件包裹
        ,count(distinct (a.cod_enabled = 1, a.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , a.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) 实到退件COD包裹
        ,count(distinct if(a.state = 5, a.pno, null)) 退件妥投包裹
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno , null)) 退件妥投COD包裹
        ,count(distinct if(a.state = 5, a.pno, null))/count(distinct if(pr.pno is not null , a.pno, null)) 退件妥投完成率
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno, null))/count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) COD退件妥投完成率
    from
        (
            select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null
        ) a
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = a.pno and coalesce(a.next_store_id, 1) = coalesce(a.next_store_id, 0)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        a.next_store_id store_id
        ,a.next_store_name store_name
        ,count(distinct a.pno) 应到退件包裹
        ,count(distinct (a.cod_enabled = 1, a.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , a.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) 实到退件COD包裹
        ,count(distinct if(a.state = 5, a.pno, null)) 退件妥投包裹
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno , null)) 退件妥投COD包裹
        ,count(distinct if(a.state = 5, a.pno, null))/count(distinct if(pr.pno is not null , a.pno, null)) 退件妥投完成率
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno, null))/count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) COD退件妥投完成率
    from
        (
            select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null
        ) a
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on coalesce(pr.pno,1) = coalesce(a.pno,0) and coalesce(a.next_store_id, 1) = coalesce(a.next_store_id, 0)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        a.next_store_id store_id
        ,a.next_store_name store_name
        ,count(distinct a.pno) 应到退件包裹
        ,count(distinct (a.cod_enabled = 1, a.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , a.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) 实到退件COD包裹
        ,count(distinct if(a.state = 5, a.pno, null)) 退件妥投包裹
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno , null)) 退件妥投COD包裹
        ,count(distinct if(a.state = 5, a.pno, null))/count(distinct if(pr.pno is not null , a.pno, null)) 退件妥投完成率
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno, null))/count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) COD退件妥投完成率
    from
        (
            select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null
        ) a
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = a.pno and a.next_store_id = a.next_store_id
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5, pss.pno and pi2.cod_enabled = 1, null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5, pss.pno and pi2.cod_enabled = 1, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id and pr.routed_at > date_sub(curdate(), interval 8 hour) and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
#     left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
        and pss.pno is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    left join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    left join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno /*and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'*/
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    left join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno /*and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'*/
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.store_id
from ph_staging.parcel_route pr
left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.routed_at > date_sub(curdate(), interval 5 day)
    and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
    and pi.returned = 1
    and pr.store_id = pi.dst_store_id
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.next_store_id
from ph_staging.parcel_route pr
left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.routed_at > date_sub(curdate(), interval 5 day)
    and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
    and pi.returned = 1
    and pr.store_id = pi.dst_store_id
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
#         pss.next_store_id store_id
#         ,pss.next_store_name store_name
#         ,count(distinct pr.pno) 应到退件包裹
#         ,count(distinct (pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
        pr.next_store_id
        ,pr.next_store_name
        ,pr.pno
from ph_staging.parcel_route pr
left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on  pi2.returned_pno = pi.pno
left join dwm.dwd_ex_ph_parcel_details de on de.pno = pr.pno
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.routed_at > date_sub(curdate(), interval 5 day)
    and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
    and pi.returned = 1
    and pr.next_store_id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
#         pss.next_store_id store_id
#         ,pss.next_store_name store_name
#         ,count(distinct pr.pno) 应到退件包裹
#         ,count(distinct (pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    pr.next_store_id
    ,pr.next_store_name
    ,count(pr.pno) 应到退件包裹
    ,count(if(pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
    ,count(if(de.dst_routed_at is not null , pr.pno, null)) 实到退件包裹
    ,count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) 实到退件COD包裹
    ,count(if(pi.state = 5, pr.pno, null)) 退件妥投包裹
    ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null)) 退件妥投COD包裹
    ,count(if(pi.state = 5, pr.pno, null))/count(if(de.dst_routed_at is not null , pr.pno, null)) 退件妥投完成率
    ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null))/count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) COD退件妥投完成率
from ph_staging.parcel_route pr
left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on  pi2.returned_pno = pi.pno
left join dwm.dwd_ex_ph_parcel_details de on de.pno = pr.pno
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.routed_at > date_sub(curdate(), interval 5 day)
    and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
    and pi.returned = 1
    and pr.next_store_id = pi.dst_store_id
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with s1 as
(
    select
        t1.dst_store_id store_id
        ,t1.dst_store store_name
        ,count(t1.pno) 在仓包裹数
        ,count(if(t1.cod_enabled = 'YES', t1.pno, null)) 在仓COD包裹数
        ,count(if(t1.days <= 3, t1.pno, null)) 3日内滞留
        ,count(if(t1.days <= 3 and t1.cod_enabled = 'YES', t1.pno, null)) 3日内COD滞留
        ,count(if(t1.days <= 5, t1.pno, null)) 5日内滞留
        ,count(if(t1.days <= 5 and t1.cod_enabled = 'YES', t1.pno, null)) 5日内COD滞留
        ,count(if(t1.days <= 7, t1.pno, null)) 7日内滞留
        ,count(if(t1.days <= 7 and t1.cod_enabled = 'YES', t1.pno, null)) 7日内COD滞留
        ,count(if(t1.days > 7, t1.pno, null)) 超7天滞留
        ,count(if(t1.days > 7 and t1.cod_enabled = 'YES', t1.pno, null)) 超7天COD滞留
        ,count(if(t1.client_name = 'lazada', t1.pno, null)) lazada在仓
        ,count(if(t1.client_name = 'lazada' and t1.cod_enabled = 'YES', t1.pno, null)) lazadaCOD在仓
        ,count(if(t1.client_name = 'shopee', t1.pno, null)) shopee在仓
        ,count(if(t1.client_name = 'shopee' and t1.cod_enabled = 'YES', t1.pno, null)) shopeeCOD在仓
        ,count(if(t1.client_name = 'tiktok', t1.pno, null)) tt在仓
        ,count(if(t1.client_name = 'tiktok' and t1.cod_enabled = 'YES', t1.pno, null)) ttCOD在仓
        ,count(if(t1.client_name = 'ka&c', t1.pno, null)) 'KA&小C在仓'
        ,count(if(t1.client_name = 'ka&c' and t1.cod_enabled = 'YES', t1.pno, null)) 'KA&小CCOD在仓'
    from
        (
            select
                de.pno
                ,de.dst_store_id
                ,de.dst_store
                ,if(bc.client_name is not null , bc.client_name, 'ka&c') client_name
                ,datediff(curdate(), de.dst_routed_at) days
                ,de.cod_enabled
            from dwm.dwd_ex_ph_parcel_details de
            left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
            where
                de.parcel_state not in (5,7,8,9)
                and de.dst_routed_at is not null
        ) t1
    group by 1
)
,s2 as
(
    select
        a1.dst_store_id store_id
        ,a1.dst_store store_name
        ,a1.num 当日到达COD包裹
        ,a2.num 当日交接COD包裹
        ,a3.num 当日妥投COD包裹
        ,a3.num/a1.num 当日到站COD妥投率
        ,a4.last_3day_num 3日内COD妥投包裹
        ,a4.last_3day_rate 3日COD妥投率
        ,a5.last_3_5day_num 5日COD妥投包裹
        ,a5.last_3_5day_rate 5日COD妥投率
        ,a6.last_5_7day_num 7日内COD包裹妥投数
        ,a6.last_5_7day_rate 7日COD妥投率
        ,a7.over_7day_num 超7日COD包裹妥投数
        ,a7.over_7day_rate 超7日COD妥投率
    from
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a1
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.first_scan_time >= date_sub(curdate(), interval 8 hour )
                and de.first_scan_time < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a2  on a2.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.finished_date = curdate()
                and de.parcel_state = 5
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a3 on a3.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 3 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 3 day), interval 16 hour) -- 3天前到达
            group by 1,2
         ) a4 on a4.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3_5day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3_5day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 5 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 5 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a5 on a5.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_5_7day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_5_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 7 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a6 on a6.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null)) over_7day_num
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null))/count(de.pno) over_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.parcel_state < 9
                and
                    (
                        ( de.parcel_state not in (5,7,8,9) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                        or ( de.parcel_state in (5,7,8) and de.updated_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                    )
            group by 1,2
        ) a7 on a7.dst_store_id = a1.dst_store_id
)
,s3 as
-- 应退件
(
    select
        de.dst_store_id store_id
        ,de.dst_store  store_name
        ,count(t.pno)  应退件包裹
        ,count(if(de.cod_enabled = 'YES', de.pno, null)) 应退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null)) 实际退件包裹
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null)) 实际退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null))/count(t.pno) 退件操作完成率
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null))/count(if(de.cod_enabled = 'YES', de.pno, null)) COD退件操作完成率
    from
        (
            select
                pr.pno
            from ph_staging.parcel_route pr
            where
                pr.routed_at > date_sub(curdate(), interval 8 hour)
                and pr.route_action = 'PENDING_RETURN' -- 待退件
            group by 1
        ) t
    join dwm.dwd_ex_ph_parcel_details de on t.pno = de.pno
    group by 1,2
)
,s4 as
(
    select
        pr.next_store_id store_id
        ,pr.next_store_name store_name
        ,count(pr.pno) 应到退件包裹
        ,count(if(pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
        ,count(if(de.dst_routed_at is not null , pr.pno, null)) 实到退件包裹
        ,count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) 实到退件COD包裹
        ,count(if(pi.state = 5, pr.pno, null)) 退件妥投包裹
        ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null)) 退件妥投COD包裹
        ,count(if(pi.state = 5, pr.pno, null))/count(if(de.dst_routed_at is not null , pr.pno, null)) 退件妥投完成率
        ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null))/count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) COD退件妥投完成率
    from ph_staging.parcel_route pr
    left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    left join ph_staging.parcel_info pi2 on  pi2.returned_pno = pi.pno
    left join dwm.dwd_ex_ph_parcel_details de on de.pno = pr.pno
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day)
        and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
        and pi.returned = 1
        and pr.next_store_id = pi.dst_store_id
    group by 1,2
)
select
    ss.store_id
    ,ss.store_name
    ,s1.在仓包裹数, s1.在仓COD包裹数, s1.`3日内滞留`, s1.`3日内COD滞留`, s1.`5日内滞留`, s1.`5日内COD滞留`, s1.`7日内滞留`, s1.`7日内COD滞留`, s1.超7天滞留, s1.超7天COD滞留, s1.lazada在仓, s1.lazadaCOD在仓, s1.shopee在仓, s1.shopeeCOD在仓, s1.tt在仓, s1.ttCOD在仓, s1.`KA&小C在仓`, s1.`KA&小CCOD在仓`
    ,s2.当日到达COD包裹, s2.当日交接COD包裹, s2.当日妥投COD包裹, s2.当日到站COD妥投率, s2.`3日内COD妥投包裹`, s2.`3日COD妥投率`, s2.`5日COD妥投包裹`, s2.`5日COD妥投率`, s2.`7日内COD包裹妥投数`, s2.`7日COD妥投率`, s2.超7日COD包裹妥投数, s2.超7日COD妥投率
    ,s3.应退件包裹, s3.应退件COD包裹, s3.实际退件包裹, s3.实际退件COD包裹, s3.退件操作完成率, s3.COD退件操作完成率
    ,s4.应到退件包裹, s4.应到退件COD包裹, s4.实到退件包裹, s4.实到退件COD包裹, s4.退件妥投包裹, s4.退件妥投COD包裹, s4.退件妥投完成率, s4.COD退件妥投完成率
from
    (
        select s1.store_id,s1.store_name from s1 group by 1,2
        union all
        select s2.store_id,s2.store_name from s2 group by 1,2
        union all
        select s3.store_id,s3.store_name from s3 group by 1,2
        union all
        select s4.store_id,s4.store_name from s4 group by 1,2
    ) ss
left join s1 on s1.store_id = ss.store_id
left join s2 on s2.store_id = ss.store_id
left join s3 on s3.store_id = ss.store_id
left join s4 on s4.store_id = ss.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    json_table(pre.extra_value)
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    a.id
from ph_drds.parcel_route_extra pre,json_table(pre.extra_value,'$[*]' ,columns(id int path '$images')) as a
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    a.id
from ph_drds.parcel_route_extra pre,json_table(pre.extra_value,'$[*]' ,columns(id VARCHAR(100) path '$images')) as a
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select version();
;-- -. . -..- - / . -. - .-. -.--
select
    json_extract(pre.extra_value, '$.images')
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    json_unquote(json_extract(pre.extra_value, '$.images'))
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    explode(json_extract(pre.extra_value, '$.images'))
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    replace(json_extract(pre.extra_value, '$.images'), '"','')
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '')
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    *
     ,concat('{',job_title,'}') json_test
     ,JSON_EXTRACT(concat('{',job_title,'}'),'$.id')
     ,JSON_EXTRACT(concat('{',job_title,'}'),'$.driver')
from
    (
    SELECT
        id
         , after_object
         ,replace( REPLACE(after_object, '[{',''),'}]','') as new
    from ph_staging.record_version_info rvi
    where id=383553
    )t
    lateral VIEW posexplode ( split ( new, '},{' ) ) t AS job_title, val;
;-- -. . -..- - / . -. - .-. -.--
select
    replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '')
from ph_drds.parcel_route_extra pre

where
    pre.id = '14169159'
lateral view posexplode(split, ',') as b;
;-- -. . -..- - / . -. - .-. -.--
select
    replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '')
from ph_drds.parcel_route_extra pre

lateral view posexplode(split, ',') b as b

where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) as id;
;-- -. . -..- - / . -. - .-. -.--
select
    id
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) as id;
;-- -. . -..- - / . -. - .-. -.--
select
    id
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) id as id;
;-- -. . -..- - / . -. - .-. -.--
select
    id
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) id;
;-- -. . -..- - / . -. - .-. -.--
select
    id
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) id as c;
;-- -. . -..- - / . -. - .-. -.--
select
    c
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) id as c;
;-- -. . -..- - / . -. - .-. -.--
select
                *
#                     json_extract(ext_info,'$.organization_id') store_id
#                     ,substr(fp.p_date, 1, 4) p_month
#                     ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
#                     ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
#                     ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
#                     ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
#                     ,count(if(json_unquote(json_extract(ext_info,'$.matchResult')) = 'true', fp.user_id, null)) sucess_num
                from dwm.dwd_ph_sls_pro_flash_point fp
                where
                    fp.p_date >= '2023-01-01'
                    and fp.store_id = 'PH04470200'
                    and json_unquote(json_extract(ext_info,'$.matchResult')) = 'true';
;-- -. . -..- - / . -. - .-. -.--
select
                *
#                     json_extract(ext_info,'$.organization_id') store_id
#                     ,substr(fp.p_date, 1, 4) p_month
#                     ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
#                     ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
#                     ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
#                     ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
#                     ,count(if(json_unquote(json_extract(ext_info,'$.matchResult')) = 'true', fp.user_id, null)) sucess_num
                from dwm.dwd_ph_sls_pro_flash_point fp
                where
                    fp.p_date >= '2023-01-01'
                    and json_extract(ext_info,'$.organization_id') = 'PH04470200'
                    and json_unquote(json_extract(ext_info,'$.matchResult')) = 'true';
;-- -. . -..- - / . -. - .-. -.--
select
                    ph.hno
                    ,substr(ph.created_at, 1, 4) creat_month
                    ,ph.submit_store_name
                    ,ph.submit_store_id
                    ,ph.pno
                    ,case
                        when ph.state = 0 then '未认领_待认领'
                        when ph.state = 2 then '认领成功'
                        when ph.state = 3 and ph.claim_store_id is null then '未认领_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at < coalesce(sx.claim_time,curdate()) then '认领成功_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at >= coalesce(sx.claim_time,curdate()) then '认领失败_已失效' -- 理赔失效
                    end head_state
                    ,ph.state
                    ,ph.claim_store_id
                    ,ph.claim_store_name
                    ,ph.claim_at
                from  ph_staging.parcel_headless ph
                left join
                    (
                        select
                            ph.pno
                            ,min(pct.created_at) claim_time
                        from ph_staging.parcel_headless ph
                        join ph_bi.parcel_claim_task pct on pct.pno = ph.pno
                        where
                            ph.state = 3 -- 时效
                        group by 1
                    ) sx on sx.pno = ph.pno
                where
                    ph.state < 4
                    and ph.created_at >= '2023-04-01'
                    and ph.submit_store_id = 'PH19280F01';
;-- -. . -..- - / . -. - .-. -.--
select
                    ph.hno
                    ,substr(ph.created_at, 1, 4) creat_month
                    ,ph.submit_store_name
                    ,ph.submit_store_id
                    ,ph.pno
                    ,case
                        when ph.state = 0 then '未认领_待认领'
                        when ph.state in (1,2) then '认领成功'
                        when ph.state = 3 and ph.claim_store_id is null then '未认领_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at < coalesce(sx.claim_time,curdate()) then '认领成功_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at >= coalesce(sx.claim_time,curdate()) then '认领失败_已失效' -- 理赔失效
                    end head_state
                    ,ph.state
                    ,ph.claim_store_id
                    ,ph.claim_store_name
                    ,ph.claim_at
                from  ph_staging.parcel_headless ph
                left join
                    (
                        select
                            ph.pno
                            ,min(pct.created_at) claim_time
                        from ph_staging.parcel_headless ph
                        join ph_bi.parcel_claim_task pct on pct.pno = ph.pno
                        where
                            ph.state = 3 -- 时效
                        group by 1
                    ) sx on sx.pno = ph.pno
                where
                    ph.state < 4
                    and ph.created_at >= '2023-04-01'
                    and ph.submit_store_id = 'PH19280F01';
;-- -. . -..- - / . -. - .-. -.--
select  date_sub('2023-04-03', interval 3 day );
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,pi.cod_amount/100 COD金融
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
where
    de.dst_routed_at < date_sub(curdate(), interval 2 day )
    and de.cod_enabled = 'YES'
    and de.parcel_state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno 运单号
    ,plt.created_at 任务生成时间
    ,concat('SSRD', plt.id) 任务ID
    ,case plt.vip_enable
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end 客户类型
    ,plt.client_id 客户ID
    ,pi.cod_amount/100 COD金额
    ,oi.cogs_amount COGS
    ,ss.short_name 始发地
    ,ss2.short_name  目的地
    ,convert_tz(pi.created_at , '+00:00', '+07:00') 揽件时间
    ,cast(pi.exhibition_weight as double)/1000 '重量'
    ,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) '尺寸'
    ,case pi.parcel_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,case  plt.last_valid_action
        when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end 最后有效路由
    ,plt.last_valid_routed_at 最后有效路由网点
    ,plt.last_valid_staff_info_id 最后有效路由操作人
    ,ss3.name 最后有效路由网点
    ,case plt.is_abnormal
        when 1 then '是'
        when 0 then '否'
     end 是否异常
    ,group_concat(wo.order_no) 工单编号
    ,'C-包裹状态未更新' 问题来源渠道
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 状态
    ,if(plt.fleet_routeids is null, '一致', '不一致') 解封车是否异常
    ,plt.fleet_stores 异常区间
    ,fvp.van_line_name 异常车线
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join ph_staging.fleet_van_proof fvp on fvp.id = substring_index(plt.fleet_routeids, '/', 1)
left join ph_staging.sys_store ss3 on ss3.id = plt.last_valid_store_id
left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
where
    plt.created_at >= '2023-04-01'
    and plt.source = 3 -- C来源
    and plt.state < 5
group by 3;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno 运单号
    ,plt.created_at 任务生成时间
    ,concat('SSRD', plt.id) 任务ID
    ,case plt.vip_enable
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end 客户类型
    ,plt.client_id 客户ID
    ,pi.cod_amount/100 COD金额
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) '物品价值(cogs)'
    ,ss.short_name 始发地
    ,ss2.short_name  目的地
    ,convert_tz(pi.created_at , '+00:00', '+07:00') 揽件时间
    ,cast(pi.exhibition_weight as double)/1000 '重量'
    ,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) '尺寸'
    ,case pi.parcel_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,case  plt.last_valid_action
        when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end 最后有效路由
    ,plt.last_valid_routed_at 最后有效路由网点
    ,plt.last_valid_staff_info_id 最后有效路由操作人
    ,ss3.name 最后有效路由网点
    ,case plt.is_abnormal
        when 1 then '是'
        when 0 then '否'
     end 是否异常
    ,group_concat(wo.order_no) 工单编号
    ,'C-包裹状态未更新' 问题来源渠道
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 状态
    ,if(plt.fleet_routeids is null, '一致', '不一致') 解封车是否异常
    ,plt.fleet_stores 异常区间
    ,fvp.van_line_name 异常车线
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join ph_staging.fleet_van_proof fvp on fvp.id = substring_index(plt.fleet_routeids, '/', 1)
left join ph_staging.sys_store ss3 on ss3.id = plt.last_valid_store_id
left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
where
    plt.created_at >= '2023-04-01'
    and plt.source = 3 -- C来源
    and plt.state < 5
group by 3;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno 运单号
    ,plt.created_at 任务生成时间
    ,concat('SSRD', plt.id) 任务ID
    ,case plt.vip_enable
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end 客户类型
    ,plt.client_id 客户ID
    ,pi.cod_amount/100 COD金额
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) '物品价值(cogs)'
    ,ss.short_name 始发地
    ,ss2.short_name  目的地
    ,convert_tz(pi.created_at , '+00:00', '+07:00') 揽件时间
    ,cast(pi.exhibition_weight as double)/1000 '重量'
    ,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) '尺寸'
    ,case pi.parcel_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,case  plt.last_valid_action
        when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end 最后有效路由
    ,plt.last_valid_routed_at 最后有效路由网点
    ,plt.last_valid_staff_info_id 最后有效路由操作人
    ,ss3.name 最后有效路由网点
    ,case plt.is_abnormal
        when 1 then '是'
        when 0 then '否'
     end 是否异常
    ,group_concat(wo.order_no) 工单编号
    ,'C-包裹状态未更新' 问题来源渠道
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 状态
    ,if(plt.fleet_routeids is null, '一致', '不一致') 解封车是否异常
    ,plt.fleet_stores 异常区间
    ,fvp.van_line_name 异常车线
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join ph_staging.fleet_van_proof fvp on fvp.id = substring_index(plt.fleet_routeids, '/', 1)
left join ph_staging.sys_store ss3 on ss3.id = plt.last_valid_store_id
left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
where
    plt.created_at >= '2023-04-01'
    and plt.source = 1 -- C来源
    and plt.state < 5
group by 3;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno

from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
where
    de.dst_store_id = 'PH19040F05' -- 目的地网点是拍卖仓
    and pcd.field_name = 'dst_store_id'
    and pcd.new_value = 'PH19040F05'
    and de.parcel_state not in (5,7,8,9)
    and pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        de.dst_store_id = 'PH19040F05' -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
select
    a.pno
    ,a.store_name store
from
    (
        select
            pr.pno
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.id desc ) rn
        from ph_staging.parcel_route pr
        join t on t.pno = pr.pno
        where
            pr.routed_at < t.created_at
            and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
    ) a
where
    a.rn = 1

union

-- 目的地网点在仓未达终态
select
    de.pno
    ,de.dst_store store
from dwm.dwd_ex_ph_parcel_details de
where
    de.dst_routed_at is not null
    and de.parcel_state not in (5,7,8,9) -- 未终态，且目的地网点有路由
    and de.dst_store_id != 'PH19040F05'  -- 目的地网点不是拍卖仓

union
-- 退件未发出
select
    de.pno
    ,de.src_store store
from dwm.dwd_ex_ph_parcel_details de
where
    de.returned = 1
    and de.pickup_out_time is null;
;-- -. . -..- - / . -. - .-. -.--
select
    count(*) from
(
    select
            de.pno
            ,de.src_store store
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.returned = 1
            and de.pickup_out_time is null
);
;-- -. . -..- - / . -. - .-. -.--
select
    count(*) from
(
    select
            de.pno
            ,de.src_store store
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.returned = 1
            and de.pickup_out_time is null
            and de.parcel_state not in (5,7,8,9)
);
;-- -. . -..- - / . -. - .-. -.--
select
            de.pno
            ,de.src_store store
            ,de.parcel_state
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.returned = 1
            and de.pickup_out_time is null
            and de.parcel_state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        de.dst_store_id = 'PH19040F05' -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
select
    a.pno
    ,a.store_name store
from
    (
        select
            pr.pno
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.id desc ) rn
        from ph_staging.parcel_route pr
        join t on t.pno = pr.pno
        where
            pr.routed_at < t.created_at
            and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
    ) a
where
    a.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    count(*) from
(
    select
            de.pno
            ,de.src_store store
            ,de.parcel_state
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        where
            de.returned = 1
            and pr.pno is null
            and de.parcel_state not in (5,7,8,9)
) a;
;-- -. . -..- - / . -. - .-. -.--
select
    count(*) from
(
    select
            de.pno
            ,de.src_store store
            ,de.parcel_state
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = de.src_store_id
        where
            de.returned = 1
            and pr.pno is null
            and de.parcel_state not in (5,7,8,9)
) a;
;-- -. . -..- - / . -. - .-. -.--
select
            de.pno
            ,de.src_store store
            ,de.parcel_state
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = de.src_store_id
        where
            de.returned = 1
            and pr.pno is null
            and de.parcel_state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
            de.pno
            ,de.src_store store
            ,de.parcel_state
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.returned = 1
            and de.last_store_id != de.src_store_id
            and de.parcel_state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
            de.pno
            ,de.src_store store
            ,de.parcel_state
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and de.parcel_state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,de.src_store store
from dwm.dwd_ex_ph_parcel_details de
where
    de.returned = 1
    and de.last_store_id = de.src_store_id
    and de.parcel_state not in (2,5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,de.src_store store
    ,de.parcel_state
from dwm.dwd_ex_ph_parcel_details de
where
    de.returned = 1
    and de.last_store_id = de.src_store_id
    and de.parcel_state not in (2,5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,de.last_store_name store
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
where
    de.dst_store_id = 'PH19040F05' -- 目的地网点是拍卖仓
    and pcd.field_name = 'dst_store_id'
    and pcd.new_value = 'PH19040F05'
    and de.parcel_state not in (5,7,8,9)
    and pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,de.last_store_name store
from dwm.dwd_ex_ph_parcel_details de
where
    de.dst_routed_at is not null
    and de.parcel_state not in (5,7,8,9) -- 未终态，且目的地网点有路由
    and de.dst_store_id != 'PH19040F05';
;-- -. . -..- - / . -. - .-. -.--
select count(*) from
                    (select
    de.pno
    ,de.last_store_name store
from dwm.dwd_ex_ph_parcel_details de
where
    de.dst_routed_at is not null
    and de.parcel_state not in (5,7,8,9) -- 未终态，且目的地网点有路由
    and de.dst_store_id != 'PH19040F05';
;-- -. . -..- - / . -. - .-. -.--
select count(*) from
                    (select
    de.pno
    ,de.last_store_name store
from dwm.dwd_ex_ph_parcel_details de
where
    de.dst_routed_at is not null
    and de.parcel_state not in (5,7,8,9) -- 未终态，且目的地网点有路由
    and de.dst_store_id != 'PH19040F05'  -- 目的地网点不是拍卖仓
                        );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        de.dst_store_id = 'PH19040F05' -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.routed_at < t.created_at
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.dst_routed_at is not null
            and de.parcel_state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and de.dst_store_id != 'PH19040F05'  -- 目的地网点不是拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and de.parcel_state not in (2,5,7,8,9)
)
select
    de.pno
    ,b.type 类型
    ,b.store 当前网点
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,oi.cod_amount/100 COD金额
    ,de.src_store 揽收网点
    ,de.dst_store 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join ph_staging.order_info oi on b.pno = oi.pno
left join ph_staging.parcel_route pr on pr.pno = b.pno and pr.route_action = 'INVENTORY' and pr.routed_at >= date_add(curdate(), interval 8 hour)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        de.dst_store_id = 'PH19040F05' -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.routed_at < t.created_at
                    and pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.dst_routed_at is not null
            and de.parcel_state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and de.dst_store_id != 'PH19040F05'  -- 目的地网点不是拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and de.parcel_state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 寄件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,de.dst_store 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join ph_staging.order_info oi on b.pno = oi.pno
left join ph_staging.parcel_route pr on pr.pno = b.pno and pr.route_action = 'INVENTORY' and pr.routed_at >= date_add(curdate(), interval 8 hour)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key) 地址
from
    (
        select
            a.pno
            ,link_id
        from
            (
                select
                    pr.pno
                    ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
                from ph_staging.parcel_route pr
                left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
                where
                    pr.route_action = 'TAKE_PHOTO'
                    and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
                    and pr.routed_at > date_sub(date_sub(curdate() ,interval 7 day), interval 8 hour )
                    and pr.pno = 'P35301F7J38AQ'
            ) a
        lateral view explode(split(a.valu, ',')) id as link_id
    ) a
left join ph_staging.sys_attachment sa on sa.id = a.link_id;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 路由时间
    ,a.store_name 操作网点
    ,a.staff_info_id 操作员工
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key) 地址
from
    (
        select
            a.pno
            ,a.routed_at
            ,a.store_name
            ,a.staff_info_id
            ,link_id
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,pr.store_id
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
                from ph_staging.parcel_route pr
                left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
                where
                    pr.route_action = 'TAKE_PHOTO'
                    and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
                    and pr.routed_at > date_sub(date_sub(curdate() ,interval 7 day), interval 8 hour )
#                     and pr.pno = 'P35301F7J38AQ'
            ) a
        lateral view explode(split(a.valu, ',')) id as link_id
    ) a
left join ph_staging.sys_attachment sa on sa.id = a.link_id;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 路由时间
    ,a.store_name 操作网点
    ,a.staff_info_id 操作员工
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key) 地址
from
    (
        select
            a.pno
            ,a.routed_at
            ,a.store_name
            ,a.staff_info_id
            ,link_id
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,pr.store_id
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
                from ph_staging.parcel_route pr
                left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
                where
                    pr.route_action = 'TAKE_PHOTO'
                    and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
                    and pr.routed_at > date_sub(date_sub(curdate() ,interval 21 day), interval 8 hour )
#                     and pr.pno = 'P35301F7J38AQ'
            ) a
        lateral view explode(split(a.valu, ',')) id as link_id
    ) a
left join ph_staging.sys_attachment sa on sa.id = a.link_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,json_extract(am.extra_info, '$.losr_task_id') lose_task_id
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-03-01'
        and am.abnormal_time < '2023-05-01'
        and am.state = 1
    group by 1,2
)
, lost as
(
    select
        pr.pno
        ,pr.staff_info_id
        ,pr.routed_at
    from ph_staging.parcel_route pr
    join  t on pr.pno = t.merge_column
    where
        pr.route_action = 'DIFFICULTY_HANDOVER'
        and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
)
select
    t.merge_column 单号
    ,t.customary_pno 正向单号
    ,t.name 网点名称
    ,if(t.returned = 0 ,'Fwd', 'Rts') 正向或逆向
    ,case pr.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 最后一条有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一条有效路由时间
    ,convert_tz(pri.routed_at, '+00:00', '+08:00') 最后一次打印面单日期
    ,convert_tz(pri2.routed_at, '+00:00', '+08:00') '如果是退件面单，最后一次正向打印面单的日期'
    ,if(t.returned = 1, convert_tz(pri.routed_at, '+00:00', '+08:00'), null) 退件面单最后一次打印日期
    ,t.client_id
    ,if(t.isappeal in (2,3,4,5) ,'yes', 'no') 是否有申诉记录
    ,if(c.pno is null , 'NO', 'YES') 'Source C'
    ,case aft.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then ' to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route after Lost was reported'
    ,lost.staff_info_id 'ID that submitted Lost'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,case bef.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route before reporting Lost'
    ,group_concat(plr.staff_id) staff
from t
left join
    (
          select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on t.merge_column = pr.pno
        where  -- 最后有效路由
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = t.merge_column and pr.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.merge_column
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = t.merge_column and pri.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.customary_pno
        where
            pr.route_action = 'PRINTING'
            and t.returned = 1
    ) pri2 on pri2.pno = t.customary_pno and pri2.rn = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t on t.merge_column = plt.pno
        where
            plt.source = 3
        group by 1
    ) c on c.pno = t.merge_column
left join lost on lost.pno = t.merge_column
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.merge_column and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.merge_column and bef.rn = 1
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = t.lose_task_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.routed_at
        ,a.store_id
        ,a.store_name
        ,a.staff_info_id
        ,link_id
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.store_name
                ,pr.staff_info_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
            from ph_staging.parcel_route pr
            left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
            where
                pr.route_action = 'TAKE_PHOTO'
                and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
                and pr.routed_at > date_sub(date_sub(curdate() ,interval 21 day), interval 8 hour )
#                     and pr.pno = 'P35301F7J38AQ'
        ) a
    lateral view explode(split(a.valu, ',')) id as link_id
);
;-- -. . -..- - / . -. - .-. -.--
select
        a.pno
        ,a.routed_at
        ,a.store_id
        ,a.store_name
        ,a.staff_info_id
        ,link_id
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.store_name
                ,pr.staff_info_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
            from ph_staging.parcel_route pr
            left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
            where
                pr.route_action = 'TAKE_PHOTO'
                and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
                and pr.routed_at > date_sub(date_sub(curdate() ,interval 21 day), interval 8 hour )
#                     and pr.pno = 'P35301F7J38AQ'
        ) a
    lateral view explode(split(a.valu, ',')) id as link_id;
;-- -. . -..- - / . -. - .-. -.--
select
        a.pno
        ,a.routed_at
        ,a.store_id
        ,a.store_name
        ,a.staff_info_id
        ,link_id
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.store_name
                ,pr.staff_info_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
            from ph_staging.parcel_route pr
            left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
            where
                pr.route_action = 'TAKE_PHOTO'
                and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
                and pr.routed_at >= date_sub(date_sub(curdate() ,interval 1 day), interval 8 hour )
                and pr.routed_at < date_sub(curdate(), interval 8 hour )
#                     and pr.pno = 'P35301F7J38AQ'
        ) a
    lateral view explode(split(a.valu, ',')) id as link_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.routed_at
        ,a.store_id
        ,a.store_name
        ,a.staff_info_id
        ,link_id
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.store_name
                ,pr.staff_info_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
            from ph_staging.parcel_route pr
            left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
            where
                pr.route_action = 'TAKE_PHOTO'
                and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
                and pr.routed_at >= date_sub(date_sub(curdate() ,interval 1 day), interval 8 hour )
                and pr.routed_at < date_sub(curdate(), interval 8 hour )
#                     and pr.pno = 'P35301F7J38AQ'
        ) a
    lateral view explode(split(a.valu, ',')) id as link_id
);
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.routed_at
        ,a.store_id
        ,a.store_name
        ,a.staff_info_id
        ,link_id
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.store_name
                ,pr.staff_info_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
            from ph_staging.parcel_route pr
            left join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
            where
                pr.route_action = 'TAKE_PHOTO'
                and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
                and pr.routed_at >= date_sub(date_sub(curdate() ,interval 1 day), interval 8 hour )
                and pr.routed_at < date_sub(curdate(), interval 8 hour )
        ) a
    lateral view explode(split(a.valu, ',')) id as link_id
);
;-- -. . -..- - / . -. - .-. -.--
select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.area_name 地区
    ,de.pickup_time 揽收时间
    ,de.dst_store_in_time 到达目的地网点时间
    ,a.pno
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) '物品价值(cogs)'
    ,oi.cod_amount/100 COD金融
    ,datediff(date_sub(curdate(), interval 1 day), de.dst_routed_at) 在仓天数
    ,if(pri.pno is null, '否', '是') 是否打印面单
    ,convert_tz(a.routed_at, '+00:00', '+08:00') 拍照路由时间
    ,a.store_name 操作网点
    ,a.staff_info_id 操作员工
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key) 地址
from a
left join ph_staging.sys_attachment sa on sa.id = a.link_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_ex_ph_parcel_details de on de.pno = a.pno
left join ph_staging.order_info oi on oi.pno = de.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
left join
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        join
            (
                select
                    a.pno
                from a
                group by 1
            ) a1 on a1.pno = pr.pno
        where
            pr.route_action = 'PRINTING'
        group by 1
    ) pri on pri.pno = a.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from ph_bi.parcel_lose_task plt
where
#     plt.created_at >= '2023-04-01'
#     and plt.state in (5,6)
#     and plt.penalties > 0
    plt.total is null
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from ph_bi.parcel_lose_task plt
where
    plt.total = 2
order by pno;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from ph_bi.parcel_lose_task plt
where
    plt.total = 2
    and plt.created_at >= '2023-04-01'
order by pno;
;-- -. . -..- - / . -. - .-. -.--
with s1 as
(
    select
        t1.dst_store_id store_id
        ,t1.dst_store store_name
        ,count(t1.pno) 在仓包裹数
        ,count(if(t1.cod_enabled = 'YES', t1.pno, null)) 在仓COD包裹数
        ,count(if(t1.days <= 3, t1.pno, null)) 3日内滞留
        ,count(if(t1.days <= 3 and t1.cod_enabled = 'YES', t1.pno, null)) 3日内COD滞留
        ,count(if(t1.days <= 5, t1.pno, null)) 5日内滞留
        ,count(if(t1.days <= 5 and t1.cod_enabled = 'YES', t1.pno, null)) 5日内COD滞留
        ,count(if(t1.days <= 7, t1.pno, null)) 7日内滞留
        ,count(if(t1.days <= 7 and t1.cod_enabled = 'YES', t1.pno, null)) 7日内COD滞留
        ,count(if(t1.days > 7, t1.pno, null)) 超7天滞留
        ,count(if(t1.days > 7 and t1.cod_enabled = 'YES', t1.pno, null)) 超7天COD滞留
        ,count(if(t1.client_name = 'lazada', t1.pno, null)) lazada在仓
        ,count(if(t1.client_name = 'lazada' and t1.cod_enabled = 'YES', t1.pno, null)) lazadaCOD在仓
        ,count(if(t1.client_name = 'shopee', t1.pno, null)) shopee在仓
        ,count(if(t1.client_name = 'shopee' and t1.cod_enabled = 'YES', t1.pno, null)) shopeeCOD在仓
        ,count(if(t1.client_name = 'tiktok', t1.pno, null)) tt在仓
        ,count(if(t1.client_name = 'tiktok' and t1.cod_enabled = 'YES', t1.pno, null)) ttCOD在仓
        ,count(if(t1.client_name = 'ka&c', t1.pno, null)) 'KA&小C在仓'
        ,count(if(t1.client_name = 'ka&c' and t1.cod_enabled = 'YES', t1.pno, null)) 'KA&小CCOD在仓'
    from
        (
            select
                de.pno
                ,de.dst_store_id
                ,de.dst_store
                ,if(bc.client_name is not null , bc.client_name, 'ka&c') client_name
                ,datediff(curdate(), de.dst_routed_at) days
                ,de.cod_enabled
            from dwm.dwd_ex_ph_parcel_details de
            left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
            where
                de.parcel_state not in (5,7,8,9)
                and de.dst_routed_at is not null
        ) t1
    group by 1
)
,s2 as
(
    select
        a1.dst_store_id store_id
        ,a1.dst_store store_name
        ,a1.num 当日到达COD包裹
        ,a2.num 当日交接COD包裹
        ,a3.num 当日妥投COD包裹
        ,a3.num/a1.num 当日到站COD妥投率
        ,a4.last_3day_num 3日内COD妥投包裹
        ,a4.last_3day_rate 3日COD妥投率
        ,a5.last_3_5day_num 5日COD妥投包裹
        ,a5.last_3_5day_rate 5日COD妥投率
        ,a6.last_5_7day_num 7日内COD包裹妥投数
        ,a6.last_5_7day_rate 7日COD妥投率
        ,a7.over_7day_num 超7日COD包裹妥投数
        ,a7.over_7day_rate 超7日COD妥投率
    from
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a1
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.first_scan_time >= date_sub(curdate(), interval 8 hour )
                and de.first_scan_time < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a2  on a2.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.finished_date = curdate()
                and de.parcel_state = 5
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a3 on a3.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 3 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 3 day), interval 16 hour) -- 3天前到达
            group by 1,2
         ) a4 on a4.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3_5day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3_5day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 5 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 5 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a5 on a5.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_5_7day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_5_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 7 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a6 on a6.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null)) over_7day_num
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null))/count(de.pno) over_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.parcel_state < 9
                and
                    (
                        ( de.parcel_state not in (5,7,8,9) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                        or ( de.parcel_state in (5,7,8) and de.updated_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                    )
            group by 1,2
        ) a7 on a7.dst_store_id = a1.dst_store_id
)
,s3 as
-- 应退件
(
    select
        de.dst_store_id store_id
        ,de.dst_store  store_name
        ,count(t.pno)  应退件包裹
        ,count(if(de.cod_enabled = 'YES', de.pno, null)) 应退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null)) 实际退件包裹
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null)) 实际退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null))/count(t.pno) 退件操作完成率
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null))/count(if(de.cod_enabled = 'YES', de.pno, null)) COD退件操作完成率
    from
        (
            select
                pr.pno
            from ph_staging.parcel_route pr
            where
                pr.routed_at > date_sub(curdate(), interval 8 hour)
                and pr.route_action = 'PENDING_RETURN' -- 待退件
            group by 1
        ) t
    join dwm.dwd_ex_ph_parcel_details de on t.pno = de.pno
    group by 1,2
)
,s4 as
(
    select
        pr.next_store_id store_id
        ,pr.next_store_name store_name
        ,count(pr.pno) 应到退件包裹
        ,count(if(pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
        ,count(if(de.dst_routed_at is not null , pr.pno, null)) 实到退件包裹
        ,count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) 实到退件COD包裹
        ,count(if(pi.state = 5, pr.pno, null)) 退件妥投包裹
        ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null)) 退件妥投COD包裹
        ,count(if(pi.state = 5, pr.pno, null))/count(if(de.dst_routed_at is not null , pr.pno, null)) 退件妥投完成率
        ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null))/count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) COD退件妥投完成率
    from ph_staging.parcel_route pr
    left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    left join ph_staging.parcel_info pi2 on  pi2.returned_pno = pi.pno
    left join dwm.dwd_ex_ph_parcel_details de on de.pno = pr.pno
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day)
        and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
        and pi.returned = 1
        and pr.next_store_id = pi.dst_store_id
    group by 1,2
)
select
    ss.store_id
    ,ss.store_name
    ,s1.在仓包裹数, s1.在仓COD包裹数, s1.`3日内滞留`, s1.`3日内COD滞留`, s1.`5日内滞留`, s1.`5日内COD滞留`, s1.`7日内滞留`, s1.`7日内COD滞留`, s1.超7天滞留, s1.超7天COD滞留, s1.lazada在仓, s1.lazadaCOD在仓, s1.shopee在仓, s1.shopeeCOD在仓, s1.tt在仓, s1.ttCOD在仓, s1.`KA&小C在仓`, s1.`KA&小CCOD在仓`
    ,s2.当日到达COD包裹, s2.当日交接COD包裹, s2.当日妥投COD包裹, s2.当日到站COD妥投率, s2.`3日内COD妥投包裹`, s2.`3日COD妥投率`, s2.`5日COD妥投包裹`, s2.`5日COD妥投率`, s2.`7日内COD包裹妥投数`, s2.`7日COD妥投率`, s2.超7日COD包裹妥投数, s2.超7日COD妥投率
    ,s3.应退件包裹, s3.应退件COD包裹, s3.实际退件包裹, s3.实际退件COD包裹, s3.退件操作完成率, s3.COD退件操作完成率
    ,s4.应到退件包裹, s4.应到退件COD包裹, s4.实到退件包裹, s4.实到退件COD包裹, s4.退件妥投包裹, s4.退件妥投COD包裹, s4.退件妥投完成率, s4.COD退件妥投完成率
from
    (
        select s1.store_id,s1.store_name from s1 group by 1,2
        union
        select s2.store_id,s2.store_name from s2 group by 1,2
        union
        select s3.store_id,s3.store_name from s3 group by 1,2
        union
        select s4.store_id,s4.store_name from s4 group by 1,2
    ) ss
left join s1 on s1.store_id = ss.store_id
left join s2 on s2.store_id = ss.store_id
left join s3 on s3.store_id = ss.store_id
left join s4 on s4.store_id = ss.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,if(pi.state = 5, ss.name, null) 妥投网点
    ,pi.state
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'p61181GHK3SdM', 'P20231GA55KaP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'p0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'p0206WR89Nbg', 'P6201ZUFJ6BD', 'p0234NQPB1AE', 'p022817SZKUaK', 'P6201S7BHEAY', 'p0234N629Xab', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBk', 'P620114UHYEAJ', 'P021415AB3NBH', 'p0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2Aa', 'p0112K5RUMci', 'p6201K6B0EbA', 'P0220K1W1Dar', 'p6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'p0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'p0104XNMY1Al', 'P0105MFWH5aI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'p6222Y45Q9ad', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAk', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAh', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'p01121C85S0bn', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAa', 'P3016AHZW8as', 'P3230DMS09aM', 'p3221AHZVGfh', 'p3307DUSZ7Ao', 'P3608AHZWRaA', 'p322319N0SCe', 'p61011EN7TBS', 'p33011QBZMAB', 'p281313PWNAs', 'p2906140HBBe', 'P33021XRY1Aw', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'p3231JE2QEaa', 'p3309AHZV2Ab', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'p3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'pT13111VJRC0bd', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,if(pi.state = 5, ss.name, null) 妥投网点
    ,pi.state
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,if(pi.state = 5, ss.name, null) 妥投网点
    ,pi.state
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX')
    or pi.recent_pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,if(pi.state = 5, ss.name, null) 妥投网点
    ,pi.state
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX')
#     or pi.recent_pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX')

union all

select
    pi.recent_pno pno
    ,if(pi.state = 5, ss.name, null) 妥投网点
    ,pi.state
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.recent_pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,if(pi.state = 5, ss.name, null) 妥投网点
    ,pi.state
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX')
#     or pi.recent_pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX')

union

select
    pi.recent_pno pno
    ,if(pi.state = 5, ss.name, null) 妥投网点
    ,pi.state
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.recent_pno in ('P61171DPYUTBA', 'P19141D1X78AF', 'P201817WV6RAA', 'PT61151PVV9AA', 'P110716C16JAH', 'PT61201SK18GF', 'P201817J2EEAA', 'P201817RYZYAZ', 'P611817BNYWEV', 'P612017HYV2GK', 'PT61201VKD1GJ', 'P612317W38AAN', 'P201817GUBGAJ', 'P6123181ZUCAQ', 'P61231822T3AQ', 'P6117181PYQAK', 'P6128187586DW', 'P201818NPD9AZ', 'P6118141JPYCQ', 'P201818R54BAA', 'P612018EBJYHB', 'P612018K4Y5GR', 'P611618HKFNAB', 'P611718MYUGAO', 'PT613121ZZ2BU', 'P201818VHHXAZ', 'PT211324YH7AA', 'PT2102263F5AD', 'P21041952HEAY', 'PT211326698AD', 'PT121225WT5AB', 'P612319C6W5AK', 'P6118191D7TEV', 'PD612019H7GCCJ', 'P6120195RT3GR', 'P6102196VCAAG', 'P202019HY1ZBN', 'P181119YWE2AK', 'P181119YWE4AK', 'P181119YWE7AK', 'P181119YWE3AK', 'P181119YWEAAK', 'P181119YWE6AK', 'P181119YWE9AK', 'P181119YWE8AK', 'P181119YWEBAK', 'PT61131S29X6AA', 'PT21122AJA5AK', 'P20181A2JGXAY', 'PD061517VFYWAI', 'P192419H6AYAY', 'P20341A1MKRAA', 'PT611821F4GC2BY', 'P61201A7UURCZ', 'P201819Y5MMAZ', 'P61181AC7WRDE', 'P61181AK62SCH', 'PT61181SD7X2FI', 'P61211B6ANTAF', 'P19051B66FDAW', 'P20031BAUUCAG', 'PT20131SPSB6BL', 'P19241A9MVXCJ', 'P61221BE0CHAK', 'P61021BS6Z1AA', 'P61181BW6CCEL', 'P61011BPPW6EO', 'P21041BXCFTAB', 'PT61181SZSJ0BI', 'P61181BQG79DM', 'PT61201T0PE6GD', 'PT20231T46M6AW', 'P61231C0K9MBD', 'P18111CDQCNAH', 'P17051A04KZBI', 'P61181CFAGJFH', 'P61091CJG1KAD', 'P19011CFAFUAJ', 'P19241CFACQAE', 'P53021BBRJ0CE', 'P21051CHTT2AA', 'P18031CHYUVBF', 'PD21021CK7Z2AI', 'P01151CKTCAAP', 'PT14851TCUQ3ZZ', 'PT61231TDMV5AW', 'P61011CYSS3AX', 'PT61071TAN94AE', 'PT14011TDT50AC', 'P61261CJ1E1AD', 'P20181D0J7YAZ', 'PT21081THUS6AA', 'PT21121TD9Q4AS', 'PT19241TDDT4BR', 'P61301DB36ZAV', 'P20181DBH4ZAZ', 'PD61151D8V97AM', 'P61171DEZN8AO', 'P21051D9M10AC', 'P20181D6C2HAZ', 'P20181DER67AZ', 'P61151D71U8AK', 'P20181E1WMVAZ', 'P21021E3NWKAF', 'P61181EDKC0CY', 'P61161E9JYTAA', 'PT61181TUVF6CN', 'P61061E4P35HA', 'P61181EDKBVFI', 'P61171DNKH0AK', 'P61201E4NH5HF', 'P19271E4KD1AV', 'P61221EAWXXAM', 'P20071E88ZDAA', 'P61201DQ9XSGD', 'P61011E9T8SFF', 'P61171EJHS4AK', 'PT20081UJ729BG', 'PT20141UJA43AL', 'P61181DNKCMCY', 'P61231E52JYAM', 'P61181DTAJHDD', 'P61201ED3RDGU', 'P61201EDTAUGT', 'P61201EM0EAAL', 'P61051EFCT2BY', 'P21081EREG7AJ', 'PT612321F4U48AQ', 'P20131EKU43BE', 'PT21021UV8A0AO', 'P21131EHT7BAC', 'P61271EGX9FAO', 'P21021EAACMAN', 'P17051EXE55BN', 'PD61011EKJ77JQ', 'PD61011B17KEJQ', 'P21021EPS1GAD', 'P18111EVFHPAK', 'P61231EVEA0AE', 'P61161EVFFHAB', 'P61181F2NC4AT', 'PT61011U58V3DG', 'P80051EBUQNAK', 'PT61171UVNS5AA', 'P21021EMDWUAG', 'PD17031EXFN2AI', 'P19211DWH4YAA', 'P21081FHM7PAI', 'P61201EMTFMGR', 'P07351FHC1GAZ', 'P61041FYH9PAO', 'P20181FYFT3AZ', 'PT61201VBNQ1BB', 'P61231FJ28ZAM', 'P61201FTA8BGR', 'P61201G8PAHGT', 'P18011FS4FWBD', 'P61181GHK3SDM', 'P20231GA55KAP', 'P6210XD52DAO', 'P022017Z3MZAZ', 'P022417DUQ2AX', 'P011419G2TVAF', 'P6210XUZVYAB', 'FLPHM000004752832', 'P0206XAVPTBG', 'P011719AHQZAT', 'P020618JEEKBG', 'P011817374KAU', 'P0226TZA1YBB', 'P620718Z6RYAE', 'P011913AE90AB', 'P0224W209WAP', 'P0206WR89NBG', 'P6201ZUFJ6BD', 'P0234NQPB1AE', 'P022817SZKUAK', 'P6201S7BHEAY', 'P0234N629XAB', 'P0228JYEEVBC', 'P02041964QPAV', 'P0223166AWGAE', 'P0112KAASZBK', 'P620114UHYEAJ', 'P021415AB3NBH', 'P0117U8DMTAK', 'P022515PDSXAD', 'P6220142Y1UAC', 'P022413PX15AQ', 'P0226TV68AAL', 'P0220130DKKAB', 'P0213MWQY2AA', 'P0112K5RUMCI', 'P6201K6B0EBA', 'P0220K1W1DAR', 'P6201EPX9DAZ', 'P0121NZPC0AX', 'P0212T9TGTAV', 'P0116F0QE4AS', 'P0119QSUKUAY', 'P0233T7VWWBB', 'P0222PJ521AI', 'P0206PWMZ5BL', 'P02121396WDAV', 'P6201X5WR6BB', 'P0224Z0SGJAW', 'P0228JK5AFAS', 'P0203FJU14AX', 'P012110BGA3AT', 'P0104XNMY1AL', 'P0105MFWH5AI', 'P6210144XS6AJ', 'P023410XCZ4AQ', 'P6201K35CHBA', 'P0206FCH69BL', 'P6201TUE5TAL', 'P0223131JVNAG', 'P6222Y45Q9AD', 'P0210100GT3AC', 'P011512V7DJAC', 'P6216PU8RXAK', 'P020611DYCJAM', 'P6223YQAZVAF', 'P0220VYFPKAH', 'P0227YZW3PAX', 'P022011MY0NAF', 'P022610XDBUAH', 'P6201ZYA9MAY', 'P0112NY5EABP', 'PD020513TFYWAZ', 'P0104HEMN3AF', 'PD62071BUK41AL', 'P02141C6B1FAW', 'P01121C85S0BN', 'P02071CFSHGAO', 'P62011DA8ZMBC', 'PT1031TNGN7BB', 'P4714188CC4AE', 'P490416MT3SAV', 'P472113SVX7AW', 'P610211J1C0AA', 'P4715AHZX2AD', 'P4904A87JNAO', 'P4904AJ0DQAZ', 'P5105AJ0D5AE', 'P4514DQTGRBL', 'P5126AHZUTAJ', 'P7707G5B5AAH', 'P5302XKT3KAU', 'P5302XKT3TDB', 'P4715YRZZDAH', 'P45145HYT3AP', 'P47196WPNKAA', 'P5120127KKHAH', 'P4721WK3W4AW', 'PD4703Q0MNRAB', 'P4721S1VKMAA', 'P4712ZM7XKAB', 'P7304ZJ3S4AD', 'P510517BFUCBO', 'P47081573ZFAU', 'P5101TSGFXAE', 'P7412UPR74AG', 'P471517X6X3AN', 'P7302ZSAXQBD', 'P510514RMQ1BY', 'P4712AJZJRAH', 'P7905MDJKEAI', 'P6916XKT3VDP', 'P51055N28BBR', 'P4704FFC0VAE', 'P470317M5J9AL', 'P511213W61NAK', 'P3227SQBP6BF', 'P3205AHZWBAA', 'P3016AHZW8AS', 'P3230DMS09AM', 'P3221AHZVGFH', 'P3307DUSZ7AO', 'P3608AHZWRAA', 'P322319N0SCE', 'P61011EN7TBS', 'P33011QBZMAB', 'P281313PWNAS', 'P2906140HBBE', 'P33021XRY1AW', 'P300284U21AO', 'P3101HXHE6AJ', 'P2913NUCA8AO', 'P3102TZA60AL', 'P3231JE2QEAA', 'P3309AHZV2AB', 'P32375PDBEBT', 'P3221A0XXNFK', 'P3226F8JJPAX', 'P3207951XBAX', 'P33246QJJ0AM', 'P3223UM7X1CC', 'P3101S6YYGAT', 'P3221DMXC7DN', 'P020619TZT9BF', 'P32077NDA2AK', 'P61161CTG9HAL', 'P32341DAQV8AB', 'P32341DBB13AK', 'PT32211U7XJ8EZ', 'PT32211UH3T8FN', 'P32261FGVMBBW', 'P64021F71W3BS', 'P64021F8NE5AZ', 'P13261FCDYWAK', 'P03051FH0YGBF', 'P64021FHV8SBI', 'P64021FE8DRBL', 'P04211F72W0AE', 'PT13021VFNJ7AF', 'PT16101VBHY0AJ', 'P13031FTJF0AQ', 'PT13111VJRC0BD', 'P64021FNZV7BL', 'P64131FMUQ1AD', 'P100011FHZD7AJ', 'P13271FXWQCAK', 'P16031FYZA0AG', 'P64021FHCD1DK', 'PT16041VRTS0AJ', 'P13031G9N1VBO', 'P13031G605UBQ', 'P16041FV05EAJ', 'P10011GCW2MAG', 'PT13301VYZN3AO', 'P03141G35FQBD', 'P03051G9R1GAX');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        de.dst_store_id = 'PH19040F05' -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.routed_at < t.created_at
                    and pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.dst_routed_at is not null
            and de.parcel_state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and de.dst_store_id != 'PH19040F05'  -- 目的地网点不是拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and de.parcel_state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 寄件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,de.dst_store 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join ph_staging.parcel_route pr on pr.pno = b.pno and pr.route_action = 'INVENTORY' and pr.routed_at >= date_add(curdate(), interval 8 hour)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,a.pack_no
    ,count(a.pno) over (partition by a.pack_no) num
from
    (
        select
            *
        from
            (
                select
                    plt.pno
                    ,psd.pack_no
                    ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                from ph_bi.parcel_lose_task plt
                left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                where
                    plt.updated_at >= '2023-03-01'
                    and plt.state = 6
                    and plt.duty_result = 1
            ) a
        where
            a.rk = 1
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct plt.id)
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27';
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,sum(plr.duty_ratio) jishu
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1
order by 2 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,sum(plr.duty_ratio)/100 jishu
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1
order by 2 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,ss.name 网点
    ,sum(plr.duty_ratio)/100 jishu
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2
order by 3 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,ss.name 网点
    ,count(plt.id) 技术
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2
order by 3 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,ss.name 网点
    ,count(plt.id) 技术
from ph_bi.parcel_lose_task plt
left join
    (
        select
            plr.lose_task_id
            ,plr.store_id
        from ph_bi.parcel_lose_responsible plr
        where
            plr.created_at >= '2023-03-01'
        group by 1,2
    ) plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2
order by 3 desc;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
   select
       a.*
   from
       (
            select
                plt.pno
                ,plr.store_id
                ,plt.id
                ,pr.routed_at
                ,row_number() over (partition by plt.id order by pr.routed_at desc ) rk
            from ph_bi.parcel_lose_task plt
            left join
                (
                    select
                        plr.lose_task_id
                        ,plr.store_id
                    from ph_bi.parcel_lose_responsible plr
                    where
                        plr.created_at >= '2023-03-01'
                    group by 1,2
                ) plr on plr.lose_task_id = plt.id
            left join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at < date_sub(plt.created_at, interval 8 hour)
            where
                plt.state = 6
                and plt.duty_result = 1
                and plt.created_at >= '2023-03-01'
                and plt.created_at < '2023-04-27'
                and plr.store_id in ('PH19280F01', 'PH61182U01', 'PH14010F00', 'PH19280400', 'PH61270401', 'PH61180400', 'PH14010400', 'PH18180200', 'PH14160300', 'PH52050800', 'PH74060200', 'PH18060200', 'PH18040100', 'PH14200300', 'PH21130100', 'PH61184403', 'PH64021N00', 'PH51050301', 'PH21020301')

       ) a
   where
       a.rk = 1
   group by 1,2,3
)
select
    t.store_id
    ,date(convert_tz(t.routed_at, '+00:00', '+08:00')) date_d
    ,t.id
    ,t.pno
from t;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
   select
       a.*
   from
       (
            select
                plt.pno
                ,plr.store_id
                ,plt.id
                ,pr.routed_at
                ,row_number() over (partition by plt.id order by pr.routed_at desc ) rk
            from ph_bi.parcel_lose_task plt
            left join
                (
                    select
                        plr.lose_task_id
                        ,plr.store_id
                    from ph_bi.parcel_lose_responsible plr
                    where
                        plr.created_at >= '2023-03-01'
                    group by 1,2
                ) plr on plr.lose_task_id = plt.id
            left join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at < date_sub(plt.created_at, interval 8 hour)
            where
                plt.state = 6
                and plt.duty_result = 1
                and plt.created_at >= '2023-03-01'
                and plt.created_at < '2023-04-27'
                and plr.store_id in ('PH19280F01', 'PH61182U01', 'PH14010F00', 'PH19280400', 'PH61270401', 'PH61180400', 'PH14010400', 'PH18180200', 'PH14160300', 'PH52050800', 'PH74060200', 'PH18060200', 'PH18040100', 'PH14200300', 'PH21130100', 'PH61184403', 'PH64021N00', 'PH51050301', 'PH21020301')

       ) a
   where
       a.rk = 1
   group by 1,2,3,4
)
select
    t.store_id
    ,date(convert_tz(t.routed_at, '+00:00', '+08:00')) date_d
    ,t.id
    ,t.pno
from t;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
   select
       a.*
   from
       (
            select
                plt.pno
                ,plr.store_id
                ,plt.id
                ,pr.routed_at
                ,row_number() over (partition by plt.id order by pr.routed_at desc ) rk
            from ph_bi.parcel_lose_task plt
            left join
                (
                    select
                        plr.lose_task_id
                        ,plr.store_id
                    from ph_bi.parcel_lose_responsible plr
                    where
                        plr.created_at >= '2023-03-01'
                    group by 1,2
                ) plr on plr.lose_task_id = plt.id
            left join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at < date_sub(plt.created_at, interval 8 hour)
            where
                plt.state = 6
                and plt.duty_result = 1
                and plt.created_at >= '2023-03-01'
                and plt.created_at < '2023-04-27'
                and plr.store_id in ('PH19280F01', 'PH61182U01', 'PH14010F00', 'PH19280400', 'PH61270401', 'PH61180400', 'PH14010400', 'PH18180200', 'PH14160300', 'PH52050800', 'PH74060200', 'PH18060200', 'PH18040100', 'PH14200300', 'PH21130100', 'PH61184403', 'PH64021N00', 'PH51050301', 'PH21020301')

       ) a
   where
       a.rk = 1
   group by 1,2,3,4,5
)
select
    t.store_id
    ,date(convert_tz(t.routed_at, '+00:00', '+08:00')) date_d
    ,t.id
    ,t.pno
from t;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
   select
       a.*
   from
       (
            select
                plt.pno
                ,plr.store_id
                ,plt.id
                ,pr.routed_at
                ,row_number() over (partition by plt.id order by pr.routed_at desc ) rk
            from ph_bi.parcel_lose_task plt
            left join
                (
                    select
                        plr.lose_task_id
                        ,plr.store_id
                    from ph_bi.parcel_lose_responsible plr
                    where
                        plr.created_at >= '2023-03-01'
                    group by 1,2
                ) plr on plr.lose_task_id = plt.id
            left join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at < date_sub(plt.created_at, interval 8 hour)
            where
                plt.state = 6
                and plt.duty_result = 1
                and plt.created_at >= '2023-03-01'
                and plt.created_at < '2023-04-27'
                and plr.store_id in ('PH19280F01', 'PH61182U01', 'PH14010F00', 'PH19280400', 'PH61270401', 'PH61180400', 'PH14010400', 'PH18180200', 'PH14160300', 'PH52050800', 'PH74060200', 'PH18060200', 'PH18040100', 'PH14200300', 'PH21130100', 'PH61184403', 'PH64021N00', 'PH51050301', 'PH21020301')

       ) a
   where
       a.rk = 1
   group by 1,2,3,4,5
)
select
    t.store_id
    ,ss.short_name
    ,date(convert_tz(t.routed_at, '+00:00', '+08:00')) date_d
    ,t.id
    ,t.pno
from t
left join ph_staging.sys_store ss on ss.id = t.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
   select
       a.*
   from
       (
            select
                plt.pno
                ,plr.store_id
                ,plt.id
                ,pr.routed_at
                ,row_number() over (partition by plt.id order by pr.routed_at desc ) rk
            from ph_bi.parcel_lose_task plt
            join
                (
                    select
                        plr.lose_task_id
                        ,plr.store_id
                    from ph_bi.parcel_lose_responsible plr
                    where
                        plr.created_at >= '2023-03-01'
                        and plr.store_id in ('PH19280F01', 'PH61182U01', 'PH14010F00', 'PH19280400', 'PH61270401', 'PH61180400', 'PH14010400', 'PH18180200', 'PH14160300', 'PH52050800', 'PH74060200', 'PH18060200', 'PH18040100', 'PH14200300', 'PH21130100', 'PH61184403', 'PH64021N00', 'PH51050301', 'PH21020301')
                    group by 1,2
                ) plr on plr.lose_task_id = plt.id
            left join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at < date_sub(plt.created_at, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
   select
       a.*
   from
       (
            select
                plt.pno
                ,plr.store_id
                ,plt.id
                ,pr.routed_at
                ,row_number() over (partition by plt.id order by pr.routed_at desc ) rk
            from ph_bi.parcel_lose_task plt
            join
                (
                    select
                        plr.lose_task_id
                        ,plr.store_id
                    from ph_bi.parcel_lose_responsible plr
                    where
                        plr.created_at >= '2023-03-01'
                        and plr.store_id in ('PH19280F01', 'PH61182U01', 'PH14010F00', 'PH19280400', 'PH61270401', 'PH61180400', 'PH14010400', 'PH18180200', 'PH14160300', 'PH52050800', 'PH74060200', 'PH18060200', 'PH18040100', 'PH14200300', 'PH21130100', 'PH61184403', 'PH64021N00', 'PH51050301', 'PH21020301')
                    group by 1,2
                ) plr on plr.lose_task_id = plt.id
            left join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at < date_sub(plt.created_at, interval 8 hour)
            where
                plt.state = 6
                and plt.duty_result = 1
                and plt.created_at >= '2023-03-01'
                and plt.created_at < '2023-04-27'
       ) a
   where
       a.rk = 1
   group by 1,2,3,4,5
)
select
    t.store_id
    ,ss.short_name
    ,date(convert_tz(t.routed_at, '+00:00', '+08:00')) date_d
    ,t.id
    ,t.pno
from t
left join ph_staging.sys_store ss on ss.id = t.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,count(plt.id)
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
where
     plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.client_id is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.id is null then '小c'
    end as  客户
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,count(plt.id)
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.dwd_dim_bigClient bc on pi.client_id=bc.client_id
left join ph_staging.ka_profile kp on .client_id=kp.id
where
     plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.client_id is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.id is null then '小c'
    end as  客户
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,count(plt.id)
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.dwd_dim_bigClient bc on pi.client_id=bc.client_id
left join ph_staging.ka_profile kp on pi.client_id=kp.id
where
     plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,ss.name 网点
    ,plr.staff_id
    ,sum(plr.duty_ratio)/100 jishu
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2,3
order by 4 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,ss.name 网点
    ,plr.staff_id
#     ,sum(plr.duty_ratio)/100 jishu
    ,count(plt.id) jishu
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2,3
order by 4 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,ss.name 网点
    ,plr.staff_id
    ,case
        when  hsi.`state`=1 and hsi.`wait_leave_state` =0 then '在职'
        when  hsi.`state`=1 and hsi.`wait_leave_state` =1 then '待离职'
        when hsi.`state` =2 then '离职'
        when hsi.`state` =3 then '停职'
    end 在职状态
    ,sum(plr.duty_ratio)/100 jishu
#     ,count(plt.id) jishu
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = plr.staff_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2,3,4
order by 5 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,ss.name 网点
    ,plr.staff_id
    ,case
        when  hsi.`state`=1 and hsi.`wait_leave_state` =0 then '在职'
        when  hsi.`state`=1 and hsi.`wait_leave_state` =1 then '待离职'
        when hsi.`state` =2 then '离职'
        when hsi.`state` =3 then '停职'
    end 在职状态
    ,sum(plr.duty_ratio)/100 jishu
#     ,count(plt.id) jishu
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
left join ph_backyard.hr_staff_info hsi on hsi.staff_info_id = plr.staff_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2,3,4
order by 5 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    plr.store_id
    ,ss.name 网点
    ,plr.staff_id
    ,case
        when  hsi.`state`=1 and hsi.`wait_leave_state` =0 then '在职'
        when  hsi.`state`=1 and hsi.`wait_leave_state` =1 then '待离职'
        when hsi.`state` =2 then '离职'
        when hsi.`state` =3 then '停职'
    end 在职状态
#     ,sum(plr.duty_ratio)/100 jishu
    ,count(plt.id) jishu
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
left join ph_backyard.hr_staff_info hsi on hsi.staff_info_id = plr.staff_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2,3,4
order by 5 desc;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    plt.pno
    ,plt.created_at
    ,plt.updated_at
    ,case
    when bc.client_id is not null then bc.client_name
    when kp.id is not null and bc.client_id is null then '普通ka'
    when kp.id is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,case pi2.article_category
         when 0 then '文件'
         when 1 then '干燥食品'
         when 2 then '日用品'
         when 3 then '数码产品'
         when 4 then '衣物'
         when 5 then '书刊'
         when 6 then '汽车配件'
         when 7 then '鞋包'
         when 8 then '体育器材'
         when 9 then '化妆品'
         when 10 then '家居用具'
         when 11 then '水果'
         when 99 then '其它'
        end as 物品类型
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 cod金额
    ,if(pi2.cod_enabled = 1, 'y')
    ,case plt.last_valid_action
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as  最后一个有效路由
    ,ss.name 丢失包裹所在网点
    ,case
        when ss.category=1 then 'SP'
        when ss.category=2 then 'DC'
        when ss.category=4 then 'SHOP'
        when ss.category=5 then 'SHOP'
        when ss.category=6 then 'FH'
        when ss.category=7 then 'SHOP'
        when ss.category=8 then 'Hub'
        when ss.category=9 then 'Onsite'
        when ss.category=10 then 'BDC'
        when ss.category=11 then 'fulfillment'
        when ss.category=12 then 'B-HUB'
        when ss.category=13 then 'CDC'
        when ss.category=14 then 'PDC'
    end 网点类型
    ,plt.last_valid_staff_info_id 最后操作快递员
    ,case plt.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end '来源'
    ,case plt.duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓7主3套餐(仓管70%主管30%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 21 then '仓7主3套餐(仓管70%主管30%)'
    end 套餐
    ,t.t_value 原因
from ph_bi.parcel_lose_task plt
left join ph_staging.sys_store ss on plt.last_valid_store_id =ss.id
left join ph_drds.lazada_order_info_d loi on plt.pno=loi.pno
left join ph_staging.order_info oi on plt.pno=oi.pno
left join dwm.dwd_dim_bigClient bc on oi.client_id=bc.client_id
left join ph_staging.ka_profile kp on oi.client_id=kp.id
left join ph_staging.parcel_info pi2 on plt.pno=pi2.pno
left join ph_bi.translations t on plt.duty_reasons=t.t_key
where
    plt.state=6
    and plt.duty_result=1
    and plt.updated_at >= '2023-03-01'
    and plt.updated_at < '2023-04-27'
    and t.lang = 'zh-CN';
;-- -. . -..- - / . -. - .-. -.--
SELECT
    plt.pno
    ,plt.created_at
    ,plt.updated_at
    ,case
    when bc.client_id is not null then bc.client_name
    when kp.id is not null and bc.client_id is null then '普通ka'
    when kp.id is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,case pi2.article_category
         when 0 then '文件'
         when 1 then '干燥食品'
         when 2 then '日用品'
         when 3 then '数码产品'
         when 4 then '衣物'
         when 5 then '书刊'
         when 6 then '汽车配件'
         when 7 then '鞋包'
         when 8 then '体育器材'
         when 9 then '化妆品'
         when 10 then '家居用具'
         when 11 then '水果'
         when 99 then '其它'
        end as 物品类型
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 cod金额
    ,if(pi2.cod_enabled = 1, 'y')
    ,case plt.last_valid_action
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as  最后一个有效路由
    ,ss.name 丢失包裹所在网点
    ,case
        when ss.category=1 then 'SP'
        when ss.category=2 then 'DC'
        when ss.category=4 then 'SHOP'
        when ss.category=5 then 'SHOP'
        when ss.category=6 then 'FH'
        when ss.category=7 then 'SHOP'
        when ss.category=8 then 'Hub'
        when ss.category=9 then 'Onsite'
        when ss.category=10 then 'BDC'
        when ss.category=11 then 'fulfillment'
        when ss.category=12 then 'B-HUB'
        when ss.category=13 then 'CDC'
        when ss.category=14 then 'PDC'
    end 网点类型
    ,plt.last_valid_staff_info_id 最后操作快递员
    ,case plt.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end '来源'
    ,case plt.duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓7主3套餐(仓管70%主管30%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 21 then '仓7主3套餐(仓管70%主管30%)'
    end 套餐
    ,t.t_value 原因
from ph_bi.parcel_lose_task plt
left join ph_staging.sys_store ss on plt.last_valid_store_id =ss.id
left join ph_drds.lazada_order_info_d loi on plt.pno=loi.pno
left join ph_staging.order_info oi on plt.pno=oi.pno
left join dwm.dwd_dim_bigClient bc on oi.client_id=bc.client_id
left join ph_staging.ka_profile kp on oi.client_id=kp.id
left join ph_staging.parcel_info pi2 on plt.pno=pi2.pno
left join ph_bi.translations t on plt.duty_reasons=t.t_key
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
    and t.lang = 'zh-CN';
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.pack_no
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

select
    a.pno
    ,a2.ratio
from a
left join
    (
        select
            psd.pack_no
            ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
        from ph_staging.pack_seal_detail psd
        join
            (
                select
                    a.pack_no
                from a
                group by 1
            ) a1 on a1.pack_no = psd.pack_no
        left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
        group by 1
    ) a2 on a2.pack_no = a.pack_no;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.pack_no
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

select
    a.pno
    ,a2.ratio
    ,a2.seal_num
from a
left join
    (
        select
            psd.pack_no
            ,count(psd.pno) seal_num
            ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
        from ph_staging.pack_seal_detail psd
        join
            (
                select
                    a.pack_no
                from a
                group by 1
            ) a1 on a1.pack_no = psd.pack_no
        left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
        group by 1
    ) a2 on a2.pack_no = a.pack_no;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.pack_no
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

select
    a.pno
    ,a2.pack_no
    ,a2.ratio
    ,a2.seal_num
from a
left join
    (
        select
            psd.pack_no
            ,count(psd.pno) seal_num
            ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
        from ph_staging.pack_seal_detail psd
        join
            (
                select
                    a.pack_no
                from a
                group by 1
            ) a1 on a1.pack_no = psd.pack_no
        left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
        group by 1
    ) a2 on a2.pack_no = a.pack_no;
;-- -. . -..- - / . -. - .-. -.--
select
    hsi.staff_info_id
    ,hjt.job_name
from ph_bi.hr_staff_info hsi
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
where
    hsi.staff_info_id in ('120072', '134656', '132744', '144666', '123400', '138407', '144975', '146865', '125021', '132436', '128244', '120282', '147272', '146520', '145591', '145390', '131781', '149451', '146585', '122107', '138260', '124441', '142557', '133522', '147945', '132907', '119081', '147515', '119462', '135354', '150011', '135692', '146286', '125532', '133963', '148714', '134748', '141232', '147729', '139155', '131707', '148013', '140774', '123612', '129538', '123370', '119279', '135323');
;-- -. . -..- - / . -. - .-. -.--
select
    hsi.staff_info_id
    ,hjt.job_name
from ph_bi.hr_staff_info hsi
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
where
    hsi.staff_info_id in ('122045', '123109', '136875', '131888', '126146', '135814', '139915', '126295', '121862', '139548', '146160', '126298', '124824', '138330', '133128', '138072', '132653', '131546', '134129', '126554', '139332', '138177', '138416', '135259', '125453', '137715', '134042', '133699', '134773', '134040', '137721', '126308', '136759', '124969', '136043', '136435', '132455', '124821', '138385', '145375', '140081', '139920', '136217', '125133', '140921', '124968', '140079', '124840');
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.pack_no
        ,a.last_valid_store_id
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,plt.last_valid_store_id
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

select
    ss.name
    ,count(distinct a.pack_no) 丢失集包数
    ,count(distinct a.pno) 丢失包裹数
from a
left join
    (
        select
            psd.pack_no
            ,count(psd.pno) seal_num
            ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
        from ph_staging.pack_seal_detail psd
        join
            (
                select
                    a.pack_no
                from a
                group by 1
            ) a1 on a1.pack_no = psd.pack_no
        left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
        group by 1
    ) a2 on a2.pack_no = a.pack_no
left join ph_staging.sys_store ss on ss.id = a.last_valid_store_id
where
    a2.ratio > 0.7
    and a2.seal_num > 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.pack_no
        ,a.last_valid_store_id
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,plt.last_valid_store_id
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

select
    ss.name
    ,count(distinct a.pack_no) 丢失集包数
    ,count(distinct a.pno) 丢失包裹数
from a
left join
    (
        select
            psd.pack_no
            ,count(psd.pno) seal_num
            ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
        from ph_staging.pack_seal_detail psd
        join
            (
                select
                    a.pack_no
                from a
                group by 1
            ) a1 on a1.pack_no = psd.pack_no
        left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
        group by 1
    ) a2 on a2.pack_no = a.pack_no
left join ph_staging.sys_store ss on ss.id = a.last_valid_store_id
where
    a2.ratio = 1
    and a2.seal_num > 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.pack_no
        ,a.last_valid_store_id
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,plt.last_valid_store_id
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

select
    ss.name
    ,count(distinct a.pack_no) 丢失集包数
    ,sum(a2.seal_num) 丢失包裹数
from a
left join
    (
        select
            psd.pack_no
            ,count(psd.pno) seal_num
            ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
        from ph_staging.pack_seal_detail psd
        join
            (
                select
                    a.pack_no
                from a
                group by 1
            ) a1 on a1.pack_no = psd.pack_no
        left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
        group by 1
    ) a2 on a2.pack_no = a.pack_no
left join ph_staging.sys_store ss on ss.id = a.last_valid_store_id
where
    a2.ratio = 1
    and a2.seal_num > 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.pack_no
        ,a.last_valid_store_id
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,plt.last_valid_store_id
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

# select
#     ss.name
#     ,count(distinct a.pack_no) 丢失集包数
#     ,sum(a2.seal_num) 丢失包裹数
# from a
# left join
#     (
        select
            psd.pack_no
            ,count(psd.pno) seal_num
            ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
        from ph_staging.pack_seal_detail psd
        join
            (
                select
                    a.pack_no
                from a
                group by 1
            ) a1 on a1.pack_no = psd.pack_no
        left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.pack_no
        ,a.last_valid_store_id
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,plt.last_valid_store_id
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

select
    ss.name
    ,count(distinct a.pack_no) 丢失集包数
    ,sum(a2.seal_num) 丢失包裹数
from a
join
    (
        select
            psd.pack_no
            ,count(psd.pno) seal_num
            ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
        from ph_staging.pack_seal_detail psd
        join
            (
                select
                    a.pack_no
                from a
                group by 1
            ) a1 on a1.pack_no = psd.pack_no
        left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
        group by 1
    ) a2 on a2.pack_no = a.pack_no
left join ph_staging.sys_store ss on ss.id = a.last_valid_store_id
where
    a2.ratio = 1
    and a2.seal_num > 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.pack_no
        ,a.last_valid_store_id
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,plt.last_valid_store_id
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

select
    b.name
    ,count(distinct b.pack_no) 丢失集包数
    ,count(distinct b.pno) 丢失包裹数
from
    (
                select
            a.pno
            ,a2.pack_no
            ,ss.name
            ,a2.ratio
            ,a2.seal_num
        from a
        left join
            (
                select
                    psd.pack_no
                    ,count(psd.pno) seal_num
                    ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
                from ph_staging.pack_seal_detail psd
                join
                    (
                        select
                            a.pack_no
                        from a
                        group by 1
                    ) a1 on a1.pack_no = psd.pack_no
                left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
                group by 1
            ) a2 on a2.pack_no = a.pack_no
        left join ph_staging.sys_store ss on ss.id = a.last_valid_store_id
        where
            a2.ratio = 1
            and a2.seal_num > 1
    ) b
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        a.pno
        ,a.pack_no
        ,a.last_valid_store_id
    from
        (
            select
                *
            from
                (
                    select
                        plt.pno
                        ,plt.last_valid_store_id
                        ,psd.pack_no
                        ,row_number() over (partition by plt.pno order by psd.created_at desc) rk
                    from ph_bi.parcel_lose_task plt
                    left join ph_staging.pack_seal_detail psd on psd.pno = plt.pno
                    where
                        plt.created_at >= '2023-03-01'
                        and plt.created_at < '2023-04-27'
                        and plt.state = 6
                        and plt.duty_result = 1
                ) a
            where
                a.rk = 1
        ) a

)

        select
            a.pno
            ,a2.pack_no
            ,ss.name
            ,a2.ratio
            ,a2.seal_num
        from a
        left join
            (
                select
                    psd.pack_no
                    ,count(psd.pno) seal_num
                    ,count(if(plt.pno is not null , psd.pno, null))/count(psd.pno) ratio
                from ph_staging.pack_seal_detail psd
                join
                    (
                        select
                            a.pack_no
                        from a
                        group by 1
                    ) a1 on a1.pack_no = psd.pack_no
                left join ph_bi.parcel_lose_task plt on plt.pno = psd.pno and plt.state = 6 and plt.duty_result = 1
                group by 1
            ) a2 on a2.pack_no = a.pack_no
        left join ph_staging.sys_store ss on ss.id = a.last_valid_store_id
        where
            a2.ratio = 1
            and a2.seal_num > 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        de.dst_store_id = 'PH19040F05' -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.routed_at < t.created_at
                    and pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.dst_routed_at is not null
            and de.parcel_state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and de.dst_store_id != 'PH19040F05'  -- 目的地网点不是拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 寄件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,de.dst_store 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join ph_staging.parcel_route pr on pr.pno = b.pno and pr.route_action = 'INVENTORY' and pr.routed_at >= date_add(curdate(), interval 8 hour)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        de.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.routed_at < t.created_at
                    and pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and de.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 寄件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,de.dst_store 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        de.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.routed_at < t.created_at
                    and pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and de.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 寄件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,de.dst_store 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.routed_at < t.created_at
                    and pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 寄件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.routed_at < t.created_at
                    and pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 寄件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and pi.pno = 'P1904TZZ96AO'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.dst_detail_address 收件人地址
    ,pd.last_valid_action 最后一条有效路由
    ,pd.last_valid_store_id 最后有效路由操作网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0504 t on t.pno = pi.pno
left join ph_bi.parcel_detail pd on pd.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.dst_detail_address 收件人地址
    ,case pd.last_valid_action
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一条有效路由
    ,pd.last_valid_store_id 最后有效路由操作网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0504 t on t.pno = pi.pno
left join ph_bi.parcel_detail pd on pd.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
elect
    pi.pno
    ,pi.dst_detail_address 收件人地址
    ,case pd.last_valid_action
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一条有效路由
    ,ss.name 最后有效路由操作网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0504 t on t.pno = pi.pno
left join ph_bi.parcel_detail pd on pd.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pd.last_valid_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.dst_detail_address 收件人地址
    ,case pd.last_valid_action
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一条有效路由
    ,ss.name 最后有效路由操作网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0504 t on t.pno = pi.pno
left join ph_bi.parcel_detail pd on pd.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pd.last_valid_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.dst_detail_address 收件人地址
    ,seal.pack_no
    ,case pr.route_action
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一条有效路由
    ,ss.name 最后有效路由操作网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0504 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.store_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0504 t on t.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = pi.pno and pr.rk = 1
left join ph_staging.sys_store ss on ss.id = pr.store_id
left join
    (
        select
            psd.pno
            ,psd.pack_no
            ,row_number() over (partition by psd.pno order by psd.created_at desc ) rk
        from ph_staging.pack_seal_detail psd
        join tmpale.tmp_ph_pno_lj_0504 t on t.pno = psd.pno
    ) seal on seal.pno = pi.pno and seal.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.routed_at < t.created_at
                    and pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
left join ph_staging.sys_store ss on ss.name = b.store
where
    pi.state not in (5,7,8,9)
    and ss.category not in (8,12)
#     and pi.pno = 'P1904TZZ96AO'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.routed_at < t.created_at
                    and pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P1904TZZ96AO'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from dw_dmd.parcel_store_stage_new pssn
where
    pssn.van_arrived_at >= date_sub(curdate(), interval 32 hour )
    and pssn.van_arrived_at < date_sub(curdate(), interval 8 hour)
    and pssn.arrival_pack_no is not null
    and pssn.van_arrived_at is null;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.id
from
ph_bi.parcel_claim_task pct
left join
    (
        select
            pcol.task_id
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
        where
            pct.created_at >= '2023-05-01'
            and pcol.action in (21,7)
        group by 1
    ) pcol on pct.id = pcol.task_id
where
    pct.created_at >= '2023-05-01'
    and pcol.task_id is null;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.id
    ,pct.pno
from
ph_bi.parcel_claim_task pct
left join
    (
        select
            pcol.task_id
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
        where
            pct.created_at >= '2023-05-01'
            and pcol.action in (21,7)
        group by 1
    ) pcol on pct.id = pcol.task_id
where
    pct.created_at >= '2023-05-01'
    and pcol.task_id is null;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.id
    ,pct.pno
    ,pct.state
from
ph_bi.parcel_claim_task pct
left join
    (
        select
            pcol.task_id
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
        where
            pct.created_at >= '2023-05-01'
            and pcol.action in (21,7)
        group by 1
    ) pcol on pct.id = pcol.task_id
where
    pct.created_at >= '2023-05-01'
    and pcol.task_id is null;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.id
    ,pct.pno
    ,pct.state
from
ph_bi.parcel_claim_task pct
left join
    (
        select
            pcol.task_id
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
        where
            pct.created_at >= '2023-04-01'
            and pcol.action in (21,7)
        group by 1
    ) pcol on pct.id = pcol.task_id
where
    pct.created_at >= '2023-04-01'
    and pcol.task_id is null
    and pct.state > 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.id
    ,pct.pno
    ,pct.state
from
ph_bi.parcel_claim_task pct
left join
    (
        select
            pcol.task_id
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
        where
            pct.created_at >= '2023-01-01'
            and pct.state = 6
            and pcol.action in (21,7)
        group by 1
    ) pcol on pct.id = pcol.task_id
where
    pct.created_at >= '2023-01-01'
    and pcol.task_id is null
    and pct.state = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.id
    ,pct.pno
    ,pcol2.operator_id
from ph_bi.parcel_claim_task pct
left join
    (
        select
            pcol.task_id
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
        where
            pct.created_at >= '2023-01-01'
            and pct.state = 6
            and pcol.action in (21,7)
        group by 1
    ) pcol on pct.id = pcol.task_id
left join ph_bi.parcel_cs_operation_log pcol2 on pcol2.task_id = pct.id and pcol2.action in (14,12)
where
    pct.created_at >= '2023-01-01'
    and pcol.task_id is null
    and pct.state = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.id
    ,pct.pno
    ,group_concat(pcol2.operator_id) 操作人员
from ph_bi.parcel_claim_task pct
left join
    (
        select
            pcol.task_id
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
        where
            pct.created_at >= '2023-01-01'
            and pct.state = 6
            and pcol.action in (21,7)
        group by 1
    ) pcol on pct.id = pcol.task_id
left join ph_bi.parcel_cs_operation_log pcol2 on pcol2.task_id = pct.id and pcol2.action in (14,12)
where
    pct.created_at >= '2023-01-01'
    and pcol.task_id is null
    and pct.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.id
    ,pct.pno
    ,pcol2.operator_id 操作人员
from ph_bi.parcel_claim_task pct
left join
    (
        select
            pcol.task_id
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
        where
            pct.created_at >= '2023-01-01'
            and pct.state = 6
            and pcol.action in (21,7)
        group by 1
    ) pcol on pct.id = pcol.task_id
left join ph_bi.parcel_cs_operation_log pcol2 on pcol2.task_id = pct.id and pcol2.action in (14)
where
    pct.created_at >= '2023-01-01'
    and pcol.task_id is null
    and pct.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select * from tmpale.tmp_ph_pno_lj_0506;
;-- -. . -..- - / . -. - .-. -.--
select
            psd.pno
            ,psd.pack_no
            ,row_number() over (partition by psd.pno order by psd.created_at desc ) rk
        from ph_staging.pack_seal_detail psd
        join tmpale.tmp_ph_pno_lj_0506 t on t.pno = psd.pno;
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.route_action
            ,pr.store_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0506 t on t.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL');
;-- -. . -..- - / . -. - .-. -.--
select
    min(pi.created_at)
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0506 t on t.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.dst_detail_address 收件人地址
    ,seal.pack_no
    ,case pr.route_action
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一条有效路由
    ,ss.name 最后有效路由操作网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0506 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.store_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0506 t on t.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = pi.pno and pr.rk = 1
left join ph_staging.sys_store ss on ss.id = pr.store_id
left join
    (
        select
            psd.pno
            ,psd.pack_no
            ,row_number() over (partition by psd.pno order by psd.created_at desc ) rk
        from ph_staging.pack_seal_detail psd
        join tmpale.tmp_ph_pno_lj_0506 t on t.pno = psd.pno
    ) seal on seal.pno = pi.pno and seal.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
select
    a.pno
    ,a.date_d
from a
left join
    (
        select
            pr2.pno
            ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        from ph_staging.parcel_route pr2
        join
            (
                select a.pno from a group by 1
            ) b on pr2.pno = b.pno
        where
            pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr2.routed_at >= '2023-03-31 16:00:00'
    ) b on a.pno = b.pno and a.date_d = b.date_d;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
select
    a.pno
    ,a.date_d
from a
left join
    (
        select
            pr2.pno
            ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        from ph_staging.parcel_route pr2
        join
            (
                select a.pno from a group by 1
            ) b on pr2.pno = b.pno
        where
            pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr2.routed_at >= '2023-03-31 16:00:00'
        group by 1,2
    ) b on a.pno = b.pno and a.date_d = b.date_d;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
select
    a.pno
    ,a.date_d
from a
join
    (
        select
            pr2.pno
            ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        from ph_staging.parcel_route pr2
        join
            (
                select a.pno from a group by 1
            ) b on pr2.pno = b.pno
        where
            pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr2.routed_at >= '2023-03-31 16:00:00'
        group by 1,2
    ) b on a.pno = b.pno and a.date_d = b.date_d;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
select
    a.pno
    ,a.date_d
from a
join
    (
        select
            pr2.pno
            ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        from ph_staging.parcel_route pr2
        join
            (
                select a.pno from a group by 1
            ) b on pr2.pno = b.pno
        where
            pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr2.routed_at >= '2023-03-31 16:00:00'
        group by 1,2
    ) b on a.pno = b.pno and a.date_d = b.date_d
left join ph_staging.parcel_info pi on pi.pno = a.pno
where
    pi.state != 7;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
select
    a.pno
    ,a.date_d
from a
join
    (
        select
            pr2.pno
            ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        from ph_staging.parcel_route pr2
        join
            (
                select a.pno from a group by 1
            ) b on pr2.pno = b.pno
        where
            pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr2.routed_at >= '2023-03-31 16:00:00'
        group by 1,2
    ) b on a.pno = b.pno and a.date_d = b.date_d
left join ph_staging.parcel_info pi on pi.pno = a.pno
where
    pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
        ,pr.store_id
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
, b as
(
    select
        pr2.pno
        ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        ,pr2.staff_info_id
    from ph_staging.parcel_route pr2
    join
        (
            select a.pno from a group by 1
        ) b on pr2.pno = b.pno
    where
        pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr2.routed_at >= '2023-03-31 16:00:00'
)
select
    a.pno 包裹
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.cod_amount/100 COD金额
    ,group_concat(b2.staff_info_id) 交接员工id
from a
join
    (
        select
            b.pno
            ,b.date_d
        from b
        group by 1,2
    ) b on a.pno = b.pno and a.date_d = b.date_d
left join ph_staging.parcel_info pi on pi.pno = a.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join b b2 on b2.pno = a.pno and b2.date_d = a.date_d
where
    pi.state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
        ,pr.store_id
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
, b as
(
    select
        pr2.pno
        ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        ,pr2.staff_info_id
    from ph_staging.parcel_route pr2
    join
        (
            select a.pno from a group by 1
        ) b on pr2.pno = b.pno
    where
        pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr2.routed_at >= '2023-03-31 16:00:00'
)
select
    a.pno 包裹
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.cod_amount/100 COD金额
    ,group_concat(b2.staff_info_id) 交接员工id
from a
join
    (
        select
            b.pno
            ,b.date_d
        from b
        group by 1,2
    ) b on a.pno = b.pno and a.date_d = b.date_d
left join ph_staging.parcel_info pi on pi.pno = a.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join b b2 on b2.pno = a.pno and b2.date_d = a.date_d
where
    pi.state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
        ,pr.store_id
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
, b as
(
    select
        pr2.pno
        ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        ,pr2.staff_info_id
    from ph_staging.parcel_route pr2
    join
        (
            select a.pno from a group by 1
        ) b on pr2.pno = b.pno
    where
        pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr2.routed_at >= '2023-03-31 16:00:00'
)
select
    a.pno 包裹
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.cod_amount/100 COD金额
    ,group_concat(distinct b2.staff_info_id) 交接员工id
from a
join
    (
        select
            b.pno
            ,b.date_d
        from b
        group by 1,2
    ) b on a.pno = b.pno and a.date_d = b.date_d
left join ph_staging.parcel_info pi on pi.pno = a.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join b b2 on b2.pno = a.pno and b2.date_d = a.date_d
where
    pi.state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
, b as
(
    select
        pr2.pno
        ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        ,pr2.staff_info_id
        ,pr2.store_id
    from ph_staging.parcel_route pr2
    join
        (
            select a.pno from a group by 1
        ) b on pr2.pno = b.pno
    where
        pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr2.routed_at >= '2023-03-31 16:00:00'
)
select
    a.pno 包裹
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.cod_amount/100 COD金额
    ,group_concat(distinct b2.staff_info_id) 交接员工id
from a
join
    (
        select
            b.pno
            ,b.date_d
            ,b.store_id
        from b
        group by 1,2,3
    ) b on a.pno = b.pno and a.date_d = b.date_d
left join ph_staging.parcel_info pi on pi.pno = a.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join b b2 on b2.pno = a.pno and b2.date_d = a.date_d
where
    pi.state not in (5,7,8,9)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
, b as
(
    select
        pr2.pno
        ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        ,pr2.staff_info_id
        ,pr2.store_id
    from ph_staging.parcel_route pr2
    join
        (
            select a.pno from a group by 1
        ) b on pr2.pno = b.pno
    where
        pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr2.routed_at >= '2023-03-31 16:00:00'
)
select
    a.pno 包裹
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.cod_amount/100 COD金额
    ,group_concat(distinct b2.staff_info_id) 交接员工id
from a
join
    (
        select
            b.pno
            ,b.date_d
            ,b.store_id
        from b
        group by 1,2,3
    ) b on a.pno = b.pno and a.date_d = b.date_d
left join ph_staging.parcel_info pi on pi.pno = a.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join b b2 on b2.pno = a.pno and b2.date_d = a.date_d
where
    pi.state not in (5,7,8,9)
    and a.date_d < curdate()
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pcol.task_id
        ,pcol.action
        ,pcol.operator_id
        ,pcol.created_at
    from ph_bi.parcel_claim_task pct
    left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
    where
        pct.created_at >= '2023-01-01'
        and pct.state = 6
)

select
    pct.id 理赔任务ID
    ,pct.pno 单号
    ,json_extract(pcn.neg_result,'$.money') 理赔金额
    ,t4.created_at 电话号码不对时间
    ,t5.created_at 客户不接电话时间
    ,t1.created_at 待重新协商时间
    ,t2.created_at 审核通过时间
    ,t2.operator_id 审核通过员工
    ,t3.created_at 已联系时间
    ,t3.created_at 已联系员工
from ph_bi.parcel_claim_task pct
left join
    (
        select
            pcn.task_id
            ,pcn.neg_result
            ,row_number() over (partition by pcn.task_id order by pcn.created_at desc ) rk
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.created_at >= '2023-01-01'
            and pct.state = 6
    ) pcn on pcn.task_id = pct.id and pcn.rk = 1
left join t t1 on t1.task_id = pct.id and t1.action = 7 -- 待重新协商
left join t t2 on t2.task_id = pct.id and t2.action = 14 -- 审核通过
left join t t3 on t3.task_id = pct.id and t3.action = 21 -- 已联系
left join t t4 on t4.task_id = pct.id and t4.action = 19 -- 电话号码不对
left join t t5 on t5.task_id = pct.id and t5.action = 18 -- 客户不接电话
where
    pct.created_at >= '2023-01-01'
    and pct.state = 6;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pcol.task_id
        ,pcol.action
        ,pcol.operator_id
        ,pcol.created_at
    from ph_bi.parcel_claim_task pct
    left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
    where
        pct.created_at >= '2023-01-01'
        and pct.state = 6
)

select
    pct.id 理赔任务ID
    ,pct.pno 单号
    ,json_unquote(json_extract(pcn.neg_result,'$.money')) 理赔金额
    ,t4.created_at 电话号码不对时间
    ,t5.created_at 客户不接电话时间
    ,t1.created_at 待重新协商时间
    ,t2.created_at 审核通过时间
    ,t2.operator_id 审核通过员工
    ,t3.created_at 已联系时间
    ,t3.created_at 已联系员工
from ph_bi.parcel_claim_task pct
left join
    (
        select
            pcn.task_id
            ,pcn.neg_result
            ,row_number() over (partition by pcn.task_id order by pcn.created_at desc ) rk
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.created_at >= '2023-01-01'
            and pct.state = 6
    ) pcn on pcn.task_id = pct.id and pcn.rk = 1
left join t t1 on t1.task_id = pct.id and t1.action = 7 -- 待重新协商
left join t t2 on t2.task_id = pct.id and t2.action = 14 -- 审核通过
left join t t3 on t3.task_id = pct.id and t3.action = 21 -- 已联系
left join t t4 on t4.task_id = pct.id and t4.action = 19 -- 电话号码不对
left join t t5 on t5.task_id = pct.id and t5.action = 18 -- 客户不接电话
where
    pct.created_at >= '2023-01-01'
    and pct.state = 6;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pcol.task_id
        ,pcol.action
        ,pcol.operator_id
        ,pcol.created_at
    from ph_bi.parcel_claim_task pct
    left join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = pct.id and pcol.type = 2
    where
        pct.created_at >= '2023-01-01'
        and pct.state = 6
)

select
    pct.id 理赔任务ID
    ,pct.client_id 客户ID
    ,pct.pno 单号
    ,json_unquote(json_extract(pcn.neg_result,'$.money')) 理赔金额
    ,t4.created_at 电话号码不对时间
    ,t5.created_at 客户不接电话时间
    ,t1.created_at 待重新协商时间
    ,t2.created_at 审核通过时间
    ,t2.operator_id 审核通过员工
    ,t3.created_at 已联系时间
    ,t3.created_at 已联系员工
from ph_bi.parcel_claim_task pct
left join
    (
        select
            pcn.task_id
            ,pcn.neg_result
            ,row_number() over (partition by pcn.task_id order by pcn.created_at desc ) rk
        from ph_bi.parcel_claim_task pct
        left join ph_bi.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.created_at >= '2023-01-01'
            and pct.state = 6
    ) pcn on pcn.task_id = pct.id and pcn.rk = 1
left join t t1 on t1.task_id = pct.id and t1.action = 7 -- 待重新协商
left join t t2 on t2.task_id = pct.id and t2.action = 14 -- 审核通过
left join t t3 on t3.task_id = pct.id and t3.action = 21 -- 已联系
left join t t4 on t4.task_id = pct.id and t4.action = 19 -- 电话号码不对
left join t t5 on t5.task_id = pct.id and t5.action = 18 -- 客户不接电话
where
    pct.created_at >= '2023-01-01'
    and pct.state = 6;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P1904TZZ96AO'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
#     and dp.store_category not in (8,12)
    and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,pi.cod_amount/100 cod_amount
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
where
    de.dst_routed_at < date_sub(curdate(), interval 2 day )
    and de.cod_enabled = 'YES'
    and de.parcel_state not in (5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
set @begin_time = '2023-05-01';
;-- -. . -..- - / . -. - .-. -.--
set @end_time = '2023-05-08';
;-- -. . -..- - / . -. - .-. -.--
set @begin_time = '2023-05-01'
 @end_time = '2023-05-08';
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pi.pno
            ,pi.client_id
            ,pi2.ticket_pickup_store_id
            ,ss.name as ticket_pickup_store_name
            ,convert_tz(pi2.created_at, '+00:00', '+08:00') 退件时间
        from ph_staging.parcel_info pi
        join ph_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
        join ph_staging.sys_store ss on ss.id =pi2.ticket_pickup_store_id
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
        where
            pi.state = 7
            and pi2.created_at >=date_sub(current_date,interval 37 day)
            and pi2.created_at < current_time
    )

select
    t.pno
    ,t.ticket_pickup_store_name
    ,pr.store_name
    ,pr.staff_info_id
    ,pr.staff_info_name
    ,pr.remark 待退件备注
    ,mark.remark 最后一次包裹备注
    ,job_name 职位
    ,sd.name 部门
    ,case
        when xs.pno is not null then '协商退件'
        when di.pno is not null and xs.pno is null then '拒收直接退回'
#       when xs.pno is null and di.pno is null and (pcr.remark != 'Wait for replace order and return' or dai.pno is not null ) then '三次派送失败退件'
        when xs.pno is null and di.pno is null and sd.name in ('Flash Express Customer Service','Overseas Business Project') then 'MS操作中断运输并退回'
        when xs.pno is null and di.pno is null and pr.staff_info_id in ('10000','10001') then '三次派送失败退件'
        end 退件原因
    ,if(di2.pno is not null , '是', '否') 是否有收件人拒收派件标记
    ,dai.delivery_attempt_num 尝试派送天数
    ,t.退件时间
    ,ssd.sla as 时效天数
    ,ssd.end_date as 包裹普通超时时效截止日_整体
    ,ssd.end_7_date as 包裹严重超时时效截止日_整体
#     ,if(xs.pno is not null, 'y', 'n') 是否协商退件
#     ,if(di.pno is not null and xs.pno is null , 'y', 'n') 是否策略直接退回
#     ,if(xs.pno is null and di.pno is null and (pcr.remark != 'Wait for replace order and return' or dai.pno is not null ), '三次派送失败退件', 'MS操作中断运输并退回') 是否尝试三次派送失败退件
from t
left join
    (
        select
            di.pno
            ,cdt.operator_id
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        where
            cdt.negotiation_result_category in (3,4)
            and cdt.operator_id not in ('10000','10001')
        group by 1
    ) xs on xs.pno = t.pno
left join
    (
        select
            di.pno
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        left join ph_staging.ka_profile kp on kp.id = t.client_id
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        where
            di.diff_marker_category in (2,17)
            and kp.reject_return_strategy_category = 2 -- 退件策略：直接退回
            and cdt.negotiation_result_category in (3,4)
            and cdt.operator_id in ('10000','10001')
        group by 1
    ) di on di.pno = t.pno
# left join
#     (
#         select
#             pcr.pno
#             ,pcr.remark
#         from ph_staging.parcel_change_record pcr
#         join t on t.pno = pcr.pno
#         where
#             pcr.change_type = 0
#     ) pcr on pcr.pno = t.pno
left join
    (
        select
            dai.pno
            ,dai.delivery_attempt_num
        from ph_staging.delivery_attempt_info dai
        join t on dai.pno = t.pno
        where
            dai.delivery_attempt_num >= 3
    ) dai on dai.pno = t.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on ssd.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
             ,pr.store_name
            ,pr.staff_info_name
            ,pr.remark
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.pno
        where
            pr.route_action = 'PENDING_RETURN'
    ) pr on pr.pno = t.pno and pr.rn = 1
left join
    (
        select
            td.pno
        from ph_staging.ticket_delivery_marker tdm
        left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
        join t on td.pno = t.pno
        where
            tdm.marker_id in (2,17)
        group by 1
    ) di2 on di2.pno = t.pno
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_bi.sys_department sd on sd.id = hsi.sys_department_id
left join
    (
        select
            pr.pno
            ,pr.remark
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn2
        from ph_staging.parcel_route pr
        join t on pr.pno = t.pno
        where
            pr.route_action = 'MANUAL_REMARK'
    ) mark on mark.pno = t.pno and mark.rn2 = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    count(*)
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
            ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    ) a
where
    a.parcel_value > 10000;
;-- -. . -..- - / . -. - .-. -.--
select
    count(*)
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
            ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    ) a
where
    a.parcel_value > 20000;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
            ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    a.ticket_pickup_store_id
    ,count(a.pno)
from a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
            ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    a.ticket_pickup_store_id
    ,count(a.pno)
from a
where
    a.parcel_value > 10000
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
            ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno)
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
where
    a.parcel_value > 10000
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
            ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno)
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
where
    a.parcel_value > 20000
group by 1
order by 2 desc;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno)
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
where
    a.parcel_value > 20000
group by 1
order by 2 desc;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno)
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
where
    a.parcel_value > 10000
group by 1
order by 2 desc;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno)
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
where
    a.parcel_value > 10000
    and a.state not in (5,7,8,9)
group by 1
order by 2 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name
    ,count(a.pno)
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
where
    a.parcel_value > 10000
#     and a.state not in (5,7,8,9)
group by 1
order by 2 desc;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno)
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
where
    a.parcel_value > 10000
#     and a.state not in (5,7,8,9)
group by 1
order by 2 desc;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno) 包裹数
    ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
    ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
group by 1
order by 3 desc;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno) 包裹数
    ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
    ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
group by 1
order by 4 desc;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno) 包裹数
    ,count(if(a.parcel_value > 20000, a.pno, null)) 高价值包裹数
    ,count(if(a.parcel_value > 20000, a.pno, null))/count(a.pno) 高价值占比
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
group by 1
having count(a.pno) > 10000
order by 4 desc;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno) 包裹数
    ,count(if(a.parcel_value > 15000, a.pno, null)) 高价值包裹数
    ,count(if(a.parcel_value > 15000, a.pno, null))/count(a.pno) 高价值占比
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
group by 1
having count(a.pno) > 10000
order by 4 desc;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
select
    ss.name
    ,count(a.pno) 包裹数
    ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
    ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
group by 1
having count(a.pno) > 10000
order by 4 desc;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
# select
#     ss.name
#     ,count(a.pno) 包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
# from a
# left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
# group by 1
# having count(a.pno) > 10000
# order by 4 desc
select
    ss.name
    ,a.ticket_pickup_staff_info_id
    ,count(a.pno)
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
where
    a.parcel_value > 10000
    and a.ticket_pickup_store_id
    and ss.name in ('11 PN5-HUB_Santa Rosa','PSA_PDC','CLB_PDC','TOA_PDC','NOP_PDC')
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
# select
#     ss.name
#     ,count(a.pno) 包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
# from a
# left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
# group by 1
# having count(a.pno) > 10000
# order by 4 desc
select
    ss.name
    ,a.ticket_pickup_staff_info_id
    ,count(a.pno)
from a
left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
where
    a.parcel_value > 10000
    and ss.name in ('11 PN5-HUB_Santa Rosa','PSA_PDC','CLB_PDC','TOA_PDC','NOP_PDC')
group by 1,2
order by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
# select
#     ss.name
#     ,count(a.pno) 包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
# from a
# left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
# group by 1
# having count(a.pno) > 10000
# order by 4 desc
select
    *
from
    (
                select
            a.*
            ,row_number() over (partition by a.ticket_pickup_store_id, a.ticket_pickup_staff_info_id order by a.num desc ) rk
        from
            (
                select
                    ss.name
                    ,a.ticket_pickup_staff_info_id
                    ,count(a.pno) num
                from a
                left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
                where
                    a.parcel_value > 10000
                    and ss.name in ('11 PN5-HUB_Santa Rosa','PSA_PDC','CLB_PDC','TOA_PDC','NOP_PDC')
                group by 1,2
                order by 1,2
            ) a
    ) b
where
    b.rk < 6;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
# select
#     ss.name
#     ,count(a.pno) 包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
# from a
# left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
# group by 1
# having count(a.pno) > 10000
# order by 4 desc
select
    *
from
    (
                select
            a.*
            ,row_number() over (partition by a.name, a.ticket_pickup_staff_info_id order by a.num desc ) rk
        from
            (
                select
                    ss.name
                    ,a.ticket_pickup_staff_info_id
                    ,count(a.pno) num
                from a
                left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
                where
                    a.parcel_value > 10000
                    and ss.name in ('11 PN5-HUB_Santa Rosa','PSA_PDC','CLB_PDC','TOA_PDC','NOP_PDC')
                group by 1,2
                order by 1,2
            ) a
    ) b
where
    b.rk < 6;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
# select
#     ss.name
#     ,count(a.pno) 包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
# from a
# left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
# group by 1
# having count(a.pno) > 10000
# order by 4 desc
select
    *
from
    (
        select
            a.*
            ,row_number() over (partition by a.name, a.ticket_pickup_staff_info_id order by a.num desc ) rk
        from
            (
                select
                    ss.name
                    ,a.ticket_pickup_staff_info_id
                    ,count(a.pno) num
                from a
                left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
                where
                    a.parcel_value > 10000
                    and ss.name in ('11 PN5-HUB_Santa Rosa','PSA_PDC','CLB_PDC','TOA_PDC','NOP_PDC')
                group by 1,2
            ) a
    ) b
where
    b.rk < 6;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
# select
#     ss.name
#     ,count(a.pno) 包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
# from a
# left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
# group by 1
# having count(a.pno) > 10000
# order by 4 desc
select
    *
from
    (
        select
            a.*
            ,row_number() over (partition by a.name order by a.num desc ) rk
        from
            (
                select
                    ss.name
                    ,a.ticket_pickup_staff_info_id
                    ,count(a.pno) num
                from a
                left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
                where
                    a.parcel_value > 10000
                    and ss.name in ('11 PN5-HUB_Santa Rosa','PSA_PDC','CLB_PDC','TOA_PDC','NOP_PDC')
                group by 1,2
            ) a
    ) b
where
    b.rk < 6;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
# select
#     ss.name
#     ,count(a.pno) 包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
# from a
# left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
# group by 1
# having count(a.pno) > 10000
# order by 4 desc
select
    *
from
    (
        select
            a.*
            ,row_number() over (partition by a.name order by a.num desc ) rk
        from
            (
                select
                    ss.name
                    ,a.ticket_pickup_staff_info_id
                    ,count(a.pno) num
                from a
                left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
                where
                    a.parcel_value > 15000
                    and ss.name in ('11 PN5-HUB_Santa Rosa','PSA_PDC','CLB_PDC','TOA_PDC','NOP_PDC')
                group by 1,2
            ) a
    ) b
where
    b.rk < 6;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
# select
#     ss.name
#     ,count(a.pno) 包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
# from a
# left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
# group by 1
# having count(a.pno) > 10000
# order by 4 desc
select
    *
from
    (
        select
            a.*
            ,row_number() over (partition by a.name order by a.num desc ) rk
        from
            (
                select
                    ss.name
                    ,a.ticket_pickup_staff_info_id
                    ,count(a.pno) num
                from a
                left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
                where
                    a.parcel_value > 20000
                    and ss.name in ('11 PN5-HUB_Santa Rosa','PSA_PDC','CLB_PDC','TOA_PDC','NOP_PDC')
                group by 1,2
            ) a
    ) b
where
    b.rk < 6;
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
where
    pi.dst_phone = '09918919066'
    or pi.src_phone = '09918919066';
;-- -. . -..- - / . -. - .-. -.--
select
    plt.pno
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
where
    plt.state in (5,6)
    and (pi.dst_phone = '09918919066'
    or pi.src_phone = '09918919066');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
#     and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    count(*)
from
    (
        select
            de.*
            ,case bc.client_name
                when 'lazada' then dl.delievey_end_date
                when 'shopee' then ds.end_date
                when 'tiktok' then dt.end_date
            end end_date
        from dwm.dwd_ex_ph_parcel_details de
        left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
        left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = de.pno
        left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = de.pno
        left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = de.pno
    ) a
where
    a.parcel_state not in (5,7,8,9)
    and a.end_date < curdate();
;-- -. . -..- - / . -. - .-. -.--
select
    count(*)
from
    (
        select
            de.*
            ,case bc.client_name
                when 'lazada' then dl.delievey_end_date
                when 'shopee' then ds.end_date
                when 'tiktok' then dt.end_date
            end end_date
            ,pi.cod_amount/100 cod_num
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info pi on pi.pno = de.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
        left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = de.pno
        left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = de.pno
        left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = de.pno
    ) a
where
    a.parcel_state not in (5,7,8,9)
    and a.end_date < curdate()
    and a.cod_num > 10000;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            de.*
            ,case bc.client_name
                when 'lazada' then dl.delievey_end_date
                when 'shopee' then ds.end_date
                when 'tiktok' then dt.end_date
            end end_date
            ,pi.cod_amount/100 cod_num
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info pi on pi.pno = de.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
        left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = de.pno
        left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = de.pno
        left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = de.pno
    ) a
where
    a.parcel_state not in (5,7,8,9)
    and a.end_date < curdate()
    and a.cod_num > 10000;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,a.cod_num cod金额
    ,a.end_date 派送时效
    ,a.client_id
    ,a.parcel_state_name 包裹状态
    ,a.pickup_time 揽收时间
    ,a.last_cn_route_action 最后一条有效路由
    ,a.last_route_time 最后一条有效路由时间
    ,a.last_store_name 包裹当前网点
    ,a.last_store_id 包裹当前网点ID
    ,a.dst_routed_at 目的地网点的第一次有效路由时间
    ,a.first_cn_marker_category 第一次尝试派送失败原因
    ,a.first_marker_at 第一次尝试派送失败时间
    ,a.dst_store 目的地网点
    ,a.dst_region 目的地网点大区
    ,a.dst_piece 目的地网点片区
from
    (
        select
            de.*
            ,case bc.client_name
                when 'lazada' then dl.delievey_end_date
                when 'shopee' then ds.end_date
                when 'tiktok' then dt.end_date
            end end_date
            ,pi.cod_amount/100 cod_num
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info pi on pi.pno = de.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
        left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = de.pno
        left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = de.pno
        left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = de.pno
    ) a
where
    a.parcel_state not in (5,7,8,9)
    and a.end_date < curdate()
    and a.cod_num > 10000;
;-- -. . -..- - / . -. - .-. -.--
ore_name 包裹当前网点
    ,a.last_store_id 包裹当前网点ID
    ,a.dst_routed_at 目的地网点的第一次有效路由时间
    ,a.first_cn_marker_category 第一次尝试派送失败原因
    ,a.first_marker_at 第一次尝试派送失败时间
    ,a.dst_store 目的地网点
    ,a.dst_region 目的地网点大区
    ,a.dst_piece 目的地网点片区
    ,if(plt.pno is not null , '是', '否') 是否人工无需追责过
from
    (
        select
            de.*
            ,case bc.client_name
                when 'lazada' then dl.delievey_end_date
                when 'shopee' then ds.end_date
                when 'tiktok' then dt.end_date
            end end_date
            ,pi.cod_amount/100 cod_num
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info pi on pi.pno = de.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
        left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = de.pno
        left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = de.pno
        left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = de.pno
    ) a
left join ph_bi.parcel_lose_task plt on plt.pno = a.pno and plt.state = 6 and plt.operator_id not in (10000,10001)
where
    a.parcel_state not in (5,7,8,9)
    and a.end_date < curdate()
    and a.cod_num > 10000
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,a.cod_num cod金额
    ,a.end_date 派送时效
    ,a.client_id
    ,a.parcel_state_name 包裹状态
    ,a.pickup_time 揽收时间
    ,a.last_cn_route_action 最后一条有效路由
    ,a.last_route_time 最后一条有效路由时间
    ,a.last_store_name 包裹当前网点
    ,a.last_store_id 包裹当前网点ID
    ,a.dst_routed_at 目的地网点的第一次有效路由时间
    ,a.first_cn_marker_category 第一次尝试派送失败原因
    ,a.first_marker_at 第一次尝试派送失败时间
    ,a.dst_store 目的地网点
    ,a.dst_region 目的地网点大区
    ,a.dst_piece 目的地网点片区
    ,if(plt.pno is not null , '是', '否') 是否人工无需追责过
from
    (
        select
            de.*
            ,case bc.client_name
                when 'lazada' then dl.delievey_end_date
                when 'shopee' then ds.end_date
                when 'tiktok' then dt.end_date
            end end_date
            ,pi.cod_amount/100 cod_num
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info pi on pi.pno = de.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
        left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = de.pno
        left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = de.pno
        left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = de.pno
    ) a
left join ph_bi.parcel_lose_task plt on plt.pno = a.pno and plt.state = 6 and plt.operator_id not in (10000,10001)
where
    a.parcel_state not in (5,7,8,9)
    and a.end_date < curdate()
    and a.cod_num > 10000
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pack_no
from ph_staging.pack_info pi
left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
left join ph_staging.parcel_route pr on pr.store_id = pi.unseal_store_id
where
    pi.created_at >= '2023-05-07 16:00:00'
    and pi.created_at < '2023-05-08 16:00:00'
    and pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pack_no
from ph_staging.pack_info pi
left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
left join ph_staging.parcel_route pr on pr.store_id = pi.unseal_store_id and pr.routed_at >  '2023-05-07 16:00:00'
where
    pi.created_at >= '2023-05-07 16:00:00'
    and pi.created_at < '2023-05-08 16:00:00'
    and pr.pno is null
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pack_no
from ph_staging.pack_info pi
left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.unseal_store_id and pr.routed_at >  '2023-05-07 16:00:00'
where
    pi.created_at >= '2023-05-07 16:00:00'
    and pi.created_at < '2023-05-08 16:00:00'
    and pr.pno is null
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.unseal_store_id and pr.routed_at >  '2023-05-07 16:00:00'
        where
            pi.created_at >= '2023-05-07 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
            and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.unseal_store_id and pr.routed_at >  '2023-05-07 16:00:00'
        where
            pi.created_at >= '2023-04-25 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
            and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.unseal_store_id and pr.routed_at >  '2023-05-07 16:00:00'
        where
            pi.created_at >= '2023-04-25 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at >  '2023-05-07 16:00:00'
        where
            pi.created_at >= '2023-04-25 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id
        where
            pi.created_at >= '2023-04-25 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > '2023-04-26 16:00:00'
        where
            pi.created_at >= '2023-04-26 16:00:00'
            and pi.created_at < '2023-04-27 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > '2023-04-26 16:00:00'
        where
            pi.created_at >= '2023-04-26 16:00:00'
#             and pi.created_at < '2023-04-27 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.state
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > '2023-04-26 16:00:00'
        where
            pi.created_at >= '2023-04-26 16:00:00'
#             and pi.created_at < '2023-04-27 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
            pi.pack_no
            ,pi.state
            ,pi.seal_count
            ,pr.pno
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > '2023-04-26 16:00:00'
        where
            pi.created_at >= '2023-04-26 16:00:00'
#             and pi.created_at < '2023-04-27 16:00:00'
#             and pr.pno is null
            and pi.pack_no = 'P57573245'
            and pr.pno is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.state
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > '2023-04-26 16:00:00'
        where
            pi.created_at >= '2023-04-26 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pack_no
    ,pi.state
    ,pi.seal_count
    ,pr.pno
from ph_staging.pack_info pi
left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > '2023-04-26 16:00:00'
where
    pi.created_at >= '2023-04-26 16:00:00'
    and pi.created_at < '2023-05-08 16:00:00'
#             and pi.created_at < '2023-04-27 16:00:00'
#             and pr.pno is null
    and pi.pack_no = 'P57372981'
    and pr.pno is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pack_no
    ,pi.state
    ,pi.seal_count
    ,psd.pno
    ,pr.pno
from ph_staging.pack_info pi
left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > '2023-04-26 16:00:00'
where
    pi.created_at >= '2023-04-26 16:00:00'
    and pi.created_at < '2023-05-08 16:00:00'
#             and pi.created_at < '2023-04-27 16:00:00'
#             and pr.pno is null
    and pi.pack_no = 'P57372981'
    and pr.pno is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.state
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > pi.created_at
        where
            pi.created_at >= '2023-04-26 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.state
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > pi.created_at
        where
            pi.created_at >= '2023-04-26 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.state
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > pi.created_at and pr.routed_at > '2023-04-26 16:00:00'
        where
            pi.created_at >= '2023-04-26 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pack_no
    ,pi.state
    ,pi.seal_count
    ,psd.pno
    ,pr.pno
from ph_staging.pack_info pi
left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > '2023-04-26 16:00:00'
where
    pi.created_at >= '2023-04-26 16:00:00'
    and pi.created_at < '2023-05-08 16:00:00'
#             and pi.created_at < '2023-04-27 16:00:00'
#             and pr.pno is null
    and pi.pack_no = 'P56802609'
    and pr.pno is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            pi.pack_no
            ,pi.state
            ,pi.seal_count
            ,count(distinct pr.pno) num
        from ph_staging.pack_info pi
        left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
        left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > pi.created_at and pr.routed_at > '2023-04-26 16:00:00' and pr.route_action in ('RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
        where
            pi.created_at >= '2023-04-26 16:00:00'
            and pi.created_at < '2023-05-08 16:00:00'
#             and pr.pno is null
        group by 1
    ) a
where
    a.num > 0
    and a.num < a.seal_count;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pack_no
    ,pi.state
    ,pi.seal_count
    ,psd.pno
    ,pr.pno
from ph_staging.pack_info pi
left join ph_staging.pack_seal_detail psd on psd.pack_no = pi.pack_no
left join dwm.dwd_ex_ph_parcel_details de on de.pno = psd.pno
left join ph_staging.parcel_route pr on pr.pno = psd.pno and pr.store_id = pi.es_unseal_store_id and pr.routed_at > '2023-04-26 16:00:00' and pr.route_action in ('RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
where
    pi.created_at >= '2023-04-26 16:00:00'
    and pi.created_at < '2023-05-08 16:00:00'
#             and pi.created_at < '2023-04-27 16:00:00'
#             and pr.pno is null
    and pi.pack_no = 'P55500745'
    and pr.pno is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,a.cod_num cod金额
    ,a.end_date 派送时效
    ,a.client_id
    ,a.parcel_state_name 包裹状态
    ,a.pickup_time 揽收时间
    ,a.last_cn_route_action 最后一条有效路由
    ,a.last_route_time 最后一条有效路由时间
    ,a.last_store_name 包裹当前网点
    ,a.last_store_id 包裹当前网点ID
    ,a.dst_routed_at 目的地网点的第一次有效路由时间
    ,a.first_cn_marker_category 第一次尝试派送失败原因
    ,a.first_marker_at 第一次尝试派送失败时间
    ,a.dst_store 目的地网点
    ,a.dst_region 目的地网点大区
    ,a.dst_piece 目的地网点片区
    ,if(plt.pno is not null , '是', '否') 是否人工无需追责过
from
    (
        select
            de.*
            ,case bc.client_name
                when 'lazada' then dl.delievey_end_date
                when 'shopee' then ds.end_date
                when 'tiktok' then dt.end_date
            end end_date
            ,pi.cod_amount/100 cod_num
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info pi on pi.pno = de.pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
        left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = de.pno
        left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = de.pno
        left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = de.pno
    ) a
left join ph_bi.parcel_lose_task plt on plt.pno = a.pno and plt.state = 5 and plt.operator_id not in (10000,10001)
where
    a.parcel_state not in (5,7,8,9)
    and a.end_date < curdate()
    and a.cod_num > 10000
group by 1;
;-- -. . -..- - / . -. - .-. -.--
set @begin_time = '2023-05-01',@end_time = '2023-05-08';
;-- -. . -..- - / . -. - .-. -.--
select
    date(plt.created_at)
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= @begin_time
    and plt.created_at < @end_time
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
pr1.store_name 发车网点
,pr1.next_store_name 到车网点
,ft1.line_name 线路名称
,ft1.proof_id 出车凭证号
,ft1.plan_leave_time 计划发车时间
,ft1.real_leave_time 实际发车时间
,ft2.plan_arrive_time 计划到车时间
,ft2.real_arrive_time 实际到车时间
,ft1.proof_plate_number 车牌号
,case ft1.line_plate_type
when 100 then '4W'
when 101 then '4WJ'
when 102 then 'PH4WFB'
when 200 then '6W5.5'
when 201 then '6W6.5'
when 203 then '6W7.2'
when 204 then 'PH6W'
when 205 then 'PH6WF'
when 210 then '6W8.8'
when 300 then '10W'
when 400 then '14W'
end 车型
,pr2.解封车时间
,pr1.'装载重量(KG)'
,pr1.'体积(立方米)'
,pr1.应到包裹数
,pr2.实到包裹数
,pr1.应到包裹数 - pr2.实到包裹数 未到包裹数
,pr1.应到集包数
,pr2.实到集包数
,pr1.应到集包数 - pr2.实到集包数 未到集包数

from
(
  select
  pr1.proof_id
  ,pr1.store_name
  ,pr1.next_store_name
  ,count(distinct pr1.pno) 应到包裹数
  ,count(distinct pr1.packpno) 应到集包数
  ,sum(pi.store_weight/1000) '装载重量(KG)'
  ,sum(pi.store_length*pi.store_width*pi.store_height/1000000) '体积(立方米)'
  from
  (
    select distinct
    REPLACE(json_extract(pr.extra_value,'$.proofId'),'\"','') proof_id
    ,pr.store_name
    ,pr.next_store_name
    ,pr.pno
    ,replace(json_extract(pr.extra_value, '$.packPno'),'\"','') packpno
    FROM ph_staging.parcel_route pr
    where pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and  pr.routed_at >= date_sub(curdate(),interval 6 day)
  ) pr1
  left join ph_staging.parcel_info pi
  on pr1.pno = pi.pno
  group by 1,2,3
) pr1

left join

(
  select
  REPLACE(json_extract(pr.extra_value,'$.proofId'),'\"','') proof_id
  ,pr.store_name
  ,count(distinct pr.pno) 实到包裹数
  ,count(distinct replace(json_extract(pr.extra_value, '$.packPno'),'\"',''))  实到集包数
  ,convert_tz(min(pr.routed_at),'+00:00','+08:00') 解封车时间
  FROM ph_staging.parcel_route pr
  where pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
  and  pr.routed_at >= date_sub(curdate(),interval 6 day)
  group by 1,2
) pr2
on pr1.proof_id = pr2.proof_id
and pr1.next_store_name = pr2.store_name

left join ph_bi.fleet_time ft1
on ft1.proof_id = pr1.proof_id
and ft1.store_name = pr1.store_name

left join ph_bi.fleet_time ft2
on ft2.proof_id = pr2.proof_id
and ft2.next_store_name = pr2.store_name

where ft2.real_arrive_time >= date_sub(curdate(),interval 1 day)
and ft2.real_arrive_time < curdate();
;-- -. . -..- - / . -. - .-. -.--
SELECT
	pr.pno
    ,ft.`store_name` 始发网点
    ,ft.`next_store_name` 目的网点
    ,ft.line_name 线路名称
    ,pr.proof_id 出车凭证
	,ft.proof_plate_number 车牌号
    ,ft.`real_arrive_time` 实际到车时间
    ,pi.`client_id` 客户ID
            	   ,case pi.parcel_category
                     when '0' then '文件'
                     when '1' then '干燥食品'
                     when '10' then '家居用具'
                     when '11' then '水果'
                     when '2' then '日用品'
                     when '3' then '数码产品'
                     when '4' then '衣物'
                     when '5' then '书刊'
                     when '6' then '汽车配件'
                     when '7' then '鞋包'
                     when '8' then '体育器材'
                     when '9' then '化妆品'
                     when '99' then '其它'
                     end  '物品类型'
                  ,pi.store_weight/1000 '物品重量'
                  ,pi.store_length*pi.store_width*pi.store_height '体积'
           		  ,pr.store_name 车货关联到港网点
from (-- 最后一条路由是车货关联出港
                                select
                                pr.store_id,
                                pr.routed_at,
                                pr.`pno`,
                                pr.store_name,
                                pr.proof_id

                                from(select
                                     pr.`pno`
                                     ,pr.store_id
                                     ,pr.`routed_at`
                                     ,pr.route_action
                                     ,pr.store_name
                                     ,REPLACE(json_extract(pr.extra_value,'$.proofId'),'\"','') proof_id
                                     ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                                     from ph_staging.`parcel_route`as pr
                                     where convert_tz(pr.routed_at,'+00:00','+08:00')>= date_sub(CURRENT_DATE ,INTERVAL 7 day)

                                     ) pr
                                       where pr.rn = 1
                                      and pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
       )pr
 LEFT JOIN `ph_bi`.`fleet_time` ft on ft.`proof_id` =pr.`proof_id`
 LEFT JOIN `ph_staging`.`parcel_info` pi on pi.pno=pr.pno

 where convert_tz(pr.routed_at,'+00:00','+08:00') >= date_sub(curdate(),interval 7 day)
and convert_tz(pr.routed_at,'+00:00','+08:00') < curdate()
GROUP by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct pss.pno)
from dw_dmd.parcel_store_stage_new pss
where
    pss.van_out_proof_id = 'parcel_store_stage_new';
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct pss.pno)
from dw_dmd.parcel_store_stage_new pss
where
    pss.van_out_proof_id = 'DMTL23109M3';
;-- -. . -..- - / . -. - .-. -.--
select distinct
    REPLACE(json_extract(pr.extra_value,'$.proofId'),'\"','') proof_id
    ,pr.store_name
    ,pr.next_store_name
    ,pr.pno
    ,replace(json_extract(pr.extra_value, '$.packPno'),'\"','') packpno
    FROM ph_staging.parcel_route pr
    where pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and  pr.routed_at >= date_sub(curdate(),interval 6 day)
    and pr.store_name = 'DMT_SP';
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
)
select
    pssn.pno
from dw_dmd.parcel_store_stage_new pssn
join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
where
    ft1.proof_id = 'DMTL23109M3'
    and ft.store_name = 'DMT_SP';
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
)
select
    pssn.pno
from dw_dmd.parcel_store_stage_new pssn
join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
where
    ft1.proof_id = 'DMTL23109M3'
    and ft1.store_name = 'DMT_SP';
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
)
-- 各网点应到包裹书
select
    ft1.proof_id
    ,ft1.next_store_id
    ,ft1.next_store_name
    ,count(pssn.pno)
from dw_dmd.parcel_store_stage_new pssn
join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
where
    ft1.proof_id = 'DMTL23109M3'
    and ft1.store_name = 'DMT_SP'
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
)
-- 各网点应到包裹书
select
    ft1.proof_id
    ,ft1.next_store_id
    ,ft1.next_store_name
    ,count(pssn.pno)
from dw_dmd.parcel_store_stage_new pssn
join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
where
    ft1.proof_id = 'DMTL23109M3'
#     and ft1.store_name = 'DMT_SP'
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.proof_id = 'DMTL23109M3';
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹书
select
    ft1.proof_id
    ,pssn.next_store_id
    ,pssn.next_store_name
    ,count(pssn.pno)
from dw_dmd.parcel_store_stage_new pssn
join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
where
    ft1.proof_id = 'DMTL23109M3'
#     and ft1.store_name = 'DMT_SP'
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
        ft2.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,count(pssn.pno)
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    where
        ft2.proof_id = 'DMTL23109M3'
    group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
# ,sh_ar as
# (
#     select
#         ft1.proof_id
#         ,pssn.next_store_id
#         ,pssn.next_store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
# #     group by 1,2,3
# )
# ,re_ar as
# (
    select
        ft2.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,count(pssn.pno)
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    where
        ft2.proof_id = 'DMTL23109M3'
    group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
# ,sh_ar as
# (
#     select
#         ft1.proof_id
#         ,pssn.next_store_id
#         ,pssn.next_store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
# #     group by 1,2,3
# )
# ,re_ar as
# (
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,count(pssn.pno)
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    where
        ft2.proof_id = 'DMTL23109M3'
    group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select max(prd.created_at) from ph_drds.pack_route_d prd;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pssn.first_valid_routed_at 目的地网点的第一次有效路由时间
    ,pssn.last_valid_routed_at 目的地网点的最后一次有效路由时间
    ,datediff(curdate(), pssn.first_valid_routed_at) 在仓天数
from ph_staging.parcel_info pi
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = pi.pno and pi.dst_store_id = pssn.store_id and pssn.valid_store_order is not null
where
    pi.state not in (5,7,8,9)
    and pssn.first_valid_routed_at < date_sub(curdate(), interval  2 day );
;-- -. . -..- - / . -. - .-. -.--
select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13');
;-- -. . -..- - / . -. - .-. -.--
select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
# , b as
# (
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
select
        pi.pno
        ,pcd.created_at
    from  ph_staging.parcel_info pi
    left join ph_staging.parcel_change_detail pcd  on pi.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and pi.state not in (5,7,8,9)
        and pr.pno is null;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pcd.created_at
    from  ph_staging.parcel_info pi
    left join ph_staging.parcel_change_detail pcd  on pi.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and pi.state not in (5,7,8,9)
        and pr.pno is null
)
# , b
# (
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pcd.created_at
    from  ph_staging.parcel_info pi
    left join ph_staging.parcel_change_detail pcd  on pi.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and pi.state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-04-01'
    and mw.created_at < '2023-05-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        pr.pno
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'PENDING_RETURN'
        and pr.routed_at >= '2023-03-31 16:00:00'
    group by 1,2
)
, b as
(
    select
        pr2.pno
        ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
        ,pr2.staff_info_id
        ,pr2.store_id
    from ph_staging.parcel_route pr2
    join
        (
            select a.pno from a group by 1
        ) b on pr2.pno = b.pno
    where
        pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr2.routed_at >= '2023-03-31 16:00:00'
)
select
    a.pno 包裹
    ,a.date_d 待退件操作日期
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.cod_amount/100 COD金额
    ,group_concat(distinct b2.staff_info_id) 交接员工id
from a
join
    (
        select
            b.pno
            ,b.date_d
            ,b.store_id
        from b
        group by 1,2,3
    ) b on a.pno = b.pno and a.date_d = b.date_d
left join ph_staging.parcel_info pi on pi.pno = a.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join b b2 on b2.pno = a.pno and b2.date_d = a.date_d
where
    pi.state not in (5,7,8,9)
    and a.date_d < curdate()
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    dc.store_id,
    ss.name,
    count(distinct dc.pno) 应派,
    count(distinct(if(date(convert_tz(pi.`finished_at`,'+00:00' ,'+08:00'))=date_sub(current_date,interval 1 day),dc.`pno` ,null))) 今日妥投量,
    count(distinct if(td.`pno` is not null,dc.pno,null))网点交接包裹量  ,
    count(distinct if(td.`pno` is not null,dc.pno,null))/count(distinct dc.pno) 网点交接率
#     concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dc.pno  ,null))/count(distinct dc.pno)*100,2),"%")  大件占比
from  ph_bi.`dc_should_delivery_today` dc
left join `ph_staging`.parcel_info  pi on dc.`pno` =pi.`pno`
left join `ph_staging`.`ticket_delivery` td on td.`pno` =dc.pno and date(convert_tz(td.`delivery_at` ,'+00:00' ,'+08:00'))= dc.stat_date and td.`state` in (0,1,2)
left join ph_staging.sys_store ss on ss.id = dc.store_id
where
    dc.`stat_date` = date_sub(current_date,interval 1 day)
    and dc.state<6
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*,
    a.avg_decnt 网点人均可交接量
    ,if((t.入职时间 < date_sub(current_date,interval 7 day) and t.今日应派 > 200 and t.网点应派交接率>=0.95 and t.今日个人交接量>15 and t.今日个人交接量>0   and t.今日个人妥投量 <10 and t.今日个人揽收件量 <30  and t.今日派件时长 <3 and t.网点妥投率 <0.9 and sh.员工id is null)
     or ((t.入职时间 < date_sub(current_date,interval 7 day) and t.今日应派 > 200 and t.网点应派交接率<0.95 and t.今日个人交接量>0 and t.今日个人妥投量 <10 and t.今日个人揽收件量 <30  and t.今日派件时长 <3 and t.网点妥投率 <0.9 and sh.员工id is null))
     or((t.入职时间 < date_sub(current_date,interval 7 day) and (t.今日应派-t.网点交接量)>10 and t.今日个人揽收件量 <30 and t.今日个人交接量=0 and sh.员工id is null))
    ,"是","否") "是否低效"
    ,if(sh.员工id is not null,"是","")"通过审批支援"
    from (
    SELECT
    mr.`name`大区 ,
    mp.name 片区,
    hi.`sys_store_id` 网点id,
    ss.name 网点名称,
    hi.`staff_info_id` 员工工号 ,
    hi.`name`  员工姓名,
    case when jr.今日个人交接量 is null then 0 else jr.今日个人交接量 end 今日个人交接量,
    case when tt.个人妥投量 is null then 0 else tt.个人妥投量 end 今日个人妥投量 ,
    case when  jr.今日个人揽收件量 is null then 0 else jr.今日个人揽收件量 end 今日个人揽收件量 ,
    jr.上班打卡时间  '今日上班打卡时间', jr.下班打卡时间  '今日下班打卡时间',
    case when yp.应派 is null then 0 else  yp.应派 end '今日应派',
    case when yp.今日妥投量 is null then 0 else  yp.今日妥投量 end '网点妥投量'  ,
     case when yp.网点交接包裹量 is null then 0 else  yp.网点交接包裹量 end '网点交接量'  ,
       yp.应派 - yp.网点交接包裹量 网点应派未交接包裹量,
     case when yp.网点交接率 is null then 0 else  yp.网点交接率 end '网点应派交接率'  ,
    round((if(yp.今日妥投量 is null,0,yp.今日妥投量)/if(yp.应派 is null,0,yp.应派)),2) 网点妥投率,
    case hi.`state`  when 1 then "在职" when 2 then "离职" when 3 then "停职" end as 在职状态,
    CASE hi.`job_title` when 13 then "Bike" when 110 then "Van" when 1000 then "Tricycle" end as "岗位",
    CASE when hi.`formal` =1 then '正式' when  hi.`formal` =0 then '外协' end as '正式or外协',
    date(hi.`hire_date`) 入职时间,
     v2.`shift_start` ,v2.`shift_end` ,v2.`stat_date` ,
    round(tt.个人妥投量/jr.今日个人交接量,2) as "个人交接妥投率",
    case when  jr.揽收任务 is null then 0 else jr.揽收任务 end '今日揽收任务',
    jr.打卡时长  '今日打卡时长',
    case when jc.今日派件时长 is null then 0 else jc.今日派件时长 end 今日派件时长,
    jc.今日首次妥投时间,jc.今日倒数第二次妥投时间,jr.第一件揽收时间
from  ph_bi.`hr_staff_info` hi
left join `ph_staging`.`sys_store` ss on ss.`id` =hi.`sys_store_id`
left join `ph_staging`.`sys_manage_piece` mp on mp.`id` =ss.`manage_piece`
left join `ph_staging`.`sys_manage_region` mr on mr.id =ss.`manage_region`
left join
    (# 今日信息
select
    hi.`staff_info_id` ,
    gr.今日个人交接量, gr.大件数量, gr.大件占比, gr.小件数量,gr.小件占比,
    pp.今日个人揽收件量,pp.第一件揽收时间,rw.揽收任务,
    ad.上班打卡时间,ad.下班打卡时间,ad.打卡时长
from  ph_bi.`hr_staff_info` hi
left join(#今日个人交接
select
dt.`store_id`,
ss.`name` ,
dt.`staff_info_id`,
jt.`job_name` 职位,
COUNT(distinct dt.`pno`)  今日个人交接量,
count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dt.pno  ,null)) '大件数量',
concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dt.pno  ,null))/count(distinct dt.pno)*100,2),"%")  大件占比,
count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,null,dt.pno )) 小件数量,
concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,null,dt.pno ))/count(distinct dt.pno)*100,2),"%") 小件占比
from `ph_staging`.`ticket_delivery` dt
left join `ph_staging`.`parcel_info` pi on dt.`pno` = pi.`pno`
left join `ph_staging`.`sys_store` ss on dt.`store_id`  = ss.`id`
LEFT JOIN `ph_bi`.`hr_staff_info`  hr on hr.`staff_info_id` =dt.`staff_info_id`
LEFT JOIN ph_bi.`hr_job_title` jt on jt.`id` =hr.`job_title`
where date(convert_tz(dt.`delivery_at`,'+00:00','+08:00'))= date_sub(CURRENT_DATE,interval 1 day)
and dt.`transfered` = 0
and dt.`state` in (0,1,2)
GROUP BY 3
)gr on gr.`staff_info_id`=hi.`staff_info_id`

left join (#今日揽收
        select pi.`ticket_pickup_staff_info_id` ,p.第一件揽收时间,COUNT(DISTINCT(pi.`pno`)) 今日个人揽收件量
        from `ph_staging`.`parcel_info` pi
         left join   (#第一件揽收时间
          select pi.`ticket_pickup_staff_info_id` ,min(convert_tz(pi.`created_at`,  '+00:00', '+08:00')) 第一件揽收时间 from ph_staging.parcel_info pi
        where pi.`state` <9
	and date(convert_tz(pi.`created_at`,'+00:00','+08:00')) >=date_sub(CURRENT_DATE,interval 1 day)

        group by 1) p on p.`ticket_pickup_staff_info_id`=pi.`ticket_pickup_staff_info_id`

        where pi.`state` <9
	and date(convert_tz(pi.`created_at`,'+00:00','+08:00')) >=date_sub(CURRENT_DATE,interval 1 day)

        group by 1)pp  on pp.`ticket_pickup_staff_info_id` =hi.`staff_info_id`

    LEFT JOIN (#今日揽收任务数
select  tp.staff_info_id , COUNT(tp.id) 揽收任务
        from ph_staging.ticket_pickup tp
where date(convert_tz(tp.`created_at`,'+00:00','+08:00'))  >=date_sub(CURRENT_DATE,interval 1 day)

 and tp.`state` =2
group by 1) rw on rw.staff_info_id=hi.`staff_info_id`

left join (#今日出勤
    select v.`staff_info_id`  ,v.`attendance_started_at` 上班打卡时间,v.`attendance_end_at` 下班打卡时间, round(timestampdiff(second,v.`attendance_started_at`,v.`attendance_end_at`) / 3600,2) 打卡时长
    from ph_bi.`attendance_data_v2` v
    where v.`stat_date`  = date_sub(CURRENT_DATE,interval 1 day)
  )ad on ad.`staff_info_id`=hi.`staff_info_id`
) jr on jr.`staff_info_id`=hi.`staff_info_id`


left join ( #今日工作时长
select dc.`staff_info_id` , dc.`store_id` , round(dc.`duration` / 3600,2) 今日派件时长 ,dc.`first_delivery_finish_time` 今日首次妥投时间 ,dc.stat_end 今日倒数第二次妥投时间
from `ph_bi`.`delivery_count_staff` dc
left join `ph_staging`.`sys_store` ss on dc.`store_id` = ss.`id`
where dc.`finished_at` =date_sub(CURRENT_DATE,interval 1 day)
and dc.`duration` <> 0
group by 1) jc on jc.staff_info_id=hi.`staff_info_id`

LEFT JOIN (#今日派送人数
    SELECT case
                   when pi.dst_store_id = 'PH39070101' and pi.duty_store_id in ('PH39070102','PH59030100') THEN pi.duty_store_id
                   else pi.`dst_store_id`
      end 目的地网点id,
       count(DISTINCT pi.`ticket_delivery_staff_info_id`) 参与派送人数,
       count(DISTINCT pi.`pno`) 处理量
  FROM `ph_staging`.`parcel_info` pi
   left join ph_bi.`hr_staff_info` hi on hi.`staff_info_id` =pi.`ticket_delivery_staff_info_id`
 WHERE pi.`finished_at` >=convert_tz(date_sub(CURRENT_DATE,interval 1 day) , '+08:00', '+00:00')
     and  pi.`finished_at` <=convert_tz(CURRENT_DATE , '+08:00', '+00:00')
    and hi.`job_title` in(110,13,1000)
    and pi.`ticket_delivery_staff_info_id` >300000
 GROUP BY 1)ck on ck.目的地网点id=hi.`sys_store_id`
LEFT JOIN ( #今日应派妥投
  select dc.store_id,
count(distinct dc.pno) 应派,
 COUNT(DISTINCT(if(date(convert_tz(pi.`finished_at`,"+00:00" ,"+08:00"))=date_sub(CURRENT_DATE,interval 1 day),dc.`pno` ,null))) 今日妥投量,
 COUNT(distinct if(td.`pno` is not null,dc.pno,null))网点交接包裹量  ,
  COUNT(distinct if(td.`pno` is not null,dc.pno,null))/count(distinct dc.pno) 网点交接率,
concat(round(count(distinct if(pi.`weight`>5000 or pi.`length`+pi.`width`+pi.`height`>80,dc.pno  ,null))/count(distinct dc.pno)*100,2),"%")  大件占比
from  ph_bi.`dc_should_delivery_today` dc
LEFT JOIN `ph_staging`.parcel_info  pi on dc.`pno` =pi.`pno`
left  join `ph_staging`.`ticket_delivery` td on td.`pno` =dc.pno and date(convert_tz(td.`delivery_at` ,"+00:00","+08:00"))= dc.stat_date and td.`state` in (0,1,2)
    where dc.`stat_date` = date_sub(CURRENT_DATE,interval 1 day)
        and dc.state<6
    group by 1
    ) yp  on yp.`store_id`=hi.`sys_store_id`
LEFT JOIN ( #今日妥投
    select
    pi.`ticket_delivery_staff_info_id` ,COUNT(DISTINCT pi.`pno`) 个人妥投量
    from `ph_staging`.parcel_info pi
   LEFT JOIN `ph_bi`.`hr_staff_info`  hr on hr.`staff_info_id` =pi.`ticket_delivery_staff_info_id`
    left join `ph_staging`.`sys_store` ss on hr.`sys_store_id`  = ss.`id`
    where pi.`state` =5
    and  date(convert_tz(pi.`finished_at`,"+00:00","+08:00"))=date_sub(CURRENT_DATE,interval 1 day)
    GROUP by 1) tt on tt.`ticket_delivery_staff_info_id`=hi.`staff_info_id`
left join ph_bi.`attendance_data_v2` v2 on v2.`staff_info_id` =hi.`staff_info_id` and v2.`stat_date` =date_sub(CURRENT_DATE,interval 1 day)
where hi.`state` in (1,3)
and hi.`job_title` in (13,110,1000)
and hi.`is_sub_staff`= 0
and hi.`formal`= 1
and ss.`category`  in (1)
and ss.`state` =1
#and jr.今日个人交接量 is not null
order by 1,2,3,4,5,14
) t
left join (#网点人均可交接
        select
        dc.`stat_date`
        ,dc.`store_id`
        ,ss.`name`
        ,COUNT(distinct dc.`pno`)  cnt
        ,round(COUNT(distinct dc.`pno`)/count(distinct td.`staff_info_id` ) ,0) avg_decnt
        FROM dwm.dwd_ph_dc_should_delivery_d dc
        left join `ph_staging`.`ticket_delivery` td on td.`pno` =dc.`pno` and dc.`stat_date` =date(convert_tz(td.`delivery_at`,"+00:00","+08:00")) and td.`state`in (0,1,2)
        left join ph_bi.`sys_store` ss on ss.`id` =dc.`store_id`
        where dc.`stat_date` =date_sub(CURRENT_DATE ,interval 1 day)
        and ss.`category` =1
         and dc.`state` <6
        GROUP BY 1,2,3 )
        a on a.store_id=t.网点id
left join (# 删掉支援人员
          SELECT
        hrs.`store_id` 被支援网点id
        ,hrs.`store_name` 被支援网点
        ,hrs.`staff_info_id`  员工id
        ,date(hr.`hire_date`) 入职日期
        ,ss.`name`  员工所属网点
        ,date_sub(CURRENT_DATE,interval 1 day) 统计日期
        ,jt.`job_name`  申请支援职位名称
        ,hrs.`employment_begin_date`  支援开始日期
        ,hrs.`employment_end_date`  支援结束日期
        ,hrs.`employment_days`  支援天数
          FROM  `ph_backyard`.`hr_staff_apply_support_store` hrs

        LEFT JOIN  `ph_bi`.`hr_job_title`  jt
        on jt.`id` =hrs.`job_title_id`

        LEFT JOIN  ph_bi.`hr_staff_info` hr
        on hr.`staff_info_id` =hrs.`staff_info_id`

        LEFT JOIN `ph_staging`.`sys_store`  ss
        on ss.`id` =hr.`sys_store_id`
          where hrs.`status` =2
        and hr.`job_title`  in(13,110,1000)
        and date_sub(CURRENT_DATE,interval 1 day)>= hrs.`employment_begin_date`
        and date_sub(CURRENT_DATE,interval 1 day)<= hrs.employment_end_date
   ) sh on sh.员工id=t.员工工号
where (t.今日上班打卡时间 is not null or t.今日下班打卡时间 is not null);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = t.妥投时间
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = t.妥投时间;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,case
        when bc.client_name = 'lazada' then dl.delievey_end_date
        when bc.client_name = 'shopee' then ds.end_date
        when bc.client_name = 'tiktok' then dt.end_date
    else null end 派送时效
    ,case
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) > 0 then '超时效'
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) <= 0 and
            datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) >= -1 then '临近超时效'
        else '未超时效'
    end 时效判断
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = t.运单号
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = t.运单号
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = t.运单号
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间);
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,case
        when bc.client_name = 'lazada' then dl.delievey_end_date
        when bc.client_name = 'shopee' then ds.end_date
        when bc.client_name = 'tiktok' then dt.end_date
    else null end 派送时效
    ,case
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) > 0 then '超时效'
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) <= 0 and
            datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) >= -1 then '临近超时效'
        else '未超时效'
    end 时效判断
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = t.运单号
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = t.运单号
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = t.运单号
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间)
left join tmpale.dwd_th_network_spill_detl_rd dt on dt.统计日期 = t.妥投时间 and dt.网点名称 = t.妥投网点;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,case
        when bc.client_name = 'lazada' then dl.delievey_end_date
        when bc.client_name = 'shopee' then ds.end_date
        when bc.client_name = 'tiktok' then dt.end_date
    else null end 派送时效
    ,case
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) > 0 then '超时效'
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) <= 0 and
            datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) >= -1 then '临近超时效'
        else '未超时效'
    end 时效判断
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = t.运单号
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = t.运单号
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = t.运单号
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间)
left join dwm.dwd_th_network_spill_detl_rd dt on dt.统计日期 = t.妥投时间 and dt.网点名称 = t.妥投网点;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,case
        when bc.client_name = 'lazada' then dl.delievey_end_date
        when bc.client_name = 'shopee' then ds.end_date
        when bc.client_name = 'tiktok' then dt.end_date
    else null end 派送时效
    ,case
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) > 0 then '超时效'
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) <= 0 and
            datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) >= -1 then '临近超时效'
        else '未超时效'
    end 时效判断
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = t.运单号
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = t.运单号
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = t.运单号
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间)
left join dwm.dwd_ph_network_spill_detl_rd dt on dt.统计日期 = t.妥投时间 and dt.网点名称 = t.妥投网点;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,bc.client_name
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,case
        when bc.client_name = 'lazada' then dl.delievey_end_date
        when bc.client_name = 'shopee' then ds.end_date
        when bc.client_name = 'tiktok' then dt.end_date
    else null end 派送时效
    ,case
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) > 0 then '超时效'
        when datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) <= 0 and
            datediff(t.妥投时间,case
            when bc.client_name = 'lazada' then dl.delievey_end_date
            when bc.client_name = 'shopee' then ds.end_date
            when bc.client_name = 'tiktok' then dt.end_date
            else null end ) >= -1 then '临近超时效'
        else '未超时效'
    end 时效判断
    ,if(dt.爆仓预警 = 'Alert', '是', '否') 当日是否爆仓
    ,pi.cod_amount/100 COD金额
    ,dn.shl_delivery_par_cnt 网点应派
    ,dn.delivery_par_cnt 妥投量
    ,dn.handover_par_cnt 交接量
    ,dn.delivery_rate 妥投率
    ,ds.handover_par_cnt 今日个人交接量
    ,ds.delivery_par_cnt 今日个人妥投量
    ,ds.pickup_par_cnt 今日个人揽收量
from tmpale.tmp_ph_pno_lj_0515 t
left join ph_staging.parcel_info pi on t.运单号 = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = t.运单号
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = t.运单号
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = t.运单号
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwm_ph_staff_wide_s ds on t.妥投快递员ID = ds.staff_info_id and ds.stat_date = date(t.妥投时间)
left join dwm.dwm_ph_network_wide_s dn on dn.store_name = t.妥投网点 and dn.stat_date = date(t.妥投时间)
left join dwm.dwd_ph_network_spill_detl_rd dt on dt.统计日期 = t.妥投时间 and dt.网点名称 = t.妥投网点;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pcd.created_at
    from  ph_staging.parcel_info pi
    left join ph_staging.parcel_change_detail pcd  on pi.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and pi.state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
join tmpale.tmp_ph_pno_lj_0516 t on b.pno = t.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pcd.created_at
    from  ph_staging.parcel_info pi
    left join ph_staging.parcel_change_detail pcd  on pi.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and pi.state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join tmpale.tmp_ph_pno_lj_0516 t on de.pno = t.pno
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
#     ,b.type 类型
#     ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,de.last_store_name 最后一条有效路由网点
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join tmpale.tmp_ph_pno_lj_0516 t on de.pno = t.pno
# join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
#     ,b.type 类型
#     ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,de.last_store_name 最后一条有效路由网点
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join tmpale.tmp_ph_pno_lj_0516 t on de.pno = t.pno
# join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = de.last_store_name and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join tmpale.tmp_ph_pno_lj_0516 t on t.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = de.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
#     ,b.type 类型
#     ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,de.last_store_name 最后一条有效路由网点
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join tmpale.tmp_ph_pno_lj_0516 t on de.pno = t.pno
# join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = de.last_store_name and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join tmpale.tmp_ph_pno_lj_0516 t on t.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = de.pno
# where
#     pi.state not in (5,7,8,9)
#     and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,mw.operator_name
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-04-01'
    and mw.created_at < '2023-05-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,mw.operator_name 操作人
        ,case swm.type
            when 1 then '派件低效'
            when 2 then '虚假操作'
            when 3 then '虚假打卡'
        end 违规类型
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_backyard.staff_warning_message swm on swm.id = mw.staff_warning_message_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-04-01'
    and mw.created_at < '2023-05-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,mw.operator_name 操作人
        ,case swm.type
            when 1 then '派件低效'
            when 3 then '虚假操作'
            when 4 then '虚假打卡'
        end 违规类型
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_backyard.staff_warning_message swm on swm.id = mw.staff_warning_message_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-04-01'
    and mw.created_at < '2023-05-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
with a as
    (
        select
            pr.pno
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
        from ph_staging.parcel_route pr
        where
            pr.route_action = 'PENDING_RETURN'
            and pr.routed_at >= '2023-03-31 16:00:00'
        group by 1,2
    )
    , b as
    (
        select
            pr2.pno
            ,date(convert_tz(pr2.routed_at, '+00:00', '+08:00')) date_d
            ,pr2.staff_info_id
            ,pr2.store_id
        from ph_staging.parcel_route pr2
        join
            (
                select a.pno from a group by 1
            ) b on pr2.pno = b.pno
        where
            pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr2.routed_at >= '2023-03-31 16:00:00'
    )
    select
        a.pno 包裹
        ,a.date_d 待退件操作日期
        ,dp.store_name 网点
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,pi.cod_amount/100 COD金额
        ,group_concat(distinct b2.staff_info_id) 交接员工id
    from a
    join
        (
            select
                b.pno
                ,b.date_d
                ,b.store_id
            from b
            group by 1,2,3
        ) b on a.pno = b.pno and a.date_d = b.date_d
    left join ph_staging.parcel_info pi on pi.pno = a.pno
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
    left join b b2 on b2.pno = a.pno and b2.date_d = a.date_d
    where
        pi.state not in (5,7,8,9)
        and a.date_d < curdate()
    group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.dst_detail_address 收件人地址
    ,seal.pack_no
    ,case pr.route_action
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一条有效路由
    ,ss.name 最后有效路由操作网点
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_0518 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.store_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0518 t on t.pno = pr.pno
        where
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = pi.pno and pr.rk = 1
left join ph_staging.sys_store ss on ss.id = pr.store_id
left join
    (
        select
            psd.pno
            ,psd.pack_no
            ,row_number() over (partition by psd.pno order by psd.created_at desc ) rk
        from ph_staging.pack_seal_detail psd
        join tmpale.tmp_ph_pno_lj_0518 t on t.pno = psd.pno
    ) seal on seal.pno = pi.pno and seal.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
select
    f1.proof_id 出车凭证
    ,f1.next_store_id 网点ID
    ,f1.next_store_name 网点
    ,sh_not_ar.pno_num 应到未到包裹数
    ,ar_not_sh.pno_num 实到不应到包裹数
    ,pack_sh_not_ar.pack_num 应到未到集包数
    ,pack_ar_not_sh.pack_num 实到不应到集包数
from ft f1
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(sr.pno) pno_num
        from ft f
        left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
        left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
        where
            rr.pno is null
        group by 1,2,3
    ) sh_not_ar on f1.proof_id = sh_not_ar.proof_id and f1.next_store_id = sh_not_ar.store_id
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(rr.pno) pno_num
        from ft f
        left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
        left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
        where
            sr.pno is null
        group by 1,2,3
    ) ar_not_sh on ar_not_sh.proof_id = f1.proof_id and ar_not_sh.store_id = f1.next_store_id
left join
    (
        select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null
        group by 1,2,3
    ) pack_sh_not_ar on pack_sh_not_ar.proof_id = f1.proof_id and pack_sh_not_ar.store_id = f1.next_store_id
left join
    (
        select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is not null
        group by 1,2,3
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,ps.pack_pno
#             ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    f1.proof_id 出车凭证
    ,f1.next_store_id 网点ID
    ,f1.next_store_name 网点
    ,sh_not_ar.pno_num 应到未到包裹数
    ,ar_not_sh.pno_num 实到不应到包裹数
    ,pack_sh_not_ar.pack_num 应到未到集包数
    ,pack_ar_not_sh.pack_num 实到不应到集包数
from ft f1
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(sr.pno) pno_num
        from ft f
        left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
        left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
        where
            rr.pno is null
        group by 1,2,3
    ) sh_not_ar on f1.proof_id = sh_not_ar.proof_id and f1.next_store_id = sh_not_ar.store_id
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(rr.pno) pno_num
        from ft f
        left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
        left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
        where
            sr.pno is null
        group by 1,2,3
    ) ar_not_sh on ar_not_sh.proof_id = f1.proof_id and ar_not_sh.store_id = f1.next_store_id
left join
    (
        select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null
        group by 1,2,3
    ) pack_sh_not_ar on pack_sh_not_ar.proof_id = f1.proof_id and pack_sh_not_ar.store_id = f1.next_store_id
left join
    (
        select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is not null
        group by 1,2,3
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
# ,sh_ar as
# (
#     select
#         ft1.proof_id
#         ,pssn.next_store_id
#         ,pssn.next_store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
#     group by 1,2,3,4
# )
# ,re_ar as
# (
#     select
#         ft2.proof_id
#         ,pssn.store_id
#         ,pssn.store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
#     group by 1,2,3,4
# )
# , pack_sh as
# (
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
# ,sh_ar as
# (
#     select
#         ft1.proof_id
#         ,pssn.next_store_id
#         ,pssn.next_store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
#     group by 1,2,3,4
# )
# ,re_ar as
# (
#     select
#         ft2.proof_id
#         ,pssn.store_id
#         ,pssn.store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
#     group by 1,2,3,4
# )
# , pack_sh as
# (
#     select
#         ft3.proof_id
#         ,pr.next_store_id
#         ,pr.next_store_name
#         ,json_extract(pr.extra_value, '$.packPno') pack_pno
#     from ph_staging.parcel_route pr
#     join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
#     where
#         pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
#         and pr.routed_at > date_sub(curdate(), interval 5 day )
#     group by 1,2,3,4
# )
# , pack_re as
# (
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,json_extract(pr.extra_value, '$.packPno') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
# ,sh_ar as
# (
#     select
#         ft1.proof_id
#         ,pssn.next_store_id
#         ,pssn.next_store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
#     group by 1,2,3,4
# )
# ,re_ar as
# (
#     select
#         ft2.proof_id
#         ,pssn.store_id
#         ,pssn.store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
#     group by 1,2,3,4
# )
# , pack_sh as
# (
#     select
#         ft3.proof_id
#         ,pr.next_store_id
#         ,pr.next_store_name
#         ,json_extract(pr.extra_value, '$.packPno') pack_pno
#     from ph_staging.parcel_route pr
#     join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
#     where
#         pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
#         and pr.routed_at > date_sub(curdate(), interval 5 day )
#     group by 1,2,3,4
# )
# , pack_re as
# (
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,json_unquote(json_extract(pr.extra_value, '$.packPno')) pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
# ,sh_ar as
# (
#     select
#         ft1.proof_id
#         ,pssn.next_store_id
#         ,pssn.next_store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
#     group by 1,2,3,4
# )
# ,re_ar as
# (
#     select
#         ft2.proof_id
#         ,pssn.store_id
#         ,pssn.store_name
#         ,pssn.pno
#     from dw_dmd.parcel_store_stage_new pssn
#     join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
#     group by 1,2,3,4
# )
# , pack_sh as
# (
#     select
#         ft3.proof_id
#         ,pr.next_store_id
#         ,pr.next_store_name
#         ,json_extract(pr.extra_value, '$.packPno') pack_pno
#     from ph_staging.parcel_route pr
#     join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
#     where
#         pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
#         and pr.routed_at > date_sub(curdate(), interval 5 day )
#     group by 1,2,3,4
# )
# , pack_re as
# (
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'),'"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    f1.proof_id 出车凭证
    ,f1.next_store_id 网点ID
    ,f1.next_store_name 网点
    ,sh_not_ar.pno_num 应到未到包裹数
    ,ar_not_sh.pno_num 实到不应到包裹数
    ,pack_sh_not_ar.pack_num 应到未到集包数
    ,pack_ar_not_sh.pack_num 实到不应到集包数
from ft f1
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(sr.pno) pno_num
        from ft f
        left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
        left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
        where
            rr.pno is null
        group by 1,2,3
    ) sh_not_ar on f1.proof_id = sh_not_ar.proof_id and f1.next_store_id = sh_not_ar.store_id
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(rr.pno) pno_num
        from ft f
        left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
        left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
        where
            sr.pno is null
        group by 1,2,3
    ) ar_not_sh on ar_not_sh.proof_id = f1.proof_id and ar_not_sh.store_id = f1.next_store_id
left join
    (
        select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null
        group by 1,2,3
    ) pack_sh_not_ar on pack_sh_not_ar.proof_id = f1.proof_id and pack_sh_not_ar.store_id = f1.next_store_id
left join
    (
        select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is not null
        group by 1,2,3
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is not null;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH61180601'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
            ,ps.pack_pno
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
#         and ft.proof_id = 'DMTL23109M3'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
    f1.proof_id 出车凭证
    ,f1.next_store_id 网点ID
    ,f1.next_store_name 网点
    ,sh_not_ar.pno_num 应到未到包裹数
    ,ar_not_sh.pno_num 实到不应到包裹数
    ,pack_sh_not_ar.pack_num 应到未到集包数
    ,pack_ar_not_sh.pack_num 实到不应到集包数
from ft f1
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(sr.pno) pno_num
        from ft f
        left join sh_ar sr on sr.proof_id = f.proof_id and f.next_store_id = sr.next_store_id
        left join re_ar rr on rr.proof_id = sr.proof_id and rr.store_id = sr.next_store_id and rr.pno = sr.pno
        where
            rr.pno is null
        group by 1,2,3
    ) sh_not_ar on f1.proof_id = sh_not_ar.proof_id and f1.next_store_id = sh_not_ar.store_id
left join
    (
        select
            f.next_store_id store_id
            ,f.next_store_name store_name
            ,f.proof_id
            ,count(rr.pno) pno_num
        from ft f
        left join re_ar rr on rr.proof_id = f.proof_id and rr.store_id = f.next_store_id
        left join sh_ar sr on sr.proof_id = rr.proof_id and sr.next_store_id = rr.store_id and rr.pno = sr.pno
        where
            sr.pno is null
        group by 1,2,3
    ) ar_not_sh on ar_not_sh.proof_id = f1.proof_id and ar_not_sh.store_id = f1.next_store_id
left join
    (
        select
            f.proof_id
            ,f.next_store_id store_id
            ,f.next_store_name store_name
            ,count(ps.pack_pno) pack_num
        from ft f
        left join pack_sh ps on ps.proof_id = f.proof_id and ps.next_store_id = f.next_store_id
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = ps.next_store_id and pr.pack_pno = ps.pack_pno
        where
            pr.pack_pno is null
        group by 1,2,3
    ) pack_sh_not_ar on pack_sh_not_ar.proof_id = f1.proof_id and pack_sh_not_ar.store_id = f1.next_store_id
left join
    (
        select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno
        where
            ps.pack_pno is null
        group by 1,2,3
    ) pack_ar_not_sh on pack_ar_not_sh.proof_id = f1.proof_id and pack_ar_not_sh.store_id = f1.next_store_id;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH81161D00'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
            ,ps.pack_pno
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH81161D00'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
            ,ps.pack_pno
            ,f.store_name store
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH19040F00'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
            ,ps.pack_pno
            ,f.store_name store
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno;
;-- -. . -..- - / . -. - .-. -.--
with ft as
(
    select
        ft.proof_id
        ,ft.store_id
        ,ft.store_name
        ,ft.next_store_id
        ,ft.next_store_name
    from ph_bi.fleet_time ft
    where
        ft.real_arrive_time >= date_sub(curdate(), interval 1 day )
        and ft.real_arrive_time < curdate()
        and ft.store_id is not null
        and ft.next_store_id = 'PH19040F00'
        and ft.proof_id = 'PN4L2310AT2'
)
-- 各网点应到包裹
,sh_ar as
(
    select
        ft1.proof_id
        ,pssn.next_store_id
        ,pssn.next_store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft1 on ft1.store_id = pssn.store_id and ft1.proof_id = pssn.van_out_proof_id
    group by 1,2,3,4
)
,re_ar as
(
    select
        ft2.proof_id
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.pno
    from dw_dmd.parcel_store_stage_new pssn
    join ft ft2 on ft2.proof_id = pssn.van_in_proof_id and ft2.next_store_id = pssn.store_id
    group by 1,2,3,4
)
, pack_sh as
(
    select
        ft3.proof_id
        ,pr.next_store_id
        ,pr.next_store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_pno
    from ph_staging.parcel_route pr
    join ft ft3 on ft3.proof_id = json_extract(pr.extra_value, '$.proofId') and ft3.next_store_id = pr.next_store_id
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day )
    group by 1,2,3,4
)
, pack_re as
(
    select
        ft4.proof_id
        ,pr.store_id
        ,pr.store_name
        ,replace(json_extract(pr.extra_value, '$.packPno'), '"', '') pack_pno
    from ph_staging.parcel_route pr
    join ft ft4 on ft4.proof_id = json_extract(pr.extra_value, '$.proofId') and ft4.next_store_id = pr.store_id
    where
        pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at > date_sub(curdate(), interval 5 day )
        and json_extract(pr.extra_value, '$.packPno') is not null
    group by 1,2,3,4
)
select
            pr.proof_id
            ,pr.store_id
            ,pr.store_name
            ,pr.pack_pno
            ,ps.pack_pno
            ,f.store_name store
#             ,count(pr.pack_pno) pack_num
        from ft f
        left join pack_re pr on pr.proof_id = f.proof_id and pr.store_id = f.next_store_id
        left join pack_sh ps on ps.proof_id = pr.proof_id and ps.next_store_id = pr.store_id and ps.pack_pno = pr.pack_pno;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.staff_info_id
    ,count(pi.pno) num
from dwm.dwm_ph_staff_wide_s dp
join ph_staging.parcel_info pi on pi.ticket_delivery_staff_info_id = dp.staff_info_id and pi.state = 5
where
    dp.stat_date = date_sub(curdate(), interval 1 day)
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
    and pi.finished_at < convert_tz(dp.attendance_end_at, '+08:00', '+00:00')
    and pi.finished_at > date_sub(convert_tz(dp.attendance_end_at, '+08:00', '+00:00'), interval 30 minute )
group by 1
having count(pi.pno) > 30;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.staff_info_id
    ,count(pi.pno) 下班前半小时妥投包裹数
    ,count(if(st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) < 200, pi.pno, null))  下班前半小时妥投包裹数200米内
from dwm.dwm_ph_staff_wide_s dp
join ph_staging.parcel_info pi on pi.ticket_delivery_staff_info_id = dp.staff_info_id and pi.state = 5
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    dp.stat_date = date_sub(curdate(), interval 1 day)
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
    and pi.finished_at < convert_tz(dp.attendance_end_at, '+08:00', '+00:00')
    and pi.finished_at > date_sub(convert_tz(dp.attendance_end_at, '+08:00', '+00:00'), interval 30 minute )
group by 1
having count(pi.pno) > 30;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.staff_info_id
    ,count(pi.pno) 下班前半小时妥投包裹数
    ,count(if(st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) < 200, pi.pno, null))  下班前半小时妥投包裹数200米内
from dwm.dwm_ph_staff_wide_s dp
join ph_staging.parcel_info pi on pi.ticket_delivery_staff_info_id = dp.staff_info_id and pi.state = 5
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    dp.stat_date = date_sub(curdate(), interval 1 day)
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
    and pi.finished_at < convert_tz(dp.attendance_end_at, '+08:00', '+00:00')
    and pi.finished_at > date_sub(convert_tz(dp.attendance_end_at, '+08:00', '+00:00'), interval 10 minute )
group by 1
having count(pi.pno) > 30;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.staff_info_id
    ,count(pi.pno) 下班前半小时妥投包裹数
    ,count(if(st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) < 200, pi.pno, null))  下班前半小时妥投包裹数200米内
from dwm.dwm_ph_staff_wide_s dp
join ph_staging.parcel_info pi on pi.ticket_delivery_staff_info_id = dp.staff_info_id and pi.state = 5
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    dp.stat_date = date_sub(curdate(), interval 1 day)
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
    and pi.finished_at < convert_tz(dp.attendance_end_at, '+08:00', '+00:00')
    and pi.finished_at > date_sub(convert_tz(dp.attendance_end_at, '+08:00', '+00:00'), interval 10 minute )
group by 1
having count(pi.pno) > 20;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.staff_info_id
    ,count(pi.pno) 下班前10分钟妥投包裹数
    ,count(if(st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) < 200, pi.pno, null))  下班前10分钟妥投包裹数200米内
from dwm.dwm_ph_staff_wide_s dp
join ph_staging.parcel_info pi on pi.ticket_delivery_staff_info_id = dp.staff_info_id and pi.state = 5
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    dp.stat_date = date_sub(curdate(), interval 1 day)
    and pi.finished_at >= date_sub(date_sub(curdate(), interval 1 day ), interval 8 hour)
    and pi.finished_at < convert_tz(dp.attendance_end_at, '+08:00', '+00:00')
    and pi.finished_at > date_sub(convert_tz(dp.attendance_end_at, '+08:00', '+00:00'), interval 10 minute )
group by 1
having count(pi.pno) > 20;