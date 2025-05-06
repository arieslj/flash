
select
    pr.pno
    ,'联系不上客户' 标记类型
    ,count(distinct date (convert_tz(pr2.routed_at, '+00:00', '+08:00'))) 标记次数
from ph_staging.parcel_route pr
join ph_staging.parcel_route pr2 on pr2.pno = pr.pno and pr2.marker_category = 1 and pr2.created_at > date_sub(curdate(), interval 2 month)
where
    pr.routed_at > '2024-08-08 16:00:00'
    and pr.route_action = 'DELIVERY_CONFIRM'
group by 1
having count(distinct date (convert_tz(pr2.routed_at, '+00:00', '+08:00'))) >= 3


;

select
    pr.pno
    ,'客户改约时间' 标记类型
    ,count(distinct date (convert_tz(pr2.routed_at, '+00:00', '+08:00'))) 标记次数
from ph_staging.parcel_route pr
join ph_staging.parcel_route pr2 on pr2.pno = pr.pno and pr2.marker_category = 70 and pr2.created_at > date_sub(curdate(), interval 2 month)
where
    pr.routed_at > '2024-08-08 16:00:00'
    and pr.route_action = 'DELIVERY_CONFIRM'
group by 1
having count(distinct date (convert_tz(pr2.routed_at, '+00:00', '+08:00'))) >= 3

