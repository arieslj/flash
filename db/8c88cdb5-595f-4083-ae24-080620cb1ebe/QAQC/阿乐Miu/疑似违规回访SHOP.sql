select
    case vrv.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,vrv.client_id 客户ID
    ,vrv.created_at 任务创建时间
    ,vrv.link_id 关联单号
    ,a.归属网点名称
from
    (
        select
            vrv.id
            ,vrv.created_at
            ,vrv.client_id
            ,vrv.link_id
            ,vrv.type
#             ,case vrv.type
#                 when 1 then '揽件任务异常取消'
#                 when 2 then '虚假妥投'
#                 when 3 then '收件人拒收'
#                 when 4 then '标记客户改约时间'
#                 when 5 then 'KA现场不揽收'
#                 when 6 then '包裹未准备好'
#                 when 7 then '上报错分未妥投'
#                 when 8 then '多次尝试派送失败'
#             end 回访类型
        from nl_production.violation_return_visit vrv
        where
            vrv.created_at > '2024-11-01'
            and vrv.created_at < '2024-12-01'
           -- and vrv.link_id = 'TH10056DECWN8B'
    ) vrv
join
    (
        select
            distinct a.id
            ,a.归属网点名称
            ,a.department
            ,a.归属网点id
        from
            (
                SELECT
                    kp.id
                    ,CASE
                        WHEN bc.client_name = 'lazada' then  'PMD-lazada'
                        WHEN bc.client_name = 'shopee' then  'PMD-shopee'
                        WHEN bc.client_name = 'tiktok' then  'PMD-tiktok'
                        WHEN bc.client_name ='AA0622' THEN 'PMD-shein'
                        WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '20001' THEN 'FFM'
                        WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '4' THEN 'Network'
                        WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '34' THEN 'Network Bulky'
                        WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '40' THEN 'Sales'
                        WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' and if(kp.`account_type_category` = '3',hs2.`node_department_id`, hs.`node_department_id`) IN ('1098','1099','1100','1101','1268') THEN 'Retail-sales'
                        WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' THEN 'Shop'
                        WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' AND if(kp.`account_type_category` = '3',kp.`agent_id`, kp.`id`) = 'BF5633' THEN 'PMD-CFM'
                        WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' THEN 'PMD-KAM'
                        WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '3' THEN 'Customer Service'
                        WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '545' THEN 'Bulky Business Development'
                        else 'Other'
                    END AS department
                    ,if(kp.`account_type_category` = '3',kp2.store_id, kp.`store_id`) '归属网点id'
                    ,if(kp.`account_type_category` = '3',ss2.`name`, ss.`name`) '归属网点名称'
                FROM fle_staging.ka_profile kp
                LEFT JOIN fle_staging.ka_profile kp2 on kp2.`id` =kp.`agent_id`
                 LEFT JOIN bi_pro.hr_staff_info hs on kp.`staff_info_id` = hs.`staff_info_id`
                LEFT JOIN bi_pro.hr_staff_info hs2 on kp2.`staff_info_id` = hs2.`staff_info_id`
                LEFT JOIN `fle_staging`.`sys_store` ss on ss.`id` =kp.store_id
                LEFT JOIN `fle_staging`.`sys_store` ss2 on ss2.`id` =kp2.store_id
                LEFT JOIN dwm.tmp_ex_big_clients_id_detail bc on bc.`client_id` =kp.id

#                 union all
#
#                 SELECT
#                 pi.client_id 客户id
#                 , case
#                                         when kp.`agent_category`= '3'  AND kp.department_id= '388' THEN 'PMD-KAM'
#                                         when ss.`category` in ('1') THEN 'Network'
#                                         when ss.`category` in ('10','13') THEN 'Network Bulky'
#                                         when ss.`category` in ('4','5','7') THEN 'Shop'
#                                         when ss.`category` in ('6') THEN 'FH'
#                                         when ss.`category` in ('11') THEN 'FFM'
#                                         else 'Other'
#                            end 归属部门,
#                    pi.`ticket_pickup_store_id` '归属网点id'
#                     ,ss.`name` '归属网点名称'
#                 FROM fle_staging.parcel_info pi
#                 LEFT JOIN `fle_staging`.`sys_store` ss on ss.`id` =pi.`ticket_pickup_store_id`
#                 LEFT JOIN fle_staging.ka_profile kp on pi.`agent_id`  =kp.`id`
#                 LEFT JOIN dwm.tmp_ex_big_clients_id_detail bc on bc.`client_id` =pi.`client_id`
#                 WHERE
#                 pi.`created_at`   >= convert_tz(DATE_FORMAT(curdate(),'%Y-%m-01')-interval 1 month,'+07:00','+00:00')
#                 and pi.`created_at`   < convert_tz(DATE_FORMAT(curdate(),'%Y-%m-01')-interval 0 month,'+07:00','+00:00')
#                 AND pi.`state` !='9'
#                 AND pi.`returned` ='0'
#                 and pi.`customer_type_category` ='1'
            ) a
        where
            a.归属网点名称 != 'Autoqaqc'
    )a on a.id = vrv.`client_id`
where
    a.department = 'Shop'

union all

select
    case vrv.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 回访类型
    ,vrv.client_id 客户ID
    ,vrv.created_at 任务创建时间
    ,vrv.link_id 关联单号
    ,ss.name 归属网点名称
from
    (
        select
            vrv.id
            ,vrv.created_at
            ,vrv.client_id
            ,vrv.link_id
            ,vrv.type
#             ,case vrv.type
#                 when 1 then '揽件任务异常取消'
#                 when 2 then '虚假妥投'
#                 when 3 then '收件人拒收'
#                 when 4 then '标记客户改约时间'
#                 when 5 then 'KA现场不揽收'
#                 when 6 then '包裹未准备好'
#                 when 7 then '上报错分未妥投'
#                 when 8 then '多次尝试派送失败'
#             end 回访类型
        from nl_production.violation_return_visit vrv
        where
            vrv.created_at > '2024-11-01'
            and vrv.created_at < '2024-12-01'
           -- and vrv.link_id = 'TH10056DECWN8B'
    ) vrv
left join fle_staging.parcel_info pi on vrv.link_id = pi.pno
left join fle_staging.ka_profile kp on kp.id = vrv.client_id
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
where
    pi.created_at > '2024-11-01'
    and kp.id is null
    and pi.`returned` ='0'
    and pi.`customer_type_category` ='1'
    and ss.category in (4,5,7) -- SHOP

