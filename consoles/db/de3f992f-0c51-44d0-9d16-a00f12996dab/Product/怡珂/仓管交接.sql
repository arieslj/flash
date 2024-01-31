select
    hsi.staff_info_id
    ,if(d1.双重预警 = 'Alert' or d2.双重预警 = 'Alert' or d3.双重预警 = 'Alert' or d4.双重预警 = 'Alert' or d5.双重预警 = 'Alert' or d6.双重预警 = 'Alert' or d7.双重预警 = 'Alert' , '是', '否' )  近一周是否爆仓
from bi_pro.hr_staff_info hsi
join tmpale.tmp_th_sco_staff_lj_1220 t on t.staff = hsi.staff_info_id
left join dwm.dwd_th_network_spill_detl_rd d1 on d1.网点ID = hsi.sys_store_id and d1.统计日期 = date_sub(curdate(), interval 1 day)
left join dwm.dwd_th_network_spill_detl_rd d2 on d2.网点ID = hsi.sys_store_id and d2.统计日期 = date_sub(curdate(), interval 2 day)
left join dwm.dwd_th_network_spill_detl_rd d3 on d3.网点ID = hsi.sys_store_id and d3.统计日期 = date_sub(curdate(), interval 3 day)
left join dwm.dwd_th_network_spill_detl_rd d4 on d4.网点ID = hsi.sys_store_id and d4.统计日期 = date_sub(curdate(), interval 4 day)
left join dwm.dwd_th_network_spill_detl_rd d5 on d5.网点ID = hsi.sys_store_id and d5.统计日期 = date_sub(curdate(), interval 5 day)
left join dwm.dwd_th_network_spill_detl_rd d6 on d6.网点ID = hsi.sys_store_id and d6.统计日期 = date_sub(curdate(), interval 6 day)
left join dwm.dwd_th_network_spill_detl_rd d7 on d7.网点ID = hsi.sys_store_id and d7.统计日期 = date_sub(curdate(), interval 7 day)