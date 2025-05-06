with t as
    (
        select
            pi.pno
            ,pi.dst_store_id
            ,pi.exhibition_weight
            ,pi.created_at
            ,ps.arrive_dst_route_at
            ,pi.state
            ,pi.client_id
            ,datediff(curdate(), ps.arrive_dst_route_at) detain_days
        from ph_staging.parcel_info pi
        left join ph_bi.parcel_sub ps on pi.dst_store_id = ps.arrive_dst_store_id and ps.pno = pi.pno
        where
            pi.state in (1,2,3,4,6)
            and datediff(curdate(), ps.arrive_dst_route_at) >= 5
            and ps.arrive_dst_route_at != '1970-01-01 00:00:00'
    )
select
    curdate() 统计日期date
    ,dp.region_name 大区Area
    ,dp.piece_name 片区district
    ,dp.store_name 网点DC
    ,t1.pno 运单Tracking_Number
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then 'Normal KA'
        when kp.`id` is null then 'GE'
    end as '客户类型Client_type`'
    ,t1.exhibition_weight/1000  重量Weights
    ,date_format(convert_tz(t1.created_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s')  包裹揽收时间Receive_time
    ,date_format(t1.arrive_dst_route_at, '%Y-%m-%d %H:%i:%s') '到达网点时间Arrival time at the DC'
    ,pr.route  最后有效路由Last_effective_route
    ,date_format(convert_tz(pr.routed_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') 最后有效路由操作时间Last_effective_routing_time
    ,concat(ddd2.CN_element, ddd2.EN_element)  包裹最新状态latest_parcel_status
    ,t1.detain_days '到达DC天数Days to DC'
    ,so.third_sorting_code 三段码third_sorting_code
from t t1
left join ph_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,concat(ddd.element, '-', ddd.CN_element) route
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and  ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            ps.pno
            ,ps.third_sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc) rk
        from ph_drds.parcel_sorting_code_info ps
        join t t1 on t1.pno = ps.pno
        where
            ps.created_at > date_sub(curdate(), interval 8 month)
    ) so on so.pno = t1.pno and so.rk = 1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_dim_dict ddd2 on ddd2.element = t1.state and ddd2.db = 'ph_staging' and ddd2.tablename = 'parcel_info' and ddd2.fieldname = 'state'

