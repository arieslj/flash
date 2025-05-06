select
    substr(vrv.created_at,1,7) 月份
    ,bc.client_name
    ,if( vrv.visit_staff_id = 10001 or ( vrv.visit_staff_id = 0 and vrv.visit_state = 2 ), 'automatic', 'manual')  回访方式
    ,count(distinct vrv.link_id) 包裹量
    ,count(vrv.id) 回访任务量
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id
where
    vrv.created_at > '2023-09-01'
    and vrv.type in (3,8)
group by 1,2,3

;


select
    a1.link_id
from
    (
        select
            vrv.link_id
            ,vrv.created_at
            ,date(vrv.created_at) vrv_date
        from nl_production.violation_return_visit vrv
        where
            vrv.type = 3
            and vrv.visit_state in (3,4)
            and vrv.data_source != 16
    ) a1
join
    (
        select
            vrv.link_id
            ,vrv.created_at
            ,date(vrv.created_at) vrv_date
        from nl_production.violation_return_visit vrv
        where
            vrv.type = 3
            and vrv.data_source = 16
    ) a2 on a1.vrv_date = a2.vrv_date and a1.link_id = a2.link_id
join ph_staging.diff_info di on di.pno = a1.link_id and di.diff_marker_category = 17 and di.state = 0
where
    a1.created_at < a2.created_at
group by 1


;

select
    substr(convert_tz(pi.created_at, '+00:00', '+08:00'),1,7) 月份
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,count(pi.pno) 包裹量
from ph_staging.parcel_info pi
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.ka_profile kp on kp.id = pi.client_id
where
    pi.created_at >= '2023-08-31 16:00:00'
    and pi.created_at < '2023-12-31 16:00:00'
    and pi.state < 9
    and pi.returned = 0
group by 1,2
order by 1,2
;

select
    max(vrv.created_at)
from nl_production.violation_return_visit vrv