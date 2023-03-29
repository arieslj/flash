select
    ss.name 网点
    ,date(convert_tz(di.created_at, '+00:00', '+07:00')) 日期
    ,count(distinct di.pno) 包裹数
from fle_staging.store_diff_ticket sdt
left join fle_staging.diff_info di on di.id = sdt.diff_info_id
left join fle_staging.sys_store ss on ss.id = di.store_id
where
    di.diff_marker_category in (19,20) -- 网点上报破损,19 修复后直接继续派送，20会涉及到后续协商结果，以及是否进入闪速系统
    and di.created_at >= '2022-12-31 17:00:00'
    and di.store_id = 'TH01180105'
group by 1,2