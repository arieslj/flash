select
    tdm.*
from ph_staging.ticket_delivery_marker tdm
left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
where
    td.staff_info_id = '146865'
    and tdm.created_at > '2023-03-06 16:00:00'
    and tdm.created_at < '2023-03-07 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    tdm.*
    ,td.pno
from ph_staging.ticket_delivery_marker tdm
left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
where
    td.staff_info_id = '146865'
    and tdm.created_at > '2023-03-06 16:00:00'
    and tdm.created_at < '2023-03-07 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    tdm.*
    ,td.pno
from ph_staging.ticket_delivery_marker tdm
left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
where
    td.staff_info_id = '146865'
    and tdm.created_at > '2023-03-07 16:00:00'
    and tdm.created_at < '2023-03-08 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    tdm.*
    ,td.pno
from ph_staging.ticket_delivery_marker tdm
left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
where
    td.staff_info_id = '143836'
    and tdm.created_at > '2023-03-07 16:00:00'
    and tdm.created_at < '2023-03-08 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    tdm.marker_id
    ,td.delivery_at 改约时间
    ,td.pno
    ,convert_tz(tdm.created_at, '+00:00', '+07:00') 标记时间
from ph_staging.ticket_delivery_marker tdm
left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
where
    td.staff_info_id = '143836'
    and tdm.created_at > '2023-03-06 16:00:00'
    and tdm.created_at < '2023-03-07 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    case tdm.marker_id # 标记ID
         when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '无交接文件/交接文件不清晰'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '无包裹/取消寄件'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
        end 标记
    ,td.delivery_at 改约后时间
    ,td.pno
    ,convert_tz(tdm.created_at, '+00:00', '+07:00') 标记时间
from ph_staging.ticket_delivery_marker tdm
left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
where
    td.staff_info_id = '143836'
    and tdm.created_at > '2023-03-06 16:00:00'
    and tdm.created_at < '2023-03-07 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    case tdm.marker_id # 标记ID
         when 1 then '客户不在家/电话无人接听'
         when 2 then '收件人拒收'
         when 3 then '快件分错网点'
         when 4 then '外包装破损'
         when 5 then '货物破损'
         when 6 then '货物短少'
         when 7 then '货物丢失'
         when 8 then '电话联系不上'
         when 9 then '客户改约时间'
         when 10 then '客户不在'
         when 11 then '客户取消任务'
         when 12 then '无人签收'
         when 13 then '客户周末或假期不收货'
         when 14 then '客户改约时间'
         when 15 then '当日运力不足，无法派送'
         when 16 then '联系不上收件人'
         when 17 then '收件人拒收'
         when 18 then '快件分错网点'
         when 19 then '外包装破损'
         when 20 then '货物破损'
         when 21 then '货物短少'
         when 22 then '货物丢失'
         when 23 then '收件人/地址不清晰或不正确'
         when 24 then '收件地址已废弃或不存在'
         when 25 then '收件人电话号码错误'
         when 26 then 'cod金额不正确'
         when 27 then '无实际包裹'
         when 28 then '已妥投未交接'
         when 29 then '收件人电话号码是空号'
         when 30 then '快件分错网点-地址正确'
         when 31 then '快件分错网点-地址错误'
         when 32 then '禁运品'
         when 33 then '严重破损（丢弃）'
         when 34 then '退件两次尝试派送失败'
         when 35 then '不能打开locker'
         when 36 then 'locker不能使用'
         when 37 then '该地址找不到lockerstation'
         when 38 then '一票多件'
         when 39 then '多次尝试派件失败'
         when 40 then '客户不在家/电话无人接听'
         when 41 then '错过班车时间'
         when 42 then '目的地是偏远地区,留仓待次日派送'
         when 43 then '目的地是岛屿,留仓待次日派送'
         when 44 then '企业/机构当天已下班'
         when 45 then '子母件包裹未全部到达网点'
         when 46 then '不可抗力原因留仓(台风)'
         when 47 then '虚假包裹'
         when 50 then '客户取消寄件'
         when 51 then '信息录入错误'
         when 52 then '客户取消寄件'
         when 69 then '禁运品'
         when 70 then '客户改约时间'
         when 71 then '当日运力不足，无法派送'
         when 72 then '客户周末或假期不收货'
         when 73 then '收件人/地址不清晰或不正确'
         when 74 then '收件地址已废弃或不存在'
         when 75 then '收件人电话号码错误'
         when 76 then 'cod金额不正确'
         when 77 then '企业/机构当天已下班'
         when 78 then '收件人电话号码是空号'
         when 79 then '快件分错网点-地址错误'
         when 80 then '客户取消任务'
         when 81 then '重复下单'
         when 82 then '已完成揽件'
         when 83 then '联系不上客户'
         when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 85 then '寄件人电话号码是空号'
         when 86 then '包裹不符合揽收条件超大件'
         when 87 then '包裹不符合揽收条件违禁品'
         when 88 then '寄件人地址为岛屿'
         when 89 then '运力短缺，跟客户协商推迟揽收'
         when 90 then '包裹未准备好推迟揽收'
         when 91 then '包裹包装不符合运输标准'
         when 92 then '无交接文件/交接文件不清晰'
         when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
         when 94 then '无包裹/取消寄件'
         when 95 then '车辆/人力短缺推迟揽收'
         when 96 then '遗漏揽收'
         when 97 then '子母件(一个单号多个包裹)'
         when 98 then '地址错误addresserror'
         when 99 then '包裹不符合揽收条件：超大件'
         when 100 then '包裹不符合揽收条件：违禁品'
         when 101 then '包裹包装不符合运输标准'
         when 102 then '包裹未准备好'
         when 103 then '运力短缺，跟客户协商推迟揽收'
         when 104 then '子母件(一个单号多个包裹)'
         when 105 then '破损包裹'
         when 106 then '空包裹'
         when 107 then '不能打开locker(密码错误)'
         when 108 then 'locker不能使用'
         when 109 then 'locker找不到'
         when 110 then '运单号与实际包裹的单号不一致'
         when 111 then 'box客户取消任务'
         when 112 then '不能打开locker(密码错误)'
         when 113 then 'locker不能使用'
         when 114 then 'locker找不到'
         when 115 then '实际重量尺寸大于客户下单的重量尺寸'
         when 116 then '客户仓库关闭'
         when 117 then '客户仓库关闭'
        end 标记
    ,tdm.desired_at 改约后时间
    ,td.pno
    ,convert_tz(tdm.created_at, '+00:00', '+07:00') 标记时间
from ph_staging.ticket_delivery_marker tdm
left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
where
    td.staff_info_id = '143836'
    and tdm.created_at > '2023-03-06 16:00:00'
    and tdm.created_at < '2023-03-07 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    ce.*
from ph_drds.courier_equipment ce
where
    ce.created_at >= '2023-03-01 00:00:00'
    and ce.created_at < '2023-03-09 00:00:00'
    and ce.staff_info_id in ('146865','143836');
;-- -. . -..- - / . -. - .-. -.--
select ce.*
from ph_drds.courier_equipment ce
where ce.created_at >= '2023-01-01 00:00:00'
  and ce.created_at < '2023-03-09 00:00:00'
  and ce.staff_info_id in ('146865', '143836');
;-- -. . -..- - / . -. - .-. -.--
select *
from ph_staging.customer_group cg
where cg.id = 1;
;-- -. . -..- - / . -. - .-. -.--
select *
from (select pr.pno
           , pr.dst_name
           , CONCAT('`', pr.dst_phone)
           , pr.client_id
           , date (pr.标记时间) 标记日期
   , pr.标记时间
   , case when hour(pr.标记时间)>= 8 and hour(pr.标记时间)<10 then '8点-10点前'
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
    AND tt.rkj=1;
;-- -. . -..- - / . -. - .-. -.--
select
                    pcd.pno
                    ,ss.name
                    ,ss1.name name1
                    ,row_number()over(partition by pcd.pno order by pcd.created_at asc) rank
                from ph_staging.parcel_change_detail pcd
                left join ph_bi.sys_store ss on ss.id=pcd.old_value
                left join ph_bi.sys_store ss1 on ss1.id=pcd.new_value
                where
                    pcd.created_at>=CURRENT_DATE()-interval 30 day
                    and pcd.field_name = 'dst_store_id';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        di.pno
    from ph_staging.diff_info di
    where
        di.created_at < date_sub(curdate(), interval 8 hour)
        and di.created_at >= date_sub(curdate(), interval 32 hour)
        and di.diff_marker_category in (30,31)
    group by 1
)

select
    a.pno
    ,di.num '上报错分次数'
    ,ss.name '妥投网点'
    ,pcd. '初始目的地网点/修改信息网点1'
    ,pcd.'修改后目的地网点1'
    ,pcd.'修改信息网点2'
    ,pcd.'修改后目的地网点2'
    ,pcd.'修改信息网点3'
    ,pcd.'修改后目的地网点3'
    ,pcd.'修改信息网点4'
    ,pcd.'修改后目的地网点4'
    ,pcd.'修改信息网点5'
    ,pcd.'修改后目的地网点5'
    ,pcd.'修改信息网点6'
    ,pcd.'修改后目的地网点6'
    ,pcd.'修改信息网点7'
    ,pcd.'修改后目的地网点7'
    ,ifnull(pcd1.old_value,'未修改邮编') '初始邮编'
    ,a.dst_postal_code '最终邮编'
    ,if(pcd1.old_value is null or pcd1.old_value=pi1.dst_postal_code,'是','否')'初始邮编和最终邮编是否相同'
    ,case
        when a.dst_postal_code<>pcd1.old_value and pcd1.old_value is not null then '客户原因-目的地邮编有误'
        when pcd1.old_value is null then 'HUB错分'
        when pcd1.old_value=a.dst_postal_code and pcd1.old_value is not null then 'flash原因'
    end '责任归属'
    ,ifnull(pcd2.old_value,'未修改详细地址') '初始详细地址'
    ,a.dst_detail_address '最终详细地址'
from ph_staging.parcel_info a
join t on a.pno = t.pno
left join ph_bi.sys_store ss on a.ticket_delivery_store_id=ss.id
left join
    (
        select
            pcd.pno
            ,max(if(pcd.rank=1,pcd.name,null)) '初始目的地网点/修改信息网点1'
            ,max(if(pcd.rank=1,pcd.name1,null)) '修改后目的地网点1'
            ,max(if(pcd.rank=2,pcd.name,null)) '修改信息网点2'
            ,max(if(pcd.rank=2,pcd.name1,null)) '修改后目的地网点2'
            ,max(if(pcd.rank=3,pcd.name,null)) '修改信息网点3'
            ,max(if(pcd.rank=3,pcd.name1,null)) '修改后目的地网点3'
            ,max(if(pcd.rank=4,pcd.name,null)) '修改信息网点4'
            ,max(if(pcd.rank=4,pcd.name1,null)) '修改后目的地网点4'
            ,max(if(pcd.rank=5,pcd.name,null)) '修改信息网点5'
            ,max(if(pcd.rank=5,pcd.name1,null)) '修改后目的地网点5'
            ,max(if(pcd.rank=6,pcd.name,null)) '修改信息网点6'
            ,max(if(pcd.rank=6,pcd.name1,null)) '修改后目的地网点6'
            ,max(if(pcd.rank=7,pcd.name,null)) '修改信息网点7'
            ,max(if(pcd.rank=7,pcd.name1,null)) '修改后目的地网点7'
        from
            (
                select
                    pcd.pno
                    ,ss.name
                    ,ss1.name name1
                    ,row_number()over(partition by pcd.pno order by pcd.created_at) rank
                from ph_staging.parcel_change_detail pcd
                left join ph_bi.sys_store ss on ss.id=pcd.old_value
                left join ph_bi.sys_store ss1 on ss1.id=pcd.new_value
                where
                    pcd.created_at>=CURRENT_DATE()-interval 30 day
                    and pcd.field_name = 'dst_store_id'
            )pcd
        group by 1
    )pcd on pcd.pno = a.pno
left join
    (
        select
            di.pno
            ,count(di.pno) num
        from ph_staging.diff_info di
        where
            di.created_at>=CURRENT_DATE()-interval 30 day
            and di.diff_marker_category in (30,31)
        group by 1
    )di on di.pno=a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at >= CURRENT_DATE()-interval 30 day
            and pcd.field_name = 'dst_postal_code'
    )pcd1 on a.pno=pcd1.pno and pcd1.rank = 1
left join
    (
        select
            pi.pno
            ,pi.dst_postal_code
            ,pi.dst_detail_address
        from ph_staging.parcel_info pi
        where
            pi.created_at >= CURRENT_DATE()-interval 40 day
    )pi1 on pi1.pno=a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at )rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name = 'dst_detail_address'
    )pcd2 on a.pno=pcd2.pno and pcd2.rank=  1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,di.num '上报错分次数'
    ,ss.name '妥投网点'
    ,pcd. '初始目的地网点/修改信息网点1'
    ,pcd.'修改后目的地网点1'
    ,pcd.'修改信息网点2'
    ,pcd.'修改后目的地网点2'
    ,pcd.'修改信息网点3'
    ,pcd.'修改后目的地网点3'
    ,pcd.'修改信息网点4'
    ,pcd.'修改后目的地网点4'
    ,pcd.'修改信息网点5'
    ,pcd.'修改后目的地网点5'
    ,pcd.'修改信息网点6'
    ,pcd.'修改后目的地网点6'
    ,pcd.'修改信息网点7'
    ,pcd.'修改后目的地网点7'
    ,ifnull(pcd1.old_value,'未修改邮编') '初始邮编'
    ,a.dst_postal_code '最终邮编'
    ,if(pcd1.old_value is null or pcd1.old_value=pi1.dst_postal_code,'是','否')'初始邮编和最终邮编是否相同'
    ,case when a.dst_postal_code<>pcd1.old_value and pcd1.old_value is not null then '客户原因-目的地邮编有误'
    when pcd1.old_value is null then 'HUB错分'
    when pcd1.old_value=a.dst_postal_code and pcd1.old_value is not null then 'flash原因'
    end '责任归属'
    ,ifnull(pcd2.old_value,'未修改详细地址') '初始详细地址'
    ,a.dst_detail_address '最终详细地址'
from
    (
        select
            distinct
            dd.pno
        from ph_staging.diff_info dd
        where
            dd.created_at>='2023-03-01'
            and dd.diff_marker_category='31'
    )dd
join ph_staging.parcel_info a on dd.pno = a.pno
left join ph_bi.sys_store ss on a.ticket_delivery_store_id = ss.id
left join
    (
        select
            pcd.pno
            ,max(if(pcd.rank=1,pcd.name,null)) '初始目的地网点/修改信息网点1'
            ,max(if(pcd.rank=1,pcd.name1,null)) '修改后目的地网点1'
            ,max(if(pcd.rank=2,pcd.name,null)) '修改信息网点2'
            ,max(if(pcd.rank=2,pcd.name1,null)) '修改后目的地网点2'
            ,max(if(pcd.rank=3,pcd.name,null)) '修改信息网点3'
            ,max(if(pcd.rank=3,pcd.name1,null)) '修改后目的地网点3'
            ,max(if(pcd.rank=4,pcd.name,null)) '修改信息网点4'
            ,max(if(pcd.rank=4,pcd.name1,null)) '修改后目的地网点4'
            ,max(if(pcd.rank=5,pcd.name,null)) '修改信息网点5'
            ,max(if(pcd.rank=5,pcd.name1,null)) '修改后目的地网点5'
            ,max(if(pcd.rank=6,pcd.name,null)) '修改信息网点6'
            ,max(if(pcd.rank=6,pcd.name1,null)) '修改后目的地网点6'
            ,max(if(pcd.rank=7,pcd.name,null)) '修改信息网点7'
            ,max(if(pcd.rank=7,pcd.name1,null)) '修改后目的地网点7'
        from
            (
                select
                    pcd.pno
                    ,ss.name
                    ,ss1.name name1
                    ,row_number()over(partition by pcd.pno order by pcd.created_at asc) rank
                from ph_staging.parcel_change_detail pcd
                left join ph_bi.sys_store ss on ss.id=pcd.old_value
                left join ph_bi.sys_store ss1 on ss1.id=pcd.new_value
                where
                    pcd.created_at>=CURRENT_DATE()-interval 30 day
                    and pcd.field_name='dst_store_id'
            )pcd
        group by 1
    )pcd on pcd.pno = a.pno
left join
    (
        select
            di.pno
            ,count(di.pno) num
        from ph_staging.diff_info di
        where
            di.created_at>=CURRENT_DATE()-interval 30 day
            and di.diff_marker_category in (30,31)
        group by 1
    )di on di.pno=a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_postal_code'
    )pcd1 on a.pno=pcd1.pno and pcd1.rank = 1
left join
    (
        select
            pi.pno
            ,pi.dst_postal_code
            ,pi.dst_detail_address
        from ph_staging.parcel_info pi
        where
            pi.created_at>=CURRENT_DATE()-interval 40 day
    )pi1 on pi1.pno = a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_detail_address'
    )pcd2 on a.pno=pcd2.pno and pcd2.rank = 1
where
    pcd1.old_value=a.dst_postal_code and pcd1.old_value is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,di.num '上报错分次数'
    ,ss.name '妥投网点'
    ,pcd. '初始目的地网点/修改信息网点1'
    ,pcd.'修改后目的地网点1'
    ,pcd.'修改信息网点2'
    ,pcd.'修改后目的地网点2'
    ,pcd.'修改信息网点3'
    ,pcd.'修改后目的地网点3'
    ,pcd.'修改信息网点4'
    ,pcd.'修改后目的地网点4'
    ,pcd.'修改信息网点5'
    ,pcd.'修改后目的地网点5'
    ,pcd.'修改信息网点6'
    ,pcd.'修改后目的地网点6'
    ,pcd.'修改信息网点7'
    ,pcd.'修改后目的地网点7'
    ,ifnull(pcd1.old_value,'未修改邮编') '初始邮编'
    ,a.dst_postal_code '最终邮编'
    ,if(pcd1.old_value is null or pcd1.old_value=pi1.dst_postal_code,'是','否')'初始邮编和最终邮编是否相同'
    ,case when a.dst_postal_code<>pcd1.old_value and pcd1.old_value is not null then '客户原因-目的地邮编有误'
    when pcd1.old_value is null then 'HUB错分'
    when pcd1.old_value=a.dst_postal_code and pcd1.old_value is not null then 'flash原因'
    end '责任归属'
    ,ifnull(pcd2.old_value,'未修改详细地址') '初始详细地址'
    ,a.dst_detail_address '最终详细地址'
from
    (
        select
            distinct
            dd.pno
        from ph_staging.diff_info dd
        where
            dd.created_at>='2023-03-01'
            and dd.diff_marker_category='31'
    )dd
join ph_staging.parcel_info a on dd.pno = a.pno
left join ph_bi.sys_store ss on a.ticket_delivery_store_id = ss.id
left join
    (
        select
            pcd.pno
            ,max(if(pcd.rank=1,pcd.name,null)) '初始目的地网点/修改信息网点1'
            ,max(if(pcd.rank=1,pcd.name1,null)) '修改后目的地网点1'
            ,max(if(pcd.rank=2,pcd.name,null)) '修改信息网点2'
            ,max(if(pcd.rank=2,pcd.name1,null)) '修改后目的地网点2'
            ,max(if(pcd.rank=3,pcd.name,null)) '修改信息网点3'
            ,max(if(pcd.rank=3,pcd.name1,null)) '修改后目的地网点3'
            ,max(if(pcd.rank=4,pcd.name,null)) '修改信息网点4'
            ,max(if(pcd.rank=4,pcd.name1,null)) '修改后目的地网点4'
            ,max(if(pcd.rank=5,pcd.name,null)) '修改信息网点5'
            ,max(if(pcd.rank=5,pcd.name1,null)) '修改后目的地网点5'
            ,max(if(pcd.rank=6,pcd.name,null)) '修改信息网点6'
            ,max(if(pcd.rank=6,pcd.name1,null)) '修改后目的地网点6'
            ,max(if(pcd.rank=7,pcd.name,null)) '修改信息网点7'
            ,max(if(pcd.rank=7,pcd.name1,null)) '修改后目的地网点7'
        from
            (
                select
                    pcd.pno
                    ,ss.name
                    ,ss1.name name1
                    ,row_number()over(partition by pcd.pno order by pcd.created_at asc) rank
                from ph_staging.parcel_change_detail pcd
                left join ph_bi.sys_store ss on ss.id=pcd.old_value
                left join ph_bi.sys_store ss1 on ss1.id=pcd.new_value
                where
                    pcd.created_at>=CURRENT_DATE()-interval 30 day
                    and pcd.field_name='dst_store_id'
            )pcd
        group by 1
    )pcd on pcd.pno = a.pno
left join
    (
        select
            di.pno
            ,count(di.pno) num
        from ph_staging.diff_info di
        where
            di.created_at>=CURRENT_DATE()-interval 30 day
            and di.diff_marker_category in (30,31)
        group by 1
    )di on di.pno=a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_postal_code'
    )pcd1 on a.pno=pcd1.pno and pcd1.rank = 1
left join
    (
        select
            pi.pno
            ,pi.dst_postal_code
            ,pi.dst_detail_address
        from ph_staging.parcel_info pi
        where
            pi.created_at>=CURRENT_DATE()-interval 40 day
    )pi1 on pi1.pno = a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_detail_address'
    )pcd2 on a.pno=pcd2.pno and pcd2.rank = 1
where
    a.ticket_delivery_store_id =pcd.`初始目的地网点/修改信息网点1`;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,di.num '上报错分次数'
    ,ss.name '妥投网点'
    ,pcd. '初始目的地网点/修改信息网点1'
    ,pcd.'修改后目的地网点1'
    ,pcd.'修改信息网点2'
    ,pcd.'修改后目的地网点2'
    ,pcd.'修改信息网点3'
    ,pcd.'修改后目的地网点3'
    ,pcd.'修改信息网点4'
    ,pcd.'修改后目的地网点4'
    ,pcd.'修改信息网点5'
    ,pcd.'修改后目的地网点5'
    ,pcd.'修改信息网点6'
    ,pcd.'修改后目的地网点6'
    ,pcd.'修改信息网点7'
    ,pcd.'修改后目的地网点7'
    ,ifnull(pcd1.old_value,'未修改邮编') '初始邮编'
    ,a.dst_postal_code '最终邮编'
    ,if(pcd1.old_value is null or pcd1.old_value=pi1.dst_postal_code,'是','否')'初始邮编和最终邮编是否相同'
    ,case when a.dst_postal_code<>pcd1.old_value and pcd1.old_value is not null then '客户原因-目的地邮编有误'
    when pcd1.old_value is null then 'HUB错分'
    when pcd1.old_value=a.dst_postal_code and pcd1.old_value is not null then 'flash原因'
    end '责任归属'
    ,ifnull(pcd2.old_value,'未修改详细地址') '初始详细地址'
    ,a.dst_detail_address '最终详细地址'
from
    (
        select
            distinct
            dd.pno
        from ph_staging.diff_info dd
        where
            dd.created_at>='2023-03-01'
            and dd.diff_marker_category='31'
    )dd
join ph_staging.parcel_info a on dd.pno = a.pno
left join ph_bi.sys_store ss on a.ticket_delivery_store_id = ss.id
left join
    (
        select
            pcd.pno
            ,max(if(pcd.rank=1,pcd.name,null)) '初始目的地网点/修改信息网点1'
            ,max(if(pcd.rank=1,pcd.name1,null)) '修改后目的地网点1'
            ,max(if(pcd.rank=2,pcd.name,null)) '修改信息网点2'
            ,max(if(pcd.rank=2,pcd.name1,null)) '修改后目的地网点2'
            ,max(if(pcd.rank=3,pcd.name,null)) '修改信息网点3'
            ,max(if(pcd.rank=3,pcd.name1,null)) '修改后目的地网点3'
            ,max(if(pcd.rank=4,pcd.name,null)) '修改信息网点4'
            ,max(if(pcd.rank=4,pcd.name1,null)) '修改后目的地网点4'
            ,max(if(pcd.rank=5,pcd.name,null)) '修改信息网点5'
            ,max(if(pcd.rank=5,pcd.name1,null)) '修改后目的地网点5'
            ,max(if(pcd.rank=6,pcd.name,null)) '修改信息网点6'
            ,max(if(pcd.rank=6,pcd.name1,null)) '修改后目的地网点6'
            ,max(if(pcd.rank=7,pcd.name,null)) '修改信息网点7'
            ,max(if(pcd.rank=7,pcd.name1,null)) '修改后目的地网点7'
        from
            (
                select
                    pcd.pno
                    ,ss.name
                    ,ss1.name name1
                    ,row_number()over(partition by pcd.pno order by pcd.created_at asc) rank
                from ph_staging.parcel_change_detail pcd
                left join ph_bi.sys_store ss on ss.id=pcd.old_value
                left join ph_bi.sys_store ss1 on ss1.id=pcd.new_value
                where
                    pcd.created_at>=CURRENT_DATE()-interval 30 day
                    and pcd.field_name='dst_store_id'
            )pcd
        group by 1
    )pcd on pcd.pno = a.pno
left join
    (
        select
            di.pno
            ,count(di.pno) num
        from ph_staging.diff_info di
        where
            di.created_at>=CURRENT_DATE()-interval 30 day
            and di.diff_marker_category in (30,31)
        group by 1
    )di on di.pno=a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_postal_code'
    )pcd1 on a.pno=pcd1.pno and pcd1.rank = 1
left join
    (
        select
            pi.pno
            ,pi.dst_postal_code
            ,pi.dst_detail_address
        from ph_staging.parcel_info pi
        where
            pi.created_at>=CURRENT_DATE()-interval 40 day
    )pi1 on pi1.pno = a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_detail_address'
    )pcd2 on a.pno=pcd2.pno and pcd2.rank = 1
where
    ss.name =pcd.`初始目的地网点/修改信息网点1`;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,di.num '上报错分次数'
    ,ss.name '妥投网点'
    ,pcd. '初始目的地网点/修改信息网点1'
    ,pcd.'修改后目的地网点1' 第一次修改后网点
    ,pcd.'修改信息网点2' 第2次修改前网点
    ,pcd.'修改后目的地网点2' 第2次修改后网点
    ,pcd.'修改信息网点3' 第3次修改前网点
    ,pcd.'修改后目的地网点3' 第3次修改后网点
    ,pcd.'修改信息网点4' 第4次修改前网点
    ,pcd.'修改后目的地网点4' 第4次修改后网点
    ,pcd.'修改信息网点5' 第5次修改前网点
    ,pcd.'修改后目的地网点5' 第5次修改后网点
    ,pcd.'修改信息网点6' 第6次修改前网点
    ,pcd.'修改后目的地网点6' 第6次修改后网点
    ,pcd.'修改信息网点7' 第7次修改前网点
    ,pcd.'修改后目的地网点7' 第7次修改后网点
    ,ifnull(pcd1.old_value,'未修改邮编') '初始邮编'
    ,a.dst_postal_code '最终邮编'
    ,if(pcd1.old_value is null or pcd1.old_value=pi1.dst_postal_code,'是','否')'初始邮编和最终邮编是否相同'
    ,case when a.dst_postal_code<>pcd1.old_value and pcd1.old_value is not null then '客户原因-目的地邮编有误'
    when pcd1.old_value is null then 'HUB错分'
    when pcd1.old_value=a.dst_postal_code and pcd1.old_value is not null then 'flash原因'
    end '责任归属'
    ,ifnull(pcd2.old_value,'未修改详细地址') '初始详细地址'
    ,a.dst_detail_address '最终详细地址'
from
    (
        select
            distinct
            dd.pno
        from ph_staging.diff_info dd
        where
            dd.created_at>='2023-03-01'
            and dd.diff_marker_category='31'
    )dd
join ph_staging.parcel_info a on dd.pno = a.pno
left join ph_bi.sys_store ss on a.ticket_delivery_store_id = ss.id
left join
    (
        select
            pcd.pno
            ,max(if(pcd.rank=1,pcd.name,null)) '初始目的地网点/修改信息网点1'
            ,max(if(pcd.rank=1,pcd.name1,null)) '修改后目的地网点1'
            ,max(if(pcd.rank=2,pcd.name,null)) '修改信息网点2'
            ,max(if(pcd.rank=2,pcd.name1,null)) '修改后目的地网点2'
            ,max(if(pcd.rank=3,pcd.name,null)) '修改信息网点3'
            ,max(if(pcd.rank=3,pcd.name1,null)) '修改后目的地网点3'
            ,max(if(pcd.rank=4,pcd.name,null)) '修改信息网点4'
            ,max(if(pcd.rank=4,pcd.name1,null)) '修改后目的地网点4'
            ,max(if(pcd.rank=5,pcd.name,null)) '修改信息网点5'
            ,max(if(pcd.rank=5,pcd.name1,null)) '修改后目的地网点5'
            ,max(if(pcd.rank=6,pcd.name,null)) '修改信息网点6'
            ,max(if(pcd.rank=6,pcd.name1,null)) '修改后目的地网点6'
            ,max(if(pcd.rank=7,pcd.name,null)) '修改信息网点7'
            ,max(if(pcd.rank=7,pcd.name1,null)) '修改后目的地网点7'
        from
            (
                select
                    pcd.pno
                    ,ss.name
                    ,ss1.name name1
                    ,row_number()over(partition by pcd.pno order by pcd.created_at asc) rank
                from ph_staging.parcel_change_detail pcd
                left join ph_bi.sys_store ss on ss.id=pcd.old_value
                left join ph_bi.sys_store ss1 on ss1.id=pcd.new_value
                where
                    pcd.created_at>=CURRENT_DATE()-interval 30 day
                    and pcd.field_name='dst_store_id'
            )pcd
        group by 1
    )pcd on pcd.pno = a.pno
left join
    (
        select
            di.pno
            ,count(di.pno) num
        from ph_staging.diff_info di
        where
            di.created_at>=CURRENT_DATE()-interval 30 day
            and di.diff_marker_category in (30,31)
        group by 1
    )di on di.pno=a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_postal_code'
    )pcd1 on a.pno=pcd1.pno and pcd1.rank = 1
left join
    (
        select
            pi.pno
            ,pi.dst_postal_code
            ,pi.dst_detail_address
        from ph_staging.parcel_info pi
        where
            pi.created_at>=CURRENT_DATE()-interval 40 day
    )pi1 on pi1.pno = a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_detail_address'
    )pcd2 on a.pno=pcd2.pno and pcd2.rank = 1
where
    ss.name =pcd.`初始目的地网点/修改信息网点1`;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,di.num '上报错分次数'
    ,ss.name '妥投网点'
    ,pcd. '初始目的地网点/修改信息网点1'
    ,pcd.'修改后目的地网点1' 第一次修改后网点
    ,pcd.'修改信息网点2' 第2次修改前网点
    ,pcd.'修改后目的地网点2' 第2次修改后网点
    ,pcd.'修改信息网点3' 第3次修改前网点
    ,pcd.'修改后目的地网点3' 第3次修改后网点
    ,pcd.'修改信息网点4' 第4次修改前网点
    ,pcd.'修改后目的地网点4' 第4次修改后网点
    ,pcd.'修改信息网点5' 第5次修改前网点
    ,pcd.'修改后目的地网点5' 第5次修改后网点
    ,pcd.'修改信息网点6' 第6次修改前网点
    ,pcd.'修改后目的地网点6' 第6次修改后网点
    ,pcd.'修改信息网点7' 第7次修改前网点
    ,pcd.'修改后目的地网点7' 第7次修改后网点
    ,ifnull(pcd1.old_value,'未修改邮编') '初始邮编'
    ,a.dst_postal_code '最终邮编'
#     ,if(pcd1.old_value is null or pcd1.old_value=pi1.dst_postal_code,'是','否')'初始邮编和最终邮编是否相同'
#     ,case when a.dst_postal_code<>pcd1.old_value and pcd1.old_value is not null then '客户原因-目的地邮编有误'
#     when pcd1.old_value is null then 'HUB错分'
#     when pcd1.old_value=a.dst_postal_code and pcd1.old_value is not null then 'flash原因'
#     end '责任归属'
    ,ifnull(pcd2.old_value,'未修改详细地址') '初始详细地址'
    ,a.dst_detail_address '最终详细地址'
from
    (
        select
            distinct
            dd.pno
        from ph_staging.diff_info dd
        where
            dd.created_at>='2023-03-01'
            and dd.diff_marker_category='31'
    )dd
join ph_staging.parcel_info a on dd.pno = a.pno
left join ph_bi.sys_store ss on a.ticket_delivery_store_id = ss.id
left join
    (
        select
            pcd.pno
            ,max(if(pcd.rank=1,pcd.name,null)) '初始目的地网点/修改信息网点1'
            ,max(if(pcd.rank=1,pcd.name1,null)) '修改后目的地网点1'
            ,max(if(pcd.rank=2,pcd.name,null)) '修改信息网点2'
            ,max(if(pcd.rank=2,pcd.name1,null)) '修改后目的地网点2'
            ,max(if(pcd.rank=3,pcd.name,null)) '修改信息网点3'
            ,max(if(pcd.rank=3,pcd.name1,null)) '修改后目的地网点3'
            ,max(if(pcd.rank=4,pcd.name,null)) '修改信息网点4'
            ,max(if(pcd.rank=4,pcd.name1,null)) '修改后目的地网点4'
            ,max(if(pcd.rank=5,pcd.name,null)) '修改信息网点5'
            ,max(if(pcd.rank=5,pcd.name1,null)) '修改后目的地网点5'
            ,max(if(pcd.rank=6,pcd.name,null)) '修改信息网点6'
            ,max(if(pcd.rank=6,pcd.name1,null)) '修改后目的地网点6'
            ,max(if(pcd.rank=7,pcd.name,null)) '修改信息网点7'
            ,max(if(pcd.rank=7,pcd.name1,null)) '修改后目的地网点7'
        from
            (
                select
                    pcd.pno
                    ,ss.name
                    ,ss1.name name1
                    ,row_number()over(partition by pcd.pno order by pcd.created_at asc) rank
                from ph_staging.parcel_change_detail pcd
                left join ph_bi.sys_store ss on ss.id=pcd.old_value
                left join ph_bi.sys_store ss1 on ss1.id=pcd.new_value
                where
                    pcd.created_at>=CURRENT_DATE()-interval 30 day
                    and pcd.field_name='dst_store_id'
            )pcd
        group by 1
    )pcd on pcd.pno = a.pno
left join
    (
        select
            di.pno
            ,count(di.pno) num
        from ph_staging.diff_info di
        where
            di.created_at>=CURRENT_DATE()-interval 30 day
            and di.diff_marker_category in (30,31)
        group by 1
    )di on di.pno=a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_postal_code'
    )pcd1 on a.pno=pcd1.pno and pcd1.rank = 1
left join
    (
        select
            pi.pno
            ,pi.dst_postal_code
            ,pi.dst_detail_address
        from ph_staging.parcel_info pi
        where
            pi.created_at>=CURRENT_DATE()-interval 40 day
    )pi1 on pi1.pno = a.pno
left join
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number()over(partition by pcd.pno order by pcd.created_at asc)rank
        from ph_staging.parcel_change_detail pcd
        where
            pcd.created_at>=CURRENT_DATE()-interval 30 day
            and pcd.field_name='dst_detail_address'
    )pcd2 on a.pno=pcd2.pno and pcd2.rank = 1
where
    ss.name =pcd.`初始目的地网点/修改信息网点1`;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
)
select
    t.ss_name 网点
    ,t.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
from t
left join
    ( -- 交接数
        select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
        group by 1,2
    ) scan on scan.staff_info_id = t.staff_info_id
left join
    (
        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
        group by 1,2
    ) fin on fin.staff_info_id = t.staff_info_id
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
            and pr.staff_info_id = '136400'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
#         join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
            and pr.staff_info_id = '136400'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
        and hsi.staff_info_id = '136400'
)
select
    t.ss_name 网点
    ,t.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
from t
left join
    ( -- 交接数
        select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2
    ) scan on scan.staff_info_id = t.staff_info_id
left join
    (
        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
        group by 1,2
    ) fin on fin.staff_info_id = t.staff_info_id
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
        and hsi.staff_info_id = '136400'
)
select
    t.ss_name 网点
    ,t.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,count(distinct scan.date_d)
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
from t
left join
    ( -- 交接数
        select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2
    ) scan on scan.staff_info_id = t.staff_info_id
left join
    (
        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
        group by 1,2
    ) fin on fin.staff_info_id = t.staff_info_id
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
        and hsi.staff_info_id = '136400'
)
select
    t.ss_name 网点
    ,t.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,count(distinct scan.date_d)
    ,sum(scan.num)
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
from t
left join
    ( -- 交接数
        select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2
    ) scan on scan.staff_info_id = t.staff_info_id
left join
    (
        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
        group by 1,2
    ) fin on fin.staff_info_id = t.staff_info_id
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
        and hsi.staff_info_id = '136400'
);
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
        and hsi.staff_info_id = '136400';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
        and hsi.staff_info_id = '136400'
)
, total as
(
    select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,'scan' type
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2

        union all

        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,'fin' type
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
        group by 1,2
)
select
    t.ss_name 网点
    ,t.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
from
    (
        select
            total.staff_info_id
            ,total.date_d
        from total
        group by 1,2
    ) t
left join total scan on scan.staff_info_id = t.staff_info_id and scan.date_d = t.date_d and scan.type = 'scan'
left join total fin on fin.staff_info_id = t.staff_info_id and fin.date_d = t.date_d and fin.type = 'fin'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
        and hsi.staff_info_id = '136400'
)
, total as
(
    select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,'scan' type
            ,t.ss_name
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2,3,4

        union all

        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,'fin' type
            ,t.ss_name
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
        group by 1,2,3,4
)
select
    t.ss_name 网点
    ,t.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
from
    (
        select
            total.staff_info_id
            ,total.date_d
            ,total.ss_name
        from total
        group by 1,2,3
    ) t
left join total scan on scan.staff_info_id = t.staff_info_id and scan.date_d = t.date_d and scan.type = 'scan'
left join total fin on fin.staff_info_id = t.staff_info_id and fin.date_d = t.date_d and fin.type = 'fin'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
#         and hsi.staff_info_id = '136400'
)
, total as
(
    select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,'scan' type
            ,t.ss_name
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2,3,4

        union all

        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,'fin' type
            ,t.ss_name
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 25 day), interval 8 hour)
        group by 1,2,3,4
)
select
    t.ss_name 网点
    ,t.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
from
    (
        select
            total.staff_info_id
            ,total.date_d
            ,total.ss_name
        from total
        group by 1,2,3
    ) t
left join total scan on scan.staff_info_id = t.staff_info_id and scan.date_d = t.date_d and scan.type = 'scan'
left join total fin on fin.staff_info_id = t.staff_info_id and fin.date_d = t.date_d and fin.type = 'fin'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
#         and hsi.staff_info_id = '136400'
)
, total as
(
    select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,'scan' type
            ,t.ss_name
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pr.route_at < date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2,3,4

        union all

        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,'fin' type
            ,t.ss_name
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pi.finished_at <
        group by 1,2,3,4
)
select
    t.ss_name 网点
    ,t.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,count(distinct scan.date_d) 近30天交接天数
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
    ,count(distinct fin.date_d) 近30天妥投天数
from
    (
        select
            total.staff_info_id
            ,total.date_d
            ,total.ss_name
        from total
        group by 1,2,3
    ) t
left join total scan on scan.staff_info_id = t.staff_info_id and scan.date_d = t.date_d and scan.type = 'scan'
left join total fin on fin.staff_info_id = t.staff_info_id and fin.date_d = t.date_d and fin.type = 'fin'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
#         and hsi.staff_info_id = '136400'
)
, total as
(
    select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,'scan' type
            ,t.ss_name
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pr.route_at < date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2,3,4

        union all

        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,'fin' type
            ,t.ss_name
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pi.finished_at < date_sub(curdate(), interval 8 hour)
        group by 1,2,3,4
)
select
    t.ss_name 网点
    ,t.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,count(distinct scan.date_d) 近30天交接天数
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
    ,count(distinct fin.date_d) 近30天妥投天数
from
    (
        select
            total.staff_info_id
            ,total.date_d
            ,total.ss_name
        from total
        group by 1,2,3
    ) t
left join total scan on scan.staff_info_id = t.staff_info_id and scan.date_d = t.date_d and scan.type = 'scan'
left join total fin on fin.staff_info_id = t.staff_info_id and fin.date_d = t.date_d and fin.type = 'fin'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
#         and hsi.staff_info_id = '136400'
)
, total as
(
    select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,'scan' type
            ,t.ss_name
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2,3,4

        union all

        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,'fin' type
            ,t.ss_name
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pi.finished_at < date_sub(curdate(), interval 8 hour)
        group by 1,2,3,4
)
select
    t.ss_name 网点
    ,t.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,count(distinct scan.date_d) 近30天交接天数
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
    ,count(distinct fin.date_d) 近30天妥投天数
from
    (
        select
            total.staff_info_id
            ,total.date_d
            ,total.ss_name
        from total
        group by 1,2,3
    ) t
left join total scan on scan.staff_info_id = t.staff_info_id and scan.date_d = t.date_d and scan.type = 'scan'
left join total fin on fin.staff_info_id = t.staff_info_id and fin.date_d = t.date_d and fin.type = 'fin'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
#         and hsi.staff_info_id = '136400'
)
, total as
(
    select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,'scan' type
            ,t.ss_name
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2,3,4

        union all

        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,'fin' type
            ,t.ss_name
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pi.finished_at < date_sub(curdate(), interval 8 hour)
        group by 1,2,3,4
)
select
    a.ss_name 网点
    ,a.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,count(distinct scan.date_d) 近30天交接天数
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
    ,count(distinct fin.date_d) 近30天妥投天数
from t a
left join
    (
        select
            total.staff_info_id
            ,total.date_d
            ,total.ss_name
        from total
        group by 1,2,3
    ) t on t.staff_info_id = a.staff_info_id and t.ss_name = a.ss_name
left join total scan on scan.staff_info_id = t.staff_info_id and scan.date_d = t.date_d and scan.type = 'scan'
left join total fin on fin.staff_info_id = t.staff_info_id and fin.date_d = t.date_d and fin.type = 'fin'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
#         and hsi.staff_info_id = '136400'
)
, total as
(
    select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,'scan' type
            ,t.ss_name
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2,3,4

        union all

        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,'fin' type
            ,t.ss_name
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pi.finished_at < date_sub(curdate(), interval 8 hour)
        group by 1,2,3,4
)
select
    *
from total;
;-- -. . -..- - / . -. - .-. -.--
select
    hsi.staff_info_id
    ,hsi.hire_date
from ph_bi.hr_staff_info hsi
where
    hsi.staff_info_id in ('119999', '121776', '125595', '127320', '144914', '126471', '129577', '143552', '128544', '130629', '139340', '142684', '121517', '124245', '122849', '147026', '129478', '139564', '138995', '132638', '142468', '142398', '121959', '147204', '140513', '141731', '119363', '143365', '146200', '131902', '146662', '136717', '141425', '147700', '123315', '143644', '146887', '146301', '146973', '147313', '132704', '119263', '129450', '143836', '138168', '126277', '126820', '132318', '127738', '143159', '142878', '120650', '142461', '145659', '137498', '137552', '138000', '123831', '138684', '146078', '147338', '136411', '138850', '148502', '147271', '121614', '137223', '141200', '144392', '146816', '147626', '146985', '147117', '145885', '147910', '126985', '138674', '145092', '147716', '141582', '143109', '144085', '146844', '120671', '132576', '131210', '141791', '145706', '146910', '148060', '148693', '143813', '144606', '144713', '147202', '121549', '136363', '141386', '141151', '143837', '145412', '146858', '135396', '136414', '136979', '146185', '141935', '146629', '135674', '124103', '137645', '141549', '146865', '133938', '139445', '142106', '142674', '145900', '137230', '145800', '146031', '147246', '121500', '124751', '139759', '144557', '145803', '146810', '146970', '147001', '144886', '146472', '123868', '143519', '146076', '146737', '147083', '148413', '133321', '138572', '139911', '143055', '143674', '147333', '147929', '120718', '128919', '147316', '147780', '147828', '148073');
;-- -. . -..- - / . -. - .-. -.--
select
    *
from ph_staging.parcel_headless ph
where
    ph.created_at >= '2021-12-31 16:00:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    *
from ph_staging.parcel_headless ph
where
    ph.created_at >= '2021-12-31 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,ss.name
from tmpale.tmpale.tmp_th_1_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,ss.name
from tmpale.tmp_ph_1_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    *
    ,ss.name
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,ss.name
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,t.month_d 月份
    ,sum(t.count_num)/count(distinct t.staff_info) 网点平均访问次数
    ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 2
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,t.month_d 月份
    ,sum(t.count_num) 总访问次数
    ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
    ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
#     ,sum(t.count_num)/count(distinct t.staff_info) 网点平均访问次数
#     ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
    and ss.category in (8,12)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,t.month_d 月份
    ,sum(t.count_num) 总访问次数
    ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
    ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
#     ,sum(t.count_num)/count(distinct t.staff_info) 网点平均访问次数
#     ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
#     and ss.category in (8,12)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
    ,sum(t.count_num) 总访问次数
    ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
    ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
#     ,sum(t.count_num)/count(distinct t.staff_info) 网点平均访问次数
#     ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
#     and ss.category in (8,12)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
#     ,sum(t.count_num) 总访问次数
#     ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
#     ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
     ,ss.name
    ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数
    ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
    and ss.category in (8,12)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,ss.name
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
    and ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,ss.name
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,ss.name
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa';
;-- -. . -..- - / . -. - .-. -.--
select
    t.staff_info
    ,t.month_d
    ,ss.name
    ,sum(t.count_num)
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.staff_info
    ,t.month_d
    ,ss.name
    ,sum(t.count_num)
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa'
    and t.count_num > 2
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
#     ,sum(t.count_num) 总访问次数
#     ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
#     ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
     ,ss.name
    ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数
    ,sum(t.count_num) 总访问
    ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
    and ss.category in (8,12)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.staff_info
    ,t.month_d
    ,ss.name
    ,sum(t.count_num)
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa'
    and t.count_num > 2
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.总访问_认领
    ,b.网点每人平均访问次数_认领
    ,b.访问员工数_认领
from
    (
        select
            t.month_d
            ,ss.name
            ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数_hub
            ,sum(t.count_num) 总访问_hub
            ,count(distinct t.staff_info) 访问员工数_hub
        from tmpale.tmp_ph_hub_0318 t
        left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
        left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
            and ss.name = '11 PN5-HUB_Santa Rosa'
            and t.count_num > 2
        group by 1,2
    ) a
left join
    (
         select
            t.month_d
            ,ss.name
            ,sum(t._col1)/count(distinct t._col1) 网点每人平均访问次数_认领
            ,sum(t._col1) 总访问_认领
            ,count(distinct t.c_sid_ms) 访问员工数_认领
        from tmpale.tmp_ph_renlin_0318  t
        left join ph_bi.hr_staff_info hsi on t.c_sid_ms = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
        left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
            and ss.name = '11 PN5-HUB_Santa Rosa'
            and t._col1 > 2
        group by 1,2
    )  b on a.month_d = b.month_d and a.name = b.name;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
    ,ss.name 网点
    ,t.staff_info
    ,t.count_num 次数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 10;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
    ,ss.name 网点
    ,t.staff_info
    ,t.count_num 次数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 10
    and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
    ,ss.name 网点
    ,t.c_sid_ms
    ,t._col1 次数
from tmpale.tmp_ph_renlin_0318 t
left join ph_bi.hr_staff_info hsi on t.c_sid_ms = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t._col1 > 10
    and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.总访问_认领
    ,b.网点每人平均访问次数_认领
    ,b.访问员工数_认领
from
    (
        select
            t.month_d
            ,ss.name
            ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数_hub
            ,sum(t.count_num) 总访问_hub
            ,count(distinct t.staff_info) 访问员工数_hub
        from tmpale.tmp_ph_hub_0318 t
        left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
#         left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
#             and ss.name = '11 PN5-HUB_Santa Rosa'
            and t.count_num > 2
        group by 1,2
    ) a
left join
    (
         select
            t.month_d
            ,ss.name
            ,sum(t._col1)/count(distinct t._col1) 网点每人平均访问次数_认领
            ,sum(t._col1) 总访问_认领
            ,count(distinct t.c_sid_ms) 访问员工数_认领
        from tmpale.tmp_ph_renlin_0318  t
        left join ph_bi.hr_staff_info hsi on t.c_sid_ms = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
#         left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
#             and ss.name = '11 PN5-HUB_Santa Rosa'
            and t._col1 > 2
        group by 1,2
    )  b on a.month_d = b.month_d and a.name = b.name;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,case pi.returned
        when 0 then '正向'
        when 1 then '逆向'
    end 包裹类型
    ,pr.route_action
    ,plt.staff
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0321 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on t.pno = pr.pno
        where  -- 最后有效路由
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = pi.pno and pr.rn = 1
left join
    (
        select
            plt.pno
            ,group_concat(plr.staff_id) staff
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        group by 1
    ) plt on plt.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,case pi.returned
        when 0 then '正向'
        when 1 then '逆向'
    end 包裹类型
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一条有效路由
    ,plt.staff
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0321 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on t.pno = pr.pno
        where  -- 最后有效路由
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = pi.pno and pr.rn = 1
left join
    (
        select
            plt.pno
            ,group_concat(plr.staff_id) staff
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        group by 1
    ) plt on plt.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,case pi.returned
        when 0 then '正向'
        when 1 then '逆向'
    end 包裹类型
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一条有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后有效路由时间
    ,pi.client_id 包裹客户ID
    ,if(ss.pno is not null , '是', '否') 是否有申诉记录
    ,plt.staff
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0321 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on t.pno = pr.pno
        where  -- 最后有效路由
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = pi.pno and pr.rn = 1
left join
    (
        select
            plt.pno
            ,group_concat(plr.staff_id) staff
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        group by 1
    ) plt on plt.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on t.pno = pr.pno
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = pi.pno and pri.rn = 1
left join
    (
        select
            am.pno
        from ph_bi.abnormal_message am
        join tmpale.tmp_ph_pno_0321 t on am.pno = t.pno
        where
            am.isappeal in (2,3,4,5)
            and am.state = 1
        group by 1
    ) ss on ss.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select date_format(now(), '%H:%i:%s');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,case pi.returned
        when 0 then '正向'
        when 1 then '逆向'
    end 包裹类型
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
    end as 最后一条有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后有效路由时间
    ,date_format(convert_tz(pri.routed_at, '+00:00', '+08:00'), '%Y-%m-%d') 打印面单日期
    ,date_format(convert_tz(pri.routed_at, '+00:00', '+08:00'), '%H:%i:%s') 打印面单时间
    ,pi.client_id 包裹客户ID
    ,if(ss.pno is not null , '是', '否') 是否有申诉记录
    ,plt.staff
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0321 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on t.pno = pr.pno
        where  -- 最后有效路由
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = pi.pno and pr.rn = 1
left join
    (
        select
            plt.pno
            ,group_concat(plr.staff_id) staff
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        group by 1
    ) plt on plt.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on t.pno = pr.pno
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = pi.pno and pri.rn = 1
left join
    (
        select
            am.pno
        from ph_bi.abnormal_message am
        join tmpale.tmp_ph_pno_0321 t on am.pno = t.pno
        where
            am.isappeal in (2,3,4,5)
            and am.state = 1
        group by 1
    ) ss on ss.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
with lost as
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
    )
select
    t.pno
    ,lost.staff_info_id 'ID that submitted Lost'
    ,aft.route_action 'Route after Lost was reported'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,bef.route_action
from tmpale.tmp_ph_pno_0321 t
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno and plt.source = 3
        group by 1
    ) c on c.pno = t.pno
left join lost on lost.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.pno and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.pno and bef.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
with lost as
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
    )
select
    t.pno
    ,case aft.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then ' to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route after Lost was reported'
    ,lost.staff_info_id 'ID that submitted Lost'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,case bef.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route before reporting Lost'
from tmpale.tmp_ph_pno_0321 t
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno and plt.source = 3
        group by 1
    ) c on c.pno = t.pno
left join lost on lost.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.pno and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.pno and bef.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
with lost as
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
    )
select
    t.pno
    ,if(c.pno is null , 'NO', 'YES') 'Source C'
    ,case aft.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then ' to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route after Lost was reported'
    ,lost.staff_info_id 'ID that submitted Lost'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,case bef.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route before reporting Lost'
from tmpale.tmp_ph_pno_0321 t
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno and plt.source = 3
        group by 1
    ) c on c.pno = t.pno
left join lost on lost.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.pno and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.pno and bef.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.总访问_认领
    ,b.网点每人平均访问次数_认领
    ,b.访问员工数_认领
from
    (
        select
            t.month_d
            ,ss.name
            ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数_hub
            ,sum(t.count_num) 总访问_hub
            ,count(distinct t.staff_info) 访问员工数_hub
        from tmpale.tmp_ph_hub_0318 t
        left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
#         left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
#             and ss.name = '11 PN5-HUB_Santa Rosa'
            and t.count_num > 2
        group by 1,2
    ) a
left join
    (
         select
            t.month_d
            ,ss.name
            ,sum(t._col1)/count(distinct t. c_sid_ms) 网点每人平均访问次数_认领
            ,sum(t._col1) 总访问_认领
            ,count(distinct t. c_sid_ms) 访问员工数_认领
        from tmpale.tmp_ph_renlin_0318  t
        left join ph_bi.hr_staff_info hsi on t.c_sid_ms = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
#         left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
#             and ss.name = '11 PN5-HUB_Santa Rosa'
            and t._col1 > 2
        group by 1,2
    )  b on a.month_d = b.month_d and a.name = b.name;