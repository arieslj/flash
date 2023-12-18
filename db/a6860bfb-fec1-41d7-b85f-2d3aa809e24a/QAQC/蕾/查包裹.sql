select
    pi.pno
    ,oi.out_trade_no
    ,pi.dst_name
    ,pi.dst_detail_address
    ,pi.src_name
    ,pi.src_detail_address
    ,sci.sorting_code

from ph_staging.parcel_info pi
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join dwm.drds_ph_parcel_sorting_code_info sci on sci.pno = pi.pno
where
    ss.name = 'AND_SP'
    -- and pi.dst_detail_address regexp 'Landmark'
    -- and pi.cod_enabled = 1
    and oi.src_phone regexp '560021347'
    and sci.sorting_code like '%1A-01'
    -- and pi.dst_detail_address regexp 'Caloo'
    -- and oi.src_name regexp 'Jesriel'


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
,if(sdt.pno is not null,'应派','非应派') as 是否应派
,pi.date '在仓天数'
,td.date '交接天数'
,pr1.date '盘库天数'
,td5.'标记天数' '历史标记改约天数'

,convert_tz(pr3.routed_at,'+00:00','+08:00') '今日交接时间'
,pr3.staff_info_id '今日交接员工'
,convert_tz(pr7.routed_at,'+00:00','+08:00') '今日盘库时间'
,pr2.marker_category
,pr2.last_element
,pr2.last_marker

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
	and pr.pno is not null
	)pi
 left join ph_bi.dc_should_delivery_today sdt on sdt.pno=pi.pno and sdt.stat_date=CURRENT_DATE()
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
	(
		select
			pr.pno
			,pr.marker_category
			,pr.last_element
			,pr.last_marker
			from
			    (
			        select
			            pr.pno
			           , pr.marker_category
			           , pr.store_id
			             ,tdt2.element last_element
		                 ,tdt2.cn_element last_marker
			           , row_number() over (partition by pr.pno order by pr.routed_at desc) rank
			      from ph_staging.parcel_route pr
			      left join dwm.dwd_dim_dict tdt2 on pr.marker_category = tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
			      where date (convert_tz(pr.routed_at , '+00:00', '+08:00'))=CURRENT_DATE()
				    and pr.marker_category is not null
			      )pr
			where pr.rank=1
)pr2 on pr2.pno=pi.pno
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
    pi.pno
    ,pi.src_phone
from ph_staging.parcel_info pi
where
    pi.pno in ('P64022VT13NAE','P64022W9PEJAE','P64022TW3B2DN','P64082SMCPUAE','P64022UPFRUDW','P64022SG9NCAD','P64022U3A6NAE','P64022VQ2ZGAA','P64022VZ26ZAE','P64022VTVKSAD','P64022V9PCXBO','P64022W8ZVTAE','P64022VB3K5BN','P64022VE7XWEJ','P64022W4T9NAN','P64022VUS93BO','P64022VQQ80EI','P64022W2ESPDO','P64022V1GQCAN','P64022UNGXEDU','P64022UB3NEAE','P64022V21F1BO','P12112WRXY5AB','P64022WA7YFAE','P64022VDXA1EI','P64022WMXNPDA','P64022UVZSYDU','P64022TVBBSBP','P64022PVDHUEF','P64022VEJMVDU','P64022WDG5GDA','P64022TYXDFBO','P64022U286GBH','P64022VH7SAZZ','P64022V2R3CDD','P64022VD692AE','P64022VDP28BN','P64022W1Q0RDU','P64022VE6GDDB','P64022VY02GBB','P64022W1EPJDU','P64022W22EJZZ','P64022V3YS3AD','P64022W2XV2DV','P64132VNUBAAC','P64022TW55ACP','P64022V4DBWEU','P64022UK08NBN','P64022V0SHAAN','P64022V3YS4AD','P64022VTX4CEF')
