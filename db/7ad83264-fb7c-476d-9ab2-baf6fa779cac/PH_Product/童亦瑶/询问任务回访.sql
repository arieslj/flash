select
    count(if(pci.apology_type in (0,2,3), pci.id, null)) 回复量
    ,count(pci.id) 总任务量
    ,count(if(pci.apology_type in (1), pci.id, null))  超时量
    ,count(if(pci.apology_type in (0), pci.id, null))  处理中量
from ph_bi.parcel_complaint_inquiry pci
where
    pci.created_at > date_sub(curdate(), interval 2 week)