select
    ppd.screening_date 日期
    ,date_format(convert_tz(cdt.updated_at, '+00:00', '+08:00'), '%l%p') 时间段
    ,count(distinct ppd.pno)
from ph_staging.parcel_priority_delivery_detail ppd
join ph_staging.diff_info di on ppd.pno = di.pno
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    ppd.screening_date >= '2024-06-12'
    and cdt.state = 1
    and cdt.updated_at > date_sub(ppd.screening_date, interval 8 hour)
    and cdt.updated_at < date_add(ppd.screening_date, interval 16 hour)
group by 1,2