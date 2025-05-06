select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal '应处理问题件数(剔除lost)'
    ,t2.deal_num 完结问题件数
    ,t1.should_not 应处理问题件数当月未完成
    ,t1.month_deal_ratio 当月问题件完结率
    ,zl.zl_num 滞留问题件单数
    ,t1.dam_short_ratio 破损短少问题件占比
    ,t1.cod_ratio COD金额问题件占比
    ,t1.other_ratio 其他问题件占比
    ,t2.avg_deal_time 完结问题件单均处理时长
    ,t2.dam_short_avg_time 破损短少问题件单均完结时长
    ,t2.cod_avg_time COD金额问题件单均完结时长
    ,t2.other_avg_time 其他问题件单均完结时长
    ,t1.jiedan_avg_time '问题件单均接单时长'
    ,t1.fin_avg_time '问题件单均接单-结单时长'
    ,cf.repeat_num 问题件重复包裹数
from
    ( -- 应处理
        select
            month(date_add(cdt.created_at, interval 13 hour)) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) should_deal
            ,count(distinct if(di.state != 1 or ( di.state = 1 and di.updated_at > date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour)), cdt.id, null))  should_not
            ,count(distinct if(di.state = 1 and di.updated_at < date_add(adddate(last_day(date_add(cdt.created_at, interval 6 hour)), 1),interval 11 hour), cdt.id, null))/count(distinct cdt.id ) month_deal_ratio
            ,count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) dam_short_ratio
            ,count(distinct if(pi.cod_enabled = 1, cdt.id, null))/count(distinct cdt.id) cod_ratio
            ,count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))/count(distinct cdt.id ) other_ratio
            ,sum(if(cdt.state != 0, timestampdiff(second , cdt.created_at, cdt.first_operated_at)/3600, 0 ))/count(distinct if(cdt.state != 0 ,cdt.id, null)) jiedan_avg_time
            ,sum(if(cdt.state = 1, timestampdiff(second ,cdt.first_operated_at, cdt.updated_at)/3600, 0 ))/count(distinct if(cdt.state = 1,cdt.id, null)) fin_avg_time
        from fle_staging.customer_diff_ticket cdt
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2022-11-30 11:00:00'
            and cdt.created_at < '2023-02-28 11:00:00'
        group by 1,2
    ) t1
left join
    ( -- 已完结
        select
            month(cdt.updated_at) month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id ) deal_num
            ,sum(timestampdiff(second, cdt.created_at, cdt.updated_at)/3600)/count(distinct cdt.id) avg_deal_time
            ,sum(if(di.diff_marker_category in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(di.diff_marker_category in (5,6,20,21), cdt.id, null)) dam_short_avg_time
            ,sum(if(pi.cod_enabled = 1, timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 1, cdt.id, null)) cod_avg_time
            ,sum(if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), timestampdiff(second, cdt.created_at, cdt.updated_at)/3600, 0))/count(distinct if(pi.cod_enabled = 0 and di.diff_marker_category not in (5,6,20,21), cdt.id, null))  other_avg_time
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.diff_marker_category not in (7,22)
            and cdt.updated_at >= '2022-11-30 17:00:00'
            and cdt.updated_at < '2023-02-28 17:00:00'
            and di.state = 1 -- 已处理
        group by 1,2
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    ( -- 滞留
        select
            '12' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2022-12-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2022-12-31 17:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-01-31 11:00:00'  -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-01-31 11:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,case
                when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                else cg.name
            end cg_name
            ,count(distinct cdt.id) zl_num
        from fle_staging.customer_diff_ticket cdt
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            di.diff_marker_category not in (7,22)
            and cdt.created_at >= '2021-12-31 17:00:00'
            and cdt.created_at < '2023-02-28 11:00:00' -- 18点之前产生
            and
                (
                    di.state != 1 or
                    (di.state = 1 and di.updated_at > '2023-02-28 17:00:00')
                )
        group by 1,2
    ) zl  on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.cg_name
            ,t.month_d
            ,count(distinct t.pno) repeat_num
        from
            (
                select
                    cdt.id
                    ,month(date_add(cdt.created_at, interval 13 hour)) month_d
                    ,case
                        when cdt.client_id = 'AA0416' then 'Lazada Buyer Return'
                        when cdt.client_id in ('AA0707','AA0657','AA0606') then 'Shopee Buyer Return'
                        when cdt.client_id in ('AA0649','AA0650') then 'Shein Buyer Return'
                        else cg.name
                    end cg_name
                    ,di.pno
                    ,count(cdt.id) over (partition by month(date_add(cdt.created_at, interval 13 hour)), di.pno) pno_count
                from fle_staging.customer_diff_ticket cdt
                left join fle_staging.diff_info di on di.id = cdt.diff_info_id
                join fle_staging.customer_group cg on cdt.group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
                where
                    di.diff_marker_category not in (7,22)
                    and cdt.created_at >= '2022-11-30 11:00:00'
                    and cdt.created_at < '2023-02-28 11:00:00'
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name