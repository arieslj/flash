select
    pi2.pno
    ,convert_tz(a1.routed_at, '+00:00', '+08:00') 标记待退件日期
    ,convert_tz(pi2.created_at, '+00:00', '+08:00') 系统操作退回寄件人扫描时间
    ,if(pr2.pno is null or timestampdiff(hour, a1.routed_at, pr2.routed_at) > 24, 'y', 'n') 是否超24小时以上
    ,ss.name 退件责任网点
    ,s2.name 退件揽收网点
from
    (
        select
            pr.pno
            ,pr.routed_at
        from my_staging.parcel_route pr
        where
            pr.route_action = 'PENDING_RETURN'
            and pr.routed_at > '2024-01-31 16:00:00'
    ) a1
join my_staging.parcel_info pi on pi.pno = a1.pno
left join my_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
left join my_staging.parcel_route pr2 on pr2.pno = pi.returned_pno and pr2.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
left join my_staging.sys_store ss on ss.id = pi2.duty_store_id
left join my_staging.sys_store s2 on s2.id = pi2.ticket_pickup_store_id
where
    pi2.state not in (5,7,8,9)

