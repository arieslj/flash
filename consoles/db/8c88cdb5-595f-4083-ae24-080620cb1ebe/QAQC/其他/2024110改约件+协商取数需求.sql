select
    t.*
    ,sd.name 所属客户部门
    ,date(convert_tz(dst.routed_at, '+00:00', '+07:00')) 第一次到达目的地网点时间（年月日）
    ,date(convert_tz(gy.created_at, '+00:00', '+07:00')) 第一次改约时间
    ,gy.cnt 改约时间总次数
    ,rej.cnt 收件人拒收总次数
    ,kh.cnt 收件人电话为空号总次数
    ,inc.cnt '收件人/地址不清晰或不正确总次数'
from tmpale.tmp_th_pno_lj_1120 t
left join
    (
        select
            t.pno
            ,pr.routed_at
            ,row_number() over (partition by t.pno order by pr.routed_at) rk
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_pno_lj_1120 t on t.pno = pi.pno
        join rot_pro.parcel_route pr on pr.pno = t.pno and pr.store_id = pi.dst_store_id
        where
            pi.created_at > '2024-09-18'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) dst on dst.pno = t.pno and dst.rk = 1
left join fle_staging.ka_profile kp on kp.id = t.client_id
left join fle_staging.sys_department sd on sd.id = kp.department_id
left join
    (
        select
            di.pno
            ,di.created_at
            ,count(1) over (partition by di.pno) cnt
            ,row_number() over (partition by di.pno order by di.created_at desc) rk
        from fle_staging.parcel_problem_detail  di
        join tmpale.tmp_th_pno_lj_1120 t on t.pno = di.pno
        where
            di.created_at > '2024-09-18'
            and di.diff_marker_category = 14
    ) gy on gy.pno = t.pno and gy.rk = 1
left join
    (
        select
            t.pno
            ,count(di.id) cnt
        from fle_staging.diff_info di
        join tmpale.tmp_th_pno_lj_1120 t on t.pno = di.pno
        where
            di.created_at > '2024-09-18'
            and di.diff_marker_category = 17
        group by 1
    ) rej on rej.pno = t.pno
left join
    (
        select
            t.pno
            ,count(di.id) cnt
        from fle_staging.parcel_problem_detail di
        join tmpale.tmp_th_pno_lj_1120 t on t.pno = di.pno
        where
            di.created_at > '2024-09-18'
            and di.diff_marker_category = 40
        group by 1
    ) lx on lx.pno = t.pno
left join
    (
        select
            t.pno
            ,count(di.id) cnt
        from fle_staging.diff_info di
        join tmpale.tmp_th_pno_lj_1120 t on t.pno = di.pno
        where
            di.created_at > '2024-09-18'
            and di.diff_marker_category = 29
        group by 1
    ) kh on kh.pno = t.pno
left join
    (
        select
            t.pno
            ,count(di.id) cnt
        from fle_staging.diff_info di
        join tmpale.tmp_th_pno_lj_1120 t on t.pno = di.pno
        where
            di.created_at > '2024-09-18'
            and di.diff_marker_category = 23
        group by 1
    ) inc on inc.pno = t.pno