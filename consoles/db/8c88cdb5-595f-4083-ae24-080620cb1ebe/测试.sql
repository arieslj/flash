


select
    pr.distance
    ,pr.'距离'
    ,pr.store_id
    ,pr.name
    ,pr.route_action
    ,pr.routed_at
    ,pr.pno
    ,pr2.route_action
from
    (
        select
            case
                when round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0)<=200 then '网点操作'
                when round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0) is null then '网点操作'
            else '仓外操作'
            end as distance
            ,round(st_distance_sphere(point(json_extract(pr.extra_value, '$.lng'),json_extract(pr.extra_value, '$.lat')), point(ss.lng,ss.lat)),0) '距离'
            ,store_id
            ,ss.name name
            ,pr.route_action
            ,convert_tz(pr.routed_at,'+00:00','+07:00') routed_at
            ,pr.pno
            ,pr.id
        from rot_pro.parcel_route pr
        left join fle_staging.sys_store ss on ss.id = pr.store_id
        where
            ss.lng is not null
            and ss.lat is not null
        #     and convert_tz(pr.created_at,'+00:00','+07:00')>='2025-04-09'
        #     and convert_tz(pr.created_at,'+00:00','+07:00')<'2025-04-10'
            and pr.routed_at >= '2025-05-14 17:00:00'
            and pr.routed_at < '2025-05-15 17:00:00'
            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN','DELIVERY_MARKER','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DIFFICULTY_HANDOVER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED')
            and pr.store_id in ('TH02060149','TH01480142','TH03040255','TH71140100','TH02040114','TH02030145','TH15060836','TH01100108','TH04030108','TH04020410')
        --    and pr.pno = 'THT55021UYDRB0Z'
  ) pr
left join
    (
        select
            pr.pno
            ,'RECEIVE_WAREHOUSE_SCAN' route_action
        from rot_pro.parcel_route pr
        where
            pr.routed_at >= '2025-05-01 17:00:00'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_id in ('TH02060149','TH01480142','TH03040255','TH71140100','TH02040114','TH02030145','TH15060836','TH01100108','TH04030108','TH04020410')

        union

        select
            pr.pno
            ,'SHIPMENT_WAREHOUSE_SCAN' route_action
        from rot_pro.parcel_route pr
        where
            pr.routed_at >= '2025-05-01 17:00:00'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_id in ('TH02060149','TH01480142','TH03040255','TH71140100','TH02040114','TH02030145','TH15060836','TH01100108','TH04030108','TH04020410')

        union

        select
            pr.pno
            ,'RECEIVED' route_action
        from rot_pro.parcel_route pr
        where
            pr.routed_at >= '2025-05-01 17:00:00'
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.onsite') = true
            and pr.store_id in ('TH02060149','TH01480142','TH03040255','TH71140100','TH02040114','TH02030145','TH15060836','TH01100108','TH04030108','TH04020410')
    ) pr2 on pr.pno = pr2.pno and pr.route_action = pr2.route_action
where
     pr2.pno is null
    and  pr.distance='仓外操作'