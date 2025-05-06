
select
    pr.distance
    ,pr.store_id
    ,pr.route_action
    ,count(distinct pr.pno) pno_cnt
from
    (
        select
            case
                when round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0)<=200 then '网点操作'
                when round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0) is null then '网点操作'
            else '仓外操作'
            end as distance
            ,store_id
            ,pr.route_action
            ,pr.pno
            ,pr.id
        from rot_pro.parcel_route pr
        left join fle_staging.sys_store ss on ss.id = pr.store_id
        where
            ss.lng is not null
            and ss.lat is not null
        #     and convert_tz(pr.created_at,'+00:00','+07:00')>='2025-04-09'
        #     and convert_tz(pr.created_at,'+00:00','+07:00')<'2025-04-10'
            and pr.routed_at >= '2025-04-08 17:00:00'
            and pr.routed_at < '2025-04-10 17:00:00'
            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN','DELIVERY_MARKER','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DIFFICULTY_HANDOVER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED')
    ) pr
left join
    (
        select
            pr.pno
            ,'RECEIVE_WAREHOUSE_SCAN' route_action
        from rot_pro.parcel_route pr
        where
            pr.routed_at >= '2025-04-01 17:00:00'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
    ) pr2 on pr.pno = pr2.pno and pr.route_action = pr2.route_action
where
    pr2.pno is null
group by 1,2,3
