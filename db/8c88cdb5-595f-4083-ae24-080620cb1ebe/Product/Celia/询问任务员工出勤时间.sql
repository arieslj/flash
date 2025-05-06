select
    t.*
    ,adv.attendance_started_at
    ,adv.attendance_end_at
from bi_pro.attendance_data_v2 adv
join tmpale.tmp_th_staff_lj_0425 t on t.staff = adv.staff_info_id and date_add(t.p_date, interval 3 day) = adv.stat_date