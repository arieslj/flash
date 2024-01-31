-- 需求文档： https://flashexpress.feishu.cn/sheets/shtcn1Px4BCVxwexxEwoLF88Scg?sheet=mi5XMi


select
    pi.pno
    ,
from my_staging.parcel_info pi
left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm
where
    pi.state in (1,2,3,4,6)
;

