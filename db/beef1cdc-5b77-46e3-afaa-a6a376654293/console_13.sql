select
    *
from fle_dwd.dwd_drds_parcel_sorting_code_info_di prc
where
    prc.p_date >= '2023-08-01'
    and prc.pno = 'PT353222EACY9AP'