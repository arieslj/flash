select
    *
from rot_pro.parcel_route pr
where
    pr.route_action = 'DELIVERY_CONFIRM'
   -- and pr.extra_value like '%album_reason%'
    and json_extract(pr.extra_value, '$.album_reason') is not null
    and pr.routed_at > '2024-11-01'


;


select
    dp.pno
    ,json_extract(dp.extra_value, '$.albumReason') as album_reason
    ,convert_tz(pi.finished_at, '+00:00', '+07:00') finish_time
from dwm.drds_parcel_route_extra dp
join fle_staging.parcel_info pi on pi.pno = dp.pno
where
    dp.route_action = 'DELIVERY_CONFIRM'
    and length(replace(json_extract(dp.extra_value, '$.albumReason'), '"', '')) > 2
    and dp.created_at > '2024-11-09'
    and pi.state = 5
    and pi.ticket_delivery_store_id in ('TH77020300', 'TH01010203', 'TH76040101', 'TH01010303','TH01010127')
    and pi.finished_at > '2024-11-09 17:00:00'
    and pi.finished_at < '2024-11-20 17:00:00'


;

SELECT t.*
     FROM dwm.drds_parcel_route_extra t
     WHERE pno = 'TH77026E461Y4A'
    and t.created_at > '2024-11-01'