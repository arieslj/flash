select
    vrv.client_id  客户ID
    ,ss.name 网点名称
    ,vrv.link_id 单号
    ,vrv.created_at 提交时间
from nl_production.violation_return_visit vrv
left join ph_staging.sys_store ss on ss.id = vrv.store_id
where
    vrv.type = 8
    and vrv.created_at >= '2024-02-26'
    and vrv.created_at < '2024-03-04'
    and vrv.client_id in ('AA0089','AA0090','AA0128','AA0051','AA0050','AA0080','AA0121','AA0139','AA0131')