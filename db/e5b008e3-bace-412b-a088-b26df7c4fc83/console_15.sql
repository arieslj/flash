
;


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
	 ,if(di.state=1,convert_tz(cdt.updated_at,'+00:00','+08:00'),null)  '疑难件处理完成时间'
# 	 ,datediff('hour',convert_tz(di.created_at,'+00:00','+08:00'),if(di.state=1,convert_tz(di.updated_at,'+00:00','+08:00'),null)) '疑难件处理时长/h'
# 	 ,datediff(now(),if(di.state=0,convert_tz(di.created_at,'+00:00','+08:00'),null) ) '未处理当前时间-上报时间/d'
#     ,if(di.state = 0 and di.created_at >= concat(curdate(), ' 12:00:00'), '当日20点后', '之前') 8点判断
    ,case
        when di.created_at >= date_add('${date1}', interval 12 hour ) then '当日20点后'
        when di.created_at < date_add('${date1}', interval 12 hour ) and di.created_at >= date_sub('${date1}', interval 8 hour ) then '积压时间 0 day'
        when di.created_at < date_sub('${date1}', interval 8 hour ) then concat('积压时间', datediff('${date1}', convert_tz(di.created_at , '+00:00', '+08:00'), ' day'))
    end 积压时长
    ,case
        when cdt.state = 1 and cdt.updated_at <= date_add(cdt.created_at, interval  2 hour) then '及时'
        when cdt.state = 1 and cdt.updated_at > date_add(cdt.created_at, interval  2 hour) then '不及时'
        else null
    end 是否及时
    ,if(di.state = 1 , round(timestampdiff(second, di.created_at, di.updated_at )/ 3600, 2), null) 处理时长_h
from ph_staging.diff_info di
left join dwm.dwd_dim_dict tdt2 on di.diff_marker_category= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category' -- 标记原因
join ph_staging.parcel_info pi on pi.pno=di.pno
join dwm.dwd_dim_bigClient dd on pi.client_id=dd.client_id
left join ph_bi.sys_store ss on ss.id=pi.ticket_pickup_store_id #揽收网点
left join ph_bi.sys_store ss1 on ss1.id=pi.dst_store_id#目的地网点
left join ph_bi.sys_store ss2 on ss2.id=di.store_id #上报当前网点
left join ph_bi.hr_staff_info hi on hi.staff_info_id=di.staff_info_id #疑难件处理人对应网点
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id and cdt.organization_type=2 #疑难件处理进度
left join ph_bi.hr_staff_info hi2 on hi2.staff_info_id=cdt.operator_id #疑难件处理人对应网点
left join ph_bi.sys_department sd on sd.id=hi2.node_department_id
where
    di.diff_marker_category in (23,73,29,78,25,75,31,79)
    and di.created_at >= date_add('${date1}', interval  1 hour)
    and di.created_at < date_add('${date1}', interval 12 hour)