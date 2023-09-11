select
    case
        when vrv.created_at < '2023-08-01' then '0701-0731'
        when vrv.created_at >= '2023-8-01' then '0801-0817'
    end period
    ,case
        when vrv.type = 3 then '收件人拒收回访'
        when vrv.type = 8 then '多次尝试派送失败回访'
    end 回访类型
    ,sum(vrv.visit_num) 回访总数
    ,count(if(vrv.visit_result = 43, vrv.id, null)) 多次尝试派送失败回访继续派送量
    ,count(if(vrv.visit_result = 43 and pi.state = 5, vrv.id, null)) 多次尝试派送失败回访继续派送妥投量
    ,count(if(json_extract(vrv.extra_value, '$.rejection_delivery_again') = 2, vrv.id, null)) 收件人拒收回访继续派送量
    ,count(if(json_extract(vrv.extra_value, '$.rejection_delivery_again') = 2 and pi.state = 5, vrv.id, null)) 收件人拒收回访继续派送妥投量
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id and bc.client_name = 'tiktok'
left join ph_staging.parcel_info pi on pi.pno = vrv.link_id
where
    vrv.visit_num > 0
    and vrv.type in (3,8)
    and vrv.created_at >= '2023-07-01'
    and vrv.created_at < '2023-08-18'
group by 1,2

;

select
    min(vrv.created_at)
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id and bc.client_name = 'tiktok'
where
    vrv.visit_num > 0
    and vrv.type in (3,8)
    and vrv.created_at >= '2023-07-01'
    and vrv.created_at < '2023-08-18'
    and vrv.visit_result = 43