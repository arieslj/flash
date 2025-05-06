-- 拒收, 按照网点明细

select
    month(convert_tz(ra.created_at, '+00:00', '+08:00')) 月份
    ,dm.store_name 网点
    ,dm.region_name 大区
    ,count(distinct if(ra.audit_result = 1, ra.id, null))  通过量
    ,count(distinct if(ra.audit_result = 2, ra.id, null)) 未通过量
from my_wrs.reject_audit ra
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = ra.courier_staffId
left join dwm.dim_my_sys_store_rd dm on dm.store_id = hsi.sys_store_id and dm.stat_date = date_sub(curdate(), interval 1 day)
where
    ra.created_at > '2023-12-31 16:00:00'
    and ra.created_at < '2024-10-31 16:00:00'
group by 1,2,3
order by 1,2,3


;


-- 按照拒收原因

select
    month(convert_tz(ra.created_at, '+00:00', '+08:00')) 月份
    ,ddd.cn_element 拒收原因
    ,count(distinct if(ra.audit_result = 1, ra.id, null))  通过量
    ,count(distinct if(ra.audit_result = 2, ra.id, null)) 未通过量
from my_wrs.reject_audit ra
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = ra.courier_staffId
left join dwm.dwd_dim_dict ddd on ddd.element = ra.rejection_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'rejection_category'
where
    ra.created_at > '2023-12-31 16:00:00'
    and ra.created_at < '2024-10-31 16:00:00'
group by 1,2
order by 1,2

;

-- 改约



select
    dm.store_name 网点
    ,dm.region_name 大区
    ,count(distinct if(waa.audit_result = 1, waa.id, null)) 通过量
    ,count(distinct if(waa.audit_result = 2, waa.id, null)) 未通过量
from my_wrs.whats_app_audit waa
left join dwm.dim_my_sys_store_rd dm on dm.store_id = waa.report_store_id and dm.stat_date = date_sub(curdate(), interval 1 day)
where
    waa.created_at > '2023-12-31 16:00:00'
    and waa.created_at < '2024-10-31 16:00:00'
group by 1,2
order by 1,2

;






select
    *
from