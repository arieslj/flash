# select
#     a2.date_2
#     ,a2.client_id
#     ,a1.pnos '第一次尝试派送时效-1'
#     ,a2.pnos '第一次尝试派送时效-2'
# from
okk
;


select
    date_sub(dep.delievey_end_date, interval 1 day) 日期
    ,client_id 客户id
    ,count(dep.pno) '正向时效-1'
from dwm.dwd_ex_ph_lazada_pno_period dep
where
    dep.delievey_end_date >= '2023-09-02'
    and dep.delievey_end_date < '2023-10-20'
    and dep.returned = 0
group by 1,2