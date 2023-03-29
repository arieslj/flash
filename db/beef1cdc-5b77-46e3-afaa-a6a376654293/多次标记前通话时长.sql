with ma as
(
    select
        td.pno
        ,td.staff_info_id
        ,tdm.*
        ,row_number() over (partition by td.pno,td.staff_info_id order by tdm.created_at) rn
    from
        (
            select
                td.*
            from
                (
                     select
                        td.id
                        ,td.pno
                        ,td.staff_info_id
                    from fle_dwd.dwd_fle_ticket_delivery_di td
                    where
                        td.p_date >= '2023-01-01'
                ) td
            join
                (
                    select
                        *
                    from test.pno0337 t
                ) a on a.pno = td.pno and a.staff = td.staff_info_id
        ) td
    left join
        (
            select
                *
            from fle_dwd.dwd_fle_ticket_delivery_marker_di tdm
            where
                tdm.p_date >= '2023-01-01'
        ) tdm on tdm.delivery_id = td.id
)
, ph as
(
    select
        pho.*
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.extra_value
                ,pr.staff_info_id
            from fle_dwd.dwd_rot_parcel_route_di pr
            where
                pr.p_date >= '2023-01-01'
                and pr.route_action in ('PHONE')
        ) pho
    join
        (
            select
                *
            from test.pno0337 t
        ) b on b.pno = pho.pno and b.staff = pho.staff_info_id
)
select
    a.*
    ,js.ma_count `标记几次`
    ,fir.routed_at `第一次标记时间`
    ,case cast(fir.marker_id as int)
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
        when 53 then 'lazada仓库拒收'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end `第一次派件标记`
    ,get_json_object(fir.extra_value, '$.callDuration') `第一次标记前通话时长`
    ,sec.routed_at `第二次标记时间`
    ,case cast(sec.marker_id as int)
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
        when 53 then 'lazada仓库拒收'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end `第二次派件标记`
    ,get_json_object(sec.extra_value, '$.callDuration') `第二次标记前通话时长`
    ,thr.routed_at `第三次标记时间`
    ,case cast(thr.marker_id as int)
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
        when 53 then 'lazada仓库拒收'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end `第三次派件标记`
    ,get_json_object(thr.extra_value, '$.callDuration') `第三次标记前通话时长`
    ,fou.routed_at `第四次标记时间`
    ,case cast(fou.marker_id as int)
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
        when 53 then 'lazada仓库拒收'
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
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end `第四次派件标记`
    ,get_json_object(fou.extra_value, '$.callDuration') `第四次标记前通话时长`
    ,case pr.route_action
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
    end as `最后操作路由`
from
    (
         select
                *
         from test.pno0337 t
    ) a
left join
    (
        select
            ma.pno
            ,ma.staff_info_id
            ,count(ma.id) ma_count
        from ma
        group by 1,2
    ) js on js.pno = a.pno and js.staff_info_id = a.staff
left join
    (
        select
            ph1.*
        from
            (
                select
                    ph.*
                    ,ma.marker_id
                    ,ma.staff_info_id mark_staff
                    ,ma.desired_at
                    ,ma.created_at
                    ,ma.rejection_category
                    ,ma.rejection_remark
                    ,row_number() over (partition by ma.pno order by ph.routed_at desc) rn
                from ma
                left join ph on ph.pno = ma.pno and ph.staff_info_id = ma.staff_info_id
                where
                    ma.rn = 1
                    and ph.routed_at < ma.created_at
            ) ph1
        where
            ph1.rn = 1
    ) fir on fir.pno = a.pno and fir.mark_staff = a.staff
left join
    (
        select
            ph2.*
        from
            (
                select
                    ph.*
                    ,ma.marker_id
                    ,ma.desired_at
                    ,ma.staff_info_id mark_staff
                    ,ma.created_at
                    ,ma.rejection_category
                    ,ma.rejection_remark
                    ,row_number() over (partition by ma.pno order by ph.routed_at desc) rn
                from ma
                left join ma m1 on m1.pno = ma.pno and m1.staff_info_id = ma.staff_info_id and m1.rn = 1
                left join ph on ph.pno = ma.pno and ph.staff_info_id = ma.staff_info_id
                where
                    ma.rn =  2
                    and ph.routed_at < ma.created_at
                    and ph.routed_at > m1.created_at
            ) ph2
        where
            ph2.rn = 1
    ) sec on sec.pno = a.pno and sec.mark_staff = a.staff
left join
    (
        select
            ph3.*
        from
            (
                select
                    ph.*
                    ,ma.marker_id
                    ,ma.desired_at
                    ,ma.created_at
                    ,ma.staff_info_id mark_staff
                    ,ma.rejection_category
                    ,ma.rejection_remark
                    ,row_number() over (partition by ma.pno order by ph.routed_at desc) rn
                from ma
                left join ma m2 on m2.pno = ma.pno and m2.staff_info_id = ma.staff_info_id and m2.rn = 2
                left join ph on ph.pno = ma.pno and ph.staff_info_id = ma.staff_info_id
                where
                    ma.rn =  3
                    and ph.routed_at < ma.created_at
                    and ph.routed_at > m2.created_at
            ) ph3
        where
            ph3.rn = 1
    ) thr on thr.pno = a.pno and thr.mark_staff = a.staff
left join
    (
        select
            ph4.*
        from
            (
                select
                    ph.*
                    ,ma.marker_id
                    ,ma.desired_at
                    ,ma.created_at
                    ,ma.staff_info_id mark_staff
                    ,ma.rejection_category
                    ,ma.rejection_remark
                    ,row_number() over (partition by ma.pno order by ph.routed_at desc) rn
                from ma
                left join ma m3 on m3.pno = ma.pno and m3.staff_info_id = ma.staff_info_id and m3.rn = 3
                left join ph on ph.pno = ma.pno and ph.staff_info_id = ma.staff_info_id
                where
                    ma.rn =  4
                    and ph.routed_at < ma.created_at
                    and ph.routed_at > m3.created_at
            ) ph4
        where
            ph4.rn = 1
    ) fou on fou.pno = a.pno and fou.mark_staff = a.staff
left join
    (
        select
            *
        from
            (
                select
                    pr.pno
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from
                    (
                        select
                            pr.pno
                            ,pr.route_action
                            ,pr.routed_at
                        from fle_dwd.dwd_rot_parcel_route_di pr
                        where
                            pr.p_date >= '2023-01-01'
                    ) pr
                join
                    (
                        select
                            *
                        from test.pno0337 t
                    ) t
                on t.pno = pr.pno
            ) pr
        where
            pr.rn = 1
    ) pr on pr.pno = a.pno