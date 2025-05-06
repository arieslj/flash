select
    pcd.pno
    ,pcd.old_value
    ,pcd.new_value
    ,pcr.operator_id
    ,pcr.operator_name
    ,pcr.created_at operator_time
    ,hjt.job_name
    ,hsi.mobile
from fle_staging.parcel_change_detail pcd
join fle_staging.parcel_change_record pcr on pcd.record_id = pcr.id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pcr.operator_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
where
    pcd.created_at > '2024-11-30 17:00:00'
    and pcr.created_at > '2024-11-30 17:00:00'
    and pcd.new_value < pcd.old_value
    and pcd.field_name = 'cod_amount'

