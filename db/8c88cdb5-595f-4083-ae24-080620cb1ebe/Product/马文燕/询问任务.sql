select
    distinct
    pci.merge_column 运单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null) 签收时间
    ,pci.created_at 包裹进入询问任务时间
    ,acc.created_at 进入客诉时间
    ,case
        when acc.id is not null then '是'
        else '否'
    end 是否进入客诉
    ,if(pct.pno is not null, '是', '否') 是否生成理赔任务
    ,pct.created_at 生成理赔任务时间
    ,if(datediff(pct.created_at, convert_tz(pi.finished_at, '+00:00', '+07:00')) > 7, 'y', null) 生成理赔任务是否超7天
    ,am.created_at 包裹生成丢失处罚时间
from bi_center.parcel_complaint_inquiry pci
left join fle_staging.parcel_info pi on pi.pno = pci.merge_column
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join bi_pro.abnormal_customer_complaint acc on acc.pno = pci.merge_column and acc.channel_type = 16
left join bi_pro.parcel_lose_task plt on acc.abnormal_message_id = substring(plt.source_id, 16)
left join bi_pro.abnormal_message am on am.id = substring(plt.source_id, 16)
left join bi_pro.parcel_claim_task pct on pct.pno = pci.merge_column
where
    pci.created_at > '2024-09-01'
    and pci.created_at < '2024-09-16'
    and pci.complaints_at > '2024-09-01'
    and pci.complaints_at < '2024-09-16'