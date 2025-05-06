with t as
    (
        select
            convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
            ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) pick_date
            ,date_sub(date(convert_tz(pi.created_at, '+00:00', '+08:00')), interval 8 hour) start_at
            ,date_add(date(convert_tz(pi.created_at, '+00:00', '+08:00')), interval 16 hour) end_at
            ,pi.pno
            ,pi.ticket_pickup_store_id
            ,ss.name ss_name
            ,pi.state
            ,pi.ticket_pickup_staff_info_id
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        where
            pi.created_at > '2024-09-30 16:00:00'
            and pi.created_at < '2024-10-03 16:00:00'
            and pi.returned = 0
            and pi.client_id not in ('AA0173', 'AA0170', 'AA0171', 'AA0169', 'AA0172')
            and ss.category in (1,10,14)
#             and pi.pno = 'P16056THXUZAG'
    )
select
    t1.pno 运单号
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 运单状态
    ,t1.pick_date 揽收日期
    ,t1.pick_time 揽收时间
    ,t1.ss_name 揽收网点
    ,t1.ticket_pickup_staff_info_id 揽收快递员
    ,if(otr.pno is not null, 1, 0) 当日是否有其他路由
    ,if(plt.pno is not null, 1, 0) 是否判责丢失
from t t1
left join
    (
        select
            distinct
            t1.pno
            ,t1.pick_date
            ,pr.store_id
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-09-30 16:00:00'
            and pr.routed_at < '2024-10-03 16:00:00'
            and pr.routed_at > t1.start_at
            and pr.routed_at < t1.end_at
            and pr.route_action = 'RECEIVE_WAREHOUSE_SCAN'
    ) rws on rws.pno = t1.pno and rws.pick_date = t1.pick_date and rws.store_id = t1.ticket_pickup_store_id
left join
    (
        select
            distinct
            t1.pno
            ,t1.pick_date
            ,pr.store_id
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-09-30 16:00:00'
            and pr.routed_at < '2024-10-03 16:00:00'
            and pr.routed_at > t1.start_at
            and pr.routed_at < t1.end_at
#             and pr.store_id = t1.ticket_pickup_store_id
            and pr.route_action in ('STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) otr on otr.pno = t1.pno and otr.pick_date = t1.pick_date and otr.store_id = t1.ticket_pickup_store_id
left join ph_bi.parcel_lose_task plt on plt.pno = t1.pno and plt.state = 6 and plt.penalties > 0 and plt.duty_result = 1 and plt.created_at > '2024-10-01'
where
    rws.pno is null
