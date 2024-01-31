-- 需求文档：https://flashexpress.feishu.cn/wiki/ObOxwqLujiTCrjk4YSqcm0OqnGe

select
    concat('SSRD', t.task_id) id
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end  问题渠道
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case plt.state
        when 1 then '待处理'   -- 待处理
        when 2 then '待处理' -- 待处理
        when 3 then '待工单回复'  -- 待工单回复
        when 4 then '已工单回复' -- 已工单回复
        when 5 then '无须追责'  -- 无须追责
        when 6 then '责任人已认定' -- 责任人已认定
    end 闪速最终判责结果
    ,if(pct.pno is not null, 'Y', 'N' ) 最终是否丢失理赔
from bi_pro.parcel_lose_task plt
join tmpale.tmp_th_plt_task_id_0131 t on t.task_id = plt.id
left join fle_staging.customer_issue ci on ci.id = plt.source_id
left join fle_staging.ka_profile kp on kp.id = plt.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
left join bi_pro.parcel_claim_task pct on pct.pno = plt.pno and pct.state = 6