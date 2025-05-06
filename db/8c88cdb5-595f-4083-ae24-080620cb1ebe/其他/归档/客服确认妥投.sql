select
    t.*
    ,pr.remark
    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) confirm_date
    ,date_format(convert_tz(pr.routed_at, '+00:00', '+07:00') , '%H:%i:%s') confirm_time
    ,concat('(', pr.staff_info_id, ')', pr.staff_info_name) confirm_staff
from tmpale.tmp_th_pno_lj_0725 t
left join rot_pro.parcel_route pr on t.pno = pr.pno and pr.remark regexp 'ยืนยันเคลม'  and pr.routed_at > '2024-06-01'


;



select
    pr.pno
    ,json(pr.extra_value, '$.[*]')
from rot_pro.parcel_route pr
left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
where
    pr.routed_at > '2024-07-07 17:00:00'
    and pr.routed_at < '2024-07-08 17:00:00'
    and pr.route_action = 'DELIVERY_CONFIRM'
    and pr.pno = 'THT600611D9ZJ9Z'

;


select
    json_extract(dpr.extra_value, '$.waybillNumberConsistency') aas
from dwm.drds_parcel_route_extra dpr
where
    dpr.route_extra_id = '668b5d78ed01f600076e6fa6'
;





;

select
    pi.pno
from fle_staging.parcel_info pi
join fle_staging.order_info oi on oi.pno = pi.pno
where
    pi.created_at > date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour)
    and pi.returned = 0
    and pi.cod_amount = 0
    and oi.cogs_amount = 0
limit 100