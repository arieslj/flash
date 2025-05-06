with t as
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.store_id
            ,pr.store_name
            ,json_extract(pr.extra_value, '$.lng') lng
           ,json_extract(pr.extra_value, '$.lat') lat
        from rot_pro.parcel_route pr
        where
           pr.routed_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
            and (  ( pr.route_action = 'CHANGE_PARCEL_CLOSE' and pr.store_id = 12 )or ( pr.route_action = 'DELIVERY_CONFIRM' ) )
    )
select
    date_sub(curdate(), interval 1 day) as stat_date
    ,t1.pno
    ,pi.client_id 客户ID
    ,pi.dst_name 收件人姓名
    ,case pi.returned
        when 0 then '正向'
        when 1 then '逆向'
    end 正向逆向
    ,case pi.state
		  when 1 then '已揽收'
		  when 2 then '运输中'
		  when 3 then '派送中'
		  when 4 then '已滞留'
		  when 5 then '已签收'
		  when 6 then '疑难件处理中'
		  when 7 then '已退件'
		  when 8 then '异常关闭'
		  when 9 then '已撤销'
		  else pi.state
      end as '包裹状态'
    ,convert_tz(t1.routed_at, '+00:00', '+07:00') as 终态时间
    ,if(t1.route_action = 'DELIVERY_CONFIRM', t1.staff_info_id , null) 妥投快递员ID
    ,if(t1.route_action = 'DELIVERY_CONFIRM', t1.store_name, null) 妥投网点
    ,convert_tz(pr2.routed_at, '+00:00', '+07:00') as 最后一次有效路由时间
    ,ddd.CN_element 最后一次有效路由
    ,pr2.staff_info_id 最后一次有效路由操作员工ID
    ,pr2.store_name 最后一次有效路由网点
    ,pr2.region_name 最后一次有效路由网点大区
    ,pr2.piece_name 最后一次有效路由网点片区
    ,pr2.province_name 最后一次有效路由网点府
    ,if(t1.route_action = 'DELIVERY_CONFIRM', st_distance_sphere(point(t1.lng, t1.lat), point(ss.lng, ss.lat)), null) 妥投距离网点距离_m
    ,datediff(convert_tz(pr2.routed_at, '+00:00', '+07:00'), convert_tz(t1.routed_at, '+00:00', '+07:00')) 妥投和最后一次有效路由间隔天数
    ,pci.complaint_count 未收到包裹问询次数
from t t1
left join fle_staging.sys_store ss on ss.id = t1.store_id
left join fle_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > date_sub(curdate(), interval 3 month)
join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.route_action
            ,pr.store_id
            ,pr.store_name
            ,dt.piece_name
            ,dt.region_name
            ,dt.province_name
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dim_th_sys_store_rd dt on dt.store_id = pr.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
        where
            pr.routed_at > date_sub(curdate(), interval 31 hour)
            and pr.routed_at < date_sub(curdate(), interval 7 hour)
            and pr.routed_at > t1.routed_at
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) pr2 on pr2.pno = t1.pno and pr2.rk = 1
left join dwm.dwd_dim_dict ddd on ddd.element = pr2.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join
    (
        select
            t1.pno
            ,count(distinct pci.id) complaint_count
        from bi_center.parcel_complaint_inquiry pci
        join t t1 on t1.pno = pci.merge_column
        where
            pci.created_at > date_sub(curdate(), interval 2 month)
        group by 1
    ) pci on pci.pno = t1.pno
