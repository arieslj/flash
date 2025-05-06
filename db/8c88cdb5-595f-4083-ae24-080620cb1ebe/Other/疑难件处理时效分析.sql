select
    case di.diff_marker_category # 疑难原因
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
    ,if(cdt.operator_id in (10000,10001,10002,10003), '自动处理', '人工处理') 处理方式
#     ,di.created_at 创建时间
#     ,cdt.updated_at 更新时间
    ,bc.client_name 客户名称
#     ,cdt.first_operated_at 第一次处理时间
    ,case
        when 0 then '客服未处理'
        when 1 then '已处理完毕'
        when 2 then '正在沟通中'
        when 3 then '财务驳回'
        when 4 then '客户未处理'
        when 5 then '转交闪速系统'
        when 6 then '转交QAQC'
    end as 处理状态
#     ,case cdt.negotiation_result_category
#         when 1 then '赔偿'
#         when 2 then '关闭订单(不赔偿不退货)'
#         when 3 then '退货'
#         when 4 then '退货并赔偿'
#         when 5 then '继续配送'
#         when 6 then '继续配送并赔偿'
#         when 7 then '正在沟通中'
#         when 8 then '丢弃包裹的，换单后寄回BKK'
#         when 9 then '货物找回，继续派送'
#         when 10 then '改包裹状态'
#         when 11 then '需客户修改信息'
#         when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
#         when 13 then 'TT退件新增“holding（15天后丢弃）”协商结果'
#     end as 协商结果
#     ,case  cdt.service_type
#         when 1 then '总部客服'
#         when 2 then 'miniCS客服'
#         when 3 then 'FH客服'
#     end  客服类型
#     ,case cdt.hand_over_normal_cs_reason # 状态
#         when 1 then '协商不一致'
#         when 2 then '无法联系客户'
#     end as 转交总部cs理由
    ,case
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 1  then '1小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 1 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 2 then '1-2小时'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 2 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 3 then '2-3小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 3 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 4 then '3-4小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 4 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 5 then '4-5小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 5 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 6 then '5-6小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 6 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 12 then '6-12小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 12 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 24 then '12-24小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 24 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 49 then '1-2天内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 48 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 168 then '2-7天内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 168  then '7天以上'
    end 处理时效
#     ,timestampdiff(hour, di.created_at, cdt.first_operated_at)/24 第一次处理时效_天数
    ,count(distinct di.id) 个数
from fle_staging.diff_info di
left join fle_staging.customer_diff_ticket cdt on di.id = cdt.diff_info_id
join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id and bc.client_name in ('lazada', 'shopee', 'tiktok')
where
    di.created_at >= '2023-04-30 17:00:00'
    and di.created_at < '2023-05-31 17:00:00'
#     and cdt.state = 1 -- 已处理
#     and cdt.operator_id not in (10000,10003,10002)
group by 1,2,3,4,5


;


select
    case di.diff_marker_category # 疑难原因
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
    ,bc.client_name
    ,sum(timestampdiff(second , di.created_at, cdt.updated_at)/3600)/count(distinct di.id) 平均处理时长_小时
from fle_staging.diff_info di
left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id and bc.client_name in ('lazada', 'shopee', 'tiktok')
where
    di.created_at >= '2023-04-30 17:00:00'
    and di.created_at < '2023-05-31 17:00:00'
#     and di.diff_marker_category = 39 -- 多次尝试派送失败
    and cdt.operator_id not in (10000,10001,10002,10003)
group by 1,2
;




select
    cdt.operator_id
    ,ss.name
    ,hjt.job_name
#     case cdt.negotiation_result_category
#         when 1 then '赔偿'
#         when 2 then '关闭订单(不赔偿不退货)'
#         when 3 then '退货'
#         when 4 then '退货并赔偿'
#         when 5 then '继续配送'
#         when 6 then '继续配送并赔偿'
#         when 7 then '正在沟通中'
#         when 8 then '丢弃包裹的，换单后寄回BKK'
#         when 9 then '货物找回，继续派送'
#         when 10 then '改包裹状态'
#         when 11 then '需客户修改信息'
#         when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
#         when 13 then 'TT退件新增“holding（15天后丢弃）”协商结果'
#     end as 协商结果
    ,count(distinct  di.id) deal_num
#     ,di.pno
#     ,di.id
    ,sum(timestampdiff(second , di.created_at, cdt.updated_at)/3600)/count(distinct di.id) 平均处理时长_小时
from fle_staging.diff_info di
left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id and bc.client_name in ('lazada', 'shopee', 'tiktok')
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = cdt.operator_id
left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
where
    di.created_at >= '2023-04-30 17:00:00'
    and di.created_at < '2023-05-31 17:00:00'
    and di.diff_marker_category = 17
    and cdt.operator_id not in (10000,10001,10002,10003)
group by 1,2,3


;

select
    cdt.operator_id
    ,di.pno
    ,bc.client_name 客户平台
    ,case pi.returned
        when 1 then '退件'
        when 0 then '正向'
    end 方向
    ,di.id
    ,case cdt.negotiation_result_category
        when 1 then '赔偿'
        when 2 then '关闭订单(不赔偿不退货)'
        when 3 then '退货'
        when 4 then '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK'
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
        when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
        when 13 then 'TT退件新增“holding（15天后丢弃）”协商结果'
    end as 协商结果
    ,case cdt.organization_type
        when 1 then '网点'
        when 2 then sd.name
    end 处理机构
    ,ss.name 处理网点
    ,case cdt.user_ticket_state
        when 0 then '未启用客户处理'
        when 0 then '启用但未处理'
        when 0 then '启用且已处理'
    end 客户处理状态
    ,timestampdiff(second , di.created_at, cdt.updated_at)/3600 处理时长_h
    ,if(vrv.id is not null , 1, 0) 是否进入回访
    ,vrv.data_source 回访逻辑
    ,vrv.visit_num 回访次数
    ,vrv.visit_staff_id 回访员工
    ,timestampdiff(second , vrv.created_at, vrv.updated_at)/3600 回访时长_h
from fle_staging.diff_info di
left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id and bc.client_name in ('lazada', 'shopee', 'tiktok')
left join fle_staging.parcel_info pi on pi.pno = di.pno
left join nl_production.violation_return_visit vrv on di.id = json_extract(vrv.extra_value, '$.diff_id')
left join bi_pro.sys_department sd on sd.id = cdt.organization_id
left join fle_staging.sys_store ss on ss.id = cdt.organization_id
where
    di.created_at >= '2023-04-30 17:00:00'
    and di.created_at < '2023-05-31 17:00:00'
    and di.diff_marker_category = 17