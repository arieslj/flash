select
    t.pno
    ,count(pcol.id) cnt
from bi_pro.parcel_lose_task plt
join tmpale.tmp_th_pno_lj_0222 t on t.pno = plt.pno
left join bi_pro.parcel_cs_operation_log pcol on pcol.task_id = plt.id
where
    pcol.action = 4
    and plt.penalties > 0
    -- and t.pno = 'TH67014SBAQ33F'
group by 1
