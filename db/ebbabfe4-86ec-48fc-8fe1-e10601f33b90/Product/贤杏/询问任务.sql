select
    pci.merge_column
from my_bi.parcel_complaint_inquiry pci
where
    pci.created_at >= '2024-03-05'
    and pci.created_at < '2024-03-19'

;

select
    hsi.staff_info_id
    ,hsi.hire_type
    ,case
        when hsi.hire_type in (1,2,3,4,5) then '正式员工'
        when hsi.hire_type in (11,12) then '外协'
        when hsi.hire_type in (13) then '个人代理'
    end 员工类型
from my_bi.hr_staff_info hsi
join tmpale.tmp_my_staff_lj_0321 t on t.staff = hsi.staff_info_id
