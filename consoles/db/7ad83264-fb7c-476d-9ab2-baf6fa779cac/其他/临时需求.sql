select
    km.应揽收日期
	,count(distinct km.运单号) as 应揽收订单量
	,count(distinct if(km.揽收订单时间<km.应揽收时间,km.运单号,null)) as 时效内揽收订单量
	#,count(distinct if(km.揽收订单日期 is null,km.运单号,null)) as 截止目前历史未揽收订单量
	,concat(round(count(distinct if(km.揽收订单时间<km.应揽收时间,km.运单号,null))/count(distinct km.运单号)*100,2),'%') as 绝对揽收率
    from
        (
	             select
			    oi.pno as 运单号
			    ,oi.src_name as seller名称
			    ,if(hour(convert_tz(oi.confirm_at, '+00:00', '+08:00'))<12,concat(date_add(date(convert_tz(oi.confirm_at, '+00:00', '+08:00')), interval 1 day), ' 00:00:00'),date_add(convert_tz(oi.confirm_at, '+00:00', '+08:00'),interval 1 day)) as 应揽收时间
	            ,date(if(hour(convert_tz(oi.confirm_at, '+00:00', '+08:00'))<12,concat(date_add(date(convert_tz(oi.confirm_at, '+00:00', '+08:00')), interval 1 day), ' 00:00:00'),date_add(convert_tz(oi.confirm_at, '+00:00', '+08:00'),interval 1 day))) as 应揽收日期
			    ,convert_tz(oi.created_at, '+00:00', '+08:00') as 创建订单时间
			    ,convert_tz(oi.confirm_at, '+00:00', '+08:00') as 订单确认时间
			    ,date(convert_tz(oi.confirm_at, '+00:00', '+08:00'))as 订单确认日期
			    ,convert_tz(pi.created_at, '+00:00', '+08:00') as 揽收订单时间
			    ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) as 揽收订单日期
			    ,case oi.state
				    when 0	then'已确认'
					when 1	then'待揽件'
					when 2	then'已揽收'
					when 3	then'已取消(已终止)'
					when 4	then'已删除(已作废)'
					when 5	then'预下单'
					when 6	then'被标记多次，限制揽收'
				    end as 订单状态
			 from  ph_staging.order_info oi
			left join ph_staging.parcel_info pi on oi.pno=pi.pno
			where oi.confirm_at>=date_sub(current_date,interval 40 day)
			  and oi.client_id in('AA0131')
			  and oi.state not in(3,4)
        )km
group by 1
order by 1;




select
        fn.end_date as 理论妥投日期
		,count(distinct fn.pno) as 理论妥投包裹
		,count(distinct case when fn.latest_created_date<=fn.end_date then fn.pno else null end) as 时效内妥投包裹量
		,concat(round(count(distinct case when fn.latest_created_date<=fn.end_date then fn.pno else null end)/count(distinct fn.pno)*100,2),'%') as 绝对妥投率
    from
    (
        select
		        ssd.pno
		        ,ssd.src_area_name
		        ,ssd.dst_area_name
			    ,ssd.end_date
		        ,ssd.pick_date
				,date(convert_tz(cr.latest_created_at,'+00:00','+08:00')) as latest_created_date
		from  dwm.dwd_ex_ph_tiktok_sla_detail ssd
		left join
		(
			select
			    cr.tracking_no
			    ,cr.pno
			    ,cr.action_code
			    ,cr.created_at as latest_created_at
			from dwm.dwd_ph_tiktok_parcel_route_callback_record cr
			where cr.action_code in ( 'signed_personally', 'signed_thirdparty', 'signed_cod', 'unreachable_returned')
		) cr on ssd.pno=cr.pno
		where  ssd.parcel_state<9
		#and ssd.dst_area_name='VISAYAS 1'  ##看下宿务

    )fn
where fn.end_date<current_date
and fn.end_date>date_sub(current_date,interval 30 day)
group by 1
order by 1;



select
    r.pno
	,r.src_area_name
	,r.dst_area_name
    ,r.finished_date
	,r.diff_time_hours
    ,r.cn
    ,r.cn_01

from
    (
       select
		    ssd.pno
		    ,ssd.src_area_name
		    ,ssd.dst_area_name
			,ssd.finished_date
		    ,ssd.pickup_time
		    ,ssd.finished_time
            ,ssd.dst_hub_name
			,ssd.dst_store_in_time
            ,ssd.src_store
            ,ssd.dst_store
			,round(timestampdiff(second,ssd.pickup_time,ssd.finished_time)/3600,2) as diff_time_hours
            ,row_number() over(partition by ssd.src_area_name,ssd.dst_area_name,ssd.finished_date order by round(timestampdiff(second,ssd.pickup_time,ssd.finished_time)/3600,2)) as rn
            ,count(1)over(partition by ssd.src_area_name,ssd.dst_area_name,ssd.finished_date) as cn
            ,round(count(1)over(partition by ssd.src_area_name,ssd.dst_area_name,ssd.finished_date)*0.95,0) as cn_01
		    from dwm.dwd_ex_ph_tiktok_sla_detail ssd
		where ssd.finished_date>date_sub(current_date,interval 40 day)
		  and ssd.finished_date<current_date
		  and ssd.parcel_state=5
		  and ssd.returned=0
    )r
	where r.rn=r.cn_01
    order by 2，3，4