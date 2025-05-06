select
    pi.dst_phone
    ,sum(pi.cod_amount/100) cod总金额
    ,count(pi.pno) cod单量
    ,count(if(pi.state = 7, pi.pno, null)) cod退件量
    ,count(if(pi.state = 7, pi.pno, null)) / count(pi.pno)  退件率
from fle_staging.parcel_info pi
where
    pi.created_at > '2024-03-31 17:00:00'
    and pi.cod_amount > 500000
group by pi.dst_phone
having count(if(pi.state = 7, pi.pno, null)) / count(pi.pno) > 0.9