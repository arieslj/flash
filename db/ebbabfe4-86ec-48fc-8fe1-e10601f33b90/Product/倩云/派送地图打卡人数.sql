select
    swa.started_store_id
    ,swa.end_store_id
    ,swa.attendance_date 打卡日期
    ,count(distinct coalesce(hsa.staff_info_id, swa.staff_info_id)) 当日打卡人数
from my_backyard.staff_work_attendance swa
left join my_backyard.hr_staff_apply_support_store hsa on hsa.sub_staff_info_id = swa.staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= swa.attendance_date and hsa.employment_end_date >= swa.attendance_date
where
    swa.attendance_date >= '2023-11-09'
    and swa.attendance_date <= '2023-11-21'
    and swa.job_title in (13,110,1199)
    and
        (
            swa.started_store_id in ('MY06010511','MY06011600','MY04020600','MY05010100','MY04070414','MY04060400','MY04010210','MY04050100','MY04060200')
            or swa.end_store_id in ('MY06010511','MY06011600','MY04020600','MY05010100','MY04070414','MY04060400','MY04010210','MY04050100','MY04060200')
        )
group by 1,2,3