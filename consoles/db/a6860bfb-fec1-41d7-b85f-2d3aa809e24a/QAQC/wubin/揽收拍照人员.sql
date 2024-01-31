select
    t.pno
    ,pr.staff_info_id
    ,pr.staff_info_name
from ph_staging.parcel_route pr
join tmpale.tmp_ph_pno_lj_1113 t on t.pno = pr.pno
where
    pr.route_action = 'TICKET_WEIGHT_IMAGE'