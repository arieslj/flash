 select
	slt.origin_id as 始发网点ID
    ,ss.name as 始发网点
    ,slt.store_id as 网点ID
    ,ss2.name as 网点
	#,slt.next_store_id
    #,ss2.name as next_store_name
	#,slt.target_id as target_store_id
    #,ss1.name as target_store_name
	,slt.proof_id 出车凭证
	,slt.line_id 线路id
	,slt.line_name 线路名称
	,slt.line_type
	,slt.line_mode
	,convert_tz(slt.estimate_end_time,'+00:00', '+08:00') as 计划到达时间
    ,slt.sign_in_channel 签到渠道
    ,slt.order_no 站次
    ,ft.real_arrive_time 实际到港时间
    ,ft.sign_time 考勤签到时间
    ,case
       when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time < ft.sign_time then ft.real_arrive_time
       when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time > ft.sign_time then ft.sign_time
       when ft.real_arrive_time is not null then ft.real_arrive_time
       when ft.real_arrive_time is null then ft.sign_time
       else null
    end  adjust_real_arrive_time  -- 最终到达weisha时间 （实际到达和签到取最小）
from my_staging.store_line_task slt
join my_staging.sys_store ss on slt.origin_id=ss.id and ss.category in (8,12)
join my_staging.sys_store ss1 on slt.target_id=ss1.id and ss1.category in (1,10)
left join my_bi.fleet_time ft on slt.line_id=ft.line_id and slt.store_id=ft.next_store_id and date(ft.plan_arrive_time)=current_date
join my_staging.sys_store ss2 on slt.store_id=ss2.id and ss2.category in (1,10)
# left join my_staging.sys_store_bdc_bsp sb1 on slt.store_id=sb1.bsp_id -- 目的地网点如果是BSP网点时、匹配实际BDC网点
# join my_staging.sys_store ss3 on coalesce(sb1.bdc_id,slt.store_id)=ss3.id and ss3.category in (1,10)
where
    slt.order_no>=2
    and slt.line_name not like '%RS2%'
    and slt.line_mode in(1,3,4)
    and slt.estimate_end_time>=concat(date_sub(current_date,interval 1 day),' 18:00:00')
    and slt.estimate_end_time<concat(current_date,' 18:00:00')
    and slt.deleted = 0