select
    count(distinct if(pr.route_action in ('CHANGE_PARCEL_INFO'), pr.id, null)) 更改包裹信息
    ,count(distinct if(pr.route_action in ('REPLACE_PNO'), pr.id, null)) 换单打印信息
    ,count(distinct if(ss.category != 14 and pr.route_action in ('RECEIVED'), pr.id, null)) '揽收路由（目的地网点非PDC）'
    ,count(distinct if(pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN'), pr.id, null))  '到件入仓/整包到件的数'
    ,count(distinct if(pi.returned = 1 and ss.category = 14 and pr.route_action = 'RECEIVED', pr.id, null)) '"揽收退件" 退件单号目的地网点为 "PDC" 的包裹'
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    pr.routed_at >= date_sub(date_sub(curdate(), interval 7 day), interval 8 hour)