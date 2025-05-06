with t as
    (
        select
            convert_tz(di.created_at, '+00:00', '+07:00') diff_time
            ,date( convert_tz(di.created_at, '+00:00', '+07:00')) diff_date
            ,di.pno
        from fle_staging.diff_info di
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.created_at > '2023-12-31 17:00:00'
            and di.diff_marker_category = 17
            and pi.client_id in ('AA0660', 'AA0661', 'AA0703', 'AA0823', 'AA0824')
    )
select
    t1.diff_date
    ,count(distinct t1.pno) as total
    ,count(distinct if(acc.pno is not null or vr.pno is not null, t1.pno, null))/count(distinct t1.pno) rate
from t t1
left join
    (
        select
            acc.pno
        from bi_pro.abnormal_customer_complaint acc
        join t t1 on t1.pno = acc.pno
        where
            acc.created_at > t1.diff_time
            and acc.complaints_sub_type = 61 -- 拒收投诉
            and acc.created_at > '2023-12-01'
        group by 1
    ) acc on acc.pno = t1.pno
left join
    (
        select
            t1.pno
        from nl_production.violation_return_visit vrv
        join t t1 on t1.pno = vrv.link_id
        where
            vrv.type = 3
            and vrv.created_at > '2023-12-31'
            and vrv.created_at > t1.diff_time
            and vrv.visit_result in (18,8,19,20,21,22,31,32)
        group by 1
    ) vr on vr.pno = t1.pno
group by 1
;


with t as
    (
        select
            convert_tz(di.created_at, '+00:00', '+07:00') diff_time
            ,date( convert_tz(di.created_at, '+00:00', '+07:00')) diff_date
            ,di.store_id
            ,di.pno
        from fle_staging.diff_info di
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.created_at > '2023-12-31 17:00:00'
            and di.diff_marker_category = 17
            and pi.client_id in ('AA0660', 'AA0661', 'AA0703', 'AA0823', 'AA0824')
    )
select
    t1.diff_time 上报问题件时间
    ,t1.pno 运单号
    ,dt.store_name 上报网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,if(acc.pno is not null, 'Y', 'N') 是否被投诉虚假拒收
    ,if(vr.pno is not null, 'Y', 'N') 是否回访确认虚假拒收
from t t1
left join dwm.dim_th_sys_store_rd dt on dt.store_id = t1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            acc.pno
        from bi_pro.abnormal_customer_complaint acc
        join t t1 on t1.pno = acc.pno
        where
            acc.created_at > t1.diff_time
            and acc.complaints_sub_type = 61 -- 拒收投诉
            and acc.created_at > '2023-12-01'
        group by 1
    ) acc on acc.pno = t1.pno
left join
    (
        select
            t1.pno
        from nl_production.violation_return_visit vrv
        join t t1 on t1.pno = vrv.link_id
        where
            vrv.type = 3
            and vrv.created_at > '2023-12-31'
            and vrv.created_at > t1.diff_time
            and vrv.visit_result in (18,8,19,20,21,22,31,32)
        group by 1
    ) vr on vr.pno = t1.pno
where
    acc.pno is not null
    or vr.pno is not null