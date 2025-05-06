select
    pi.pno
    ,pi.client_id 客户ID
    ,pi.cod_amount/100 COD
    ,if(bc.client_name = 'lazada', pi.insure_declare_value, pai.cogs_amount)/100 COGS
    ,pi.store_parcel_amount/100 运费
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 最终状态
from ph_staging.parcel_info pi
left join ph_staging.parcel_additional_info pai on pai.pno = pi.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.created_at > '2023-11-30 16:00:00'
    and pi.created_at < '2024-12-31 16:00:00'
    and pi.returned = 0
    and pi.client_id in ('AA0089','AA0090','AA0128','AA0051','AA0050','AA0080','AA0121','AA0139','AA0131')
    and if(bc.client_name = 'lazada', pi.insure_declare_value, pai.cogs_amount) > 500000
