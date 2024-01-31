select
    dt.统计日期
    ,dt.网点ID
    ,ss.name  网点名称
    ,if(dt.双重预警 = 'Alert', 1, 0) 当日是否爆仓
from dwm.dwd_th_network_spill_detl_rd dt
left join fle_staging.sys_store ss on ss.id = dt.网点ID
where
    dt.统计日期 >= '2023-11-01'
    and dt.统计日期 < '2023-12-01'