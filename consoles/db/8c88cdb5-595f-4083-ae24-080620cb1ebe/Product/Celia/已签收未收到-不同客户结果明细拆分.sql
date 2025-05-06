select
    ·
    ,count(if(pci.apology_type = 1, pci.id, null)) 已超时
    ,count(if(pci.apology_type = 2, pci.id, null)) 已处理
    ,count(if(pci.qaqc_is_receive_parcel = 2, pci.id, null)) 已收到包裹
    ,count(if(pci.qaqc_is_receive_parcel = 3, pci.id, null)) 丢失量
    ,count(if(pci.apology_type = 1, pci.id, null)) / count(pci.id) 已超时占比
    ,count(if(pci.apology_type = 2, pci.id, null)) / count(pci.id) 已处理占比
    ,count(pci.id) 总单量
from bi_center.parcel_complaint_inquiry pci
where
    if(pci.client_type = 1, pci.created_at < date_sub(curdate(), interval 2 day) and pci.created_at >= date_sub(curdate(), interval 4 day), pci.created_at < date_sub(curdate(), interval 3 day) and pci.created_at >= date_sub(curdate(), interval 6 day) )
    and pci.client_type in (1,2,3,4)
group by 1

union all

select
    '平台' 客户类型
    ,count(if(pci.apology_type = 1, pci.id, null)) 已超时
    ,count(if(pci.apology_type = 2, pci.id, null)) 已处理
    ,count(if(pci.qaqc_is_receive_parcel = 2, pci.id, null)) 已收到包裹
    ,count(if(pci.qaqc_is_receive_parcel = 3, pci.id, null)) 丢失量
    ,count(if(pci.apology_type = 1, pci.id, null)) / count(pci.id) 已超时占比
    ,count(if(pci.apology_type = 2, pci.id, null)) / count(pci.id) 已处理占比
    ,count(pci.id) 总单量
from bi_center.parcel_complaint_inquiry pci
where
    if(pci.client_type = 1, pci.created_at < date_sub(curdate(), interval 2 day) and pci.created_at >= date_sub(curdate(), interval 4 day), pci.created_at < date_sub(curdate(), interval 3 day) and pci.created_at >= date_sub(curdate(), interval 6 day) )
    and pci.client_type in (1,2,3,4)
group by 1

union all

select
    '非平台' 客户类型
    ,count(if(pci.apology_type = 1, pci.id, null)) 已超时
    ,count(if(pci.apology_type = 2, pci.id, null)) 已处理
    ,count(if(pci.qaqc_is_receive_parcel = 2, pci.id, null)) 已收到包裹
    ,count(if(pci.qaqc_is_receive_parcel = 3, pci.id, null)) 丢失量
    ,count(if(pci.apology_type = 1, pci.id, null)) / count(pci.id) 已超时占比
    ,count(if(pci.apology_type = 2, pci.id, null)) / count(pci.id) 已处理占比
    ,count(pci.id) 总单量
from bi_center.parcel_complaint_inquiry pci
where
    if(pci.client_type = 1, pci.created_at < date_sub(curdate(), interval 2 day) and pci.created_at >= date_sub(curdate(), interval 4 day), pci.created_at < date_sub(curdate(), interval 3 day) and pci.created_at >= date_sub(curdate(), interval 6 day) )
    and pci.client_type not in (1,2,3,4)
group by 1

