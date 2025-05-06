select
    pi.pno
    ,if(json_extract(pr.extra_value, '$.onsite') = true, '是', '否') 是否OS揽收
from rot_pro.parcel_route pr
join fle_staging.parcel_info pi on pi.pno = pr.pno and pr.store_id = pi.ticket_pickup_store_id
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pi.created_at > date_sub(curdate(), interval 2 month)
    and pr.routed_at > date_sub(curdate(), interval 2 month)
    and pr.pno = 'TH01166V7K2H3A'
   -- and pr.pno in ('${SUBSTITUTE(SUBSTITUTE(p1,"\n",","),",","','")}')





;


select
    pi.pno
    ,if(sc.store_id is not null or ss.category = 9, '是', '否') 是否OS揽收
from fle_staging.parcel_info pi
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.scheduling_center_virtual_store sc
    on sc.relate_hash_id = sha2
                            (if(pi.ka_warehouse_id is not null,concat(pi.client_id, pi.ka_warehouse_id),
                            concat(pi.client_id,pi.src_phone,pi.src_province_code,pi.src_city_code,ifnull(pi.src_district_code, ''),pi.src_postal_code,pi.src_detail_address)
                            ),'256')
where
    pi.created_at > date_sub(curdate(), interval 90 day)
    and pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p1,"\n",","),",","','")}')