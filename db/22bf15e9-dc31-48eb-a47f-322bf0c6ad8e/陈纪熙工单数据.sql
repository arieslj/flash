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
    *
from ( -- 当月产生
         select
             month(date_add(wo.created_at, interval 6 hour))  month_d
            , count(distinct wo.id) should_deal
            , count(distinct if(wo.status in (1, 2) or wo.status in (3, 4) and wo.latest_reply_at >= adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1) +interval 18 hour, wo.id,  null)) already_deal                                                          should_not_deal
            , count(distinct if(wo.status in (3, 4) and wo.latest_reply_at <= adddate(last_day(date_add(wo.created_at, interval 6 hour)), 1) + interval 18 hour)) / count(distinct wo.id) deal_rate
         from bi_pro.work_order wo
                  left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         where wo.created_at > '2022-11-30 18:00:00'
           and wo.created_at < '2023-02-28 18:00:00'
           and wo.store_id = 22
           and ss.id is not null) t1
         left join
     ( -- 当月完结，已回复和已关闭的工单按照最后一次回复时间认定为结束时间
         select month(wo.latest_reply_at) month_d
              , count(distinct wo.id)     already_deal
              , sum(timestampdiff(second, wo.created_at, wo.latest_reply_at) / 3600) /
                count(distinct wo.id)     deal_avg_time
         from bi_pro.work_order wo
                  left join fle_staging.sys_store ss on ss.id = wo.created_store_id
         where wo.latest_reply_at >= '2022-12-01 00:00:00'
           and wo.latest_reply_at < '2023-03-01 00:00:00'
           and wo.store_id = 22
           and ss.id is not null
           and wo.status in (3, 4)
    ) t2
