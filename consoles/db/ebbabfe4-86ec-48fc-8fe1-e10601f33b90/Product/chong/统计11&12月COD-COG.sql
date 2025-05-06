select
    case
        when pi.cod_enabled = 1 and pi.cod_amount > 0 and pi.cod_amount <= 10000 then '1-100'
        when pi.cod_enabled = 1 and pi.cod_amount > 10000 and pi.cod_amount <= 20000 then '101-200'
        when pi.cod_enabled = 1 and pi.cod_amount > 20000 and pi.cod_amount <= 30000 then '201-300'
        when pi.cod_enabled = 1 and pi.cod_amount > 30000 and pi.cod_amount <= 40000 then '301-400'
        when pi.cod_enabled = 1 and pi.cod_amount > 40000 and pi.cod_amount <= 50000 then '401-500'
        when pi.cod_enabled = 1 and pi.cod_amount > 50000  then '500以上'
        when pi.cod_enabled = 0 then '0'
    end COD分段
    ,count(pi.pno) 包裹数
from my_staging.parcel_info pi
left join my_staging.order_info oi on pi.pno = oi.pno
where
    pi.returned = 0
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-12-31 16:00:00'
group by 1

;


select
    case
        when oi.cogs_amount > 0 and oi.cogs_amount <= 10000 then '1-100'
        when oi.cogs_amount > 10000 and oi.cogs_amount <= 20000 then '101-200'
        when oi.cogs_amount > 20000 and oi.cogs_amount <= 30000 then '201-300'
        when oi.cogs_amount > 30000 and oi.cogs_amount <= 40000 then '301-400'
        when oi.cogs_amount > 40000 and oi.cogs_amount <= 50000 then '401-500'
        when oi.cogs_amount > 50000  then '500以上'
        when oi.cogs_amount = 0 or oi.cogs_amount is null then '0'
    end COD分段
    ,count(pi.pno) 包裹数
from my_staging.parcel_info pi
left join my_staging.order_info oi on pi.pno = oi.pno
where
    pi.returned = 0
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-12-31 16:00:00'
group by 1