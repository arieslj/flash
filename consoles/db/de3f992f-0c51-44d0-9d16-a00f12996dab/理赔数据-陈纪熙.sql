select
    *
from
    (
        select
            month(pct.created_at) month_d
            ,cg.name cg_name
            ,count(distinct if(pct.source in (1,2,3,5,8,33), pct.id, null)) lost_num
            ,count(distinct if(pct.source in (4,6,7,9,10), pct.id, null)) damage_num
            ,count(distinct if(pct.state in (6,7,8) and pct.updated_at < date_format(date_add(now(), interval 2 month), '%Y-%m-11 00:00:00'), pct.id, null))/count(distinct pct.id) month_deal_ratio
        from bi_pro.parcel_claim_task pct
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = pct.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            pct.created_at >= '2022-12-01'
            and pct.created_at < '2023-03-01'
    ) t1
left join
    (
        select
            *
        from  bi_pro.parcel_claim_task pct
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = pct.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            pct.state in (6,7,8)
            and pct.updated_at >= '2022-12-01'
            and pct.updated_at < '2023-03-01'
    ) t2

