select
    pi.pno
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,pi.ticket_delivery_store_id 妥投网点ID
    ,ss.name 妥投网点
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 妥投距离网点距离
    ,if(pr.pno is null, '否', '是') 是否妥投后盘库
    ,convert_tz(pi.finished_at, '+00:00', '+07:00') 妥投时间
    ,if(hsi.is_sub_staff = 1, '是', '否') 妥投员工是否子账号（外协）
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_0328 t on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
left join
    (
        select
            pr.pno
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_0328 t on t.pno = pr.pno
        left join fle_staging.parcel_info pi on pi.pno = t.pno
        where
            pr.route_action = 'INVENTORY'
            and pr.routed_at > pi.finished_at
        group by 1
    ) pr on pr.pno = t.pno

;


