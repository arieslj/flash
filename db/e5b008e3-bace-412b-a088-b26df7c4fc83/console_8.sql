
with a as
(
    select
        coalesce(a.client_name, '总计') client_name
        ,coalesce(a.疑难件原因, '总计') 疑难件原因
        ,a.`0-2小时`
        ,a.`2-4小时`
        ,a.`4-6小时`
        ,a.`6小时以上`
        ,a.总疑难件量
        ,a.继续配送
        ,a.退货
        ,a.平均处理时长_h
    from
        (
            select
                bc.client_name
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
                ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
                ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
                ,count(if(timestampdiff(second , cdt.created_at, cdt.updated_at)/3600 < 2, di.id, null)) '0-2小时'
                ,count(if(timestampdiff(second , cdt.created_at, cdt.updated_at)/3600 >= 2 and timestampdiff(second , cdt.created_at, cdt.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
                ,count(if(timestampdiff(second , cdt.created_at, cdt.updated_at)/3600 >= 4 and timestampdiff(second , cdt.created_at, cdt.updated_at)/3600 < 6, di.id, null )) '4-6小时'
                ,count(if(timestampdiff(second , cdt.created_at, cdt.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
                ,sum(if(cdt.operator_id not in (10000,10001,100002), timestampdiff(second , cdt.created_at, cdt.updated_at)/3600, null))/count(if(cdt.operator_id not in (10000,10001,100002), di.id, null)) 平均处理时长_h
                ,count(di.id) 总疑难件量
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join ph_staging.store_diff_ticket sdt on sdt.diff_info_id = di.id
#             left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.updated_at >= date_sub('${date1}', interval 8 hour )
                and di.updated_at < date_add('${date1}', interval 16 hour ) -- 今日处理
                and cdt.state = 1 -- 已处理
                and if(bc.client_name in ('shopee', 'tiktok'), di.diff_marker_category in (23,73,29,78,25,75,31,79), di.diff_marker_category in (23,73,29,78,25,75,31,79,17))
            group by 1,2
            with rollup
        ) a
    order by 1,2
)
, b as
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
                bc.client_name
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
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 8 and vrv.created_at > date_add(di.created_at, interval 8 hour)
            where
                if(bc.client_name in ('shopee', 'tiktok'), di.diff_marker_category in (23,73,29,78,25,75,31,79), di.diff_marker_category in (23,73,29,78,25,75,31,79,17))
                and di.created_at >= date_sub('${date1}', interval 12 hour)
                and di.created_at < date_add('${date1}', interval 12 hour )
                and vrv.link_id is null
            group by 1,2
            with rollup
        ) a2
)
select
    t1.client_name
    ,t1.疑难件原因
    ,a1.`0-2小时`
    ,a1.`2-4小时`
    ,a1.`4-6小时`
    ,a1.`6小时以上`
    ,a1.继续配送
    ,a1.退货
    ,a1.平均处理时长_h
    ,a1.总疑难件量
    ,b1.`20-9单量`
    ,b1.`前日20-今日9点处理完成量`
    ,b1.`20-9点11点处理完成量`
    ,b1.`9-20单量`
    ,b1.`9-20已处理单量`
    ,b1.`9-20已处理2小时内量`
from
    (
        select
            t1.疑难件原因
            ,t1.client_name
        from
            (
                select
                    a.client_name
                    ,a.疑难件原因
                from a

                union

                select
                    b.client_name
                    ,b.疑难件原因
                from b
            ) t1
        group by 1,2
    ) t1
left join a a1 on t1.client_name = a1.client_name and t1.疑难件原因 = a1.疑难件原因
left join b b1 on t1.client_name = b1.client_name and t1.疑难件原因 = b1.疑难件原因
order by t1.client_name,case t1.疑难件原因
                            when '总计' then 1
                            when '详细地址错误' then 2
                            when '收件人电话号码是空号' then 3
                            when '收件人电话号码错误' then 4
                            when '省市乡邮编错误' then 5
                            when '收件人拒收' then 6
                        end

;











select
    coalesce(a2.vrv_type, '总计') 回访类型
    ,coalesce(a2.client_name, '总计') 客户
    ,a2.`昨日20-今日20单量`
    ,a2.`昨日20-今日20处理完成单量`
    ,a2.`昨日20-今日20处理及时完成单量`
from
    (
        select
            case a.type
                when 1 then '揽件任务异常取消'
                when 2 then '虚假妥投'
                when 3 then '收件人拒收'
                when 4 then '标记客户改约时间'
                when 5 then 'KA现场不揽收'
                when 6 then '包裹未准备好'
                when 7 then '上报错分未妥投'
                when 8 then '多次尝试派送失败'
            end vrv_type
            ,a.client_name
            ,count(a.id) '昨日20-今日20单量'
            ,count(if(a.visit_state in (3,4), a.id, null)) '昨日20-今日20处理完成单量'
            ,count(if(a.beyond_time = 'y', a.id, null)) '昨日20-今日20处理及时完成单量'
        from
            (
                select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.type
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,vrv.updated_at
                    ,vrv.visit_num
                    ,case
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then 'n'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'

                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) > 240 then 'n'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
                where
                    vrv.created_at >= date_sub('${date1}', interval 4 hour)
                    and vrv.created_at < date_add('${date1}', interval 20 hour)
                    and vrv.type in  (3,8)
            ) a
        group by 1,2
        with rollup
    ) a2
order by case  a2.vrv_type
            when '收件人拒收' then 1
            when '多次尝试派送失败' then 2
            when '总计' then 3
        end desc ,
        case  a2.client_name
            when 'lazada' then 1
            when 'tiktok' then 2
            when 'shopee' then 3
            when '总计' then 4
        end desc



;

#20-9


select
	 di.pno '运单号'
     ,dd.client_name 客户名称
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
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
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
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
    end as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,if(cdt.state = 1, '已处理', '未处理完成') '疑难件处理情况'
	 ,if(cdt.state=1,convert_tz(cdt.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
# 	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
# 	 ,datediff(now(),if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ) '未处理当前时间-上报时间/d'
#     ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
    ,case
        when di.created_at >= date_add('${date1}', interval 12 hour ) then '当日20点后'
        when di.created_at < date_add('${date1}', interval 12 hour ) and di.created_at >= date_sub('${date1}', interval 8 hour ) then '积压时间 0 day'
        when di.created_at < date_sub('${date1}', interval 8 hour ) then concat('积压时间', datediff('${date1}', convert_tz(di.created_at , '+00:00', '+08:00'), ' day'))
    end 积压时长
    ,case
        when cdt.state = 1 and cdt.updated_at <= date_add('${date1}', interval  3 hour ) then '及时'
        when cdt.state = 1 and cdt.updated_at > date_add('${date1}', interval  3 hour ) then '不及时'
        else null
    end 是否及时
from ph_staging.diff_info di
# left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 8 and vrv.visit_state = 1
where
    if(dd.client_name in ('shopee', 'tiktok'), di.diff_marker_category in (23,73,29,78,25,75,31,79), di.diff_marker_category in (23,73,29,78,25,75,31,79,17))
    and di.created_at >= date_sub('${date1}', interval 12 hour)
    and di.created_at < date_add('${date1}', interval  1 hour)
    and vrv.link_id is null


;

# 9-20


select
	 di.pno '运单号'
     ,dd.client_name 客户名称
	 ,convert_tz(pi.created_at,'+00:00','+08:00') '揽收日期'
	 ,ss.name '揽收网点'
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
		  ELSE pi.state
		  end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
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
        end  as ' 疑难件原因 '
	 ,convert_tz(di.created_at,'+00:00','+08:00') '上报时间'
     ,date(convert_tz(di.created_at,'+00:00','+08:00')) '上报日期'
	 ,di.staff_info_id '上报人'
	 ,hi.name '上报人姓名'
	 ,sd.name '处理机构'
	 ,cdt.operator_id '客服操作人ID'
	 ,convert_tz(cdt.first_operated_at,'+00:00','+08:00') '第一次处理时间'
	 ,ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00')) '最后一次处理时间'
	 ,case cdt.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  when 2 then '正在沟通中'
		  when 3 then '财务驳回'
		  when 4 then '客户未处理'
		  when 5 then '转交闪速系统'
		  when 6 then '转交QAQC'
		  else cdt.state
		  end '客服处理情况'

     ,case cdt.negotiation_result_category
          when 1 then '赔偿'
          when 2        then '关闭订单(不赔偿不退货)'
          when 3        then'退货'
          when 4        then '退货并赔偿'
          when 5        then '继续配送'
          when 6        then '继续配送并赔偿'
          when 7        then '正在沟通中'
          when 8        then '丢弃包裹的，换单后寄回BKK'
          when 9        then '货物找回，继续派送'
          when 10       then  '改包裹状态'
          when 11       then '需客户修改信息'
          when 12       then '丢弃并赔偿（包裹发到内部拍卖仓）'
	  end '处理结果'
	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),ifnull(convert_tz(cdt.last_operated_at,'+00:00','+08:00'),convert_tz(cdt.first_operated_at,'+00:00','+08:00'))) '客服处理-上报时长/h'
	 ,case di.state
		  when 0 then '未处理'
		  when 1 then '已处理'
		  else di.state
      end '疑难件处理情况'
	 ,if(di.state=1,convert_tz(cdt.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
# 	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
# 	 ,datediff(now(),if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ) '未处理当前时间-上报时间/d'
#     ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
    ,case
        when di.created_at >= date_add('${date1}', interval 12 hour ) then '当日20点后'
        when di.created_at < date_add('${date1}', interval 12 hour ) and di.created_at >= date_sub('${date1}', interval 8 hour ) then '积压时间 0 day'
        when di.created_at < date_sub('${date1}', interval 8 hour ) then concat('积压时间', datediff('${date1}', convert_tz(di.created_at , '+00:00', '+08:00'), ' day'))
    end 积压时长
    ,case
        when cdt.state = 1 and cdt.updated_at <= date_add(cdt.created_at, interval  2 hour) then '及时'
        when cdt.state = 1 and cdt.updated_at > date_add(cdt.created_at, interval  2 hour) then '不及时'
        else null
    end 是否及时
    ,if(di.state = 1 , round(timestampdiff(second, di.created_at, di.updated_at )/ 3600, 2), null) 处理时长_h
from ph_staging.diff_info di
# left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
left join nl_production.violation_return_visit vrv on vrv.link_id = di.pno and vrv.type = 8 and vrv.visit_state = 1
where
    if(dd.client_name in ('shopee', 'tiktok'), di.diff_marker_category in (23,73,29,78,25,75,31,79), di.diff_marker_category in (23,73,29,78,25,75,31,79,17))
    and di.created_at >= date_add('${date1}', interval  1 hour)
    and di.created_at < date_add('${date1}', interval 12 hour)
    and vrv.link_id is null


;


select
    vrv.link_id 运单号
    ,case vrv.type
        when 1 then '揽件任务异常取消'
        when 2 then '虚假妥投'
        when 3 then '收件人拒收'
        when 4 then '标记客户改约时间'
        when 5 then 'KA现场不揽收'
        when 6 then '包裹未准备好'
        when 7 then '上报错分未妥投'
        when 8 then '多次尝试派送失败'
    end 违规类型
    ,bc.client_name 客户明细
    ,case vrv.visit_state
        when 1 then '待回访'
        when 2 then '沟通中'
        when 3 then '多次未联系上客户'
        when 4 then '已回访'
        when 5 then '因同包裹生成其他回访任务关闭'
        when 6 then 'VR回访结果=99关闭'
        when 7 then '超回访时效关闭'
    end 回访状态
    ,vrv.created_at 回访任务创建时间
    ,if(vrv.visit_state in (3,4,5,6,7), vrv.updated_at, null) 结束时间
    ,if(vrv.visit_state in (3,4,5,6,7), timestampdiff(second , vrv.created_at, vrv.updated_at)/3600, null ) '处理时长/小时'
    ,vrv.visit_num 回访次数
    ,case
        when vrv.visit_state in (4,6) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then '否'
        when vrv.visit_state in (4,6) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then '是'
        when vrv.visit_state in (4,6) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then '否'
        when vrv.visit_state in (4,6) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then '是'

        when vrv.visit_state in (3,5) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then '否'
        when vrv.visit_state in (3,5) and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then '是'
        when vrv.visit_state in (7) then '是'
    end 是否超时
from nl_production.violation_return_visit vrv
join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
where
    vrv.created_at >= date_sub('${date1}', interval 4 hour)
    and vrv.created_at < date_add('${date1}', interval 20 hour)
    and vrv.type in (3,8)