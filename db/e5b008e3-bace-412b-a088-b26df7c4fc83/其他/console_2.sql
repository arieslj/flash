select
    *
from ph_staging.parcel_headless ph
where
    ph.created_at >= '2021-12-31 16:00:00'
;
select
    t.*
    ,ss.name
from tmpale.tmp_ph_1_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id;

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
group by 1
;

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
group by 1,2
;

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
    )  b on a.month_d = b.month_d and a.name = b.name
;
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
    and ss.id is not null
;
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
    and ss.id is not null
;

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
group by 1
;

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
group by 1,2,3
;
select date_sub(curdate(),interval 1 day)
;

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
    mw.staff_info_id in ('119872', '124880', '119279', '119022', '118822', '118925', '120282', '130832', '120267', '123336', '119617', '146865')

;



select
pi.pno '运单号'
,pi.'包裹状态'
,pi.created_at '揽收时间'
,pi.client_id '客户ID'
,pi.client_name '客户类型'
,pi.dst_name '目的地网点'
,pi.'大区'
,pi.'片区'
,pi.cod '是否cod'
,pi.dst_routed_at '到仓时间'

,pi.date '在仓天数'
,td.date '交接天数'
,pr1.date '盘库天数'
,td5.'标记天数' '历史标记改约天数'

,convert_tz(pr3.routed_at,'+00:00','+08:00') '今日交接时间'
,pr3.staff_info_id '今日交接员工'
,convert_tz(pr7.routed_at,'+00:00','+08:00') '今日盘库时间'
,case pr2.marker_category
when 1 then '客户不在家/电话无人接听'
        when 10 then '客户不在'
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
        when 11 then '客户取消任务'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 2 then '收件人拒收'
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
        when 3 then '快件分错网点'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 4 then '外包装破损'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 5 then '货物破损'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 6 then '货物短少'
        when 69 then '禁运品'
        when 7 then '货物丢失'
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
        when 8 then '电话联系不上'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 9 then '客户改约时间'
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
        when  120 then '海关查收'
end '今日派件标记原因'

,td6.'标记日期' '最后一次标记改约日期'
,td6.'改约日期' '最后一次标记改约到的日期'

,if(plt.pno is not null,'在闪速系统',null)'截止目前是否在闪速系统'
,plt.created_at '最后一次进入闪速时间'
,date_diff(CURRENT_DATE(),plt.created_at) '最后一次进入闪速系统距今日天数'
,plt.'进入闪速的来源' '进入闪速的原因'
,pi.cod_money 'cod金额'
,sdb.district_code 'bray'
,sd.name '乡名称'
,sdb.delivery_code '派送码'

from  -- 在仓7天及以上，且未妥投，揽收从7.22开始
	(select
	pi.pno
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
	ELSE '其他'
	end as '包裹状态'
	,convert_tz(pi.created_at,'+00:00','+08:00') created_at
	,pi.client_id
	,pi.dst_store_id
	,pi.dst_district_code
	,ss.name  dst_name
	,smp.name '片区'
	,smr.name '大区'
	,if(pi.cod_enabled=1,'cod','非cod') cod
	,pi.cod_amount/100 'cod_money'
	,pr.dst_routed_at
	,pr.date
	,dd.client_name
	from ph_staging.parcel_info pi
   join
		(select
		pr.pno
		,pr.dst_routed_at
		,date_diff(CURRENT_DATE(),pr.dst_routed_at) date
		from dwm.dwd_ex_ph_parcel_details pr
		where date_diff(CURRENT_DATE(),dst_routed_at)>=0
		)pr
	on pr.pno=pi.pno
	left join ph_bi.sys_store ss on ss.id=pi.dst_store_id
	left join ph_bi.sys_manage_piece smp on smp.id=ss.manage_piece
	left join ph_bi.sys_manage_region smr on smr.id=ss.manage_region
	left join dwm.dwd_dim_bigClient dd on dd.client_id=pi.client_id
	where pi.created_at>=CURRENT_DATE()-interval 70 day
	and pi.state not in(5,7,8,9)
	and pi.returned=0
    and ss.category not in (6,8,12)
	and pr.pno is not null)pi

left join  -- 交接天数
	(select
	td.pno
	,count(td.date) date
	from
	(select
	distinct
	td.pno
	,date(convert_tz(td.created_at,'+00:00','+08:00')) date
	from ph_staging.ticket_delivery td
	where td.created_at>=CURRENT_DATE()-interval 70 day )td
	group by 1
	)td  on td.pno=pi.pno

left join
    (select
    pr.pno
    ,count(pr.date) date
    from
	(select
	distinct
	pr.pno
	,date(convert_tz(pr.routed_at,'+00:00','+08:00')) date
	from ph_staging.parcel_route pr
	where pr.route_action='INVENTORY'
	and pr.routed_at>=CURRENT_DATE()-interval 70 day)pr
	group by 1)pr1 on pr1.pno=pi.pno
left join
(select
pr.pno
,pr.marker_category
from
(select
pr.pno
,pr.marker_category
,pr.store_id
,row_number()over(partition by pr.pno order by pr.routed_at desc) rank
from ph_staging.parcel_route pr
where date(convert_tz(pr.routed_at,'+00:00','+08:00'))=CURRENT_DATE())pr
where pr.rank=1)pr2 on pr2.pno=pi.pno

left join
(select
pr.pno
,pr.staff_info_id
,pr.routed_at
,pr.marker_category
from
(select
pr.pno
,pr.staff_info_id
,pr.marker_category
,pr.store_id
,pr.routed_at
,row_number()over(partition by pr.pno order by pr.routed_at desc) rank
from ph_staging.parcel_route pr
where date(convert_tz(pr.routed_at,'+00:00','+08:00'))=CURRENT_DATE()
and pr.route_action='DELIVERY_TICKET_CREATION_SCAN')pr
where pr.rank=1)pr3 on pr3.pno=pi.pno

left join -- 改约情况
(select
td.pno
,count(distinct td.'标记日期') '标记天数'
from
(select
td.pno
,date(convert_tz(tdm.created_at,'+00:00','+08:00')) '标记日期'
,date(convert_tz(tdm.desired_at,'+00:00','+08:00')) '改约日期'
,row_number()over(partition by td.pno,date(convert_tz(tdm.created_at,'+00:00','+08:00')) order by tdm.created_at desc) rank
from ph_staging.ticket_delivery td
left join ph_staging.ticket_delivery_marker tdm
on tdm.delivery_id =td.id
where td.created_at>CURRENT_DATE()-interval 70 day
and tdm.marker_id in(9,14,70)
)td
where td.rank=1
group by 1)td5 on td5.pno=pi.pno

left join -- 改约情况
(select
*
from
(select
td.pno
,date(convert_tz(tdm.created_at,'+00:00','+08:00')) '标记日期'
,date(convert_tz(tdm.desired_at,'+00:00','+08:00')) '改约日期'
,row_number()over(partition by td.pno order by tdm.created_at desc) rank
from ph_staging.ticket_delivery td
left join ph_staging.ticket_delivery_marker tdm
on tdm.delivery_id =td.id
where td.created_at>CURRENT_DATE()-interval 70 day
and tdm.marker_id in(9,14,70)
)td
where td.rank=1
)td6 on td6.pno=pi.pno


left join
(select
pr.pno
,pr.staff_info_id
,pr.routed_at
,pr.marker_category
from
(select
pr.pno
,pr.staff_info_id
,pr.marker_category
,pr.store_id
,pr.routed_at
,row_number()over(partition by pr.pno order by pr.routed_at desc) rank
from ph_staging.parcel_route pr
where date(convert_tz(pr.routed_at,'+00:00','+08:00'))=CURRENT_DATE()
and pr.route_action='INVENTORY'
and pr.routed_at>=CURRENT_DATE()-interval 70 day)pr
where pr.rank=1)pr7 on pr7.pno=pi.pno
left join
(select
*
from
(select
plt.pno
,plt.created_at
,case plt.source
when 1 then 'A-问题件-丢失'
when 2 then 'B-记录本-丢失'
when 3 then 'C-包裹状态未更新'
when 4 then 'D-问题件-破损/短少'
when 5 then 'E-记录本-索赔-丢失'
when 6 then 'F-记录本-索赔-破损/短少'
when 7 then 'G-记录本-索赔-其他'
when 8 then 'H-包裹状态未更新-IPC计数'
when 9 then 'I-问题件-外包装破损险'
when 10 then 'J-问题记录本-外包装破损险'
when 11 then 'K-超时效包裹'
when 33 then 'C来源HUB波次举报（临时来源，发送工单后将恢复C来源)'
else plt.source
end '进入闪速的来源'
,row_number()over(partition by plt.pno order by plt.created_at desc)rank
from ph_bi.parcel_lose_task plt
where plt.created_at>=CURRENT_DATE()-interval 70 day
and plt.state in(1,2,3,4)) plt
where plt.rank=1)plt
on plt.pno=pi.pno
left join ph_staging.store_delivery_barangay_group_info sdb on sdb.district_code=pi.dst_district_code and sdb.store_id=pi.dst_store_id and sdb.deleted=0
left join ph_bi.sys_district sd on sd.code=pi.dst_district_code

;




select
    ppl.replace_pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_pno_log ppl
left join ph_staging.parcel_info pi on pi.pno = ppl.initial_pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
where
    ppl.replace_pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')

union all

select
    pi.pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
where
    pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')




;

select
    oi.cod_amount
    ,oi.insure_declare_value
#     ,oi.cogs_amount
    ,oi.cod_enabled

from ph_staging.parcel_info  oi
where
    oi.pno = 'P35511D0J3BAG';