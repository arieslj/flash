--hive
with sor as
(select
    sor.oss_bucket_key pno
    ,sor.url_sor
    ,sor.rn
from
    (
        select
            sor.oss_bucket_key
            ,fle_dwd.dws_url(sor.bucket_name,sor.object_key,180) as url_sor
            ,sor.bucket_name
            ,sor.rn
        from
            (
              select
                   oss_bucket_key
                  ,object_key
                  ,bucket_name
                  ,device_id
                  ,row_number() OVER(PARTITION BY oss_bucket_key ORDER BY created_at) rn
              from fle_dwd.dwd_drds_sorting_attachment_di sa
              join test.tmp_pno2_hss t on t.pno  = sa.oss_bucket_key
              where sa.p_date >= '2022-12-30'
              and sa.p_date < '2023-02-01'
              and oss_bucket_type in ( 'SORT_PARCEL_INFO')
            )sor
    ) sor
),

fc as
(
  select fc.pno
    ,fc.after_weight/1000 `复称重量`
    ,concat_ws('*', fc.after_length, fc.after_width, after_height) `复称尺寸`
    ,fc.rn
from
    (
        select
            pwr.pno
            ,pwr.store_id
            , pwr.before_weight
            , pwr.before_length
            , pwr.before_width
            , pwr.before_height
            , pwr.after_weight
            , pwr.after_length
            , pwr.after_width
            , pwr.after_height
            , pwr.rn
        from (

                        select
                            pwr.pno
                            ,pwr.store_id
                            ,pwr.before_weight
                            ,pwr.before_length
                            ,pwr.before_width
                            ,pwr.before_height
                            ,pwr.after_weight
                            ,pwr.after_length
                            ,pwr.after_width
                            ,pwr.after_height
                            ,row_number() over (partition by pwr.pno order by pwr.created_at  ) rn
                        from fle_dwd.dwd_fle_parcel_weight_revise_record_di pwr
                        join test.tmp_pno2_hss t on pwr.pno = t.pno
                        where p_date >= '2022-12-30'
                        and p_date < '2023-02-01'
                            and pwr.event in ('3') --3:sor
            ) pwr
    ) fc
)

SELECT
a.pno
,pi2.`揽收时间`
,oi.`客户重量`
,oi.`客户尺寸`
,pi2.`揽收重量`
,pi2.`揽收尺寸`
,pi2.`揽收照片`
,a.`第一次分拣图片`
,a.`第二次分拣图片`
,a.`第三次分拣图片`
,b.`第一次复称重量`
,b.`第二次复称重量`
,b.`第三次复称重量`
,b.`第一次复称尺寸`
,b.`第二次复称尺寸`
,b.`第三次复称尺寸`
from
(
  select
    t.pno
    ,if(sor1.rn=1,sor1.url_sor,null) `第一次分拣图片`
    ,if(sor1.rn=2,sor2.url_sor,null) `第二次分拣图片`
    ,if(sor1.rn=3,sor3.url_sor,null) `第三次分拣图片`
  from test.tmp_pno2_hss t
  left join sor sor1
  on t.pno=sor1.pno and sor1.rn=1
  left join sor sor2
  on t.pno=sor2.pno and sor2.rn=2
  left join sor sor3
  on t.pno=sor3.pno and sor3.rn=3
) a
left join
(
  select
    t.pno
    ,if(fc1.rn=1,fc1.`复称重量`,null) `第一次复称重量`
    ,if(fc1.rn=1,fc1.`复称尺寸`,null) `第一次复称尺寸`
    ,if(fc2.rn=2,fc1.`复称重量`,null) `第二次复称重量`
    ,if(fc2.rn=2,fc1.`复称尺寸`,null) `第二次复称尺寸`
    ,if(fc3.rn=3,fc1.`复称重量`,null) `第三次复称重量`
    ,if(fc3.rn=3,fc1.`复称尺寸`,null) `第三次复称尺寸`
from test.tmp_pno2_hss t
left join fc fc1
on t.pno=fc1.pno and fc1.rn=1
left join fc fc2
on t.pno=fc2.pno and fc2.rn=2
left join fc fc3
on t.pno=fc3.pno and fc3.rn=3
)b
on a.pno=b.pno

left join
(--揽收
  select
    pi2.pno
    ,pi2.created_at `揽收时间`
    ,pi2.exhibition_weight `揽收重量`
    ,concat_ws('*',pi2.exhibition_length,pi2.exhibition_width,pi2.exhibition_height) `揽收尺寸`
    ,sa.url `揽收照片`
  from
  (--揽收尺寸
      select
        pi2.pno
        ,pi2.created_at
        ,pi2.exhibition_weight
        ,pi2.exhibition_length
        ,pi2.exhibition_width
        ,pi2.exhibition_height
      from fle_dwd.dwd_fle_parcel_info_di pi2
      join test.tmp_pno2_hss t
        on pi2.pno=t.pno
      where pi2.p_date>='2022-12-30'
      and pi2.p_date<'2023-02-01'

  )pi2
  left join
  (--揽收照片
   select
     oss_bucket_key
     ,fle_dwd.dws_url(sa.bucket_name,sa.object_key,180) as url
   from test.tmp_pno2_hss t
   left join
   (
     select
        oss_bucket_key
        ,object_key
        ,bucket_name
        ,device_id
      from fle_dwd.dwd_drds_sorting_attachment_di sa
        join  test.tmp_pno2_hss t on t.pno = sa.oss_bucket_key
      where sa.p_date >= '2022-12-30'
      and sa.p_date < '2023-02-01'
      and oss_bucket_type in ( 'DWS_PARCEL_WEIGHT_INFO','PARCEL_UPDATE_WEIGHT_INFO')
    )sa on sa.oss_bucket_key = t.pno
  )sa on sa.oss_bucket_key=pi2.pno
)pi2
on pi2.pno=a.pno

left join
(--客户
  select
  oi.pno
  ,oi.weight `客户重量`
  ,concat_ws('*',oi.`length`,oi.width,oi.height) `客户尺寸`
  from test.tmp_pno2_hss t
  left join
    (
      select
        oi.pno
        ,oi.weight
        ,oi.`length`
        ,oi.width
        ,oi.height
      from fle_dwd.dwd_fle_order_info_di oi
      join test.tmp_pno2_hss t on t.pno = oi.pno
      where oi.p_date>='2022-12-30'
      and oi.p_date<'2023-02-01'
    )oi on oi.pno=t.pno
)oi on oi.pno=a.pno