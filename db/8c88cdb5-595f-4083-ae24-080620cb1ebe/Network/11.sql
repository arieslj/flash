select
    ss.id as store_id
    ,ss.name as store_name
    ,mp.name as piece_name
    ,mr.name as region_name
    ,adv.staff_info_id as staff_info_id
    ,hsi.job_title
    ,datediff(curdate(),hsi.hire_date)as work_days
    ,adv.staff_info_id as sub_staff_info_id
    ,hsi.job_title as sub_job_title
    ,ss.id as sub_store_id
    ,ss.name as sub_store_name
    ,mp.name as sub_piece_name
    ,mr.name as sub_region_name
    ,adv.attendance_started_at
	,adv.attendance_end_at
	,('N') as if_support
from fle_staging.sys_store ss1
join bi_pro.attendance_data_v2 adv on ss1.id=adv.sys_store_id and adv.stat_date=current_date and (adv.attendance_started_at is not null or adv.attendance_end_at is not null)
join bi_pro.hr_staff_info hsi on adv.staff_info_id=hsi.staff_info_id
left join fle_staging.sys_store ss on ss.id=hsi.sys_store_id #所属网点信息
left join fle_staging.sys_manage_piece mp on mp.id = ss.manage_piece #所属片区信息
left join fle_staging.sys_manage_region mr on mr.id = ss.manage_region #所属大区信息
where ss1.category in(1,10)
and hsi.state in(1,3)
and hsi.job_title in (13,110,452,1497)
and hsi.formal =1
and hsi.staff_info_id ='72277'
union all

select
    ss.id as store_id
    ,ss.name as store_name
    ,mp.name as piece_name
    ,mr.name as region_name
    ,hsa.staff_info_id
	,hsi.job_title
    ,datediff(curdate(),hsi.hire_date)as work_days
	,hsa.sub_staff_info_id
    ,hsa.job_title_id as sub_job_title
    ,ss1.id as sub_store_id
    ,ss1.name as sub_store_name
    ,mp1.name as sub_piece_name
    ,mr1.name as sub_region_name
    ,adv.attendance_started_at
	,adv.attendance_end_at
	,('Y') as if_support
from backyard_pro.hr_staff_apply_support_store hsa
join bi_pro.attendance_data_v2 adv on hsa.staff_info_id=adv.staff_info_id and adv.stat_date=current_date and (adv.attendance_started_at is not null or adv.attendance_end_at is not null)
join bi_pro.hr_staff_info hsi on hsi.staff_info_id =hsa.staff_info_id and hsi.formal =1
left join fle_staging.sys_store ss on ss.id=hsi.sys_store_id #所属网点信息
left join fle_staging.sys_manage_piece mp on mp.id = ss.manage_piece #所属片区信息
left join fle_staging.sys_manage_region mr on mr.id = ss.manage_region #所属大区信息
left join fle_staging.sys_store ss1 on ss1.id=hsa.store_id #所属网点信息
left join fle_staging.sys_manage_piece mp1 on mp1.id = ss1.manage_piece #所属片区信息
left join fle_staging.sys_manage_region mr1 on mr1.id = ss1.manage_region #所属大区信息
where hsa.status = 2 #支援审核通过
    and hsa.actual_begin_date <=current_date
    and coalesce(hsa.actual_end_date, curdate())>=current_date
    and hsa.employment_begin_date<=current_date
    and hsa.employment_end_date>=current_date
    and hsa.sub_staff_info_id>0
    and hsa.job_title_id in (13,110,452,1497)
    and hsi.formal =1