select
    *
from
(
     select
         pr.pno
         ,pr.dst_name
         ,CONCAT('`', pr.dst_phone)
         ,pr.client_id
         ,date(pr.标记时间) 标记日期
         ,pr.标记时间
         ,case when hour(pr.标记时间)>= 8 and hour(pr.标记时间)<10 then '8点-10点前'
          when hour(pr.标记时间)>= 10 and hour(pr.标记时间)<12 then '10点-12点前'
          when hour(pr.标记时间)>= 12 and hour(pr.标记时间)<14 then '12点-14点前'
          when hour(pr.标记时间)>= 14 and hour(pr.标记时间)<16 then '14点-16点前'
         when hour(pr.标记时间)>= 16 and hour(pr.标记时间)<18 then '16点-18点前'
         when hour(pr.标记时间)>= 18 and hour(pr.标记时间)<20 then '18点-20点前'
         when hour(pr.标记时间)>= 20 and hour(pr.标记时间)<22 then '20点-22点前'
         when hour(pr.标记时间)>= 22 and hour(pr.标记时间)<24 then '22点-24点前'
         when hour(pr.标记时间)>= 0 and hour(pr.标记时间)<2 then '0点-2点前'
         when hour(pr.标记时间)>= 2 and hour(pr.标记时间)<4 then '2点-4点前'
         when hour(pr.标记时间)>= 4 and hour(pr.标记时间)<6 then '4点-6点前'
          when hour(pr.标记时间)>= 6 and hour(pr.标记时间)<8 then '6点-8点前'
        end as '标记时间段'
         ,prpf.电话时间 首次电话时间
         ,prp.电话时间
         ,prj.交接扫描时间
         ,ifnull(timestampdiff(second,prp.电话时间,pr.标记时间),0) 电话到标记时间差
         ,ifnull(timestampdiff(second,prpf.电话时间,pr.标记时间),0) 首次电话到标记时间差
          ,ifnull(timestampdiff(second,prj.交接扫描时间,pr.标记时间),0) 交接到标记时间差
         ,CASE di.rejection_category
         when 1 then '未购买商品'
         WHEN 2 then '商品不满意'
         WHEN 3 then '不想买了'
         WHEN 4 then '物流不满意'
         WHEN 5 then '理赔不满意'
         WHEN 6 then '外包装破损'
         WHEN 7 then '卖家问题拒收'
         WHEN 8 then '包裹破损'
         WHEN 9 then '包裹短少'
         WHEN 10 then '收件人不接受理赔(废弃)'
         WHEN 11 then '其中'
         end as '三级子原因'
         ,pr.标记类型
         ,pr.拒收类型
         ,pr.是否COD
         ,pr.网点名称
         ,pr.网点ID
         ,pr.`大区`
         ,pr.`片区`
         ,pr.网点类型
         ,pr.标记员工ID
         ,hjt.job_name as '快递员职位'
         ,pr.mark_lat
         ,pr.mark_lng
         ,prpf.call_lat first_call_lat
         ,prpf.call_lng first_call_lng
         ,prp.call_lat call_lat
         ,prp.call_lng call_lng
         ,pr.store_lat
         ,pr.store_lng
         ,prpf.callDuration
         ,ifnull(prpf.callDuration,0) '第一次通话时长'
         ,ifnull(prp.callDuration,0) '离标记最近的通话的时长'
         ,round(st_distance_sphere(point(prpf.call_lng,prpf.call_lat), point(pr.store_lng,pr.store_lat)),0) '第一次通话时距离'
         ,round(st_distance_sphere(point(prp.call_lng,prp.call_lat), point(pr.store_lng,pr.store_lat)),0) '离标记最近的通话时的距离'
         ,round(st_distance_sphere(point(pr.mark_lng,pr.mark_lat), point(pr.store_lng,pr.store_lat)),0) '标记时离网点的距离'
         ,rank() over(partition by pr.pno order by ifnull(timestampdiff(second,prp.电话时间,pr.标记时间),0)) rk
         ,rank() over(partition by pr.pno order by ifnull(timestampdiff(second,prpf.电话时间,pr.标记时间),0) desc) rkf
         ,rank() over(partition by pr.pno order by ifnull(timestampdiff(second,prj.交接扫描时间,pr.标记时间),0) desc)rkj
         ,min(pr_phone.电话时间)  离交接时间最近一次打电话的时间
         ,ifnull(timestampdiff(second,prj.交接扫描时间,min(pr_phone.电话时间)),0) 交接时间和最近一次电话的时间差
         -- ,case when dy.pno is not null then '延误' else '非延误' end 是否延误判责
     from
         (
          select
          pr.pno pno,pi.dst_name,pi.dst_phone
          ,pi.client_id
          ,convert_tz(pr.routed_at,'+00:00','+08:00') 标记时间
          ,case when pr.marker_category in (2,17) then '客户拒收'
                when pr.marker_category in (9,14,70) then '客户改约时间'
                else '异常情况' end 标记类型
          ,case when json_extract(pr.extra_value, '$.rejectionModeCategory') = 1 then '当面拒收'
                when json_extract(pr.extra_value, '$.rejectionModeCategory') = 2 then '电话拒收'
                else '客户改约时间' end 拒收类型
          ,pr.store_id 网点ID
          ,case when pi.cod_enabled = 1 then 'COD' else '非COD' end 是否COD
          ,ss.name 网点名称
          ,case when pr.store_category = 1  then 'SP'
             when pr.store_category = 10 then 'BDC'
             else 'other' end 网点类型
          ,pr.staff_info_id 标记员工ID
          ,json_extract(pr.extra_value, '$.lat') mark_lat
          ,json_extract(pr.extra_value, '$.lng') mark_lng
          ,ss.lat store_lat
          ,ss.lng store_lng
          ,ss.province_code
          ,ss.city_code
          ,ss.district_code
          ,mr.`name` '大区',mp.`name` '片区'
          ,row_number() over(partition by pr.pno order by pr.routed_at ) rk
          from `ph_staging`.parcel_route pr
          join `ph_staging`.sys_store ss on pr.store_id = ss.id
          left join `ph_staging`.parcel_info pi  on pr.pno = pi.pno
            LEFT JOIN `ph_staging`.`sys_manage_region` mr on mr.`id` =ss.`manage_region`
                LEFT JOIN `ph_staging`.`sys_manage_piece` mp on mp.`id` =ss.`manage_piece`
          where 1 = 1
          and pr.marker_category in (2,17,9,14,70)
          and pr.route_action = 'DELIVERY_MARKER'
          and pr.routed_at >= convert_tz(date_sub(CURRENT_DATE ,interval 1 day),'+08:00','+00:00')
          and pr.routed_at < convert_tz(CURRENT_DATE,'+08:00','+00:00')
          and pi.created_at >= convert_tz(date_sub(CURRENT_DATE ,interval 30 day),'+08:00','+00:00')

         ) pr
         LEFT JOIN `ph_bi`.hr_staff_info hsi on hsi.staff_info_id  =pr.标记员工ID
         LEFT JOIN ph_bi.hr_job_title hjt on hsi.job_title =hjt.id
         left join

         (
          select
          pr.pno pno
          ,convert_tz(pr.routed_at,'+00:00','+08:00') 电话时间
          ,pr.store_id 网点ID
          ,pr.staff_info_id 标记员工ID
          ,json_extract(pr.extra_value, '$.lat') call_lat
          ,json_extract(pr.extra_value, '$.lng') call_lng
          ,json_extract(pr.extra_value, '$.callDuration') callDuration
          from `ph_staging`.parcel_route pr
          where 1 = 1
          and pr.route_action in('PHONE','INCOMING_CALL') -- DELIVERY_TICKET_CREATION_SCAN
          and pr.routed_at >= convert_tz(date_sub(CURRENT_DATE ,interval 1 day),'+08:00','+00:00')
          and pr.routed_at <= convert_tz(CURRENT_DATE,'+08:00','+00:00')
         ) prp
         on pr.pno = prp.pno
         and prp.电话时间 < pr.标记时间
         and date(prp.电话时间) = date(pr.标记时间)

         left join

         (
          select
          pr.pno pno
          ,convert_tz(pr.routed_at,'+00:00','+08:00') 电话时间
          ,pr.store_id 网点ID
          ,pr.staff_info_id 标记员工ID
          ,json_extract(pr.extra_value, '$.lat') call_lat
          ,json_extract(pr.extra_value, '$.lng') call_lng
          ,json_extract(pr.extra_value, '$.callDuration') callDuration
          from `ph_staging`.parcel_route pr
          where 1 = 1
          and pr.route_action in('PHONE','INCOMING_CALL')
          and pr.routed_at >= convert_tz(date_sub(CURRENT_DATE ,interval 1 day),'+08:00','+00:00')
          and pr.routed_at <= convert_tz(CURRENT_DATE,'+08:00','+00:00')
         ) prpf
         on pr.pno = prpf.pno
         and prpf.电话时间 < pr.标记时间
         and date(prpf.电话时间) = date(pr.标记时间)

         LEFT JOIN
         (
             select pr.pno,convert_tz(pr.routed_at,'+00:00','+08:00') '交接扫描时间'
          from `ph_staging`.parcel_route pr
          where 1 = 1
          and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
          and pr.routed_at >= convert_tz(date_sub(CURRENT_DATE ,interval 1 day),'+08:00','+00:00')
          and pr.routed_at <= convert_tz(CURRENT_DATE,'+08:00','+00:00')
            )prj on prj.pno=pr.pno

        -- 新增加部分
        left join        (
          select
          pr.pno pno
          ,convert_tz(pr.routed_at,'+00:00','+08:00') 电话时间
          ,pr.store_id 网点ID
          ,pr.staff_info_id 标记员工ID
          ,json_extract(pr.extra_value, '$.lat') call_lat
          ,json_extract(pr.extra_value, '$.lng') call_lng
          ,json_extract(pr.extra_value, '$.callDuration') callDuration
          from `ph_staging`.parcel_route pr
          where 1 = 1
          and pr.route_action in('PHONE','INCOMING_CALL')
          and pr.routed_at >= convert_tz(date_sub(CURRENT_DATE ,interval 1 day),'+08:00','+00:00')
          and pr.routed_at <= convert_tz(CURRENT_DATE,'+08:00','+00:00')
         ) pr_phone
         on pr.pno = pr_phone.pno
         and pr_phone.电话时间 >= prj.交接扫描时间

        -- --

            LEFT JOIN `ph_staging`.diff_info di on di.pno =pr.pno
         where pr.rk = 1 -- AND prp.标记员工ID=pr.标记员工ID -- AND date(pr.标记时间)  date(pr.交接扫描时间)
          group by 1,2,3,4,5,6,7,8,9,10,11,12
) tt
where 1=1
    and tt.rk = 1
    and tt.rkf = 1
    AND tt.rkj=1