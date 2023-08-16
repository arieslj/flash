
with  b as
(
    select
        coalesce(a2.client_name, '总计') client_name
        ,coalesce(a2.疑难件原因, '总计') 疑难件原因
        ,a2.`20-9单量`
        ,a2.`前日20-今日9点处理完成量`
        ,a2.`20-9点11点处理完成量`
        ,a2.`9-20单量`
        ,a2.`9-20已处理单量`
        ,a2.`9-20已处理2小时内量`
    from
        (
           select
                case
                    when bc.`client_id` is not null then bc.client_name
                    when kp.id is not null and bc.client_id is null then '普通ka'
                    when kp.`id` is null then '小c'
                end client_name
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
                    when 23 then '详细地址错误'
                    when 24 then '收件地址已废弃或不存在'
                    when 25 then '收件人电话号码错误'
                    when 26 then 'cod金额不正确'
                    when 27 then '无实际包裹'
                    when 28 then '已妥投未交接'
                    when 29 then '收件人电话号码是空号'
                    when 30 then '送错网点'
                    when 31 then '省市乡邮编错误'
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
                    when 73 then '详细地址错误'
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
                end as 疑难件原因
                ,count(if(di.created_at >= date_sub('${date1}', interval 12 hour) and di.created_at < date_add('${date1}', interval  1 hour), di.id, null)) '20-9单量'
                ,count(if(di.created_at >= date_sub('${date1}', interval 12 hour) and di.created_at < date_add('${date1}', interval  1 hour) and cdt.state = 1 , di.id, null)) '前日20-今日9点处理完成量'
                ,count(if(di.created_at >= date_sub('${date1}', interval 12 hour) and di.created_at < date_add('${date1}', interval  1 hour) and cdt.state = 1 and cdt.updated_at < date_add('${date1}', interval  3 hour ) , di.id, null)) '20-9点11点处理完成量'
                ,count(if(di.created_at >= date_add('${date1}', interval  1 hour) and di.created_at < date_add('${date1}', interval 12 hour), di.id, null)) '9-20单量'
                ,count(if(di.created_at >= date_add('${date1}', interval  1 hour) and di.created_at < date_add('${date1}', interval 12 hour) and cdt.state = 1 , di.id, null)) '9-20已处理单量'
                ,count(if(di.created_at >= date_add('${date1}', interval  1 hour) and di.created_at < date_add('${date1}', interval 12 hour) and cdt.state = 1 and cdt.updated_at < date_add(di.created_at, interval  2 hour ), di.id, null)) '9-20已处理2小时内量'
            from ph_staging.diff_info di
            join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join ph_staging.store_diff_ticket sdt2 on sdt2.diff_info_id = di.id
#             left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada', 'shopee', 'tiktok')
            left join ph_staging.ka_profile kp on kp.id = pi.client_id
            left join nl_production.violation_return_visit vrv on vrv.type in (3,8)  and json_extract(vrv.extra_value, '$.diff_id') = di.id
            left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
            where
                di.diff_marker_category not in (7,22,5,20,6,21,15,71,34,69,32,39,53,28)
                and di.created_at >= date_sub('${date1}', interval 12 hour)
                and di.created_at < date_add('${date1}', interval 12 hour )
                and vrv.link_id is null
                and ss.category = 6
            group by 1,2
            with rollup
        ) a2
)
select
    b1.client_name
    ,b1.疑难件原因
    ,b1.`20-9单量`
    ,b1.`前日20-今日9点处理完成量`
    ,b1.`20-9点11点处理完成量`
    ,b1.`9-20单量`
    ,b1.`9-20已处理单量`
    ,b1.`9-20已处理2小时内量`
from  b b1
order by
    case b1.client_name
        when 'lazada' then 1
        when 'shopee' then 2
        when 'tiktok' then 3
        when '普通ka' then 4
        when '小c' then 5
        when '总计' then 6
    end
    ,case b1.疑难件原因
        when '总计' then 1
        when '详细地址错误' then 2
        when '收件人电话号码是空号' then 3
        when '收件人电话号码错误' then 4
        when '省市乡邮编错误' then 5
        when '收件人拒收' then 6
    end
