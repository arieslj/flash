select
    month(pi.p_date) p_month
    ,count(pi.pno) pi_count
from fle_dwd.dwd_fle_parcel_info_di pi
where
    pi.p_date >= '2023-01-01'
    and pi.p_date < '2023-07-01'
    and pi.state < '9'
    and pi.returned = '0'
    and pi.client_id in ('AA0121','AA0050','AA0128','AA0089','AA0139','AA0131','AA0090','AA0080','AA0051','AA0132')
group by 1
;


