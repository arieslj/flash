select
hr.`staff_info_id`
,hr.`identity` 身份证
,hr.mobile 手机号
,hr.`company_name_ef` 外协公司
from  `ph_bi`.`hr_staff_info`  hr
where hr.`staff_info_id` in
(
'394000','393814','393814','393814','386101','394000','394000','393327','393327','390841','394001','394001','394001','394001','394001','391857','391857','394982','394982','393904','393904','393904','391867','391867','391867','391867','391867','391867','392986','392986','392986','392986','392986','392986','392986','392986'
)


;


-- 正式员工入职信息
select
hr.`staff_info_id`
,hr.`job_title`
,si.`name`
,case hr.`state`
when 1 then '在职'
when 2 then '离职'
end as state
,hr.`hire_date` 入职日期
from  `ph_bi`.`hr_staff_info`  hr
left join `ph_staging`.`staff_info_job_title` si
on si.`id` = hr.`job_title`
where hr.`staff_info_id` in
('179256','178687','177815','177678','178152','178599','177747','177882','178011','160375','177806')

;


select a.id,
date(a.date),
count( a.`pno` )
from
(
select distinct pi.`pno`, sw.ID ,date(sw.`date`) date
from tmpale.tmp_ph_ttime_0104 sw
left join `ph_staging`.`parcel_info`  pi
on pi.`ticket_delivery_staff_info_id` = sw.`id`
and convert_tz(pi.`finished_at`,'+00:00','+08:00') >=from_unixtime(sw.`ttime`)
and convert_tz(pi.`finished_at`,'+00:00','+08:00')<= date_add(sw.date,interval 1 day)
where pi.`state` =5
#and pi.`ticket_delivery_staff_info_id` ='3158683'
#and date(sw.`date` )='2022-12-03'
) a
#where a.id='3158683'
group by 1,2
