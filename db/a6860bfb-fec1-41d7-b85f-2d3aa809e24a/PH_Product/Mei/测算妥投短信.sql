with t as
    (
        select
            pi.pno
            ,pi.client_id
            ,pi.finished_at
            ,pi.ticket_delivery_staff_lng
            ,pi.ticket_delivery_staff_lat
            ,pi.dst_store_id
        from ph_staging.parcel_info pi
        where
            pi.state = 5
            and pi.returned = 0
            and pi.finished_at >= '2023-06-30 16:00:00'
            and pi.finished_at < '2023-08-31 16:00:00'
    )
select
    date(convert_tz(t1.finished_at, '+00:00', '+08:00')) 妥投日期
    ,t1.client_id 客户ID
    ,case
        when bc.client_id is not null then bc.client_name
        when bc.client_id is null and kp.id is not null then '普通KA'
        else '小c'
    end 客户类型
    ,case
        when st_distance_sphere(point(t1.ticket_delivery_staff_lng, t1.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) <= 100 then '0-100'
        when st_distance_sphere(point(t1.ticket_delivery_staff_lng, t1.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) > 100 and st_distance_sphere(point(t1.ticket_delivery_staff_lng, t1.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) <= 200 then '100-200'
        when st_distance_sphere(point(t1.ticket_delivery_staff_lng, t1.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) > 100 and st_distance_sphere(point(t1.ticket_delivery_staff_lng, t1.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) <= 200 then '200-300'
        when st_distance_sphere(point(t1.ticket_delivery_staff_lng, t1.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) > 100 and st_distance_sphere(point(t1.ticket_delivery_staff_lng, t1.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) <= 200 then '300-400'
        when st_distance_sphere(point(t1.ticket_delivery_staff_lng, t1.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) > 400 and st_distance_sphere(point(t1.ticket_delivery_staff_lng, t1.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) <= 500 then '400-500'
        when st_distance_sphere(point(t1.ticket_delivery_staff_lng, t1.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) > 500 then '500以上'
     end 妥投距离网点距离
    ,case
        when json_extract(ph.extra_value, '$.callDuration') >= 1 and json_extract(ph.extra_value, '$.callDuration') < 9 then '1-8'
        when json_extract(ph.extra_value, '$.callDuration') >= 9 and json_extract(ph.extra_value, '$.callDuration') < 11 then '9-10'
        when json_extract(ph.extra_value, '$.callDuration') >= 11 and json_extract(ph.extra_value, '$.callDuration') < 16 then '11-15'
        when json_extract(ph.extra_value, '$.callDuration') >= 16 and json_extract(ph.extra_value, '$.callDuration') < 21 then '16-20'
        when json_extract(ph.extra_value, '$.callDuration') >= 21 then '21以上'
        else '1以内'
    end 通话时长
    ,if(acc.pno is null, '否', '是') 是否有虚假投妥投诉
    ,count(distinct t1.pno) 包裹数
from t t1
left join
    (
        select
            pr.pno
            ,pr.extra_value
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'PHONE'
            and pr.routed_at < t1.finished_at
            and pr.routed_at > date_sub(curdate(), interval 90 day )
    ) ph on ph.pno = t1.pno and ph.rk = 1
left join ph_staging.sys_store ss on ss.id = t1.dst_store_id
left join ph_bi.abnormal_customer_complaint acc on acc.pno = t1.pno and acc.complaints_type = 1 -- 虚假妥投类
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join ph_staging.ka_profile kp on kp.id = t1.client_id
group by 1,2,3,4,5,6