select
    di.pno
    ,cdt.id
    ,di.diff_marker_category
    ,case di.diff_marker_category # 疑难原因
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
        when 48 then '转交FH包裹留仓'
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
        end as 疑难原因
    ,convert_tz(di.created_at, '+00:00', '+08:00') 进入疑难件时间
    ,now() 当前时间
    ,if(plt.id is not null , '是', '否') 是否进入闪速
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 闪速认定任务状态
    ,if(timestampdiff(second ,convert_tz(di.created_at, '+00:00', '+08:00') ,now())/3600 > 24, '是', '否') 是否超24小时
    ,concat(timestampdiff(day,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'D', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00'), now())%24, 'H') 时间差
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
where
    di.state = 0
    and pi.state not in (5,7,8,9)
;

select
    a1.*
from
    (
        select
            plt.pno
            ,plt.state
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end 客户类型
            ,if(pi.state in (5,7,8,9), '是', '否') 包裹是否终态
            ,if(plt.created_at > convert_tz(pi.finished_at , '+00:00', '+08:00'), '是', '否') 是否终态后进入闪速
            ,case plt.source
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
                when 11 then 'K-超时效包裹'
                when 12 then 'L-高度疑似丢失'
            end 问题来源渠道
            ,plt.source
            ,concat(timestampdiff(day ,plt.created_at  ,now()), 'D', timestampdiff(hour ,plt.created_at  ,now())%24, 'H') 进入闪速时间
            ,if(timestampdiff(hour ,plt.created_at  ,now())/3600 > 24, '是', '否' ) 是否超24小时
            ,timestampdiff(second ,plt.created_at  ,now())/3600 time_diff
            ,case plt.state
                when 1 then '丢失件待处理'
                when 2 then '疑似丢失件待处理'
                when 3 then '待工单回复'
                when 4 then '已工单回复'
                when 5 then '包裹未丢失'
                when 6 then '丢失件处理完成'
            end 闪速认定任务状态
        from ph_bi.parcel_lose_task plt
        left join ph_staging.parcel_info pi on pi.pno = plt.pno
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            plt.state in (1,2,3,4)
    ) a1
where
    ( a1.source = 3 and a1.time_diff > 48 )
    or a1.source !=3