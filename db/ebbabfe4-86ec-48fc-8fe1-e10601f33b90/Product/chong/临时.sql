
select
    t.pno
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
from my_staging.parcel_info pi
join tmpale.tmp_my_pno_lj_0126 t on t.pno = pi.pno
left join my_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join my_staging.parcel_additional_info pai on pai.pno = pi2.pno

;


SELECT
    pi.`pno` 'Note',
    pi.recent_pno 'New pno',
    pi.`dst_name` 'Name',
    pi.`dst_phone` 'Phone Number',
    pi.`dst_detail_address` 'Address',
    case pi.article_category
     when 0 then 'File'
     when 1 then 'Dry Food'
     when 2 then 'Daily necessities'
     when 3 then 'Digital Products'
     when 4 then 'Clothes'
     when 5 then 'Book'
     when 6 then 'Auto parts'
     when 7 then 'Shoes and bags'
     when 8 then 'Exercise tools'
     when 9 then 'Household'
     when 10 then 'Furniture'
     when 11 then 'Fruit'
     when 99 then 'Others'
    end as 'Item',
    pi.`store_length` 'Length (cm)',
    pi.`store_width`  'Width (cm)',
    pi.`store_height` 'Height (cm)',
    pi.`store_weight`*0.001 'Weight (kg)',
    '1' as 'Number of Packages',
    pi.`dst_postal_code` 'Dropoff Zip Code' ,
    sc.`name` 'Dropoff City',
    case pi.`cod_enabled`
    when 1 then '是'
    else  '否' end as '是否cod',
    convert_tz(pi.`created_at` ,'+00:00','+08:00') 揽收时间,
    ss.`name` 目的地网点,
      CASE pi.state WHEN 1 THEN '已揽收' WHEN 2 THEN '运输中' WHEN 3 THEN '派送中' WHEN 4 THEN '已滞留' WHEN 5 THEN '已签收' WHEN 6 THEN '疑难件处理中' WHEN 7 THEN '已退件' WHEN 8 THEN '异常关闭' ELSE 'OTHER' END AS '包裹状态'
    ,if(ad.`cogs_amount` IS NOT NULL ,ad.`cogs_amount` ,oi.`cogs_amount` )  *0.01 '物品价值'
    ,oi.cod_amount/100 'COD金额'

FROM `my_staging`.`parcel_info` pi
LEFT JOIN `my_staging`.`sys_city`  sc on pi.`src_city_code` = sc.`code`
left JOIN `my_staging`.`sys_store` ss on ss.`id` =pi.`dst_store_id`
LEFT JOIN `my_staging`.`order_info` oi on pi.`pno` =oi.`pno`
left join  `my_staging`.`parcel_additional_info`  ad on ad.`pno` =pi.`pno`
 where  pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
or pi.recent_pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
limit 5000