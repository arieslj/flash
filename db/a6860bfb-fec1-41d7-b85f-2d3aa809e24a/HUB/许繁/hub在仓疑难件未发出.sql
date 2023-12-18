-- 疑难件处理中
select
    date(convert_tz(di.created_at, '+00:00', '+08:00')) 上报日期
    ,convert_tz(di.created_at, '+00:00', '+08:00') 上报时间
    ,di.pno 单号
    ,ddd.CN_element 问题件类型
    ,ss.name HUB
    ,'疑难件处理中' 类型
from ph_staging.diff_info di
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join ph_staging.sys_store ss on ss.id = di.store_id
where
    ss.category = 8
    and cdt.state != 1

union all

select
    date(convert_tz(di.created_at, '+00:00', '+08:00')) 上报日期
    ,convert_tz(di.created_at, '+00:00', '+08:00') 上报时间
    ,di.pno 单号
    ,ddd2.CN_element 问题件类型
    ,ss.name HUB
    ,'疑难件处理完未发出' 类型
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwd_dim_dict ddd2 on ddd2.element = di.diff_marker_category and ddd2.db = 'ph_staging' and ddd2.tablename = 'diff_info' and ddd2.fieldname = 'diff_marker_category'
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join ph_staging.sys_store ss on ss.id = di.store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = di.pno and pssn.store_id = di.store_id
where
    ss.category = 8
    and cdt.state = 1
    and cdt.updated_at > date_sub(curdate(), interval 60 day)
    and pssn.shipped_at is null
    and pi.state not in (5,7,8,9)
group by 1,2,3,4,5,6