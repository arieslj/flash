-- 疑难件

with p as
(
    select
        pi.pno
        ,convert_tz(pi.created_at, '+00:00', '+08:00') created_time
        ,pi.ticket_pickup_store_id
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.returned
    from ph_staging.parcel_info pi
    where
        pi.created_at <= date_sub('${date1}', interval 8 hour)
        and pi.state = 6

)
select
    p1.pno 单号
    ,if(p1.returned = 0, '正向', '逆向') 方向
    ,ss.name 揽收网点名称
    ,ss2.name 目的地网点名称
    ,p1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then 'GE'
    end as 客户类型
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
    ,datediff(now(), convert_tz(de.routed_at, '+00:00', '+08:00')) 目的地网点停留时长
    ,date(p1.created_time) 揽收日期
    ,case
        when ss.category = 6 then 'FH处理'
        when ss.category != 6 and ( bc.client_name in ('lazada', 'shopee', 'tiktok') or ss.name = 'Autoqaqc') then '客服处理'
        when ss.category != 6 and bc.client_name is null and ss.name != 'Autoqaqc' then '揽收网点处理'
    end 处理机构
from ph_staging.diff_info di
join p p1 on p1.pno = di.pno
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id and cdt.state != 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join p p1 on p1.pno = pr.pno and pr.store_id = p1.dst_store_id
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
    ) de on de.pno = p1.pno and de.rk = 1
left join ph_staging.sys_store ss on ss.id = p1.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = p1.dst_store_id
left join ph_staging.ka_profile kp on kp.id = p1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = p1.client_id

;



-- 平台退件仓库

with t as
(
    select
        pi.pno
        ,pi.ticket_pickup_store_id
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.created_at
        ,pi.returned
    from ph_staging.parcel_info pi
    where
        pi.state not in (5,6,7,8,9)
        and pi.dst_store_id in ('PH19040F04','PH19040F06','PH19040F07','PH19280F10')
        and pi.created_at <= date_sub('${date1}', interval 8 hour)
)
select
    t1.pno
    ,if(t1.returned = 0 , '正向', '逆向') 方向
    ,ss.name 揽收网点
    ,ss2.name 目的地网点
    ,t1.client_id
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then 'GE'
    end as 客户类型
    ,ss3.name 当前网点
    ,datediff(now(), convert_tz(dst.routed_at, '+00:00', '+08:00')) 目的地网点停留时间
    ,date(convert_tz(t1.created_at, '+00:00', '+08:00')) 揽收日期
    ,las.CN_element 最后一条有效路由
    ,convert_tz(las.routed_at, '+00:00', '+08:00') 最后一条有效路由时间
    ,inv.inv_num 盘库次数
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_id
            ,ddd.CN_element
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join t p1 on p1.pno = pr.pno
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
    ) las on las.pno = t1.pno
left join ph_staging.sys_store ss on ss.id = t1.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = t1.dst_store_id
left join ph_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join ph_staging.sys_store ss3 on ss3.id = las.store_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join t p1 on p1.pno = pr.pno and pr.store_id = p1.dst_store_id
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
    ) dst on dst.pno = t1.pno and dst.rk = 1
left join
    (
        select
            pr.pno
            ,count(pr.id) inv_num
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.dst_store_id and pr.route_action = 'INVENTORY'
        group by 1
    ) inv on inv.pno = t1.pno


;





-- 退给丢弃仓的包裹


with t as
(
    select
        pi.pno
        ,pi.ticket_pickup_store_id
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.created_at
        ,pi.returned
    from ph_staging.parcel_info pi
    where
        pi.state not in (5,6,7,8,9)
        and pi.dst_store_id in ('PH19040F05') -- 丢弃仓
        and pi.created_at <= date_sub('${date1}', interval 8 hour)
)
select
    t1.pno
    ,if(t1.returned = 0 , '正向', '逆向') 方向
    ,ss.name 揽收网点
    ,ss2.name 目的地网点
    ,t1.client_id
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then 'GE'
    end as 客户类型
    ,ss3.name 当前网点
    ,date(convert_tz(t1.created_at, '+00:00', '+08:00')) 揽收日期
    ,las.CN_element 最后一条有效路由
    ,convert_tz(las.routed_at, '+00:00', '+08:00') 最后一条有效路由时间
    ,if(clo.pno is null ,'否' ,'是') 是否关闭过
    ,inv.inv_num 盘库次数
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_id
            ,ddd.CN_element
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join t p1 on p1.pno = pr.pno
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
    ) las on las.pno = t1.pno
left join ph_staging.sys_store ss on ss.id = t1.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = t1.dst_store_id
left join ph_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join ph_staging.sys_store ss3 on ss3.id = las.store_id
left join
    (
        select
            pr.pno
            ,count(pr.id) inv_num
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.dst_store_id and pr.route_action = 'INVENTORY'
        group by 1
    ) inv on inv.pno = t1.pno
left join
    (
        select
            pr.pno
            ,max(pr.routed_at) rou_time
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'CHANGE_PARCEL_CLOSE'
        group by 1
    ) clo on clo.pno = t1.pno



;

-- 非疑难件，非丢弃件

with t as
(
    select
        pi.pno
        ,pi.ticket_pickup_store_id
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.created_at
        ,pi.returned
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    where
        pi.state not in (5,6,7,8,9)
        and pi.dst_store_id not in ('PH19040F04','PH19040F06','PH19040F07','PH19280F10','PH19040F05')
        and pi.created_at <= date_sub('${date1}', interval 8 hour)
)
select
    t1.pno
    ,if(t1.returned = 0 , '正向', '逆向') 方向
    ,ss.name 揽收网点
    ,ss2.name 目的地网点
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then 'GE'
    end as 客户类型
    ,ss3.name 当前网点
    ,datediff(now(), convert_tz(dst.routed_at, '+00:00', '+08:00')) 目的地网点停留时间
    ,date(convert_tz(t1.created_at, '+00:00', '+08:00')) 揽收日期
    ,las.CN_element 最后一条有效路由
    ,convert_tz(las.routed_at, '+00:00', '+08:00') 最后一条有效路由时间
    ,td.try_num 尝试派送次数
    ,if(plt.pno is null , '否' ,'是') 当前是否有闪速认定任务
    ,
    ,inv.inv_num 盘库次数
from t t1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_id
            ,ddd.CN_element
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join t p1 on p1.pno = pr.pno
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
    ) las on las.pno = t1.pno
left join ph_staging.sys_store ss on ss.id = t1.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = t1.dst_store_id
left join ph_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join ph_staging.sys_store ss3 on ss3.id = las.store_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join t p1 on p1.pno = pr.pno and pr.store_id = p1.dst_store_id
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
    ) dst on dst.pno = t1.pno and dst.rk = 1
left join
    (
        select
            pr.pno
            ,count(pr.id) inv_num
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.dst_store_id and pr.route_action = 'INVENTORY'
        group by 1
    ) inv on inv.pno = t1.pno
left join
    (
        select
            di.pno
            ,ddd2.CN_element
            ,row_number() over (partition by di.pno order by di.created_at desc ) rk
            ,di.created_at
        from ph_staging.diff_info di
        join t t1 on t1.pno = di.pno
        left join dwm.dwd_dim_dict ddd2 on ddd2.element = di.diff_marker_category and ddd2.db = 'ph_staging' and ddd2.tablename = 'diff_info' and  ddd2.fieldname = 'diff_marker_category'
    ) di on di.pno = t1.pno and di.rk = 1
left join
    (
        select
            t1.pno
            ,count(distinct convert_tz(tdm.created_at, '+00:00', '+08:00')) try_num
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1
    ) td on td.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        group by 1
    ) plt on plt.pno = t1.pno
left join dwm.dwd_ex_ph_lazada_pno_period la on la.pno = t1.pno
left join dwm.dwd_ex_shopee_lost_pno_period de