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
    ,ss.phone 网点电话
    ,ss.name 网点名称
    ,smp.name 片区
    ,smr.name 大区
    ,concat(ss.manager_id, '(', ss.manager_name, ')') '网点主管工号（姓名）'
    ,concat(smp.manager_id, '(', smp.manager_name, ')') 'DM工号（姓名）'
    ,concat(smr.manager_id, '(', smr.manager_name, ')') 'AM工号（姓名'
    ,pci.created_at
    ,case
        when pci.client_type = 1 then date_add(pci.created_at, interval 48 hour)
        else date_add(pci.created_at, interval 72 hour)
    end 上传入口关闭的时间点
    ,pi2.cod_amount/100 COD
    ,pai.cogs_amount/100 COGS
    ,curdate() dt 
from bi_center.parcel_complaint_inquiry pci
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pci.staff_info_id
left join fle_staging.sys_store ss on ss.id = pci.store_id
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.parcel_info pi on pi.pno = pci.merge_column
left join fle_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join fle_staging.parcel_additional_info pai on pai.pno = pi2.pno
where
    pci.apology_type = 0
    and timestampdiff(minute , now(), if(pci.client_type = 1, date_add(pci.created_at, interval 48 hour), date_add(pci.created_at, interval 72 hour))) < 1440 -- 24小时内
    ;

select * from tmpale.dwd_th_complaint_inquiry_d
select * from tmpale.dwd_ph_complaint_inquiry_d
;

select
    case
        when pci.apology_type = 0 then '即将超时未上传'
        when pci.apology_type = 1 then '已超时未上传'
        when pci.apology_type = 2 then '已上传'
    end 处理结果
    ,t.client_type 客户类型
    ,t.pno  单号
    ,t.staff_info '快递员工号(姓名'
    ,t.staff_phone 快递员电话
    ,t.store_phone 网点电话
    ,t.store_name 网点名称
    ,t.picec 片区
    ,t.region 大区
    ,t.store_manager '网点主管工号（姓名）'
    ,t.dm_manager  'DM工号（姓名）'
    ,t.am_manager 'AM工号（姓名）'
    ,t.created_at 询问任务创建时间
    ,t.sla_close_time 上传入口关闭的时间
    ,t.cod cod金额
    ,t.cogs cogs金额
from tmpale.dwd_th_complaint_inquiry_d t
left join bi_center.parcel_complaint_inquiry pci on pci.id = t.id
where
    t.dt = curdate()

;
select
    t.client_type 客户类型
    ,t.pno  单号
    ,t.staff_info '快递员工号(姓名'
    ,t.staff_phone 快递员电话
    ,t.store_phone 网点电话
    ,t.store_name 网点名称
    ,t.picec 片区
    ,t.region 大区
    ,t.store_manager '网点主管工号（姓名）'
    ,t.dm_manager  'DM工号（姓名）'
    ,t.am_manager 'AM工号（姓名）'
    ,t.created_at 询问任务创建时间
    ,t.sla_close_time 上传入口关闭的时间
    ,t.cod cod金额
    ,t.cogs cogs金额
from tmpale.dwd_th_complaint_inquiry_d t
where
    t.dt = curdate()