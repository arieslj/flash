select
    case  a.diff_marker_category
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
    ,a.类型
    ,a.疑难件创建时间段
    ,a.处理时间
    ,a.单量
    ,b.avg_deal_h 平均处理时长_hour
from
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 1 then '1小时内'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 >= 1 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 2 then '1-2小时'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 2 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 24 then '2小时-1天'
                when timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 > 24 and timestampdiff(second, di.created_at, cdt.first_operated_at)/3600 < 72 then '1-3天'
                else  '3天以上'
            end 处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
        group by 1,2,3,4

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,case
                when cdt.negotiation_result_category is not null  and cdt.updated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') then '12点前处理完成'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.updated_at < concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 16:00:00') then '超时12小时以内'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 16:00:00') and cdt.updated_at < concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  1 day), ' 16:00:00') then '超时12-36小时内'
                when cdt.negotiation_result_category is not null  and cdt.updated_at >= concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  1 day), ' 16:00:00') and cdt.updated_at < concat(date_add(date(convert_tz(di.created_at, '+00:00','+08:00')), interval  2 day), ' 04:00:00') then '超时36-48小时'
#                 when cdt.first_operated_at > concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00') and cdt.first_operated_at < date_add(concat(date(convert_tz(di.created_at, '+00:00','+08:00')), ' 04:00:00'), interval 2 day) then '0-2天内'
                else '超时2天以上+未处理'
            end 处理时间
#             ,convert_tz(di.created_at, '+00:00', '+08:00') 创建时间
#             ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00') 第一次处理时间
            ,count(di.id) 单量
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
        group by 1,2,3,4
    ) a
left join
    (
        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.updated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10
            and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16
            and cdt.negotiation_result_category is not null
        group by 1,2

        union all

        select
            di.diff_marker_category
            ,if(ss.category = 6, 'FH', '网点') 类型
            ,if(hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 10 and hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 16, '10-16', '16点-次日10点') 疑难件创建时间段
            ,sum(timestampdiff(second , di.created_at, cdt.updated_at)/3600)/count(di.id) avg_deal_h
        from ph_staging.diff_info di
        left join ph_staging.parcel_info pi on di.pno = pi.pno
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and
            (hour(convert_tz(di.created_at, '+00:00', '+08:00')) < 10 or hour(convert_tz(di.created_at, '+00:00', '+08:00')) >= 16)
            and cdt.negotiation_result_category is not null
        group by 1,2

    ) b on a.diff_marker_category = b.diff_marker_category and a.疑难件创建时间段 = b.疑难件创建时间段 and a.类型 = b.类型

;


select
    case  di.diff_marker_category
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
    ,case cdt. negotiation_result_category
        when 1 then '赔偿'
        when 2 then '关闭订单(不赔偿不退货)'
        when 3 then '退货'
        when 4 then  '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK'
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
    end AS 协商结果
    ,if(ss.category = 6, 'FH', '网点') 类型
    ,count(di.id) 单量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.created_at >= '2023-05-31 16:00:00'
    and di.created_at < '2023-06-19 16:00:00'
    and bc.client_id is null  -- ka&小c
    and cdt.negotiation_result_category is not null
group by 1,2,3

;


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
    end 疑难原因
    ,count(if(a.change_phone_num > 0, id, null)) 修改电话量
    ,count(if(a.change_address_num > 0, id, null)) 修改地址量
    ,count(if(a.change_address_num > 0 and a.change_phone_num > 0, id, null)) 修改电话和地址量
    ,count(if(a.change_address_num = 0 and a.change_phone_num = 0, id, null)) 未修改电话和地址量
from
    (
        select
            di.pno
            ,di.diff_marker_category
            ,di.id
            ,date(convert_tz(cdt.last_operated_at, '+00:00', '+08:00')) deal_date
            ,pcd.field_name
            ,count(if(pcd.field_name in ('dst_phone', 'dst_home_phone'), di.id, null)) change_phone_num
            ,count(if(pcd.field_name in ('dst_city_code', 'dst_detail_address', 'dst_district_code', 'dst_province_code'), di.id, null)) change_address_num
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        left join ph_staging.parcel_change_detail pcd on pcd.pno = di.pno and pcd.created_at > cdt.last_operated_at
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null  -- ka&小c
            and cdt.negotiation_result_category = 5
        group by 1,2,3,4
    ) a
group by 1

;
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
    end 疑难原因
    ,count(distinct if(a.sub_num = 2, a.pno, null)) 提交2次_包裹量
    ,count(distinct if(a.sub_num = 3, a.pno, null)) 提交3次_包裹量
    ,count(distinct if(a.sub_num = 4, a.pno, null)) 提交4次_包裹量
    ,count(distinct if(a.sub_num = 5, a.pno, null)) 提交5次_包裹量
    ,count(distinct if(a.sub_num > 5, a.pno, null)) 提交5次以上_包裹量
from
    (
        select
            di.pno
            ,di.diff_marker_category
            ,count(di.id) sub_num
        from ph_staging.diff_info di
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
        where
            di.created_at >= '2023-05-31 16:00:00'
            and di.created_at < '2023-06-19 16:00:00'
            and bc.client_id is null
        group by 1,2
    ) a
where
    a.sub_num >= 2
group by 1

;

select
    di.pno
    ,count(di.id) sub_num
from ph_staging.diff_info di
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.created_at >= '2023-05-31 16:00:00'
    and di.created_at < '2023-06-19 16:00:00'
    and bc.client_id is null
group by 1
having count(di.id) >= 3
;

select
    case
        when di.updated_at >= '2023-05-31 16:00:00' and di.updated_at < '2023-06-07 16:00:00' then '0601-0607'
        when di.updated_at >= '2023-06-07 16:00:00' and di.updated_at < '2023-06-14 16:00:00' then '0608-0614'
    end 周
    ,case ss.category
      when 1 then 'SP'
      when 2 then 'DC'
      when 4 then 'SHOP'
      when 5 then 'SHOP'
      when 6 then 'FH'
      when 7 then 'SHOP'
      when 8 then 'Hub'
      when 9 then 'Onsite'
      when 10 then 'BDC'
      when 11 then 'fulfillment'
      when 12 then 'B-HUB'
      when 13 then 'CDC'
      when 14 then 'PDC'
    end 网点类型
    ,ss.name 网点
    ,count(di.id) 处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-14 16:00:00'
    and bc.client_id is null
    and di.state = 1
group by 1,2,3
order by 1,2,3
;

select
    ss.name 网点
    ,if(ss.category = 6, 'FH', '网点') 类型
    ,count(di.id)/count(distinct date(convert_tz(di.updated_at, '+00:00', '+08:00'))) 日均处理量
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on di.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
where
    di.state = 1
    and di.updated_at >= '2023-05-31 16:00:00'
    and di.updated_at < '2023-06-01 16:00:00'
    and bc.client_id is null
group by 1,2
order by 3 desc


;
select
    a.CN_element
    ,count(if(a.rk1 = 1 and a.state = 5, a.pno, null )) 第一次协商为继续派送后妥投
    ,count(if(a.rk1 = 2 and a.state = 5, a.pno, null )) 第二次协商为继续派送后妥投
    ,count(if(a.rk1 = 3 and a.state = 5, a.pno, null )) 第三次协商为继续派送后妥投
    ,count(if(a.state != 5, a.pno, null))  '进入问题件，协商为继续派送，最终未妥投'
from
    (

        select
            a.pno
            ,a.CN_element
            ,b.rk1
            ,a.state
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            di.pno
                            ,ddd.CN_element
                            ,pi.state
                            ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                        from ph_staging.diff_info di
                        left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
                        left join ph_staging.parcel_info pi on di.pno = pi.pno
                        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                        left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
                        where
                            di.created_at >= '2023-05-31 16:00:00'
                            and di.created_at < '2023-06-19 16:00:00'
                            and bc.client_id is null  -- ka&小c
                            and cdt.negotiation_result_category in (5,6)
                    ) a1
                where
                    a1.rk = 1
            ) a
        left join
            (
                select
                    di.pno
                    ,row_number() over (partition by di.pno order by cdt.updated_at) rk1
                    ,row_number() over (partition by di.pno order by cdt.updated_at desc) rk2
                from ph_staging.diff_info di
                left join ph_staging.parcel_info pi on di.pno = pi.pno
                left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
                join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
                where
                    di.created_at >= '2023-05-31 16:00:00'
                    and di.created_at < '2023-06-19 16:00:00'
                    and bc.client_id is null  -- ka&小c
                    and cdt.negotiation_result_category in (5,6)
            ) b on b.pno = a.pno and b.rk2 = 1
    ) a
group by 1