select
    t.pno
    ,count(if(ppd.diff_marker_category = 40, ppd.id, null)) 联系不上
    ,count(if(ppd.diff_marker_category = 14, ppd.id, null)) 改约
    ,count(distinct ppd.id) '留仓&疑难件次数'
from ph_staging.parcel_problem_detail ppd
join tmpale.tmp_ph_pno_lj_0218 t on t.pno = ppd.pno
group by 1