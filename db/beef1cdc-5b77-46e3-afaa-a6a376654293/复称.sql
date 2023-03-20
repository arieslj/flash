with fc as
(
    select
        pwr.pno
        ,pwr.after_weight
        ,row_number() over (partition by pwr.pno order by pwr.created_at) rn
    from fle_dwd.dwd_fle_parcel_weight_revise_record_di pwr
    join test.tmp_pno2_hss t on pwr.pno = t.pno
    where
        pwr.p_date  >= '2023-01-01'
        and pwr.p_date < '2023-03-01'
)
, sor as
(
    select
        sa.oss_bucket_key
        ,sa.object_key
        ,sa.bucket_name
        ,row_number() over (partition by sa.oss_bucket_key order by sa.created_at) rn
    from fle_dwd.dwd_drds_sorting_attachment_di sa
    join test.tmp_pno2_hss t on sa.oss_bucket_key = t.pno
    where
        sa.p_date >= '2023-01-01'
        and sa.p_date < '2023-03-01'
        and sa.oss_bucket_type in ('SORT_PARCEL_INFO')
)
select
    t.pno
    ,oi.weight `客户重量`
    ,pii.exhibition_weight `揽收重量`
    ,fle_dwd.dws_url(pic.bucket_name,pic.object_key,180) as url_pick
    ,fc1.after_weight `第一次复称重量`
    ,fle_dwd.dws_url(sor1.bucket_name,sor1.object_key,180) as  `第一次复称图片链接`
    ,fc2.after_weight `第二次复称重量`
    ,fle_dwd.dws_url(sor2.bucket_name,sor2.object_key,180) as  `第二次复称图片链接`
    ,fc3.after_weight `第三次复称重量`
    ,fle_dwd.dws_url(sor3.bucket_name,sor3.object_key,180) as  `第三次复称图片链接`
from test.tmp_pno2_hss t
left join
    ( -- 揽收重量
        select
            pi.pno
            ,pi.exhibition_weight
        from fle_dwd.dwd_fle_parcel_info_di pi
        join test.tmp_pno2_hss t on t.pno = pi.pno
        where
            pi.p_date >= '2023-01-01'
            and pi.p_date < '2023-02-01'
    ) pii on pii.pno = t.pno
left join
    ( -- 揽收照片
        select
            sa.oss_bucket_key
            ,sa.object_key
            ,sa.bucket_name
        from fle_dwd.dwd_drds_sorting_attachment_di sa
        join test.tmp_pno2_hss t on t.pno = sa.oss_bucket_key
        where
            sa.p_date >= '2023-01-01'
            and sa.p_date < '2023-03-01'
            and sa.oss_bucket_type = 'DWS_PARCEL_WEIGHT_INFO'
    ) pic on pic.oss_bucket_key = t.pno
left join
    (
        select
            oi.pno
            ,oi.weight
        from fle_dwd.dwd_fle_order_info_di oi
        join test.tmp_pno2_hss t on t.pno = oi.pno
        where
            oi.p_date >= '2022-10-01'
            and oi.p_date < '2023-02-01'
    ) oi on oi.pno = t.pno
left join fc fc1 on fc1.pno = t.pno and fc1.rn = 1
left join fc fc2 on fc2.pno = t.pno and fc2.rn = 2
left join fc fc3 on fc3.pno = t.pno and fc3.rn = 3
left join sor sor1 on sor1.oss_bucket_key = t.pno and sor1.rn = 1
left join sor sor2 on sor2.oss_bucket_key = t.pno and sor2.rn = 1
left join sor sor3 on sor3.oss_bucket_key = t.pno and sor3.rn = 1