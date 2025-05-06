select
    hsi.staff_info_id
    ,hsi.hire_date 入职时间
    ,hjt.job_name 职位
    ,case
        when hsi.hire_type in (1,2,3,4,5) then '正式员工'
        when hsi.hire_type in (11,12) then '外协'
        when hsi.hire_type in (13) then '个人代理'
    end 员工类型
from bi_pro.hr_staff_info hsi
# join tmpale.tmp_th_staff_lj_0111 t on t.staff = hsi.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
where
    hsi.staff_info_id in (607981)


;

select
    t.staff
    ,hjt.job_name 职位
    ,hsa.staff_info_id 原工号
    ,hsi.hire_date 入职时间
from backyard_pro.hr_staff_apply_support_store hsa
join tmpale.tmp_th_staff_lj_0111_v2 t on t.staff = hsa.sub_staff_info_id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = hsa.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title


;


select
    dai.client_id
    ,count(1)
from fle_staging.delivery_attempt_info dai
join fle_staging.ka_profile kp on kp.id = dai.client_id
where
    kp.department_id = 13
    and dai.created_at > '2024-10-31 17:00:00'
group by dai.client_id