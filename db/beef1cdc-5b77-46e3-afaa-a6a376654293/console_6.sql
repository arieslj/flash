select
    a.p_date `揽收日期`
    ,a.pno
    ,a.exhibition_weight `展示重量`
    ,a.chicun `展示尺寸`
    ,case a.article_category
        when '13' then 'A3塑料袋'
        when '14' then 'A4塑料'
        when '8' then 'A4气泡文件袋'
        when '7' then 'A4文件袋'
    end `包材类型`
    ,fle_dwd.dws_url(a.bucket_name,a.object_key,180) `最后一次复称链接`
from
    (
        select
            pi.*
            ,sa.*
            ,row_number() over (partition by sa.oss_bucket_key order by sa.created_at desc ) rk
        from
            (
                select
                    pi.p_date
                    ,pi.pno
                    ,pi.exhibition_weight
                    ,pi.article_category
                    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height ) chicun
                from fle_dwd.dwd_fle_parcel_info_di pi
                where
                    pi.p_date >= date_sub(`current_date`(), 7)
                    and pi.article_category in (13,14,8,7)
            ) pi
        join
            (
                select
                    sa.oss_bucket_key
                    ,sa.object_key
                    ,sa.bucket_name
                    ,sa.created_at
                from fle_dwd.dwd_drds_sorting_attachment_di sa
                where
                    sa.oss_bucket_type in ('SORT_PARCEL_INFO','DWS_PARCEL_WEIGHT_INFO')
                    and sa.p_date >= date_sub(`current_date`(), 7)
            ) sa on sa.oss_bucket_key = pi.pno

    ) a
where
    a.rk = 1