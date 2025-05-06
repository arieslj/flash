select
    vrv.link_id 运单号
    ,case
        when vrv.created_at > '2024-03-23' and vrv.created_at < '2024-03-28' then '0323-0328'
        when vrv.created_at > '2024-04-23' and vrv.created_at < '2024-04-28' then '0423-0428'
    end 时间段
    ,vrv.updated_at 回访完成时间
    ,if(pi.returned = 1, dai.returned_delivery_attempt_num, dai.delivery_attempt_num) 派送次数
    ,if(pi.returned = 0 and pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00')) 正向妥投日期
from nl_production.violation_return_visit vrv
left join ph_staging.parcel_info pi on pi.pno = vrv.link_id
left join ph_staging.delivery_attempt_info dai on dai.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )
where
    vrv.type = 8
    and vrv.client_id in ('AA0131','AA0132')
    and vrv.visit_staff_id = 10001
    and vrv.visit_state = 3
    and
    ((vrv.created_at > '2024-03-23' and vrv.created_at < '2024-03-28') or (vrv.created_at > '2024-04-23' and vrv.created_at < '2024-04-28') )


