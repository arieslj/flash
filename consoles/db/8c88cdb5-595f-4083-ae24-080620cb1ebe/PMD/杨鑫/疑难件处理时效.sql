select
    date (convert_tz(cdt.created_at,'+00:00','+07:00')) p_date
    ,cg.name 客服组
    ,count(distinct cdt.diff_info_id) 已生成
    ,count(distinct if(cdt.state = 1, cdt.diff_info_id, null)) 已处理
    ,count(distinct if(cdt.state = 2, cdt.diff_info_id, null)) 沟通中
    ,count(distinct if(cdt.state = 0, cdt.diff_info_id, null)) 未处理
    ,sum(if(cdt.state = 1, timestampdiff(second, cdt.first_operated_at, cdt.last_operated_at)/3600, 0)) 时效总量
    ,sum(if(cdt.state = 1, timestampdiff(second, cdt.first_operated_at, cdt.last_operated_at)/3600, 0)) / count(distinct if(cdt.state = 1, cdt.diff_info_id, null)) 时效
    ,sum(if(cdt.first_operated_at is not null, timestampdiff(second, cdt.created_at, cdt.first_operated_at)/3600, 0)) 首次响应总量
    ,count(distinct if(cdt.first_operated_at is not null, cdt.diff_info_id, null)) 首次响应个数
    ,sum(if(cdt.first_operated_at is not null, timestampdiff(second, cdt.created_at, cdt.first_operated_at)/3600, 0))/count(distinct if(cdt.first_operated_at is not null, cdt.diff_info_id, null)) 首次响应时长
     -- d0
    ,(count(distinct if(cdt.created_at <= date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 11 hour) and cdt.first_operated_at < date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 17 hour), cdt.diff_info_id, null )) + count(distinct if(cdt.created_at > date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 11 hour) and cdt.first_operated_at < date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 29 hour), cdt.diff_info_id, null ))) D0及时量
    ,(count(distinct if(cdt.created_at <= date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 11 hour) and cdt.first_operated_at < date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 17 hour), cdt.diff_info_id, null )) + count(distinct if(cdt.created_at > date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 11 hour) and cdt.first_operated_at < date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 29 hour), cdt.diff_info_id, null ))) / count(distinct cdt.diff_info_id) D0及时受理率
    -- d1
    ,(count(distinct if(cdt.created_at <= date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 11 hour) and cdt.first_operated_at > date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 17 hour) and cdt.first_operated_at <  date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 41 hour), cdt.diff_info_id, null )) + count(distinct if(cdt.created_at > date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 11 hour) and cdt.first_operated_at > date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 29 hour) and cdt.first_operated_at <  date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 41 hour), cdt.diff_info_id, null ))) D1及时量
    ,(count(distinct if(cdt.created_at <= date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 11 hour) and cdt.first_operated_at > date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 17 hour) and cdt.first_operated_at <  date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 41 hour), cdt.diff_info_id, null )) + count(distinct if(cdt.created_at > date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 11 hour) and cdt.first_operated_at > date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 29 hour) and cdt.first_operated_at <  date_add(date (convert_tz(cdt.created_at,'+00:00','+08:00')), interval 41 hour), cdt.diff_info_id, null ))) / count(distinct cdt.diff_info_id) D1及时受理率
    -- 2d关闭
    ,count(distinct if(cdt.state = 1 and timestampdiff(second, cdt.created_at, cdt.last_operated_at)/3600 < 48, cdt.diff_info_id, null)) 问题件2d关闭量
    ,count(distinct if(cdt.state = 1 and timestampdiff(second, cdt.created_at, cdt.last_operated_at)/3600 < 48, cdt.diff_info_id, null)) / count(distinct cdt.diff_info_id) 问题件2d关闭率
    -- 3d关闭
    ,count(distinct if(cdt.state = 1 and timestampdiff(second, cdt.created_at, cdt.last_operated_at)/3600 < 72, cdt.diff_info_id, null)) 问题件3d关闭量
    ,count(distinct if(cdt.state = 1 and timestampdiff(second, cdt.created_at, cdt.last_operated_at)/3600 < 72, cdt.diff_info_id, null)) / count(distinct cdt.diff_info_id) 问题件3d关闭率
    -- 5d关闭
    ,count(distinct if(cdt.state = 1 and timestampdiff(second, cdt.created_at, cdt.last_operated_at)/3600 < 120, cdt.diff_info_id, null)) 问题件5d关闭量
    ,count(distinct if(cdt.state = 1 and timestampdiff(second, cdt.created_at, cdt.last_operated_at)/3600 < 120, cdt.diff_info_id, null)) / count(distinct cdt.diff_info_id) 问题件5d关闭率
    -- 7d关闭
    ,count(distinct if(cdt.state = 1 and timestampdiff(second, cdt.created_at, cdt.last_operated_at)/3600 < 168, cdt.diff_info_id, null)) 问题件7d关闭量
    ,count(distinct if(cdt.state = 1 and timestampdiff(second, cdt.created_at, cdt.last_operated_at)/3600 < 168, cdt.diff_info_id, null)) / count(distinct cdt.diff_info_id) 问题件7d关闭率
from fle_staging.customer_diff_ticket cdt
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = cdt.client_id and cgkr.deleted = 0
left join fle_staging.customer_group cg on cg.id = cgkr.customer_group_id
where
    cdt.organization_type = 2
    and cdt.vip_enable = 1
    and cdt.created_at >= date_sub('${sdate}', interval 7 hour)
    and cdt.created_at < date_add('${edate}', interval 17 hour)
    and cdt.state not in (5,6)
    -- and bc.client_name in ('lazada', 'shopee', 'tiktok')
    and cg.name in ('LAZADA', 'Shopee', 'TikTok', 'KAM CN', 'THAI KAM')
group by 1,2
order by 1,2
