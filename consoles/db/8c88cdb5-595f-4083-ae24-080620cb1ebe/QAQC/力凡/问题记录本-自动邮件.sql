select
    date (convert_tz(ci.created_at, '+00:00', '+07:00')) 日期
    ,ci.submitter_department 提交部门
    ,ci.submitter_id 提交工号
    ,count(distinct ci.pno) 提交的运单票数
    ,sum(ifnull(pi.cod_amount, 0))/100 提交的COD合计
from fle_staging.customer_issue ci
left join fle_staging.parcel_info pi on pi.pno = ci.pno
-- left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ci.submitter_id
where
    ci.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
    and ci.created_at < date_sub(curdate(), interval 7 hour)
    and ci.request_sup_type = 26
    and ci.request_sub_type = 260
    and ci.submitter_department = 'QAQC'
group by 1,2,3
order by 1,2,3

;


select
    date (convert_tz(ci.created_at, '+00:00', '+07:00')) 日期
    ,ci.submitter_department 提交部门
    ,ci.submitter_id 提交工号
    ,pi.pno 运单号
    ,pi.cod_amount/100 COD金额
from fle_staging.customer_issue ci
left join fle_staging.parcel_info pi on pi.pno = ci.pno
-- left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ci.submitter_id
where
    ci.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
    and ci.created_at < date_sub(curdate(), interval 7 hour)
    and ci.request_sup_type = 26
    and ci.request_sub_type = 260
    and ci.submitter_department = 'QAQC'
