select
    concat('SSRD',plt.`id`) '任务ID Task ID'
    ,plt.created_at '任务生成时间 Task Generation Time'
    ,plt.pno '运单号Tracking Number'
    ,case plt.`vip_enable`
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end as '客户类型Customer Type'
    ,case plt.`duty_result`
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end as '判责类型Judgment type'
    ,t.`t_value` '原因Reason'
    ,plt.`client_id` '客户ID Customer ID'
    ,pi.cod_amount/100 'COD金额 COD amount'
    ,oi.cogs_amount/100 COGS
    ,plt.`parcel_created_at` '揽收时间Pickup D/T'
    ,pi.exhibition_weight '重量Weight'
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) '尺寸Size'
    ,case pi.article_category
         when 0 then '文件'
         when 1 then '干燥食品'
         when 2 then '日用品'
         when 3 then '数码产品'
         when 4 then '衣物'
         when 5 then '书刊'
         when 6 then '汽车配件'
         when 7 then '鞋包'
         when 8 then '体育器材'
         when 9 then '化妆品'
         when 10 then '家居用具'
         when 11 then '水果'
         when 99 then '其它'
    end as '物品类型Item Type'
    ,if(pr1.pno is not null, '是', '否') '是否有发无到Whether Shipped without Arrival'
    ,pr.`next_store_name`  '下一站点Next DC/Hub'
    ,case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 33 then 'C来源HUB波次举报（临时来源，发送工单后将恢复C来源)'
    end  '问题件来源渠道Source of problem'
    ,group_concat(distinct wo.order_no) '工单编号Ticket number'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key)) '包裹外包装且展示面单的照片Photos of the package and showing the face sheet'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key)) '包裹外包装的照片Photos of the outer packaging'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa3.object_key)) '包裹外包装破损的照片Photos of damaged packages'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa4.object_key)) '包裹内填充物的照片Photo of the filling in the package'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa5.object_key)) '包裹目前重量的照片Photo of the current weight of the package'
    ,group_concat(distinct concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa6.object_key)) '应收到的产品的照片Photos of the product you should receive'
from  `ph_bi`.`parcel_lose_task` plt
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )
left join `ph_staging`.`parcel_route` pr on pr.`pno` = plt.`pno` and pr.`store_id` = plt.`last_valid_store_id` and pr.routed_at > date_sub(curdate(), interval 3 month)
left join `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
left join `ph_bi`.`translations` t on plt.duty_reasons = t.t_key and t.`lang` = 'zh-CN'
left join ph_staging.parcel_route pr1 on pr1.pno = plt.pno and pr1.route_action = 'HAVE_HAIR_SCAN_NO_TO' and pr1.routed_at > date_sub(curdate(), interval 3 month)
left join ph_staging.sys_attachment sa1 on sa1.oss_bucket_key = plt.source_id and sa1.object_key regexp 'LABEL'
left join ph_staging.sys_attachment sa2 on sa2.oss_bucket_key = plt.source_id and sa2.object_key regexp 'PACK'
left join ph_staging.sys_attachment sa3 on sa3.oss_bucket_key = plt.source_id and sa3.object_key regexp 'DAMAGED'
left join ph_staging.sys_attachment sa4 on sa4.oss_bucket_key = plt.source_id and sa4.object_key regexp 'FILLER'
left join ph_staging.sys_attachment sa5 on sa5.oss_bucket_key = plt.source_id and sa5.object_key regexp 'WEIGHT'
left join ph_staging.sys_attachment sa6 on sa6.oss_bucket_key = plt.source_id and sa6.object_key regexp 'RECEIVABLE'
where
    plt.state = 5
    and plt.operator_id not in (10000,10001)
    and plt.updated_at >= date_sub(curdate(), interval 30 day)
    and plt.updated_at < curdate()
    and bc.client_id is null
    and plt.vip_enable = 0
    and plt.duty_reasons in ('parcel_lose_duty_no_res_reasons_1', 'parcel_lose_duty_no_res_reasons_2', 'parcel_lose_duty_no_res_reasons_6', 'parcel_lose_duty_no_res_reasons_7')
group by 1
