select
    pci.id
    ,case  pci.client_type
        when 1 then 'lazada'
        when 2 then 'shopee'
        when 3 then 'tiktok'
        when 4 then 'shein'
        when 5 then 'otherKAM'
        when 6 then 'otherKA'
        when 7 then '小C'
    end 客户类型
    ,pci.merge_column 单号
    ,concat(pci.staff_info_id, '(', hsi.name, ')') '快递员工号(姓名)'
    ,hsi.mobile 快递员电话
    ,ss.manager_phone 网点电话
    ,ss.name 网点名称
    ,smp.name 片区
    ,smr.name 大区
    ,concat(ss.manager_id, '(', ss.manager_name, ')') '网点主管工号（姓名）'
    ,concat(smp.manager_id, '(', smp.manager_name, ')') 'DM工号（姓名）'
    ,concat(smr.manager_id, '(', smr.manager_name, ')') 'AM工号（姓名'
    ,pci.created_at 询问任务创建时间
    ,date_add(pci.created_at, interval 48 hour) 上传入口关闭的时间点 -- 马来都是48小时
    ,pi2.cod_amount/100 COD
    ,pai.cogs_amount/100 COGS
    ,curdate() dt
from my_bi.parcel_complaint_inquiry pci
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = pci.staff_info_id
left join my_staging.sys_store ss on ss.id = pci.store_id
left join my_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join my_staging.sys_manage_region smr on smr.id = ss.manage_region
left join my_staging.parcel_info pi on pi.pno = pci.merge_column
left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join my_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pci.apology_type = 0
    and timestampdiff(minute , now(), date_add(pci.created_at, interval 48 hour)) < 1440 -- 24小时内

    ;

select * from tmpale.dwd_ph_complaint_inquiry_d