with t as
(
    select
        pi.pno
        ,de.dst_store
        ,de.dst_piece
        ,de.dst_region
        ,pi.dst_phone
        ,pi.dst_home_phone
    from ph_staging.parcel_info pi
    left join dwm.dwd_ex_ph_parcel_details de on de.pno = pi.pno
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    where
        pi.state not in (5,7,8,9)
        and de.dst_routed_at is not null
        and datediff(curdate(), de.dst_routed_at) >= 7
        and bc.client_id is null
)
select
    t1.pno 运单号
    ,t1.dst_region 目的地大区
    ,t1.dst_piece 目的地片区
    ,t1.dst_store 目的地网点
    ,if(td.de_num = 3, 1, 0) 尝试派送次数3
    ,if(td.de_num = 4, 1, 0) 尝试派送次数4
    ,if(td.de_num = 5, 1, 0) 尝试派送次数5
    ,if(td.de_num = 6, 1, 0) 尝试派送次数6
    ,if(td.de_num = 7, 1, 0) 尝试派送次数7
    ,if(td.de_num >= 8, 1, 0) 尝试派送次数8以上
    ,t1.dst_phone 收件人电话
    ,t1.dst_home_phone 收件人家庭电话
from t t1
left join
    (
        select
            td.pno
            ,count(distinct date(convert_tz(tdm.created_at ,'+00:00', '+08:00'))) de_num
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1
    ) td on td.pno = t1.pno
where
    td.de_num >= 3

;
select
    di.pno
    ,sdt.pending_handle_category
from ph_staging.diff_info di
left join ph_staging.store_diff_ticket sdt on sdt.diff_info_id = di.id
where
    di.pno = 'P16011S133GAF'


;

select
    t.pno
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
    end as 包裹状态
    ,pi.dst_phone 收件人电话
    ,pi.dst_home_phone 收件人家庭电话
from tmpale.tmp_ph_pno_0626 t
left join ph_staging.parcel_info pi on pi.pno = t.pno
where
    pi.state not in (5,7,8,9)


;

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
			where oi.confirm_at>=date_sub(current_date,interval 10 day)
			  and oi.client_id in('AA0131')
			  and oi.state not in(3,4)
        )km
group by 1
order by 1