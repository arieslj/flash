select
    pr.pno
    ,pr.staff_info_id Staff
    ,oi.cogs_amount/100 cogs
    ,ss.name
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
where
    pr.routed_at > date_sub(curdate(), interval 4 month )
    and pr.route_action = 'DELIVERY_CONFIRM'
    and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p1,"\n",","),",","','")}')
;


select
    pr.pno Waybill_number
    ,pr.staff_info_id Staff
    ,oi.cogs_amount/100 COGS
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') Mark_time
    ,ss.name
from
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
        from ph_staging.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 4 month )
            and pr.route_action in ( 'DELIVERY_MARKER', 'DELIVERY_TICKET_CREATION_SCAN')
            and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p1,"\n",","),",","','")}')
    ) pr
left join
    (
        select
            pi.pno
            ,pi.returned
            ,pi.customary_pno
            ,pi.dst_store_id
        from ph_staging.parcel_info pi
        where
            pi.created_at > date_sub(curdate(), interval 4 month )
    ) pi on pi.pno = pr.pno
left join
    (
        select
            oi.pno
            ,oi.cogs_amount
        from ph_staging.order_info oi
        where
            oi.created_at > date_sub(curdate(), interval 4 month )
    ) oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id


;


select
    pr.pno Waybill_number
    ,pr.staff_info_id Staff
    ,oi.cogs_amount/100 COGS
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') Mark_time
    ,ss.name
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
where
    pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
    and pr.route_action in ( 'DELIVERY_MARKER', 'DELIVERY_TICKET_CREATION_SCAN')
    and pr.routed_at >date_sub(curdate(), interval 4 month )

;

select
    pi.pno
    ,pi.returned_pno
from ph_staging.parcel_info pi
where
    pi.created_at > date_sub(curdate(), interval 4 month )
    and pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p3,"\n",","),",","','")}')