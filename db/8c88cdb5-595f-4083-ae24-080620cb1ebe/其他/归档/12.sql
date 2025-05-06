select
    date(convert_tz(pr.routed_at, '+00:00', '+07:00')) p_date
    ,count(1)
#     ,json_extract(pr.extra_value, '$.returnVisitEnabled') visit_enabled
from `rot_pro`.parcel_route  pr
WHERE  pr.route_action ='DETAIN_WAREHOUSE'
and pr.created_at >='2024-03-31 17:00:00'
and pr.created_at <='2024-04-17 17:00:00'
and pr.extra_value like "%returnVisitEnabled%"
group by 1

;

select
    t.pno
    ,pi.client_id
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0416 t on t.pno = pi.pno

;

select
    distinct
    r.*
#     r.*
#     ,json_extract(r.extra_value, '$.returnVisitEnabled') visit_enabled
from rot_pro.parcel_route r
LEFT JOIN fle_staging.parcel_info  p on r.pno = p.pno
left join rot_pro.parcel_route pr on pr.pno = r.pno and pr.routed_at < '2024-04-11 17:00:00' and pr.routed_at > '2024-01-01' and pr.route_action = 'DETAIN_WAREHOUSE' and pr.marker_category in (40,14) and json_extract(pr.extra_value, '$.returnVisitEnabled') = 1
 -- left join nl_production.violation_return_visit vrv on vrv.link_id = r.pno and vrv.type = 8 and
WHERE
    r.`route_action` ='DETAIN_WAREHOUSE'
  and r.`created_at` >='2024-04-11 17:00:00'
  and r.`created_at` <='2024-04-12 17:00:00'
  and r.`marker_category` in(40,14)
and p.client_id in('AA0660','AA0824','AA0823','AA0661')
and json_extract(r.extra_value, '$.deliveryAttemptNum') > 1
and json_extract(r.extra_value, '$.returnVisitEnabled') is null
  and pr.pno is null
and p.returned = 0
;


select
    *
from