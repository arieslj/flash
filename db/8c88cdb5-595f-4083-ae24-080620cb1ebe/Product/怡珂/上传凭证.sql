select
    a.merge_column 单号
    ,a.client_name 客户类型
    ,a.apology_staff_info_id 上传凭证人
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,a.call_back_period 回访时效节点
    ,timestampdiff(minute, a.call_back_period, a.apology_at)/60 '上传证据时间-回访时效时间差'
    ,a.client_period 平台时效节点
from
    (
        select
            pci.merge_column
            ,case  pci.client_type
                when 1 then 'lazada'
                when 2 then 'shopee'
                when 3 then 'tiktok'
                when 4 then 'shein'
                when 5 then 'otherKAM'
                when 6 then 'otherKA'
                when 7 then '小C'
            end client_name
            ,case
                when pci.client_type = 1 and pci.created_at <= date_add(date(pci.created_at), interval 16 hour) then date_add(date(pci.created_at), interval 24 hour)
                when pci.client_type = 1 and pci.created_at > date_add(date(pci.created_at), interval 16 hour) then date_add(date(pci.created_at), interval 32 hour)
                when pci.client_type != 1 then date_add(pci.created_at, interval 48 hour)
            end call_back_period
            ,case
                when pci.client_type = 1  then date_add(pci.created_at, interval 48 hour)
                when pci.client_type != 1 then date_add(pci.created_at, interval 72 hour)
            end client_period
            ,pci.apology_at
            ,pci.apology_staff_info_id
        from bi_center.parcel_complaint_inquiry pci
        where
            pci.callback_state != 0
            and pci.apology_evidence != ''
            and pci.created_at >= '2023-12-29'
    ) a
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = a.apology_staff_info_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = hsi.sys_store_id and DT.stat_date = '2024-01-10'