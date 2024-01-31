-- 文档：https://flashexpress.feishu.cn/docx/AYkvdzK4coqAkYxtVk7cE14tn8b

/*
        =====================================================================+
        表名称：985d_ph_tiktok_daily_delivery
        功能描述：菲律宾TT历史未派送成功明细

        需求来源：
        编写人员: jiangtong
        设计日期：2022-10-21
        修改日期: 2023-01-04
        修改人员: jaingtong
        修改记录：2023-10-11,苏德明,确认时间 范围由固定日期'2022-10-18'之后调整为近30天
        修改原因: 修改为所有正向回调未达终态的派送包裹
  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
  +=====================================================================
  */


 select

          sd.client_id
         ,sd.pno 'Tracking number '
         ,sd.order_time 'creation_date'
         ,sd.confirm_time 'booking_date'
         ,sd.pickup_time 'Actual Pickup TIME'
         ,date(sd.pickup_time) 'Actual Pickup Date'
         ,case when sd.returned='0' then '正向件'
                   when sd.returned='1' then '退件'
                   else null end as '正向/退件'
          ,case when sd.returned='0' and date(sd.last_route_time)>sd.end_date and date(sd.last_route_time)<=sd.end_7_date then '正向普通超时'
                        when sd.returned='0' and date(sd.last_route_time)>sd.end_7_date then '正向严重超时'
                        when sd.returned='1' and date(sd.last_route_time)>sd.end_date and date(sd.last_route_time)<=sd.end_7_date then '退件普通超时'
                        when sd.returned='1' and date(sd.last_route_time)>sd.end_7_date then '退件严重超时'
                        when date(sd.last_route_time)<=sd.end_date then datediff(sd.end_date,sd.last_route_time)
                        else null end as '剩余SLA'
         ,prk.delivery_attempt  'Delivery Attempts made'
         ,prk.last_attempt_failed_time 'Last Attempts Failed Time'
         ,case pi.`state`
         when 1 then '已揽收'
         when 2 then '运输中'
         when 3 then '派送中'
         when 4 then '滞留中'
         when 5 then '已签收'
         when 6 then '疑难件处理中'
         when 7 then '已退件'
         when 8 then '异常关闭'
         when 9 then '已撤销'
         end 'Parcel_Status'
         ,fa.failed_delivery_reason
         ,fa.failed_delivered_date
         ,fa.failure_courier_id
         ,fa.failure_courier_id_dc
         ,ca.action_code 'Parcel Callback Query Status'

         ,sd.src_store 'Pick up branch'
         ,sd.parcel_state_name 'current status'
         ,sd.dst_routed_at 'date & time arrived at destination branch '
         ,sd.last_store_name 'Current parcel located branch'
         ,sd.dst_store 'Destination  Branch'
         ,sd.dst_province 'Delivery DC Province'
         ,sc.name 'Delivery DC city'
         ,sd.dst_area_name 'Delivery DC Tiktok Region'
         ,sd.exhibition_weight/1000 'Actual Weight'
         ,sd.exhibition_length 'Actual package_length'
         ,sd.exhibition_width 'Actual package_width'
         ,sd.exhibition_height 'Actual package_height'
         ,sd.cod_enabled 'COD type'
         ,kw.out_client_id 'seller_id'
         ,sd.parcel_src_name 'seller_name'

         ,sd.first_scan_time 'date of 1st handover to rider'
         ,if(sd.first_marker_at is not null,timestampdiff(hour,sd.pickup_time,sd.first_marker_at)/24,timestampdiff(hour,sd.pickup_time,sd.finished_time)/24) 'count of days from pick up date'
         ,sd.sla 'recipient SLA area'
         ,a.pod 'POD'
         ,pi.dst_phone

from
(
        select * from dwm.dwd_ex_ph_tiktok_sla_detail sd
        where
        confirm_time >=date_add(current_date, interval -30 day)
        and sd.pickup_time is not null
        and sd.returned_pno is null
        and sd.returned=0
) sd

left join
(
  select
  *
  from
  (
          select
                ca.tracking_no pno
           ,ca.action_code
           ,row_number() over(partition by ca.tracking_no ORDER BY ca.created_at desc) rn
          from dwm.`dwd_ph_tiktok_parcel_route_callback_record` ca
          where
          created_at>=convert_tz(DATE_ADD(CURDATE(),interval -60 day) ,'+08:00','+00:00')
  ) tt
  where
  tt.rn=1
)ca on sd.pno=ca.pno


left join ph_staging.sys_city sc on sd.dst_city_code=sc.code
left join ph_staging.parcel_info pi on sd.pno=pi.pno and pi.created_at>=convert_tz(DATE_ADD(CURDATE(),interval -33 day) ,'+08:00','+00:00')
left join `ph_staging`.`ka_warehouse` kw on kw.`id` = pi.`ka_warehouse_id`

left join
(
   select
                pno
                ,group_concat(concat(delivery_attempts,',',reason) ORDER BY p_date ) failed_delivery_reason
                ,group_concat(concat(delivery_attempts,',',p_date) ORDER BY p_date ) failed_delivered_date
                ,group_concat(concat(delivery_attempts,',',staff_info_id) ORDER BY p_date ) failure_courier_id
                ,group_concat(concat(delivery_attempts,',',name) ORDER BY p_date ) failure_courier_id_dc
                ,max(delivery_attempts) attempts
  from
  (
       SELECT
         pr.tracking_no pno
        ,replace(json_extract(delivery_courier, '$.name'),'"','') 'delivery_name'
        ,pr.reason_code
        ,case when pr.reason_code='R102' then '收件人拒付货款'
              when pr.reason_code='R103' then '收件人地址错误'
              when pr.reason_code='R104' then '联系不到收件人'
              when pr.reason_code='R105' then '收件人号码错误'
              when pr.reason_code='R106' then '收件人拒收'
              when pr.reason_code='R107' then '包裹破损拒收'
              when pr.reason_code='R108' then '收件人要求改派'
              when pr.reason_code='R109' then '包裹含禁运品'
              when pr.reason_code='R110' then '恶劣天气或不可抗力'
              when pr.reason_code='R149' then '消费者刷单'
              when pr.reason_code='R147' then '交通事故'
              when pr.reason_code='R148' then '其他异常原因'
              when pr.reason_code='R117' then '包裹破损'
              when pr.reason_code='R116' then '包裹丢失'
              when pr.reason_code='R112' then '分拣错误'
              else null end as reason
        ,convert_tz(pr.created_at,'+00:00','+08:00') created_at
        ,date(convert_tz(pr.created_at,'+00:00','+08:00')) p_date
        ,pr.delivery_attempts delivery_attempts
        ,hr.staff_info_id
        ,sy.name
        ,row_number() over(partition by pr.tracking_no,date(convert_tz(pr.created_at,'+00:00','+08:00')) ORDER BY convert_tz(pr.created_at,'+00:00','+08:00') ) rn

        FROM dwm.`dwd_ph_tiktok_parcel_route_callback_record` pr
        left join ph_bi.hr_staff_info hr on lower(replace(json_extract(delivery_courier, '$.name'),'"',''))=lower(hr.name)
        left join ph_staging.sys_store sy on hr.sys_store_id=sy.id
        where
                pr.action_code in('sign_failure','1st_attempt_failed','2nd_attempt_failed','3rd_attempt_failed','multiple_attempt_failed')
                and pr.created_at>=convert_tz(DATE_ADD(CURDATE(),interval -60 day) ,'+08:00','+00:00')
    )a
    where
        a.rn=1
    group by 1

) fa on pi.pno=fa.pno

left join
( -- 找到首条parcel_route做过标记的包裹（快递员标记、疑难件标记）
 SELECT
   c.pno
  ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', c.object_key) ORDER BY c.p_date ) pod

        FROM
        (
                select pr.`pno`,
                           pr.marker_category,
                           PR.`route_action`,
                           pr.remark,
                           date_format(convert_tz(pr.routed_at, '+00:00', '+08:00'), '%Y-%m-%d')  p_date,
                           convert_tz(pr.routed_at, '+00:00', '+08:00')  routed_at,
                           row_number() over(partition by pr.pno, substring(convert_tz(pr.routed_at, '+00:00', '+08:00'), 1, 10)  order by convert_tz(pr.routed_at, '+00:00', '+08:00')desc)  rnk
                from ph_staging.parcel_route pr
                join dwm.dwd_ex_ph_tiktok_sla_detail sd on pr.pno=sd.pno
                where
                pr.`route_action` in ( 'DELIVERY_MARKER','DIFFICULTY_HANDOVER')
                and pr.routed_at>=convert_tz(DATE_ADD(CURDATE(),interval -60 day) ,'+08:00','+00:00')
				and sd.pick_date>=DATE_ADD(CURDATE(),interval -60 day)
        ) T
   left join
   (
          -- 找到照片Link
      select td.pno
            ,ss.`object_key`
            ,date_format(convert_tz(td.created_at, '+00:00', '+08:00'), '%Y-%m-%d')  p_date
            ,row_number() over(partition by td.pno, substring(convert_tz(td.created_at, '+00:00', '+08:00'), 1, 10)  order by convert_tz(td.created_at, '+00:00', '+08:00') desc)  rnk
      FROM `ph_staging`.`ticket_delivery` td
      LEFT JOIN `ph_staging`.`sys_attachment` ss
      on ss.`oss_bucket_key`  = td.`id`
      and ss.`oss_bucket_type`  = 'DELIVERY_PICKUPS_MARK_UPLOAD'
      where
          td.created_at>=convert_tz(DATE_ADD(CURDATE(),interval -60 day) ,'+08:00','+00:00')
    )c
        on T.pno=c.pno and T.p_date=c.p_date
    WHERE
        T.RNK = 1
    and c.rnk=1
    group by 1
) a on sd.pno=a.pno

left join
(
        SELECT
                         pr.tracking_no pno
                        ,date(convert_tz(pr.created_at,'+00:00','+08:00')) p_date
                        ,row_number() over(partition by pr.tracking_no ORDER BY convert_tz(pr.created_at,'+00:00','+08:00') desc) rn
        FROM dwm.`dwd_ph_tiktok_parcel_route_callback_record` pr
        where
                pr.action_code in ('signed_personally','signed_thirdparty','signed_cod','pkg_damaged','pkg_lost','pkg_scrap')
        and pr.created_at>=convert_tz(DATE_ADD(CURDATE(),interval -60 day) ,'+08:00','+00:00')
)cnd
on sd.pno=cnd.pno and cnd.rn=1

left join
(
         select
                pr.pno
                ,count(pr.action_code) as delivery_attempt
                ,max(convert_tz(pr.created_at,'+00:00','+08:00')) last_attempt_failed_time
        from
        (
                select *,ROW_NUMBER() OVER(PARTITION BY pno,date(convert_tz(created_at,'+00:00','+08:00')) ORDER BY created_at desc) rn
                from dwm.`dwd_ph_tiktok_parcel_route_callback_record`
                where
                created_at>=convert_tz(DATE_ADD(CURDATE(),interval -60 day) ,'+08:00','+00:00')
        ) pr
        where
        pr.action_code in('sign_failure','1st_attempt_failed','2nd_attempt_failed','3rd_attempt_failed','multiple_attempt_failed')
        and pr.rn = 1
        group by 1
) prk on sd.pno=prk.pno
where
cnd.pno is null
and pi.state not in(5,7,8,9)
and prk.delivery_attempt >= 3
and prk.last_attempt_failed_time >= date_sub(current_date, interval 1 day)