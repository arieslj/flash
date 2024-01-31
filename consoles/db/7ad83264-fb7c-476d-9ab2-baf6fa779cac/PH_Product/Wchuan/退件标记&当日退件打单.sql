-- wchuan需求
select
    pi.pno
    ,ss.name 网点
    ,pr.staff_info_id 操作待退件员工
    ,pr.store_name 操作部门
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 操作时间
    ,'待退件标记未退件' 类型
from ph_staging.parcel_info pi
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'PENDING_RETURN'
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    pi.dst_store_id in ('PH14010F01', 'PH14010F00')
    and pi.interrupt_category = 3
    and pi.returned_pno is null

union all

select
    pr2.pno
    ,ss2.name  网点
    ,pr2.staff_info_id 操作待退件员工
    ,pr2.store_name 操作部门
    ,convert_tz(pr2.routed_at, '+00:00', '+08:00') 操作时间
    ,'今日退件打印' 类型
from ph_staging.parcel_route pr2
left join ph_staging.sys_store ss2 on ss2.id = pr2.store_id
where
    pr2.store_id in ('PH14010F01', 'PH14010F00')
    and pr2.route_action = 'SYSTEM_AUTO_RETURN'
    and pr2.routed_at > '2023-08-09 16:00:00'
    and pr2.routed_at < '2023-08-10 16:00:00'

;

select
    t.*
 from dwm.dwd_ph_dc_should_be_delivery t
 left join ph_staging.parcel_route pr on pr.pno = t.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
 where
    t.p_date = '2023-08-09'
    and  t.dst_store_id in ('PH35172802','PH35300N03','PH35300M02')
    and pr.routed_at > '2023-08-08 16:00:00'

;



