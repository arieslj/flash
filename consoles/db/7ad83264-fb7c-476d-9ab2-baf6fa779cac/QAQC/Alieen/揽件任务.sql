select
        tp.id 揽件任务ID
        ,tp.staff_info_id 快递员
        ,ss.name 网点
from ph_staging.ticket_pickup tp
left join ph_staging.sys_store ss on ss.id = tp.store_id
where
    tp.created_at >= '2023-12-12 16:00:00'
    and tp.created_at < '2023-12-13 16:00:00'

;

#
# SELECT pi.ticket_pickup_store_id '网点id'
#     ,ss.name '网点名称'
#     ,sme.name '大区'
#     ,smp.name '片区'
#     ,date(convert_tz(pi.created_at,'+00:00', '+08:00'))   '日期'
#     ,count(distinct if( pi.returned =0, pi.pno,null) ) '总揽件量'
#     ,COUNT(DISTINCT if(ddb.`client_name`  ="lazada"and ddb.`remark` = "warehouse" and pi.returned =0 ,pi.`pno` ,null)) 'Lazada-仓库揽收量'
#     ,COUNT(DISTINCT if(ddb.`client_name`  ="lazada"and ddb.`remark` = "seller" and pi.returned =0 ,pi.`pno` ,null)) 'Lazada-seller揽收量'
#     ,COUNT(DISTINCT IF(ddb.`client_name`  ="shopee"and ddb.`remark` in ("seller","dropoff")  and pi.returned =0,pi.`pno` ,null)) 'shopee-seller揽收量'
#      ,COUNT(DISTINCT IF(ddb.`client_name`  ="tiktok" and pi.returned =0,pi.`pno` ,null)) 'tiktok揽收量'
# 	 ,COUNT(DISTINCT IF(ddb.`client_name`  ="shein" and pi.returned =0,pi.`pno` ,null)) 'shein揽收量'
#     ,count(distinct if(pi.customer_type_category=2 and ddb.`client_name` is null
#                        and pi.returned =0,pi.pno ,null)) 'KA客户揽收量'
#     ,count(distinct if(pi.customer_type_category=1 and ddb.`client_name` is null
#                        and pi.returned =0 and ss.`category` not in (4,5,6,7) ,pi.pno ,null)) 'GE客户揽收量'
# 	,count(distinct if(pi.`client_id` in ('BA0196','BA0233') and pi.returned =0 ,pi.pno ,null)) '跨境客户揽收量'
#     ,count(distinct if(ss.category = 6 and `customer_type_category` = 1 and pi.returned =0 ,pi.pno ,null)) 'FH揽收量'
#     ,count(distinct if(ss.`category` in (4,5,7) and `customer_type_category` = 1 and
#                        ddb.`client_name` is null
#                        and pi.returned =0 ,pi.pno ,null)) 'shop揽收量'
#     ,COUNT(distinct IF(pi.returned =1,pi.pno,null )) '退件量'
#
# FROM ph_staging.parcel_info pi
#
# left JOIN `dwm`.dwd_dim_bigClient ddb on pi.`client_id` =ddb.`client_id` ##大客户
# left join ph_staging.`sys_store` ss on ss.`id`= pi.ticket_pickup_store_id ##揽件网点
# left join ph_staging.sys_manage_region sme on ss.manage_region= sme.id ##大区
# left join ph_staging.sys_manage_piece smp on ss.manage_piece= smp.id ##片区
# LEFT JOIN `ph_staging`.`ka_profile` ka ON ka.`id` = pi.`client_id`
#
#
# WHERE  pi.`created_at` >=convert_tz('${starttime}','+08:00','+00:00')
# and pi.`created_at` <=convert_tz('${endtime} 23:59:59','+08:00','+00:00')
# and pi.state <> 9 ##剔除撤销件
#
# GROUP BY   1,2,3,4,5
#  ORDER BY 6 desc