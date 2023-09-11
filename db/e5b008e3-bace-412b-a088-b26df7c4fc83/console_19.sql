
/*=====================================================================+
表名称： TT未终态包裹清理进度
功能描述：TT未终态包裹清理进度
脚本名称：1248d_ph_tiktok_backlog_parcle

需求来源：
编写人员: wuzhongxian
设计日期：20230206
修改日期:
修改人员:
修改原因:

-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+=====================================================================*/
/*
 with backlog_parcel_tiktok as
(
     select
	        cr.tracking_no
	       ,tcr.pno
	      ,cr.created_at as pickup_created_at
	      ,tcr.latest_created_at
	      ,tcr.action_code
	      ,tcr.route_action
	      ,if(cr.tracking_no=tcr.pno,ai.delivery_attempt_num,ai.returned_delivery_attempt_num) as delivery_attempt_num
	     ,cr1.created_at 3rd_attempt_failed_time
	   from #揽收成功回调
	       (
	           select
	                   cr.tracking_no
	                   ,cr.pno
	                   ,cr.created_at
	                   ,row_number() over (partition by cr.pno order by cr.created_at ) as rn
	                   ,cr.route_action
	                   ,cr.action_code
	            from dwm.dwd_ph_tiktok_parcel_route_callback_record cr
	           where cr.action_code in('pickup_success','drop_off_success')
	       )cr
		   join # 回调全部的包裹最后一条路由时间
		   (
		      select
		          cr.tracking_no
		          ,cr.pno
		         ,cr.created_at as latest_created_at
		         ,cr.action_code
		         ,cr.route_action
		         ,row_number() over (partition by cr.tracking_no order by cr.created_at desc) as rn
		      from dwm.dwd_ph_tiktok_parcel_route_callback_record cr
		   )tcr on cr.tracking_no=tcr.tracking_no and tcr.rn=1
	    left join #已经终态的包裹
		   (
		      select
		          cr.tracking_no
		         ,count(cr.action_code) as cn
		      from dwm.dwd_ph_tiktok_parcel_route_callback_record cr
		      where cr.action_code in('pkg_damaged','pkg_lost','signed_personally','signed_thirdparty','signed_cod','unreachable_returned','pkg_scrap')
		      group by 1
		   )tcr2 on tcr.tracking_no=tcr2.tracking_no
		left join ph_staging.delivery_attempt_info ai on tcr.tracking_no=ai.pno  #回传给客户的尝试次数以及最后一次尝试对应的标记
	    left join dwm.dwd_ph_tiktok_parcel_route_callback_record cr1 on tcr.tracking_no=cr1.pno and cr1.action_code='3rd_attempt_failed'  # 第三次尝试对应时间
		where  tcr2.tracking_no is null and cr.rn=1
)
*/


select
     oi.client_id as '客户ID client_id'
    , oi.ka_warehouse_id as '仓库ID warehouse_id'
    , kw.out_client_id as '卖家ID_Seller_ID'
    , oi.src_name as '卖家名称 Seller_name'
	, bpt.tracking_no as '回调系统运单号 system TN'
	, bpt.pno as '内部运单号 internal TN'
    , if(pi.returned=1,'退件单','正向单') as '是否退件单号 if return TN'
    , case when pi.state = 1 then '已揽收'
	    when pi.state = 2 then '运输中'
	    when pi.state = 3 then '派送中'
	    when pi.state = 4 then '已滞留'
	    when pi.state = 5 then '已签收'
	    when pi.state = 6 then '疑难件处理中'
	    when pi.state = 7 then '已退件'
	    when pi.state = 8 then '异常关闭'
	    when pi.state = 9 then '已撤销'
		end as '包裹最新状态 latest parcel status'
    , di.疑难件上报时间 as '疑难件上报时间 problematic parcel reporting time'
    , di.疑难件原因 as  '疑难件原因 problematic resaon'
    , di.疑难件处理机构  as '疑难件处理机构 problematic department'
    , di.疑难件处理情况 as '疑难件处理情况 problematic status'

    , ssd.src_store as '揽收网点 pickup DC'
    , ssd.src_piece as '揽收片区 pickup piece'
    , ssd.src_region as '揽收大区 pickup area'
     ,ssd.src_area_name as  '寄件人所在时效区域 area1'

    , sp1.name as '寄件人所在省份 seller_province'
    , ct1.name '寄件人所在城市 seller_city'
	, sd1.name '寄件人人所在的乡 seller_barangay'

    ,tpr.dst_area_code as '目的地网点所在时效区域 destination_area'
	 ,tpr.dst_province_name as '目的地网点所在省 destination province'
    , ssd.dst_store as '目的网点 destination DC'
    , ssd.dst_piece as '目的片区 destination district'
    , ssd.dst_region as '目的大区 destination area'


    ,ssd.dst_area_name as '收件人所在时效区域 consignee_area1'
    , sp2.name '收件人所在省 consignee province'
    , ct2.name '收件人所在城市 consignee city'
	, sd2.name '收件人所在的区域 consignee district'
    , pi.dst_phone as 收件人电话
    , pi.dst_name as 收件人姓名
   	, tt.dst_routed_at as '到达目的地网点时间 arrive destionation DC time'
     ,datediff(date(now()),date(convert_tz(tt.dst_routed_at,'+00:00','+08:00'))) as  '到目的地网点时间_天 datediff_now_dst_store'
    , datediff(date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')),date(convert_tz(pi.created_at,'+00:00','+08:00'))) as  '揽收到目的地网点时间_天 datediff_pcikup_dst_store'
    , case when tt.dst_routed_at is not null then '在仓' when tt.dst_routed_at is null then '在途' else 'null' end as '在仓_or_在途 in DC or in transit'

    , concat(ssd.src_area_name,' to ',ssd.dst_area_name) as '流向 direction'
    , convert_tz(bpt.pickup_created_at,'+00:00','+08:00') as '回调揽收时间 callback pickup time'
    , date(convert_tz(bpt.pickup_created_at,'+00:00','+08:00') )as '回调揽收日期 callback pickup date'

    , ssd.sla as '时效天数 SLA'
    , ssd.end_date as '包裹普通超时时效截止日_整体 last day of SLA'
    ,if( ssd.end_7_date is null,ssd.end_date,ssd.end_7_date) as '包裹严重超时时效截止日_整体 last day of SLA+7/ 2sla+7'
    , pi.cod_amount/1000 as 'cod金额 cod amount'
	, convert_tz(bpt.latest_created_at,'+00:00','+08:00') as '回调最后一条路由时间last movement time'
	, bpt.action_code as '回调最后一条路由动作 last movement'
	, ifnull(bpt.delivery_attempt_num,0)as '回调尝试次数 callback attempt_times'
	, bpt.delivery_attempt_num as '回调第三次尝试时间 delivery_attempt_num'
	, pc.third_sorting_code as '三段码 delivery code'
    , convert_tz(pr2.routed_at,'+00:00','+08:00') as '最后一次交接时间 last handover time'
    , if(date(convert_tz(pr2.routed_at,'+00:00','+08:00'))=current_date,'是','否') as '是否当日交接 handover dateimte '
    , pr2.staff_info_id as '最后一次交接人 last handover courier'
    ,case when pi.dst_district_code in('PH180302','PH18030T','PH18030U','PH18030V','PH18030W','PH18030A','PH18030Z','PH180310','PH18030C','PH180313','PH180314','PH18030F','PH18031F','PH18031G','PH18030G','PH18031H','PH18031J','PH18031K','PH18031L','PH18031M','PH18031N','PH18031P','PH18030H','PH18031Q','PH18030N','PH18031W','PH18031X','PH18031Y','PH18031Z',
		'PH180320','PH180321','PH18030P','PH180322','PH180323','PH180324','PH180325') then 'flashhome代派' else '网点自派' end as '派送归属 belong_delivery'
    , case when tt.dst_routed_at is not null and tt.last_store_name<>ssd.dst_store then ssd.dst_store else tt.last_store_name end as '当前网点 current DC'
    , tt.last_route_time as '最后一次有效路由时间 last movement time'
    , tt.last_route_action as '最后一次有效路由动作 last vlid movement'
	, prlm.last_marker_time as '最后一次派件标记时间 last delivery mark time'
	, prlm.last_marker as '最后一次派件标记原因 last delivery mark'
	#, if(pi.discard_enabled=0,'否','是') as '是否丢弃 if discard'
    , di3.created_at as '最后一次进入闪速系统判责时间 latest Lost task system time'
    , if(di3.state is not null,'闪速系统判责中',null)  as '最后一次进入闪速系统判责进度 latest Lost task system process'
	, prm.SYSTEM_AUTO_RETURN_time as  '标记系统自动退件时间 auto return time'
	, prm.wait_return_time as '标记待打印退件时间 time of reprint waybill'
	, case when ssd.end_date>=current_date then '未超时效'
	    when ssd.end_date<current_date  and if( ssd.end_7_date is null,ssd.end_date,ssd.end_7_date) >=current_date then '普通超时效'
	    when if( ssd.end_7_date is null,ssd.end_date,ssd.end_7_date) <current_date then '严重超时效' else null end as '时效类别判断SLA category'
    , if(ssd.end_date<current_date,'已超时效','未超时效') as '是否超时效 if breach SLA'
    , datediff(ssd.end_date,current_date) as '距离超时效天数 breach in days'
    , case when datediff(ssd.end_date,current_date)<0 then '已超时效'
            when datediff(ssd.end_date,current_date)=0 then '即将超时效_距离超时效0天'
            when datediff(ssd.end_date,current_date)=1 then '即将超时效_距离超时效1天'
            when datediff(ssd.end_date,current_date)=2 then '即将超时效_距离超时效2天'
            when datediff(ssd.end_date,current_date)>2 then '即将超时效_距离超时效>2天'
        else null end as '超时风险类型 risk type of breach SLA'
	, datediff(current_date, date(convert_tz(bpt.latest_created_at,'+00:00','+08:00'))) as '最后一条回调距离今日的天数差 days from last callback until now'
	, case  when di3.state is not null then '丢失破损闪速判责中'
	        when  prm.SYSTEM_AUTO_RETURN_time is not null then '待退件'
	    	when  prm.wait_return_time is not null then '待退件'
	        when ifnull(bpt.delivery_attempt_num,0) >=3 then '满足三次尝试派送'
	        when datediff(date(now()),date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')))>=3 and  ifnull(bpt.delivery_attempt_num,0) =2 and date(prlm.last_marker_time)=current_date then '满足三次尝试派送'
	    	when di2.pno is not null then '地址错分导致延迟'
	        when di.疑难件原因 is not null then '疑难件处理中'
	    	when  datediff(date(now()),date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')))<3 and  datediff(date(now()),date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')))>0 then '到目的地网点后不够三次尝试'
	        when datediff(date(now()),date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')))>=3 and  ifnull(bpt.delivery_attempt_num,0) =2 and date(prlm.last_marker_time)<current_date then '包裹到网点>=3天但尝试次数<3'
	        when  datediff(date(now()),date(convert_tz(tt.dst_routed_at,'+00:00','+08:00')))>=3 and ifnull(bpt.delivery_attempt_num,0) <2  then '包裹到网点>=3天但尝试次数<3'
			else null end as '滞留分析'
from tmpale.tmp_backlog_parcel_tiktok  bpt
left join ph_staging.order_info oi on bpt.tracking_no=oi.pno
left join ph_staging.parcel_info pi on bpt.pno=pi.pno
left join ph_staging.ka_warehouse kw on oi.ka_warehouse_id=kw.id
left join dwm.dwd_ex_ph_tiktok_sla_detail ssd on bpt.pno=ssd.pno
left join ph_staging.sys_store ss3 on ssd.dst_store_id=ss3.id


# 寄件人区域
left join ph_staging.sys_province sp1 on sp1.code=pi.src_province_code
left join ph_staging.sys_city ct1 on ct1.code=pi.src_city_code
left join ph_staging.sys_district sd1 on sd1.code=pi.src_district_code

# 收件人区域
left join ph_staging.sys_province sp2 on sp2.code=pi.dst_province_code
left join ph_staging.sys_city ct2 on ct2.code=pi.dst_city_code
left join ph_staging.sys_district sd2 on sd2.code=pi.dst_district_code


left join
(
	  select
	      distinct
		 tpr.dst_province_code
	    ,sp.name as dst_province_name
		 ,tpr.dst_area_code
	   from dwm.dwd_ph_dict_tiktok_period_rules tpr
	   join ph_staging.sys_province sp on tpr.dst_province_code=sp.code
	   where  tpr.sla_version='v2'
)tpr on ss3.province_code=tpr.dst_province_code # 收件人区域，寄件人区域

left join dwm.dwd_ex_ph_parcel_details tt on bpt.pno=tt.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = tt.last_store_id and dp.stat_date =date_sub(current_date,interval 1 day)
left join ph_staging.sys_province sp on dp.province_code=sp.code
left join
	(
		select
		        dt.pno
		        ,dt.staff_info_id
		        ,dt.created_at as delivery_created_at
		        ,tdt2.cn_element as last_marker
		        ,convert_tz(dm.created_at,'+00:00','+08:00') last_marker_time
		        ,row_number() over (partition by  dt.pno order by dt.created_at desc) as rk
		from ph_staging.ticket_delivery dt
		join tmpale.tmp_backlog_parcel_tiktok  dw on dt.pno=dw.pno
		left join ph_staging.ticket_delivery_marker dm on dt.id=dm.delivery_id
		left join dwm.dwd_dim_dict tdt2 on dm.marker_id= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
	) prlm on bpt.pno = prlm.pno and prlm.rk = 1 /*最后一条派件标记*/
left join
    (
			select
		        di.pno
		        ,di.staff_info_id
		        ,tdt2.cn_element as 疑难件原因
		         , convert_tz(di.created_at,'+00:00','+08:00') as 疑难件上报时间
			    ,if(cdt.operator_id=10001,'回访批量导入/自动处理',sd.name) as 疑难件处理机构
	          #  ,cdt.operator_id '客服操作人ID'
			    ,case cdt.state
					  when 0 then '未处理'
					  when 1 then '已处理'
					  when 2 then '正在沟通中'
					  when 3 then '财务驳回'
					  when 4 then '客户未处理'
					  when 5 then '转交闪速系统'
					  when 6 then '转交QAQC'
					  end '疑难件处理情况'
			 ,row_number() over (partition by di.pno order by convert_tz(di.created_at,'+00:00','+08:00') desc) as rk
		from tmpale.tmp_backlog_parcel_tiktok tt
		join ph_staging.diff_info di on tt.pno=di.pno
		left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
		left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2
		left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
		left join ph_bi.sys_department sd on sd.id=hi2.node_department_id # 待处理人部门
        where di.state=0
	)di on bpt.pno=di.pno and di.rk=1 /*疑难件原因*/
left join
    (
        select
	        di.pno
	        ,tdt2.cn_element as 疑难件原因
	        ,convert_tz(di.created_at,'+00:00','+08:00') as 疑难件上报时间
             ,row_number() over (partition by di.pno order by convert_tz(di.created_at,'+00:00','+08:00') desc) as rk
		from tmpale.tmp_backlog_parcel_tiktok tt
		join ph_staging.diff_info di on tt.pno=di.pno
		left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
		left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2
        where di.state=1 and tdt2.element in(30,31,79,73,23)
    )di2 on bpt.pno=di2.pno and di2.rk=1  /*错分疑难件原因*/
left join
	(
	    select
			lt.pno
	        ,lt.created_at as created_at
	        ,lt.state
			,row_number() over (partition by lt.pno order by lt.created_at desc) as rk
		   from tmpale.tmp_backlog_parcel_tiktok tt
		  join ph_bi.parcel_lose_task lt on tt.pno=lt.pno
		   where lt.created_at>date_sub(CURRENT_DATE ,interval 30 day)
		   and lt.created_at < current_date()
		   and lt.state not in(5,6)
    )di3 on bpt.pno=di3.pno and di3.rk=1  /*丢失*/
left join
    (
	    select
	        pr.store_id
	        ,pr.pno
	        ,pr.store_name
	        ,pr.routed_at
	        ,pr.staff_info_id
	        ,pr.route_action
	    from
	        (
	            select
	                pr.pno
	                ,pr.store_id
	                ,pr.routed_at
	                ,pr.route_action
	                ,pr.store_name
	                ,pr.staff_info_id
	                ,row_number() over(partition by pr.pno order by pr.routed_at DESC ) as rn
	         from ph_staging.parcel_route pr
	         join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
	         where pr.routed_at>= date_sub(now(),interval 1 month)
	         and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
	        )pr
	    where pr.rn = 1
    ) pr2 on pr2.pno =bpt.pno -- 最后一次交接
left join
    (
	    select
			pc.pno
			,pc.sorting_code
	        ,pc.third_sorting_code
	        ,pc.line_code
	        ,row_number()over(partition by pc.pno order by pc.created_at desc) as rn
		from ph_drds.parcel_sorting_code_info pc
		join tmpale.tmp_backlog_parcel_tiktok  bpt on pc.pno=bpt.pno
	)pc on pc.pno =bpt.pno and pc.rn=1 -- 包裹最新派件码
left join
    (
           select
           pr.pno
           ,max(if(pr.route_action = 'SYSTEM_AUTO_RETURN',date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as SYSTEM_AUTO_RETURN_time
           ,max(if(pr.route_action in( 'PENDING_RETURN','DELAY_RETURN'),date(convert_tz(pr.routed_at, '+00:00', '+08:00')),null)) as wait_return_time
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action in( 'SYSTEM_AUTO_RETURN','PENDING_RETURN','DELAY_RETURN')
           and pr.routed_at >= date_sub(now(),interval 3 month)
           group by 1
    )prm on bpt.pno=prm.pno  -- 打印退件和待退件
left join
    (
           select
                pr.pno
           from ph_staging.parcel_route pr
           join tmpale.tmp_backlog_parcel_tiktok  bpt on pr.pno=bpt.pno
           where pr.route_action ='REFUND_CONFIRM'
           and pr.routed_at >= date_sub(now(),interval 10 month)
           group by 1
    )prm2 on bpt.pno=prm2.pno
where  datediff(ssd.end_date,current_date)<=0 and prm2.pno is null


