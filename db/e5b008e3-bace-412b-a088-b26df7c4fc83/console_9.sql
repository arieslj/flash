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
		  else pi.state
      end as '包裹状态'
	 ,ss1.name '目的地网点'
	 ,ss2.name '上报疑难件网点'
	, di.diff_marker_category
    ,tdt2.cn_element as ' 疑难件原因 '
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
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
# 	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
# 	 ,datediff(now(),if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ) '未处理当前时间-上报时间/d'
#     ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
    ,case
        when di.created_at >= date_add(curdate(), interval 12 hour ) then '当日20点后'
        when di.created_at < date_add(curdate(), interval 12 hour ) and di.created_at >= date_sub(curdate(), interval 8 hour ) then '积压时间 0 day'
        when di.created_at < date_sub(curdate(), interval 8 hour ) then concat('积压时间', datediff(now(), convert_tz(di.created_at , '+00:00', '+08:00'), ' day'))
    end 积压时长
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    di.diff_marker_category in (23,73,29,78,25,75)
    and di.state = 1
    and di.updated_at >= date_sub(curdate(), interval 8 hour )
    and di.updated_at < date_add(curdate(), interval 16 hour ) -- 今日处理

union all

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
    ,tdt2.cn_element as ' 疑难件原因 '
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
	 ,if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
# 	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
# 	 ,datediff(now(),if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ) '未处理当前时间-上报时间/d'
#     ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
    ,case
        when di.created_at >= date_add('${date1}', interval 12 hour ) then '当日20点后'
        when di.created_at < date_add('${date1}', interval 12 hour ) and di.created_at >= date_sub('${date1}', interval 8 hour ) then '积压时间 0 day'
        when di.created_at < date_sub('${date1}', interval 8 hour ) then concat('积压时间', datediff('${date1}', convert_tz(di.created_at , '+00:00', '+08:00'), ' day'))
    end 积压时长
    ,if(di.state = 0 and di.created_at >= concat('${date1}', ' 12:00:00'), '当日20点后', '之前') 8点判断
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    di.diff_marker_category in (23,73,29,78,25,75)
    and
    (
        (di.state = 0 and di.created_at < date_add('${date1}', interval  16 hour) )
        or (di.state = 1 and di.created_at < date_add('${date1}', interval  16 hour) and di.updated_at >= date_add('${date1}', interval  16 hour))
    )
;

;


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
                ,tdt2.cn_element 疑难件原因
                ,count(if(cdt.negotiation_result_category = 5, di.id, null)) 继续配送
                ,count(if(cdt.negotiation_result_category = 3, di.id, null)) 退货
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 < 2, di.id, null)) '0-2小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 2 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 4 , di.id, null)) '2-4小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 4 and timestampdiff(second , di.created_at, di.updated_at)/3600 < 6, di.id, null )) '4-6小时'
                ,count(if(timestampdiff(second , di.created_at, di.updated_at)/3600 >= 6 , di.id, null )) '6小时以上'
                ,sum(if(cdt.operator_id not in (10000,10001,100002), timestampdiff(second , di.created_at, di.updated_at)/3600, null))/count(if(cdt.operator_id not in (10000,10001,100002), di.id, null)) 平均处理时长_h
                ,count(di.id) 总疑难件量
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.updated_at >= date_sub('${date1}', interval 8 hour )
                and di.updated_at < date_add('${date1}', interval 16 hour ) -- 今日处理
                and di.state = 1 -- 已处理
                and di.diff_marker_category in (23,73,29,78,25,75,2,17)
            group by 1,2
            with rollup
        ) a
    order by 1,2
),
b as
(
        select
        coalesce(a.client_name, '总计') client_name
        ,coalesce(a.疑难件原因, '总计') 疑难件原因
        ,a.当日20点后
        ,a.积压时间0day
        ,a.积压1天及以上
    from
        (
                select
                coalesce(bc.client_name, '总计') client_name
                ,coalesce(tdt2.cn_element, '总计') 疑难件原因
                ,count(if(di.created_at >= date_add('${date1}', interval 12 hour), di.id, null)) 当日20点后
                ,count(if(di.created_at < date_add('${date1}', interval 12 hour ) and di.created_at >= date_sub('${date1}', interval 8 hour ), di.id, null)) '积压时间0day'
                ,count(if(di.created_at < date_sub('${date1}', interval 8 hour ), di.id, null)) '积压1天及以上'
            from ph_staging.diff_info di
            left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
            left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
            left join ph_staging.parcel_info pi on pi.pno = di.pno
            join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
            where
                di.diff_marker_category in (23,73,29,78,25,75,2,17)
                and
                (
                    (di.state = 0 and di.created_at < date_add('${date1}', interval  16 hour) )
                    or (di.state = 1 and di.created_at < date_add('${date1}', interval  16 hour) and di.updated_at >= date_add('${date1}', interval  16 hour))
                )
            group by 1,2
            with rollup
        ) a
    order by 1,2
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
    ,b1.当日20点后
    ,b1.积压时间0day
    ,b1.积压1天及以上
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
order by 1,2

;

select
    count(di.id)
from ph_staging.diff_info di
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
where
    di.diff_marker_category in (2,17)
    and date(convert_tz(di.created_at ,'+00:00', '+08:00')) = '2023-06-20'


;


select
    t.pno
    ,count(distinct date(convert_tz(ppd.created_at, '+00:00', '+08:00'))) 尝试天数
from ph_staging.parcel_problem_detail ppd
join tmpale.tmp_ph_try_pno_0623 t on t.pno = ppd.pno
group by 1
;
select
    t.pno
    ,count(distinct date(convert_tz(tdm.created_at, '+00:00', '+08:00')) ) 尝试天数
from ph_staging.ticket_delivery td
join tmpale.tmp_ph_try_pno_0623 t on t.pno = td.pno
left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
group by 1
