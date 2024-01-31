select
    t.store_id 网点id
    ,swa.attendance_date 打卡日期
    ,count(distinct coalesce(hsa.staff_info_id, swa.staff_info_id)) 当日打卡人数
from backyard_pro.staff_work_attendance swa
join tmpale.tmp_th_store_1122 t on (swa.end_store_id = t.store_id or swa.started_store_id = t.store_id)
left join backyard_pro.hr_staff_apply_support_store hsa on hsa.sub_staff_info_id = swa.staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= swa.attendance_date and hsa.employment_end_date >= swa.attendance_date
where
    swa.attendance_date >= '2023-11-09'
    and swa.attendance_date <= '2023-11-21'
    and swa.job_title in (13,110,452,1497)
group by 1,2
