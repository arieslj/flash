select
    hr.`staff_info_id`
    ,hr.`job_title`
    ,si.`name`
    ,case hr.`state`
        when 1 then '在职'
        when 2 then '离职'
    end as state
    ,hr.`hire_date` 入职日期
from  `my_bi`.`hr_staff_info`  hr
left join `my_staging`.`staff_info_job_title` si on si.`id` = hr.`job_title`
where
    hr.`staff_info_id` in
    ();

select
hr.`staff_info_id`
,hr.`identity` 身份证
,hr.mobile 手机号
,hr.`company_name_ef` 外协公司
from  `my_bi`.`hr_staff_info`  hr
where hr.`staff_info_id` in
('348089','354342','355287','355293','375579','377316','378480','378685','383983','385021','385311','385687','394275','394434','395126','395302','395304','396072','396184','398420','398570','398828','398977','399030','399096','399103','399142','399143','399153','399201','399329','399403','400241','400332','400338','400375','400396','400423','400601','401203','401578','402038','402057','402235','402332','402337','402483','402526','402549','402832','402835','402882','403031','403074','403075','403080','403106','403260','403263','403388','403436','403450','403475','404149','404227','404481','404487','404741','404827','404858','404867','405434','405710','406270','406293','406296','406440','406484','406566','406580','406711','406750','406818','406906','406989','407102','407116','408186','408187','408216','408221','408237','408523','408524','408531','408568','409095','409101','409764','409849','410536','410537','410575','410650','410653','410736','410752','410767','410775','411011','411041','411042','411046','411054','411162','411181','412661','412704','412727','412733','412745','412758','412766','412772','412788','412877','412952','413055','413134','413135','413419','413444','413446','413588','413634','413661','413663','413914','414043','414207','414208','414273','414277','414305','414310','414324','414340','414486','414538','414630','414738','414968','415011','415676','415697','415726','417689')


;

select a.id,
date(a.date),
count( a.`pno` )
from
(
select distinct pi.`pno`, sw.ID ,date(sw.`date`) date
from tmpale.tmp_my_time_2023_12_06 sw
left join `my_staging`.`parcel_info`  pi
on pi.`ticket_delivery_staff_info_id` = sw.`id`
and convert_tz(pi.`finished_at`,'+00:00','+08:00') >=from_unixtime(sw.`ttime`)
and convert_tz(pi.`finished_at`,'+00:00','+08:00')<= date_add(sw.date,interval 1 day)
where pi.`state` =5
#and pi.`ticket_delivery_staff_info_id` ='3158683'
#and date(sw.`date` )='2022-12-03'
) a
#where a.id='3158683'
group by 1,2