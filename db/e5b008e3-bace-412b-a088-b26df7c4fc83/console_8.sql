select
    *
from ph_bi.should_stocktaking_parcel_info_recently ssp
left join ph_staging.parcel_info pi on pi.pno = ssp.pno
where
    ssp.stat_date = curdate()
    and ssp.hour = hour(now())
group by 1
;
select  * from