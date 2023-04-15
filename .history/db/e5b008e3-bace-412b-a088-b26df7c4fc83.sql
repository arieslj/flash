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
;-- -. . -..- - / . -. - .-. -.--
select
    a.staff_info_id*
from
    (

        select
            a.*
        from
            (
                select
                    mw.staff_info_id
                    ,mw.id
                    ,mw.created_at
                    ,count(mw.id) over (partition by mw.staff_info_id) js_num
                    ,row_number() over (partition by mw.staff_info_id order by mw.created_at desc) rn
                from ph_backyard.message_warning mw
            ) a
        where
            a.rn = 1
    ) a
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a.staff_info_id
where
    a.js_num >= 3
    and a.created_at < '2023-01-01'
    and hsi.state = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.staff_info_id
from
    (

        select
            a.*
        from
            (
                select
                    mw.staff_info_id
                    ,mw.id
                    ,mw.created_at
                    ,count(mw.id) over (partition by mw.staff_info_id) js_num
                    ,row_number() over (partition by mw.staff_info_id order by mw.created_at desc) rn
                from ph_backyard.message_warning mw
            ) a
        where
            a.rn = 1
    ) a
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a.staff_info_id
where
    a.js_num >= 3
    and a.created_at < '2023-01-01'
    and hsi.state = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
     pr.`store_id`
    ,pr.pno

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
    and ss.category in (8,12)
    and ss.state = 1
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
     pr.`store_id` 网点ID
    ,ss.name 网点
    ,pr.pno 包裹

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
    and ss.category in (8,12)
    and ss.state = 1
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
     pr.`store_id` 网点ID
    ,ss.name 网点
    ,pr.pno 包裹

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
    and ss.category in (8,12)
#     and ss.state = 1
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
     pr.`store_id` 网点ID
    ,ss.name 网点
    ,pr.pno 包裹

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
#     and ss.category in (8,12)
#     and ss.state = 1
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select date_sub(curdate(),interval 1 day);
;-- -. . -..- - / . -. - .-. -.--
select
     pr.`store_id` 网点ID
    ,ss.name 网点
    ,pr.pno 包裹

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
#     and ss.category in (8,12)
#     and ss.state = 1
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    mw.staff_info_id
    ,mw.id
    ,mw.type_code
from ph_backyard.message_warning mw
where
    mw.staff_info_id in ('119872', '124880', '119279', '119022', '118822', '118925', '120282', '130832', '120267', '123336', '119617', '146865');
;-- -. . -..- - / . -. - .-. -.--
select
    mw.staff_info_id
    ,mw.id
    ,mw.type_code
    ,mw.date_at
from ph_backyard.message_warning mw
where
    mw.staff_info_id in ('119872', '124880', '119279', '119022', '118822', '118925', '120282', '130832', '120267', '123336', '119617', '146865');
;-- -. . -..- - / . -. - .-. -.--
select
    mw.staff_info_id
    ,mw.id
    ,mw.type_code
    ,mw.date_at
    ,mw.created_at
from ph_backyard.message_warning mw
where
    mw.staff_info_id in ('119872', '124880', '119279', '119022', '118822', '118925', '120282', '130832', '120267', '123336', '119617', '146865');
;-- -. . -..- - / . -. - .-. -.--
select
    mw.staff_info_id 员工ID
    ,mw.id 警告信ID
    ,mw.created_at 警告信创建时间
    ,mw.is_delete 是否删除
    ,case mw.type_code
        when 'warning_1'  then '迟到早退'
        when 'warning_29' then '贪污包裹'
        when 'warning_30' then '偷盗公司财物'
        when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 'warning_9'  then '腐败/滥用职权'
        when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 'warning_5'  then '持有或吸食毒品'
        when 'warning_4'  then '工作时间或工作地点饮酒'
        when 'warning_10' then '玩忽职守'
        when 'warning_2'  then '无故连续旷工3天'
        when 'warning_3'  then '贪污'
        when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
        when 'warning_7'  then '通过社会媒体污蔑公司'
        when 'warning_27' then '工作效率未达到公司的标准(KPI)'
        when 'warning_26' then 'Fake POD'
        when 'warning_25' then 'Fake Status'
        when 'warning_24' then '不接受或不配合公司的调查'
        when 'warning_23' then '损害公司名誉'
        when 'warning_22' then '失职'
        when 'warning_28' then '贪污钱'
        when 'warning_21' then '煽动/挑衅/损害公司利益'
        when 'warning_20' then '谎报里程'
        when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
        when 'warning_19' then '未按照网点规定的时间回款'
        when 'warning_17' then '伪造证件'
        when 'warning_12' then '未告知上级或无故旷工'
        when 'warning_13' then '上级没有同意请假'
        when 'warning_14' then '没有通过系统请假'
        when 'warning_15' then '未按时上下班'
        when 'warning_16' then '不配合公司的吸毒检查'
        when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
        else mw.`type_code`
    end as '警告原因'
from ph_backyard.message_warning mw
where
    mw.staff_info_id in ('119872', '124880', '119279', '119022', '118822', '118925', '120282', '130832', '120267', '123336', '119617', '146865');
;-- -. . -..- - / . -. - .-. -.--
select
    a.date_d
    ,a.pr_num 派件量
    ,b.diff_num 疑难量
    ,b.diff_num/a.pr_num 疑难件率
from
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
            ,count(distinct pr.pno) pr_num
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-02-13 16:00:00'
            and pr.routed_at < '2023-03-20 16:00:00'
            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN','DELIVERY_CONFIRM')
        group by 1
    ) a
left join
    (
        select
            date(convert_tz(di.created_at, '+00:00', '+08:00')) date_d
            ,count(distinct di.pno) diff_num
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'
        group by 1
    ) b on a.date_d = b.date_d;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
    ,case a.diff_marker_category
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
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end reason
    ,count(distinct a.pno) diff_num
    ,count(distinct a.pno) over (partition by date(convert_tz(a.created_at, '+00:00', '+08:00'))) 总计
from
    (
        select
            di.diff_marker_category
            ,di.created_at
            ,di.pno
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'

        union all

        select
            ppd.diff_marker_category
            ,ppd.created_at
            ,ppd.pno
        from ph_staging.parcel_problem_detail ppd
        where
            ppd.created_at >= '2023-02-13 16:00:00'
            and ppd.created_at < '2023-03-20 16:00:00'
            and ppd.parcel_problem_type_category = 2 -- 留仓
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
    ,case a.diff_marker_category
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
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end reason
    ,count(distinct a.pno) diff_num
    ,count( a.pno) over (partition by date(convert_tz(a.created_at, '+00:00', '+08:00'))) 总计
from
    (
        select
            di.diff_marker_category
            ,di.created_at
            ,di.pno
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'

        union all

        select
            ppd.diff_marker_category
            ,ppd.created_at
            ,ppd.pno
        from ph_staging.parcel_problem_detail ppd
        where
            ppd.created_at >= '2023-02-13 16:00:00'
            and ppd.created_at < '2023-03-20 16:00:00'
            and ppd.parcel_problem_type_category = 2 -- 留仓
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
    ,case a.diff_marker_category
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
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end reason
    ,count(distinct a.pno) diff_num
    ,count( a.pno) over (partition by date(convert_tz(a.created_at, '+00:00', '+08:00'))) 总计
from
    (
        select
            di.diff_marker_category
            ,di.created_at
            ,di.pno
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'

        union all

        select
            ppd.diff_marker_category
            ,ppd.created_at
            ,ppd.pno
        from ph_staging.parcel_problem_detail ppd
        where
            ppd.created_at >= '2023-02-13 16:00:00'
            and ppd.created_at < '2023-03-20 16:00:00'
            and ppd.parcel_problem_type_category = 2 -- 留仓
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
    ,case a.diff_marker_category
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
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end reason
    ,count(distinct a.pno) diff_num
#     ,count( a.pno) over (partition by date(convert_tz(a.created_at, '+00:00', '+08:00'))) 总计
from
    (
        select
            di.diff_marker_category
            ,di.created_at
            ,di.pno
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'

        union all

        select
            ppd.diff_marker_category
            ,ppd.created_at
            ,ppd.pno
        from ph_staging.parcel_problem_detail ppd
        where
            ppd.created_at >= '2023-02-13 16:00:00'
            and ppd.created_at < '2023-03-20 16:00:00'
            and ppd.parcel_problem_type_category = 2 -- 留仓
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
    ,case a.diff_marker_category
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
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end reason
    ,count(distinct a.pno) diff_num
#     ,count( a.pno) over (partition by date(convert_tz(a.created_at, '+00:00', '+08:00'))) 总计
from
    (
        select
            di.diff_marker_category
            ,di.created_at
            ,di.pno
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'

        union all

        select
            ppd.diff_marker_category
            ,ppd.created_at
            ,ppd.pno
        from ph_staging.parcel_problem_detail ppd
        where
            ppd.created_at >= '2023-02-13 16:00:00'
            and ppd.created_at < '2023-03-20 16:00:00'
            and ppd.parcel_problem_type_category = 2 -- 留仓
    ) a
group by 1,2
with rollup;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,sum(a.diff_num) over (partition by a.date_d) date_total
from
    (
        select
            date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
            ,case a.diff_marker_category
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
                when 92 then '客户提供的清单里没有此包裹'
                when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
                when 94 then '客户取消寄件/客户实际不想寄此包裹'
                when 95 then '车辆/人力短缺推迟揽收'
                when 96 then '遗漏揽收(已停用)'
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
                when 118 then 'SHOPEE订单系统自动关闭'
                when 119 then '客户取消包裹'
                when 121 then '地址错误'
                when 122 then '当日运力不足，无法揽收'
            end reason
            ,count(distinct a.pno) diff_num
        from
            (
                select
                    di.diff_marker_category
                    ,di.created_at
                    ,di.pno
                from ph_staging.diff_info di
                where
                    di.created_at >= '2023-02-13 16:00:00'
                    and di.created_at < '2023-03-20 16:00:00'

                union all

                select
                    ppd.diff_marker_category
                    ,ppd.created_at
                    ,ppd.pno
                from ph_staging.parcel_problem_detail ppd
                where
                    ppd.created_at >= '2023-02-13 16:00:00'
                    and ppd.created_at < '2023-03-20 16:00:00'
                    and ppd.parcel_problem_type_category = 2 -- 留仓
            ) a
        group by 1,2
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,sum(a.diff_num) total
from
    (
        select
            case a.diff_marker_category
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
                when 92 then '客户提供的清单里没有此包裹'
                when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
                when 94 then '客户取消寄件/客户实际不想寄此包裹'
                when 95 then '车辆/人力短缺推迟揽收'
                when 96 then '遗漏揽收(已停用)'
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
                when 118 then 'SHOPEE订单系统自动关闭'
                when 119 then '客户取消包裹'
                when 121 then '地址错误'
                when 122 then '当日运力不足，无法揽收'
            end reason
            ,count(distinct a.pno) diff_num
        from
            (
                select
                    di.diff_marker_category
                    ,di.created_at
                    ,di.pno
                from ph_staging.diff_info di
                where
                    di.created_at >= '2023-02-13 16:00:00'
                    and di.created_at < '2023-03-20 16:00:00'

                union all

                select
                    ppd.diff_marker_category
                    ,ppd.created_at
                    ,ppd.pno
                from ph_staging.parcel_problem_detail ppd
                where
                    ppd.created_at >= '2023-02-13 16:00:00'
                    and ppd.created_at < '2023-03-20 16:00:00'
                    and ppd.parcel_problem_type_category = 2 -- 留仓
            ) a
        group by 1
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,sum(a.diff_num) over () total
from
    (
        select
            case a.diff_marker_category
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
                when 92 then '客户提供的清单里没有此包裹'
                when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
                when 94 then '客户取消寄件/客户实际不想寄此包裹'
                when 95 then '车辆/人力短缺推迟揽收'
                when 96 then '遗漏揽收(已停用)'
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
                when 118 then 'SHOPEE订单系统自动关闭'
                when 119 then '客户取消包裹'
                when 121 then '地址错误'
                when 122 then '当日运力不足，无法揽收'
            end reason
            ,count(distinct a.pno) diff_num
        from
            (
                select
                    di.diff_marker_category
                    ,di.created_at
                    ,di.pno
                from ph_staging.diff_info di
                where
                    di.created_at >= '2023-02-13 16:00:00'
                    and di.created_at < '2023-03-20 16:00:00'

                union all

                select
                    ppd.diff_marker_category
                    ,ppd.created_at
                    ,ppd.pno
                from ph_staging.parcel_problem_detail ppd
                where
                    ppd.created_at >= '2023-02-13 16:00:00'
                    and ppd.created_at < '2023-03-20 16:00:00'
                    and ppd.parcel_problem_type_category = 2 -- 留仓
            ) a
        group by 1
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pi.pno) 揽收量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno)  揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) 总疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pi.pno) 揽收量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno)  揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) 总疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pi.pno) 揽收量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno)  揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) 总疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pi.pno) 揽收量
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) COD疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
    and pi.cod_enabled = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pi.pno) 揽收量
    ,count(if(pi,kp.cod_enabled = 1, pi.pno, null)) 揽收COD量
    ,count(if(pi,kp.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno) 揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pi.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(if(pi,kp.cod_enabled = 1, pi.pno, null)) COD疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
group by 1
order by 5
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pi.pno) 揽收量
    ,count(if(pi.cod_enabled = 1, pi.pno, null)) 揽收COD量
    ,count(if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno) 揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pi.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(if(pi,kp.cod_enabled = 1, pi.pno, null)) COD疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
group by 1
order by 5
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pi.pno) 揽收量
    ,count(if(pi.cod_enabled = 1, pi.pno, null)) 揽收COD量
    ,count(if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno) 揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pi.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(if(pi.cod_enabled = 1, pi.pno, null)) COD疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
group by 1
order by 5
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pi.pno) 揽收量
    ,count(if(pi.cod_enabled = 1, pi.pno, null)) 揽收COD量
    ,count(if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno) 揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pi.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(if(pi.cod_enabled = 1, pi.pno, null)) COD疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
group by 1
order by 5 desc
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pr.pno) 交接量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno)  揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) 总疑难件率
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pr.pno) 交接量
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) COD疑难件率
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
    and pi.cod_enabled = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pr.pno) 交接量
    ,count(if(pi.cod_enabled = 1, pr.pno, null)) 交接COD量
    ,count(if(pi.cod_enabled = 1, pr.pno, null))/count(distinct pi.pno) 交接COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pr.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null))/count(if(pi.cod_enabled = 1, pr.pno, null)) COD疑难件率
from ph_staging.parcel_route pr
left join  ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
group by 1
order by 5 desc
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pr.pno) 交接量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno)  揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) 总疑难件率
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pr.pno) 交接量
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) COD疑难件率
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
    and pi.cod_enabled = 1
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pr.pno) 交接量
    ,count(if(pi.cod_enabled = 1, pr.pno, null)) 交接COD量
    ,count(if(pi.cod_enabled = 1, pr.pno, null))/count(distinct pi.pno) 交接COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pr.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null))/count(if(pi.cod_enabled = 1, pr.pno, null)) COD疑难件率
from ph_staging.parcel_route pr
left join  ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1
order by 5 desc
limit 100;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada','shopee','tiktok')
    where
        pr.routed_at >= '2023-02-13 16:00:00'
        and pr.routed_at < '2023-03-20 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    group by 1
)
select
    case di.diff_marker_category
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
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,count(distinct di.pno) 疑难件量
    ,scan.scan_num 交接总量
    ,count(distinct di.pno)/scan.scan_num 疑难件率
    ,scan.cod_num COD交接量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null))/scan.cod_num COD疑难件率
from t
left join ph_staging.parcel_info pi on pi.pno = t.pno
left join
    (
        select
            di.pno
            ,di.diff_marker_category
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        group by 1,2

        union all

        select
            ppd.pno
            ,ppd.diff_marker_category
        from ph_staging.parcel_problem_detail ppd
        join t on t.pno = ppd.pno
        where
            ppd.parcel_problem_type_category = 2
        group by 1,2
    ) di on di.pno = t.pno
cross join
    (
        select
            count(t.pno) scan_num
            ,count(if(pi.cod_enabled = 1, pi.pno, null)) cod_num
        from t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
    ) scan;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada','shopee','tiktok')
    where
        pr.routed_at >= '2023-02-13 16:00:00'
        and pr.routed_at < '2023-03-20 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    group by 1
)
select
    case di.diff_marker_category
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
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,count(distinct di.pno) 疑难件量
    ,scan.scan_num 交接总量
    ,count(distinct di.pno)/scan.scan_num 疑难件率
    ,scan.cod_num COD交接量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null))/scan.cod_num COD疑难件率
from t
left join ph_staging.parcel_info pi on pi.pno = t.pno
left join
    (
        select
            di.pno
            ,di.diff_marker_category
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        group by 1,2

        union all

        select
            ppd.pno
            ,ppd.diff_marker_category
        from ph_staging.parcel_problem_detail ppd
        join t on t.pno = ppd.pno
        where
            ppd.parcel_problem_type_category = 2
        group by 1,2
    ) di on di.pno = t.pno
cross join
    (
        select
            count(t.pno) scan_num
            ,count(if(pi.cod_enabled = 1, pi.pno, null)) cod_num
        from t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
    ) scan
group by 1,3,5;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        case
            when bc.`client_id` is not null then bc.client_name
            when kp.id is not null and bc.client_id is null then '普通ka'
            when kp.`id` is null then '小c'
        end client_type
        ,pr.pno
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    left join ph_staging.ka_profile kp on kp.id = pi.client_id
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    where
        pr.routed_at >= '2023-02-13 16:00:00'
        and pr.routed_at < '2023-03-20 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    group by 1,2
)
select
    t.client_type
    ,case di.diff_marker_category
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
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,count(distinct di.pno) 疑难件量
    ,scan.scan_num 交接总量
    ,count(distinct di.pno)/scan.scan_num 疑难件率
    ,scan.cod_num COD交接量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null))/scan.cod_num COD疑难件率
from t
left join ph_staging.parcel_info pi on pi.pno = t.pno
left join
    (
        select
            di.pno
            ,di.diff_marker_category
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        group by 1,2

        union all

        select
            ppd.pno
            ,ppd.diff_marker_category
        from ph_staging.parcel_problem_detail ppd
        join t on t.pno = ppd.pno
        where
            ppd.parcel_problem_type_category = 2
        group by 1,2
    ) di on di.pno = t.pno
left  join
    (
        select
            t.client_type
            ,count(t.pno) scan_num
            ,count(if(pi.cod_enabled = 1, pi.pno, null)) cod_num
        from t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        group by 1
    ) scan on scan.client_type = t.client_type
group by 1,2,4,6;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        case
            when bc.`client_id` is not null then bc.client_name
            when kp.id is not null and bc.client_id is null then '普通ka'
            when kp.`id` is null then '小c'
        end client_type
        ,pr.pno
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    left join ph_staging.ka_profile kp on kp.id = pi.client_id
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    where
        pr.routed_at >= '2023-02-13 16:00:00'
        and pr.routed_at < '2023-03-20 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    group by 1,2
)
select
    t.client_type
    ,case di.diff_marker_category
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
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end 疑难原因
    ,count(distinct di.pno) 疑难件量
    ,scan.scan_num 交接总量
    ,count(distinct di.pno)/scan.scan_num 疑难件率
    ,scan.cod_num COD交接量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null))/scan.cod_num COD疑难件率
from t
left join ph_staging.parcel_info pi on pi.pno = t.pno
left join
    (
        select
            di.pno
            ,di.diff_marker_category
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        group by 1,2

        union all

        select
            ppd.pno
            ,ppd.diff_marker_category
        from ph_staging.parcel_problem_detail ppd
        join t on t.pno = ppd.pno
        where
            ppd.parcel_problem_type_category = 2
        group by 1,2
    ) di on di.pno = t.pno
left  join
    (
        select
            t.client_type
            ,count(t.pno) scan_num
            ,count(if(pi.cod_enabled = 1, pi.pno, null)) cod_num
        from t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        group by 1
    ) scan on scan.client_type = t.client_type
group by 1,2,4,6;
;-- -. . -..- - / . -. - .-. -.--
select
    am.merge_column
    ,am.extra_info
from ph_bi.abnormal_message am
join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
where
    am.abnormal_object = 1 -- 集体处罚
    and am.punish_category = 7 -- 包裹丢失
    and am.abnormal_time >= '2023-01-01'
    and am.abnormal_time < '2023-03-01'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    am.merge_column
    ,am.extra_info
from ph_bi.abnormal_message am
join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
where
    am.abnormal_object = 1 -- 集体处罚
    and am.punish_category = 7 -- 包裹丢失
    and am.abnormal_time >= '2023-01-01'
    and am.abnormal_time < '2023-03-01'
    and am.state = 1
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,am.extra_info
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2
)
, lost as
(
    select
        pr.pno
        ,pr.staff_info_id
        ,pr.routed_at
    from ph_staging.parcel_route pr
    join  t on pr.pno = t.merge_column
    where
        pr.route_action = 'DIFFICULTY_HANDOVER'
        and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
)
select
    t.merge_column 单号
    ,t.customary_pno 正向单号
    ,t.name 网点名称
    ,if(t.returned = 0 ,'Fwd', 'Rts') 正向或逆向
    ,case plt.last_valid_action
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
    end 最后一条有效路由
    ,plt.last_valid_routed_at
    ,convert_tz(pri.routed_at, '+00:00', '+08:00') 最后一次打印面单日期
    ,convert_tz(pri2.routed_at, '+00:00', '+08:00') 如果是退件面单，最后一次正向打印面单的日期
    ,if(t.returned = 1, convert_tz(pri.routed_at, '+00:00', '+08:00'), null) 退件面单最后一次打印日期
    ,t.client_id
    ,if(t.isappeal in (2,3,4,5) ,'yes', 'no') 是否有申诉记录
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
    ,group_concat(plr.staff_id)
from t
left join ph_bi.parcel_lose_task plt on plt.id = json_extract(t.extra_info, '$.losr_task_id')
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.merge_column
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = t.merge_column and pri.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.customary_pno
        where
            pr.route_action = 'PRINTING'
            and t.returned = 1
    ) pri2 on pri2.pno = t.customary_pno and pri2.rn = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t on t.merge_column = plt.pno
        where
            plt.source = 3
        group by 1
    ) c on c.pno = t.merge_column
left join lost on lost.pno = t.merge_column
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.merge_column and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.merge_column and bef.rn = 1
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,am.extra_info
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2
)
, lost as
(
    select
        pr.pno
        ,pr.staff_info_id
        ,pr.routed_at
    from ph_staging.parcel_route pr
    join  t on pr.pno = t.merge_column
    where
        pr.route_action = 'DIFFICULTY_HANDOVER'
        and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
)
select
    t.merge_column 单号
    ,t.customary_pno 正向单号
    ,t.name 网点名称
    ,if(t.returned = 0 ,'Fwd', 'Rts') 正向或逆向
    ,case plt.last_valid_action
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
    end 最后一条有效路由
    ,plt.last_valid_routed_at
    ,convert_tz(pri.routed_at, '+00:00', '+08:00') 最后一次打印面单日期
    ,convert_tz(pri2.routed_at, '+00:00', '+08:00') '如果是退件面单，最后一次正向打印面单的日期'
    ,if(t.returned = 1, convert_tz(pri.routed_at, '+00:00', '+08:00'), null) 退件面单最后一次打印日期
    ,t.client_id
    ,if(t.isappeal in (2,3,4,5) ,'yes', 'no') 是否有申诉记录
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
    ,group_concat(plr.staff_id)
from t
left join ph_bi.parcel_lose_task plt on plt.id = json_extract(t.extra_info, '$.losr_task_id')
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.merge_column
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = t.merge_column and pri.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.customary_pno
        where
            pr.route_action = 'PRINTING'
            and t.returned = 1
    ) pri2 on pri2.pno = t.customary_pno and pri2.rn = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t on t.merge_column = plt.pno
        where
            plt.source = 3
        group by 1
    ) c on c.pno = t.merge_column
left join lost on lost.pno = t.merge_column
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.merge_column and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.merge_column and bef.rn = 1
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        am.merge_column
        ,am.extra_info
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,json_extract(am.extra_info, '$.losr_task_id') lose_task_id
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2
)
, lost as
(
    select
        pr.pno
        ,pr.staff_info_id
        ,pr.routed_at
    from ph_staging.parcel_route pr
    join  t on pr.pno = t.merge_column
    where
        pr.route_action = 'DIFFICULTY_HANDOVER'
        and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
)
select
    t.merge_column 单号
    ,t.customary_pno 正向单号
    ,t.name 网点名称
    ,if(t.returned = 0 ,'Fwd', 'Rts') 正向或逆向
    ,case plt.last_valid_action
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
    end 最后一条有效路由
    ,plt.last_valid_routed_at 最后一条有效路由时间
    ,convert_tz(pri.routed_at, '+00:00', '+08:00') 最后一次打印面单日期
    ,convert_tz(pri2.routed_at, '+00:00', '+08:00') '如果是退件面单，最后一次正向打印面单的日期'
    ,if(t.returned = 1, convert_tz(pri.routed_at, '+00:00', '+08:00'), null) 退件面单最后一次打印日期
    ,t.client_id
    ,if(t.isappeal in (2,3,4,5) ,'yes', 'no') 是否有申诉记录
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
    ,group_concat(plr.staff_id) staff
from t
left join ph_bi.parcel_lose_task plt on plt.id = t.lose_task_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.merge_column
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = t.merge_column and pri.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.customary_pno
        where
            pr.route_action = 'PRINTING'
            and t.returned = 1
    ) pri2 on pri2.pno = t.customary_pno and pri2.rn = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t on t.merge_column = plt.pno
        where
            plt.source = 3
        group by 1
    ) c on c.pno = t.merge_column
left join lost on lost.pno = t.merge_column
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.merge_column and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.merge_column and bef.rn = 1
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        am.merge_column
        ,json_extract(am.extra_info, '$.losr_task_id') lose_task_id
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,json_extract(am.extra_info, '$.losr_task_id') lose_task_id
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2
)
, lost as
(
    select
        pr.pno
        ,pr.staff_info_id
        ,pr.routed_at
    from ph_staging.parcel_route pr
    join  t on pr.pno = t.merge_column
    where
        pr.route_action = 'DIFFICULTY_HANDOVER'
        and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
)
select
    t.merge_column 单号
    ,t.customary_pno 正向单号
    ,t.name 网点名称
    ,if(t.returned = 0 ,'Fwd', 'Rts') 正向或逆向
    ,case pr.route_action
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
    end 最后一条有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一条有效路由时间
    ,convert_tz(pri.routed_at, '+00:00', '+08:00') 最后一次打印面单日期
    ,convert_tz(pri2.routed_at, '+00:00', '+08:00') '如果是退件面单，最后一次正向打印面单的日期'
    ,if(t.returned = 1, convert_tz(pri.routed_at, '+00:00', '+08:00'), null) 退件面单最后一次打印日期
    ,t.client_id
    ,if(t.isappeal in (2,3,4,5) ,'yes', 'no') 是否有申诉记录
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
    ,group_concat(plr.staff_id) staff
from t
left join
    (
          select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on t.merge_column = pr.pno
        where  -- 最后有效路由
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = t.merge_column and pr.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.merge_column
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = t.merge_column and pri.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.customary_pno
        where
            pr.route_action = 'PRINTING'
            and t.returned = 1
    ) pri2 on pri2.pno = t.customary_pno and pri2.rn = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t on t.merge_column = plt.pno
        where
            plt.source = 3
        group by 1
    ) c on c.pno = t.merge_column
left join lost on lost.pno = t.merge_column
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.merge_column and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.merge_column and bef.rn = 1
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = t.lose_task_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,json_extract(am.extra_info, '$.losr_task_id') lose_task_id
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2
)
select
    t.merge_column
    ,case pr.route_action
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
    end 最后一条有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一条有效路由时间
from t
left join
(
      select
        pr.pno
        ,pr.route_action
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
    from ph_staging.parcel_route pr
    join  t on t.merge_column = pr.pno
    where  -- 最后有效路由
        pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
) pr on pr.pno = t.merge_column and pr.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select DATE_FORMAT(curdate() ,'%Y%m');
;-- -. . -..- - / . -. - .-. -.--
SELECT
	DATE_FORMAT(plt.`updated_at`, '%Y%m%d') '统计日期 Statistical date'
	,if(plt.`duty_result`=3,pr.store_name,ss.`name`) '网点名称 store name'
	,smp.`name` '片区Area'
	,smr.`name` '大区District'
	,pi.`揽件包裹Qty. of pick up parcel`
	,pi2.`妥投包裹Qty. of delivered parcel`
	,COUNT(DISTINCT(if(plt.`duty_result`=1 and plt.`duty_type` in(4),plt.`pno`,null)))*0.5+COUNT(DISTINCT(if(plt.`duty_result`=1 and plt.`duty_type` not in(4),plt.`pno`,null))) '丢失 Lost'
	,COUNT(DISTINCT(if(plt.`duty_result`=2 and plt.`duty_type` in(4),plt.`pno`,null)))*0.5+COUNT(DISTINCT(if(plt.`duty_result`=2 and plt.`duty_type` not in(4),plt.`pno`,null))) '破损 Dmaged'
	,COUNT(DISTINCT(if(plt.`duty_result`=3 and plt.`duty_type` in(4),plt.`pno`,null)))*0.5+COUNT(DISTINCT(if(plt.`duty_result`=3 and plt.`duty_type` not in(4),plt.`pno`,null))) '超时包裹 Over SLA'
	,sum(if(plt.`duty_result`=1,pcn.claim_money,0)) '丢失理赔金额 Lost claim amount'
	,sum(if(plt.`duty_result`=2,pcn.claim_money,0)) '破损理赔金额 Damage claim amount'
	,sum(if(plt.`duty_result`=3,pcn.claim_money,0)) '超时效理赔金额 Over SLA claim amount'
FROM  `ph_bi`.`parcel_lose_task` plt
LEFT JOIN `ph_bi`.`parcel_lose_responsible` plr on plr.`lose_task_id` =plt.`id`
LEFT JOIN `ph_bi`.`sys_store` ss on ss.`id` = plr.`store_id`
LEFT JOIN `ph_bi`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
LEFT JOIN `ph_bi`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
LEFT JOIN ( SELECT
                    DATE_FORMAT(convert_tz(pi.`created_at`,'+00:00','+08:00'),'%Y%m%d') 揽收日期
                    ,pi.`ticket_pickup_store_id`
           			,COUNT( DISTINCT(pi.pno)) '揽件包裹Qty. of pick up parcel'
             FROM `ph_staging`.`parcel_info` pi
           	 where pi.`state`<9
           	 and DATE_FORMAT(convert_tz(pi.`created_at`,'+00:00','+08:00'),'%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
             GROUP BY 1,2
            ) pi on pi.揽收日期=DATE_FORMAT(plt.`updated_at`, '%Y%m%d') and pi.`ticket_pickup_store_id`= plr.`store_id`
LEFT JOIN ( SELECT
                    DATE_FORMAT(convert_tz(pi.`finished_at`, '+00:00','+08:00'),'%Y%m%d') 妥投日期
                    ,pi.`ticket_delivery_store_id`
           			,COUNT( DISTINCT(if(pi.state=5,pi.pno,null))) '妥投包裹Qty. of delivered parcel'
             FROM `ph_staging`.`parcel_info` pi
           	 where pi.`state`<9
           	 and DATE_FORMAT(convert_tz(pi.`finished_at`, '+00:00','+08:00'),'%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
             GROUP BY 1,2
            ) pi2 on pi2.妥投日期=DATE_FORMAT(plt.`updated_at`, '%Y%m%d') and pi2.`ticket_delivery_store_id`= plr.`store_id`
LEFT JOIN
(

    SELECT *
     FROM
           (
                 SELECT pct.`pno`
                               ,pct.`id`
                    ,pct.`finance_updated_at`
                             ,pct.`state`
                               ,pct.`created_at`
                        ,row_number() over (partition by pct.`pno` order by pct.`created_at` DESC ) row_num
             FROM `ph_bi`.parcel_claim_task pct
             where pct.state=6
           )t0
    WHERE t0.row_num=1
)pct on pct.pno=plt.pno
LEFT  join
        (
            select *
            from
                (
                select
                pcn.`task_id`
                ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) row_num
                from `ph_bi`.parcel_claim_negotiation pcn
                ) t1
            where t1.row_num=1
        )pcn on pcn.task_id =pct.`id`
LEFT JOIN (select pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value
           from (select
         pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value,
         row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
         from `ph_staging`.`parcel_route` pr
         where pr.`routed_at`>= CONVERT_TZ('2022-12-01','+08:00','+00:00')
         and pr.`route_action` in(
             select dd.`element`  from dwm.dwd_dim_dict dd where dd.remark ='valid')
                ) pr
         where pr.rn = 1
        ) pr on pr.pno=plt.`pno`
where plt.`state` in (6)
and plt.`operator_id` not in ('10000','10001')
and DATE_FORMAT(plt.`updated_at`, '%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
and plt.`updated_at` IS NOT NULL
GROUP BY 1,2,3,4
ORDER BY 1,2;
;-- -. . -..- - / . -. - .-. -.--
SELECT DISTINCT

	plt.created_at '任务生成时间 Task generation time'
    ,CONCAT('SSRD',plt.`id`) '任务ID Task ID'
	,plt.`pno`  '运单号 Waybill'
	,case plt.`vip_enable`
    when 0 then '普通客户'
    when 1 then 'KAM客户'
    end as '客户类型 Client type'
	,case plt.`duty_result`
	when 1 then '丢失'
	when 2 then '破损'
	when 3 then '超时效'
	end as '判责类型Judgement type'
	,t.`t_value` '原因 Reason'
	,plt.`client_id` '客户ID Client ID'
	,pi.`cod_amount`/100 'COD金额 COD'
	,plt.`parcel_created_at` '揽收时间 Pick up time'
	,cast(pi.exhibition_weight as double)/1000 '重量 Weight'
    ,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) '尺寸 Size'
	,case pi.parcel_category
     when '0' then '文件'
     when '1' then '干燥食品'
     when '10' then '家居用具'
    when '11' then '水果'
     when '2' then '日用品'
     when '3' then '数码产品'
     when '4' then '衣物'
     when '5' then '书刊'
    when '6' then '汽车配件'
     when '7' then '鞋包'
    when '8' then '体育器材'
     when '9' then '化妆品'
    when '99' then '其它'
    end  as '包裹品类 Item type'
	,pr.route_action 最后一条有效路由动作
	,wo.`order_no` '工单号 Ticket No.'
	,case  plt.`source`
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
		WHEN 11 THEN 'K-超时效'
		when 12 then 'L-高度疑似丢失'
		END AS '问题件来源渠道 Source channel of issue'
	,case plt.`state`
	when 5 then '无需追责'
	when 6 then '责任人已认定'
	end  as '状态 Status'
    ,plt.`fleet_stores` '异常区间 Abnormal interval'
    ,ft.`line_name`  '异常车线  Abnormal LH'
	,plt.`operator_id` '处理人 Handler'
	,plt.`updated_at` '处理时间 Handle time'
	,plt.`penalty_base` '判罚依据 Basis of penalty'
    ,case plt.`link_type`
    WHEN 0 THEN 'ipc计数后丢失'
    WHEN 1 THEN '揽收网点已揽件，未收件入仓'
    WHEN 2 THEN '揽收网点已收件入仓，未发件出仓'
    WHEN 3 THEN '中转已到件入仓扫描，中转未发件出仓'
    WHEN 4 THEN '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
    WHEN 5 THEN '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
    WHEN 6 THEN '分拨发件出仓扫描，目的地未到件入仓(集包)'
    WHEN 7 THEN '分拨发件出仓扫描，目的地未到件入仓(单件)'
    WHEN 8 THEN '目的地到件入仓扫描，目的地未交接,当日遗失'
    WHEN 9 THEN '目的地到件入仓扫描，目的地未交接,次日遗失'
    WHEN 10 THEN '目的地交接扫描，目的地未妥投'
    WHEN 11 THEN '目的地妥投后丢失'
    WHEN 12 THEN '途中破损/短少'
    WHEN 13 THEN '妥投后破损/短少'
    WHEN 14 THEN '揽收网点已揽件，未收件入仓'
    WHEN 15 THEN '揽收网点已收件入仓，未发件出仓'
    WHEN 16 THEN '揽收网点发件出仓到分拨了'
    WHEN 17 THEN '目的地到件入仓扫描，目的地未交接'
    WHEN 18 THEN '目的地交接扫描，目的地未妥投'
    WHEN 19 THEN '目的地妥投后破损短少'
    WHEN 20 THEN '分拨已发件出仓，下一站分拨未到件入仓(集包)'
    WHEN 21 THEN '分拨已发件出仓，下一站分拨未到件入仓(单件)'
    WHEN 22 THEN 'ipc计数后丢失'
    WHEN 23 THEN '超时效SLA'
    WHEN 24 THEN '分拨发件出仓到下一站分拨了'
	end as '判责环节 Judgement'
    ,case if(plt.state= 6,plt.`duty_type`,null)
	when 1 then '快递员100%套餐'
    when 2 then '仓7主3套餐(仓管70%主管30%)'
 	when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
    when 5 then  '快递员721套餐(快递员70%仓管20%主管10%)'
    when 6 then  '仓管721套餐(仓管70%快递员20%主管10%)'
    when 8 then  'LH全责（LH100%）'
    when 7 then  '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
    when 21 then  '仓7主3套餐(仓管70%主管30%)'
	end as '套餐 Penalty plan'
	,ss3.`name` '责任网点 Resposible DC'
	,case pct.state
                when 1 then '丢失件待协商'
                when 2 then '协商不一致'
                when 3 then '待财务核实'
                when 4 then '待财务支付'
                when 5 then '支付驳回'
                when 6 then '理赔完成'
                when 7 then '理赔终止'
                when 8 then '异常关闭'
                end as '理赔处理状态 Status of claim'
	,if(pct.state=6,pcn.claim_money,0) '理赔金额 Claim amount'
	,timestampdiff( hour ,plt.`created_at` ,plt.`updated_at`) '处理时效 Processing SLA'
	,DATE_FORMAT(plt.`updated_at`,'%Y%m%d') '统计日期 Statistical date'
	,plt.`remark` 备注




FROM  `ph_bi`.`parcel_lose_task` plt
LEFT JOIN `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno
LEFT JOIN `ph_bi`.`sys_store` ss on ss.id = pi.`ticket_pickup_store_id`
LEFT JOIN `ph_bi`.`sys_store` ss1 on ss1.id = pi.`dst_store_id`

LEFT JOIN `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
LEFT JOIN `ph_bi`.`fleet_time` ft on ft.`proof_id` =LEFT (plt.`fleet_routeids`,11)
LEFT JOIN `ph_bi`.`parcel_lose_stat_detail` pld on pld. `lose_task_id`=plt.`id`
LEFT JOIN `ph_bi`.`parcel_lose_responsible` plr on plr.`lose_task_id`=plt.`id`
LEFT JOIN `ph_bi`.`sys_store` ss3 on ss3.id = plr.store_id
LEFT JOIN `ph_bi`.`translations` t ON plt.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'
LEFT JOIN
(

    SELECT *
     FROM
           (
                 SELECT pct.`pno`
                               ,pct.`id`
                    ,pct.`finance_updated_at`
                             ,pct.`state`
                               ,pct.`created_at`
                        ,row_number() over (partition by pct.`pno` order by pct.`created_at` DESC ) row_num
             FROM `ph_bi`.parcel_claim_task pct

           )t0
    WHERE t0.row_num=1
)pct on pct.pno=plt.pno
LEFT  join
        (
            select *
            from
                (
                select
                pcn.`task_id`
                ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) row_num
                from `ph_bi`.parcel_claim_negotiation pcn
                ) t1
            where t1.row_num=1
        )pcn on pcn.task_id =pct.`id`
LEFT JOIN (select pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value
           from (select
         pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value,
         row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
         from `ph_staging`.`parcel_route` pr
         where pr.`routed_at`>= CONVERT_TZ('2022-12-01','+08:00','+00:00')
         and pr.`route_action` in(
             select dd.`element`  from dwm.dwd_dim_dict dd where dd.remark ='valid')
                ) pr
         where pr.rn = 1
        ) pr on pr.pno=plt.`pno`
where 1=1
and plt.`state` in (5,6)
and plt.`operator_id` not in ('10000','10001')
and DATE_FORMAT(plt.`updated_at`, '%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
GROUP BY 2
ORDER BY 2;
;-- -. . -..- - / . -. - .-. -.--
select DATE_FORMAT(curdate() ,'%Y-%m-%d');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.store_total_amount
    ,pi.store_parcel_amount
    ,pi.cod_poundage_amount
    ,pi.material_amount
    ,pi.insure_amount
    ,pi.freight_insure_amount
    ,pi.label_amount
from ph_staging.parcel_info pi
where
    pi.pno = 'P18031DPPG5BQ';
;-- -. . -..- - / . -. - .-. -.--
select
    pi.store_total_amount
    ,pi.store_parcel_amount
    ,pi.cod_poundage_amount
    ,pi.material_amount
    ,pi.insure_amount
    ,pi.freight_insure_amount
    ,pi.label_amount
    ,pi.cod_amount
from ph_staging.parcel_info pi
where
    pi.pno = 'P18031DPPG5BQ';
;-- -. . -..- - / . -. - .-. -.--
select
    pcd.pno
    ,if(pi.returned = 0, '正向', '逆向') 包裹流向
    ,pi.customary_pno 原单号
    ,oi.cogs_amount cog金额
    ,pi2.store_total_amount 总运费
    ,pi2.cod_amount/100 COD金额
    ,pi2.cod_poundage_amount COD手续费
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 当前包裹状态
from ph_staging.parcel_change_detail pcd
left join ph_staging.parcel_info pi on pcd.pno = pi.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
where
    pcd.new_value = 'PH19040F05'
    and pcd.created_at >= '2023-01-31 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pcd.pno
    ,if(pi.returned = 0, '正向', '逆向') 包裹流向
    ,pi.customary_pno 原单号
    ,oi.cogs_amount/100 cog金额
    ,pi2.store_total_amount 总运费
    ,pi2.cod_amount/100 COD金额
    ,pi2.cod_poundage_amount COD手续费
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 当前包裹状态
from ph_staging.parcel_change_detail pcd
left join ph_staging.parcel_info pi on pcd.pno = pi.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
where
    pcd.new_value = 'PH19040F05'
    and pcd.created_at >= '2023-01-31 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    *
from tmpale.tmp_ph_test_0406;
;-- -. . -..- - / . -. - .-. -.--
select
    t.dated
    ,t.staff
    ,count(distinct t.pno) num
    ,group_concat(t.pno) pno
from tmpale.tmp_ph_test_0406 t
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.category
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.category
    ,ss2.category category2
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
left join ph_staging.sys_store ss2 on ss2.id = ph.claim_store_id
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.category
    ,ss2.category
    ,count(ph.hno) num
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
left join ph_staging.sys_store ss2 on ss2.id = ph.claim_store_id
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.category
    ,ss2.category
    ,count(ph.hno) num
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
left join ph_staging.sys_store ss2 on ss2.id = ph.claim_store_id
where
    ph.claim_store_id is not null
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name
    ,ss2.name name2
    ,count(ph.hno) num
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
left join ph_staging.sys_store ss2 on ss2.id = ph.claim_store_id
where
    ph.claim_store_id is not null
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select #应集包
            pr.`store_id`
            ,count(distinct pr.`pno`) 应集包量
        from `ph_staging`.`parcel_route` pr
        left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
        left join ph_staging.parcel_route pr2 on pr2.pno = pr.pno and pr2.route_action = 'UNSEAL' and DATE_FORMAT(CONVERT_TZ(pr2.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day) and pr2.store_id = pr.store_id
        where
            pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
            and pi.`exhibition_weight`<=3000
            and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
            and pi.`exhibition_length` <=30
            and pi.`exhibition_width` <=30
            and pi.`exhibition_height` <=30
            and pr2.pno is not null
        GROUP BY 1;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,v2.出勤收派员人数
    ,v2.出勤仓管人数
    ,v2.出勤主管人数
    ,pr.妥投量
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
    ,dc.应派量
    ,pr3.交接量
    ,concat(round(pr3.交接量/dc.应派量,4)*100,'%') 交接率
    ,pr4.应盘点量
    ,pr5.实际盘点量
    ,pr4.应盘点量- pr5.实际盘点量 未盘点量
    ,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
    ,pr6.应集包量
    ,pr7.实际集包量
    ,concat(round(pr7.实际集包量/pr6.应集包量,4)*100,'%') 集包率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
            and ss.state = 1
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
left join
    (
        select #出勤
            hi.`sys_store_id`
            ,count(distinct(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
            ,count(distinct(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
            ,count(distinct(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
        from `ph_bi`.`attendance_data_v2` v2
        left join `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
        where
            v2.`stat_date`=date_sub(curdate(),interval 1 day)
            and
                (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
        group by 1
    )v2 on v2.`sys_store_id`=ss.`id`
left join
    (
        select #妥投
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 妥投量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_CONFIRM')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr on pr.`store_id`=ss.`id`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
            )pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d') >= date_sub(curdate(),interval 1 day)
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`
left join
    (
        select #应派
            dc.`store_id`
            ,count(distinct(dc.`pno`)) 应派量
        from `ph_bi`.`dc_should_delivery_today` dc
        where
            dc.`stat_date`= date_sub(curdate(),interval 1 day)
        group by 1
    ) dc on dc.`store_id`=ss.`id`
left join
    (
        select #交接
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 交接量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr3 on pr3.`store_id`=ss.`id`
left join
    (
        select #应盘
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应盘点量
        from
            (
                select #最后一条有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`state`
                    ,pr.`routed_at`
                from
                    (
                        select
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`state`
                             ,pr.`routed_at`
                             ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                        from `ph_staging`.`parcel_route` pr
                        where
                            DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')<=date_sub(curdate(),interval 1 day)
                            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
            left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
            left join
                (
                    select #车货关联出港
                        pr.`pno`
                        ,pr.`store_id`
                        ,pr.`routed_at`
                    from `ph_staging`.`parcel_route` pr
                    where
                        pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')<=date_sub(curdate(),interval 1 day)
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')>=date_sub(curdate(),interval 200 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
            and pi.state in (1,2,3,4,6)
        group by 1
    )pr4 on pr4.`store_id`=ss.`id`
left join
    (
        select #实际盘点
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际盘点量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
        GROUP BY 1
    )pr5 on pr5.`store_id`=ss.`id`
left join
    (
        select #应集包
            pr.`store_id`
            ,count(distinct pr.`pno`) 应集包量
        from `ph_staging`.`parcel_route` pr
        left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
        left join ph_staging.parcel_route pr2 on pr2.pno = pr.pno and pr2.route_action = 'UNSEAL' and DATE_FORMAT(CONVERT_TZ(pr2.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day) and pr2.store_id = pr.store_id
        where
            pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
            and pi.`exhibition_weight`<=3000
            and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
            and pi.`exhibition_length` <=30
            and pi.`exhibition_width` <=30
            and pi.`exhibition_height` <=30
            and pr2.pno is not null
        GROUP BY 1
    )pr6 on pr6.`store_id`=ss.`id`
left join
    (
        select #实际集包
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际集包量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ( 'SEAL')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr7 on pr7.`store_id`=ss.`id`
group by 1,2,3,4
order by 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,v2.出勤收派员人数
    ,v2.出勤仓管人数
    ,v2.出勤主管人数
    ,pr.妥投量
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
    ,dc.应派量
    ,pr3.交接量
    ,concat(round(pr3.交接量/dc.应派量,4)*100,'%') 交接率
    ,pr4.应盘点量
    ,pr5.实际盘点量
    ,pr4.应盘点量- pr5.实际盘点量 未盘点量
    ,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
    ,pr6.应集包量
    ,pr7.实际集包量
    ,concat(round(pr7.实际集包量/pr6.应集包量,4)*100,'%') 集包率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
            and ss.state = 1
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
left join
    (
        select #出勤
            hi.`sys_store_id`
            ,count(distinct(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
            ,count(distinct(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
            ,count(distinct(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
        from `ph_bi`.`attendance_data_v2` v2
        left join `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
        where
            v2.`stat_date`=date_sub(curdate(),interval 1 day)
            and
                (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
        group by 1
    )v2 on v2.`sys_store_id`=ss.`id`
left join
    (
        select #妥投
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 妥投量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_CONFIRM')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr on pr.`store_id`=ss.`id`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            )pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') >= date_sub(curdate(),interval 1 day)
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`
left join
    (
        select #应派
            dc.`store_id`
            ,count(distinct(dc.`pno`)) 应派量
        from `ph_bi`.`dc_should_delivery_today` dc
        where
            dc.`stat_date`= date_sub(curdate(),interval 1 day)
        group by 1
    ) dc on dc.`store_id`=ss.`id`
left join
    (
        select #交接
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 交接量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr3 on pr3.`store_id`=ss.`id`
left join
    (
        select #应盘
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应盘点量
        from
            (
                select #最后一条有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`state`
                    ,pr.`routed_at`
                from
                    (
                        select
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`state`
                             ,pr.`routed_at`
                             ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                        from `ph_staging`.`parcel_route` pr
                        where
                            DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
            left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
            left join
                (
                    select #车货关联出港
                        pr.`pno`
                        ,pr.`store_id`
                        ,pr.`routed_at`
                    from `ph_staging`.`parcel_route` pr
                    where
                        pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
            and pi.state in (1,2,3,4,6)
        group by 1
    )pr4 on pr4.`store_id`=ss.`id`
left join
    (
        select #实际盘点
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际盘点量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        GROUP BY 1
    )pr5 on pr5.`store_id`=ss.`id`
left join
    (
        select #应集包
            pr.`store_id`
            ,count(distinct pr.`pno`) 应集包量
        from `ph_staging`.`parcel_route` pr
        left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
        left join ph_staging.parcel_route pr2 on pr2.pno = pr.pno and pr2.route_action = 'UNSEAL' and DATE_FORMAT(CONVERT_TZ(pr2.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day) and pr2.store_id = pr.store_id
        where
            pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            and pi.`exhibition_weight`<=3000
            and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
            and pi.`exhibition_length` <=30
            and pi.`exhibition_width` <=30
            and pi.`exhibition_height` <=30
            and pr2.pno is not null
        GROUP BY 1
    )pr6 on pr6.`store_id`=ss.`id`
left join
    (
        select #实际集包
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际集包量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ( 'SEAL')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr7 on pr7.`store_id`=ss.`id`
group by 1,2,3,4
order by 2;
;-- -. . -..- - / . -. - .-. -.--
select #实际集包
            pr.`store_id`
            ,count(distinctpr.`pno`) 实际集包量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ( 'SEAL')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select #实际集包
            pr.`store_id`
            ,count(distinct pr.`pno`) 实际集包量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ( 'SEAL')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    hub_name
   , to_date (van_arrive_phtime) AS '到港日期'
    ,SUM (hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (hub_should_seal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (hub_should_seal = 1  AND seal_phtime IS NOT NULL, 1, 0))/ SUM (hub_should_seal) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '应拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0))/ SUM (IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '应直接集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际直接集包包裹数'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0))/ SUM (IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'、
            , date_add (pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    )
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    hub_name
   , date (van_arrive_phtime) AS '到港日期'
    ,SUM (hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (hub_should_seal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (hub_should_seal = 1  AND seal_phtime IS NOT NULL, 1, 0))/ SUM (hub_should_seal) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '应拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0))/ SUM (IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '应直接集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际直接集包包裹数'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0))/ SUM (IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'、
            , date_add (pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    )
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    hub_name
    ,date(van_arrive_phtime) AS '到港日期'
    ,SUM(hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (hub_should_seal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (hub_should_seal = 1  AND seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '应拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '应直接集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际直接集包包裹数'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'、
            , date_add (pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    )
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    hub_name
    ,date(van_arrive_phtime) AS '到港日期'
    ,SUM(hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (hub_should_seal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (hub_should_seal = 1  AND seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '应拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '应直接集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际直接集包包裹数'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'、
            , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    )
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    hub_name
    ,date(van_arrive_phtime) AS '到港日期'
    ,SUM(hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (hub_should_seal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (hub_should_seal = 1  AND seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '应拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '应直接集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际直接集包包裹数'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
            , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    )
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
select date_sub(curdate(), 1);
;-- -. . -..- - / . -. - .-. -.--
select
    *
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = date_sub(curdate(), interval 1 day)
    where
        ph.parcel_discover_date = '{$date}';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) hour) time1
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = t.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) hour) time1
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = t.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) hour) time1
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
#     ,b.area
    ,a.hno
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select  substring_index('2-4','-',1);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,a.submit_store_id
#     ,b.area
    ,a.hno
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,a.submit_store_id
#     ,b.area
    ,a.hno
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,a.submit_store_id
#     ,b.area
    ,a.hno
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,a.submit_store_id
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,a.submit_store_id
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,b.area
#     ,a.hno
#     ,b.num
# from
#     (
#         select
#             ph.submit_store_name
#             ,ph.submit_store_id
#             ,a.unload_period
#             ,ph.hno
#         from ph_staging.parcel_headless ph
#         join
#             (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
#     ,b.area
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select * from ph_nbd.suspected_headless_parcel_detail_v1 sh where  sh.store_id = 'PH19280F01' and sh.arrival_date = '2023-04-23';
;-- -. . -..- - / . -. - .-. -.--
select * from ph_staging.parcel_headless ph where ph.parcel_discover_date = '2023-04-03' and ph.submit_store_id = 'PH19280F01';
;-- -. . -..- - / . -. - .-. -.--
select * from ph_nbd.suspected_headless_parcel_detail_v1 sh where  sh.store_id = 'PH19280F01' and sh.arrival_date = '2023-04-02';
;-- -. . -..- - / . -. - .-. -.--
select * from ph_staging.parcel_headless ph where ph.parcel_discover_date = '2023-04-02' and ph.submit_store_id = 'PH19280F01';
;-- -. . -..- - / . -. - .-. -.--
select * from ph_staging.parcel_headless ph where date(convert_tz(ph.created_at,'+00:00', '+08:00')) = '2023-04-02' and ph.submit_store_id = 'PH19280F01';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
# )
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
select * from ph_nbd.suspected_headless_parcel_detail_v1 sh where  sh.store_id = 'PH19280F01' and sh.arrival_date = '2023-04-03';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and ph.find_area_category regexp a.type;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category
            ,
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type regexp ph.find_area_category;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type regexp ph.find_area_category;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type regexp cast(ph.find_area_category as int);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-02'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-02', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-02', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-02'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
#     ,b.area
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
select * from ph_nbd.suspected_headless_parcel_detail_v1 sh where  sh.store_id = 'PH19280F01' and sh.arrival_date = '2023-03-29';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
#             ,a.type
#             ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
#             ,a.type
#             ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)

        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
where
     a.type like  concat('%',b.area, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,a.type
#             ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)

        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
where
     a.type like  concat('%',b.area, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,case
                when t.parcel_type = 0 then '1,2'
                when t.parcel_type = 1 then '2,3'
                when t.parcel_type = 2 then '3'
            end type
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3,4
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
where
     b.type like  concat('%',a.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,case
                when sh.parcel_type = 0 then '1,2'
                when sh.parcel_type = 1 then '2,3'
                when sh.parcel_type = 2 then '3'
            end type
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3,4
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
where
     b.type like  concat('%',a.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,case
                when sh.parcel_type = 0 then '1,2'
                when sh.parcel_type = 1 then '2,3'
                when sh.parcel_type = 2 then '3'
            end type

            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
where
     b.type like  concat('%',a.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like concat('%',ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period


            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,case
                        when t.parcel_type = 0 then '1'
                        when t.parcel_type = 1 then '2'
                        when t.parcel_type = 2 then '3'
                    end type
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like concat('%',ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period


            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-02'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-02', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-02', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-02'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-28'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-28'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-28'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-28'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
            and ph.state = 0
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-28'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
            and ph.state = 0
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
#             ,case  sh.parcel_type
#                 when 0 then 'A'
#                 when 1 then 'B'
#                 when 2 then 'C'
#             end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select arrival_date,unload_period,store_id,parcel_type,count(pno)AS headless_count
from ph_nbd.suspected_headless_parcel_detail_v1
where arrival_date = '2023-03-29'
and store_id = 'PH19280F01'
group by unload_period, parcel_type;
;-- -. . -..- - / . -. - .-. -.--
select
        fp.p_date 日期
        ,ss.name 网点
        ,ss.id 网点ID
        ,fp.view_num 访问人次
    #     ,fp.view_staff_num uv
        ,fp.match_num 点击匹配量
        ,fp.search_num 点击搜索量
        ,fp.sucess_num 成功匹配量
    from
        (
            select
                json_extract(ext_info,'$.organization_id') store_id
                ,fp.p_date
                ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
                ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
                ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
                ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
                ,count(if(json_unquote(json_extract(ext_info,'$.matchResult')) = 'true', fp.user_id, null)) sucess_num
            from dwm.dwd_ph_sls_pro_flash_point fp
            where
                fp.p_date >= '2023-03-01'
            group by 1,2
        ) fp
    left join ph_staging.sys_store ss on ss.id = fp.store_id
    where
        ss.category in (8,12);
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,ss3.name 揽收网点
    ,pr.next_store_name 揽收网点下一站
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id
left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
where
    pi.created_at >= convert_tz('2023-04-10', '+08:00', '+00:00')
    and pi.created_at < convert_tz('2023-04-10', '+08:00', '+00:00')
    and ss2.id = 'PH14160302'  -- 99hub
    and ss3.category = 14;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
    ,pi.pno
    ,ss3.name 揽收网点
    ,pr.next_store_name 揽收网点下一站
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id
left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
where
    pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
    and pi.created_at < convert_tz('2023-04-10', '+08:00', '+00:00')
    and ss2.id = 'PH14160302'  -- 99hub
    and ss3.category = 14;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
    ,pi.pno
    ,ss3.name 揽收网点
    ,pr.next_store_name 揽收网点下一站
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id -- 目的地hub
left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id -- 揽收网点
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
where
    pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
    and pi.created_at < convert_tz('2023-04-10', '+08:00', '+00:00')
    and ss2.id = 'PH14160302'  -- 99hub
    and ss3.category = 14;
;-- -. . -..- - / . -. - .-. -.--
select
    a.日期
    ,a.揽收网点
    ,count(if(a.next_store_id = 'PH14160302', a.pno, null)) 下一站99
    ,count(if(a.next_store_id != 'PH14160302', a.pno, null)) 下一站非99
from
    (
        select
            date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
            ,pi.pno
            ,ss3.name 揽收网点
            ,pr.next_store_name 揽收网点下一站
            ,pr.next_store_id
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
        left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id -- 目的地hub
        left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id -- 揽收网点
        left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
        where
            pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
            and pi.created_at < convert_tz('2023-04-10', '+08:00', '+00:00')
            and ss2.id = 'PH14160302'  -- 99hub
            and ss3.category = 14 -- PDC
            and pr.pno is not null
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.日期
    ,a.揽收网点
    ,count(distinct if(a.next_store_id = 'PH14160302', a.pno, null)) 下一站99
    ,count(distinct if(a.next_store_id != 'PH14160302', a.pno, null)) 下一站非99
from
    (
        select
            date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
            ,pi.pno
            ,ss3.name 揽收网点
            ,pr.next_store_name 揽收网点下一站
            ,pr.next_store_id
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
        left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id -- 目的地hub
        left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id -- 揽收网点
        left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
        where
            pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
            and pi.created_at < convert_tz('2023-04-10', '+08:00', '+00:00')
            and ss2.id = 'PH14160302'  -- 99hub
            and ss3.category = 14 -- PDC
            and pr.pno is not null
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.日期
    ,a.揽收网点
    ,count(distinct if(a.next_store_id = 'PH14160302', a.pno, null)) 下一站99
    ,count(distinct if(a.next_store_id != 'PH14160302', a.pno, null)) 下一站非99
from
    (
        select
            date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
            ,pi.pno
            ,ss3.name 揽收网点
            ,pr.next_store_name 揽收网点下一站
            ,pr.next_store_id
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
        left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id -- 目的地hub
        left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id -- 揽收网点
        left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
        where
            pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
            and pi.created_at < convert_tz('2023-04-11', '+08:00', '+00:00')
            and ss2.id = 'PH14160302'  -- 99hub
            and ss3.category = 14 -- PDC
            and pr.pno is not null
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.日期
    ,a.揽收网点
    ,count(distinct if(a.next_store_id = 'PH14160302', a.pno, null)) 下一站99
    ,count(distinct if(a.next_store_id != 'PH14160302', a.pno, null)) 下一站非99
from
    (
        select
            date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
            ,pi.pno
            ,ss3.name 揽收网点
            ,pr.next_store_name 揽收网点下一站
            ,pr.next_store_id
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
        left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id -- 目的地hub
        left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id -- 揽收网点
        left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
        where
            pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
            and pi.created_at < convert_tz('2023-04-12', '+08:00', '+00:00')
            and ss2.id = 'PH14160302'  -- 99hub
            and ss3.category = 14 -- PDC
            and pr.pno is not null
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
        ,case sh.parcel_type
            when 0 then '1,2'
            when 1 then '2,3'
            when 2 then '3'
        end type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,max(b.num) max_num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2

                    ,t.type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
            and ph.state = 0
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
        ,case sh.parcel_type
            when 0 then '1,2'
            when 1 then '2,3'
            when 2 then '3'
        end type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,max(b.num) max_num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2

                    ,t.type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
            and ph.state = 0
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    a.store_id
    ,date(a.van_arrive_phtime) AS '到港日期'
    ,SUM(a.hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (a.hub_should_seal = 1 AND a.seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (a.hub_should_seal = 1  AND a.seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,pss.store_id
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
            , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    ) a
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,v2.出勤收派员人数
    ,v2.出勤仓管人数
    ,v2.出勤主管人数
    ,pr.妥投量
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
    ,dc.应派量
    ,pr3.交接量
    ,concat(round(pr3.交接量/dc.应派量,4)*100,'%') 交接率
    ,pr4.应盘点量
    ,pr5.实际盘点量
    ,pr4.应盘点量- pr5.实际盘点量 未盘点量
    ,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
    ,seal.应该集包包裹量
    ,seal.应集包且实际集包的总包裹量 实际集包量
    ,seal.集包率 集包率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
left join
    (
        select #出勤
            hi.`sys_store_id`
            ,count(distinct(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
            ,count(distinct(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
            ,count(distinct(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
        from `ph_bi`.`attendance_data_v2` v2
        left join `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
        where
            v2.`stat_date`=date_sub(curdate(),interval 1 day)
            and
                (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
        group by 1
    )v2 on v2.`sys_store_id`=ss.`id`
left join
    (
        select #妥投
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 妥投量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_CONFIRM')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr on pr.`store_id`=ss.`id`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            )pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') >= date_sub(curdate(),interval 1 day)
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`
left join
    (
        select #应派
            dc.`store_id`
            ,count(distinct(dc.`pno`)) 应派量
        from `ph_bi`.`dc_should_delivery_today` dc
        where
            dc.`stat_date`= date_sub(curdate(),interval 1 day)
        group by 1
    ) dc on dc.`store_id`=ss.`id`
left join
    (
        select #交接
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 交接量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr3 on pr3.`store_id`=ss.`id`
left join
    (
        select #应盘
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应盘点量
        from
            (
                select #最后一条有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`state`
                    ,pr.`routed_at`
                from
                    (
                        select
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`state`
                             ,pr.`routed_at`
                             ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                        from `ph_staging`.`parcel_route` pr
                        where
                            DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
            left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
            left join
                (
                    select #车货关联出港
                        pr.`pno`
                        ,pr.`store_id`
                        ,pr.`routed_at`
                    from `ph_staging`.`parcel_route` pr
                    where
                        pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
            and pi.state in (1,2,3,4,6)
        group by 1
    )pr4 on pr4.`store_id`=ss.`id`
left join
    (
        select #实际盘点
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际盘点量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        GROUP BY 1
    )pr5 on pr5.`store_id`=ss.`id`
left join
    (
        SELECT
            a.store_id
            ,date(a.van_arrive_phtime) AS '到港日期'
            ,SUM(a.hub_should_seal) AS '应该集包包裹量'
            ,SUM(IF (a.hub_should_seal = 1 AND a.seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
            ,SUM(IF (a.hub_should_seal = 1  AND a.seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
        FROM
            (
                SELECT
                    pi.pno
                    , pss.store_name AS 'hub_name'
                    ,pss.store_id
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                            8 HOUR) AS 'van_arrive_phtime'
                    , pss.arrival_pack_no
                    , pack.es_unseal_store_name
                    ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
            -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                         AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
                    , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
                FROM ph_staging.parcel_info pi
                JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
                    AND pi.pno = pss.pno
                    AND pss.store_category IN (8, 12)
                    AND pss.store_name != '66 BAG_HUB_Maynila'
                    AND pss.store_name NOT REGEXP '^Air|^SEA'
                LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
                WHERE
                    1 = 1
                    AND pi.state < 9
                    AND pi.returned = 0
            ) a
        GROUP BY 1, 2
        ORDER BY 1, 2
    ) seal on seal.store_id = ss.id
group by 1,2,3,4
order by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from ph_bi.abnormal_customer_complaint acc
where
    acc.work_id is not null
limit 20;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,case
        when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
        when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
        when hsi.`state`=2 then '离职'
        when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') created_at
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
        ,ROW_NUMBER ()over(partition by hsi.staff_info_id order by mw.created_at ) rn
        ,count(mw.id) over (partition by hsi.staff_info_id) ct
    from
    (
             select
                mw.staff_info_id
            from ph_backyard.message_warning mw
            where
                mw.type_code = 'warning_27'
                and mw.operator_id = 87166
#             and mw.created_at >=convert_tz('2023-04-13','+08:00','+00:00')
            group by 1
    )ws
    join ph_bi.hr_staff_info hsi  on ws.staff_info_id=hsi.staff_info_id
    left join  ph_backyard.message_warning mw on hsi.staff_info_id =mw.staff_info_id and  mw.is_delete =0
    left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
    left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
    left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
    where
        hsi.state <> 2
)

select 
    t.staff_info_id 员工id
    ,t. 在职状态
    ,t.所属网点
    ,t.大区
    ,t.片区
    ,t.ct 警告次数
    ,t.created_at 第一次警告信时间
    ,t.警告原因 第一次警告原因
    ,t.警告类型 第一次警告类型
    ,t2.created_at 第二次警告信时间
    ,t2.警告原因 第二次警告原因
    ,t2.警告类型 第二次警告类型
    ,t3.created_at 第三次警告信时间
    ,t3.警告原因 第三次警告原因
    ,t3.警告类型 第三次警告类型
    ,t4.created_at 第四次警告信时间
    ,t4.警告原因 第四次警告原因
    ,t4.警告类型 第四次警告类型
    ,t5.created_at 第五次警告信时间
    ,t5.警告原因 第五次警告原因
    ,t5.警告类型 第五次警告类型
from t 
left join t t2 on t.staff_info_id=t2.staff_info_id and t2.rn=2
left join t t3 on t.staff_info_id=t3.staff_info_id and t3.rn=3
left join t t4 on t.staff_info_id=t4.staff_info_id and t4.rn=4
left join t t5 on t.staff_info_id=t5.staff_info_id and t5.rn=5
where
    t.rn=1;
;-- -. . -..- - / . -. - .-. -.--
select DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
;-- -. . -..- - / . -. - .-. -.--
select  DATE_ADD(curdate(),interval -day(curdate())+1 day);
;-- -. . -..- - / . -. - .-. -.--
select
    swm.date_at
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
        when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
        when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
        when hsi.`state`=2 then '离职'
        when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join  ph_backyard.message_warning mw on hsi.staff_info_id =mw.staff_info_id and  mw.is_delete =0
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
    mw.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    and mw.type_code = 'warning_27';
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join  ph_backyard.message_warning mw on hsi.staff_info_id =mw.staff_info_id and  mw.is_delete =0
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
    mw.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    and mw.type_code = 'warning_27';
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
    mw.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    and mw.type_code = 'warning_27'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
    mw.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    and mw.type_code = 'warning_27'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,swm.date_at 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_backyard.staff_warning_message swm on swm.id = mw.staff_warning_message_id
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
    swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    and mw.type_code = 'warning_27'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
SELECT wo.`order_no` `工单编号`,
case wo.status
     when 1 then '未阅读'
     when 2 then '已经阅读'
     when 3 then '已回复'
     when 4 then '已关闭'
     end '工单状态',
pi.`client_id`  '客户ID',
wo.`pnos` '运单号',
case wo.order_type
          when 1 then '查找运单'
          when 2 then '加快处理'
          when 3 then '调查员工'
          when 4 then '其他'
          when 5 then '网点信息维护提醒'
          when 6 then '培训指导'
          when 7 then '异常业务询问'
          when 8 then '包裹丢失'
          when 9 then '包裹破损'
          when 10 then '货物短少'
          when 11 then '催单'
          when 12 then '有发无到'
          when 13 then '上报包裹不在集包里'
          when 16 then '漏揽收'
          when 50 then '虚假撤销'
          when 17 then '已签收未收到'
          when 18 then '客户投诉'
          when 19 then '修改包裹信息'
          when 20 then '修改 COD 金额'
          when 21 then '解锁包裹'
          when 22 then '申请索赔'
          when 23 then 'MS 问题反馈'
          when 24 then 'FBI 问题反馈'
          when 25 then 'KA System 问题反馈'
          when 26 then 'App 问题反馈'
          when 27 then 'KIT 问题反馈'
          when 28 then 'Backyard 问题反馈'
          when 29 then 'BS/FH 问题反馈'
          when 30 then '系统建议'
          when 31 then '申诉罚款'
          else wo.order_type
          end  '工单类型',
wo.`title` `工单标题`,
wo.`created_at` `工单创建时长`,
wor.`工单回复时间` `工单回复时间`,
wo.`created_staff_info_id` `发起人`,
wo.`closed_at` `工单关闭时间`,
wor.staff_info_id `回复人`,
ss1.name `创建网点名称`,
case
when ss1.`category` in (1,2,10,13) then 'sp'
              when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`created_store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`created_store_id`= '12' then 'QA&QC'
              when wo.`created_store_id`= '18' then 'Flash Home客服中心'
              when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`created_store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `创建网点/部门 `,
ss.name `受理网点名称`,
case when ss.`category` in (1,2,10,13) then 'sp'
              when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`store_id`= '12' then 'QA&QC'
              when wo.`store_id`= '18' then 'Flash Home客服中心'
              when wo.`store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `受理网点/部门 `,
pi. `last_cn_route_action` `最后一步有效路由`,
pi.last_route_time `操作时间`,
pi.last_store_name `操作网点`,
pi.last_staff_info_id `操作人员`

from `ph_bi`.`work_order` wo
left join dwm.dwd_ex_ph_parcel_details pi
on wo.`pnos` =pi.`pno` and  pick_date>=date_sub(curdate(),interval 2 month)
left join
    (select order_id,staff_info_id ,max(created_at) `工单回复时间`
     from `ph_bi`.`work_order_reply`
     group by 1,2) wor
on  wor.`order_id`=wo.`id`

left join   `ph_bi`.`sys_store`  ss on ss.`id` =wo.`store_id`
left join   `ph_bi`.`sys_store`  ss1 on ss1.`id` =wo.`created_store_id`
where month(wo.`created_at`) =month(CURDATE());
;-- -. . -..- - / . -. - .-. -.--
SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,v2.出勤收派员人数
    ,v2.出勤仓管人数
    ,v2.出勤主管人数
    ,pr.妥投量
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
    ,dc.应派量
    ,pr3.交接量
    ,concat(round(pr3.交接量/dc.应派量,4)*100,'%') 交接率
    ,pr4.应盘点量
    ,pr5.实际盘点量
    ,pr4.应盘点量- pr5.实际盘点量 未盘点量
    ,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
    ,seal.应该集包包裹量
    ,seal.应集包且实际集包的总包裹量 实际集包量
    ,seal.集包率 集包率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
left join
    (
        select #出勤
            hi.`sys_store_id`
            ,count(distinct(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
            ,count(distinct(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
            ,count(distinct(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
        from `ph_bi`.`attendance_data_v2` v2
        left join `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
        join ph_staging.sys_store ss on ss.id = hi.sys_store_id and ss.category in (8,12)
        where
            v2.`stat_date`=date_sub(curdate(),interval 1 day)
            and
                (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
        group by 1
    )v2 on v2.`sys_store_id`=ss.`id`
left join
    (
        select #妥投
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 妥投量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('DELIVERY_CONFIRM')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr on pr.`store_id`=ss.`id`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            )pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') >= date_sub(curdate(),interval 1 day)
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`
left join
    (
        select #应派
            dc.`store_id`
            ,count(distinct(dc.`pno`)) 应派量
        from `ph_bi`.`dc_should_delivery_today` dc
        join ph_staging.sys_store ss on ss.id = dc.store_id and ss.category in (8,12)
        where
            dc.`stat_date`= date_sub(curdate(),interval 1 day)
        group by 1
    ) dc on dc.`store_id`=ss.`id`
left join
    (
        select #交接
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 交接量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr3 on pr3.`store_id`=ss.`id`
left join
    (
        select #应盘
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应盘点量
        from
            (
                select #最后一条有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`state`
                    ,pr.`routed_at`
                from
                    (
                        select
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`state`
                             ,pr.`routed_at`
                             ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                        from `ph_staging`.`parcel_route` pr
                        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                        where
                            DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
            left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
            left join
                (
                    select #车货关联出港
                        pr.`pno`
                        ,pr.`store_id`
                        ,pr.`routed_at`
                    from `ph_staging`.`parcel_route` pr
                    join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                    where
                        pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
            and pi.state in (1,2,3,4,6)
        group by 1
    )pr4 on pr4.`store_id`=ss.`id`
left join
    (
        select #实际盘点
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际盘点量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        GROUP BY 1
    )pr5 on pr5.`store_id`=ss.`id`
left join
    (
        SELECT
            a.store_id
            ,date(a.van_arrive_phtime) AS '到港日期'
            ,SUM(a.hub_should_seal) AS '应该集包包裹量'
            ,SUM(IF (a.hub_should_seal = 1 AND a.seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
            ,SUM(IF (a.hub_should_seal = 1  AND a.seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
        FROM
            (
                SELECT
                    pi.pno
                    , pss.store_name AS 'hub_name'
                    ,pss.store_id
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                            8 HOUR) AS 'van_arrive_phtime'
                    , pss.arrival_pack_no
                    , pack.es_unseal_store_name
                    ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
            -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                         AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
                    , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
                FROM ph_staging.parcel_info pi
                JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
                    AND pi.pno = pss.pno
                    AND pss.store_category IN (8, 12)
                    AND pss.store_name != '66 BAG_HUB_Maynila'
                    AND pss.store_name NOT REGEXP '^Air|^SEA'
                LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
                WHERE
                    1 = 1
                    AND pi.state < 9
                    AND pi.returned = 0
            ) a
        GROUP BY 1, 2
        ORDER BY 1, 2
    ) seal on seal.store_id = ss.id
group by 1,2,3,4
order by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    mw.date_ats
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    mw.date_ats
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and mw.date_ats >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    swm.date_at
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    swm.date_at
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct if(swm.hr_fix_status = 0, swm.id, null)) 未处理量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
SELECT wo.`order_no` `工单编号`,
case wo.status
     when 1 then '未阅读'
     when 2 then '已经阅读'
     when 3 then '已回复'
     when 4 then '已关闭'
     end '工单状态',
pi.`client_id`  '客户ID',
wo.`pnos` '运单号',
case wo.order_type
          when 1 then '查找运单'
          when 2 then '加快处理'
          when 3 then '调查员工'
          when 4 then '其他'
          when 5 then '网点信息维护提醒'
          when 6 then '培训指导'
          when 7 then '异常业务询问'
          when 8 then '包裹丢失'
          when 9 then '包裹破损'
          when 10 then '货物短少'
          when 11 then '催单'
          when 12 then '有发无到'
          when 13 then '上报包裹不在集包里'
          when 16 then '漏揽收'
          when 50 then '虚假撤销'
          when 17 then '已签收未收到'
          when 18 then '客户投诉'
          when 19 then '修改包裹信息'
          when 20 then '修改 COD 金额'
          when 21 then '解锁包裹'
          when 22 then '申请索赔'
          when 23 then 'MS 问题反馈'
          when 24 then 'FBI 问题反馈'
          when 25 then 'KA System 问题反馈'
          when 26 then 'App 问题反馈'
          when 27 then 'KIT 问题反馈'
          when 28 then 'Backyard 问题反馈'
          when 29 then 'BS/FH 问题反馈'
          when 30 then '系统建议'
          when 31 then '申诉罚款'
          else wo.order_type
          end  '工单类型',
wo.`title` `工单标题`,
wo.`created_at` `工单创建时长`,
wor.`工单回复时间` `工单回复时间`,
wo.`created_staff_info_id` `发起人`,
wo.`closed_at` `工单关闭时间`,
wor.staff_info_id `回复人`,
ss1.name `创建网点名称`,
case
when ss1.`category` in (1,2,10,13) then 'sp'
              when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`created_store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`created_store_id`= '12' then 'QA&QC'
              when wo.`created_store_id`= '18' then 'Flash Home客服中心'
              when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`created_store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `创建网点/部门 `,
ss.name `受理网点名称`,
case when ss.`category` in (1,2,10,13) then 'sp'
              when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`store_id`= '12' then 'QA&QC'
              when wo.`store_id`= '18' then 'Flash Home客服中心'
              when wo.`store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `受理网点/部门 `,
pi. `last_cn_route_action` `最后一步有效路由`,
pi.last_route_time `操作时间`,
pi.last_store_name `操作网点`,
pi.last_staff_info_id `操作人员`

from `ph_bi`.`work_order` wo
left join dwm.dwd_ex_ph_parcel_details pi
on wo.`pnos` =pi.`pno` and  pick_date>=date_sub(curdate(),interval 2 month)
left join
    (select order_id,staff_info_id ,max(created_at) `工单回复时间`
     from `ph_bi`.`work_order_reply`
     group by 1,2) wor
on  wor.`order_id`=wo.`id`

left join   `ph_bi`.`sys_store`  ss on ss.`id` =wo.`store_id`
left join   `ph_bi`.`sys_store`  ss1 on ss1.`id` =wo.`created_store_id`
where wo.`created_at` >= date_add(curdate(),interval -day(curdate()) + 1 day);
;-- -. . -..- - / . -. - .-. -.--
SELECT wo.`order_no` `工单编号`,
case wo.status
     when 1 then '未阅读'
     when 2 then '已经阅读'
     when 3 then '已回复'
     when 4 then '已关闭'
     end '工单状态',
pi.`client_id`  '客户ID',
wo.`pnos` '运单号',
case wo.order_type
          when 1 then '查找运单'
          when 2 then '加快处理'
          when 3 then '调查员工'
          when 4 then '其他'
          when 5 then '网点信息维护提醒'
          when 6 then '培训指导'
          when 7 then '异常业务询问'
          when 8 then '包裹丢失'
          when 9 then '包裹破损'
          when 10 then '货物短少'
          when 11 then '催单'
          when 12 then '有发无到'
          when 13 then '上报包裹不在集包里'
          when 16 then '漏揽收'
          when 50 then '虚假撤销'
          when 17 then '已签收未收到'
          when 18 then '客户投诉'
          when 19 then '修改包裹信息'
          when 20 then '修改 COD 金额'
          when 21 then '解锁包裹'
          when 22 then '申请索赔'
          when 23 then 'MS 问题反馈'
          when 24 then 'FBI 问题反馈'
          when 25 then 'KA System 问题反馈'
          when 26 then 'App 问题反馈'
          when 27 then 'KIT 问题反馈'
          when 28 then 'Backyard 问题反馈'
          when 29 then 'BS/FH 问题反馈'
          when 30 then '系统建议'
          when 31 then '申诉罚款'
          else wo.order_type
          end  '工单类型',
wo.`title` `工单标题`,
wo.`created_at` `工单创建时长`,
wor.`工单回复时间` `工单回复时间`,
wo.`created_staff_info_id` `发起人`,
wo.`closed_at` `工单关闭时间`,
wor.staff_info_id `回复人`,
ss1.name `创建网点名称`,
case
when ss1.`category` in (1,2,10,13) then 'sp'
              when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`created_store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`created_store_id`= '12' then 'QA&QC'
              when wo.`created_store_id`= '18' then 'Flash Home客服中心'
              when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`created_store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `创建网点/部门 `,
ss.name `受理网点名称`,
case when ss.`category` in (1,2,10,13) then 'sp'
              when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`store_id`= '12' then 'QA&QC'
              when wo.`store_id`= '18' then 'Flash Home客服中心'
              when wo.`store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `受理网点/部门 `,
pi. `last_cn_route_action` `最后一步有效路由`,
pi.last_route_time `操作时间`,
pi.last_store_name `操作网点`,
pi.last_staff_info_id `操作人员`

from `ph_bi`.`work_order` wo
left join dwm.dwd_ex_ph_parcel_details pi
on wo.`pnos` =pi.`pno` and  pick_date>=date_sub(curdate(),interval 2 month)
left join
    (select order_id,staff_info_id ,max(created_at) `工单回复时间`
     from `ph_bi`.`work_order_reply`
     group by 1,2) wor
on  wor.`order_id`=wo.`id`

left join   `ph_bi`.`sys_store`  ss on ss.`id` =wo.`store_id`
left join   `ph_bi`.`sys_store`  ss1 on ss1.`id` =wo.`created_store_id`
where wo.`created_at` >= date_sub(curdate() , interval 31 day);
;-- -. . -..- - / . -. - .-. -.--
select
    date(swm.created_at) 录入日期
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct if(swm.hr_fix_status = 0, swm.id, null)) 未处理量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(swm.created_at) 录入日期
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct if(swm.hr_fix_status = 0, swm.id, null)) HRBP未处理量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,swm.date_at 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_backyard.staff_warning_message swm on swm.id = mw.staff_warning_message_id
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-03-01'
    and mw.created_at < '2023-04-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-03-01'
    and mw.created_at < '2023-04-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,case
        when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
        when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
        when hsi.`state`=2 then '离职'
        when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') created_at
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
        ,ROW_NUMBER ()over(partition by hsi.staff_info_id order by mw.created_at ) rn
        ,count(mw.id) over (partition by hsi.staff_info_id) ct
    from
    (
             select
                mw.staff_info_id
            from ph_backyard.message_warning mw
            where
                mw.type_code = 'warning_27'
                and mw.operator_id = 87166
                and mw.is_delete = 0
#             and mw.created_at >=convert_tz('2023-04-13','+08:00','+00:00')
            group by 1
    )ws
    join ph_bi.hr_staff_info hsi  on ws.staff_info_id=hsi.staff_info_id
    left join  ph_backyard.message_warning mw on hsi.staff_info_id =mw.staff_info_id and  mw.is_delete =0
    left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
    left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
    left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
    where
        hsi.state <> 2
)

select 
    t.staff_info_id 员工id
    ,t. 在职状态
    ,t.所属网点
    ,t.大区
    ,t.片区
    ,t.ct 警告次数
    ,t.created_at 第一次警告信时间
    ,t.警告原因 第一次警告原因
    ,t.警告类型 第一次警告类型
    ,t2.created_at 第二次警告信时间
    ,t2.警告原因 第二次警告原因
    ,t2.警告类型 第二次警告类型
    ,t3.created_at 第三次警告信时间
    ,t3.警告原因 第三次警告原因
    ,t3.警告类型 第三次警告类型
    ,t4.created_at 第四次警告信时间
    ,t4.警告原因 第四次警告原因
    ,t4.警告类型 第四次警告类型
    ,t5.created_at 第五次警告信时间
    ,t5.警告原因 第五次警告原因
    ,t5.警告类型 第五次警告类型
from t 
left join t t2 on t.staff_info_id=t2.staff_info_id and t2.rn=2
left join t t3 on t.staff_info_id=t3.staff_info_id and t3.rn=3
left join t t4 on t.staff_info_id=t4.staff_info_id and t4.rn=4
left join t t5 on t.staff_info_id=t5.staff_info_id and t5.rn=5
where
    t.rn=1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(swm.created_at) 录入日期
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct if(swm.hr_fix_status = 0, swm.id, null)) HRBP未处理量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
    and mw.type_code = 'warning_27'
#     mw.created_at >= '2023-03-01'
#     and mw.created_at < '2023-04-01'
    and mw.is_delete = 0;