with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-12-01'
            and plt.parcel_created_at < '2024-01-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select
    t1.pno 运单号
    ,pi.client_id 客户ID
    ,oi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,case
        when 1st.pno is not null then 1st.type
        when 1st.pno is null and 2nd.pno is not null then 2nd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is not null then 3rd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is not null then 4th.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is null and 5th.pno is not null then 5th.type
        else 'other'
    end 环节
    ,if(pi.returned = 0, '正向', '逆向') '正向/逆向'
    ,if(pi.returned = 1, ss_custom.name, ss2.name) 正向揽收网点
    ,if(pi.returned = 1, ss2.name, null) 退件揽收网点
    ,ps1.store_name 上游网点
    ,ss4.name 最后有效路由网点
    ,ss3.name 判责网点
    ,ps1.van_in_line_name 车线名称
    ,ps1.van_arrived_at 车货到港时间
    ,if(pack.pno is not null, '是', '否') 是否集包
    ,pack.seal_store_name 集包网点
    ,pack.es_unseal_store_name 应拆包网点
    ,pack.pack_no 集包号
    ,ps1.last_valid_route_action '车货到港后最后有效路由'
    ,ps1.last_valid_routed_at '车货到港后最后有效路由时间'
    ,if(scan_no.pno is not null, '是', '否')  是否上报有发无到
    ,scan_no.store_name 上报有发无到网点
    ,scan_no.route_time  上报有发无到时间
    ,if(mac.pno is not null, '是', '否') 是否上分拣机
    ,4th.staff_info_id 最后交接员工id
from  t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-11-30'
left join my_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join my_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join my_staging.sys_store ss_custom on ss_custom.id = pi2.ticket_pickup_store_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss3 on ss3.id = t1.store_id
left join my_staging.sys_store ss4 on ss4.id = t1.last_valid_store_id
left join
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,ft.store_id
            ,ft.store_name
            ,pssn.van_in_line_name
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.van_arrived_at desc) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        left join my_bi.fleet_time ft on pssn.van_in_proof_id = ft.proof_id and pssn.store_id = ft.next_store_id and ft.arrive_type in (3,5)
        where
            pssn.van_arrived_at < t1.created_at
    ) ps1 on ps1.pno = t1.pno and ps1.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name seal_store_name
            ,json_extract(pr.extra_value, '$.esUnsealStoreName') es_unseal_store_name
            ,json_extract(pr.extra_value, '$.packPno') pack_no
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SEAL'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
            and pr.routed_at > '2023-11-30'
    ) pack on pack.pno = t1.pno and pack.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-11-30'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
    ) scan_no on scan_no.pno = t1.pno and  scan_no.rk = 1
left join
    (
        select
            t1.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-11-30'
            and pr.staff_info_id = 136770
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
        group by 1
    ) mac on mac.pno = t1.pno
left join
    (
        select -- 分拨揽收丢失
            pi.pno
            ,'分拨揽收后丢失' type
        from my_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-11-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pi.created_at > '2023-11-31'
            and pi.ticket_pickup_store_id = t1.last_valid_store_id
            and pi.ticket_pickup_store_id = t1.store_id
            and pr.pno is null
        group by 1,2
    ) 1st on 1st.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'到港分拨后遗失' type
        from t t1
        left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = t1.store_id
        where
            pssn.van_arrived_at is not null
            and (pssn.first_valid_routed_at is null or pssn.first_valid_routed_at > date_sub(t1.created_at, interval  8 hour))
        group by 1,2
    ) 2nd on 2nd.pno = t1.pno
left join
    (
        select
            t1.pno
           ,'分拨到件入仓后丢失' type
        from t t1
        where
            t1.last_valid_store_id = t1.store_id
            and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
        group by 1,2
    ) 3rd on 3rd.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'分拨交接后丢失' type
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from t t1
        join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            t1.last_valid_store_id = t1.store_id
            and pr.pno is not null
    ) 4th on 4th.pno = t1.pno and 4th.rk = 1
left join
    (
        select -- 判给发件出仓网点
            t1.pno
            ,'分拨发件出仓后丢失' type
        from t t1
        left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pr.pno is not null
        group by 1,2
    ) 5th on 5th.pno = t1.pno


