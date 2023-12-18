select
    month(date_add(wo.created_at, interval 6 hour)) 月份
    ,wo.order_no
    ,wo.pnos
    ,wo.created_at 工单创建时间
#     ,count(distinct  wo.id) num
from bi_pro.work_order wo
 left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id
 join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name = 'Shopee'
 left join fle_staging.sys_store ss on ss.id = wo.created_store_id
where wo.store_id = 22
  and wo.created_at >= '2022-11-30 18:00:00'
  and wo.created_at < '2023-02-28 18:00:00'
  and ss.id is not null
;

select
    t1.month_d 月份
    ,t1.cg_name 项目组
    ,t1.should_deal 应处理工单数
    ,t2.already_deal 完结工单数
    ,t1.not_already_deal 应处理工单当月未完成单数
    ,t1.deal_rate 当月工单完结率
    ,zl.zl_num 滞留工单单数
    ,t2.deal_avg_time 完结工单单均处理时长
    ,cf.repeat_num 工单重复包裹数
from
    ( -- 当月产生
         select
             month(date_add(wo.created_at, interval 6 hour))  month_d
             ,cg.name cg_name
             ,count(distinct wo.id) should_deal
             ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
             ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) dealnum
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
         where
            wo.created_at > '2022-11-30 18:00:00'
            and wo.created_at < '2023-02-28 18:00:00'
            and wo.store_id = 22
            and ss.id is not null
         group by 1,2
    ) t1
left join
     (-- 当月完结，已回复和已关闭的工单按照最后一次回复时间认定为结束时间
         select
             month(wo.latest_reply_at) month_d
            ,cg.name cg_name
            ,count(distinct wo.id)  already_deal
            ,sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /count(distinct wo.id) deal_avg_time
         from bi_pro.work_order wo
         left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
         join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
         where wo.latest_reply_at >= '2022-12-01 00:00:00'
            and wo.latest_reply_at < '2023-03-01 00:00:00'
            and wo.store_id = 22
            and ss.id is not null
            and wo.status in (3, 4)
         group by 1,2
    ) t2 on t2.month_d = t1.month_d and t2.cg_name = t1.cg_name
left join
    (
        select
            '12' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-01-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2022-12-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '1' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-02-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-01-31 18:00:00')
                )
        group by 1,2

        union all

        select
            '2' month_d
            ,cg.name cg_name
            ,count(distinct wo.id) zl_num
        from bi_pro.work_order wo
        left join fle_staging.sys_store ss on ss.id = wo.created_store_id
        left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
        join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
        where
            ss.id is not null
            and wo.created_at >= '2022-01-01'
            and wo.created_at < '2023-03-01'
            and wo.store_id = 22
            and
                (
                    wo.status in (1,2)
                    or (wo.status in (3,4) and wo.latest_reply_at >= '2023-02-28 18:00:00')
                )
        group by 1,2
    ) zl on zl.month_d = t1.month_d and zl.cg_name = t1.cg_name
left join
    (
        select
            t.month_d
            ,t.cg_name
            ,count(distinct t.pnos) repeat_num
        from
            (
                select
                    wo.id
                    ,cg.name cg_name
                    ,wo.pnos
                    ,month(date_add(wo.created_at, interval 6 hour))  month_d
                    ,count(wo.id) over (partition by month(date_add(wo.created_at, interval 6 hour)),wo.pnos) pno_count
                from bi_pro.work_order wo
                left join fle_staging.sys_store ss on ss.id = wo.created_store_id
                left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
                join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
                where
                    wo.created_at > '2022-11-30 18:00:00'
                    and wo.created_at < '2023-02-28 18:00:00'
                    and wo.store_id = 22
                    and ss.id is not null
            ) t
        where
            t.pno_count >= 2
        group by 1,2
    ) cf on cf.month_d = t1.month_d and cf.cg_name = t1.cg_name



；

-- 案例
select
     month(date_add(wo.created_at, interval 6 hour))  所属月份
     ,cg.name 项目组
#      ,count(distinct wo.id) should_deal
#      ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at <= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
    ,wo.order_no 工单号
    ,wo.created_at 工单创建时间
    ,wo.latest_reply_at 最后回复时间
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
 from bi_pro.work_order wo
 left join fle_staging.sys_store ss on ss.id = wo.created_store_id
 left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
 join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
 where
    wo.created_at > '2022-11-28 18:00:00'
    and wo.created_at < '2023-03-01 18:00:00'
    and wo.store_id = 22
    and ss.id is not null
;

select
     month(wo.latest_reply_at) 月份
    ,cg.name 项目组
#     ,count(distinct wo.id)  already_deal
#     ,sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /count(distinct wo.id) deal_avg_time
    ,wo.created_at 工单创建时间
    ,wo.latest_reply_at 工单最后回复时间
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
from bi_pro.work_order wo
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
where wo.latest_reply_at >= '2022-11-01 00:00:00'
and wo.latest_reply_at < '2023-03-11 00:00:00'
and wo.store_id = 22
and ss.id is not null
and wo.status in (3, 4)
;

-- 滞留

select
    cg.name cg_name
    ,wo.order_no
    ,wo.client_id
    ,wo.pnos
    ,wo.created_at 工单创建时间
    ,wo.latest_reply_at 工单最后回复时间
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
from bi_pro.work_order wo
left join fle_staging.sys_store ss on ss.id = wo.created_store_id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
where
    ss.id is not null
    and wo.created_at >= '2022-01-01'
    and wo.created_at < '2023-03-01'
    and wo.store_id = 22
#     and
#         (
#             wo.status in (1,2)
#             or (wo.status in (3,4) and wo.latest_reply_at >= '2022-12-31 18:00:00')
#         )
;
select
     month(date_add(wo.created_at, interval 6 hour))  month_d
     ,cg.name cg_name
#      ,count(distinct wo.id) should_deal
#      ,count(distinct if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), wo.id,  null)) not_already_deal
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) / count(distinct wo.id) deal_rate
#      ,count(distinct if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), wo.id, null)) dealnum
    ,wo.id
    ,wo.status
    ,wo.created_at
    ,wo.order_no
    ,wo.pnos
    ,wo.latest_reply_at
    ,if(wo.status in (1, 2) or (wo.status in (3, 4) and wo.latest_reply_at >= date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour)), 1,  null) not_already_deal
    ,if(wo.status in (3, 4) and wo.latest_reply_at < date_add(adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1), interval 18 hour), 1, null) dealnum
 from bi_pro.work_order wo
 left join fle_staging.sys_store ss on ss.id = wo.created_store_id
 left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = wo.client_id and cgkr.deleted = 0  -- 已经删除的关联关系不要，要不然会造成数据重复
 join fle_staging.customer_group cg on  cgkr.customer_group_id = cg.id and cg.name in ('Shopee','LAZADA','TikTok','THAI KAM','KAM CN')
 where
    wo.created_at > '2022-11-30 18:00:00'
    and wo.created_at < '2023-02-28 18:00:00'
    and wo.store_id = 22
    and ss.id is not null
    and cg.name = 'Shopee'
    and month(date_add(wo.created_at, interval 6 hour)) = 2
;

select
    *
from fle_staging.ka_profile kp
where
    kp.id = 'CAM2214'