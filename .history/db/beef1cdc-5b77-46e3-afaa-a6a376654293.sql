select
    a.*
from
    (
        select
            pi.pno
            ,pi.p_date
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-6-01'
    ) a
join
    (
        select
            *
        from test.pno0337 t
    ) b on b.pno = a.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    min(a.p_date) dated
from
    (
        select
            pi.pno
            ,pi.p_date
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-6-01'
    ) a
join
    (
        select
            *
        from test.pno0337 t
    ) b on b.pno = a.pno;
;-- -. . -..- - / . -. - .-. -.--
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
                ) a on a.pno = td.pno -- and a.staff = td.staff_info_id
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
        ) b on b.pno = pho.pno -- and b.staff = pho.staff_info_id
)
select
    a.*
    ,js.ma_count `标记几次`
    ,tm1.created_at `第一次标记时间`
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
get_json_object(fir.extra_value, '$.callDuration')    end `第一次派件标记`
    , `第一次标记前通话时长`
    ,get_json_object(fir.extra_value, '$.diaboloDuration') `第一次标记前响铃时长`
    ,tm2.created_at `第二次标记时间`
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
    ,tm3.created_at `第三次标记时间`
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
    ,tm4.created_at `第四次标记时间`
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
    ,case cast(pi.state as int)
     when 1 then '已揽收'
     when 2 then '运输中'
     when 3 then '派送中'
     when 4 then '已滞留'
     when 5 then '已签收'
     when 6 then '疑难件处理中'
     when 7 then '已退件'
     when 8 then '异常关闭'
     when 9 then '已撤销'
    end as 包裹状态
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
    ) js on js.pno = a.pno -- and js.staff_info_id = a.staff
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
                left join ph on ph.pno = ma.pno --and ph.staff_info_id = ma.staff_info_id
                where
                    ma.rn = 1
                    and ph.routed_at < ma.created_at
            ) ph1
        where
            ph1.rn = 1
    ) fir on fir.pno = a.pno --and fir.mark_staff = a.staff

left join
    (
      select
      ma.pno
      ,ma.created_at
      ,ma.rn
      from ma
      where ma.rn=1
    )tm1 on tm1.pno=a.pno
left join
    (
      select
      ma.pno
      ,ma.created_at
      ,ma.rn
      from ma
      where ma.rn=2
    )tm2 on tm2.pno=a.pno
left join
    (
      select
      ma.pno
      ,ma.created_at
      ,ma.rn
      from ma
      where ma.rn=3
    )tm3 on tm3.pno=a.pno
left join
    (
      select
      ma.pno
      ,ma.created_at
      ,ma.rn
      from ma
      where ma.rn=4
    )tm4 on tm4.pno=a.pno


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
                left join ma m1 on m1.pno = ma.pno and m1.rn = 1 -- and m1.staff_info_id = ma.staff_info_id
                left join ph on ph.pno = ma.pno -- and ph.staff_info_id = ma.staff_info_id
                where
                    ma.rn =  2
                    and ph.routed_at < ma.created_at
                    and ph.routed_at > m1.created_at
            ) ph2
        where
            ph2.rn = 1
    ) sec on sec.pno = a.pno --and sec.mark_staff = a.staff
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
                left join ma m2 on m2.pno = ma.pno  and m2.rn = 2 -- and m2.staff_info_id = ma.staff_info_id
                left join ph on ph.pno = ma.pno -- and ph.staff_info_id = ma.staff_info_id
                where
                    ma.rn =  3
                    and ph.routed_at < ma.created_at
                    and ph.routed_at > m2.created_at
            ) ph3
        where
            ph3.rn = 1
    ) thr on thr.pno = a.pno --and thr.mark_staff = a.staff
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
                left join ma m3 on m3.pno = ma.pno  and m3.rn = 3 -- and m3.staff_info_id = ma.staff_info_id
                left join ph on ph.pno = ma.pno -- and ph.staff_info_id = ma.staff_info_id
                where
                    ma.rn =  4
                    and ph.routed_at < ma.created_at
                    and ph.routed_at > m3.created_at
            ) ph4
        where
            ph4.rn = 1
    ) fou on fou.pno = a.pno --and fou.mark_staff = a.staff
left join
(
  select
    pi.pno
    ,pi.state
  from fle_dwd.dwd_fle_parcel_info_di pi
  where pi.p_date>='2023-01-01'
)pi on pi.pno=a.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.*
        ,td.store_id
    from
        (
            select
                td.pno
                ,td.store_id
            from fle_dwd.dwd_fle_ticket_delivery_di td
            where
                td.p_date >= date_sub(`current_date`(), 90)
                and td.store_id in ('TH20040247','TH20040268','TH20040248')
            group by 1,2
        ) td
    join
        (
            select
                pi.pno
                ,pi.state
                ,pi.cod_amount
            from fle_dwd.dwd_fle_parcel_info_di pi
            where
                pi.state != '5'
        ) pi on pi.pno = td.pno
)
select
    b.pno
    ,cast(b.cod_amount as int)/100 cod
    ,case b.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,b.staff_info_id `最后操作人`
    ,b.store_id
from
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.routed_at desc ) rk
        from
            (
                select
                    pr.*
                    ,t1.cod_amount
                    ,t1.state
                    ,t1.store_id
                from
                    (
                        select
                            pr.pno
                            ,pr.staff_info_id
                            ,pr.route_action
                            ,pr.routed_at
        --                     ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
                        from fle_dwd.dwd_rot_parcel_route_di pr
                        where
                            pr.p_date >= date_sub(`current_date`(), 90)
                            and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                               'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                               'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                               'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                               'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                               'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    ) pr
                join t t1 on t1.pno = pr.pno
            ) a
    ) b;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.p_date  `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `流向`
    ,pi.client_id
    ,pi.dated_diff `揽收至今天数`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,pr.store_name `当前网点`
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
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
    end `最后一条有效路由`
    ,datediff(pr.routed_at, `current_date`()) `最后有效路由至今日期`
    ,di.diff_marker_category
    ,case di.diff_marker_category
        when '1' then '客户不在家/电话无人接听'
        when '2' then '收件人拒收'
        when '3' then '快件分错网点'
        when '4' then '外包装破损'
        when '5' then '货物破损'
        when '6' then '货物短少'
        when '7' then '货物丢失'
        when '8' then '电话联系不上'
        when '9' then '客户改约时间'
        when '10' then '客户不在'
        when '11' then '客户取消任务'
        when '12' then '无人签收'
        when '13' then '客户周末或假期不收货'
        when '14' then '客户改约时间'
        when '15' then '当日运力不足，无法派送'
        when '16' then '联系不上收件人'
        when '17' then '收件人拒收'
        when '18' then '快件分错网点'
        when '19' then '外包装破损'
        when '20' then '货物破损'
        when '21' then '货物短少'
        when '22' then '货物丢失'
        when '23' then '收件人/地址不清晰或不正确'
        when '24' then '收件地址已废弃或不存在'
        when '25' then '收件人电话号码错误'
        when '26' then 'cod金额不正确'
        when '27' then '无实际包裹'
        when '28' then '已妥投未交接'
        when '29' then '收件人电话号码是空号'
        when '30' then '快件分错网点-地址正确'
        when '31' then '快件分错网点-地址错误'
        when '32' then '禁运品'
        when '33' then '严重破损（丢弃）'
        when '34' then '退件两次尝试派送失败'
        when '35' then '不能打开locker'
        when '36' then 'locker不能使用'
        when '37' then '该地址找不到lockerstation'
        when '38' then '一票多件'
        when '39' then '多次尝试派件失败'
        when '40' then '客户不在家/电话无人接听'
        when '41' then '错过班车时间'
        when '42' then '目的地是偏远地区,留仓待次日派送'
        when '43' then '目的地是岛屿,留仓待次日派送'
        when '44' then '企业/机构当天已下班'
        when '45' then '子母件包裹未全部到达网点'
        when '46' then '不可抗力原因留仓(台风)'
        when '47' then '虚假包裹'
        when '48' then '转交FH包裹留仓'
        when '50' then '客户取消寄件'
        when '51' then '信息录入错误'
        when '52' then '客户取消寄件'
        when '53' then 'lazada仓库拒收'
        when '69' then '禁运品'
        when '70' then '客户改约时间'
        when '71' then '当日运力不足，无法派送'
        when '72' then '客户周末或假期不收货'
        when '73' then '收件人/地址不清晰或不正确'
        when '74' then '收件地址已废弃或不存在'
        when '75' then '收件人电话号码错误'
        when '76' then 'cod金额不正确'
        when '77' then '企业/机构当天已下班'
        when '78' then '收件人电话号码是空号'
        when '79' then '快件分错网点-地址错误'
        when '80' then '客户取消任务'
        when '81' then '重复下单'
        when '82' then '已完成揽件'
        when '83' then '联系不上客户'
        when '84' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '85' then '寄件人电话号码是空号'
        when '86' then '包裹不符合揽收条件超大件'
        when '87' then '包裹不符合揽收条件违禁品'
        when '88' then '寄件人地址为岛屿'
        when '89' then '运力短缺，跟客户协商推迟揽收'
        when '90' then '包裹未准备好推迟揽收'
        when '91' then '包裹包装不符合运输标准'
        when '92' then '客户提供的清单里没有此包裹'
        when '93' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '94' then '客户取消寄件/客户实际不想寄此包裹'
        when '95' then '车辆/人力短缺推迟揽收'
        when '96' then '遗漏揽收(已停用)'
        when '97' then '子母件(一个单号多个包裹)'
        when '98' then '地址错误addresserror'
        when '99' then '包裹不符合揽收条件：超大件'
        when '100' then '包裹不符合揽收条件：违禁品'
        when '101' then '包裹包装不符合运输标准'
        when '102' then '包裹未准备好'
        when '103' then '运力短缺，跟客户协商推迟揽收'
        when '104' then '子母件(一个单号多个包裹)'
        when '105' then '破损包裹'
        when '106' then '空包裹'
        when '107' then '不能打开locker(密码错误)'
        when '108' then 'locker不能使用'
        when '109' then 'locker找不到'
        when '110' then '运单号与实际包裹的单号不一致'
        when '111' then 'box客户取消任务'
        when '112' then '不能打开locker(密码错误)'
        when '113' then 'locker不能使用'
        when '114' then 'locker找不到'
        when '115' then '实际重量尺寸大于客户下单的重量尺寸'
        when '116' then '客户仓库关闭'
        when '117' then '客户仓库关闭'
        when '118' then 'SHOPEE订单系统自动关闭'
        when '119' then '客户取消包裹'
        when '121' then '地址错误'
        when '122' then '当日运力不足，无法揽收'
    end as `疑难原因`
    ,datediff(di.created_at, `current_date`()) `问题件处理天数`
    ,ss.name `揽收网点`
    ,ss2.name` '目的地网点'`
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.ticket_pickup_store_id
            ,datediff(pi.p_date, `current_date`()) dated_diff
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2023-01-01'
            and pi.p_date < '2023-03-01'
            and pi.state not in ('5', '7', '8', '9')
    ) pi
join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at) rk
                from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
                where
                    pr.p_date >= '2023-01-01'
                    and pr.p_date < '2023-03-01'
                    and pr.valid_route = '1'
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = pi.pno
left join
    (
        select
            di.*
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.diff_marker_category
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                from fle_dwd.dwd_fle_diff_info_di di
                where
                    di.created_at >= '2023-01-01'
                    and di.state = '0'
            ) di
        where
            di.rk = 1
    ) di on di.pno = pi.pno
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss  on ss.id = pi.ticket_pickup_store_id
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2  on ss2.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.p_date  `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `流向`
    ,pi.client_id
    ,pi.dated_diff `揽收至今天数`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,pr.store_name `当前网点`
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
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
    end `最后一条有效路由`
    ,datediff(pr.routed_at, `current_date`()) `最后有效路由至今日期`
    ,di.diff_marker_category
    ,case di.diff_marker_category
        when '1' then '客户不在家/电话无人接听'
        when '2' then '收件人拒收'
        when '3' then '快件分错网点'
        when '4' then '外包装破损'
        when '5' then '货物破损'
        when '6' then '货物短少'
        when '7' then '货物丢失'
        when '8' then '电话联系不上'
        when '9' then '客户改约时间'
        when '10' then '客户不在'
        when '11' then '客户取消任务'
        when '12' then '无人签收'
        when '13' then '客户周末或假期不收货'
        when '14' then '客户改约时间'
        when '15' then '当日运力不足，无法派送'
        when '16' then '联系不上收件人'
        when '17' then '收件人拒收'
        when '18' then '快件分错网点'
        when '19' then '外包装破损'
        when '20' then '货物破损'
        when '21' then '货物短少'
        when '22' then '货物丢失'
        when '23' then '收件人/地址不清晰或不正确'
        when '24' then '收件地址已废弃或不存在'
        when '25' then '收件人电话号码错误'
        when '26' then 'cod金额不正确'
        when '27' then '无实际包裹'
        when '28' then '已妥投未交接'
        when '29' then '收件人电话号码是空号'
        when '30' then '快件分错网点-地址正确'
        when '31' then '快件分错网点-地址错误'
        when '32' then '禁运品'
        when '33' then '严重破损（丢弃）'
        when '34' then '退件两次尝试派送失败'
        when '35' then '不能打开locker'
        when '36' then 'locker不能使用'
        when '37' then '该地址找不到lockerstation'
        when '38' then '一票多件'
        when '39' then '多次尝试派件失败'
        when '40' then '客户不在家/电话无人接听'
        when '41' then '错过班车时间'
        when '42' then '目的地是偏远地区,留仓待次日派送'
        when '43' then '目的地是岛屿,留仓待次日派送'
        when '44' then '企业/机构当天已下班'
        when '45' then '子母件包裹未全部到达网点'
        when '46' then '不可抗力原因留仓(台风)'
        when '47' then '虚假包裹'
        when '48' then '转交FH包裹留仓'
        when '50' then '客户取消寄件'
        when '51' then '信息录入错误'
        when '52' then '客户取消寄件'
        when '53' then 'lazada仓库拒收'
        when '69' then '禁运品'
        when '70' then '客户改约时间'
        when '71' then '当日运力不足，无法派送'
        when '72' then '客户周末或假期不收货'
        when '73' then '收件人/地址不清晰或不正确'
        when '74' then '收件地址已废弃或不存在'
        when '75' then '收件人电话号码错误'
        when '76' then 'cod金额不正确'
        when '77' then '企业/机构当天已下班'
        when '78' then '收件人电话号码是空号'
        when '79' then '快件分错网点-地址错误'
        when '80' then '客户取消任务'
        when '81' then '重复下单'
        when '82' then '已完成揽件'
        when '83' then '联系不上客户'
        when '84' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '85' then '寄件人电话号码是空号'
        when '86' then '包裹不符合揽收条件超大件'
        when '87' then '包裹不符合揽收条件违禁品'
        when '88' then '寄件人地址为岛屿'
        when '89' then '运力短缺，跟客户协商推迟揽收'
        when '90' then '包裹未准备好推迟揽收'
        when '91' then '包裹包装不符合运输标准'
        when '92' then '客户提供的清单里没有此包裹'
        when '93' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '94' then '客户取消寄件/客户实际不想寄此包裹'
        when '95' then '车辆/人力短缺推迟揽收'
        when '96' then '遗漏揽收(已停用)'
        when '97' then '子母件(一个单号多个包裹)'
        when '98' then '地址错误addresserror'
        when '99' then '包裹不符合揽收条件：超大件'
        when '100' then '包裹不符合揽收条件：违禁品'
        when '101' then '包裹包装不符合运输标准'
        when '102' then '包裹未准备好'
        when '103' then '运力短缺，跟客户协商推迟揽收'
        when '104' then '子母件(一个单号多个包裹)'
        when '105' then '破损包裹'
        when '106' then '空包裹'
        when '107' then '不能打开locker(密码错误)'
        when '108' then 'locker不能使用'
        when '109' then 'locker找不到'
        when '110' then '运单号与实际包裹的单号不一致'
        when '111' then 'box客户取消任务'
        when '112' then '不能打开locker(密码错误)'
        when '113' then 'locker不能使用'
        when '114' then 'locker找不到'
        when '115' then '实际重量尺寸大于客户下单的重量尺寸'
        when '116' then '客户仓库关闭'
        when '117' then '客户仓库关闭'
        when '118' then 'SHOPEE订单系统自动关闭'
        when '119' then '客户取消包裹'
        when '121' then '地址错误'
        when '122' then '当日运力不足，无法揽收'
    end as `疑难原因`
    ,datediff(di.created_at, `current_date`()) `问题件处理天数`
    ,ss.name `揽收网点`
    ,ss2.name` '目的地网点'`
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.ticket_pickup_store_id
            ,datediff(pi.p_date, `current_date`()) dated_diff
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2023-01-01'
            and pi.p_date < '2023-03-01'
            and pi.state not in ('5', '7', '8', '9')
    ) pi
join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
                where
                    pr.p_date >= '2023-01-01'
                    and pr.p_date < '2023-03-01'
                    and pr.valid_route = '1'
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = pi.pno
left join
    (
        select
            di.*
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.diff_marker_category
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                from fle_dwd.dwd_fle_diff_info_di di
                where
                    di.created_at >= '2023-01-01'
                    and di.state = '0'
            ) di
        where
            di.rk = 1
    ) di on di.pno = pi.pno
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss  on ss.id = pi.ticket_pickup_store_id
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2  on ss2.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.p_date  `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `流向`
    ,pi.client_id
    ,pi.dated_diff `揽收至今天数`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,pr.store_name `当前网点`
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
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
    end `最后一条有效路由`
    ,datediff( `current_date`(), pr.routed_at) `最后有效路由至今日期`
    ,di.diff_marker_category
    ,case di.diff_marker_category
        when '1' then '客户不在家/电话无人接听'
        when '2' then '收件人拒收'
        when '3' then '快件分错网点'
        when '4' then '外包装破损'
        when '5' then '货物破损'
        when '6' then '货物短少'
        when '7' then '货物丢失'
        when '8' then '电话联系不上'
        when '9' then '客户改约时间'
        when '10' then '客户不在'
        when '11' then '客户取消任务'
        when '12' then '无人签收'
        when '13' then '客户周末或假期不收货'
        when '14' then '客户改约时间'
        when '15' then '当日运力不足，无法派送'
        when '16' then '联系不上收件人'
        when '17' then '收件人拒收'
        when '18' then '快件分错网点'
        when '19' then '外包装破损'
        when '20' then '货物破损'
        when '21' then '货物短少'
        when '22' then '货物丢失'
        when '23' then '收件人/地址不清晰或不正确'
        when '24' then '收件地址已废弃或不存在'
        when '25' then '收件人电话号码错误'
        when '26' then 'cod金额不正确'
        when '27' then '无实际包裹'
        when '28' then '已妥投未交接'
        when '29' then '收件人电话号码是空号'
        when '30' then '快件分错网点-地址正确'
        when '31' then '快件分错网点-地址错误'
        when '32' then '禁运品'
        when '33' then '严重破损（丢弃）'
        when '34' then '退件两次尝试派送失败'
        when '35' then '不能打开locker'
        when '36' then 'locker不能使用'
        when '37' then '该地址找不到lockerstation'
        when '38' then '一票多件'
        when '39' then '多次尝试派件失败'
        when '40' then '客户不在家/电话无人接听'
        when '41' then '错过班车时间'
        when '42' then '目的地是偏远地区,留仓待次日派送'
        when '43' then '目的地是岛屿,留仓待次日派送'
        when '44' then '企业/机构当天已下班'
        when '45' then '子母件包裹未全部到达网点'
        when '46' then '不可抗力原因留仓(台风)'
        when '47' then '虚假包裹'
        when '48' then '转交FH包裹留仓'
        when '50' then '客户取消寄件'
        when '51' then '信息录入错误'
        when '52' then '客户取消寄件'
        when '53' then 'lazada仓库拒收'
        when '69' then '禁运品'
        when '70' then '客户改约时间'
        when '71' then '当日运力不足，无法派送'
        when '72' then '客户周末或假期不收货'
        when '73' then '收件人/地址不清晰或不正确'
        when '74' then '收件地址已废弃或不存在'
        when '75' then '收件人电话号码错误'
        when '76' then 'cod金额不正确'
        when '77' then '企业/机构当天已下班'
        when '78' then '收件人电话号码是空号'
        when '79' then '快件分错网点-地址错误'
        when '80' then '客户取消任务'
        when '81' then '重复下单'
        when '82' then '已完成揽件'
        when '83' then '联系不上客户'
        when '84' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '85' then '寄件人电话号码是空号'
        when '86' then '包裹不符合揽收条件超大件'
        when '87' then '包裹不符合揽收条件违禁品'
        when '88' then '寄件人地址为岛屿'
        when '89' then '运力短缺，跟客户协商推迟揽收'
        when '90' then '包裹未准备好推迟揽收'
        when '91' then '包裹包装不符合运输标准'
        when '92' then '客户提供的清单里没有此包裹'
        when '93' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '94' then '客户取消寄件/客户实际不想寄此包裹'
        when '95' then '车辆/人力短缺推迟揽收'
        when '96' then '遗漏揽收(已停用)'
        when '97' then '子母件(一个单号多个包裹)'
        when '98' then '地址错误addresserror'
        when '99' then '包裹不符合揽收条件：超大件'
        when '100' then '包裹不符合揽收条件：违禁品'
        when '101' then '包裹包装不符合运输标准'
        when '102' then '包裹未准备好'
        when '103' then '运力短缺，跟客户协商推迟揽收'
        when '104' then '子母件(一个单号多个包裹)'
        when '105' then '破损包裹'
        when '106' then '空包裹'
        when '107' then '不能打开locker(密码错误)'
        when '108' then 'locker不能使用'
        when '109' then 'locker找不到'
        when '110' then '运单号与实际包裹的单号不一致'
        when '111' then 'box客户取消任务'
        when '112' then '不能打开locker(密码错误)'
        when '113' then 'locker不能使用'
        when '114' then 'locker找不到'
        when '115' then '实际重量尺寸大于客户下单的重量尺寸'
        when '116' then '客户仓库关闭'
        when '117' then '客户仓库关闭'
        when '118' then 'SHOPEE订单系统自动关闭'
        when '119' then '客户取消包裹'
        when '121' then '地址错误'
        when '122' then '当日运力不足，无法揽收'
    end as `疑难原因`
    ,datediff( `current_date`(), di.created_at) `问题件处理天数`
    ,ss.name `揽收网点`
    ,ss2.name` '目的地网点'`
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.ticket_pickup_store_id
            ,datediff(`current_date`(), pi.p_date) dated_diff
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-01-01'
            and pi.p_date < '2022-03-01'
            and pi.state not in ('5', '7', '8', '9')
    ) pi
join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
                where
                    pr.p_date >= '2022-01-01'
                    and pr.p_date < '2022-03-01'
                    and pr.valid_route = '1'
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = pi.pno
left join
    (
        select
            di.*
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.diff_marker_category
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                from fle_dwd.dwd_fle_diff_info_di di
                where
                    di.created_at >= '2022-01-01'
                    and di.created_at < '2022-10-01'
                    and di.state = '0'
            ) di
        where
            di.rk = 1
    ) di on di.pno = pi.pno
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss  on ss.id = pi.ticket_pickup_store_id
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2  on ss2.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.p_date  `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `流向`
    ,pi.client_id
    ,pi.dated_diff `揽收至今天数`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,pr.store_name `当前网点`
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
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
    end `最后一条有效路由`
    ,datediff( `current_date`(), pr.routed_at) `最后有效路由至今日期`
    ,di.diff_marker_category
    ,case di.diff_marker_category
        when '1' then '客户不在家/电话无人接听'
        when '2' then '收件人拒收'
        when '3' then '快件分错网点'
        when '4' then '外包装破损'
        when '5' then '货物破损'
        when '6' then '货物短少'
        when '7' then '货物丢失'
        when '8' then '电话联系不上'
        when '9' then '客户改约时间'
        when '10' then '客户不在'
        when '11' then '客户取消任务'
        when '12' then '无人签收'
        when '13' then '客户周末或假期不收货'
        when '14' then '客户改约时间'
        when '15' then '当日运力不足，无法派送'
        when '16' then '联系不上收件人'
        when '17' then '收件人拒收'
        when '18' then '快件分错网点'
        when '19' then '外包装破损'
        when '20' then '货物破损'
        when '21' then '货物短少'
        when '22' then '货物丢失'
        when '23' then '收件人/地址不清晰或不正确'
        when '24' then '收件地址已废弃或不存在'
        when '25' then '收件人电话号码错误'
        when '26' then 'cod金额不正确'
        when '27' then '无实际包裹'
        when '28' then '已妥投未交接'
        when '29' then '收件人电话号码是空号'
        when '30' then '快件分错网点-地址正确'
        when '31' then '快件分错网点-地址错误'
        when '32' then '禁运品'
        when '33' then '严重破损（丢弃）'
        when '34' then '退件两次尝试派送失败'
        when '35' then '不能打开locker'
        when '36' then 'locker不能使用'
        when '37' then '该地址找不到lockerstation'
        when '38' then '一票多件'
        when '39' then '多次尝试派件失败'
        when '40' then '客户不在家/电话无人接听'
        when '41' then '错过班车时间'
        when '42' then '目的地是偏远地区,留仓待次日派送'
        when '43' then '目的地是岛屿,留仓待次日派送'
        when '44' then '企业/机构当天已下班'
        when '45' then '子母件包裹未全部到达网点'
        when '46' then '不可抗力原因留仓(台风)'
        when '47' then '虚假包裹'
        when '48' then '转交FH包裹留仓'
        when '50' then '客户取消寄件'
        when '51' then '信息录入错误'
        when '52' then '客户取消寄件'
        when '53' then 'lazada仓库拒收'
        when '69' then '禁运品'
        when '70' then '客户改约时间'
        when '71' then '当日运力不足，无法派送'
        when '72' then '客户周末或假期不收货'
        when '73' then '收件人/地址不清晰或不正确'
        when '74' then '收件地址已废弃或不存在'
        when '75' then '收件人电话号码错误'
        when '76' then 'cod金额不正确'
        when '77' then '企业/机构当天已下班'
        when '78' then '收件人电话号码是空号'
        when '79' then '快件分错网点-地址错误'
        when '80' then '客户取消任务'
        when '81' then '重复下单'
        when '82' then '已完成揽件'
        when '83' then '联系不上客户'
        when '84' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '85' then '寄件人电话号码是空号'
        when '86' then '包裹不符合揽收条件超大件'
        when '87' then '包裹不符合揽收条件违禁品'
        when '88' then '寄件人地址为岛屿'
        when '89' then '运力短缺，跟客户协商推迟揽收'
        when '90' then '包裹未准备好推迟揽收'
        when '91' then '包裹包装不符合运输标准'
        when '92' then '客户提供的清单里没有此包裹'
        when '93' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '94' then '客户取消寄件/客户实际不想寄此包裹'
        when '95' then '车辆/人力短缺推迟揽收'
        when '96' then '遗漏揽收(已停用)'
        when '97' then '子母件(一个单号多个包裹)'
        when '98' then '地址错误addresserror'
        when '99' then '包裹不符合揽收条件：超大件'
        when '100' then '包裹不符合揽收条件：违禁品'
        when '101' then '包裹包装不符合运输标准'
        when '102' then '包裹未准备好'
        when '103' then '运力短缺，跟客户协商推迟揽收'
        when '104' then '子母件(一个单号多个包裹)'
        when '105' then '破损包裹'
        when '106' then '空包裹'
        when '107' then '不能打开locker(密码错误)'
        when '108' then 'locker不能使用'
        when '109' then 'locker找不到'
        when '110' then '运单号与实际包裹的单号不一致'
        when '111' then 'box客户取消任务'
        when '112' then '不能打开locker(密码错误)'
        when '113' then 'locker不能使用'
        when '114' then 'locker找不到'
        when '115' then '实际重量尺寸大于客户下单的重量尺寸'
        when '116' then '客户仓库关闭'
        when '117' then '客户仓库关闭'
        when '118' then 'SHOPEE订单系统自动关闭'
        when '119' then '客户取消包裹'
        when '121' then '地址错误'
        when '122' then '当日运力不足，无法揽收'
    end as `疑难原因`
    ,datediff( `current_date`(), di.created_at) `问题件处理天数`
    ,ss.name `揽收网点`
    ,ss2.name` '目的地网点'`
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.ticket_pickup_store_id
            ,datediff(`current_date`(), pi.p_date) dated_diff
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-03-01'
            and pi.p_date < '2022-05-01'
            and pi.state not in ('5', '7', '8', '9')
    ) pi
join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
                where
                    pr.p_date >= '2022-03-01'
                    and pr.p_date < '2022-05-01'
                    and pr.valid_route = '1'
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = pi.pno
left join
    (
        select
            di.*
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.diff_marker_category
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                from fle_dwd.dwd_fle_diff_info_di di
                where
                    di.created_at >= '2022-01-01'
                    and di.created_at < '2022-12-01'
                    and di.state = '0'
            ) di
        where
            di.rk = 1
    ) di on di.pno = pi.pno
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss  on ss.id = pi.ticket_pickup_store_id
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2  on ss2.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.p_date  `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `流向`
    ,pi.client_id
    ,pi.dated_diff `揽收至今天数`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,pr.store_name `当前网点`
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
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
    end `最后一条有效路由`
    ,datediff( `current_date`(), pr.routed_at) `最后有效路由至今日期`
    ,di.diff_marker_category
    ,case di.diff_marker_category
        when '1' then '客户不在家/电话无人接听'
        when '2' then '收件人拒收'
        when '3' then '快件分错网点'
        when '4' then '外包装破损'
        when '5' then '货物破损'
        when '6' then '货物短少'
        when '7' then '货物丢失'
        when '8' then '电话联系不上'
        when '9' then '客户改约时间'
        when '10' then '客户不在'
        when '11' then '客户取消任务'
        when '12' then '无人签收'
        when '13' then '客户周末或假期不收货'
        when '14' then '客户改约时间'
        when '15' then '当日运力不足，无法派送'
        when '16' then '联系不上收件人'
        when '17' then '收件人拒收'
        when '18' then '快件分错网点'
        when '19' then '外包装破损'
        when '20' then '货物破损'
        when '21' then '货物短少'
        when '22' then '货物丢失'
        when '23' then '收件人/地址不清晰或不正确'
        when '24' then '收件地址已废弃或不存在'
        when '25' then '收件人电话号码错误'
        when '26' then 'cod金额不正确'
        when '27' then '无实际包裹'
        when '28' then '已妥投未交接'
        when '29' then '收件人电话号码是空号'
        when '30' then '快件分错网点-地址正确'
        when '31' then '快件分错网点-地址错误'
        when '32' then '禁运品'
        when '33' then '严重破损（丢弃）'
        when '34' then '退件两次尝试派送失败'
        when '35' then '不能打开locker'
        when '36' then 'locker不能使用'
        when '37' then '该地址找不到lockerstation'
        when '38' then '一票多件'
        when '39' then '多次尝试派件失败'
        when '40' then '客户不在家/电话无人接听'
        when '41' then '错过班车时间'
        when '42' then '目的地是偏远地区,留仓待次日派送'
        when '43' then '目的地是岛屿,留仓待次日派送'
        when '44' then '企业/机构当天已下班'
        when '45' then '子母件包裹未全部到达网点'
        when '46' then '不可抗力原因留仓(台风)'
        when '47' then '虚假包裹'
        when '48' then '转交FH包裹留仓'
        when '50' then '客户取消寄件'
        when '51' then '信息录入错误'
        when '52' then '客户取消寄件'
        when '53' then 'lazada仓库拒收'
        when '69' then '禁运品'
        when '70' then '客户改约时间'
        when '71' then '当日运力不足，无法派送'
        when '72' then '客户周末或假期不收货'
        when '73' then '收件人/地址不清晰或不正确'
        when '74' then '收件地址已废弃或不存在'
        when '75' then '收件人电话号码错误'
        when '76' then 'cod金额不正确'
        when '77' then '企业/机构当天已下班'
        when '78' then '收件人电话号码是空号'
        when '79' then '快件分错网点-地址错误'
        when '80' then '客户取消任务'
        when '81' then '重复下单'
        when '82' then '已完成揽件'
        when '83' then '联系不上客户'
        when '84' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '85' then '寄件人电话号码是空号'
        when '86' then '包裹不符合揽收条件超大件'
        when '87' then '包裹不符合揽收条件违禁品'
        when '88' then '寄件人地址为岛屿'
        when '89' then '运力短缺，跟客户协商推迟揽收'
        when '90' then '包裹未准备好推迟揽收'
        when '91' then '包裹包装不符合运输标准'
        when '92' then '客户提供的清单里没有此包裹'
        when '93' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '94' then '客户取消寄件/客户实际不想寄此包裹'
        when '95' then '车辆/人力短缺推迟揽收'
        when '96' then '遗漏揽收(已停用)'
        when '97' then '子母件(一个单号多个包裹)'
        when '98' then '地址错误addresserror'
        when '99' then '包裹不符合揽收条件：超大件'
        when '100' then '包裹不符合揽收条件：违禁品'
        when '101' then '包裹包装不符合运输标准'
        when '102' then '包裹未准备好'
        when '103' then '运力短缺，跟客户协商推迟揽收'
        when '104' then '子母件(一个单号多个包裹)'
        when '105' then '破损包裹'
        when '106' then '空包裹'
        when '107' then '不能打开locker(密码错误)'
        when '108' then 'locker不能使用'
        when '109' then 'locker找不到'
        when '110' then '运单号与实际包裹的单号不一致'
        when '111' then 'box客户取消任务'
        when '112' then '不能打开locker(密码错误)'
        when '113' then 'locker不能使用'
        when '114' then 'locker找不到'
        when '115' then '实际重量尺寸大于客户下单的重量尺寸'
        when '116' then '客户仓库关闭'
        when '117' then '客户仓库关闭'
        when '118' then 'SHOPEE订单系统自动关闭'
        when '119' then '客户取消包裹'
        when '121' then '地址错误'
        when '122' then '当日运力不足，无法揽收'
    end as `疑难原因`
    ,datediff( `current_date`(), di.created_at) `问题件处理天数`
    ,ss.name `揽收网点`
    ,ss2.name` '目的地网点'`
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.ticket_pickup_store_id
            ,datediff(`current_date`(), pi.p_date) dated_diff
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-03-01'
            and pi.p_date < '2022-05-01'
            and pi.state not in ('5', '7', '8', '9')
    ) pi
join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
                where
                    pr.p_date >= '2022-03-01'
                    and pr.p_date < '2022-05-01'
                    and pr.valid_route = '1'
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = pi.pno
left join
    (
        select
            di.*
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.diff_marker_category
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                from fle_dwd.dwd_fle_diff_info_di di
                where
                    di.created_at >= '2022-03-01'
                    and di.created_at < '2022-12-01'
                    and di.state = '0'
            ) di
        where
            di.rk = 1
    ) di on di.pno = pi.pno
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss  on ss.id = pi.ticket_pickup_store_id
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2  on ss2.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.p_date  `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `流向`
    ,pi.client_id
    ,pi.dated_diff `揽收至今天数`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,pr.store_name `当前网点`
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
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
    end `最后一条有效路由`
    ,datediff( `current_date`(), pr.routed_at) `最后有效路由至今日期`
    ,di.diff_marker_category
    ,case di.diff_marker_category
        when '1' then '客户不在家/电话无人接听'
        when '2' then '收件人拒收'
        when '3' then '快件分错网点'
        when '4' then '外包装破损'
        when '5' then '货物破损'
        when '6' then '货物短少'
        when '7' then '货物丢失'
        when '8' then '电话联系不上'
        when '9' then '客户改约时间'
        when '10' then '客户不在'
        when '11' then '客户取消任务'
        when '12' then '无人签收'
        when '13' then '客户周末或假期不收货'
        when '14' then '客户改约时间'
        when '15' then '当日运力不足，无法派送'
        when '16' then '联系不上收件人'
        when '17' then '收件人拒收'
        when '18' then '快件分错网点'
        when '19' then '外包装破损'
        when '20' then '货物破损'
        when '21' then '货物短少'
        when '22' then '货物丢失'
        when '23' then '收件人/地址不清晰或不正确'
        when '24' then '收件地址已废弃或不存在'
        when '25' then '收件人电话号码错误'
        when '26' then 'cod金额不正确'
        when '27' then '无实际包裹'
        when '28' then '已妥投未交接'
        when '29' then '收件人电话号码是空号'
        when '30' then '快件分错网点-地址正确'
        when '31' then '快件分错网点-地址错误'
        when '32' then '禁运品'
        when '33' then '严重破损（丢弃）'
        when '34' then '退件两次尝试派送失败'
        when '35' then '不能打开locker'
        when '36' then 'locker不能使用'
        when '37' then '该地址找不到lockerstation'
        when '38' then '一票多件'
        when '39' then '多次尝试派件失败'
        when '40' then '客户不在家/电话无人接听'
        when '41' then '错过班车时间'
        when '42' then '目的地是偏远地区,留仓待次日派送'
        when '43' then '目的地是岛屿,留仓待次日派送'
        when '44' then '企业/机构当天已下班'
        when '45' then '子母件包裹未全部到达网点'
        when '46' then '不可抗力原因留仓(台风)'
        when '47' then '虚假包裹'
        when '48' then '转交FH包裹留仓'
        when '50' then '客户取消寄件'
        when '51' then '信息录入错误'
        when '52' then '客户取消寄件'
        when '53' then 'lazada仓库拒收'
        when '69' then '禁运品'
        when '70' then '客户改约时间'
        when '71' then '当日运力不足，无法派送'
        when '72' then '客户周末或假期不收货'
        when '73' then '收件人/地址不清晰或不正确'
        when '74' then '收件地址已废弃或不存在'
        when '75' then '收件人电话号码错误'
        when '76' then 'cod金额不正确'
        when '77' then '企业/机构当天已下班'
        when '78' then '收件人电话号码是空号'
        when '79' then '快件分错网点-地址错误'
        when '80' then '客户取消任务'
        when '81' then '重复下单'
        when '82' then '已完成揽件'
        when '83' then '联系不上客户'
        when '84' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '85' then '寄件人电话号码是空号'
        when '86' then '包裹不符合揽收条件超大件'
        when '87' then '包裹不符合揽收条件违禁品'
        when '88' then '寄件人地址为岛屿'
        when '89' then '运力短缺，跟客户协商推迟揽收'
        when '90' then '包裹未准备好推迟揽收'
        when '91' then '包裹包装不符合运输标准'
        when '92' then '客户提供的清单里没有此包裹'
        when '93' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '94' then '客户取消寄件/客户实际不想寄此包裹'
        when '95' then '车辆/人力短缺推迟揽收'
        when '96' then '遗漏揽收(已停用)'
        when '97' then '子母件(一个单号多个包裹)'
        when '98' then '地址错误addresserror'
        when '99' then '包裹不符合揽收条件：超大件'
        when '100' then '包裹不符合揽收条件：违禁品'
        when '101' then '包裹包装不符合运输标准'
        when '102' then '包裹未准备好'
        when '103' then '运力短缺，跟客户协商推迟揽收'
        when '104' then '子母件(一个单号多个包裹)'
        when '105' then '破损包裹'
        when '106' then '空包裹'
        when '107' then '不能打开locker(密码错误)'
        when '108' then 'locker不能使用'
        when '109' then 'locker找不到'
        when '110' then '运单号与实际包裹的单号不一致'
        when '111' then 'box客户取消任务'
        when '112' then '不能打开locker(密码错误)'
        when '113' then 'locker不能使用'
        when '114' then 'locker找不到'
        when '115' then '实际重量尺寸大于客户下单的重量尺寸'
        when '116' then '客户仓库关闭'
        when '117' then '客户仓库关闭'
        when '118' then 'SHOPEE订单系统自动关闭'
        when '119' then '客户取消包裹'
        when '121' then '地址错误'
        when '122' then '当日运力不足，无法揽收'
    end as `疑难原因`
    ,datediff( `current_date`(), di.created_at) `问题件处理天数`
    ,ss.name `揽收网点`
    ,ss2.name` '目的地网点'`
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.ticket_pickup_store_id
            ,datediff(`current_date`(), pi.p_date) dated_diff
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-05-01'
            and pi.p_date < '2022-07-01'
            and pi.state not in ('5', '7', '8', '9')
    ) pi
join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
                where
                    pr.p_date >= '2022-05-01'
                    and pr.p_date < '2022-07-01'
                    and pr.valid_route = '1'
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = pi.pno
left join
    (
        select
            di.*
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.diff_marker_category
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                from fle_dwd.dwd_fle_diff_info_di di
                where
                    di.created_at >= '2022-05-01'
                    and di.created_at < '2023-01-01'
                    and di.state = '0'
            ) di
        where
            di.rk = 1
    ) di on di.pno = pi.pno
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss  on ss.id = pi.ticket_pickup_store_id
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2  on ss2.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.p_date  `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `流向`
    ,pi.client_id
    ,pi.dated_diff `揽收至今天数`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,pr.store_name `当前网点`
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
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
    end `最后一条有效路由`
    ,datediff( `current_date`(), pr.routed_at) `最后有效路由至今日期`
    ,di.diff_marker_category
    ,case di.diff_marker_category
        when '1' then '客户不在家/电话无人接听'
        when '2' then '收件人拒收'
        when '3' then '快件分错网点'
        when '4' then '外包装破损'
        when '5' then '货物破损'
        when '6' then '货物短少'
        when '7' then '货物丢失'
        when '8' then '电话联系不上'
        when '9' then '客户改约时间'
        when '10' then '客户不在'
        when '11' then '客户取消任务'
        when '12' then '无人签收'
        when '13' then '客户周末或假期不收货'
        when '14' then '客户改约时间'
        when '15' then '当日运力不足，无法派送'
        when '16' then '联系不上收件人'
        when '17' then '收件人拒收'
        when '18' then '快件分错网点'
        when '19' then '外包装破损'
        when '20' then '货物破损'
        when '21' then '货物短少'
        when '22' then '货物丢失'
        when '23' then '收件人/地址不清晰或不正确'
        when '24' then '收件地址已废弃或不存在'
        when '25' then '收件人电话号码错误'
        when '26' then 'cod金额不正确'
        when '27' then '无实际包裹'
        when '28' then '已妥投未交接'
        when '29' then '收件人电话号码是空号'
        when '30' then '快件分错网点-地址正确'
        when '31' then '快件分错网点-地址错误'
        when '32' then '禁运品'
        when '33' then '严重破损（丢弃）'
        when '34' then '退件两次尝试派送失败'
        when '35' then '不能打开locker'
        when '36' then 'locker不能使用'
        when '37' then '该地址找不到lockerstation'
        when '38' then '一票多件'
        when '39' then '多次尝试派件失败'
        when '40' then '客户不在家/电话无人接听'
        when '41' then '错过班车时间'
        when '42' then '目的地是偏远地区,留仓待次日派送'
        when '43' then '目的地是岛屿,留仓待次日派送'
        when '44' then '企业/机构当天已下班'
        when '45' then '子母件包裹未全部到达网点'
        when '46' then '不可抗力原因留仓(台风)'
        when '47' then '虚假包裹'
        when '48' then '转交FH包裹留仓'
        when '50' then '客户取消寄件'
        when '51' then '信息录入错误'
        when '52' then '客户取消寄件'
        when '53' then 'lazada仓库拒收'
        when '69' then '禁运品'
        when '70' then '客户改约时间'
        when '71' then '当日运力不足，无法派送'
        when '72' then '客户周末或假期不收货'
        when '73' then '收件人/地址不清晰或不正确'
        when '74' then '收件地址已废弃或不存在'
        when '75' then '收件人电话号码错误'
        when '76' then 'cod金额不正确'
        when '77' then '企业/机构当天已下班'
        when '78' then '收件人电话号码是空号'
        when '79' then '快件分错网点-地址错误'
        when '80' then '客户取消任务'
        when '81' then '重复下单'
        when '82' then '已完成揽件'
        when '83' then '联系不上客户'
        when '84' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '85' then '寄件人电话号码是空号'
        when '86' then '包裹不符合揽收条件超大件'
        when '87' then '包裹不符合揽收条件违禁品'
        when '88' then '寄件人地址为岛屿'
        when '89' then '运力短缺，跟客户协商推迟揽收'
        when '90' then '包裹未准备好推迟揽收'
        when '91' then '包裹包装不符合运输标准'
        when '92' then '客户提供的清单里没有此包裹'
        when '93' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '94' then '客户取消寄件/客户实际不想寄此包裹'
        when '95' then '车辆/人力短缺推迟揽收'
        when '96' then '遗漏揽收(已停用)'
        when '97' then '子母件(一个单号多个包裹)'
        when '98' then '地址错误addresserror'
        when '99' then '包裹不符合揽收条件：超大件'
        when '100' then '包裹不符合揽收条件：违禁品'
        when '101' then '包裹包装不符合运输标准'
        when '102' then '包裹未准备好'
        when '103' then '运力短缺，跟客户协商推迟揽收'
        when '104' then '子母件(一个单号多个包裹)'
        when '105' then '破损包裹'
        when '106' then '空包裹'
        when '107' then '不能打开locker(密码错误)'
        when '108' then 'locker不能使用'
        when '109' then 'locker找不到'
        when '110' then '运单号与实际包裹的单号不一致'
        when '111' then 'box客户取消任务'
        when '112' then '不能打开locker(密码错误)'
        when '113' then 'locker不能使用'
        when '114' then 'locker找不到'
        when '115' then '实际重量尺寸大于客户下单的重量尺寸'
        when '116' then '客户仓库关闭'
        when '117' then '客户仓库关闭'
        when '118' then 'SHOPEE订单系统自动关闭'
        when '119' then '客户取消包裹'
        when '121' then '地址错误'
        when '122' then '当日运力不足，无法揽收'
    end as `疑难原因`
    ,datediff( `current_date`(), di.created_at) `问题件处理天数`
    ,ss.name `揽收网点`
    ,ss2.name` '目的地网点'`
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.ticket_pickup_store_id
            ,datediff(`current_date`(), pi.p_date) dated_diff
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-07-01'
            and pi.p_date < '2022-09-01'
            and pi.state not in ('5', '7', '8', '9')
    ) pi
join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
                where
                    pr.p_date >= '2022-07-01'
                    and pr.p_date < '2022-09-01'
                    and pr.valid_route = '1'
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = pi.pno
left join
    (
        select
            di.*
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.diff_marker_category
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                from fle_dwd.dwd_fle_diff_info_di di
                where
                    di.created_at >= '2022-07-01'
                    and di.created_at < '2023-03-01'
                    and di.state = '0'
            ) di
        where
            di.rk = 1
    ) di on di.pno = pi.pno
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss  on ss.id = pi.ticket_pickup_store_id
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2  on ss2.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.p_date  `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `流向`
    ,pi.client_id
    ,pi.dated_diff `揽收至今天数`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,pr.store_name `当前网点`
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
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
    end `最后一条有效路由`
    ,datediff( `current_date`(), pr.routed_at) `最后有效路由至今日期`
    ,di.diff_marker_category
    ,case di.diff_marker_category
        when '1' then '客户不在家/电话无人接听'
        when '2' then '收件人拒收'
        when '3' then '快件分错网点'
        when '4' then '外包装破损'
        when '5' then '货物破损'
        when '6' then '货物短少'
        when '7' then '货物丢失'
        when '8' then '电话联系不上'
        when '9' then '客户改约时间'
        when '10' then '客户不在'
        when '11' then '客户取消任务'
        when '12' then '无人签收'
        when '13' then '客户周末或假期不收货'
        when '14' then '客户改约时间'
        when '15' then '当日运力不足，无法派送'
        when '16' then '联系不上收件人'
        when '17' then '收件人拒收'
        when '18' then '快件分错网点'
        when '19' then '外包装破损'
        when '20' then '货物破损'
        when '21' then '货物短少'
        when '22' then '货物丢失'
        when '23' then '收件人/地址不清晰或不正确'
        when '24' then '收件地址已废弃或不存在'
        when '25' then '收件人电话号码错误'
        when '26' then 'cod金额不正确'
        when '27' then '无实际包裹'
        when '28' then '已妥投未交接'
        when '29' then '收件人电话号码是空号'
        when '30' then '快件分错网点-地址正确'
        when '31' then '快件分错网点-地址错误'
        when '32' then '禁运品'
        when '33' then '严重破损（丢弃）'
        when '34' then '退件两次尝试派送失败'
        when '35' then '不能打开locker'
        when '36' then 'locker不能使用'
        when '37' then '该地址找不到lockerstation'
        when '38' then '一票多件'
        when '39' then '多次尝试派件失败'
        when '40' then '客户不在家/电话无人接听'
        when '41' then '错过班车时间'
        when '42' then '目的地是偏远地区,留仓待次日派送'
        when '43' then '目的地是岛屿,留仓待次日派送'
        when '44' then '企业/机构当天已下班'
        when '45' then '子母件包裹未全部到达网点'
        when '46' then '不可抗力原因留仓(台风)'
        when '47' then '虚假包裹'
        when '48' then '转交FH包裹留仓'
        when '50' then '客户取消寄件'
        when '51' then '信息录入错误'
        when '52' then '客户取消寄件'
        when '53' then 'lazada仓库拒收'
        when '69' then '禁运品'
        when '70' then '客户改约时间'
        when '71' then '当日运力不足，无法派送'
        when '72' then '客户周末或假期不收货'
        when '73' then '收件人/地址不清晰或不正确'
        when '74' then '收件地址已废弃或不存在'
        when '75' then '收件人电话号码错误'
        when '76' then 'cod金额不正确'
        when '77' then '企业/机构当天已下班'
        when '78' then '收件人电话号码是空号'
        when '79' then '快件分错网点-地址错误'
        when '80' then '客户取消任务'
        when '81' then '重复下单'
        when '82' then '已完成揽件'
        when '83' then '联系不上客户'
        when '84' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '85' then '寄件人电话号码是空号'
        when '86' then '包裹不符合揽收条件超大件'
        when '87' then '包裹不符合揽收条件违禁品'
        when '88' then '寄件人地址为岛屿'
        when '89' then '运力短缺，跟客户协商推迟揽收'
        when '90' then '包裹未准备好推迟揽收'
        when '91' then '包裹包装不符合运输标准'
        when '92' then '客户提供的清单里没有此包裹'
        when '93' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '94' then '客户取消寄件/客户实际不想寄此包裹'
        when '95' then '车辆/人力短缺推迟揽收'
        when '96' then '遗漏揽收(已停用)'
        when '97' then '子母件(一个单号多个包裹)'
        when '98' then '地址错误addresserror'
        when '99' then '包裹不符合揽收条件：超大件'
        when '100' then '包裹不符合揽收条件：违禁品'
        when '101' then '包裹包装不符合运输标准'
        when '102' then '包裹未准备好'
        when '103' then '运力短缺，跟客户协商推迟揽收'
        when '104' then '子母件(一个单号多个包裹)'
        when '105' then '破损包裹'
        when '106' then '空包裹'
        when '107' then '不能打开locker(密码错误)'
        when '108' then 'locker不能使用'
        when '109' then 'locker找不到'
        when '110' then '运单号与实际包裹的单号不一致'
        when '111' then 'box客户取消任务'
        when '112' then '不能打开locker(密码错误)'
        when '113' then 'locker不能使用'
        when '114' then 'locker找不到'
        when '115' then '实际重量尺寸大于客户下单的重量尺寸'
        when '116' then '客户仓库关闭'
        when '117' then '客户仓库关闭'
        when '118' then 'SHOPEE订单系统自动关闭'
        when '119' then '客户取消包裹'
        when '121' then '地址错误'
        when '122' then '当日运力不足，无法揽收'
    end as `疑难原因`
    ,datediff( `current_date`(), di.created_at) `问题件处理天数`
    ,ss.name `揽收网点`
    ,ss2.name` '目的地网点'`
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.ticket_pickup_store_id
            ,datediff(`current_date`(), pi.p_date) dated_diff
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-09-01'
            and pi.p_date < '2022-11-01'
            and pi.state not in ('5', '7', '8', '9')
    ) pi
join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
                where
                    pr.p_date >= '2022-09-01'
                    and pr.p_date < '2022-11-01'
                    and pr.valid_route = '1'
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = pi.pno
left join
    (
        select
            di.*
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.diff_marker_category
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                from fle_dwd.dwd_fle_diff_info_di di
                where
                    di.created_at >= '2022-07-01'
                    and di.created_at < '2023-05-01'
                    and di.state = '0'
            ) di
        where
            di.rk = 1
    ) di on di.pno = pi.pno
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss  on ss.id = pi.ticket_pickup_store_id
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2  on ss2.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.p_date  `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `流向`
    ,pi.client_id
    ,pi.dated_diff `揽收至今天数`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,pr.store_name `当前网点`
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
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
    end `最后一条有效路由`
    ,datediff( `current_date`(), pr.routed_at) `最后有效路由至今日期`
    ,di.diff_marker_category
    ,case di.diff_marker_category
        when '1' then '客户不在家/电话无人接听'
        when '2' then '收件人拒收'
        when '3' then '快件分错网点'
        when '4' then '外包装破损'
        when '5' then '货物破损'
        when '6' then '货物短少'
        when '7' then '货物丢失'
        when '8' then '电话联系不上'
        when '9' then '客户改约时间'
        when '10' then '客户不在'
        when '11' then '客户取消任务'
        when '12' then '无人签收'
        when '13' then '客户周末或假期不收货'
        when '14' then '客户改约时间'
        when '15' then '当日运力不足，无法派送'
        when '16' then '联系不上收件人'
        when '17' then '收件人拒收'
        when '18' then '快件分错网点'
        when '19' then '外包装破损'
        when '20' then '货物破损'
        when '21' then '货物短少'
        when '22' then '货物丢失'
        when '23' then '收件人/地址不清晰或不正确'
        when '24' then '收件地址已废弃或不存在'
        when '25' then '收件人电话号码错误'
        when '26' then 'cod金额不正确'
        when '27' then '无实际包裹'
        when '28' then '已妥投未交接'
        when '29' then '收件人电话号码是空号'
        when '30' then '快件分错网点-地址正确'
        when '31' then '快件分错网点-地址错误'
        when '32' then '禁运品'
        when '33' then '严重破损（丢弃）'
        when '34' then '退件两次尝试派送失败'
        when '35' then '不能打开locker'
        when '36' then 'locker不能使用'
        when '37' then '该地址找不到lockerstation'
        when '38' then '一票多件'
        when '39' then '多次尝试派件失败'
        when '40' then '客户不在家/电话无人接听'
        when '41' then '错过班车时间'
        when '42' then '目的地是偏远地区,留仓待次日派送'
        when '43' then '目的地是岛屿,留仓待次日派送'
        when '44' then '企业/机构当天已下班'
        when '45' then '子母件包裹未全部到达网点'
        when '46' then '不可抗力原因留仓(台风)'
        when '47' then '虚假包裹'
        when '48' then '转交FH包裹留仓'
        when '50' then '客户取消寄件'
        when '51' then '信息录入错误'
        when '52' then '客户取消寄件'
        when '53' then 'lazada仓库拒收'
        when '69' then '禁运品'
        when '70' then '客户改约时间'
        when '71' then '当日运力不足，无法派送'
        when '72' then '客户周末或假期不收货'
        when '73' then '收件人/地址不清晰或不正确'
        when '74' then '收件地址已废弃或不存在'
        when '75' then '收件人电话号码错误'
        when '76' then 'cod金额不正确'
        when '77' then '企业/机构当天已下班'
        when '78' then '收件人电话号码是空号'
        when '79' then '快件分错网点-地址错误'
        when '80' then '客户取消任务'
        when '81' then '重复下单'
        when '82' then '已完成揽件'
        when '83' then '联系不上客户'
        when '84' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '85' then '寄件人电话号码是空号'
        when '86' then '包裹不符合揽收条件超大件'
        when '87' then '包裹不符合揽收条件违禁品'
        when '88' then '寄件人地址为岛屿'
        when '89' then '运力短缺，跟客户协商推迟揽收'
        when '90' then '包裹未准备好推迟揽收'
        when '91' then '包裹包装不符合运输标准'
        when '92' then '客户提供的清单里没有此包裹'
        when '93' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '94' then '客户取消寄件/客户实际不想寄此包裹'
        when '95' then '车辆/人力短缺推迟揽收'
        when '96' then '遗漏揽收(已停用)'
        when '97' then '子母件(一个单号多个包裹)'
        when '98' then '地址错误addresserror'
        when '99' then '包裹不符合揽收条件：超大件'
        when '100' then '包裹不符合揽收条件：违禁品'
        when '101' then '包裹包装不符合运输标准'
        when '102' then '包裹未准备好'
        when '103' then '运力短缺，跟客户协商推迟揽收'
        when '104' then '子母件(一个单号多个包裹)'
        when '105' then '破损包裹'
        when '106' then '空包裹'
        when '107' then '不能打开locker(密码错误)'
        when '108' then 'locker不能使用'
        when '109' then 'locker找不到'
        when '110' then '运单号与实际包裹的单号不一致'
        when '111' then 'box客户取消任务'
        when '112' then '不能打开locker(密码错误)'
        when '113' then 'locker不能使用'
        when '114' then 'locker找不到'
        when '115' then '实际重量尺寸大于客户下单的重量尺寸'
        when '116' then '客户仓库关闭'
        when '117' then '客户仓库关闭'
        when '118' then 'SHOPEE订单系统自动关闭'
        when '119' then '客户取消包裹'
        when '121' then '地址错误'
        when '122' then '当日运力不足，无法揽收'
    end as `疑难原因`
    ,datediff( `current_date`(), di.created_at) `问题件处理天数`
    ,ss.name `揽收网点`
    ,ss2.name` '目的地网点'`
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.ticket_pickup_store_id
            ,datediff(`current_date`(), pi.p_date) dated_diff
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-11-01'
            and pi.p_date < '2023-01-01'
            and pi.state not in ('5', '7', '8', '9')
    ) pi
join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
                where
                    pr.p_date >= '2023-11-01'
                    and pr.p_date < '2023-01-01'
                    and pr.valid_route = '1'
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = pi.pno
left join
    (
        select
            di.*
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.diff_marker_category
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                from fle_dwd.dwd_fle_diff_info_di di
                where
                    di.created_at >= '2022-11-01'
--                     and di.created_at < '2023-0-01'
                    and di.state = '0'
            ) di
        where
            di.rk = 1
    ) di on di.pno = pi.pno
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss  on ss.id = pi.ticket_pickup_store_id
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2  on ss2.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,pi.p_date  `揽收日期`
    ,`if`(pi.returned = '1', '退件', '正向') `流向`
    ,pi.client_id
    ,pi.dated_diff `揽收至今天数`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,pr.store_name `当前网点`
    ,case pr.store_category
      when '1' then 'SP'
      when '2' then 'DC'
      when '4' then 'SHOP'
      when '5' then 'SHOP'
      when '6' then 'FH'
      when '7' then 'SHOP'
      when '8' then 'Hub'
      when '9' then 'Onsite'
      when '10' then 'BDC'
      when '11' then 'fulfillment'
      when '12' then 'B-HUB'
      when '13' then 'CDC'
      when '14' then 'PDC'
    end `当前网点类型`
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
    end `最后一条有效路由`
    ,datediff( `current_date`(), pr.routed_at) `最后有效路由至今日期`
    ,di.diff_marker_category
    ,case di.diff_marker_category
        when '1' then '客户不在家/电话无人接听'
        when '2' then '收件人拒收'
        when '3' then '快件分错网点'
        when '4' then '外包装破损'
        when '5' then '货物破损'
        when '6' then '货物短少'
        when '7' then '货物丢失'
        when '8' then '电话联系不上'
        when '9' then '客户改约时间'
        when '10' then '客户不在'
        when '11' then '客户取消任务'
        when '12' then '无人签收'
        when '13' then '客户周末或假期不收货'
        when '14' then '客户改约时间'
        when '15' then '当日运力不足，无法派送'
        when '16' then '联系不上收件人'
        when '17' then '收件人拒收'
        when '18' then '快件分错网点'
        when '19' then '外包装破损'
        when '20' then '货物破损'
        when '21' then '货物短少'
        when '22' then '货物丢失'
        when '23' then '收件人/地址不清晰或不正确'
        when '24' then '收件地址已废弃或不存在'
        when '25' then '收件人电话号码错误'
        when '26' then 'cod金额不正确'
        when '27' then '无实际包裹'
        when '28' then '已妥投未交接'
        when '29' then '收件人电话号码是空号'
        when '30' then '快件分错网点-地址正确'
        when '31' then '快件分错网点-地址错误'
        when '32' then '禁运品'
        when '33' then '严重破损（丢弃）'
        when '34' then '退件两次尝试派送失败'
        when '35' then '不能打开locker'
        when '36' then 'locker不能使用'
        when '37' then '该地址找不到lockerstation'
        when '38' then '一票多件'
        when '39' then '多次尝试派件失败'
        when '40' then '客户不在家/电话无人接听'
        when '41' then '错过班车时间'
        when '42' then '目的地是偏远地区,留仓待次日派送'
        when '43' then '目的地是岛屿,留仓待次日派送'
        when '44' then '企业/机构当天已下班'
        when '45' then '子母件包裹未全部到达网点'
        when '46' then '不可抗力原因留仓(台风)'
        when '47' then '虚假包裹'
        when '48' then '转交FH包裹留仓'
        when '50' then '客户取消寄件'
        when '51' then '信息录入错误'
        when '52' then '客户取消寄件'
        when '53' then 'lazada仓库拒收'
        when '69' then '禁运品'
        when '70' then '客户改约时间'
        when '71' then '当日运力不足，无法派送'
        when '72' then '客户周末或假期不收货'
        when '73' then '收件人/地址不清晰或不正确'
        when '74' then '收件地址已废弃或不存在'
        when '75' then '收件人电话号码错误'
        when '76' then 'cod金额不正确'
        when '77' then '企业/机构当天已下班'
        when '78' then '收件人电话号码是空号'
        when '79' then '快件分错网点-地址错误'
        when '80' then '客户取消任务'
        when '81' then '重复下单'
        when '82' then '已完成揽件'
        when '83' then '联系不上客户'
        when '84' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '85' then '寄件人电话号码是空号'
        when '86' then '包裹不符合揽收条件超大件'
        when '87' then '包裹不符合揽收条件违禁品'
        when '88' then '寄件人地址为岛屿'
        when '89' then '运力短缺，跟客户协商推迟揽收'
        when '90' then '包裹未准备好推迟揽收'
        when '91' then '包裹包装不符合运输标准'
        when '92' then '客户提供的清单里没有此包裹'
        when '93' then '包裹不符合揽收条件（超大件、违禁物品）'
        when '94' then '客户取消寄件/客户实际不想寄此包裹'
        when '95' then '车辆/人力短缺推迟揽收'
        when '96' then '遗漏揽收(已停用)'
        when '97' then '子母件(一个单号多个包裹)'
        when '98' then '地址错误addresserror'
        when '99' then '包裹不符合揽收条件：超大件'
        when '100' then '包裹不符合揽收条件：违禁品'
        when '101' then '包裹包装不符合运输标准'
        when '102' then '包裹未准备好'
        when '103' then '运力短缺，跟客户协商推迟揽收'
        when '104' then '子母件(一个单号多个包裹)'
        when '105' then '破损包裹'
        when '106' then '空包裹'
        when '107' then '不能打开locker(密码错误)'
        when '108' then 'locker不能使用'
        when '109' then 'locker找不到'
        when '110' then '运单号与实际包裹的单号不一致'
        when '111' then 'box客户取消任务'
        when '112' then '不能打开locker(密码错误)'
        when '113' then 'locker不能使用'
        when '114' then 'locker找不到'
        when '115' then '实际重量尺寸大于客户下单的重量尺寸'
        when '116' then '客户仓库关闭'
        when '117' then '客户仓库关闭'
        when '118' then 'SHOPEE订单系统自动关闭'
        when '119' then '客户取消包裹'
        when '121' then '地址错误'
        when '122' then '当日运力不足，无法揽收'
    end as `疑难原因`
    ,datediff( `current_date`(), di.created_at) `问题件处理天数`
    ,ss.name `揽收网点`
    ,ss2.name` '目的地网点'`
from
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
            ,pi.client_id
            ,pi.p_date
            ,pi.dst_store_id
            ,pi.ticket_pickup_store_id
            ,datediff(`current_date`(), pi.p_date) dated_diff
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-11-01'
            and pi.p_date < '2023-01-01'
            and pi.state not in ('5', '7', '8', '9')
    ) pi
join
    (
        select
            a.*
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,pr.store_category
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.route_action
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
                where
                    pr.p_date >= '2022-11-01'
                    and pr.p_date < '2023-01-01'
                    and pr.valid_route = '1'
            ) a
        where
            a.rk = 1
    ) pr on pr.pno = pi.pno
left join
    (
        select
            di.*
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.diff_marker_category
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rk
                from fle_dwd.dwd_fle_diff_info_di di
                where
                    di.created_at >= '2022-11-01'
--                     and di.created_at < '2023-0-01'
                    and di.state = '0'
            ) di
        where
            di.rk = 1
    ) di on di.pno = pi.pno
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss  on ss.id = pi.ticket_pickup_store_id
left join
    (
        select
            ss.id
            ,ss.name
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2  on ss2.id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
        t.pno
        ,t.name
        ,a1.created_at
        ,a1.finished_at
        ,a1.client_id
        ,a1.src_name
        ,a1.src_phone
        ,a1.src_detail_address
        ,a1.dst_name
        ,a1.dst_phone
        ,a1.dst_detail_address
        ,case a1.article_category
            when '0' then '文件เอกสาร'
            when '1' then '干燥食品อาหารแห้ง'
            when '2' then '日用品ของใช้ประจำวัน'
            when '3' then '数码商品สินค้าดิจิตอล'
            when '4' then '衣物เสื้อผ้า'
            when '5' then '书刊หนังสือและวารสาร'
            when '6' then '汽车配件อะไหล่รถยนต์'
            when '7' then '鞋包ถุงใส่รองเท้า/กระเป๋าใส่รองเท้า'
            when '8' then '体育器材 อุปกรณ์กีฬา'
            when '9' then '化妆品เครื่องสำอาง'
            when '10' then '家具用具เครื่องใช้ภายในบ้าน'
            when '11' then '水果ผลไม้'
            when '99' then '其他อื่นๆ'
        end as `物品类型ประเภทสินค้า`
        ,cast(a1.cod_amount as int)/100 cod_total
        ,a1.exhibition_weight
        ,concat_ws('*', a1.exhibition_length, a1.exhibition_width, a1.exhibition_height) chicun
        ,s1.name s1_name
        ,s2.name s2_name
        ,case a1.state
            when '1' then '已揽收 รับพัสดุแล้ว'
            when '2' then '运输中 ระหว่างการขนส่ง'
            when '3' then '派送中 ระหว่างการจัดส่ง'
            when '4' then '已滞留 พัสดุคงคลัง'
            when '5' then '已签收 เซ็นรับแล้ว'
            when '6' then '疑难件处理中 ระหว่างจัดการพัสดุมีปัญหา'
            when '7' then '已退件 ตีกลับแล้ว'
            when '8' then '异常关闭 ปิดงานมีปัญหา'
            when '9' then '已撤销 ยกเลิกแล้ว'
        end `包裹状态`
        ,group_concat(concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',a2.object_key)) `签名`
    from test.tmp_th_m_pno_0628 t
    left join
        (
            select
                pi.*
            from
                (
                    select
                        pi.pno
                        ,pi.created_at
                        ,pi.state
                        ,pi.finished_at
                        ,pi.client_id
                        ,pi.src_name
                        ,pi.src_phone
                        ,pi.src_detail_address
                        ,pi.dst_name
                        ,pi.dst_phone
                        ,pi.dst_detail_address
                        ,pi.article_category
                        ,pi.cod_amount
                        ,pi.exhibition_weight
                        ,pi.exhibition_length
                        ,pi.exhibition_width
                        ,pi.exhibition_height
                        ,pi.ticket_pickup_store_id
                        ,pi.ticket_delivery_store_id
                    from fle_dwd.dwd_fle_parcel_info_di pi
                    where
                        pi.p_date >= '2023-02-01'
                        and pi.p_date < '2023-03-01'
                ) pi
            join test.tmp_th_m_pno_0628 t on pi.pno = t.pno
        ) a1 on a1.pno = t.pno
    left join
        (
            select
                sa.*
            from
                (
                    select
                        sa.oss_bucket_key
                        ,sa.oss_bucket_type
                        ,sa.bucket_name
                        ,sa.object_key
                    from fle_dwd.dwd_fle_sys_attachment_di sa
                    where
                        sa.p_date >= '2023-02-01'
                        and sa.p_date < '2023-04-01'
                        and sa.oss_bucket_type = 'DELIVERY_CONFIRM'
                ) sa
            join test.tmp_th_m_pno_0628 t on sa.oss_bucket_key = t.pno
        ) a2 on a2.oss_bucket_key = a1.pno
    left join
        (
            select
                *
            from fle_dim.dim_fle_sys_store_da ss
            where
                ss.p_date = date_sub(`current_date`(), 1)
        ) s1 on s1.id = a1.ticket_pickup_store_id
    left join
        (
            select
                *
            from fle_dim.dim_fle_sys_store_da ss
            where
                ss.p_date = date_sub(`current_date`(), 1)
        ) s2 on s2.id = a1.ticket_delivery_store_id
    group by t.pno;
;-- -. . -..- - / . -. - .-. -.--
select
        t.pno
        ,t.name
        ,a1.created_at
        ,a1.finished_at
        ,a1.client_id
        ,a1.src_name
        ,a1.src_phone
        ,a1.src_detail_address
        ,a1.dst_name
        ,a1.dst_phone
        ,a1.dst_detail_address
        ,case a1.article_category
            when '0' then '文件เอกสาร'
            when '1' then '干燥食品อาหารแห้ง'
            when '2' then '日用品ของใช้ประจำวัน'
            when '3' then '数码商品สินค้าดิจิตอล'
            when '4' then '衣物เสื้อผ้า'
            when '5' then '书刊หนังสือและวารสาร'
            when '6' then '汽车配件อะไหล่รถยนต์'
            when '7' then '鞋包ถุงใส่รองเท้า/กระเป๋าใส่รองเท้า'
            when '8' then '体育器材 อุปกรณ์กีฬา'
            when '9' then '化妆品เครื่องสำอาง'
            when '10' then '家具用具เครื่องใช้ภายในบ้าน'
            when '11' then '水果ผลไม้'
            when '99' then '其他อื่นๆ'
        end as `物品类型ประเภทสินค้า`
        ,cast(a1.cod_amount as int)/100 cod_total
        ,a1.exhibition_weight
        ,concat_ws('*', a1.exhibition_length, a1.exhibition_width, a1.exhibition_height) chicun
        ,s1.name s1_name
        ,s2.name s2_name
        ,case a1.state
            when '1' then '已揽收 รับพัสดุแล้ว'
            when '2' then '运输中 ระหว่างการขนส่ง'
            when '3' then '派送中 ระหว่างการจัดส่ง'
            when '4' then '已滞留 พัสดุคงคลัง'
            when '5' then '已签收 เซ็นรับแล้ว'
            when '6' then '疑难件处理中 ระหว่างจัดการพัสดุมีปัญหา'
            when '7' then '已退件 ตีกลับแล้ว'
            when '8' then '异常关闭 ปิดงานมีปัญหา'
            when '9' then '已撤销 ยกเลิกแล้ว'
        end `包裹状态`
        ,group_concat(concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',a2.object_key)) `签名`
    from test.tmp_th_m_pno_0628 t
    left join
        (
            select
                pi.*
            from
                (
                    select
                        pi.pno
                        ,pi.created_at
                        ,pi.state
                        ,pi.finished_at
                        ,pi.client_id
                        ,pi.src_name
                        ,pi.src_phone
                        ,pi.src_detail_address
                        ,pi.dst_name
                        ,pi.dst_phone
                        ,pi.dst_detail_address
                        ,pi.article_category
                        ,pi.cod_amount
                        ,pi.exhibition_weight
                        ,pi.exhibition_length
                        ,pi.exhibition_width
                        ,pi.exhibition_height
                        ,pi.ticket_pickup_store_id
                        ,pi.ticket_delivery_store_id
                    from fle_dwd.dwd_fle_parcel_info_di pi
                    where
                        pi.p_date >= '2023-02-01'
                        and pi.p_date < '2023-03-01'
                ) pi
            join test.tmp_th_m_pno_0628 t on pi.pno = t.pno
        ) a1 on a1.pno = t.pno
    left join
        (
            select
                sa.*
            from
                (
                    select
                        sa.oss_bucket_key
                        ,sa.oss_bucket_type
                        ,sa.bucket_name
                        ,sa.object_key
                    from fle_dwd.dwd_fle_sys_attachment_di sa
                    where
                        sa.p_date >= '2023-02-01'
                        and sa.p_date < '2023-04-01'
                        and sa.oss_bucket_type = 'DELIVERY_CONFIRM'
                ) sa
            join test.tmp_th_m_pno_0628 t on sa.oss_bucket_key = t.pno
        ) a2 on a2.oss_bucket_key = a1.pno
    left join
        (
            select
                *
            from fle_dim.dim_fle_sys_store_da ss
            where
                ss.p_date = date_sub(`current_date`(), 1)
        ) s1 on s1.id = a1.ticket_pickup_store_id
    left join
        (
            select
                *
            from fle_dim.dim_fle_sys_store_da ss
            where
                ss.p_date = date_sub(`current_date`(), 1)
        ) s2 on s2.id = a1.ticket_delivery_store_id
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from fle_dwd.dwd_rot_parcel_route_di pr
        where
            pr.p_date >= '2022-12-01'
            and pr.route_action in ('DELIVERY_PICKUP_STORE_SCAN','SHIPMENT_WAREHOUSE_SCAN','RECEIVE_WAREHOUSE_SCAN','DIFFICULTY_HANDOVER','ARRIVAL_GOODS_VAN_CHECK_SCAN','FLASH_HOME_SCAN','RECEIVED','SEAL','UNSEAL','DISCARD_RETURN_BKK','REFUND_CONFIRM','ARRIVAL_WAREHOUSE_SCAN','DELIVERY_TRANSFER','DELIVERY_CONFIRM','STORE_KEEPER_UPDATE_WEIGHT','REPLACE_PNO','PICKUP_RETURN_RECEIPT','DETAIN_WAREHOUSE','DELIVERY_MARKER','DISTRIBUTION_INVENTORY','PARCEL_HEADLESS_PRINTED','STORE_SORTER_UPDATE_WEIGHT','SORTING_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','DELIVERY_TICKET_CREATION_SCAN','INVENTORY','STAFF_INFO_UPDATE_WEIGHT','ACCEPT_PARCEL')
)
select
    plt.pno `运单号`
    ,plt.updated_at `判责时间`
    ,t1.routed_at `最后有效路由时间`
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
from
    (
        select
            plt.pno
            ,plt.updated_at
        from fle_dwd.dwd_bi_parcel_lose_task_di plt
        where
            plt.p_date >= '2022-12-01'
            and plt.state = '6'
    ) plt
join
    (
        select
            pi.pno
            ,pi.state
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-12-01'
            and  pi.state not in ('5','7','8','9')
    ) pi on plt.pno = pi.pno
left join t t1 on t1.pno = pi.pno and t1.rk = 1
where
    t1.routed_at < plt.updated_at;
;-- -. . -..- - / . -. - .-. -.--
select * from test.tmp_th_m_pno_0628;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
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
    end as `路由`
    ,pr.routed_at `路由时间`
from test.tmp_plt_pno_0728 t
left join
    (
        select
            pr.route_action
            ,pr.routed_at
            ,pr.pno
        from fle_dwd.dwd_rot_parcel_route_di pr
        where
            pr.p_date >= '2023-01-01'
    ) pr on pr.pno = t.pno and pr.routed_at < t.task_created_at;