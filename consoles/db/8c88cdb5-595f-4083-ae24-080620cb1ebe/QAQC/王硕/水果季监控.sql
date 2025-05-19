select
    date(convert_tz(pi.created_at, '+00:00', '+07:00')) as 揽件日期
    ,count(distinct if(ss.short_name = 'KKW', pi.pno, null)) as KKW揽收量
    ,count(distinct if(ss.short_name = 'LMS', pi.pno, null)) as LMS揽收量
    ,count(distinct if(ss.short_name = 'MAK', pi.pno, null)) as MAK揽收量
    ,count(distinct if(ss.short_name = 'PPR', pi.pno, null)) as PPR揽收量
    ,count(distinct if(ss.short_name = 'WMI', pi.pno, null)) as WMI揽收量
    ,count(distinct if(ss.short_name = 'WSD', pi.pno, null)) as WSD揽收量
    ,count(distinct if(ss.short_name = 'CHT', pi.pno, null)) as CHT揽收量
    ,count(distinct if(ss.short_name = 'KIG', pi.pno, null)) as KIG揽收量
    ,count(distinct if(ss.short_name = 'KWA', pi.pno, null)) as KWA揽收量
    ,count(distinct if(ss.short_name = 'KGP', pi.pno, null)) as KGP揽收量
    ,count(distinct if(ss.short_name = '2PAW', pi.pno, null)) as 2PAW揽收量
    ,count(distinct if(ss.short_name = '2CHT', pi.pno, null)) as 2CHT揽收量
    ,count(distinct if(ss.short_name = '2TIM', pi.pno, null)) as 2TIM揽收量
    ,count(distinct if(ss.short_name = '7KUG', pi.pno, null)) as 7KUG揽收量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH05110400', pi.pno, null)) as 目的HUB_CT1量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH20050103', pi.pno, null)) as 目的HUB_EA1量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH02030204', pi.pno, null)) as 目的HUB_LAS量
    ,count(distinct if(substring_index(dt.ancestry, '/', 1) = 'TH21011305', pi.pno, null)) as 目的HUB_EA2量
    ,count(distinct pi.pno) as 合计揽收量
from fle_staging.parcel_info pi
join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store dt on dt.id = pi.dst_store_id
where
    ss.short_name in ('KKW','LMS','MAK','PPR','WMI','WSD','CHT','KIG','KWA','KGP','2PAW','2CHT','2TIM','7KUG')
    and substring_index(dt.ancestry, '/', 1) in ('TH05110400', 'TH20050103', 'TH02030204', 'TH21011305')
    and pi.returned = 0
    and pi.state < 9
    and pi.article_category = 11
    and pi.created_at >= '2025-04-30 17:00:00'
group by 1
order by 1

;


select
    ss.id
    ,ss.name
    ,ss.short_name
from fle_staging.sys_store ss
where
    ss.short_name in ('CT1','PDT','EA1','EA2')

;

select
    ss.id
    ,substring_index(ss.ancestry, '/', 1) ss_ancestry
from fle_staging.sys_store ss
where
    id = 'TH25030402'