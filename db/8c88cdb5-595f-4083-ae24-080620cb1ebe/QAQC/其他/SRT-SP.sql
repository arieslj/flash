select
    t.pno
    ,s1.staff_info_id '第一次交接扫描员工ID'
    ,convert_tz(s1.routed_at, '+00:00', '+07:00') 第一次交接扫描时间
    ,s2.staff_info_id '第二次交接扫描员工ID'
    ,convert_tz(s2.routed_at, '+00:00', '+07:00') 第二次交接扫描时间
    ,m1.staff_info_id '第一次派件标记员工ID'
    ,convert_tz(m1.routed_at, '+00:00', '+07:00') 第一次派件标时间
    ,m2.staff_info_id '最后一次派件标记员工ID'
    ,convert_tz(m2.routed_at, '+00:00', '+07:00') 最后一次派件标时间
    ,a1.staff_info_id 最后一次车货关联到港员工ID
    ,convert_tz(m2.routed_at, '+00:00', '+07:00') 最后一次车货关联到港时间
from tmpale.tmp_th_pno_lj_0620 t
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_0620 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.store_id = 'TH02040702'
    ) s1 on s1.pno = t.pno and s1.rk = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_0620 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.store_id = 'TH02040702'
    ) s2 on s2.pno = t.pno and s2.rk = 2
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_0620 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.store_id = 'TH02040702'
    ) m1 on m1.pno = t.pno and m1.rk = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_0620 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.store_id = 'TH02040702'
    ) m2 on m2.pno = t.pno and m2.rk = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_0620 t on t.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN'
            and pr.store_id = 'TH02040702'
    ) a1 on a1.pno = t.pno and a1.rk = 1