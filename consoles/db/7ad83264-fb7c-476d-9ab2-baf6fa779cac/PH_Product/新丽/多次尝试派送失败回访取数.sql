select
    date(vrv.created_at) 日期
    ,bc.client_name 客户类型
    ,count(distinct vrv.id) 回访继续派送包裹量
    ,count(if(datediff(convert_tz(pi.finished_at, '+00:00', '+08:00'), vrv.updated_at) = 1 and pi.state = 5, vrv.id, null)) 回访后次日派送妥投成功
    ,count(if(datediff(convert_tz(pi.finished_at, '+00:00', '+08:00'), vrv.updated_at) = 2 and pi.state = 5, vrv.id, null)) 回访后第二天派送妥投成功
    ,count(if(datediff(convert_tz(pi.finished_at, '+00:00', '+08:00'), vrv.updated_at) = 3 and pi.state = 5, vrv.id, null)) 回访后第三天派送妥投成功
    ,count(if(datediff(convert_tz(pi.finished_at, '+00:00', '+08:00'), vrv.updated_at) > 3 and pi.state = 5, vrv.id, null)) 回访后第三天以上派送妥投成功
    ,count(if(datediff(convert_tz(rep.created_at, '+00:00', '+08:00'), vrv.updated_at) = 1 and pi.state = 7, vrv.id, null)) 回访后次日尝试派送退件
    ,count(if(datediff(convert_tz(rep.created_at, '+00:00', '+08:00'), vrv.updated_at) = 2 and pi.state = 7, vrv.id, null)) 回访后第二天尝试派送退件
    ,count(if(datediff(convert_tz(rep.created_at, '+00:00', '+08:00'), vrv.updated_at) = 3 and pi.state = 7, vrv.id, null)) 回访后第三天派送退件
    ,count(if(datediff(convert_tz(rep.created_at, '+00:00', '+08:00'), vrv.updated_at) > 3 and pi.state = 7, vrv.id, null)) 回访后第三天以上以上尝试派送退件
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id and bc.client_name in ('tiktok', 'shopee')
left join ph_staging.parcel_info pi on pi.pno = vrv.link_id
left join ph_staging.parcel_info rep on rep.pno = pi.returned_pno
where
    vrv.type = 8 -- 多次尝试失败回访
    and vrv.created_at >= '2023-09-11'
    and vrv.created_at < '2023-09-16'
    and vrv.visit_result = 43 -- 回访继续派送
group by 1,2


;


select
    date(vrv.created_at) 回访任务创建日期
    ,bc.client_name 客户类型
    ,pi.pno 单号
    ,pi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,pi.dst_phone 收件人手机号
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on bc.client_id = vrv.client_id and bc.client_name in ('tiktok', 'shopee')
left join ph_staging.parcel_info pi on pi.pno = vrv.link_id
left join ph_staging.order_info oi on oi.pno = pi.pno
# left join ph_staging.parcel_info rep on rep.pno = pi.returned_pno
where
    vrv.type = 8 -- 多次尝试失败回访
    and vrv.created_at >= '2023-09-11'
    and vrv.created_at < '2023-09-16'
    and vrv.visit_result = 43 -- 回访继续派送
    and pi.state = 5
# group by 1,2