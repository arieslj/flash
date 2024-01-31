# 神仙卡 标记问题件
with a as
         (select pr.pno
               , pr.store_id
               , pr.staff_info_id
               , pr.marker_category
               , date(convert_tz(pr.routed_at, '+00:00', '+07:00')) dt
          from rot_pro.`parcel_route` pr
          where pr.routed_at >= date_sub('2023-12-04', interval 7 hour)
            and pr.routed_at < date_sub('2023-12-05', interval 7 hour)
#             and pr.`marker_category` in (2, 17) -- 标记信息
            and route_action = 'DELIVERY_MARKER'
          group by 1, 2, 3, 4, 5
         )
select phone.pno
     , phone.CN_element                 问题件标记类型
     , phone.client_id
     , phone.客户类型
     , phone.打电话时间
     , phone.打电话日期
     , phone.通话时长
     , phone.响铃时长
     , phone.运营商
     , phone.`staff_info_id`
     , scan.scan_cnt                    快递员的交接扫描单量
     , scan.confirm_cnt                 快递员的妥投单量
     , scan.scan_cnt - scan.confirm_cnt 快递员的未妥投单量
     , scan.detain_cnt                  快递员的货件留仓单量
     , scan.marker_cnt                  快递员的问题件标记单量
     , phone.`staff_info_phone`
     , phone.store_id
     , phone.store_name
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
                       , pr.store_id
                       , pr.store_name
                       , smp.name                                                            片区
                       , smr.name                                                            大区
                       , row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                  from (select *
                        from `rot_pro`.`parcel_route` pr
                        where pr.routed_at >= date_sub('2023-12-04', interval 7 hour)
                          and pr.routed_at < date_sub('2023-12-05', interval 7 hour)
                          and pr.`route_action` = 'PHONE'
                          and json_extract(pr.`extra_value`, '$.callDuration') >= 15
                       ) pr
                           join a on a.pno = pr.pno and pr.store_id = a.store_id and pr.staff_info_id = a.staff_info_id
                           left join fle_staging.parcel_info pi on pi.pno = a.pno
                           left join dwm.tmp_ex_big_clients_id_detail bc
                                     on pi.client_id = bc.client_id

                           left join fle_staging.ka_profile kp
                                     on pi.client_id = kp.id
                           left join fle_staging.sys_store ss on ss.id = pr.store_id
                           left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
                           left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
                           left join (select *
                                      from dwm.dwd_dim_dict
                                      where tablename = 'diff_info'
                                        and fieldname = 'diff_marker_category') dict
                                     on a.marker_category = dict.element
#          where
              ) pr
         where pr.rn = 1
     ) phone
         left join ( -- 快递员的工作量
    select pr.staff_info_id
         , count(distinct (if(pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and rn = 1, pr.pno,
                              null)))                                                          scan_cnt    -- scan 快递员的交接扫描单量
         , count(distinct
                 (if(pr.route_action = 'DELIVERY_CONFIRM', pr.pno, null)))          confirm_cnt -- confirm 快递员的妥投单量
         , count(distinct
                 (if(pr.route_action = 'DETAIN_WAREHOUSE' , pr.pno, null)))          detain_cnt  -- detain 快递员的货件留仓单量
         , count(distinct
                 (if(pr.route_action = 'DELIVERY_MARKER' , pr.pno, null)))           marker_cnt  -- marker 快递员的问题件标记单量
    from (select *,
                 date(convert_tz(pr.routed_at, '+00:00', '+07:00')) dt
          from (
                   select *,
                          row_number() over (partition by pno,route_action order by routed_at desc) rn
                   from `rot_pro`.`parcel_route` pr
                   where pr.routed_at >= date_sub('2023-12-04', interval 7 hour)
                     and pr.routed_at < date_sub('2023-12-05', interval 7 hour)
#               and pno = 'THT0142N1JPR6Z' 多次扫描case
               ) pr
          where pr.`route_action` in
                ('DELIVERY_TICKET_CREATION_SCAN', 'DELIVERY_CONFIRM', 'DETAIN_WAREHOUSE', 'DELIVERY_MARKER')
#             and pno = 'THT0142N1JPR6Z' -- 多次扫描case
         ) pr
             join a on pr.store_id = a.store_id and pr.staff_info_id = a.staff_info_id and pr.dt = a.dt
    group by pr.staff_info_id
) scan on phone.staff_info_id = scan.staff_info_id