select
    t.pno
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0704 t on t.pno = pi.pno
join rot_pro.parcel_route pr on pr.pno = t.pno and pr.route_action = 'CHANGE_PARCEL_INFO' and pr.store_id = pi.ticket_pickup_store_id
left join fle_staging.parcel_change_detail pcd on pcd.record_id = json_extract(pr.extra_value, '$.parcelChangeId')
where
    pcd.field_name = 'dst_store_id'
group by 1