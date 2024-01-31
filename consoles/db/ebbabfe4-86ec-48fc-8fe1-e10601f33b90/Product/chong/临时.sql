
select
    t.pno
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
from my_staging.parcel_info pi
join tmpale.tmp_my_pno_lj_0126 t on t.pno = pi.pno
left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join my_staging.parcel_additional_info pai on pai.pno = pi2.pno