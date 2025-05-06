with a as
         (select pr.pno
               , pr.store_id
               , pr.staff_info_id
               , pr.marker_category
               , date(convert_tz(pr.routed_at, '+00:00', '+07:00')) dt
          from rot_pro.`parcel_route` pr
          where pr.routed_at >= date_sub('2024-05-15', interval 7 hour)
            and pr.routed_at < date_sub('2024-05-17', interval 7 hour)
#             and pr.`marker_category` in (2, 17) -- 标记信息
            and route_action = 'DELIVERY_MARKER'
          group by 1, 2, 3, 4, 5
         )
select phone.pno
     , phone.CN_element 问题件标记类型
     , phone.client_id
     , phone.客户类型
     , phone.打电话时间
     , phone.打电话日期
     , phone.通话时长
     , phone.响铃时长
     , phone.运营商
     , phone.`staff_info_id`
     , scan.交接量         快递员的交接扫描单量
     , scan.妥投量         快递员的妥投单量
     , scan.未妥投量        快递员的未妥投单量
     , scan.留仓量         快递员的货件留仓单量
#      , scan.marker_cnt                  快递员的问题件标记单量
     , phone.`staff_info_phone`
     , phone.job_name 岗位
     , phone.store_id 网点
     , phone.store_name 网点名称
     , phone.片区
     , phone.大区
from (-- phone 打电话情况
         select pr.*
         from (
                  select pr.pno
                       , dict.CN_element
                       , pi.client_id
                       , case
                             when bc.`client_id` is not null then bc.client_name
                             when kp.id is not null and bc.id is null then '普通ka'
                             when kp.`id` is null then '小c'
                      end as                                                                 客户类型
                       , convert_tz(pr.routed_at, '+00:00', '+07:00')                        打电话时间
                       , date(convert_tz(pr.routed_at, '+00:00', '+07:00'))                  打电话日期
                       , json_extract(pr.`extra_value`, '$.callDuration')                    通话时长
                       , json_extract(pr.extra_value, '$.diaboloDuration')                   响铃时长
                       , json_extract(pr.extra_value, '$.carrierName')                       运营商
                       , pr.`staff_info_id`
                       , pr.`staff_info_phone`
                       , hjt.job_name
                       , pr.store_id
                       , pr.store_name
                       , smp.name                                                            片区
                       , smr.name                                                            大区
                       , row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                  from (select *
                        from `rot_pro`.`parcel_route` pr
                        where pr.routed_at >= date_sub('2024-05-15', interval 7 hour)
                          and pr.routed_at < date_sub('2024-05-17', interval 7 hour)
                          and pr.`route_action` = 'PHONE'
                          and json_extract(pr.`extra_value`, '$.callDuration') >= 15
                       ) pr
                           join a on a.pno = pr.pno and pr.store_id = a.store_id and pr.staff_info_id = a.staff_info_id
                           left join fle_staging.parcel_info pi on pi.pno = a.pno
                           left join dwm.tmp_ex_big_clients_id_detail bc on pi.client_id = bc.client_id
                           left join fle_staging.ka_profile kp on pi.client_id = kp.id
                           left join fle_staging.sys_store ss on ss.id = pr.store_id
                           left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
                           left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
                           left join `backyard_pro`.`hr_staff_info` hsi on hsi.staff_info_id = pr.staff_info_id
                           left join `backyard_pro`.`hr_job_title` hjt on hjt.`id` = hsi.`job_title`

                           left join (select *
                                      from dwm.dwd_dim_dict
                                      where tablename = 'diff_info'
                                        and fieldname = 'diff_marker_category') dict
                                     on a.marker_category = dict.element
              ) pr
         where pr.rn = 1
     ) phone
         left join ( -- 快递员的工作量
    SELECT staff_info_id
         , count(if(td.state in (0, 1, 2), td.pno, null)) 交接量
         , count(if(td.state = 0, td.pno, null))          未妥投量
         , count(if(td.state = 1, td.pno, null))          妥投量
         , count(if(td.state = 2, td.pno, null))          留仓量
    FROM fle_staging.ticket_delivery td
    WHERE 1 = 1
#     and td.staff_info_id IN (658226)
      and td.state in (0, 1, 2)
      AND td.transfered = 0
      AND td.created_at >= date_sub('2024-05-15', interval 7 hour)
      AND td.created_at <= date_sub('2024-05-17', interval 7 hour)
    group by td.staff_info_id
) scan on phone.staff_info_id = scan.staff_info_id