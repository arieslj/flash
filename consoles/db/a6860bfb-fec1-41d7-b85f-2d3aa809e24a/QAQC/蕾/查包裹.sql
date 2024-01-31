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
    ,pi.returned_pno
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
from ph_staging.parcel_info pi
where
    pi.pno in ('Shopee','P190538VU30BO','P190538YTXQBO','P190538P24HAO','P190538P22PAO','P1905382YUAAO','P190538PFCRBO','P450634AZR4BH','P1905390XQKAU','P1217398AX3AD','P011739CPG9AX','P7719323M58AN','P61203862MPGO','P1905399HAABX','P190539PRT7BO','P190539XVBQBW','P18063BE3VKAH','P18063B50UJAH','P47123D6MRKBA','P611035MYAXAX','P122135YHVWBQ','P122136D5XWBM','P611036W6KJBS','P2113372TU6AD','P122137E1D9AP','P030938FJ69AN','P6118397Z5JET','P181839V64XAV','P04303AAN3XAG','P611535KMJWBA','P110435N0B8AZ','P612335Q6YAAK','P6123363T5VAH','P210536ZU65AA','P18083733YNAO','P2105373BGDAA','P011239R9MWAG','P61033BEVQSAP','P1320372A4AAN','P1803372CXNAZ','P041237MJ16AI','P1928381TA1AH','P6116383XMMAB','P122338FHHTAL','P612438Y8XQAK','P21023B4PCUAD','P21023B6DDTAD','P61273BGQ9AAD','P4909340EYMAM','P171037926QAN','P120337MDKBAB','P122137MJ38AP','P121038VJZYBH','P1222391X86BC','P7909372A4BAI','P641137NCAHAD','P610237NGUVAE','P612138U8DZAS','P1210390RBRBD','P1206391X72AA','P03053BCMXABB','P61143BZDFZCT','P351739X8NDBG','P660638BJ8EAH','P6123399DJNAH','P611839DVM0EO','P612339EWR9AH','P120839K98NAF','P271535C1B4AQ','P420435MHV6AB','P242335QCXVBD','P5303360W1GAZ','P5302362A49CS','P3517365V9ZBH','P230336HJFVAT','P230336HJK4AT','P2815370YZ8AB','P800537MDJZAS','P110737MJ35AE','P353037NC9XAV','P33013813AGBX','P3514381DTDAA','P0703382T9JAD','P0619387HE0AG','P353038YTXCBA','P6125399H9GAV','P190539CF8PAK','P151839CSVQAI','P613039DFQKAI','P073139EE3FAV','P210239ET2PAD','P301039ET9BAV','P131239NVDEAM','P081339PW6QAH','P122139QAY9BQ','P190839X7KWAD','P612339XN0BAK','P611839YEP2BO','P611839YEQADR','P61183A5Z1ABK','P12223ARPX1AB','P12123ARPX7AX','P121136CEP9AB','P170535VUWHAD','P200437Y9NWAW','P210536AA5EAA','P230337WJZQAT','P230337WKH2AT','P210532TQF4AC','P500933J4KZAA','P21053525T4AA','P191935VUTWAE','P210234PMTZAF','P210438WCC0BI','P073735D2EEAZ','P242534PMV7AC','P2303399PUAAT','P231038FFEJAN','P0608324A0WAP','P020735A7QCAG','P650435W3JWAD','P64023BSV8GDA','P35263CWSSBAF','P61013CW8KCCR','P640238D161AD','P3521324A09AP','P612536EA35AO','P35373BW6ASAC','P19033CARXNAD','P17052YAHRRBE','P211336M9PJAD','P2105397790AA','P612038D11BBB','P611439PYUNBF','P041139X6GFBV','P210838D14AAE','P6130360PP1AA','P510636APM3AQ','P18063E8CJPAA')
