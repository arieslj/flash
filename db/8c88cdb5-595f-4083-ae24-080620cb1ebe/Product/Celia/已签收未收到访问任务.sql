select
    ci.pno
    ,pci.created_at 询问任务创建时间
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null) 签收时间
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
    end  任务来源
    ,datediff(pci.created_at, if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null)) 间隔天数
    ,case  pci.client_type
        when 1 then 'lazada'
        when 2 then 'shopee'
        when 3 then 'tiktok'
        when 4 then 'shein'
        when 5 then 'otherKAM'
        when 6 then 'otherKA'
        when 7 then '小C'
    end 客户类型
    ,pi.cod_amount/100 COD金额
    ,if(pci.callback_state = 4 or (pci.callback_state = 2 and qaqc_is_receive_parcel = 3), '是', '否') 是否丢失
    ,if(ci2.pno is not null, '是', '否') 是否索赔
from fle_staging.customer_issue ci
left join bi_center.parcel_complaint_inquiry pci on pci.source_id = ci.id
left join fle_staging.parcel_info pi on pi.pno = ci.pno
left join fle_staging.customer_issue ci2 on ci2.pno = ci.pno and ci2.request_sup_type = 14 and ci2.request_sub_type = 140
where
    (
        (ci.request_sup_type = 22 and ci.request_sub_type in (221,300))
        or (ci.request_sup_type = 16 and ci.request_sub_type = 160 and ci.request_sul_type = 55)
    )
    and pci.created_at >=  '2023-12-29'
group by 1