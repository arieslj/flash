select
    am.abnormal_time 日期
    ,am.merge_column 运单号
    ,case apde.client_type
        when 0 then '未定义'
        when 1 then 'lazada'
        when 2 then 'shopee'
        when 3 then 'tiktok'
        when 4 then 'shein'
        when 5 then 'otherKam'
        when 6 then 'ordinaryKa'
        when 7 then '小c'
    end 平台
    ,apde.client_id 客户ID
    ,apde.delivery_staff_info_id 快递员
    ,dt.store_name 网点
    ,dt.region_name 大区
    ,case
        when am.isappeal = 1 then '未申诉'
        when am.isappeal = 2 then '申诉中'
        when am.isappeal = 3 then '保持原判'
        when am.isappeal = 4 then '已变更'
        when am.isappeal = 5 or am.isdel = 1 then '已删除'
    end 申诉结果
    ,json_extract(apde.parcel_route_extra, '$.deliveryImageAiScore[0].objectKey') AS objectKey_1
    ,json_extract(apde.parcel_route_extra, '$.deliveryImageAiScore[0].waybillNumberAvailability') AS waybillNumberAvailability_1
    ,json_extract(apde.parcel_route_extra, '$.deliveryImageAiScore[0].waybillNumberConsistency') AS waybillNumberConsistency_1

    ,json_extract(apde.parcel_route_extra, '$.deliveryImageAiScore[1].objectKey') AS objectKey_2
    ,json_extract(apde.parcel_route_extra, '$.deliveryImageAiScore[1].waybillNumberAvailability') AS waybillNumberAvailability_2
    ,json_extract(apde.parcel_route_extra, '$.deliveryImageAiScore[1].waybillNumberConsistency') AS waybillNumberConsistency_2

    ,json_extract(apde.parcel_route_extra, '$.deliveryImageAiScore[2].objectKey') AS objectKey_3
    ,json_extract(apde.parcel_route_extra, '$.deliveryImageAiScore[2].waybillNumberAvailability') AS waybillNumberAvailability_3
    ,json_extract(apde.parcel_route_extra, '$.deliveryImageAiScore[2].waybillNumberConsistency') AS waybillNumberConsistency_3
from bi_pro.abnormal_message am
left join nl_production.abnormal_parcel_delivery_epod apde on apde.pno = am.merge_column
left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    am.punish_category = 80
    and am.punish_sub_category = 36
    and am.abnormal_time >= '2024-12-01'
    and am.abnormal_time < '2025-01-02'
    and json_extract(am.extra_info, '$.src') = 'abnormal_parcel_delivery_epod' -- 来自AI模型
