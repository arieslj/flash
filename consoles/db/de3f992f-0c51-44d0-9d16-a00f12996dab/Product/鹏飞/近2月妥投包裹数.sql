select
    pi.pno
    ,pi.ticket_delivery_staff_lng 妥投经度
    ,pi.ticket_delivery_staff_lat 妥投纬度
    ,ss.lng 妥投网点经度
    ,ss.lat 妥投网点纬度
    ,ss.name 妥投网点名称
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离
    ,his.pno_count  近2月妥投包裹数
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0120 t on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            pr.staff_info_id
            ,count(distinct pr.pno) pno_count
        from rot_pro.parcel_route pr
        join
            (
                select
                    t.staff
                from tmpale.tmp_th_pno_lj_0120 t
                group by 1
            ) t on t.staff = pr.staff_info_id
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 2 month), interval 7 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) his on his.staff_info_id = t.staff
