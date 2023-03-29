-- 疑难件整体数据
select
    *
from
    (

    ) a
left join
    (
        select
            date(convert_tz(di.created_at, '+00:00', '+08:00')) 日期
            ,count(distinct di.pno) 疑难件包裹量
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'
        group by 1
    ) b