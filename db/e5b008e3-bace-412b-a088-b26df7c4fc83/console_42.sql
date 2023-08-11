select
    pi.client_id
    ,pi.dst_phone 收件人
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,count(distinct pi.pno) 总包裹数
    ,count(distinct di.pno) 拒收包裹数
from ph_staging.parcel_info pi
left join ph_staging.diff_info di on pi.pno = di.pno and di.diff_marker_category in (2,17)
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = coalesce(di.store_id, pi.dst_store_id) and dp.stat_date = date_sub(curdate(), interval 1 day )
where
    pi.returned = 0
    and pi.state < 9
    and pi.client_id in ('CA0089','BA0635','A0142','BA0184','BA0056','BA0299','BA0577','CA3484','BA0258','CA1026','BA0323','BA0344','CA1644','BA0599','AA0140','CA1281','CA0548','CA0179','CA1280','CA1385','CA3478','BA0391','AA0111','AA0076','BA0441')
    and pi.created_at >= '2023-06-30 16:00:00'
    and pi.created_at < '2023-07-31 16:00:00'
group by 1,2,3


;




select
    pi.pno
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 'pickup time'
    ,src_name 'sender name'
    ,src_phone 'sender contact'
    ,pi.dst_name 'Consignee name'
    ,pi.dst_phone 'Consignee number'
    ,pi.dst_detail_address 'Consignee address'
    ,dp1.store_name 'pickup dc'
    ,dp1.piece_name 'pickup district'
    ,dp1.region_name 'pickup area'
    ,concat(hsi.name, '(', hsi.staff_info_id, ')') 'pickup courier'
    ,pi.cod_amount/100 COD
    ,pi.exhibition_weight 'weight/g'
    ,dp2.store_name 'destination dc'
    ,dp2.piece_name 'destination district'
    ,dp2.region_name 'destination area'
from ph_staging.parcel_info pi
left join dwm.dim_ph_sys_store_rd dp1 on dp1.store_id = pi.ticket_pickup_store_id and dp1.stat_date = date_sub(curdate(), interval 1 day )
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_pickup_staff_info_id
where
    if(hour(now()) >= 17, pi.created_at > date_sub(curdate(), interval 8 hour ) and pi.created_at <= date_add(curdate(), interval 9 hour), pi.created_at > date_sub(curdate(), interval 15 hour) and pi.created_at < date_sub(curdate(), interval 8 hour) )


;


select
    kp.id 客户ID
    ,ss.id 网点ID
    ,ss.name 网点
    ,count(distinct pi.pno) 总包裹数
    ,count(distinct if(pr.pno is not null , pi.pno, null)) 总拒收包裹数
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD包裹数
    ,count(distinct if(pr.pno is not null and pi.cod_enabled = 1, pi.pno, null)) COD拒收包裹数
from ph_staging.parcel_info pi
join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.marker_category in (2,17)
left join ph_staging.sys_store ss on ss.id = coalesce(pi.ticket_delivery_store_id, dst_store_id)
where
    pi.returned = 0
    and pi.state < 9
    and pi.created_at >= '2023-06-30 16:00:00'
    and pi.created_at < '2023-07-31 16:00:00'
    and bc.client_id is null
group by 1,2,3


;



select
    ds.pno
    ,if(ds.arrival_scan_route_at < curdate(), '昨天', '今天' ) 包裹日期
from ph_bi.dc_should_delivery_today ds
where
    ds.stat_date = '2023-08-01'
#     and ds.store_id = 'PH61280100'
    and ds.pno = 'P61281YPAE8CN'