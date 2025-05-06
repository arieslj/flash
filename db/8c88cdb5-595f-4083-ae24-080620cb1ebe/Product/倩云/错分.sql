select
    t.*
    ,if(dt.双重预警 = 'Alert', 'y', 'n') 当日是否爆仓
    ,a.dt_cnt 网点当月爆仓天数
    ,if(mpa.pno is not null, 'y', 'n') 当日是否Pri
from tmpale.tmp_th_pno_lj_0527 t
left join dwm.dwd_th_network_spill_detl_rd dt on dt.网点ID = t.store_id and dt.统计日期 = t.p_date
left join
    (
        select
            t.store_id
            ,count(distinct dt.统计日期) dt_cnt
        from dwm.dwd_th_network_spill_detl_rd dt
        join tmpale.tmp_th_pno_lj_0527 t on t.store_id = dt.网点ID
        where
            dt.统计日期 between '2024-05-01' and '2024-05-31'
            and dt.双重预警 = 'Alert'
        group by 1
    ) a on a.store_id = t.store_id
left join bi_center.msdashboard_pri_abnormal_data_save mpa on mpa.pno = t.pno and mpa.stat_date = t.p_date

;

select * from tmpale.tmp_th_pno_lj_0527 t