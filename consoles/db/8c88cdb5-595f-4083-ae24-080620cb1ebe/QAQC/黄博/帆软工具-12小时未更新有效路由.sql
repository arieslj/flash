with t as
    (
        select
            distinct
            pr.pno
            ,pi.src_name
            ,pssn.store_order
            ,pssn.van_in_proof_id
            ,pssn.van_arrived_at
            ,pssn.store_name
            ,pssn.store_id
        from rot_pro.parcel_route pr
        join fle_staging.parcel_info pi on pi.pno = pr.pno
        join dw_dmd.parcel_store_stage_new pssn on pssn.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_category = 14
            and pi.created_at > date_sub(curdate(), interval 2 month)
            and pi.state in (1,2,3,4,6)
            and pssn.first_valid_route_action is null
            and pssn.van_arrived_at < date_sub(now(), interval 19 hour)
            and pssn.created_at > date_sub(curdate(), interval 2 month)
    )
select
    sp.store_name 发件出仓扫描网点
    ,sp.store_id 发件出仓扫描网点ID
    ,ps.pno 运单号
    ,ps.src_name 寄件人
    ,sp.staff_info_name 发件出仓操作人
    ,convert_tz(sp.routed_at,'+00:00','+07:00') 发件出仓扫描时间
    ,ps.van_in_proof_id 出车凭证
    ,convert_tz(van.routed_at, '+00:00', '+07:00') 车货关联出港时间
    ,convert_tz(ps.van_arrived_at, '+00:00', '+07:00') 车货关联到港时间
    ,ps.store_name 车货关联到港网点
    ,ps.store_id 车货关联到港网点ID
    ,now() 更新时间
from t ps
join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.proofId') proof_id
            ,pr.staff_info_id
            ,pr.staff_info_name
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.next_store_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.next_store_id = t1.store_id and json_extract(pr.extra_value, '$.proofId') = t1.van_in_proof_id
    ) sp on sp.pno = ps.pno and sp.next_store_id = ps.store_id and ps.van_in_proof_id = sp.proof_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,json_extract(pr.extra_value, '$.proofId') proof_id
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DEPARTURE_GOODS_VAN_CK_SCAN'
            and json_extract(pr.extra_value, '$.proofId') = t1.van_in_proof_id
    ) van on van.pno = sp.pno and van.proof_id = sp.proof_id
left join
    (
        select
            pssn3.pno
            ,pssn3.store_order
        from dw_dmd.parcel_store_stage_new pssn3
        join t t1 on t1.pno = pssn3.pno
        where
            pssn3.first_valid_route_action is not null
    ) p2 on p2.pno = ps.pno and p2.store_order > ps.store_order
where
    p2.pno is null
