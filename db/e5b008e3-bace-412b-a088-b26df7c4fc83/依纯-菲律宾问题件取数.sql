-- 疑难件整体数据
select
    a.date_d 日期
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
    ) b on a.date_d = b.date_d
;

-- 整体疑难件/留仓件各类型占比

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
    ) a

;
-- 客户类型
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
group by 1

;

-- COD包裹维度

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
group by 1

;
-- ka疑难件头部客户
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
limit 100
;

-- 平台客户Shopee LZD TT疑难件/留仓件类型分布
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
group by 1,2,4,6