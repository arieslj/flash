-- 上报错分网点是妥投网点
select
    di.pno
    ,'上报错分网点是妥投网点' type
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
where
    di.created_at > '2024-03-31 16:00:00'
    and di.created_at < '2024-04-30 16:00:00'
    and pi.state = 5
    and pi.ticket_delivery_store_id = di.store_id
    and di.diff_marker_category in (23,30,31)
group by 1

union all

select
    di.pno
    ,'错分上报大于3次' type
from ph_staging.diff_info di
join
    (
        select
            di.pno
        from ph_staging.diff_info di
        where
            di.created_at > '2024-03-31 16:00:00'
            and di.created_at < '2024-04-30 16:00:00'
            and di.diff_marker_category in (23,30,31)
        group by 1
    ) a on a.pno = di.pno
where
    di.created_at > date_sub(curdate(), interval 3 month)
    and di.diff_marker_category in (23,30,31)
group by 1
having count(distinct di.id) >= 3
;

select
    a.stat_date 日期
    ,a.pno_cnt 应派数量
    ,b.pno_cnt 错分上报数量
    ,b.pno_cnt / a.pno_cnt 错分上报率
from
    (
        select
            d.stat_date
            ,count(distinct d.pno) pno_cnt
        from ph_bi.dc_should_delivery_2024_04 d
        where
            d.stat_date >= '2024-01-01'
            and d.stat_date < '2024-05-01'
        group by 1
    ) a
left join
    (
        select
            date(convert_tz(di.created_at, '+00:00', '+08:00')) p_date
            ,count(distinct di.pno) pno_cnt
        from ph_staging.diff_info di
        where
            di.created_at > '2024-03-31 16:00:00'
            and di.created_at < '2024-04-30 16:00:00'
            and di.diff_marker_category in (23,30,31)
        group by 1
    ) b on a.stat_date = b.p_date

;


-- 整体错分上报

select
    case di.diff_marker_category
        when 23 then '详细地址错误'
        when 30 then '送错网点'
        when 31 then '省市乡邮编错误'
    end 错分类型
    ,count(distinct di.pno) 包裹量
    ,row_number() over ()
from ph_staging.diff_info di
where
    di.created_at > '2024-03-31 16:00:00'
    and di.created_at < '2024-04-30 16:00:00'
    and di.diff_marker_category in (23,30,31)
group by 1

;


select
    di.pno
    ,'lazada' client_name
from ph_staging.diff_info di
join dwm.dwd_ex_ph_lazada_sla_detail la on la.pno = di.pno
where
    di.created_at > '2024-03-31 16:00:00'
    and di.created_at < '2024-04-30 16:00:00'
    and di.diff_marker_category in (23,30,31)
    and la.delievey_end_date <= coalesce(la.finished_date, curdate())
group by 1

union all

select
    di.pno
    ,'shopee' client_name
from ph_staging.diff_info di
join dwm.dwd_ex_ph_shopee_sla_detail sp on sp.pno = di.pno
where
    di.created_at > '2024-03-31 16:00:00'
    and di.created_at < '2024-04-30 16:00:00'
    and di.diff_marker_category in (23,30,31)
    and sp.delievey_end_date <= coalesce(sp.finished_date, curdate())
group by 1

union all

select
    di.pno
    ,'tiktok' client_name
from ph_staging.diff_info di
join dwm.dwd_ex_ph_tiktok_sla_detail tt on tt.pno = di.pno
where
    di.created_at > '2024-03-31 16:00:00'
    and di.created_at < '2024-04-30 16:00:00'
    and di.diff_marker_category in (23,30,31)
    and tt.end_date <= coalesce(tt.finished_date, curdate())
group by 1