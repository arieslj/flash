select
    pi.src_name
    ,count(distinct pi.pno) 包裹量
    ,count(distinct if(pr.pno is not null, pi.pno, null)) 打单量
    ,count(distinct if(pr.pno is not null, pi.pno, null)) / count(distinct pi.pno) 打单率
from fle_staging.parcel_info pi
left join rot_pro.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'PRINTING' and pr.store_category = 12
where
    pi.src_name in ('Solomon', 'บริษัท ที่นอนโซโลม่อน จํากัด')
    and pi.created_at > '2025-01-19 17:00:00'
    and pi.created_at < '2025-01-22 17:00:00'
group by 1