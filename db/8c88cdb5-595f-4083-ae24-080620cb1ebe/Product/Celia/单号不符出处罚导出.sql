select
    am.merge_column 运单号
    ,pi.client_id 客户ID
    ,am.staff_info_id 快递员
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,am.abnormal_time 处罚时间
    ,if(coalesce(am.isappeal, aq.isappeal) > 1 , '是', '否') 是否有申诉
    ,case
        when coalesce(am.isappeal, aq.isappeal) = 1 then '未申诉'
        when coalesce(am.isappeal, aq.isappeal) = 2 then '申诉中'
        when coalesce(am.isappeal, aq.isappeal) = 3 then '保持原判'
        when coalesce(am.isappeal, aq.isappeal) = 4 then '已变更'
        when coalesce(am.isappeal, aq.isappeal) = 5 or am.isdel = 1 then '已删除'
    end 申诉结果
from bi_pro.abnormal_message am
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
left join fle_staging.parcel_info pi on pi.pno = am.merge_column
left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), 1)
where
    am.abnormal_time >= '2024-08-09'
    and am.abnormal_time < '2024-08-22'
    and am.punish_category = 80
    and am.punish_sub_category = 36