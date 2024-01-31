with t as
    (
        select
            plt.pno
            ,bc.client_name
            ,plt.client_id
            ,plt.created_at
            ,plt.updated_at
            ,plt.parcel_created_at
        from my_bi.parcel_lose_task plt
        join dwm.tmp_ex_big_clients_id_detail  bc on bc.client_id = plt.client_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.source = 3
            and plt.parcel_created_at >= '2023-08-01'
    )
select
    t1.pno
    ,t1.client_id 客户ID
    ,t1.client_name 客户名称
    ,oi.cogs_amount/100 cogs
    ,t1.parcel_created_at 包裹揽收时间
    ,t1.created_at 判责任务生成时间
    ,t1.updated_at 判责时间
    ,t2.store_id 判责后第一个有效路由网点ID
    ,t2.store_name 判责后第一个有效路由网点
    ,t2.staff_info_id 判责后第一个有效路由操作人
    ,convert_tz(t2.routed_at, '+00:00', '+08:00')  判责后第一个有效路由时间
    ,ddd.CN_element  判责后第一个有效路由
from t t1
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at
            ,pr.staff_info_id
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-08-01'
            and pr.routed_at > date_sub(t1.updated_at, interval 8 hour)
            and pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) t2 on t2.pno = t1.pno and t2.rk = 1
left join dwm.dwd_dim_dict ddd on ddd.element = t2.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join my_staging.order_info oi on oi.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,bc.client_name
            ,plt.client_id
            ,plt.created_at
            ,plt.updated_at
            ,plt.parcel_created_at
        from my_bi.parcel_lose_task plt
        join dwm.tmp_ex_big_clients_id_detail  bc on bc.client_id = plt.client_id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.source = 3
            and plt.parcel_created_at >= '2023-08-01'
    )
select
    t1.pno
    ,t1.client_id 客户ID
    ,t1.client_name 客户名称
    ,oi.cogs_amount/100 cogs
    ,t1.parcel_created_at 包裹揽收时间
    ,t1.created_at 判责任务生成时间
    ,t1.updated_at 判责时间
    ,t2.store_id 判责后第一个有效路由网点ID
    ,t2.store_name 判责后第一个有效路由网点
    ,t2.staff_info_id 判责后第一个有效路由操作人
    ,convert_tz(t2.routed_at, '+00:00', '+08:00')  判责后第一个有效路由时间
    ,ddd.CN_element  判责后第一个有效路由
from t t1
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at
            ,pr.staff_info_id
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-08-01'
            and pr.routed_at > date_sub(t1.updated_at, interval 8 hour)
            and pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) t2 on t2.pno = t1.pno and t2.rk = 1
left join dwm.dwd_dim_dict ddd on ddd.element = t2.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join my_staging.order_info oi on oi.pno = t1.pno
where
    if(t2.routed_at is not null ,t2.routed_at > date_sub(t1.updated_at, interval 8 hour), 1 = 1);
;-- -. . -..- - / . -. - .-. -.--
select
	slt.origin_id as origin_store_id
    ,ss.name as origin_store_name
    ,slt.store_id
    ,coalesce(sb1.bdc_id,slt.store_id) as real_store_id
    ,ss3.name as real_store_name
	#,slt.next_store_id
    #,ss2.name as next_store_name
	#,slt.target_id as target_store_id
    #,ss1.name as target_store_name
	,slt.proof_id
	,slt.line_id
	,slt.line_name
	,slt.line_type
	,slt.line_mode
	,convert_tz(slt.estimate_end_time,'+00:00', '+07:00') as estimate_end_time
    ,slt.sign_in_channel
    ,slt.order_no
    ,ft.real_arrive_time -- 实际到港时间
    ,ft.sign_time -- 考勤签到时间
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
join my_staging.sys_store ss2 on slt.next_store_id=ss2.id and ss2.category in (1,10)
# left join my_staging.sys_store_bdc_bsp sb1 on slt.store_id=sb1.bsp_id -- 目的地网点如果是BSP网点时、匹配实际BDC网点
# join my_staging.sys_store ss3 on coalesce(sb1.bdc_id,slt.store_id)=ss3.id and ss3.category in (1,10)
where
    slt.order_no>=2
    and slt.line_name not like '%RS2%'
    and slt.line_mode in(1,3,4)
    and slt.estimate_end_time>=concat(date_sub(current_date,interval 1 day),' 18:00:00')
    and slt.estimate_end_time<concat(current_date,' 18:00:00');
;-- -. . -..- - / . -. - .-. -.--
select
	slt.origin_id as origin_store_id
    ,ss.name as origin_store_name
    ,slt.store_id
    ,slt.store_id as real_store_id
    ,ss2.name as real_store_name
	#,slt.next_store_id
    #,ss2.name as next_store_name
	#,slt.target_id as target_store_id
    #,ss1.name as target_store_name
	,slt.proof_id
	,slt.line_id
	,slt.line_name
	,slt.line_type
	,slt.line_mode
	,convert_tz(slt.estimate_end_time,'+00:00', '+08:00') as estimate_end_time
    ,slt.sign_in_channel
    ,slt.order_no
    ,ft.real_arrive_time -- 实际到港时间
    ,ft.sign_time -- 考勤签到时间
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
    and slt.estimate_end_time<concat(current_date,' 18:00:00');
;-- -. . -..- - / . -. - .-. -.--
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
    and slt.estimate_end_time<concat(current_date,' 18:00:00');
;-- -. . -..- - / . -. - .-. -.--
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
    and slt.deleted = 0;
;-- -. . -..- - / . -. - .-. -.--
with handover as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
            ,fn.formal
            ,fn.before_17_calltimes
            ,fn.diff_day
        from
            (
                select
                   pr.pno
                   ,pr.store_id
                   ,dp.store_name
                   ,dp.piece_name
                   ,dp.region_name
                   ,pr.staff_info_id
                   ,pi.state pi_state
                   ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                   ,if(pi.returned=1,'退件','正向件') as pno_type
                   ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                   ,pr.staff_name
                   ,pr.formal
                   ,pr.diff_day
                   ,pr2.before_17_calltimes
               from
                   ( # 所有19点前交接包裹找到最后一次交接的人
                       select
                           pr.*
                       from
                           (
                               select
                                   pr.pno
                                   ,pr.staff_info_id
                                   ,hsi.name as staff_name
                                   ,pr.store_id
                                   ,hsi.formal
                                   ,datediff(curdate(),hsi.hire_date) diff_day
                                   ,row_number() over(partition by pr.pno order by pr.created_at desc) as rnk
                               from my_staging.`ticket_delivery`  pr
                               left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                               left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                               where pr.created_at >= date_sub(curdate(), interval 8 hour)
                               and pr.created_at < date_add(curdate(), interval 11 hour)
                               and hsi.job_title in(13,110,1199)
                           ) pr
                           where  pr.rnk=1
                   ) pr
                   join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
                   left join my_staging.parcel_info pi on pr.pno = pi.pno
                   left join # 19点前拨打电话次数
                   (
                       select
                           pr.pno
                           ,count(pr.call_datetime) as before_17_calltimes
                       from
                           (
                             select
                               pr.pno
                               ,pr.staff_info_id
                               ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
                              from my_staging.parcel_route pr
                              where pr.routed_at >= date_sub(curdate(), interval 8 hour)
                              and pr.routed_at < date_add(curdate(), interval 11 hour)
                              and pr.route_action in ('PHONE')
                           )pr
                       group by 1
                   )pr2 on pr.pno = pr2.pno
            )fn
    ),

 handover2 as
    (
        select
            fn.pno
            ,fn.pno_type
            ,fn.store_id
            ,fn.store_name
            ,fn.piece_name
            ,fn.region_name
            ,fn.staff_info_id
            ,fn.staff_name
            ,fn.finished_at
            ,fn.pi_state
            ,fn.formal
          -- ,fn.before_17_calltimes
        from
            (
                select
                   pr.pno
                   ,pr.store_id
                   ,dp.store_name
                   ,dp.piece_name
                   ,dp.region_name
                   ,pr.staff_info_id
                   ,pi.state pi_state
                   ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                   ,if(pi.returned=1,'退件','正向件') as pno_type
                   ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                   ,pr.staff_name
                   ,pr.formal
                   -- ,pr2.before_17_calltimes
               from
                   ( # 所有22点前交接包裹找到最后一次交接的人
                       select
                           pr.*
                       from
                           (
                               select
                                   pr.pno
                                   ,pr.staff_info_id
                                   ,hsi.name as staff_name
                                   ,pr.store_id
                                   ,hsi.formal
                                   ,row_number() over(partition by pr.pno order by convert_tz(pr.created_at,'+00:00','+08:00') desc) as rnk
                               from my_staging.`ticket_delivery`  pr
                               left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                               left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                               where pr.created_at >= date_sub(curdate(), interval 8 hour)
                               and pr.created_at < date_add(curdate(), interval 14 hour)
                               and hsi.job_title in(13,110,1199)
                           ) pr
                           where  pr.rnk=1
                   ) pr
                   join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category=1
                   left join my_staging.parcel_info pi on pr.pno = pi.pno
            )fn
    )



select
    *
from
    (

        select
                fn.网点
                ,fn.大区
                ,fn.片区
        #       ,fn.负责人
                ,fn.员工ID
                ,fn.快递员姓名
                ,fn.交接量_非退件
                ,fn.非退件妥投量
                ,fn.退件妥投量
                ,fn.交接包裹未拨打电话数 交接包裹未妥投未拨打电话数
                ,fn.员工出勤信息
                ,fn.22点前快递员结束派件时间
                ,fn.妥投率
                ,case when fn.未按要求联系客户 is not null and fn.rk<=2 then '是' else null end as 违反A联系客户
                ,fn.是否出勤不达标 as 违反B出勤
                ,fn.是否低人效 as 违反C人效
                ,if(fn.虚假行为>0,'是',null) as 违反D虚假
            from
            (
                select
                    fk.*
                    ,fg.虚假行为
                    ,row_number() over (partition by fk.网点,fk.未按要求联系客户 order by fk.交接包裹未拨打电话占比 desc) as rk
                    from
                    (
                        select
                            t1.网点
                            ,t1.大区
                            ,t1.片区
        #                   ,f1.负责人
                            ,t1.员工ID
                            ,t1.快递员姓名
                            ,t1.diff_day 快递员在职时长
                            ,f2.交接量_非退件
                            ,f6.非退件妥投量
                            ,f6.退件妥投量
                            ,f1.交接包裹未拨打电话数
                            ,case when f5.late_days>=3 and f5.late_times>=300 then '最近一周迟到至少三次且迟到时间至少5小时'
                                  when f5.absent_days>=2  then '最近一周缺勤>=2次'
                                  else null end as 员工出勤信息
                            ,f6.finished_at as 22点前快递员结束派件时间
                            ,concat(round(f6.非退件妥投量/f2.交接量_非退件*100,2),'%') as 妥投率
                            ,f1.交接包裹未拨打电话占比
                            ,f5.absent_days as 缺勤天数
                            ,f5.late_days as 迟到天数
                            ,f5.late_times as 迟到时长_分钟
                            ,if(f1.交接包裹未拨打电话数>10 and f1.交接包裹未拨打电话占比>0.2,'未按要求联系客户',null) as 未按要求联系客户
                            ,case when f5.late_days>=3 and f5.late_times>=300 then '是'
                                  when f5.absent_days>=2  then '是'
                                  else null end as 是否出勤不达标
                            ,if((f6.非退件妥投量/f2.交接量_非退件<0.7 and f6.非退件妥投量<70) or f6.finished_at is null ,'是',null) as 是否低人效

                        from
                            (
                                    select
                                        dt.region_name 大区
                                        ,dt.piece_name 片区
                                        ,dt.store_name 网点
                                        ,dt.store_id
                                        ,swa.staff_info_id 员工ID
                                        ,hsi.name 快递员姓名
                                        ,if(hsi.is_sub_staff = 1, 'y', 'n')  是否支援
                                        ,datediff(curdate(), hsi.hire_date)  diff_day
                                    from my_backyard.staff_work_attendance swa
                                    left join my_bi.hr_staff_info hsi on hsi.staff_info_id = swa.staff_info_id
                                    left join dwm.dim_my_sys_store_rd dt on dt.store_id = swa.organization_id and dt.stat_date = date_sub(curdate(), interval 1 day)
                                    left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                                    left join my_staging.sys_store ss on ss.id = hsi.sys_store_id
                                    where
                                        swa.attendance_date = curdate()
                                        and (swa.started_at is not null or swa.end_at is not null)
                                        and ss.category in (1,10)
                                        and hsi.job_title in (13,110,1199)
                                ) t1
                        left join
                            (# 快递员交接包裹后拨打电话情况
                                select
                                    fn.region_name as 大区
        #                      ,case
        #                         when fn.region_name in ('Area3', 'Area6') then '彭万松'
        #                         when fn.region_name in ('Area4', 'Area9') then '韩钥'
        #                         when fn.region_name in ('Area7','Area10', 'Area11','FHome','Area14') then '张可新'
        #                         when fn.region_name in ( 'Area8') then '黄勇'
        #                         when fn.region_name in ('Area1', 'Area2','Area5', 'Area12','Area13') then '李俊'
        #                         end 负责人
                                    ,fn.piece_name as 片区
                                    ,fn.store_name as 网点
                                    ,fn.store_id
                                    ,fn.staff_info_id as 员工ID
                                    ,fn.staff_name as 快递员姓名
                                    ,fn.diff_day
                                    ,count(distinct case when  fn.before_17_calltimes is null  and fn.pi_state not in(5,9) and  (fn.finished_at> date_add(curdate(), interval 11 hour) or fn.finished_at is null)  then fn.pno else null end) as 交接包裹未拨打电话数
                                    ,count(distinct case when  fn.before_17_calltimes is null  and fn.pi_state not in(5,9) and  (fn.finished_at> date_add(curdate(), interval 11 hour) or fn.finished_at is null)  then fn.pno else null end)/count(distinct fn.pno) as 交接包裹未拨打电话占比
                                from  handover fn
                                where fn.formal=1
                                group by 1,2,3,4,5,6
                            )f1 on f1.员工ID = t1.员工ID
                        left join
                          ( -- 22点前
                              select
                                  fn.staff_info_id as 员工ID
                                  ,fn.staff_name as 快递员姓名
                                  ,count(distinct if(fn.pno_type='正向件', fn.pno ,null)) as 交接量_非退件
                              from  handover2 fn
                              group by 1,2
                          )f2 on f2.员工ID = t1.员工ID
                        left join
                            ( -- 最近一周出勤
                                select
                                    ad.staff_info_id
                                    ,sum(case
                                        when ad.leave_type is not null and ad.leave_time_type=1 then 0.5
                                        when ad.leave_type is not null and ad.leave_time_type=2 then 0.5
                                        when ad.leave_type is not null and ad.leave_time_type=3 then 1
                                        else 0  end) as leave_num
                                    ,count(distinct if(ad.attendance_time = 0, ad.stat_date, null)) absent_days
                                    ,count(distinct if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), ad.stat_date, null)) late_days
                                    ,sum(if(ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute), timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), 0)) late_times
                                from my_bi.attendance_data_v2 ad
                                where ad.attendance_time + ad.BT+ ad.BT_Y + ad.AB >0
                                and ad.stat_date>date_sub(current_date,interval 8 day)
                                and ad.stat_date<=date_sub(current_date,interval 1 day)
                                group by 1
                            ) f5 on f5.staff_info_id = t1.员工ID
                           left join
                            ( -- 22点前最后一个妥投包裹时间
                                select
                                       pi.ticket_delivery_staff_info_id
                                       ,max(convert_tz(pi.finished_at,'+00:00','+08:00')) as finished_at
                                       ,count(distinct case when pi.returned=0 and hour(convert_tz(pi.finished_at,'+00:00','+08:00'))<22 then pi.pno else null end) as 非退件妥投量
                                       ,count(distinct case when pi.returned=1 and hour(convert_tz(pi.finished_at,'+00:00','+08:00'))<22 then pi.pno else null end) as 退件妥投量
                                   from my_staging.parcel_info pi
                                   where pi.state=5
                                   and pi.finished_at>=date_sub(curdate(), interval 8 hour)
                                   and pi.finished_at<date_add(curdate(), interval 14 hour)
                                   group by 1
                            ) f6 on f6.ticket_delivery_staff_info_id = t1.员工ID
                    )fk
                left join
                (
                select
                    a.staff_info_id
                    ,sum(a.揽件虚假量) 虚假揽件量
                    ,sum(a.妥投虚假量) 虚假妥投量
                    ,sum(a.派件标记虚假量) 虚假派件标记量
                   ,sum(a.揽件虚假量)+sum(a.妥投虚假量)+sum(a.派件标记虚假量) as 虚假行为
                from
                    (
                        select
                        #     case vrv.type
                        #         when 1 then '揽件任务异常取消'
                        #         when 2 then '虚假妥投'
                        #         when 3 then '收件人拒收'
                        #         when 4 then '标记客户改约时间'
                        #         when 5 then 'KA现场不揽收'
                        #         when 6 then '包裹未准备好'
                        #         when 7 then '上报错分未妥投'
                        #         when 8 then '多次尝试派送失败'
                        #     end 回访类型
                            vrv.staff_info_id
                            ,'回访' type
                            ,count(distinct if(vrv.visit_result  in (6), vrv.link_id, null)) 妥投虚假量
                            ,count(distinct if(vrv.visit_result in (18,8,19,20,21,31,32,22,23,24), vrv.link_id, null)) 派件标记虚假量
                        #   ,count(distinct if(vrv.visit_result in (23,24), vrv.link_id, null)) 虚假改约量
                            ,count(distinct if(vrv.visit_result in (37,39,3), vrv.link_id, null)) 揽件虚假量
                        #   ,count(distinct if(vrv.visit_result in (39), vrv.link_id, null)) 虚假未准备好标记量
                        #   ,count(distinct if(vrv.visit_result in (3), vrv.link_id, null)) 虚假取消揽件任务
                        from my_nl.violation_return_visit vrv
                        where vrv.visit_state = 4
                        and vrv.updated_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
                        and vrv.updated_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour) -- 昨天
                        and vrv.visit_staff_id not in (10000,10001) -- 非ivr回访
                        and vrv.type in (1,2,3,4,5,6)
                        group by 1

                        union all

                        select
                            am.staff_info_id
                            ,'投诉' type
                            ,count(distinct if(acc.complaints_type = 2, acc.id, null)) 揽件虚假量
                            ,count(distinct if(acc.complaints_type = 1, acc.id, null)) 妥投虚假量
                            ,count(distinct if(acc.complaints_type = 3, acc.id, null)) 派件标记虚假量
                        from my_bi.abnormal_customer_complaint acc
                        left join my_bi.abnormal_message am on am.id = acc.abnormal_message_id
                        where acc.state = 1
                        and acc.updated_at >= date_sub(date_sub(curdate(), interval 1 day), interval 8 hour)
                        and acc.updated_at < date_add(date_sub(curdate(), interval 1 day), interval 16 hour) -- 昨天
                        and acc.complaints_type in (1,2,3)
                        and acc.qaqc_callback_result in (3,4,5,6) -- 真实投诉
                        group by 1
                    ) a
                group by 1
                having sum(a.揽件虚假量)+sum(a.妥投虚假量)+sum(a.派件标记虚假量) >0
                )fg on fk.员工ID=fg.staff_info_id
            )fn

    ) a
where
    a.违反A联系客户 is not null
    or a.违反B出勤 is not null
    or a.违反C人效 is not null
    or a.违反D虚假 is not null;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    now()
    ,td.*
    ,concat( round( ye. 员工当天妥投率*100,2),"%")  AS 员工当天妥投率
    ,concat( round( ye.`员工昨日妥投率`*100,2),"%") AS 员工昨日妥投率
    ,concat( round( ye.`员工前日妥投率`*100,2),"%") AS 员工前日妥投率
    ,concat( round( yp.`网点当天妥投率`*100,2),"%") AS 网点当天妥投率
    ,concat( round( yp.`网点昨日妥投率`*100,2),"%") AS 网点昨日妥投率
    ,concat( round( yp.`网点前日妥投率`*100,2),"%") AS 网点前日妥投率
FROM
    (
        select
            yg.`stat_date`  date
            ,yg.`staff_info_id` 员工工号
            ,yg.`staff_name` 员工姓名
            ,yg.`hire_days` 在职天数
            ,if(yg.`wait_leave_state` =0,'否'，'是')  是否待离职
            ,jt.`name`   岗位
            ,yg.`store_name`  网点名称
            ,yg.`region_name`  大区
            ,yg.`piece_name` 片区
            ,case
                when yg.`staff_attr` =1 then '自有'
                WHEN yg.`staff_attr` =2 then '支援'
                WHEN yg.`staff_attr` =3  then '外协'
            end as  员工类型
            ,if(yg.`is_sub_staff`=0,'否','是')  是否支援
            ,yg.`supply_store_name` 支援网点名称
            ,yg.`master_staff_info_id`  主账号
            ,yg.`master_store_name` 主账号网点
            ,smp.`name` 主账号片区
            ,smr.`name` 主账号大区
            ,ss.`name`  打卡网点名称
            ,yg.`started_store_id`
            ,yg.`attendance_started_at` 上班打卡时间
            ,yg.`attendance_end_at` 下班打卡时间
            ,tp.pickup_count  揽收任务量
            ,yg.`pickup_par_cnt` 揽收量
            ,yg.`pickup_big_par_cnt` 揽收大件量
            ,yg.`pickup_sma_par_cnt` 揽收小件量
            ,yg.`handover_par_cnt` 交接量
            ,yg.`handover_big_par_cnt` 交接大件量
            ,yg.`handover_sma_par_cnt` 交接小件量
            ,yg.`handover_cod_par_cnt` 交接cod包裹量
            ,yg.`handover_start_at` 交接开始时间
            ,yg.`handover_hour` 交接时长
            ,yg.`delivery_par_cnt` 妥投包裹量
            ,yg.`delivery_big_par_cnt`  妥投大件量
            ,yg.`delivery_sma_par_cnt` 妥投小件量
            ,yg.`delivery_cod_par_cnt` 妥投cod包裹量
            ,yg.`delivery_start_at`    妥投开始时间
            ,yg.`delivery_end_at2`     妥投结束时间
            ,yg.`delivery_hour2`       妥投时长
            ,yg.coordinate_distance    派送里程
            ,yg.`delivery_staff_cnt`   网点当天派件人数
            ,yg.`rank_delivery_in_store`  在网点派件排名
            ,yg.`mark_par_cnt`   当日派件标记数量
            ,yg.`mark_ret_par_cnt` 当日标记拒收包裹数量
            ,yg.`mark_mdf_par_cnt` 当日改约包裹数量
            ,yg.`mark_par_unen_cnt` 当日运力不足标记数量
            ,yg.`mark_par_uncon_cnt` 当日标记无人接听标记数量
        from dwm.dws_my_staff_wide_s yg
        LEFT JOIN
            (
                SELECT
                    tp.`staff_info_id`
                    ,COUNT(tp.`id`) pickup_count
                from `my_staging`.`ticket_pickup` tp
                where
                    tp.`created_at` >=convert_tz(current_date,'+08:00','+00:00')
                    and tp.`transfered` =0
                    and tp.`state` in (1,2)
                GROUP BY 1
            ) tp on tp.`staff_info_id` =yg.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` ss on ss.`id` =yg.`started_store_id`
        LEFT JOIN `my_staging`.`staff_info_job_title` jt on jt.id=yg.`job_title`
        LEFT JOIN `my_staging`.`sys_store` ss1 on ss1.`id` =yg.`master_store_id`
        LEFT JOIN `my_staging`.`sys_manage_region`  smr on smr.`id` =ss1.`manage_region`
        LEFT JOIN  `my_staging`.`sys_manage_piece`  smp on smp.`id` =ss1.`manage_piece`
        WHERE
            yg.`stat_date` = CURRENT_DATE
            and yg.`delivery_par_cnt` <80
            and (yg.`hire_days` >7 or yg.`staff_attr` in (2,3))
            and yg.`delivery_hour` <5
            and yg.`coordinate_distance` < 100
            and yg.`delivery_cod_par_cnt`< 60
            and tp.pickup_count < 10
    )td
LEFT JOIN
    (
        select stat_date
            ,staff_info_id
            ,delivery_par_cnt/handover_par_cnt as 员工当天妥投率
            ,lag1_delivery_par_cnt/lag1_handover_par_cnt as 员工昨日妥投率
            ,lag2_delivery_par_cnt/lag2_handover_par_cnt as 员工前日妥投率
        from
            (
                select
                    stat_date
                    ,staff_info_id
                    ,delivery_par_cnt
                    ,handover_par_cnt
                    ,lag(delivery_par_cnt,1) over(partition by staff_info_id order by stat_date) as lag1_delivery_par_cnt
                    ,lag(delivery_par_cnt,2) over(partition by staff_info_id order by stat_date) as lag2_delivery_par_cnt
                    ,lag(handover_par_cnt,1) over(partition by staff_info_id order by stat_date) as lag1_handover_par_cnt
                    ,lag(handover_par_cnt,2) over(partition by staff_info_id order by stat_date) as lag2_handover_par_cnt
                from  dwm.dws_my_staff_wide_s yg
                WHERE
                    yg.`stat_date`>=date_sub(CURRENT_DATE, INTERVAL 3 DAY)
             )base
        where
            stat_date=date_sub(CURRENT_DATE, INTERVAL 0 DAY)
            and  coalesce(delivery_par_cnt/handover_par_cnt,0)+coalesce(lag1_delivery_par_cnt/lag1_handover_par_cnt,0)+coalesce(lag2_delivery_par_cnt/lag2_handover_par_cnt,0)<2.7
    )ye on ye.staff_info_id=td.员工工号
join
    (
        select stat_date
            ,store_id
            ,store_name
            ,shl_delivery_delivery_par_cnt/shl_delivery_par_cnt as 网点当天妥投率
            ,shl1_delivery_delivery_par_cnt/shl1_delivery_par_cnt as 网点昨日妥投率
            ,shl2_delivery_delivery_par_cnt/shl2_delivery_par_cnt as 网点前日妥投率
        from
            (
                select
                    `stat_date`
                    ,`store_id`
                    ,`store_name`
                    ,`shl_delivery_delivery_par_cnt`
                    ,`shl_delivery_par_cnt`
                    ,lag(shl_delivery_delivery_par_cnt,1) over(partition by store_id order by stat_date) as shl1_delivery_delivery_par_cnt
                    ,lag(shl_delivery_delivery_par_cnt,2) over(partition by store_id order by stat_date) as shl2_delivery_delivery_par_cnt
                    ,lag(shl_delivery_par_cnt,1) over(partition by store_id  order by stat_date) as shl1_delivery_par_cnt
                    ,lag(shl_delivery_par_cnt,2) over(partition by store_id  order by stat_date) as shl2_delivery_par_cnt
                from  dwm.dws_my_store_should_delivery_s yp
                WHERE
                    yp.`stat_date`>=date_sub(CURRENT_DATE, INTERVAL 3 DAY)
            )base
            where
                stat_date=date_sub(CURRENT_DATE, INTERVAL 0 DAY)
                and  coalesce(shl_delivery_delivery_par_cnt/shl_delivery_par_cnt,0) +coalesce(shl1_delivery_delivery_par_cnt/shl1_delivery_par_cnt,0) +coalesce(shl2_delivery_delivery_par_cnt/shl2_delivery_par_cnt,0)<2.55
     ) yp on yp.`store_id`  =td.`started_store_id`;
;-- -. . -..- - / . -. - .-. -.--
select
    f2.大区
    ,片区
    , 网点
    , store_id
    , 员工ID
    , 快递员姓名
    , hand_no_call_count 交接包裹未拨打电话数
    , hand_no_call_ratio 交接包裹未拨打电话占比
from
    (
                select
            f1.*
            ,row_number() over (f1.网点, f1.员工ID order by f1.hand_no_call_ratio desc) rk
        from
            (
                select
                    fn.region_name as 大区
                    ,fn.piece_name as 片区
                    ,fn.store_name as 网点
                    ,fn.store_id
                    ,fn.staff_info_id as 员工ID
                    ,fn.staff_name as 快递员姓名
                    ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end) as hand_no_call_count
                    ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end)/count(distinct fn.pno) as hand_no_call_ratio
                from
                    (
                         select
                            fn.pno
                            ,fn.pno_type
                            ,fn.store_id
                            ,fn.store_name
                            ,fn.piece_name
                            ,fn.region_name
                            ,fn.staff_info_id
                            ,fn.staff_name
                            ,fn.finished_at
                            ,fn.pi_state
                            ,fn.before_17_calltimes
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,dp.store_name
                                    ,dp.piece_name
                                    ,dp.region_name
                                    ,pr.staff_info_id
                                    ,pi.state pi_state
                                    ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                                    ,if(pi.returned=1,'退件','正向件') as pno_type
                                    ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                                    ,pr.staff_name
                                    ,pr2.before_17_calltimes
                                from
                                    ( # 所有17点前交接包裹找到最后一次交接的人
                                        select
                                            pr.*
                                        from
                                            (
                                                select
                                                    pr.pno
                                                    ,pr.staff_info_id
                                                    ,hsi.name as staff_name
                                                    ,pr.store_id
                                                    ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
                                                from my_staging.parcel_route pr
                                                left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                                                left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                                                where
                                                    pr.routed_at >= date_sub(curdate(), interval 8 hour)
                                                    and pr.routed_at < date_add(curdate(), interval 9 hour)
                                                    and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
                                                    and hsi.job_title in (13,110,1199)
                                                    and hsi.formal=1
                                            ) pr
                                        where  pr.rnk = 1
                                    ) pr
                                join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category = 1
                                left join my_staging.parcel_info pi on pr.pno = pi.pno
                                left join # 17点前拨打电话次数
                                    (
                                        select
                                            pr.pno
                                            ,count(pr.call_datetime) as before_17_calltimes
                                        from
                                            (
                                                select
                                                        pr.pno
                                                        ,pr.staff_info_id
                                                        ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
                                                 from my_staging.parcel_route pr
                                                 where
                                                    pr.routed_at >= date_sub(curdate(), interval 8 hour)
                                                    and pr.routed_at < date_add(curdate(), interval 9 hour)
                                                    and pr.route_action in ('PHONE')
                                            )pr
                                        group by 1
                                    )pr2 on pr.pno = pr2.pno
                            )fn
                    ) fn
                group by 1,2,3,4,5,6
            ) f1
        where
            f1.hand_no_call_count > 10
            and f1.hand_no_call_ratio > 0.2
    ) f2
where
    f2.rk <= 2;
;-- -. . -..- - / . -. - .-. -.--
select
    f2.大区
    ,片区
    , 网点
    , store_id
    , 员工ID
    , 快递员姓名
    , hand_no_call_count 交接包裹未拨打电话数
    , hand_no_call_ratio 交接包裹未拨打电话占比
from
    (
        select
            f1.*
            ,row_number() over (f1.store_id, f1.员工ID order by f1.hand_no_call_ratio desc) rk
        from
            (
                select
                    fn.region_name as 大区
                    ,fn.piece_name as 片区
                    ,fn.store_name as 网点
                    ,fn.store_id
                    ,fn.staff_info_id as 员工ID
                    ,fn.staff_name as 快递员姓名
                    ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end) as hand_no_call_count
                    ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end)/count(distinct fn.pno) as hand_no_call_ratio
                from
                    (
                         select
                            fn.pno
                            ,fn.pno_type
                            ,fn.store_id
                            ,fn.store_name
                            ,fn.piece_name
                            ,fn.region_name
                            ,fn.staff_info_id
                            ,fn.staff_name
                            ,fn.finished_at
                            ,fn.pi_state
                            ,fn.before_17_calltimes
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,dp.store_name
                                    ,dp.piece_name
                                    ,dp.region_name
                                    ,pr.staff_info_id
                                    ,pi.state pi_state
                                    ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                                    ,if(pi.returned=1,'退件','正向件') as pno_type
                                    ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                                    ,pr.staff_name
                                    ,pr2.before_17_calltimes
                                from
                                    ( # 所有17点前交接包裹找到最后一次交接的人
                                        select
                                            pr.*
                                        from
                                            (
                                                select
                                                    pr.pno
                                                    ,pr.staff_info_id
                                                    ,hsi.name as staff_name
                                                    ,pr.store_id
                                                    ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
                                                from my_staging.parcel_route pr
                                                left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                                                left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                                                where
                                                    pr.routed_at >= date_sub(curdate(), interval 8 hour)
                                                    and pr.routed_at < date_add(curdate(), interval 9 hour)
                                                    and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
                                                    and hsi.job_title in (13,110,1199)
                                                    and hsi.formal=1
                                            ) pr
                                        where  pr.rnk = 1
                                    ) pr
                                join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category = 1
                                left join my_staging.parcel_info pi on pr.pno = pi.pno
                                left join # 17点前拨打电话次数
                                    (
                                        select
                                            pr.pno
                                            ,count(pr.call_datetime) as before_17_calltimes
                                        from
                                            (
                                                select
                                                        pr.pno
                                                        ,pr.staff_info_id
                                                        ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
                                                 from my_staging.parcel_route pr
                                                 where
                                                    pr.routed_at >= date_sub(curdate(), interval 8 hour)
                                                    and pr.routed_at < date_add(curdate(), interval 9 hour)
                                                    and pr.route_action in ('PHONE')
                                            )pr
                                        group by 1
                                    )pr2 on pr.pno = pr2.pno
                            )fn
                    ) fn
                group by 1,2,3,4,5,6
            ) f1
        where
            f1.hand_no_call_count > 10
            and f1.hand_no_call_ratio > 0.2
    ) f2
where
    f2.rk <= 2;
;-- -. . -..- - / . -. - .-. -.--
select
    f2.大区
    ,片区
    , 网点
    , store_id
    , 员工ID
    , 快递员姓名
    , hand_no_call_count 交接包裹未拨打电话数
    , hand_no_call_ratio 交接包裹未拨打电话占比
from
    (
        select
            f1.*
            ,row_number() over (partition by f1.store_id, f1.员工ID order by f1.hand_no_call_ratio desc) rk
        from
            (
                select
                    fn.region_name as 大区
                    ,fn.piece_name as 片区
                    ,fn.store_name as 网点
                    ,fn.store_id
                    ,fn.staff_info_id as 员工ID
                    ,fn.staff_name as 快递员姓名
                    ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end) as hand_no_call_count
                    ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end)/count(distinct fn.pno) as hand_no_call_ratio
                from
                    (
                         select
                            fn.pno
                            ,fn.pno_type
                            ,fn.store_id
                            ,fn.store_name
                            ,fn.piece_name
                            ,fn.region_name
                            ,fn.staff_info_id
                            ,fn.staff_name
                            ,fn.finished_at
                            ,fn.pi_state
                            ,fn.before_17_calltimes
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,dp.store_name
                                    ,dp.piece_name
                                    ,dp.region_name
                                    ,pr.staff_info_id
                                    ,pi.state pi_state
                                    ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                                    ,if(pi.returned=1,'退件','正向件') as pno_type
                                    ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                                    ,pr.staff_name
                                    ,pr2.before_17_calltimes
                                from
                                    ( # 所有17点前交接包裹找到最后一次交接的人
                                        select
                                            pr.*
                                        from
                                            (
                                                select
                                                    pr.pno
                                                    ,pr.staff_info_id
                                                    ,hsi.name as staff_name
                                                    ,pr.store_id
                                                    ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
                                                from my_staging.parcel_route pr
                                                left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                                                left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                                                where
                                                    pr.routed_at >= date_sub(curdate(), interval 8 hour)
                                                    and pr.routed_at < date_add(curdate(), interval 9 hour)
                                                    and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
                                                    and hsi.job_title in (13,110,1199)
                                                    and hsi.formal=1
                                            ) pr
                                        where  pr.rnk = 1
                                    ) pr
                                join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category = 1
                                left join my_staging.parcel_info pi on pr.pno = pi.pno
                                left join # 17点前拨打电话次数
                                    (
                                        select
                                            pr.pno
                                            ,count(pr.call_datetime) as before_17_calltimes
                                        from
                                            (
                                                select
                                                        pr.pno
                                                        ,pr.staff_info_id
                                                        ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
                                                 from my_staging.parcel_route pr
                                                 where
                                                    pr.routed_at >= date_sub(curdate(), interval 8 hour)
                                                    and pr.routed_at < date_add(curdate(), interval 9 hour)
                                                    and pr.route_action in ('PHONE')
                                            )pr
                                        group by 1
                                    )pr2 on pr.pno = pr2.pno
                            )fn
                    ) fn
                group by 1,2,3,4,5,6
            ) f1
        where
            f1.hand_no_call_count > 10
            and f1.hand_no_call_ratio > 0.2
    ) f2
where
    f2.rk <= 2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from my_bi.attendance_data_v2 ad
                    join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()

                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1199) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum/60 迟到时长_hour
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > date_add(concat(t1.stat_date, ' ', t1.shift_start), interval 1 minute ) , timestampdiff(minute , concat(t1.stat_date, ' ', t1.shift_start), t1.attendance_started_at), 0) late_time
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join my_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_my_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    st.late_num >= 3
    and st.late_time_sum >= 300;
;-- -. . -..- - / . -. - .-. -.--
select
    fn.job_name
    ,count(distinct fn.staff_info_id) staff_count
    ,sum(fn.kilo_km * fn.price) / count(distinct fn.staff_info_id)  avg_price
from
    (
         select
            smr.staff_info_id
            ,hjt.job_name
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = smr.staff_info_id
        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
        where
            smr.created_at >= '2023-05-01'
    ) fn
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    fn.job_name
    ,count(distinct fn.staff_info_id) staff_count
    ,sum(fn.kilo_km * fn.price) / count(distinct fn.staff_info_id)  avg_price
from
    (
         select
            smr.staff_info_id
            ,hjt.job_name
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = smr.staff_info_id
        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1
    ) fn
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(fn.created_at) 月份
#     ,count(distinct fn.staff_info_id) staff_count
    ,sum(fn.kilo_km * fn.price) / count(distinct fn.staff_info_id)  人均油费
from
    (
         select
            smr.staff_info_id
            ,smr.created_at
            ,hjt.job_name
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = smr.staff_info_id
        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1
    ) fn
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0;
;-- -. . -..- - / . -. - .-. -.--
select
                    smr.staff_info_id
                    ,month(smr.created_at) month
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = smr.staff_info_id
        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1;
;-- -. . -..- - / . -. - .-. -.--
select
                    smr.staff_info_id
                    ,month(smr.created_at) month
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0;
;-- -. . -..- - / . -. - .-. -.--
select
            smr.staff_info_id
            ,smr.created_at
            ,hjt.job_name
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = smr.staff_info_id
        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1;
;-- -. . -..- - / . -. - .-. -.--
select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = smr.staff_info_id
        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1
            and if(smr.data_price = 0, a.oil_price, smr.data_price)/100 is null;
;-- -. . -..- - / . -. - .-. -.--
select
            smr.staff_info_id
            ,smr.created_at
            ,hjt.job_name
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = smr.staff_info_id
        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1
            and if(smr.data_price = 0, a.oil_price, smr.data_price)/100 is null;
;-- -. . -..- - / . -. - .-. -.--
select
    month(fn.created_at) 月份
#     ,count(distinct fn.staff_info_id) staff_count
    ,sum(fn.kilo_km * fn.price) / count(distinct fn.staff_info_id)  人均油费
from
    (
         select
            smr.staff_info_id
            ,smr.created_at
            ,hjt.job_name
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = smr.staff_info_id
        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1
            -- and if(smr.data_price = 0, a.oil_price, smr.data_price)/100 is null
    ) fn
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    fn.job_name

#     ,count(distinct fn.staff_info_id) staff_count
    ,sum(if(month(fn.created_at) = 5, fn.kilo_km, 0) * if(month(fn.created_at) = 5, fn.price, 0)) / count(distinct if(month(fn.created_at) = 5, fn.staff_info_id, null))  5月人均
    ,sum(if(month(fn.created_at) = 6, fn.kilo_km, 0) * if(month(fn.created_at) = 6, fn.price, 0)) / count(distinct if(month(fn.created_at) = 6, fn.staff_info_id, null))  6月人均
    ,sum(if(month(fn.created_at) = 7, fn.kilo_km, 0) * if(month(fn.created_at) = 7, fn.price, 0)) / count(distinct if(month(fn.created_at) = 7, fn.staff_info_id, null))  7月人均
    ,sum(if(month(fn.created_at) = 8, fn.kilo_km, 0) * if(month(fn.created_at) = 8, fn.price, 0)) / count(distinct if(month(fn.created_at) = 8, fn.staff_info_id, null))  8月人均
    ,sum(if(month(fn.created_at) = 9, fn.kilo_km, 0) * if(month(fn.created_at) = 9, fn.price, 0)) / count(distinct if(month(fn.created_at) = 9, fn.staff_info_id, null))  9月人均
    ,sum(if(month(fn.created_at) = 10, fn.kilo_km, 0) * if(month(fn.created_at) = 10, fn.price, 0)) / count(distinct if(month(fn.created_at) = 10, fn.staff_info_id, null))  10月人均
from
    (
         select
            smr.staff_info_id
            ,smr.created_at
            ,hjt.job_name
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_info hsi on hsi.staff_info_id = smr.staff_info_id
        left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1
            -- and if(smr.data_price = 0, a.oil_price, smr.data_price)/100 is null
    ) fn
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    fn.job_name

#     ,count(distinct fn.staff_info_id) staff_count
    ,sum(if(month(fn.created_at) = 5, fn.kilo_km, 0) * if(month(fn.created_at) = 5, fn.price, 0)) / count(distinct if(month(fn.created_at) = 5, fn.staff_info_id, null))  5月人均
    ,sum(if(month(fn.created_at) = 6, fn.kilo_km, 0) * if(month(fn.created_at) = 6, fn.price, 0)) / count(distinct if(month(fn.created_at) = 6, fn.staff_info_id, null))  6月人均
    ,sum(if(month(fn.created_at) = 7, fn.kilo_km, 0) * if(month(fn.created_at) = 7, fn.price, 0)) / count(distinct if(month(fn.created_at) = 7, fn.staff_info_id, null))  7月人均
    ,sum(if(month(fn.created_at) = 8, fn.kilo_km, 0) * if(month(fn.created_at) = 8, fn.price, 0)) / count(distinct if(month(fn.created_at) = 8, fn.staff_info_id, null))  8月人均
    ,sum(if(month(fn.created_at) = 9, fn.kilo_km, 0) * if(month(fn.created_at) = 9, fn.price, 0)) / count(distinct if(month(fn.created_at) = 9, fn.staff_info_id, null))  9月人均
    ,sum(if(month(fn.created_at) = 10, fn.kilo_km, 0) * if(month(fn.created_at) = 10, fn.price, 0)) / count(distinct if(month(fn.created_at) = 10, fn.staff_info_id, null))  10月人均
from
    (
         select
            smr.staff_info_id
            ,smr.created_at
            ,hjt.job_name
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_transfer hst on hst.staff_info_id = smr.staff_info_id and smr.mileage_date = hst.stat_date
        left join my_bi.hr_job_title hjt on hjt.id = hst.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1
            -- and if(smr.data_price = 0, a.oil_price, smr.data_price)/100 is null
    ) fn
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    fn.job_name
    ,fn.id

#     ,count(distinct fn.staff_info_id) staff_count
    ,sum(if(month(fn.created_at) = 5, fn.kilo_km, 0) * if(month(fn.created_at) = 5, fn.price, 0)) / count(distinct if(month(fn.created_at) = 5, fn.staff_info_id, null))  5月人均
    ,sum(if(month(fn.created_at) = 6, fn.kilo_km, 0) * if(month(fn.created_at) = 6, fn.price, 0)) / count(distinct if(month(fn.created_at) = 6, fn.staff_info_id, null))  6月人均
    ,sum(if(month(fn.created_at) = 7, fn.kilo_km, 0) * if(month(fn.created_at) = 7, fn.price, 0)) / count(distinct if(month(fn.created_at) = 7, fn.staff_info_id, null))  7月人均
    ,sum(if(month(fn.created_at) = 8, fn.kilo_km, 0) * if(month(fn.created_at) = 8, fn.price, 0)) / count(distinct if(month(fn.created_at) = 8, fn.staff_info_id, null))  8月人均
    ,sum(if(month(fn.created_at) = 9, fn.kilo_km, 0) * if(month(fn.created_at) = 9, fn.price, 0)) / count(distinct if(month(fn.created_at) = 9, fn.staff_info_id, null))  9月人均
    ,sum(if(month(fn.created_at) = 10, fn.kilo_km, 0) * if(month(fn.created_at) = 10, fn.price, 0)) / count(distinct if(month(fn.created_at) = 10, fn.staff_info_id, null))  10月人均
from
    (
         select
            smr.staff_info_id
            ,smr.created_at
            ,hjt.job_name
            ,hjt.id
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_transfer hst on hst.staff_info_id = smr.staff_info_id and smr.mileage_date = hst.stat_date
        left join my_bi.hr_job_title hjt on hjt.id = hst.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1
            -- and if(smr.data_price = 0, a.oil_price, smr.data_price)/100 is null
    ) fn
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            smr.staff_info_id
            ,smr.created_at
            ,hjt.job_name
            ,hjt.id
            ,smr.mileage_date
            ,smr.end_kilometres
            ,(smr.end_kilometres - smr.start_kilometres)/1000 kilo_km
            ,smr.start_kilometres
            ,if(smr.data_price = 0, a.oil_price, smr.data_price)/100 price
        from my_backyard.staff_mileage_record smr
        left join
            (
                select
                    smr.staff_info_id
                    ,vop.oil_price
                    ,row_number() over (partition by smr.staff_info_id order by vop.effective_date desc) rk
                from
                    (
                        select
                            smr.staff_info_id
                        from my_backyard.staff_mileage_record smr
                        where
                            smr.card_status = 1
                            and smr.data_price = 0
                        group by 1
                    ) smr
                left join my_backyard.vehicle_info vi on vi.uid = smr.staff_info_id
                left join my_backyard.vehicle_oil_price vop on vop.vehicle_category_item = vi.vehicle_type_category and vop.is_deleted = 0
            ) a on smr.staff_info_id = a.staff_info_id and a.rk = 1
        left join my_bi.hr_staff_transfer hst on hst.staff_info_id = smr.staff_info_id and smr.mileage_date = hst.stat_date
        left join my_bi.hr_job_title hjt on hjt.id = hst.job_title
        where
            smr.created_at >= '2023-05-01'
            and smr.card_status = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            hst.staff_info_id
            ,hst.job_title
            ,hst.stat_date
            ,lead(hst.job_title,1) over (partition by hst.staff_info_id order by hst.stat_date)  job_titl2
        from my_bi.hr_staff_transfer hst
        where
            hst.stat_date >= '2023-07-01'
    ) a
where
    a.job_title = 13
    and a.job_titl2 in (110,1199);
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            hst.staff_info_id
            ,hst.job_title
            ,hst.stat_date
            ,lead(hst.job_title,1) over (partition by hst.staff_info_id order by hst.stat_date)  job_titl2
        from my_bi.hr_staff_transfer hst
        where
            hst.stat_date >= '2023-07-01'
    ) a
where
    a.job_title = 13
    and a.job_titl2 in (110,1199,1413);
;-- -. . -..- - / . -. - .-. -.--
select
    bi.p_month 月份
    ,bi.bike_count bike转岗人数
    ,m.staff_count 月初bike人数
    ,bi.bike_count/m.staff_count 转岗占比
from
    (
         select
            month(a.stat_date) p_month
            ,count(distinct a.staff_info_id) bike_count
        from
            (
                select
                    hst.staff_info_id
                    ,hst.job_title
                    ,hst.stat_date
                    ,lead(hst.job_title,1) over (partition by hst.staff_info_id order by hst.stat_date)  job_titl2
                from my_bi.hr_staff_transfer hst
                where
                    hst.stat_date >= '2023-07-01'
            ) a
        where
            a.job_title = 13
            and a.job_titl2 in (110,1199,1413)
        group by 1
    ) bi
left join
    (
        select
            '7' p_month
            ,count(hst2.staff_info_id) staff_count
        from my_bi.hr_staff_transfer hst2
        where
            hst2.stat_date = '2023-07-01'
            and hst2.job_title in (13)

        union all

        select
            '8' p_month
            ,count(hst2.staff_info_id) staff_count
        from my_bi.hr_staff_transfer hst2
        where
            hst2.stat_date = '2023-08-01'
            and hst2.job_title in (13)

          union all

        select
            '9' p_month
            ,count(hst2.staff_info_id) staff_count
        from my_bi.hr_staff_transfer hst2
        where
            hst2.stat_date = '2023-09-01'
            and hst2.job_title in (13)

        union all

        select
            '10' p_month
            ,count(hst2.staff_info_id) staff_count
        from my_bi.hr_staff_transfer hst2
        where
            hst2.stat_date = '2023-10-01'
            and hst2.job_title in (13)
    )  m on m.p_month = bi.p_month;
;-- -. . -..- - / . -. - .-. -.--
select
    min(oi.created_at)
from my_staging.order_info oi
where
    oi.src_phone = '0123793152';
;-- -. . -..- - / . -. - .-. -.--
select
    min(oi.created_at)
from my_staging.order_info oi;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,t.cogs_amount/100 cogs
    ,t.client_id 客户ID
    ,t.src_phone 寄件人电话
    ,t.src_name 寄件人电话
    ,case t.state
        when 0 then '已确认'
        when 1 then '待揽件'
        when 2 then '已揽收'
        when 3 then '已取消(已终止)'
        when 4 then '已删除(已作废)'
        when 5 then '预下单'
        when 6 then '被标记多次，限制揽收'
    end as 订单状态
    ,case t.p_state
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
    ,t.created_at 下单时间
    ,t.pick_at 揽收时间
    ,CONCAT('SSRD',plt.`id`) 闪速任务ID
    ,case plt.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 当前判责类型
    ,t2.t_value 判责原因
    ,group_concat(distinct ss.name) 责任网点
    ,group_concat(distinct plr.staff_id) 责任人
from tmpale.tmp_my_pno_lj_1110 t
join my_bi.parcel_lose_task plt on t.pno = plt.pno and plt.state = 6
left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join my_bi.translations t2 on t2.t_key = plt.duty_reasons and  t2.lang ='zh-CN'
left join my_staging.sys_store ss on ss.id = plr.store_id
group by 1,2,3,4,5,6,7,8,9,10,11,12;
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
    ,t.cogs_amount/100 cogs
    ,t.client_id 客户ID
    ,t.src_phone 寄件人电话
    ,t.src_name 寄件人电话
    ,case t.state
        when 0 then '已确认'
        when 1 then '待揽件'
        when 2 then '已揽收'
        when 3 then '已取消(已终止)'
        when 4 then '已删除(已作废)'
        when 5 then '预下单'
        when 6 then '被标记多次，限制揽收'
    end as 订单状态
    ,case t.p_state
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
    ,t.created_at 下单时间
    ,t.pick_at 揽收时间
    ,CONCAT('SSRD',plt.`id`) 闪速任务ID
    ,case plt.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 当前判责类型
    ,t2.t_value 判责原因
    ,group_concat(distinct ss.name) 责任网点
    ,group_concat(distinct plr.staff_id) 责任人
from tmpale.tmp_my_pno_lj_1110 t
left join my_bi.parcel_lose_task plt on t.pno = plt.pno and plt.state = 6
left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join my_bi.translations t2 on t2.t_key = plt.duty_reasons and  t2.lang ='zh-CN'
left join my_staging.sys_store ss on ss.id = plr.store_id
group by 1,2,3,4,5,6,7,8,9,10,11,12;
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct plt.pno)
from my_bi.parcel_lose_task plt
left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
where
    plr.staff_id = 135489
    and plt.state = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct plt.pno)
    ,min(plt.created_at)
    ,min(plt.parcel_created_at)
from my_bi.parcel_lose_task plt
left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
where
    plr.staff_id = 135489
    and plt.state = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    count(distinct plt.pno)
    ,min(plt.created_at)
    ,min(plt.parcel_created_at)
    ,sum(oi.cogs_amount)/100 cogs
from my_bi.parcel_lose_task plt
left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join my_staging.order_info oi on oi.pno = plt.pno
where
    plr.staff_id = 135489
    and plt.state = 6;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,am.merge_column 关联信息
    ,case am.`punish_category`
        when 1 then '虚假问题件/虚假留仓件'
        when 2 then '5天以内未妥投，且超24小时未更新'
        when 3 then '5天以上未妥投/未中转，且超24小时未更新'
        when 4 then '对问题件解决不及时'
        when 5 then '包裹配送时间超三天'
        when 6 then '未在客户要求的改约时间之前派送包裹'
        when 7 then '包裹丢失'
        when 8 then '包裹破损'
        when 9 then '其他'
        when 10 then '揽件时称量包裹不准确'
        when 11 then '出纳回款不及时'
        when 12 then '迟到罚款 每分钟10泰铢'
        when 13 then '揽收或中转包裹未及时发出'
        when 14 then '仓管对工单处理不及时'
        when 15 then '仓管未及时处理问题件包裹'
        when 16 then '客户投诉罚款 已废弃'
        when 17 then '故意不接公司电话 自定义'
        when 18 then '仓管未交接speed/优先包裹给快递员'
        when 19 then 'pri或者speed包裹未妥投'
        when 20 then '虚假妥投'
        when 21 then '客户投诉'
        when 22 then '快递员公款超时未上缴'
        when 23 then 'minics工单处理不及时'
        when 24 then '客户投诉-虚假问题件/虚假留仓件'
        when 25 then '揽收禁运包裹'
        when 26 then '早退罚款'
        when 27 then '班车发车晚点'
        when 28 then '虚假回复工单'
        when 29 then '未妥投包裹没有标记'
        when 30 then '未妥投包裹没有入仓'
        when 31 then 'speed/pri件派送中未及时联系客户'
        when 32 then '仓管未及时交接speed/pri优先包裹'
        when 33 then '揽收不及时'
        when 34 then '网点应盘点包裹未清零'
        when 35 then '漏揽收'
        when 36 then '包裹外包装不合格'
        when 37 then '超大件'
        when 38 then '多面单'
        when 39 then '不称重包裹未入仓'
        when 40 then '上传虚假照片'
        when 41 then '网点到件漏扫描'
        when 42 then '虚假撤销'
        when 43 then '虚假揽件标记'
        when 44 then '外协员工日交接不满50件包裹'
        when 45 then '超大集包处罚'
        when 46 then '不集包'
        when 47 then '理赔处理不及时'
        when 48 then '面单粘贴不规范'
        when 49 then '未换单'
        when 50 then '集包标签不规范'
        when 51 then '未及时关闭揽件任务'
        when 52 then '虚假上报（虚假违规件上报）'
        when 53 then '虚假错分'
        when 54 then '物品类型错误（水果件）'
        when 55 then '虚假上报车辆里程'
        when 56 then '物品类型错误（文件）'
        when 57 then '旷工罚款'
        when 58 then '虚假取消揽件任务'
        when 59 then '72h未联系客户道歉'
        when 60 then '虚假标记拒收'
        when 61 then '外协投诉主管未及时道歉'
        when 62 then '外协投诉客户不接受道歉'
        when 63 then '揽派件照片不合格'
        when 64 then '揽件任务未及时分配'
        when 65 then '网点未及时上传回款凭证'
        when 66 then '网点上传虚假回款凭证'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1 then '超大件'
        when 2 then '违禁品'
        when 3 then '寄件人电话号码是空号'
        when 4 then '收件人电话号码是空号'
        when 5 then '虛假上报车里程模糊'
        when 6 then '虛假上报车里程'
        when 7 then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8 then '重量差（复秤-揽收）（2kg,5kg]'
        when 9 then '重量差（复秤-揽收）>5kg'
        when 10 then '重量差（复秤-揽收）<-0.5kg'
        when 11 then '重量差（复秤-揽收）（1kg,3kg]'
        when 12 then '重量差（复秤-揽收）（3kg,6kg]'
        when 13 then '重量差（复秤-揽收）>6kg'
        when 14 then '重量差（复秤-揽收）<-1kg'
        when 15 then '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16 then '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17 then '尺寸差（复秤-揽收）>30cm'
        when 18 then '尺寸差（复秤-揽收）<-10cm'
        when 22 then '虛假上报车里程 虚假-图片与数字不符合'
        when 23 then '虛假上报车里程 虚假-滥用油卡'
    end as '具体原因'
    ,coalesce(aq.abnormal_money,am.punish_money) 处罚金额
#     ,case
#         when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
#         when am.isdel = 1 then 0.00
#         else am.punish_money
#     end 处罚金额
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,dt.store_id 责任网点ID
    ,dt.store_name 责任网点
    ,ddd.cn_element 最后有效路由
    ,am.route_at 最后有效路由时间
    ,am.reward_staff_info_id 奖励员工ID
    ,am.reward_money 奖励金额
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when  1 then '业务不熟练'
        when  2 then '虚假签收'
        when  3 then '以不礼貌的态度对待客户'
        when  4 then '揽/派件动作慢'
        when  5 then '未经客户同意投递他处'
        when  6 then '未经客户同意改约时间'
        when  7 then '不接客户电话'
        when  8 then '包裹丢失 没有数据'
        when  9 then '改约的时间和客户沟通的时间不一致'
        when  10 then '未提前电话联系客户'
        when  11 then '包裹破损 没有数据'
        when  12 then '未按照改约时间派件'
        when  13 then '未按订单带包装'
        when  14 then '不找零钱'
        when  15 then '客户通话记录内未看到员工电话'
        when  16 then '未经客户允许取消揽件任务'
        when  17 then '未给客户回执'
        when  18 then '拨打电话时间太短，客户来不及接电话'
        when  19 then '未经客户允许退件'
        when  20 then '没有上门'
        when  21 then '其他'
        when  22 then '未经客户同意改约揽件时间'
        when  23 then '改约的揽件时间和客户要求的时间不一致'
        when  24 then '没有按照改约时间揽件'
        when  25 then '揽件前未提前联系客户'
        when  26 then '答应客户揽件，但最终没有揽'
        when  27 then '很晚才打电话联系客户'
        when  28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when  29 then '因为超过当日截单时间，要求客户取消'
        when  30 then '声称不是自己负责的区域，要求客户取消'
        when  31 then '拨打电话时间太短，客户来不及接电话'
        when  32 then '不接听客户回复的电话'
        when  33 then '答应客户今天上门，但最终没有揽收'
        when  34 then '没有上门揽件，也没有打电话联系客户'
        when  35 then '货物不属于超大件/违禁品'
        when  36 then '没有收到包裹，且快递员没有联系客户'
        when  37 then '快递员拒绝上门派送'
        when  38 then '快递员擅自将包裹放在门口或他处'
        when  39 then '快递员没有按约定的时间派送'
        when  40 then '代替客户签收包裹'
        when  41 then '快说话不礼貌/没有礼貌/不愿意服务'
        when  42 then '说话不礼貌/没有礼貌/不愿意服务'
        when  43 then '快递员抛包裹'
        when  44 then '报复/骚扰客户'
        when  45 then '快递员收错COD金额'
        when  46 then '虚假妥投'
        when  47 then '派件虚假留仓件/问题件'
        when  48 then '虚假揽件改约时间/取消揽件任务'
        when  49 then '抛客户包裹'
        when  50 then '录入客户信息不正确'
        when  51 then '送货前未电话联系'
        when  52 then '未在约定时间上门'
        when  53 then '上门前不电话联系'
        when  54 then '以不礼貌的态度对待客户'
        when  55 then '录入客户信息不正确'
        when  56 then '与客户发生肢体接触'
        when  57 then '辱骂客户'
        when  58 then '威胁客户'
        when  59 then '上门揽件慢'
        when  60 then '快递员拒绝上门揽件'
        when  61 then '未经客户同意标记收件人拒收'
        when  62 then '未按照系统地址送货导致收件人拒收'
        when  63 then '情况不属实，快递员虚假标记'
        when  64 then '情况不属实，快递员诱导客户改约时间'
        when  65 then '包裹长时间未派送'
        when  66 then '未经同意拒收包裹'
        when  67 then '已交费仍索要COD'
        when  68 then '投递时要求开箱'
        when  69 then '不当场扫描揽收'
        when  70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.edit_reason 备注
    ,am.abnormal_time 异常时间
    ,am.last_edit_staff_info_id 最后操作人
    ,am.updated_at 处理时间
    ,am.edit_reason 处理原因
from my_bi.abnormal_message am
left join my_bi.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_my_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join my_bi.abnormal_qaqc aq on aq.abnormal_message_id = am.id
left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and ddd.db = 'mt_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    am.abnormal_time >= '2023-10-01'
    and am.abnormal_time < '2023-11-01'
    -- and am.state = 1
    and am.isdel = 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     dt.region_name 大区
#     ,dt.piece_name 片区
#     ,dt.store_name 网点
    count(am.merge_column)
#     am.merge_column 关联信息
#     ,case am.`punish_category`
#         when 1 then '虚假问题件/虚假留仓件'
#         when 2 then '5天以内未妥投，且超24小时未更新'
#         when 3 then '5天以上未妥投/未中转，且超24小时未更新'
#         when 4 then '对问题件解决不及时'
#         when 5 then '包裹配送时间超三天'
#         when 6 then '未在客户要求的改约时间之前派送包裹'
#         when 7 then '包裹丢失'
#         when 8 then '包裹破损'
#         when 9 then '其他'
#         when 10 then '揽件时称量包裹不准确'
#         when 11 then '出纳回款不及时'
#         when 12 then '迟到罚款 每分钟10泰铢'
#         when 13 then '揽收或中转包裹未及时发出'
#         when 14 then '仓管对工单处理不及时'
#         when 15 then '仓管未及时处理问题件包裹'
#         when 16 then '客户投诉罚款 已废弃'
#         when 17 then '故意不接公司电话 自定义'
#         when 18 then '仓管未交接speed/优先包裹给快递员'
#         when 19 then 'pri或者speed包裹未妥投'
#         when 20 then '虚假妥投'
#         when 21 then '客户投诉'
#         when 22 then '快递员公款超时未上缴'
#         when 23 then 'minics工单处理不及时'
#         when 24 then '客户投诉-虚假问题件/虚假留仓件'
#         when 25 then '揽收禁运包裹'
#         when 26 then '早退罚款'
#         when 27 then '班车发车晚点'
#         when 28 then '虚假回复工单'
#         when 29 then '未妥投包裹没有标记'
#         when 30 then '未妥投包裹没有入仓'
#         when 31 then 'speed/pri件派送中未及时联系客户'
#         when 32 then '仓管未及时交接speed/pri优先包裹'
#         when 33 then '揽收不及时'
#         when 34 then '网点应盘点包裹未清零'
#         when 35 then '漏揽收'
#         when 36 then '包裹外包装不合格'
#         when 37 then '超大件'
#         when 38 then '多面单'
#         when 39 then '不称重包裹未入仓'
#         when 40 then '上传虚假照片'
#         when 41 then '网点到件漏扫描'
#         when 42 then '虚假撤销'
#         when 43 then '虚假揽件标记'
#         when 44 then '外协员工日交接不满50件包裹'
#         when 45 then '超大集包处罚'
#         when 46 then '不集包'
#         when 47 then '理赔处理不及时'
#         when 48 then '面单粘贴不规范'
#         when 49 then '未换单'
#         when 50 then '集包标签不规范'
#         when 51 then '未及时关闭揽件任务'
#         when 52 then '虚假上报（虚假违规件上报）'
#         when 53 then '虚假错分'
#         when 54 then '物品类型错误（水果件）'
#         when 55 then '虚假上报车辆里程'
#         when 56 then '物品类型错误（文件）'
#         when 57 then '旷工罚款'
#         when 58 then '虚假取消揽件任务'
#         when 59 then '72h未联系客户道歉'
#         when 60 then '虚假标记拒收'
#         when 61 then '外协投诉主管未及时道歉'
#         when 62 then '外协投诉客户不接受道歉'
#         when 63 then '揽派件照片不合格'
#         when 64 then '揽件任务未及时分配'
#         when 65 then '网点未及时上传回款凭证'
#         when 66 then '网点上传虚假回款凭证'
#         when 67 then '时效延迟'
#         when 68 then '未及时呼叫快递员'
#         when 69 then '未及时尝试派送'
#         when 70 then '退件包裹未处理'
#         when 71 then '不更新包裹状态'
#         when 72 then 'PRI包裹未及时妥投'
#         when 73 then '临近时效包裹未及时妥投'
#     end as '处罚原因'
#     ,case am.`punish_sub_category`
#         when 1 then '超大件'
#         when 2 then '违禁品'
#         when 3 then '寄件人电话号码是空号'
#         when 4 then '收件人电话号码是空号'
#         when 5 then '虛假上报车里程模糊'
#         when 6 then '虛假上报车里程'
#         when 7 then '重量差（复秤-揽收）（0.5kg,2kg]'
#         when 8 then '重量差（复秤-揽收）（2kg,5kg]'
#         when 9 then '重量差（复秤-揽收）>5kg'
#         when 10 then '重量差（复秤-揽收）<-0.5kg'
#         when 11 then '重量差（复秤-揽收）（1kg,3kg]'
#         when 12 then '重量差（复秤-揽收）（3kg,6kg]'
#         when 13 then '重量差（复秤-揽收）>6kg'
#         when 14 then '重量差（复秤-揽收）<-1kg'
#         when 15 then '尺寸差（复秤-揽收）(10cm,20cm]'
#         when 16 then '尺寸差（复秤-揽收）(20cm,30cm]'
#         when 17 then '尺寸差（复秤-揽收）>30cm'
#         when 18 then '尺寸差（复秤-揽收）<-10cm'
#         when 22 then '虛假上报车里程 虚假-图片与数字不符合'
#         when 23 then '虛假上报车里程 虚假-滥用油卡'
#         when 71 then  '重量差（复秤后-复秤前）【KG】（2kg,5kg]'
#         when 72 then   '重量差（复秤后-复秤前）【KG】 >5 kg'
#         when 73 then   '重量差（复秤后-复秤前）【KG】<-2kg'
#         when 74 then   '尺寸差（复秤后-复秤前）【CM】(20,30]'
#         when 75 then   '尺寸差（复秤后-复秤前）【CM】>30'
#         when 76 then   '尺寸差（复秤后-复秤前）【CM】<-20'
#     end as '具体原因'
#     ,coalesce(aq.abnormal_money,am.punish_money) 处罚金额
# #     ,case
# #         when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
# #         when am.isdel = 1 then 0.00
# #         else am.punish_money
# #     end 处罚金额
#     ,am.staff_info_id 工号
#     ,hsi.name 员工姓名
#     ,dt.store_id 责任网点ID
#     ,dt.store_name 责任网点
#     ,ddd.cn_element 最后有效路由
#     ,am.route_at 最后有效路由时间
#     ,am.reward_staff_info_id 奖励员工ID
#     ,am.reward_money 奖励金额
#     ,case acc.`complaints_type`
#         when 6 then '服务态度类投诉 1级'
#         when 2 then '虚假揽件改约时间/取消揽件任务 2级'
#         when 1 then '虚假妥投 3级'
#         when 3 then '派件虚假留仓件/问题件 4级'
#         when 7 then '操作规范类投诉 5级'
#         when 5 then '其他 6级'
#         when 4 then '普通客诉 已弃用，仅供展示历史'
#         when 8 then '不当场扫描揽收 7级'
#     end as 投诉大类
#     ,case acc.complaints_sub_type
#         when  1 then '业务不熟练'
#         when  2 then '虚假签收'
#         when  3 then '以不礼貌的态度对待客户'
#         when  4 then '揽/派件动作慢'
#         when  5 then '未经客户同意投递他处'
#         when  6 then '未经客户同意改约时间'
#         when  7 then '不接客户电话'
#         when  8 then '包裹丢失 没有数据'
#         when  9 then '改约的时间和客户沟通的时间不一致'
#         when  10 then '未提前电话联系客户'
#         when  11 then '包裹破损 没有数据'
#         when  12 then '未按照改约时间派件'
#         when  13 then '未按订单带包装'
#         when  14 then '不找零钱'
#         when  15 then '客户通话记录内未看到员工电话'
#         when  16 then '未经客户允许取消揽件任务'
#         when  17 then '未给客户回执'
#         when  18 then '拨打电话时间太短，客户来不及接电话'
#         when  19 then '未经客户允许退件'
#         when  20 then '没有上门'
#         when  21 then '其他'
#         when  22 then '未经客户同意改约揽件时间'
#         when  23 then '改约的揽件时间和客户要求的时间不一致'
#         when  24 then '没有按照改约时间揽件'
#         when  25 then '揽件前未提前联系客户'
#         when  26 then '答应客户揽件，但最终没有揽'
#         when  27 then '很晚才打电话联系客户'
#         when  28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
#         when  29 then '因为超过当日截单时间，要求客户取消'
#         when  30 then '声称不是自己负责的区域，要求客户取消'
#         when  31 then '拨打电话时间太短，客户来不及接电话'
#         when  32 then '不接听客户回复的电话'
#         when  33 then '答应客户今天上门，但最终没有揽收'
#         when  34 then '没有上门揽件，也没有打电话联系客户'
#         when  35 then '货物不属于超大件/违禁品'
#         when  36 then '没有收到包裹，且快递员没有联系客户'
#         when  37 then '快递员拒绝上门派送'
#         when  38 then '快递员擅自将包裹放在门口或他处'
#         when  39 then '快递员没有按约定的时间派送'
#         when  40 then '代替客户签收包裹'
#         when  41 then '快说话不礼貌/没有礼貌/不愿意服务'
#         when  42 then '说话不礼貌/没有礼貌/不愿意服务'
#         when  43 then '快递员抛包裹'
#         when  44 then '报复/骚扰客户'
#         when  45 then '快递员收错COD金额'
#         when  46 then '虚假妥投'
#         when  47 then '派件虚假留仓件/问题件'
#         when  48 then '虚假揽件改约时间/取消揽件任务'
#         when  49 then '抛客户包裹'
#         when  50 then '录入客户信息不正确'
#         when  51 then '送货前未电话联系'
#         when  52 then '未在约定时间上门'
#         when  53 then '上门前不电话联系'
#         when  54 then '以不礼貌的态度对待客户'
#         when  55 then '录入客户信息不正确'
#         when  56 then '与客户发生肢体接触'
#         when  57 then '辱骂客户'
#         when  58 then '威胁客户'
#         when  59 then '上门揽件慢'
#         when  60 then '快递员拒绝上门揽件'
#         when  61 then '未经客户同意标记收件人拒收'
#         when  62 then '未按照系统地址送货导致收件人拒收'
#         when  63 then '情况不属实，快递员虚假标记'
#         when  64 then '情况不属实，快递员诱导客户改约时间'
#         when  65 then '包裹长时间未派送'
#         when  66 then '未经同意拒收包裹'
#         when  67 then '已交费仍索要COD'
#         when  68 then '投递时要求开箱'
#         when  69 then '不当场扫描揽收'
#         when  70 then '揽派件速度慢'
#     end as '投诉原因'
#     ,am.edit_reason 备注
#     ,am.abnormal_time 异常时间
#     ,am.last_edit_staff_info_id 最后操作人
#     ,am.updated_at 处理时间
#     ,am.edit_reason 处理原因
from my_bi.abnormal_message am
left join my_bi.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_my_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join my_bi.abnormal_qaqc aq on aq.abnormal_message_id = am.id
left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and ddd.db = 'mt_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    am.abnormal_time >= '2023-10-01'
    and am.abnormal_time < '2023-11-01'
    -- and am.state = 1
    and am.isdel = 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     dt.region_name 大区
#     ,dt.piece_name 片区
#     ,dt.store_name 网点
#     count(am.merge_column)
    am.merge_column 关联信息
    ,case am.`punish_category`
        when 1 then '虚假问题件/虚假留仓件'
        when 2 then '5天以内未妥投，且超24小时未更新'
        when 3 then '5天以上未妥投/未中转，且超24小时未更新'
        when 4 then '对问题件解决不及时'
        when 5 then '包裹配送时间超三天'
        when 6 then '未在客户要求的改约时间之前派送包裹'
        when 7 then '包裹丢失'
        when 8 then '包裹破损'
        when 9 then '其他'
        when 10 then '揽件时称量包裹不准确'
        when 11 then '出纳回款不及时'
        when 12 then '迟到罚款 每分钟10泰铢'

        when 13 then '揽收或中转包裹未及时发出'
        when 14 then '仓管对工单处理不及时'
        when 15 then '仓管未及时处理问题件包裹'
        when 16 then '客户投诉罚款 已废弃'
        when 17 then '故意不接公司电话 自定义'
        when 18 then '仓管未交接speed/优先包裹给快递员'
        when 19 then 'pri或者speed包裹未妥投'
        when 20 then '虚假妥投'
        when 21 then '客户投诉'
        when 22 then '快递员公款超时未上缴'
        when 23 then 'minics工单处理不及时'
        when 24 then '客户投诉-虚假问题件/虚假留仓件'
        when 25 then '揽收禁运包裹'
        when 26 then '早退罚款'
        when 27 then '班车发车晚点'
        when 28 then '虚假回复工单'
        when 29 then '未妥投包裹没有标记'
        when 30 then '未妥投包裹没有入仓'
        when 31 then 'speed/pri件派送中未及时联系客户'
        when 32 then '仓管未及时交接speed/pri优先包裹'
        when 33 then '揽收不及时'
        when 34 then '网点应盘点包裹未清零'
        when 35 then '漏揽收'
        when 36 then '包裹外包装不合格'
        when 37 then '超大件'
        when 38 then '多面单'
        when 39 then '不称重包裹未入仓'
        when 40 then '上传虚假照片'
        when 41 then '网点到件漏扫描'
        when 42 then '虚假撤销'
        when 43 then '虚假揽件标记'
        when 44 then '外协员工日交接不满50件包裹'
        when 45 then '超大集包处罚'
        when 46 then '不集包'
        when 47 then '理赔处理不及时'
        when 48 then '面单粘贴不规范'
        when 49 then '未换单'
        when 50 then '集包标签不规范'
        when 51 then '未及时关闭揽件任务'
        when 52 then '虚假上报（虚假违规件上报）'
        when 53 then '虚假错分'
        when 54 then '物品类型错误（水果件）'
        when 55 then '虚假上报车辆里程'
        when 56 then '物品类型错误（文件）'
        when 57 then '旷工罚款'
        when 58 then '虚假取消揽件任务'
        when 59 then '72h未联系客户道歉'
        when 60 then '虚假标记拒收'
        when 61 then '外协投诉主管未及时道歉'
        when 62 then '外协投诉客户不接受道歉'
        when 63 then '揽派件照片不合格'
        when 64 then '揽件任务未及时分配'
        when 65 then '网点未及时上传回款凭证'
        when 66 then '网点上传虚假回款凭证'
        when 67 then '时效延迟'
        when 68 then '未及时呼叫快递员'
        when 69 then '未及时尝试派送'
        when 70 then '退件包裹未处理'
        when 71 then '不更新包裹状态'
        when 72 then 'PRI包裹未及时妥投'
        when 73 then '临近时效包裹未及时妥投'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1 then '超大件'
        when 2 then '违禁品'
        when 3 then '寄件人电话号码是空号'
        when 4 then '收件人电话号码是空号'
        when 5 then '虛假上报车里程模糊'
        when 6 then '虛假上报车里程'
        when 7 then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8 then '重量差（复秤-揽收）（2kg,5kg]'
        when 9 then '重量差（复秤-揽收）>5kg'
        when 10 then '重量差（复秤-揽收）<-0.5kg'
        when 11 then '重量差（复秤-揽收）（1kg,3kg]'
        when 12 then '重量差（复秤-揽收）（3kg,6kg]'
        when 13 then '重量差（复秤-揽收）>6kg'
        when 14 then '重量差（复秤-揽收）<-1kg'
        when 15 then '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16 then '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17 then '尺寸差（复秤-揽收）>30cm'
        when 18 then '尺寸差（复秤-揽收）<-10cm'
        when 22 then '虛假上报车里程 虚假-图片与数字不符合'
        when 23 then '虛假上报车里程 虚假-滥用油卡'
        when 71 then  '重量差（复秤后-复秤前）【KG】（2kg,5kg]'
        when 72 then   '重量差（复秤后-复秤前）【KG】 >5 kg'
        when 73 then   '重量差（复秤后-复秤前）【KG】<-2kg'
        when 74 then   '尺寸差（复秤后-复秤前）【CM】(20,30]'
        when 75 then   '尺寸差（复秤后-复秤前）【CM】>30'
        when 76 then   '尺寸差（复秤后-复秤前）【CM】<-20'
    end as '具体原因'
    ,coalesce(aq.abnormal_money,am.punish_money) 处罚金额
#     ,case
#         when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
#         when am.isdel = 1 then 0.00
#         else am.punish_money
#     end 处罚金额
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,dt.store_id 责任网点ID
    ,dt.store_name 责任网点
    ,ddd.cn_element 最后有效路由
    ,am.route_at 最后有效路由时间
    ,am.reward_staff_info_id 奖励员工ID
    ,am.reward_money 奖励金额
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
        when 8 then '不当场扫描揽收 7级'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when  1 then '业务不熟练'
        when  2 then '虚假签收'
        when  3 then '以不礼貌的态度对待客户'
        when  4 then '揽/派件动作慢'
        when  5 then '未经客户同意投递他处'
        when  6 then '未经客户同意改约时间'
        when  7 then '不接客户电话'
        when  8 then '包裹丢失 没有数据'
        when  9 then '改约的时间和客户沟通的时间不一致'
        when  10 then '未提前电话联系客户'
        when  11 then '包裹破损 没有数据'
        when  12 then '未按照改约时间派件'
        when  13 then '未按订单带包装'
        when  14 then '不找零钱'
        when  15 then '客户通话记录内未看到员工电话'
        when  16 then '未经客户允许取消揽件任务'
        when  17 then '未给客户回执'
        when  18 then '拨打电话时间太短，客户来不及接电话'
        when  19 then '未经客户允许退件'
        when  20 then '没有上门'
        when  21 then '其他'
        when  22 then '未经客户同意改约揽件时间'
        when  23 then '改约的揽件时间和客户要求的时间不一致'
        when  24 then '没有按照改约时间揽件'
        when  25 then '揽件前未提前联系客户'
        when  26 then '答应客户揽件，但最终没有揽'
        when  27 then '很晚才打电话联系客户'
        when  28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when  29 then '因为超过当日截单时间，要求客户取消'
        when  30 then '声称不是自己负责的区域，要求客户取消'
        when  31 then '拨打电话时间太短，客户来不及接电话'
        when  32 then '不接听客户回复的电话'
        when  33 then '答应客户今天上门，但最终没有揽收'
        when  34 then '没有上门揽件，也没有打电话联系客户'
        when  35 then '货物不属于超大件/违禁品'
        when  36 then '没有收到包裹，且快递员没有联系客户'
        when  37 then '快递员拒绝上门派送'
        when  38 then '快递员擅自将包裹放在门口或他处'
        when  39 then '快递员没有按约定的时间派送'
        when  40 then '代替客户签收包裹'
        when  41 then '快说话不礼貌/没有礼貌/不愿意服务'
        when  42 then '说话不礼貌/没有礼貌/不愿意服务'
        when  43 then '快递员抛包裹'
        when  44 then '报复/骚扰客户'
        when  45 then '快递员收错COD金额'
        when  46 then '虚假妥投'
        when  47 then '派件虚假留仓件/问题件'
        when  48 then '虚假揽件改约时间/取消揽件任务'
        when  49 then '抛客户包裹'
        when  50 then '录入客户信息不正确'
        when  51 then '送货前未电话联系'
        when  52 then '未在约定时间上门'
        when  53 then '上门前不电话联系'
        when  54 then '以不礼貌的态度对待客户'
        when  55 then '录入客户信息不正确'
        when  56 then '与客户发生肢体接触'
        when  57 then '辱骂客户'
        when  58 then '威胁客户'
        when  59 then '上门揽件慢'
        when  60 then '快递员拒绝上门揽件'
        when  61 then '未经客户同意标记收件人拒收'
        when  62 then '未按照系统地址送货导致收件人拒收'
        when  63 then '情况不属实，快递员虚假标记'
        when  64 then '情况不属实，快递员诱导客户改约时间'
        when  65 then '包裹长时间未派送'
        when  66 then '未经同意拒收包裹'
        when  67 then '已交费仍索要COD'
        when  68 then '投递时要求开箱'
        when  69 then '不当场扫描揽收'
        when  70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.edit_reason 备注
    ,am.abnormal_time 异常时间
    ,am.last_edit_staff_info_id 最后操作人
    ,am.updated_at 处理时间
    ,am.edit_reason 处理原因
from my_bi.abnormal_message am
left join my_bi.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_my_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join my_bi.abnormal_qaqc aq on aq.abnormal_message_id = am.id
left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and ddd.db = 'mt_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    am.abnormal_time >= '2023-10-01'
    and am.abnormal_time < '2023-10-16'
    -- and am.state = 1
    and am.isdel = 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     dt.region_name 大区
#     ,dt.piece_name 片区
#     ,dt.store_name 网点
#     count(am.merge_column)
    am.merge_column 关联信息
    ,case am.`punish_category`
        when 1 then '虚假问题件/虚假留仓件'
        when 2 then '5天以内未妥投，且超24小时未更新'
        when 3 then '5天以上未妥投/未中转，且超24小时未更新'
        when 4 then '对问题件解决不及时'
        when 5 then '包裹配送时间超三天'
        when 6 then '未在客户要求的改约时间之前派送包裹'
        when 7 then '包裹丢失'
        when 8 then '包裹破损'
        when 9 then '其他'
        when 10 then '揽件时称量包裹不准确'
        when 11 then '出纳回款不及时'
        when 12 then '迟到罚款 每分钟10泰铢'

        when 13 then '揽收或中转包裹未及时发出'
        when 14 then '仓管对工单处理不及时'
        when 15 then '仓管未及时处理问题件包裹'
        when 16 then '客户投诉罚款 已废弃'
        when 17 then '故意不接公司电话 自定义'
        when 18 then '仓管未交接speed/优先包裹给快递员'
        when 19 then 'pri或者speed包裹未妥投'
        when 20 then '虚假妥投'
        when 21 then '客户投诉'
        when 22 then '快递员公款超时未上缴'
        when 23 then 'minics工单处理不及时'
        when 24 then '客户投诉-虚假问题件/虚假留仓件'
        when 25 then '揽收禁运包裹'
        when 26 then '早退罚款'
        when 27 then '班车发车晚点'
        when 28 then '虚假回复工单'
        when 29 then '未妥投包裹没有标记'
        when 30 then '未妥投包裹没有入仓'
        when 31 then 'speed/pri件派送中未及时联系客户'
        when 32 then '仓管未及时交接speed/pri优先包裹'
        when 33 then '揽收不及时'
        when 34 then '网点应盘点包裹未清零'
        when 35 then '漏揽收'
        when 36 then '包裹外包装不合格'
        when 37 then '超大件'
        when 38 then '多面单'
        when 39 then '不称重包裹未入仓'
        when 40 then '上传虚假照片'
        when 41 then '网点到件漏扫描'
        when 42 then '虚假撤销'
        when 43 then '虚假揽件标记'
        when 44 then '外协员工日交接不满50件包裹'
        when 45 then '超大集包处罚'
        when 46 then '不集包'
        when 47 then '理赔处理不及时'
        when 48 then '面单粘贴不规范'
        when 49 then '未换单'
        when 50 then '集包标签不规范'
        when 51 then '未及时关闭揽件任务'
        when 52 then '虚假上报（虚假违规件上报）'
        when 53 then '虚假错分'
        when 54 then '物品类型错误（水果件）'
        when 55 then '虚假上报车辆里程'
        when 56 then '物品类型错误（文件）'
        when 57 then '旷工罚款'
        when 58 then '虚假取消揽件任务'
        when 59 then '72h未联系客户道歉'
        when 60 then '虚假标记拒收'
        when 61 then '外协投诉主管未及时道歉'
        when 62 then '外协投诉客户不接受道歉'
        when 63 then '揽派件照片不合格'
        when 64 then '揽件任务未及时分配'
        when 65 then '网点未及时上传回款凭证'
        when 66 then '网点上传虚假回款凭证'
        when 67 then '时效延迟'
        when 68 then '未及时呼叫快递员'
        when 69 then '未及时尝试派送'
        when 70 then '退件包裹未处理'
        when 71 then '不更新包裹状态'
        when 72 then 'PRI包裹未及时妥投'
        when 73 then '临近时效包裹未及时妥投'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1 then '超大件'
        when 2 then '违禁品'
        when 3 then '寄件人电话号码是空号'
        when 4 then '收件人电话号码是空号'
        when 5 then '虛假上报车里程模糊'
        when 6 then '虛假上报车里程'
        when 7 then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8 then '重量差（复秤-揽收）（2kg,5kg]'
        when 9 then '重量差（复秤-揽收）>5kg'
        when 10 then '重量差（复秤-揽收）<-0.5kg'
        when 11 then '重量差（复秤-揽收）（1kg,3kg]'
        when 12 then '重量差（复秤-揽收）（3kg,6kg]'
        when 13 then '重量差（复秤-揽收）>6kg'
        when 14 then '重量差（复秤-揽收）<-1kg'
        when 15 then '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16 then '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17 then '尺寸差（复秤-揽收）>30cm'
        when 18 then '尺寸差（复秤-揽收）<-10cm'
        when 22 then '虛假上报车里程 虚假-图片与数字不符合'
        when 23 then '虛假上报车里程 虚假-滥用油卡'
        when 71 then  '重量差（复秤后-复秤前）【KG】（2kg,5kg]'
        when 72 then   '重量差（复秤后-复秤前）【KG】 >5 kg'
        when 73 then   '重量差（复秤后-复秤前）【KG】<-2kg'
        when 74 then   '尺寸差（复秤后-复秤前）【CM】(20,30]'
        when 75 then   '尺寸差（复秤后-复秤前）【CM】>30'
        when 76 then   '尺寸差（复秤后-复秤前）【CM】<-20'
    end as '具体原因'
    ,coalesce(aq.abnormal_money,am.punish_money) 处罚金额
#     ,case
#         when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
#         when am.isdel = 1 then 0.00
#         else am.punish_money
#     end 处罚金额
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,dt.store_id 责任网点ID
    ,dt.store_name 责任网点
    ,ddd.cn_element 最后有效路由
    ,am.route_at 最后有效路由时间
    ,am.reward_staff_info_id 奖励员工ID
    ,am.reward_money 奖励金额
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
        when 8 then '不当场扫描揽收 7级'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when  1 then '业务不熟练'
        when  2 then '虚假签收'
        when  3 then '以不礼貌的态度对待客户'
        when  4 then '揽/派件动作慢'
        when  5 then '未经客户同意投递他处'
        when  6 then '未经客户同意改约时间'
        when  7 then '不接客户电话'
        when  8 then '包裹丢失 没有数据'
        when  9 then '改约的时间和客户沟通的时间不一致'
        when  10 then '未提前电话联系客户'
        when  11 then '包裹破损 没有数据'
        when  12 then '未按照改约时间派件'
        when  13 then '未按订单带包装'
        when  14 then '不找零钱'
        when  15 then '客户通话记录内未看到员工电话'
        when  16 then '未经客户允许取消揽件任务'
        when  17 then '未给客户回执'
        when  18 then '拨打电话时间太短，客户来不及接电话'
        when  19 then '未经客户允许退件'
        when  20 then '没有上门'
        when  21 then '其他'
        when  22 then '未经客户同意改约揽件时间'
        when  23 then '改约的揽件时间和客户要求的时间不一致'
        when  24 then '没有按照改约时间揽件'
        when  25 then '揽件前未提前联系客户'
        when  26 then '答应客户揽件，但最终没有揽'
        when  27 then '很晚才打电话联系客户'
        when  28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when  29 then '因为超过当日截单时间，要求客户取消'
        when  30 then '声称不是自己负责的区域，要求客户取消'
        when  31 then '拨打电话时间太短，客户来不及接电话'
        when  32 then '不接听客户回复的电话'
        when  33 then '答应客户今天上门，但最终没有揽收'
        when  34 then '没有上门揽件，也没有打电话联系客户'
        when  35 then '货物不属于超大件/违禁品'
        when  36 then '没有收到包裹，且快递员没有联系客户'
        when  37 then '快递员拒绝上门派送'
        when  38 then '快递员擅自将包裹放在门口或他处'
        when  39 then '快递员没有按约定的时间派送'
        when  40 then '代替客户签收包裹'
        when  41 then '快说话不礼貌/没有礼貌/不愿意服务'
        when  42 then '说话不礼貌/没有礼貌/不愿意服务'
        when  43 then '快递员抛包裹'
        when  44 then '报复/骚扰客户'
        when  45 then '快递员收错COD金额'
        when  46 then '虚假妥投'
        when  47 then '派件虚假留仓件/问题件'
        when  48 then '虚假揽件改约时间/取消揽件任务'
        when  49 then '抛客户包裹'
        when  50 then '录入客户信息不正确'
        when  51 then '送货前未电话联系'
        when  52 then '未在约定时间上门'
        when  53 then '上门前不电话联系'
        when  54 then '以不礼貌的态度对待客户'
        when  55 then '录入客户信息不正确'
        when  56 then '与客户发生肢体接触'
        when  57 then '辱骂客户'
        when  58 then '威胁客户'
        when  59 then '上门揽件慢'
        when  60 then '快递员拒绝上门揽件'
        when  61 then '未经客户同意标记收件人拒收'
        when  62 then '未按照系统地址送货导致收件人拒收'
        when  63 then '情况不属实，快递员虚假标记'
        when  64 then '情况不属实，快递员诱导客户改约时间'
        when  65 then '包裹长时间未派送'
        when  66 then '未经同意拒收包裹'
        when  67 then '已交费仍索要COD'
        when  68 then '投递时要求开箱'
        when  69 then '不当场扫描揽收'
        when  70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.edit_reason 备注
    ,am.abnormal_time 异常时间
    ,am.last_edit_staff_info_id 最后操作人
    ,am.updated_at 处理时间
    ,am.edit_reason 处理原因
from my_bi.abnormal_message am
left join my_bi.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_my_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join my_bi.abnormal_qaqc aq on aq.abnormal_message_id = am.id
left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and ddd.db = 'mt_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    am.abnormal_time >= '2023-10-16'
    and am.abnormal_time < '2023-11-01'
    -- and am.state = 1
    and am.isdel = 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     dt.region_name 大区
#     ,dt.piece_name 片区
#     ,dt.store_name 网点
#     count(am.merge_column)
    am.merge_column 关联信息
    ,case am.`punish_category`
        when 1 then '虚假问题件/虚假留仓件'
        when 2 then '5天以内未妥投，且超24小时未更新'
        when 3 then '5天以上未妥投/未中转，且超24小时未更新'
        when 4 then '对问题件解决不及时'
        when 5 then '包裹配送时间超三天'
        when 6 then '未在客户要求的改约时间之前派送包裹'
        when 7 then '包裹丢失'
        when 8 then '包裹破损'
        when 9 then '其他'
        when 10 then '揽件时称量包裹不准确'
        when 11 then '出纳回款不及时'
        when 12 then '迟到罚款 每分钟10泰铢'

        when 13 then '揽收或中转包裹未及时发出'
        when 14 then '仓管对工单处理不及时'
        when 15 then '仓管未及时处理问题件包裹'
        when 16 then '客户投诉罚款 已废弃'
        when 17 then '故意不接公司电话 自定义'
        when 18 then '仓管未交接speed/优先包裹给快递员'
        when 19 then 'pri或者speed包裹未妥投'
        when 20 then '虚假妥投'
        when 21 then '客户投诉'
        when 22 then '快递员公款超时未上缴'
        when 23 then 'minics工单处理不及时'
        when 24 then '客户投诉-虚假问题件/虚假留仓件'
        when 25 then '揽收禁运包裹'
        when 26 then '早退罚款'
        when 27 then '班车发车晚点'
        when 28 then '虚假回复工单'
        when 29 then '未妥投包裹没有标记'
        when 30 then '未妥投包裹没有入仓'
        when 31 then 'speed/pri件派送中未及时联系客户'
        when 32 then '仓管未及时交接speed/pri优先包裹'
        when 33 then '揽收不及时'
        when 34 then '网点应盘点包裹未清零'
        when 35 then '漏揽收'
        when 36 then '包裹外包装不合格'
        when 37 then '超大件'
        when 38 then '多面单'
        when 39 then '不称重包裹未入仓'
        when 40 then '上传虚假照片'
        when 41 then '网点到件漏扫描'
        when 42 then '虚假撤销'
        when 43 then '虚假揽件标记'
        when 44 then '外协员工日交接不满50件包裹'
        when 45 then '超大集包处罚'
        when 46 then '不集包'
        when 47 then '理赔处理不及时'
        when 48 then '面单粘贴不规范'
        when 49 then '未换单'
        when 50 then '集包标签不规范'
        when 51 then '未及时关闭揽件任务'
        when 52 then '虚假上报（虚假违规件上报）'
        when 53 then '虚假错分'
        when 54 then '物品类型错误（水果件）'
        when 55 then '虚假上报车辆里程'
        when 56 then '物品类型错误（文件）'
        when 57 then '旷工罚款'
        when 58 then '虚假取消揽件任务'
        when 59 then '72h未联系客户道歉'
        when 60 then '虚假标记拒收'
        when 61 then '外协投诉主管未及时道歉'
        when 62 then '外协投诉客户不接受道歉'
        when 63 then '揽派件照片不合格'
        when 64 then '揽件任务未及时分配'
        when 65 then '网点未及时上传回款凭证'
        when 66 then '网点上传虚假回款凭证'
        when 67 then '时效延迟'
        when 68 then '未及时呼叫快递员'
        when 69 then '未及时尝试派送'
        when 70 then '退件包裹未处理'
        when 71 then '不更新包裹状态'
        when 72 then 'PRI包裹未及时妥投'
        when 73 then '临近时效包裹未及时妥投'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1 then '超大件'
        when 2 then '违禁品'
        when 3 then '寄件人电话号码是空号'
        when 4 then '收件人电话号码是空号'
        when 5 then '虛假上报车里程模糊'
        when 6 then '虛假上报车里程'
        when 7 then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8 then '重量差（复秤-揽收）（2kg,5kg]'
        when 9 then '重量差（复秤-揽收）>5kg'
        when 10 then '重量差（复秤-揽收）<-0.5kg'
        when 11 then '重量差（复秤-揽收）（1kg,3kg]'
        when 12 then '重量差（复秤-揽收）（3kg,6kg]'
        when 13 then '重量差（复秤-揽收）>6kg'
        when 14 then '重量差（复秤-揽收）<-1kg'
        when 15 then '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16 then '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17 then '尺寸差（复秤-揽收）>30cm'
        when 18 then '尺寸差（复秤-揽收）<-10cm'
        when 22 then '虛假上报车里程 虚假-图片与数字不符合'
        when 23 then '虛假上报车里程 虚假-滥用油卡'
        when 71 then  '重量差（复秤后-复秤前）【KG】（2kg,5kg]'
        when 72 then   '重量差（复秤后-复秤前）【KG】 >5 kg'
        when 73 then   '重量差（复秤后-复秤前）【KG】<-2kg'
        when 74 then   '尺寸差（复秤后-复秤前）【CM】(20,30]'
        when 75 then   '尺寸差（复秤后-复秤前）【CM】>30'
        when 76 then   '尺寸差（复秤后-复秤前）【CM】<-20'
    end as '具体原因'
    ,coalesce(aq.abnormal_money,am.punish_money) 处罚金额
#     ,case
#         when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
#         when am.isdel = 1 then 0.00
#         else am.punish_money
#     end 处罚金额
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,dt.store_id 责任网点ID
    ,dt.store_name 责任网点
    ,ddd.cn_element 最后有效路由
    ,am.route_at 最后有效路由时间
    ,am.reward_staff_info_id 奖励员工ID
    ,am.reward_money 奖励金额
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
        when 8 then '不当场扫描揽收 7级'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when  1 then '业务不熟练'
        when  2 then '虚假签收'
        when  3 then '以不礼貌的态度对待客户'
        when  4 then '揽/派件动作慢'
        when  5 then '未经客户同意投递他处'
        when  6 then '未经客户同意改约时间'
        when  7 then '不接客户电话'
        when  8 then '包裹丢失 没有数据'
        when  9 then '改约的时间和客户沟通的时间不一致'
        when  10 then '未提前电话联系客户'
        when  11 then '包裹破损 没有数据'
        when  12 then '未按照改约时间派件'
        when  13 then '未按订单带包装'
        when  14 then '不找零钱'
        when  15 then '客户通话记录内未看到员工电话'
        when  16 then '未经客户允许取消揽件任务'
        when  17 then '未给客户回执'
        when  18 then '拨打电话时间太短，客户来不及接电话'
        when  19 then '未经客户允许退件'
        when  20 then '没有上门'
        when  21 then '其他'
        when  22 then '未经客户同意改约揽件时间'
        when  23 then '改约的揽件时间和客户要求的时间不一致'
        when  24 then '没有按照改约时间揽件'
        when  25 then '揽件前未提前联系客户'
        when  26 then '答应客户揽件，但最终没有揽'
        when  27 then '很晚才打电话联系客户'
        when  28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when  29 then '因为超过当日截单时间，要求客户取消'
        when  30 then '声称不是自己负责的区域，要求客户取消'
        when  31 then '拨打电话时间太短，客户来不及接电话'
        when  32 then '不接听客户回复的电话'
        when  33 then '答应客户今天上门，但最终没有揽收'
        when  34 then '没有上门揽件，也没有打电话联系客户'
        when  35 then '货物不属于超大件/违禁品'
        when  36 then '没有收到包裹，且快递员没有联系客户'
        when  37 then '快递员拒绝上门派送'
        when  38 then '快递员擅自将包裹放在门口或他处'
        when  39 then '快递员没有按约定的时间派送'
        when  40 then '代替客户签收包裹'
        when  41 then '快说话不礼貌/没有礼貌/不愿意服务'
        when  42 then '说话不礼貌/没有礼貌/不愿意服务'
        when  43 then '快递员抛包裹'
        when  44 then '报复/骚扰客户'
        when  45 then '快递员收错COD金额'
        when  46 then '虚假妥投'
        when  47 then '派件虚假留仓件/问题件'
        when  48 then '虚假揽件改约时间/取消揽件任务'
        when  49 then '抛客户包裹'
        when  50 then '录入客户信息不正确'
        when  51 then '送货前未电话联系'
        when  52 then '未在约定时间上门'
        when  53 then '上门前不电话联系'
        when  54 then '以不礼貌的态度对待客户'
        when  55 then '录入客户信息不正确'
        when  56 then '与客户发生肢体接触'
        when  57 then '辱骂客户'
        when  58 then '威胁客户'
        when  59 then '上门揽件慢'
        when  60 then '快递员拒绝上门揽件'
        when  61 then '未经客户同意标记收件人拒收'
        when  62 then '未按照系统地址送货导致收件人拒收'
        when  63 then '情况不属实，快递员虚假标记'
        when  64 then '情况不属实，快递员诱导客户改约时间'
        when  65 then '包裹长时间未派送'
        when  66 then '未经同意拒收包裹'
        when  67 then '已交费仍索要COD'
        when  68 then '投递时要求开箱'
        when  69 then '不当场扫描揽收'
        when  70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.edit_reason 备注
    ,am.abnormal_time 异常时间
    ,am.last_edit_staff_info_id 最后操作人
    ,am.updated_at 处理时间
    ,am.edit_reason 处理原因
from my_bi.abnormal_message am
left join my_bi.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_my_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join my_bi.abnormal_qaqc aq on aq.abnormal_message_id = am.id
left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    am.abnormal_time >= '2023-10-16'
    and am.abnormal_time < '2023-11-01'
    -- and am.state = 1
    and am.isdel = 1;
;-- -. . -..- - / . -. - .-. -.--
select
#     dt.region_name 大区
#     ,dt.piece_name 片区
#     ,dt.store_name 网点
#     count(am.merge_column)
    am.merge_column 关联信息
    ,case am.`punish_category`
        when 1 then '虚假问题件/虚假留仓件'
        when 2 then '5天以内未妥投，且超24小时未更新'
        when 3 then '5天以上未妥投/未中转，且超24小时未更新'
        when 4 then '对问题件解决不及时'
        when 5 then '包裹配送时间超三天'
        when 6 then '未在客户要求的改约时间之前派送包裹'
        when 7 then '包裹丢失'
        when 8 then '包裹破损'
        when 9 then '其他'
        when 10 then '揽件时称量包裹不准确'
        when 11 then '出纳回款不及时'
        when 12 then '迟到罚款 每分钟10泰铢'

        when 13 then '揽收或中转包裹未及时发出'
        when 14 then '仓管对工单处理不及时'
        when 15 then '仓管未及时处理问题件包裹'
        when 16 then '客户投诉罚款 已废弃'
        when 17 then '故意不接公司电话 自定义'
        when 18 then '仓管未交接speed/优先包裹给快递员'
        when 19 then 'pri或者speed包裹未妥投'
        when 20 then '虚假妥投'
        when 21 then '客户投诉'
        when 22 then '快递员公款超时未上缴'
        when 23 then 'minics工单处理不及时'
        when 24 then '客户投诉-虚假问题件/虚假留仓件'
        when 25 then '揽收禁运包裹'
        when 26 then '早退罚款'
        when 27 then '班车发车晚点'
        when 28 then '虚假回复工单'
        when 29 then '未妥投包裹没有标记'
        when 30 then '未妥投包裹没有入仓'
        when 31 then 'speed/pri件派送中未及时联系客户'
        when 32 then '仓管未及时交接speed/pri优先包裹'
        when 33 then '揽收不及时'
        when 34 then '网点应盘点包裹未清零'
        when 35 then '漏揽收'
        when 36 then '包裹外包装不合格'
        when 37 then '超大件'
        when 38 then '多面单'
        when 39 then '不称重包裹未入仓'
        when 40 then '上传虚假照片'
        when 41 then '网点到件漏扫描'
        when 42 then '虚假撤销'
        when 43 then '虚假揽件标记'
        when 44 then '外协员工日交接不满50件包裹'
        when 45 then '超大集包处罚'
        when 46 then '不集包'
        when 47 then '理赔处理不及时'
        when 48 then '面单粘贴不规范'
        when 49 then '未换单'
        when 50 then '集包标签不规范'
        when 51 then '未及时关闭揽件任务'
        when 52 then '虚假上报（虚假违规件上报）'
        when 53 then '虚假错分'
        when 54 then '物品类型错误（水果件）'
        when 55 then '虚假上报车辆里程'
        when 56 then '物品类型错误（文件）'
        when 57 then '旷工罚款'
        when 58 then '虚假取消揽件任务'
        when 59 then '72h未联系客户道歉'
        when 60 then '虚假标记拒收'
        when 61 then '外协投诉主管未及时道歉'
        when 62 then '外协投诉客户不接受道歉'
        when 63 then '揽派件照片不合格'
        when 64 then '揽件任务未及时分配'
        when 65 then '网点未及时上传回款凭证'
        when 66 then '网点上传虚假回款凭证'
        when 67 then '时效延迟'
        when 68 then '未及时呼叫快递员'
        when 69 then '未及时尝试派送'
        when 70 then '退件包裹未处理'
        when 71 then '不更新包裹状态'
        when 72 then 'PRI包裹未及时妥投'
        when 73 then '临近时效包裹未及时妥投'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1 then '超大件'
        when 2 then '违禁品'
        when 3 then '寄件人电话号码是空号'
        when 4 then '收件人电话号码是空号'
        when 5 then '虛假上报车里程模糊'
        when 6 then '虛假上报车里程'
        when 7 then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8 then '重量差（复秤-揽收）（2kg,5kg]'
        when 9 then '重量差（复秤-揽收）>5kg'
        when 10 then '重量差（复秤-揽收）<-0.5kg'
        when 11 then '重量差（复秤-揽收）（1kg,3kg]'
        when 12 then '重量差（复秤-揽收）（3kg,6kg]'
        when 13 then '重量差（复秤-揽收）>6kg'
        when 14 then '重量差（复秤-揽收）<-1kg'
        when 15 then '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16 then '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17 then '尺寸差（复秤-揽收）>30cm'
        when 18 then '尺寸差（复秤-揽收）<-10cm'
        when 22 then '虛假上报车里程 虚假-图片与数字不符合'
        when 23 then '虛假上报车里程 虚假-滥用油卡'
        when 71 then  '重量差（复秤后-复秤前）【KG】（2kg,5kg]'
        when 72 then   '重量差（复秤后-复秤前）【KG】 >5 kg'
        when 73 then   '重量差（复秤后-复秤前）【KG】<-2kg'
        when 74 then   '尺寸差（复秤后-复秤前）【CM】(20,30]'
        when 75 then   '尺寸差（复秤后-复秤前）【CM】>30'
        when 76 then   '尺寸差（复秤后-复秤前）【CM】<-20'
    end as '具体原因'
    ,coalesce(aq.abnormal_money,am.punish_money) 处罚金额
#     ,case
#         when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
#         when am.isdel = 1 then 0.00
#         else am.punish_money
#     end 处罚金额
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,dt.store_id 责任网点ID
    ,dt.store_name 责任网点
    ,ddd.cn_element 最后有效路由
    ,am.route_at 最后有效路由时间
    ,am.reward_staff_info_id 奖励员工ID
    ,am.reward_money 奖励金额
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
        when 8 then '不当场扫描揽收 7级'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when  1 then '业务不熟练'
        when  2 then '虚假签收'
        when  3 then '以不礼貌的态度对待客户'
        when  4 then '揽/派件动作慢'
        when  5 then '未经客户同意投递他处'
        when  6 then '未经客户同意改约时间'
        when  7 then '不接客户电话'
        when  8 then '包裹丢失 没有数据'
        when  9 then '改约的时间和客户沟通的时间不一致'
        when  10 then '未提前电话联系客户'
        when  11 then '包裹破损 没有数据'
        when  12 then '未按照改约时间派件'
        when  13 then '未按订单带包装'
        when  14 then '不找零钱'
        when  15 then '客户通话记录内未看到员工电话'
        when  16 then '未经客户允许取消揽件任务'
        when  17 then '未给客户回执'
        when  18 then '拨打电话时间太短，客户来不及接电话'
        when  19 then '未经客户允许退件'
        when  20 then '没有上门'
        when  21 then '其他'
        when  22 then '未经客户同意改约揽件时间'
        when  23 then '改约的揽件时间和客户要求的时间不一致'
        when  24 then '没有按照改约时间揽件'
        when  25 then '揽件前未提前联系客户'
        when  26 then '答应客户揽件，但最终没有揽'
        when  27 then '很晚才打电话联系客户'
        when  28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when  29 then '因为超过当日截单时间，要求客户取消'
        when  30 then '声称不是自己负责的区域，要求客户取消'
        when  31 then '拨打电话时间太短，客户来不及接电话'
        when  32 then '不接听客户回复的电话'
        when  33 then '答应客户今天上门，但最终没有揽收'
        when  34 then '没有上门揽件，也没有打电话联系客户'
        when  35 then '货物不属于超大件/违禁品'
        when  36 then '没有收到包裹，且快递员没有联系客户'
        when  37 then '快递员拒绝上门派送'
        when  38 then '快递员擅自将包裹放在门口或他处'
        when  39 then '快递员没有按约定的时间派送'
        when  40 then '代替客户签收包裹'
        when  41 then '快说话不礼貌/没有礼貌/不愿意服务'
        when  42 then '说话不礼貌/没有礼貌/不愿意服务'
        when  43 then '快递员抛包裹'
        when  44 then '报复/骚扰客户'
        when  45 then '快递员收错COD金额'
        when  46 then '虚假妥投'
        when  47 then '派件虚假留仓件/问题件'
        when  48 then '虚假揽件改约时间/取消揽件任务'
        when  49 then '抛客户包裹'
        when  50 then '录入客户信息不正确'
        when  51 then '送货前未电话联系'
        when  52 then '未在约定时间上门'
        when  53 then '上门前不电话联系'
        when  54 then '以不礼貌的态度对待客户'
        when  55 then '录入客户信息不正确'
        when  56 then '与客户发生肢体接触'
        when  57 then '辱骂客户'
        when  58 then '威胁客户'
        when  59 then '上门揽件慢'
        when  60 then '快递员拒绝上门揽件'
        when  61 then '未经客户同意标记收件人拒收'
        when  62 then '未按照系统地址送货导致收件人拒收'
        when  63 then '情况不属实，快递员虚假标记'
        when  64 then '情况不属实，快递员诱导客户改约时间'
        when  65 then '包裹长时间未派送'
        when  66 then '未经同意拒收包裹'
        when  67 then '已交费仍索要COD'
        when  68 then '投递时要求开箱'
        when  69 then '不当场扫描揽收'
        when  70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.edit_reason 备注
    ,am.abnormal_time 异常时间
    ,am.last_edit_staff_info_id 最后操作人
    ,am.updated_at 处理时间
    ,am.edit_reason 处理原因
from my_bi.abnormal_message am
left join my_bi.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_my_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join my_bi.abnormal_qaqc aq on aq.abnormal_message_id = am.id
left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    am.abnormal_time >= '2023-10-01'
    and am.abnormal_time < '2023-10-16'
    -- and am.state = 1
    and am.isdel = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    swa.started_store_id
    ,swa.end_store_id
    ,swa.attendance_date 打卡日期
    ,count(distinct coalesce(hsa.staff_info_id, swa.staff_info_id)) 当日打卡人数
from my_backyard.staff_work_attendance swa
left join my_backyard.hr_staff_apply_support_store hsa on hsa.sub_staff_info_id = swa.staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= swa.attendance_date and hsa.employment_end_date >= swa.attendance_date
where
    swa.attendance_date >= '2023-11-09'
    and swa.attendance_date <= '2023-11-21'
    and swa.job_title in (13,110,1199)
    and
        (
            swa.started_store_id in ('MY06010511','MY06011600','MY04020600','MY05010100','MY04070414','MY04060400','MY04010210','MY04050100','MY04060200')
            or swa.end_store_id in ('MY06010511','MY06011600','MY04020600','MY05010100','MY04070414','MY04060400','MY04010210','MY04050100','MY04060200')
        )
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
            ,pr.next_store_id
            ,json_extract(pr.extra_value, '$.proofId') proofId
            ,json_extract(pr.extra_value, '$.packPno') pack_no
            ,pr.routed_at
            ,pr.store_id
            ,pr.store_name
            ,ft.store_name ori_store_name
        from my_staging.parcel_route pr
        left join my_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.store_id = ft.next_store_id
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
            and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.packPno') is not null
    )
, a as
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at
            ,ddd.cn_element
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk1
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk2
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
            and pr.route_action in ('UNSEAL','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > t1.routed_at
    )
select
    date(convert_tz(t1.routed_at, '+00:00', '+08:00')) 整包到件日期
    ,t1.pno
    ,t1.pack_no 集包号
    ,t1.ori_store_name 上游网点名称
    ,t1.store_name 当前网点名称
    ,if(a2.store_id = t1.store_id, '是', '否') 最后操作网点是否在整包到件网点
    ,a2.cn_element 最后操作路由
    ,timestampdiff(second, b.route_time, a1.routed_at)/3600 时间差
    ,if(c.state = 6, '是', '否') 是否判责丢失
    ,case c.state
        when 6 then '丢失'
        when 5 then '无须追责'
    end  判责结果
    ,c.store 责任网点
    ,if(d.pno is not null , '是', '否') 是否有丢失找回
from t t1
left join a a1 on a1.pno = t1.pno and a1.rk1 = 1
left join a a2 on a2.pno = t1.pno and a2.rk2 = 1
left join
    (
        select
            pr.pno
            ,min(pr.routed_at) route_time
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        where
            pr.route_action in ('UNSEAL_NOT_SCANNED', 'HAVE_HAIR_SCAN_NO_TO')
        group by 1
    ) b on b.pno = t1.pno
left join
    (
        select
            plt.pno
            ,plt.state
            ,group_concat(plr.store_id) store
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        group by 1
    ) c on c.pno = t1.pno
left join
    (
        select
            plt.pno
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 4 -- 责任判定
        left join my_staging.parcel_route pr on pr.pno = t1.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(pcol.created_at, interval 8 hour)
            and pr.routed_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
        group by 1
    ) d on d.pno = t1.pno

where
    timestampdiff(second, t1.routed_at, a1.routed_at) > 10800;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            pr.pno
            ,pr.next_store_id
            ,json_extract(pr.extra_value, '$.proofId') proofId
            ,replace(json_extract(pr.extra_value, '$.packPno'), '"','') pack_no
            ,pr.routed_at
            ,pr.store_id
            ,pr.store_name
            ,ft.store_name ori_store_name
        from my_staging.parcel_route pr
        left join my_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.store_id = ft.next_store_id
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 11 day ), interval 8 hour)
            and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            and json_extract(pr.extra_value, '$.packPno') is not null
    )
, a as
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.routed_at
            ,ddd.cn_element
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk1
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk2
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
            and pr.route_action in ('UNSEAL','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > t1.routed_at
    )
select
    date(convert_tz(t1.routed_at, '+00:00', '+08:00')) 整包到件日期
    ,t1.pno
    ,t1.pack_no 集包号
    ,t1.ori_store_name 上游网点名称
    ,t1.store_name 当前网点名称
    ,if(a2.store_id = t1.store_id, '是', '否') 最后操作网点是否在整包到件网点
    ,a2.cn_element 最后操作路由
    ,timestampdiff(second, b.route_time, a1.routed_at)/3600 时间差
    ,if(c.state = 6, '是', '否') 是否判责丢失
    ,case c.state
        when 6 then '丢失'
        when 5 then '无须追责'
    end  判责结果
    ,c.store 责任网点
    ,if(d.pno is not null , '是', '否') 是否有丢失找回
from t t1
left join a a1 on a1.pno = t1.pno and a1.rk1 = 1
left join a a2 on a2.pno = t1.pno and a2.rk2 = 1
left join
    (
        select
            pr.pno
            ,min(pr.routed_at) route_time
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        where
            pr.route_action in ('UNSEAL_NOT_SCANNED', 'HAVE_HAIR_SCAN_NO_TO')
            and pr.routed_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
        group by 1
    ) b on b.pno = t1.pno
left join
    (
        select
            plt.pno
            ,plt.state
            ,group_concat(plr.store_id) store
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        where
            plt.created_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
        group by 1
    ) c on c.pno = t1.pno
left join
    (
        select
            plt.pno
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 4 -- 责任判定
        left join my_staging.parcel_route pr on pr.pno = t1.pno
        where
            pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.routed_at > date_sub(pcol.created_at, interval 8 hour)
            and pr.routed_at > date_sub(date_sub(curdate(), interval 16 day ), interval 8 hour)
        group by 1
    ) d on d.pno = t1.pno

where
    timestampdiff(second, t1.routed_at, a1.routed_at) > 10800;
;-- -. . -..- - / . -. - .-. -.--
select
    f2.大区
    ,f2.片区
    ,f2.网点
    ,f2.store_id
    ,f2.员工ID
    ,f2.快递员姓名
    ,f2.no_return_parcel_count 非退件交接量
    ,f2.no_return_delivery_parcel_count 非退件妥投量
    ,f2.return_delivery_parcel_count 退件妥投量
    ,f2.hand_no_call_count 交接包裹未拨打电话数
    ,f2.hand_no_call_ratio 交接包裹未拨打电话占比
from
    (
        select
            f1.*
            ,row_number() over (partition by f1.store_id, f1.员工ID order by f1.hand_no_call_ratio desc) rk
        from
            (
                select
                    fn.region_name as 大区
                    ,fn.piece_name as 片区
                    ,fn.store_name as 网点
                    ,fn.store_id
                    ,fn.staff_info_id as 员工ID
                    ,fn.staff_name as 快递员姓名
                    ,count(distinct if(fn.returned = 0, fn.pno, null)) as no_return_parcel_count
                    ,count(distinct if(fn.pi_state = 5 and fn.returned = 0, fn.pno, null)) no_return_delivery_parcel_count
                    ,count(distinct if(fn.pi_state = 5 and fn.returned = 1, fn.pno, null)) return_delivery_parcel_count
                    ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end) as hand_no_call_count
                    ,count(distinct case when  fn.before_17_calltimes is null and fn.pi_state not in(5,7,8,9) then fn.pno else null end)/count(distinct fn.pno) as hand_no_call_ratio
                from
                    (
                         select
                            fn.pno
                            ,fn.pno_type
                            ,fn.store_id
                            ,fn.store_name
                            ,fn.piece_name
                            ,fn.region_name
                            ,fn.staff_info_id
                            ,fn.staff_name
                            ,fn.finished_at
                            ,fn.pi_state
                            ,fn.returned
                            ,fn.before_17_calltimes
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,dp.store_name
                                    ,dp.piece_name
                                    ,dp.region_name
                                    ,pr.staff_info_id
                                    ,pi.state pi_state
                                    ,pi.returned
                                    ,convert_tz(pi.updated_at,'+00:00','+08:00') as pi_updated_at
                                    ,if(pi.returned=1,'退件','正向件') as pno_type
                                    ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                                    ,pr.staff_name
                                    ,pr2.before_17_calltimes
                                from
                                    ( # 所有17点前交接包裹找到最后一次交接的人
                                        select
                                            pr.*
                                        from
                                            (
                                                select
                                                    pr.pno
                                                    ,pr.staff_info_id
                                                    ,hsi.name as staff_name
                                                    ,pr.store_id
                                                    ,row_number() over(partition by pr.pno order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
                                                from my_staging.parcel_route pr
                                                left join my_bi.hr_staff_info hsi on pr.staff_info_id=hsi.staff_info_id
                                                left join my_bi.hr_job_title hjt on hjt.id = hsi.job_title
                                                where
                                                    pr.routed_at >= date_sub(curdate(), interval 8 hour)
                                                    and pr.routed_at < date_add(curdate(), interval 9 hour)
                                                    and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
                                                    and hsi.job_title in (13,110,1199)
                                                    and hsi.formal = 1
                                            ) pr
                                        where  pr.rnk = 1
                                    ) pr
                                join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day) and dp.store_category = 1
                                left join my_staging.parcel_info pi on pr.pno = pi.pno
                                left join # 17点前拨打电话次数
                                    (
                                        select
                                            pr.pno
                                            ,count(pr.call_datetime) as before_17_calltimes
                                        from
                                            (
                                                select
                                                        pr.pno
                                                        ,pr.staff_info_id
                                                        ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
                                                 from my_staging.parcel_route pr
                                                 where
                                                    pr.routed_at >= date_sub(curdate(), interval 8 hour)
                                                    and pr.routed_at < date_add(curdate(), interval 9 hour)
                                                    and pr.route_action in ('PHONE')
                                            )pr
                                        group by 1
                                    )pr2 on pr.pno = pr2.pno
                            )fn
                    ) fn
                group by 1,2,3,4,5,6
            ) f1
        where
            f1.hand_no_call_count > 10
            and f1.hand_no_call_ratio > 0.2
    ) f2
where
    f2.rk <= 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    now()
    ,td.*
    ,concat( round( ye. 员工当天妥投率*100,2),'%')  AS 员工当天妥投率
    ,concat( round( ye.`员工昨日妥投率`*100,2),'%') AS 员工昨日妥投率
    ,concat( round( ye.`员工前日妥投率`*100,2),'%') AS 员工前日妥投率
    ,concat( round( yp.`网点当天妥投率`*100,2),'%') AS 网点当天妥投率
    ,concat( round( yp.`网点昨日妥投率`*100,2),'%') AS 网点昨日妥投率
    ,concat( round( yp.`网点前日妥投率`*100,2),'%') AS 网点前日妥投率
FROM
    (
        select
            yg.`stat_date`  date
            ,yg.`staff_info_id` 员工工号
            ,yg.`staff_name` 员工姓名
            ,yg.`hire_days` 在职天数
            ,if(yg.`wait_leave_state` =0,'否'，'是')  是否待离职
            ,jt.`name`   岗位
            ,yg.`store_name`  网点名称
            ,yg.`region_name`  大区
            ,yg.`piece_name` 片区
            ,case
                when yg.`staff_attr` =1 then '自有'
                WHEN yg.`staff_attr` =2 then '支援'
                WHEN yg.`staff_attr` =3  then '外协'
            end as  员工类型
            ,if(yg.`is_sub_staff`=0,'否','是')  是否支援
            ,yg.`supply_store_name` 支援网点名称
            ,yg.`master_staff_info_id`  主账号
            ,yg.`master_store_name` 主账号网点
            ,smp.`name` 主账号片区
            ,smr.`name` 主账号大区
            ,ss.`name`  打卡网点名称
            ,yg.`started_store_id`
            ,yg.`attendance_started_at` 上班打卡时间
            ,yg.`attendance_end_at` 下班打卡时间
            ,tp.pickup_count  揽收任务量
            ,yg.`pickup_par_cnt` 揽收量
            ,yg.`pickup_big_par_cnt` 揽收大件量
            ,yg.`pickup_sma_par_cnt` 揽收小件量
            ,yg.`handover_par_cnt` 交接量
            ,yg.`handover_big_par_cnt` 交接大件量
            ,yg.`handover_sma_par_cnt` 交接小件量
            ,yg.`handover_cod_par_cnt` 交接cod包裹量
            ,yg.`handover_start_at` 交接开始时间
            ,yg.`handover_hour` 交接时长
            ,yg.`delivery_par_cnt` 妥投包裹量
            ,yg.`delivery_big_par_cnt`  妥投大件量
            ,yg.`delivery_sma_par_cnt` 妥投小件量
            ,yg.`delivery_cod_par_cnt` 妥投cod包裹量
            ,yg.`delivery_start_at`    妥投开始时间
            ,yg.`delivery_end_at2`     妥投结束时间
            ,yg.`delivery_hour2`       妥投时长
            ,yg.coordinate_distance    派送里程
            ,yg.`delivery_staff_cnt`   网点当天派件人数
            ,yg.`rank_delivery_in_store`  在网点派件排名
            ,yg.`mark_par_cnt`   当日派件标记数量
            ,yg.`mark_ret_par_cnt` 当日标记拒收包裹数量
            ,yg.`mark_mdf_par_cnt` 当日改约包裹数量
            ,yg.`mark_par_unen_cnt` 当日运力不足标记数量
            ,yg.`mark_par_uncon_cnt` 当日标记无人接听标记数量
        from dwm.dws_my_staff_wide_s yg
        LEFT JOIN
            (
                SELECT
                    tp.`staff_info_id`
                    ,COUNT(tp.`id`) pickup_count
                from `my_staging`.`ticket_pickup` tp
                where
                    tp.`created_at` >=convert_tz(current_date,'+08:00','+00:00')
                    and tp.`transfered` =0
                    and tp.`state` in (1,2)
                GROUP BY 1
            ) tp on tp.`staff_info_id` =yg.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` ss on ss.`id` =yg.`started_store_id`
        LEFT JOIN `my_staging`.`staff_info_job_title` jt on jt.id=yg.`job_title`
        LEFT JOIN `my_staging`.`sys_store` ss1 on ss1.`id` =yg.`master_store_id`
        LEFT JOIN `my_staging`.`sys_manage_region`  smr on smr.`id` =ss1.`manage_region`
        LEFT JOIN  `my_staging`.`sys_manage_piece`  smp on smp.`id` =ss1.`manage_piece`
        WHERE
            yg.`stat_date` = CURRENT_DATE
            and yg.`delivery_par_cnt` <80
            and (yg.`hire_days` >7 or yg.`staff_attr` in (2,3))
            and yg.`delivery_hour` <5
            and yg.`coordinate_distance` < 100
            and yg.`delivery_cod_par_cnt`< 60
            and tp.pickup_count < 10
    )td
LEFT JOIN
    (
        select stat_date
            ,staff_info_id
            ,delivery_par_cnt/handover_par_cnt as 员工当天妥投率
            ,lag1_delivery_par_cnt/lag1_handover_par_cnt as 员工昨日妥投率
            ,lag2_delivery_par_cnt/lag2_handover_par_cnt as 员工前日妥投率
        from
            (
                select
                    stat_date
                    ,staff_info_id
                    ,delivery_par_cnt
                    ,handover_par_cnt
                    ,lag(delivery_par_cnt,1) over(partition by staff_info_id order by stat_date) as lag1_delivery_par_cnt
                    ,lag(delivery_par_cnt,2) over(partition by staff_info_id order by stat_date) as lag2_delivery_par_cnt
                    ,lag(handover_par_cnt,1) over(partition by staff_info_id order by stat_date) as lag1_handover_par_cnt
                    ,lag(handover_par_cnt,2) over(partition by staff_info_id order by stat_date) as lag2_handover_par_cnt
                from  dwm.dws_my_staff_wide_s yg
                WHERE
                    yg.`stat_date`>=date_sub(CURRENT_DATE, INTERVAL 3 DAY)
             )base
        where
            stat_date=date_sub(CURRENT_DATE, INTERVAL 0 DAY)
            and  coalesce(delivery_par_cnt/handover_par_cnt,0)+coalesce(lag1_delivery_par_cnt/lag1_handover_par_cnt,0)+coalesce(lag2_delivery_par_cnt/lag2_handover_par_cnt,0)<2.7
    )ye on ye.staff_info_id=td.员工工号
join
    (
        select stat_date
            ,store_id
            ,store_name
            ,shl_delivery_delivery_par_cnt/shl_delivery_par_cnt as 网点当天妥投率
            ,shl1_delivery_delivery_par_cnt/shl1_delivery_par_cnt as 网点昨日妥投率
            ,shl2_delivery_delivery_par_cnt/shl2_delivery_par_cnt as 网点前日妥投率
        from
            (
                select
                    `stat_date`
                    ,`store_id`
                    ,`store_name`
                    ,`shl_delivery_delivery_par_cnt`
                    ,`shl_delivery_par_cnt`
                    ,lag(shl_delivery_delivery_par_cnt,1) over(partition by store_id order by stat_date) as shl1_delivery_delivery_par_cnt
                    ,lag(shl_delivery_delivery_par_cnt,2) over(partition by store_id order by stat_date) as shl2_delivery_delivery_par_cnt
                    ,lag(shl_delivery_par_cnt,1) over(partition by store_id  order by stat_date) as shl1_delivery_par_cnt
                    ,lag(shl_delivery_par_cnt,2) over(partition by store_id  order by stat_date) as shl2_delivery_par_cnt
                from  dwm.dws_my_store_should_delivery_s yp
                WHERE
                    yp.`stat_date`>=date_sub(CURRENT_DATE, INTERVAL 3 DAY)
            )base
            where
                stat_date=date_sub(CURRENT_DATE, INTERVAL 0 DAY)
                and  coalesce(shl_delivery_delivery_par_cnt/shl_delivery_par_cnt,0) +coalesce(shl1_delivery_delivery_par_cnt/shl1_delivery_par_cnt,0) +coalesce(shl2_delivery_delivery_par_cnt/shl2_delivery_par_cnt,0)<2.55
     ) yp on yp.`store_id`  =td.`started_store_id`;
;-- -. . -..- - / . -. - .-. -.--
SELECT
#     now()
#     ,td.*
#     ,concat( round( ye. 员工当天妥投率*100,2),'%')  AS 员工当天妥投率
#     ,concat( round( ye.`员工昨日妥投率`*100,2),'%') AS 员工昨日妥投率
#     ,concat( round( ye.`员工前日妥投率`*100,2),'%') AS 员工前日妥投率
#     ,concat( round( yp.`网点当天妥投率`*100,2),'%') AS 网点当天妥投率
#     ,concat( round( yp.`网点昨日妥投率`*100,2),'%') AS 网点昨日妥投率
#     ,concat( round( yp.`网点前日妥投率`*100,2),'%') AS 网点前日妥投率
    td.date
    ,td.员工工号
    ,td.交接量
    ,td.妥投包裹量
    ,td.揽收量
    ,td.揽收任务量
    ,td.妥投时长
    ,yp.shl_delivery_par_cnt 当日网点应派
    ,date_format(td.妥投开始时间, '%Y-%m-%d %H:%i:%s')  当日首次妥投时间
    ,round(timestampdiff(second, td.上班打卡时间, td.下班打卡时间)/3600, 2) 当日打卡时长
    ,'xx'violation_criteria
FROM
    (
        select
            yg.`stat_date`  date
            ,yg.`staff_info_id` 员工工号
            ,yg.`staff_name` 员工姓名
            ,yg.`hire_days` 在职天数
            ,if(yg.`wait_leave_state` =0,'否'，'是')  是否待离职
            ,jt.`name`   岗位
            ,yg.`store_name`  网点名称
            ,yg.`region_name`  大区
            ,yg.`piece_name` 片区
            ,case
                when yg.`staff_attr` =1 then '自有'
                WHEN yg.`staff_attr` =2 then '支援'
                WHEN yg.`staff_attr` =3  then '外协'
            end as  员工类型
            ,if(yg.`is_sub_staff`=0,'否','是')  是否支援
            ,yg.`supply_store_name` 支援网点名称
            ,yg.`master_staff_info_id`  主账号
            ,yg.`master_store_name` 主账号网点
            ,smp.`name` 主账号片区
            ,smr.`name` 主账号大区
            ,ss.`name`  打卡网点名称
            ,yg.`started_store_id`
            ,yg.`attendance_started_at` 上班打卡时间
            ,yg.`attendance_end_at` 下班打卡时间
            ,tp.pickup_count  揽收任务量
            ,yg.`pickup_par_cnt` 揽收量
            ,yg.`pickup_big_par_cnt` 揽收大件量
            ,yg.`pickup_sma_par_cnt` 揽收小件量
            ,yg.`handover_par_cnt` 交接量
            ,yg.`handover_big_par_cnt` 交接大件量
            ,yg.`handover_sma_par_cnt` 交接小件量
            ,yg.`handover_cod_par_cnt` 交接cod包裹量
            ,yg.`handover_start_at` 交接开始时间
            ,yg.`handover_hour` 交接时长
            ,yg.`delivery_par_cnt` 妥投包裹量
            ,yg.`delivery_big_par_cnt`  妥投大件量
            ,yg.`delivery_sma_par_cnt` 妥投小件量
            ,yg.`delivery_cod_par_cnt` 妥投cod包裹量
            ,yg.`delivery_start_at`    妥投开始时间
            ,yg.`delivery_end_at2`     妥投结束时间
            ,yg.`delivery_hour2`       妥投时长
            ,yg.coordinate_distance    派送里程
            ,yg.`delivery_staff_cnt`   网点当天派件人数
            ,yg.`rank_delivery_in_store`  在网点派件排名
            ,yg.`mark_par_cnt`   当日派件标记数量
            ,yg.`mark_ret_par_cnt` 当日标记拒收包裹数量
            ,yg.`mark_mdf_par_cnt` 当日改约包裹数量
            ,yg.`mark_par_unen_cnt` 当日运力不足标记数量
            ,yg.`mark_par_uncon_cnt` 当日标记无人接听标记数量

        from dwm.dws_my_staff_wide_s yg
        LEFT JOIN
            (
                SELECT
                    tp.`staff_info_id`
                    ,COUNT(tp.`id`) pickup_count
                from `my_staging`.`ticket_pickup` tp
                where
                    tp.`created_at` >=convert_tz(current_date,'+08:00','+00:00')
                    and tp.`transfered` =0
                    and tp.`state` in (1,2)
                GROUP BY 1
            ) tp on tp.`staff_info_id` =yg.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` ss on ss.`id` =yg.`started_store_id`
        LEFT JOIN `my_staging`.`staff_info_job_title` jt on jt.id=yg.`job_title`
        LEFT JOIN `my_staging`.`sys_store` ss1 on ss1.`id` =yg.`master_store_id`
        LEFT JOIN `my_staging`.`sys_manage_region`  smr on smr.`id` =ss1.`manage_region`
        LEFT JOIN  `my_staging`.`sys_manage_piece`  smp on smp.`id` =ss1.`manage_piece`
        WHERE
            yg.`stat_date` = CURRENT_DATE
            and yg.`delivery_par_cnt` <80
            and (yg.`hire_days` >7 or yg.`staff_attr` in (2,3))
            and yg.`delivery_hour` <5
            and yg.`coordinate_distance` < 100
            and yg.`delivery_cod_par_cnt`< 60
            and tp.pickup_count < 10
    )td
LEFT JOIN
    (
        select stat_date
            ,staff_info_id
            ,delivery_par_cnt/handover_par_cnt as 员工当天妥投率
            ,lag1_delivery_par_cnt/lag1_handover_par_cnt as 员工昨日妥投率
            ,lag2_delivery_par_cnt/lag2_handover_par_cnt as 员工前日妥投率
        from
            (
                select
                    stat_date
                    ,staff_info_id
                    ,delivery_par_cnt
                    ,handover_par_cnt
                    ,lag(delivery_par_cnt,1) over(partition by staff_info_id order by stat_date) as lag1_delivery_par_cnt
                    ,lag(delivery_par_cnt,2) over(partition by staff_info_id order by stat_date) as lag2_delivery_par_cnt
                    ,lag(handover_par_cnt,1) over(partition by staff_info_id order by stat_date) as lag1_handover_par_cnt
                    ,lag(handover_par_cnt,2) over(partition by staff_info_id order by stat_date) as lag2_handover_par_cnt
                from  dwm.dws_my_staff_wide_s yg
                WHERE
                    yg.`stat_date`>=date_sub(CURRENT_DATE, INTERVAL 3 DAY)
             )base
        where
            stat_date=date_sub(CURRENT_DATE, INTERVAL 0 DAY)
            and  coalesce(delivery_par_cnt/handover_par_cnt,0)+coalesce(lag1_delivery_par_cnt/lag1_handover_par_cnt,0)+coalesce(lag2_delivery_par_cnt/lag2_handover_par_cnt,0)<2.7
    )ye on ye.staff_info_id=td.员工工号
join
    (
        select stat_date
            ,store_id
            ,store_name
            ,shl_delivery_par_cnt
            ,shl_delivery_delivery_par_cnt/shl_delivery_par_cnt as 网点当天妥投率
            ,shl1_delivery_delivery_par_cnt/shl1_delivery_par_cnt as 网点昨日妥投率
            ,shl2_delivery_delivery_par_cnt/shl2_delivery_par_cnt as 网点前日妥投率
        from
            (
                select
                    `stat_date`
                    ,`store_id`
                    ,`store_name`
                    ,`shl_delivery_delivery_par_cnt`
                    ,`shl_delivery_par_cnt`
                    ,lag(shl_delivery_delivery_par_cnt,1) over(partition by store_id order by stat_date) as shl1_delivery_delivery_par_cnt
                    ,lag(shl_delivery_delivery_par_cnt,2) over(partition by store_id order by stat_date) as shl2_delivery_delivery_par_cnt
                    ,lag(shl_delivery_par_cnt,1) over(partition by store_id  order by stat_date) as shl1_delivery_par_cnt
                    ,lag(shl_delivery_par_cnt,2) over(partition by store_id  order by stat_date) as shl2_delivery_par_cnt
                from  dwm.dws_my_store_should_delivery_s yp
                WHERE
                    yp.`stat_date`>=date_sub(CURRENT_DATE, INTERVAL 3 DAY)
            )base
            where
                stat_date=date_sub(CURRENT_DATE, INTERVAL 0 DAY)
                and  coalesce(shl_delivery_delivery_par_cnt/shl_delivery_par_cnt,0) +coalesce(shl1_delivery_delivery_par_cnt/shl1_delivery_par_cnt,0) +coalesce(shl2_delivery_delivery_par_cnt/shl2_delivery_par_cnt,0)<2.55
     ) yp on yp.`store_id`  =td.`started_store_id`;
;-- -. . -..- - / . -. - .-. -.--
select
    ad.staff_info_id
    ,ad.stat_date
    ,concat(date_format(ad.stat_date, '%d/%m/%Y'),'[', ad.shift_start, '-', ad.shift_end']', date_format(ad.attendance_started_at, '%H:%i'), ' Lewat ', timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), ' minit' ) late_detail
    ,timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at)  late_minutes
from my_bi.attendance_data_v2 ad
join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
where
    ad.stat_date = curdate()
    and ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB > 0
    and ad.AB > 0
    and ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute );
;-- -. . -..- - / . -. - .-. -.--
select
    ad.staff_info_id
    ,ad.stat_date
    ,date_format(ad.stat_date, '%d/%m/%Y') p_date
    ,concat('[', ad.shift_start, '-', ad.shift_end']') banci
    ,timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at)  late_minutes
from my_bi.attendance_data_v2 ad
join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
where
    ad.stat_date = curdate()
    and ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB > 0
    and ad.AB > 0
    and ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute );
;-- -. . -..- - / . -. - .-. -.--
select
    ad.staff_info_id
    ,ad.stat_date
    ,concat(date_format(ad.stat_date, '%d/%m/%Y'),'[', ad.shift_start, '-', ad.shift_end, ']', date_format(ad.attendance_started_at, '%H:%i'), ' Lewat ', timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at), ' minit' ) late_detail
    ,timestampdiff(minute , concat(ad.stat_date, ' ', ad.shift_start), ad.attendance_started_at)  late_minutes
from my_bi.attendance_data_v2 ad
join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
where
    ad.stat_date = curdate()
    and ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB > 0
    and ad.AB > 0
    and ad.attendance_started_at > date_add(concat(ad.stat_date, ' ', ad.shift_start), interval 1 minute );
;-- -. . -..- - / . -. - .-. -.--
select
    ad.staff_info_id
    ,group_concat(ad.stat_date) absence_date
from my_bi.attendance_data_v2 ad
join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
where
    ad.stat_date <= date_sub(curdate(), interval 3 day)
    and ad.stat_date >= date_sub(curdate(), interval 7 day)
    and ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB > 0
    and ad.attendance_end_at  is null
    and ad.attendance_started_at is null;
;-- -. . -..- - / . -. - .-. -.--
select
    ad.staff_info_id
    ,group_concat(ad.stat_date) absence_date
from my_bi.attendance_data_v2 ad
join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
where
    ad.stat_date <= date_sub(curdate(), interval 3 day)
    and ad.stat_date >= date_sub(curdate(), interval 7 day)
    and ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB > 0
    and ad.attendance_end_at  is null
    and ad.attendance_started_at is null
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    ad.staff_info_id
    ,group_concat(ad.stat_date) absence_date
from my_bi.attendance_data_v2 ad
join my_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1199,37,16) -- 在职且非待离职
where
    ad.stat_date <= date_sub(curdate(), interval 3 day)
    and ad.stat_date >= date_sub(curdate(), interval 7 day)
    and ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB > 0
    and ad.attendance_end_at  is null
    and ad.attendance_started_at is null
    and ad.sys_store_id != -1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
SELECT DATE(NOW()) BETWEEN '2023-01-01' AND CURDATE();
;-- -. . -..- - / . -. - .-. -.--
SELECT DATE_ADD('2023-01-01', INTERVAL dummy DAY) AS date  
FROM (  
  SELECT dummy  
  FROM (  
    SELECT 0 AS dummy  
    UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4  
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8  
    UNION ALL SELECT 9  
  ) AS numbers  
  WHERE dummy <= DATEDIFF('2023-11-01', '2023-01-01')  
) AS dates;
;-- -. . -..- - / . -. - .-. -.--
SELECT DATE_ADD('2023-01-01', INTERVAL arn.n-1 DAY)
FROM (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11) arn
CROSS JOIN (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) arnr
ORDER BY arn.n;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.plt_date
    ,a1.plt_count 生成量
    ,a1.auto_no_duty_count 系统自动无责量
    ,a1.man_no_duty_count 人工无责量
    ,a1.man_duty_count QAQC判责量
    ,a2.plt_count 自动上报量
    ,a2.a_lost_duty_count 自动上报升级a来源判责丢失量
from
    (
        select
            date(plt.created_at) plt_date
            ,count(plt.id) plt_count
            ,count(if(plt.operator_id in (10000,10001) and plt.state = 5, plt.id, null)) auto_no_duty_count
            ,count(if(plt.operator_id not in (10000,10001) and plt.state = 5, plt.id, null)) man_no_duty_count
            ,count(if(plt.operator_id not in (10000,10001) and plt.state = 6 and plt.penalties > 0, plt.id, null)) man_duty_count
        from my_bi.parcel_lose_task plt
        where
            plt.created_at >= '2023-01-01'
            and plt.created_at < '2023-11-01'
            and plt.source = 3
        group by 1
    ) a1
left join
    (
        select
            date(plt.created_at) plt_date
            ,count(distinct plt.id) plt_count
            ,count(distinct if(plt.state = 6 and plt.penalties > 0 and plt.duty_result = 1, plt.id, null)) a_lost_duty_count
        from my_staging.parcel_route pr
        join my_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(pr.extra_value, '$.diffInfoId')
        join my_bi.parcel_lose_task plt on plt.source_id = cdt.id and plt.source = 1
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and pr.remark = 'SS Judge Auto Created For Overtime'
            and pr.routed_at > '2022-11-01'
            and plt.created_at >= '2023-01-01'
            and plt.created_at < '2023-11-01'
        group by 1
    ) a2 on a2.plt_date  = a1.plt_date;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.plt_date 日期
    ,a1.plt_count 生成量
    ,a1.auto_no_duty_count 系统自动无责量
    ,a1.man_no_duty_count 人工无责量
    ,a1.man_duty_count QAQC判责量
    ,a2.plt_count 自动上报量
    ,a2.a_lost_duty_count 自动上报升级a来源判责丢失量
from
    (
        select
            date(plt.created_at) plt_date
            ,count(plt.id) plt_count
            ,count(if(plt.operator_id in (10000,10001) and plt.state = 5, plt.id, null)) auto_no_duty_count
            ,count(if(plt.operator_id not in (10000,10001) and plt.state = 5, plt.id, null)) man_no_duty_count
            ,count(if(plt.operator_id not in (10000,10001) and plt.state = 6 and plt.penalties > 0, plt.id, null)) man_duty_count
        from my_bi.parcel_lose_task plt
        where
            plt.created_at >= '2023-01-01'
            and plt.created_at < '2023-11-01'
            and plt.source = 3
        group by 1
    ) a1
left join
    (
        select
            date(plt.created_at) plt_date
            ,count(distinct plt.id) plt_count
            ,count(distinct if(plt.state = 6 and plt.penalties > 0 and plt.duty_result = 1, plt.id, null)) a_lost_duty_count
        from my_staging.parcel_route pr
        join my_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(pr.extra_value, '$.diffInfoId')
        join my_bi.parcel_lose_task plt on plt.source_id = cdt.id and plt.source = 1
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and pr.remark = 'SS Judge Auto Created For Overtime'
            and pr.routed_at > '2022-11-01'
            and plt.created_at >= '2023-01-01'
            and plt.created_at < '2023-11-01'
        group by 1
    ) a2 on a2.plt_date  = a1.plt_date
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
from
    (SELECT
        smr.staff_info_id
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,smr.mileage_date 里程日期
        ,smr.url 视频链接
        ,(sm.`end_kilometres`-sm.`start_kilometres`)*0.001 里程数
    FROM `my_backyard`.`staff_mileage_record_attachment` smr
    LEFT JOIN `my_backyard`.`staff_mileage_record` sm on sm.`staff_info_id` =smr.staff_info_id and smr.mileage_date=sm.mileage_date
    LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =smr.`staff_info_id`
    LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
    LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
    LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
    where smr.type= 2
    -- 每月1日发上个月16-月末的数据；每月16日发1-15的数据
#     and smr.mileage_date>=if(extract(day from now())=1,date_add(date_sub(CURRENT_date,interval 1 month),interval 15 day),date_sub(CURRENT_date,interval 15 day))
#     and smr.mileage_date<CURRENT_date
    and smr.mileage_date >= '2023-11-01'
    and smr.mileage_date < '2023-12-01'
    and smr.url is not null
    ORDER BY smr.staff_info_id,smr.mileage_date
    )t where t.里程数>=200;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    ss.员工
    ,ss.网点名称
    ,ss.大区
    ,ss.片区
    ,ss.上上月日均里程数
    ,s.上月日均里程数
    ,ss.上上月日均妥投件数
    ,s.上月日均妥投件数
    ,st.网点人数变化幅度
    ,(s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数 人效变化幅度
    ,(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数 里程变化幅度
FROM
    (
    -- 上上月明细
    SELECT
        sm.员工
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id` 员工
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >='2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.员工
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id` 员工
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.员工=s.员工
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `my_backyard`.`staff_mileage_record` sm
            LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >='2023-10-01'
            and sm.`mileage_date` < '2023-11-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `my_backyard`.`staff_mileage_record` sm
            LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
                and sm.`mileage_date` < '2023-12-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
/*1. 快递员本月的日均里程和上月的日均里程做对比上涨超过30%；
2. 快递员的派件人效对比上月没有上涨超过20%；
3. 快递员所在网点的日均出勤van人数对比上月没有下降或下降不低于20%。
4. 当月里程>100公里*/
GROUP BY 1;
;-- -. . -..- - / . -. - .-. -.--
with staff as
(
SELECT
    ss.staff_info_id

FROM
    (
    -- 上上月明细
    SELECT
        sm.staff_info_id
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id`
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.staff_info_id
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id`
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.staff_info_id=s.staff_info_id
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `my_backyard`.`staff_mileage_record` sm
            LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-10-01'
            and sm.`mileage_date` <'2023-11-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `my_backyard`.`staff_mileage_record` sm
            LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
                and sm.`mileage_date` < '2023-12-01'
            and smr.`state` =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
GROUP BY 1
)
SELECT
    sm.mileage_date 日期
    ,sm.staff_info_id 快递员
    ,st.`name` 网点名称
    ,mr.`name` 大区
    ,mp.`name` 片区
    ,hjt.job_name 职位
    ,convert_tz(sm.started_at,'+00:00','+07:00') 上班汇报时间
    ,sm.start_kilometres/1000 里程表开始数据
    ,sm.end_kilometres/1000 里程表结束数据
    ,sm.end_kilometres/1000-sm.start_kilometres/1000 当日里程数
    ,sd.day_count 妥投件数
    ,sd.pickup_par_cnt 揽收件数

FROM `my_backyard`.`staff_mileage_record` sm
JOIN staff as s on sm.`staff_info_id`=s.`staff_info_id`
LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
left join my_bi.hr_job_title hjt on  hd.job_title=hjt.id
left join dwm.dwd_my_inp_opt_staff_info_d sd on sd.staff_info_id=sm.`staff_info_id` and sm.mileage_date=sd.stat_date
where smr.`state` =1
and sm.`mileage_date` >= '2023-11-01'
and sm.`mileage_date` < '2023-12-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT
        sm.员工
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id` 员工
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >='2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1;
;-- -. . -..- - / . -. - .-. -.--
SELECT
            sm.`staff_info_id` 员工
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >='2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
            sm.`staff_info_id` 员工
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >='2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1
        and st.`category` in (1,10);
;-- -. . -..- - / . -. - .-. -.--
SELECT
            sm.`staff_info_id` 员工
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >='2023-10-01'
        and sm.`mileage_date` < '2023-11-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT
            sm.`staff_info_id` 员工
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >='2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and smr.`state` =1;
;-- -. . -..- - / . -. - .-. -.--
SELECT
            sm.`staff_info_id` 员工
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >='2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and sm.card_status =1
        and st.`category` in (1,10)
        and hd.job_title in (110,1199)
        GROUP BY 1,2
        ORDER BY 1,2;
;-- -. . -..- - / . -. - .-. -.--
with staff as
(
SELECT
    ss.staff_info_id

FROM
    (
    -- 上上月明细
    SELECT
        sm.staff_info_id
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id`
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
       -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and sm.card_status =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.staff_info_id
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id`
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
       -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and sm.card_status =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.staff_info_id=s.staff_info_id
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `my_backyard`.`staff_mileage_record` sm
            -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-10-01'
            and sm.`mileage_date` <'2023-11-01'
            and sm.card_status =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `my_backyard`.`staff_mileage_record` sm
            -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
                and sm.`mileage_date` < '2023-12-01'
            and sm.card_status =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
GROUP BY 1
)
SELECT
    sm.mileage_date 日期
    ,sm.staff_info_id 快递员
    ,st.`name` 网点名称
    ,mr.`name` 大区
    ,mp.`name` 片区
    ,hjt.job_name 职位
    ,convert_tz(sm.started_at,'+00:00','+07:00') 上班汇报时间
    ,sm.start_kilometres/1000 里程表开始数据
    ,sm.end_kilometres/1000 里程表结束数据
    ,sm.end_kilometres/1000-sm.start_kilometres/1000 当日里程数
    ,sd.day_count 妥投件数
    ,sd.pickup_par_cnt 揽收件数

FROM `my_backyard`.`staff_mileage_record` sm
JOIN staff as s on sm.`staff_info_id`=s.`staff_info_id`
-- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
left join my_bi.hr_job_title hjt on  hd.job_title=hjt.id
left join dwm.dwd_my_inp_opt_staff_info_d sd on sd.staff_info_id=sm.`staff_info_id` and sm.mileage_date=sd.stat_date
where sm.card_status =1
and sm.`mileage_date` >= '2023-11-01'
and sm.`mileage_date` < '2023-12-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT
    ss.员工
    ,ss.网点名称
    ,ss.大区
    ,ss.片区
    ,ss.上上月日均里程数
    ,s.上月日均里程数
    ,ss.上上月日均妥投件数
    ,s.上月日均妥投件数
    ,st.网点人数变化幅度
    ,(s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数 人效变化幅度
    ,(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数 里程变化幅度
FROM
    (
    -- 上上月明细
    SELECT
        sm.员工
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id` 员工
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >='2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and sm.card_status =1
        and st.`category` in (1,10)
        and hd.job_title in (110,1199)
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.员工
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id` 员工
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
        -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and sm.card_status =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.员工=s.员工
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `my_backyard`.`staff_mileage_record` sm
           -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >='2023-10-01'
            and sm.`mileage_date` < '2023-11-01'
            and sm.card_status =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `my_backyard`.`staff_mileage_record` sm
            -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
                and sm.`mileage_date` < '2023-12-01'
            and sm.card_status =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
/*1. 快递员本月的日均里程和上月的日均里程做对比上涨超过30%；
2. 快递员的派件人效对比上月没有上涨超过20%；
3. 快递员所在网点的日均出勤van人数对比上月没有下降或下降不低于20%。
4. 当月里程>100公里*/
GROUP BY 1;
;-- -. . -..- - / . -. - .-. -.--
with staff as
(
SELECT
    ss.staff_info_id

FROM
    (
    -- 上上月明细
    SELECT
        sm.staff_info_id
        ,sm.网点名称
        ,sm.大区
        ,sm.片区
        ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上上月日均里程数
        ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上上月日均妥投件数
    from
        (
        SELECT
            sm.`staff_info_id`
            ,sm.mileage_date
            ,st.`name` 网点名称
            ,mr.`name` 大区
            ,mp.`name` 片区
            ,sm.money
            ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
            ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
       -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-10-01'
        and sm.`mileage_date` < '2023-11-01'
        and sm.card_status =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
        ) sm
    GROUP BY 1
    ) ss
LEFT JOIN
(
-- 上月明细
    SELECT sm.staff_info_id
    ,sm.网点名称
    ,sm.大区
    ,sm.片区
    ,sum(sm.里程数)*0.001/count(distinct(sm.mileage_date)) 上月日均里程数
    ,sum(sm.妥投件数)/count(distinct(sm.mileage_date)) 上月日均妥投件数
    from
    (
        SELECT sm.`staff_info_id`
        ,sm.mileage_date
        ,st.`name` 网点名称
        ,mr.`name` 大区
        ,mp.`name` 片区
        ,sm.money
        ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
        ,dc.`day_count` 妥投件数
        FROM `my_backyard`.`staff_mileage_record` sm
       -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
        LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
        LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
        LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
        LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
        LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
        WHERE sm.`mileage_date` >= '2023-11-01'
            and sm.`mileage_date` < '2023-12-01'
        and sm.card_status =1
        and st.`category` in (1,10)
        and hd.job_title='110'
        GROUP BY 1,2
        ORDER BY 1,2
    ) sm
GROUP BY 1
) s on ss.staff_info_id=s.staff_info_id
left JOIN
(
    SELECT
        ss.网点名称
        ,(s.上月日均员工数-ss.上上月日均员工数)/ss.上上月日均员工数 网点人数变化幅度
    FROM
        (
        SELECT sm.网点名称
        ,count(1)/count(distinct(sm.mileage_date)) 上上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `my_backyard`.`staff_mileage_record` sm
            -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-10-01'
            and sm.`mileage_date` <'2023-11-01'
            and sm.card_status =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
        ) ss
    LEFT JOIN
    (
        SELECT
            sm.网点名称
            ,count(1)/count(distinct(sm.mileage_date)) 上月日均员工数
        FROM
        (
            SELECT
                sm.`staff_info_id` 员工
                ,sm.mileage_date
                ,st.`name` 网点名称
                ,mr.`name` 大区
                ,mp.`name` 片区
                ,sm.money
                ,sm.`end_kilometres`-sm.`start_kilometres` 里程数
                ,dc.`day_count` 妥投件数
            FROM `my_backyard`.`staff_mileage_record` sm
            -- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
            LEFT JOIN `my_bi`.`hr_staff_info` hr on hr.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
            LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
            LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
            LEFT JOIN `my_bi`.`delivery_count_staff` dc on dc.`finished_at` =sm.`mileage_date` and dc.`staff_info_id` =sm.`staff_info_id`
            LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
            WHERE sm.`mileage_date` >= '2023-11-01'
                and sm.`mileage_date` < '2023-12-01'
            and sm.card_status =1
            and st.`category` in (1,10)
            and hd.job_title='110'
            GROUP BY 1,2
            ORDER BY 1,2
        ) sm
        GROUP BY 1
    ) s on ss.网点名称=s.网点名称
    GROUP BY 1
) st on st.网点名称=ss.网点名称
where
(s.上月日均里程数-ss.上上月日均里程数)/ss.上上月日均里程数>0.3
and (s.上月日均妥投件数-ss.上上月日均妥投件数)/ss.上上月日均妥投件数<0.2
and st.网点人数变化幅度>-0.2
and s.上月日均里程数>100
GROUP BY 1
)
SELECT
    sm.mileage_date 日期
    ,sm.staff_info_id 快递员
    ,st.`name` 网点名称
    ,mr.`name` 大区
    ,mp.`name` 片区
    ,hjt.job_name 职位
    ,convert_tz(sm.started_at,'+00:00','+07:00') 上班汇报时间
    ,sm.start_kilometres/1000 里程表开始数据
    ,sm.end_kilometres/1000 里程表结束数据
    ,sm.end_kilometres/1000-sm.start_kilometres/1000 当日里程数
    ,sd.delivery_par_cnt 妥投件数
    ,sd.pickup_par_cnt 揽收件数

FROM `my_backyard`.`staff_mileage_record` sm
JOIN staff as s on sm.`staff_info_id`=s.`staff_info_id`
-- LEFT JOIN `my_backyard`.`staff_mileage_record_prepaid` smr on smr.`prepaid_no` =sm.`prepaid_slip_no`
LEFT JOIN `my_staging`.`sys_store` st on sm.`store_id` =st.`id`
LEFT JOIN `my_staging`.`sys_manage_region` mr on mr.`id`=st.`manage_region`
LEFT JOIN `my_staging`.`sys_manage_piece` mp on mp.`id` =st.`manage_piece`
LEFT JOIN my_bi.hr_staff_transfer hd on hd.`staff_info_id` =sm.`staff_info_id` and hd.stat_date=sm.mileage_date
left join my_bi.hr_job_title hjt on  hd.job_title=hjt.id
left join dwm.dws_my_staff_wide_s sd on sd.staff_info_id=sm.`staff_info_id` and sm.mileage_date=sd.stat_date
where sm.card_status =1
and sm.`mileage_date` >= '2023-11-01'
and sm.`mileage_date` < '2023-12-01';
;-- -. . -..- - / . -. - .-. -.--
select
    hr.`staff_info_id`
    ,hr.`job_title`
    ,si.`name`
    ,case hr.`state`
        when 1 then '在职'
        when 2 then '离职'
    end as state
    ,hr.`hire_date` 入职日期
from  `my_bi`.`hr_staff_info`  hr
left join `my_staging`.`staff_info_job_title` si on si.`id` = hr.`job_title`
where
    hr.`staff_info_id` in
    (
 '120498','120641','123572','128678','129548','130869','131470','131729','133228','134258','136293','138520','139573','139618','139644','139678','139679','139689','139706','139720','139727','139763','139764','139766','139780','139787','139796','139814','139834','139863','139869','139872','139885','139901','139906','139910','139923','139940','139945','139984','140031','140041','140046','140049','140057','140078','140100','140106','140122','140128','140139','140146','140150','140163','140188','140198','140199','140201','140203','140239','140244','140245','140286','140305','140315','140319','140349','140358','140360','140363','140367','140376','140381','140386','140403','140411','140420','140435','140453','140458','140468','140473','140476','140478','140481','140487','140488','140489','140527','140530','140550','140554','140558','140567','140569','140587','140588','140595','140596','140604','140610','140611','140614','140618','140624','140634','140645','140671','140676','140688','140693','140694','140708','140733','140739','140744','140754','140764','140765','140773','140786','140803','140843','140852','140857','140864','140867','140873','140887','140891','140896','140903','140905','140937','140939','140943','140948','140963','140985','140994','140998','141023'
    );
;-- -. . -..- - / . -. - .-. -.--
select
hr.`staff_info_id`
,hr.`identity` 身份证
,hr.mobile 手机号
,hr.`company_name_ef` 外协公司
from  `my_bi`.`hr_staff_info`  hr
where hr.`staff_info_id` in
('348089','354342','355287','355293','375579','377316','378480','378685','383983','385021','385311','385687','394275','394434','395126','395302','395304','396072','396184','398420','398570','398828','398977','399030','399096','399103','399142','399143','399153','399201','399329','399403','400241','400332','400338','400375','400396','400423','400601','401203','401578','402038','402057','402235','402332','402337','402483','402526','402549','402832','402835','402882','403031','403074','403075','403080','403106','403260','403263','403388','403436','403450','403475','404149','404227','404481','404487','404741','404827','404858','404867','405434','405710','406270','406293','406296','406440','406484','406566','406580','406711','406750','406818','406906','406989','407102','407116','408186','408187','408216','408221','408237','408523','408524','408531','408568','409095','409101','409764','409849','410536','410537','410575','410650','410653','410736','410752','410767','410775','411011','411041','411042','411046','411054','411162','411181','412661','412704','412727','412733','412745','412758','412766','412772','412788','412877','412952','413055','413134','413135','413419','413444','413446','413588','413634','413661','413663','413914','414043','414207','414208','414273','414277','414305','414310','414324','414340','414486','414538','414630','414738','414968','415011','415676','415697','415726','417689');
;-- -. . -..- - / . -. - .-. -.--
select a.id,
date(a.date),
count( a.`pno` )
from
(
select distinct pi.`pno`, sw.ID ,date(sw.`date`) date
from tmpale.tmp_my_time_2023_12_05 sw
left join `my_staging`.`parcel_info`  pi
on pi.`ticket_delivery_staff_info_id` = sw.`id`
and convert_tz(pi.`finished_at`,'+00:00','+08:00') >=from_unixtime(sw.`ttime`)
and convert_tz(pi.`finished_at`,'+00:00','+08:00')<= date_add(sw.date,interval 1 day)
where pi.`state` =5
#and pi.`ticket_delivery_staff_info_id` ='3158683'
#and date(sw.`date` )='2022-12-03'
) a
#where a.id='3158683'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select a.id,
date(a.date),
count( a.`pno` )
from
(
select distinct pi.`pno`, sw.ID ,date(sw.`date`) date
from tmpale.tmp_my_time_2023_12_06 sw
left join `my_staging`.`parcel_info`  pi
on pi.`ticket_delivery_staff_info_id` = sw.`id`
and convert_tz(pi.`finished_at`,'+00:00','+08:00') >=from_unixtime(sw.`ttime`)
and convert_tz(pi.`finished_at`,'+00:00','+08:00')<= date_add(sw.date,interval 1 day)
where pi.`state` =5
#and pi.`ticket_delivery_staff_info_id` ='3158683'
#and date(sw.`date` )='2022-12-03'
) a
#where a.id='3158683'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select dayname(curdate());
;-- -. . -..- - / . -. - .-. -.--
select
    tdp.stat_date 日期
    ,dayname(tdp.stat_date) 星期
    ,count(tdp.id) Flash发送消息总数
    ,count(distinct if(tdp.status = 0, tdp.id, null)) 未发送数量
    ,count(distinct if(tdp.status = 1, tdp.id, null)) Flash已发送未收到回执数量
    ,count(distinct if(tdp.status = 2, tdp.id, null)) 发送失败数量
    ,count(distinct if(tdp.status = 3, tdp.id, null)) 未取到照片数量
    ,count(distinct if(tdp.status = 4, tdp.id, null)) 已送达未读数量
    ,count(distinct if(tdp.status = 5, tdp.id, null)) 已读未回复数量
    ,count(distinct if(tdp.status = 6, tdp.id, null)) 已回复数量
    ,count(distinct if(tdp.status = 7, tdp.id, null)) 超24小时未回复数量
    ,count(distinct if(tdp.reply_result = 1, tdp.id, null)) 收到包裹数量
    ,count(distinct if(tdp.reply_result = 2, tdp.id, null)) 未收到包裹数量
    ,count(distinct if(tdp.reply_result = 3, tdp.id, null)) 未经允许放在其它地方数量
    ,count(distinct if(tdp.complaint = 1, tdp.id, null)) 投诉快递员数量
    ,count(distinct if(tdp.status in (4,5,6,7), tdp.id, null))/count(tdp.id) 发送成功率
    ,count(distinct if(tdp.status in (5,6,7), tdp.id, null))/count(distinct if(tdp.status in (4,5,6,7), tdp.id, null)) 已读率
    ,count(distinct if(tdp.status in (6), tdp.id, null))/count(distinct if(tdp.status in (5,6,7), tdp.id, null)) 已读回复率
    ,count(distinct if(tdp.status in (4,5,6,7) and tdp.reply_result in (2,3), tdp.id, null))/count(distinct if(tdp.status in (4,5,6,7), tdp.id, null)) 虚假妥投率
    ,count(distinct if(tdp.status in (4,5,6,7) and tdp.complaint = 1, tdp.id, null))/count(distinct if(tdp.status in (4,5,6,7), tdp.id, null)) 投诉率
from my_nl.tiktok_delivered_parcel_whatsapp_msg tdp
where
    tdp.stat_date < curdate()
    and tdp.stat_date >= date_sub(curdate(), interval 7 day )
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.id
    ,replace(replace(t.img_url, '[', ''), ']', '')
from my_nl.tiktok_delivered_parcel_whatsapp_msg t
where
    t.id = 22719;
;-- -. . -..- - / . -. - .-. -.--
select
    tdp.stat_date 日期
    ,dayname(tdp.stat_date) 星期
    ,count(tdp.id) Flash发送消息总数
    ,count(distinct if(tdp.status = 0, tdp.id, null)) 未发送数量
    ,count(distinct if(tdp.status = 1, tdp.id, null)) Flash已发送未收到回执数量
    ,count(distinct if(tdp.status = 2, tdp.id, null)) 发送失败数量
    ,count(distinct if(tdp.status = 3, tdp.id, null)) 未取到照片数量
    ,count(distinct if(tdp.status = 4, tdp.id, null)) 已送达未读数量
    ,count(distinct if(tdp.status = 5, tdp.id, null)) 已读未回复数量
    ,count(distinct if(tdp.status = 6, tdp.id, null)) 已回复数量
    ,count(distinct if(tdp.status = 7, tdp.id, null)) 超24小时未回复数量
    ,count(distinct if(tdp.reply_result = 1, tdp.id, null)) 收到包裹数量
    ,count(distinct if(tdp.reply_result = 2, tdp.id, null)) 未收到包裹数量
    ,count(distinct if(tdp.reply_result = 3, tdp.id, null)) 未经允许放在其它地方数量
    ,count(distinct if(tdp.complaint = 1, tdp.id, null)) 投诉快递员数量
    ,count(distinct if(tdp.status in (4,5,6,7), tdp.id, null))/count(tdp.id) 发送成功率
    ,count(distinct if(tdp.status in (5,6,7), tdp.id, null))/count(distinct if(tdp.status in (4,5,6,7), tdp.id, null)) 已读率
    ,count(distinct if(tdp.status in (6), tdp.id, null))/count(distinct if(tdp.status in (5,6,7), tdp.id, null)) 已读回复率
    ,count(distinct if(tdp.status in (4,5,6,7) and tdp.reply_result in (2,3), tdp.id, null))/count(distinct if(tdp.status in (4,5,6,7), tdp.id, null)) 虚假妥投率
    ,count(distinct if(tdp.status in (4,5,6,7) and tdp.complaint = 1, tdp.id, null))/count(distinct if(tdp.status in (4,5,6,7), tdp.id, null)) 投诉率
from my_nl.tiktok_delivered_parcel_whatsapp_msg tdp
where
    tdp.stat_date < curdate()
    and tdp.stat_date >= date_sub(curdate(), interval 7 day )
group by 1,2
order by 1 desc;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.*
    ,a2.img_url 图片url
from
    (
        select
            t.id
            ,t.pno
            ,t.stat_date 日期
            ,dm.region_name 大区
            ,dm.store_name 网点名称
            ,t.store_id 网点ID
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.id is null then '普通ka'
                when kp.`id` is null then '小c'
            end 客户类型
            ,t.client_id 客户ID
            ,t.delivered_at 妥投日期
            ,case t.status
                when 0 then '未发送'
                when 1 then '已发送'
                when 2 then '发送失败'
                when 3 then '无需发送'
                when 4 then '已送达'
                when 5 then '已读'
                when 6 then '已回复'
                when 7 then '超24小时未回复'
            end 状态
            ,case t.complaint
                when 0 then 'no'
                when 1 then 'yes'
            end 是否投诉
            ,t.staff_info_id 快递员ID
            ,t.staff_info_name 快递员名称
            ,t.staff_info_phone 快递员手机号
            ,t.dst_phone 收件人手机号
            ,t.dst_name 收件人名称
            ,t.distance_to_store 妥投时距离网点距离
            ,t.send_at 发送消息时间
            ,t.msg_delivered_at 消息送达时间
            ,t.read_at 阅读时间
            ,t.reply_at 回复时间
            ,case t.reply_result
                when 0 then '未回复'
                when 1 then '包裹已收到'
                when 2 then '包裹未收到'
                when 3 then '未经允许包裹放在别处'
            end 回复结果
            ,t.reply_content 回复内容
            ,t.created_at 创建时间
            ,t.updated_at 更新时间
        from my_nl.tiktok_delivered_parcel_whatsapp_msg t
        left join dwm.dim_my_sys_store_rd dm on dm.store_id = t.store_id and dm.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t.client_id
        left join my_staging.ka_profile kp on kp.id = t.client_id
        where
            t.stat_date < curdate()
            and t.stat_date >= date_sub(curdate(), interval 7 day )
    ) a1
left join
    (
        select
            a2.id
            ,group_concat(a2.url) img_url
        from
            (
                select
                    a1.id
                    ,concat('https://', json_extract(a1.img, '$.name'), '.oss-ap-southeast-3.aliyuncs.com/', json_extract(a1.img, '$.key')) url
                from
                    (
                        select
                            a.*
                            ,concat('{',replace(replace(c, '{', ''), '}', ''), '}') img
                        from
                            (
                                select
                                    t.id
                                    ,replace(replace(t.img_url, '[', ''), ']', '') img_url
                                from my_nl.tiktok_delivered_parcel_whatsapp_msg t
                                where
                                    t.stat_date < curdate()
                                    and t.stat_date >= date_sub(curdate(), interval 7 day )
                            ) a
                        lateral view explode(split(a.img_url, '},{')) id as c
                    )a1
            ) a2
        group by 1
    ) a2 on a2.id = a1.id;
;-- -. . -..- - / . -. - .-. -.--
select
            a2.id
            ,group_concat(a2.url) img_url
        from
            (
                select
                    a1.id
                    ,concat('https://', json_extract(a1.img, '$.name'), '.oss-ap-southeast-3.aliyuncs.com/', json_extract(a1.img, '$.key')) url
                from
                    (
                        select
                            a.*
                            ,concat('{',replace(replace(c, '{', ''), '}', ''), '}') img
                        from
                            (
                                select
                                    t.id
                                    ,replace(replace(t.img_url, '[', ''), ']', '') img_url
                                from my_nl.tiktok_delivered_parcel_whatsapp_msg t
                                where
                                    t.stat_date < curdate()
                                    and t.stat_date >= date_sub(curdate(), interval 7 day )
                            ) a
                        lateral view explode(split(a.img_url, '},{')) id as c
                    )a1
            ) a2
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a1.plt_date 日期
    ,a1.plt_count 生成量
    ,a1.auto_no_duty_count 系统自动无责量
    ,a1.man_no_duty_count 人工无责量
    ,a1.man_duty_count QAQC判责量
    ,a1.have_hair_scan_no_num 上报有发无到量
    ,a2.plt_count 自动上报量
    ,a2.a_lost_duty_count 自动上报升级a来源判责丢失量
from
    (
        select
            date(plt.created_at) plt_date
            ,count(distinct plt.id) plt_count
            ,count(distinct if(plt.operator_id in (10000,10001) and plt.state = 5, plt.id, null)) auto_no_duty_count
            ,count(distinct if(plt.operator_id not in (10000,10001) and plt.state = 5, plt.id, null)) man_no_duty_count
            ,count(distinct if(plt.operator_id not in (10000,10001) and plt.state = 6 and plt.penalties > 0, plt.id, null)) man_duty_count
            ,count(distinct if(pr.pno is not null, plt.id, null)) have_hair_scan_no_num
        from my_bi.parcel_lose_task plt
        left join my_staging.parcel_route pr on pr.pno = plt.pno and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
        where
            plt.created_at >= '2023-11-01'
            and plt.created_at < '2023-12-01'
            and plt.source = 3
        group by 1
    ) a1
left join
    (
        select
            date(plt.created_at) plt_date
            ,count(distinct plt.id) plt_count
            ,count(distinct if(plt.state = 6 and plt.penalties > 0 and plt.duty_result = 1, plt.id, null)) a_lost_duty_count
        from my_staging.parcel_route pr
        join my_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(pr.extra_value, '$.diffInfoId')
        join my_bi.parcel_lose_task plt on plt.source_id = cdt.id and plt.source = 1
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and pr.remark = 'SS Judge Auto Created For Overtime'
            and pr.routed_at > '2022-10-01'
            and plt.created_at >= '2023-11-01'
            and plt.created_at < '2023-12-01'
        group by 1
    ) a2 on a2.plt_date  = a1.plt_date
order by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ds.pno
        ,ds.p_date
        ,ds.dst_store_id
    from dwm.dwd_my_dc_should_be_delivery ds
    where
        ds.p_date = curdate() -- 今日应派
        and ds.should_delevry_type != '非当日应派'
)
select
    t1.p_date
    ,t1.dst_store_id
    ,dm.store_name
    ,dm.piece_name
    ,dm.region_name
    ,t1.pno
    ,if(scan.pno is not null , '是', '否') 当日是否操作分拣扫描
    ,convert_tz(scan.routed_at, '+00:00', '+08:00') 当日第一次分拣扫描时间
    ,scan.staff_info_id 操作分拣扫描员工
    ,if(cf.pno is not null , '是', '否') 是否标记错分
    ,sort.third_sorting_code 第三段码
    ,convert_tz(del.routed_at, '+00:00', '+08:00') 当日第一次交接时间
from t t1
left join dwm.dim_my_sys_store_rd dm on dm.store_id = t1.dst_store_id and dm.stat_date = date_sub(curdate(), interval 1 day )
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at >= date_sub(curdate(), interval 8 hour)
            and pr.routed_at < date_add(curdate(), interval 16 hour)
            and pr.route_action = 'SORTING_SCAN'
    ) scan on scan.pno = t1.pno and scan.rk = 1
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at >= date_sub(curdate(), interval 8 hour)
            and pr.routed_at < date_add(curdate(), interval 16 hour)
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category = 31
        group by 1
    ) cf on cf.pno = t1.pno
left join
    (
        select
            ps.pno
            ,ps.third_sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc ) rn
        from my_drds_pro.parcel_sorting_code_info ps
        join t t1 on t1.pno = ps.pno and ps.dst_store_id = t1.dst_store_id
    ) sort on sort.pno = t1.pno and sort.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at >= date_sub(curdate(), interval 8 hour)
            and pr.routed_at < date_add(curdate(), interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    ) del on del.pno = t1.pno and del.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4
    )
select -- 分拨揽收丢失
    pi.pno
    ,'分拨揽收后丢失' type
from my_staging.parcel_info pi
join t t1 on t1.pno = pi.pno
left join my_staging.parcel_route pr on pr.pno = t.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
where
    pi.created_at > '2023-10-31'
    and pi.ticket_pickup_store_id = t1.last_valid_action
    and pi.ticket_pickup_store_id = t1.store_id
    and pr.pno is null
group by 1,2

union all

select
    t1.pno
   ,'分拨交接后丢失' type
from t t1
left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id
where
    t1.last_valid_store_id = t1.store_id
    and pr.pno is not null
group by 1,2

union all

select
    t1.pno
   ,'分拨到件入仓后丢失' type
from t t1
where
    t1.last_valid_store_id = t1.store_id
    and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
group by 1,2

union all

select -- 判给发件出仓网点
    t1.pno
    ,'分拨发件出仓后丢失' type
from t t1
left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id
where
    pr.pno is not null
group by 1,2

union all

select
    t1.pno
    ,'到港分拨后遗失' type
from t t1
left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN' and t1.store_id = pr.store_id
left join my_staging.parcel_route pr2 on pr2.pno = t1.pno and pr2.created_at > '2023-10-30'  and t1.store_id = pr2.store_id and pr2.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
where
    pr.pno is not null
    and pr2.pno is null
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4
    )
select -- 分拨揽收丢失
    pi.pno
    ,'分拨揽收后丢失' type
from my_staging.parcel_info pi
join t t1 on t1.pno = pi.pno
left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
where
    pi.created_at > '2023-10-31'
    and pi.ticket_pickup_store_id = t1.last_valid_action
    and pi.ticket_pickup_store_id = t1.store_id
    and pr.pno is null
group by 1,2

union all

select
    t1.pno
   ,'分拨交接后丢失' type
from t t1
left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id
where
    t1.last_valid_store_id = t1.store_id
    and pr.pno is not null
group by 1,2

union all

select
    t1.pno
   ,'分拨到件入仓后丢失' type
from t t1
where
    t1.last_valid_store_id = t1.store_id
    and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
group by 1,2

union all

select -- 判给发件出仓网点
    t1.pno
    ,'分拨发件出仓后丢失' type
from t t1
left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id
where
    pr.pno is not null
group by 1,2

union all

select
    t1.pno
    ,'到港分拨后遗失' type
from t t1
left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN' and t1.store_id = pr.store_id
left join my_staging.parcel_route pr2 on pr2.pno = t1.pno and pr2.created_at > '2023-10-30'  and t1.store_id = pr2.store_id and pr2.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
where
    pr.pno is not null
    and pr2.pno is null
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select -- 分拨揽收丢失
    pi.pno
    ,'分拨揽收后丢失' type
from my_staging.parcel_info pi
join t t1 on t1.pno = pi.pno
left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
where
    pi.created_at > '2023-10-31'
    and pi.ticket_pickup_store_id = t1.last_valid_action
    and pi.ticket_pickup_store_id = t1.store_id
    and pr.pno is null
group by 1,2

union all

select
    t1.pno
   ,'分拨交接后丢失' type
from t t1
left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
where
    t1.last_valid_store_id = t1.store_id
    and pr.pno is not null
group by 1,2

union all

select
    t1.pno
   ,'分拨到件入仓后丢失' type
from t t1
where
    t1.last_valid_store_id = t1.store_id
    and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
group by 1,2

union all

select -- 判给发件出仓网点
    t1.pno
    ,'分拨发件出仓后丢失' type
from t t1
left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
where
    pr.pno is not null
group by 1,2

union all

select
    t1.pno
    ,'到港分拨后遗失' type
from t t1
left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
left join my_staging.parcel_route pr2 on pr2.pno = t1.pno and pr2.created_at > '2023-10-30'  and t1.store_id = pr2.store_id and pr2.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
where
    pr.pno is not null
    and pr2.pno is null
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select
    t1.pno 运单号
    ,pi.client_id 客户ID
    ,oi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,case
        when 1st.pno is not null then 1st.type
        when 1st.pno is null and 2nd.pno is not null then 2nd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is not null then 3rd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is not null then 4th.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is null and 5th.pno is not null then 5th.type
        else 'other'
    end 环节
    ,if(pi.returned = 0, '正向', '逆向') '正向/逆向'
    ,if(pi.returned = 1, ss_custom.name, ss2.name) 正向揽收网点
    ,if(pi.returned = 1, ss2.name, null) 退件揽收网点
    ,ps1.store_name 上游网点
    ,ss4.name 最后有效路由网点
    ,ss3.name 判责网点
    ,ps1.van_in_line_name 车线名称
    ,ps1.van_arrived_at 车货到港时间
    ,if(pack.pno is null, '是', '否') 是否集包
    ,pack.seal_store_name 集包网点
    ,pack.es_unseal_store_name 应拆包网点
    ,pack.pack_no 集包号
    ,ps1.last_valid_route_action '车货到港后最后有效路由'
    ,ps1.last_valid_routed_at '车货到港后最后有效路由时间'
    ,if(scan_no.pno is null, '是', '否')  是否上报有发无到
    ,scan_no.store_name 上报有发无到网点
    ,scan_no.route_time  上报有发无到时间
    ,if(mac.pno is not null, '是', '否') 是否上分拣机
    ,5th.staff_info_id 最后交接员工id
from  t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-10-30'
left join my_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join my_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join my_staging.sys_store ss_custom on ss_custom.id = pi2.ticket_pickup_store_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss3 on ss3.id = t1.store_id
left join my_staging.sys_store ss4 on ss4.id = t1.last_valid_store_id
left join
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,ft.store_id
            ,ft.store_name
            ,pssn.van_in_line_name
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.van_arrived_at desc) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno
        left join my_bi.fleet_time ft on pssn.van_in_proof_id = ft.proof_id and pssn.store_id = ft.next_store_id and ft.arrive_type in (3,5)
        where
            pssn.van_arrived_at < t1.created_at
    ) ps1 on ps1.pno = t1.pno and ps1.rk = 1
left join
    (
        select
            t1.pno
            ,pi.seal_store_name
            ,pi.es_unseal_store_name
            ,pi.pack_no
            ,row_number() over (partition by t1.pno order by fvp.created_at desc) rk
        from my_staging.fleet_van_proof_parcel_detail fvp
        join t t1 on t1.pno = fvp.relation_no
        left join my_staging.pack_info pi on pi.pack_no = fvp.pack_no
        where
            fvp.relation_category = 1
            and fvp.created_at < date_sub(t1.created_at, interval 8 hour)
            and fvp.created_at > '2023-10-30'
    ) pack on pack.pno = t1.pno and pack.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
    ) scan_no on scan_no.pno = t1.pno and  scan_no.rk = 1
left join
    (
        select
            t1.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.staff_info_id = 136770
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
        group by 1
    ) mac on mac.pno = t1.pno
left join
    (
        select -- 分拨揽收丢失
            pi.pno
            ,'分拨揽收后丢失' type
        from my_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pi.created_at > '2023-10-31'
            and pi.ticket_pickup_store_id = t1.last_valid_action
            and pi.ticket_pickup_store_id = t1.store_id
            and pr.pno is null
        group by 1,2
    ) 1st on 1st.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'到港分拨后遗失' type
        from t t1
        left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = t1.store_id
        where
            pssn.van_arrived_at is not null
            and (pssn.first_valid_routed_at is null or pssn.first_valid_routed_at > date_sub(t1.created_at, interval  8 hour))
        group by 1,2
    ) 2nd on 2nd.pno = t1.pno
left join
    (
        select
            t1.pno
           ,'分拨到件入仓后丢失' type
        from t t1
        where
            t1.last_valid_store_id = t1.store_id
            and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
        group by 1,2
    ) 3rd on 3rd.pno = t1.pno
left join
    (
        select -- 判给发件出仓网点
            t1.pno
            ,'分拨发件出仓后丢失' type
        from t t1
        left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pr.pno is not null
        group by 1,2
    ) 4th on 4th.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'分拨交接后丢失' type
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from t t1
        join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            t1.last_valid_store_id = t1.store_id
            and pr.pno is not null
    ) 5th on 5th.pno = t1.pno  and 5th.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select
    t1.pno 运单号
    ,pi.client_id 客户ID
    ,oi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,case
        when 1st.pno is not null then 1st.type
        when 1st.pno is null and 2nd.pno is not null then 2nd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is not null then 3rd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is not null then 4th.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is null and 5th.pno is not null then 5th.type
        else 'other'
    end 环节
    ,if(pi.returned = 0, '正向', '逆向') '正向/逆向'
    ,if(pi.returned = 1, ss_custom.name, ss2.name) 正向揽收网点
    ,if(pi.returned = 1, ss2.name, null) 退件揽收网点
    ,ps1.store_name 上游网点
    ,ss4.name 最后有效路由网点
    ,ss3.name 判责网点
    ,ps1.van_in_line_name 车线名称
    ,ps1.van_arrived_at 车货到港时间
    ,if(pack.pno is null, '是', '否') 是否集包
    ,pack.seal_store_name 集包网点
    ,pack.es_unseal_store_name 应拆包网点
    ,pack.pack_no 集包号
    ,ps1.last_valid_route_action '车货到港后最后有效路由'
    ,ps1.last_valid_routed_at '车货到港后最后有效路由时间'
    ,if(scan_no.pno is null, '是', '否')  是否上报有发无到
    ,scan_no.store_name 上报有发无到网点
    ,scan_no.route_time  上报有发无到时间
    ,if(mac.pno is not null, '是', '否') 是否上分拣机
    ,5th.staff_info_id 最后交接员工id
from  t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-10-30'
left join my_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join my_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join my_staging.sys_store ss_custom on ss_custom.id = pi2.ticket_pickup_store_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss3 on ss3.id = t1.store_id
left join my_staging.sys_store ss4 on ss4.id = t1.last_valid_store_id
left join
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,ft.store_id
            ,ft.store_name
            ,pssn.van_in_line_name
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.van_arrived_at desc) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        left join my_bi.fleet_time ft on pssn.van_in_proof_id = ft.proof_id and pssn.store_id = ft.next_store_id and ft.arrive_type in (3,5)
        where
            pssn.van_arrived_at < t1.created_at
    ) ps1 on ps1.pno = t1.pno and ps1.rk = 1
left join
    (
        select
            t1.pno
            ,pi.seal_store_name
            ,pi.es_unseal_store_name
            ,pi.pack_no
            ,row_number() over (partition by t1.pno order by fvp.created_at desc) rk
        from my_staging.fleet_van_proof_parcel_detail fvp
        join t t1 on t1.pno = fvp.relation_no
        left join my_staging.pack_info pi on pi.pack_no = fvp.pack_no
        where
            fvp.relation_category = 1
            and fvp.created_at < date_sub(t1.created_at, interval 8 hour)
            and fvp.created_at > '2023-10-30'
    ) pack on pack.pno = t1.pno and pack.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
    ) scan_no on scan_no.pno = t1.pno and  scan_no.rk = 1
left join
    (
        select
            t1.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.staff_info_id = 136770
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
        group by 1
    ) mac on mac.pno = t1.pno
left join
    (
        select -- 分拨揽收丢失
            pi.pno
            ,'分拨揽收后丢失' type
        from my_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pi.created_at > '2023-10-31'
            and pi.ticket_pickup_store_id = t1.last_valid_action
            and pi.ticket_pickup_store_id = t1.store_id
            and pr.pno is null
        group by 1,2
    ) 1st on 1st.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'到港分拨后遗失' type
        from t t1
        left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = t1.store_id
        where
            pssn.van_arrived_at is not null
            and (pssn.first_valid_routed_at is null or pssn.first_valid_routed_at > date_sub(t1.created_at, interval  8 hour))
        group by 1,2
    ) 2nd on 2nd.pno = t1.pno
left join
    (
        select
            t1.pno
           ,'分拨到件入仓后丢失' type
        from t t1
        where
            t1.last_valid_store_id = t1.store_id
            and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
        group by 1,2
    ) 3rd on 3rd.pno = t1.pno
left join
    (
        select -- 判给发件出仓网点
            t1.pno
            ,'分拨发件出仓后丢失' type
        from t t1
        left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pr.pno is not null
        group by 1,2
    ) 4th on 4th.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'分拨交接后丢失' type
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from t t1
        join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            t1.last_valid_store_id = t1.store_id
            and pr.pno is not null
    ) 5th on 5th.pno = t1.pno  and 5th.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select
    t1.pno 运单号
    ,pi.client_id 客户ID
    ,oi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,case
        when 1st.pno is not null then 1st.type
        when 1st.pno is null and 2nd.pno is not null then 2nd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is not null then 3rd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is not null then 4th.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is null and 5th.pno is not null then 5th.type
        else 'other'
    end 环节
    ,if(pi.returned = 0, '正向', '逆向') '正向/逆向'
    ,if(pi.returned = 1, ss_custom.name, ss2.name) 正向揽收网点
    ,if(pi.returned = 1, ss2.name, null) 退件揽收网点
    ,ps1.store_name 上游网点
    ,ss4.name 最后有效路由网点
    ,ss3.name 判责网点
    ,ps1.van_in_line_name 车线名称
    ,ps1.van_arrived_at 车货到港时间
    ,if(pack.pno is null, '是', '否') 是否集包
    ,pack.seal_store_name 集包网点
    ,pack.es_unseal_store_name 应拆包网点
    ,pack.pack_no 集包号
    ,ps1.last_valid_route_action '车货到港后最后有效路由'
    ,ps1.last_valid_routed_at '车货到港后最后有效路由时间'
    ,if(scan_no.pno is not null, '是', '否')  是否上报有发无到
    ,scan_no.store_name 上报有发无到网点
    ,scan_no.route_time  上报有发无到时间
    ,if(mac.pno is not null, '是', '否') 是否上分拣机
    ,5th.staff_info_id 最后交接员工id
from  t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-10-30'
left join my_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join my_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join my_staging.sys_store ss_custom on ss_custom.id = pi2.ticket_pickup_store_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss3 on ss3.id = t1.store_id
left join my_staging.sys_store ss4 on ss4.id = t1.last_valid_store_id
left join
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,ft.store_id
            ,ft.store_name
            ,pssn.van_in_line_name
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.van_arrived_at desc) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        left join my_bi.fleet_time ft on pssn.van_in_proof_id = ft.proof_id and pssn.store_id = ft.next_store_id and ft.arrive_type in (3,5)
        where
            pssn.van_arrived_at < t1.created_at
    ) ps1 on ps1.pno = t1.pno and ps1.rk = 1
left join
    (
        select
            t1.pno
            ,pi.seal_store_name
            ,pi.es_unseal_store_name
            ,pi.pack_no
            ,row_number() over (partition by t1.pno order by fvp.created_at desc) rk
        from my_staging.fleet_van_proof_parcel_detail fvp
        join t t1 on t1.pno = fvp.relation_no
        left join my_staging.pack_info pi on pi.pack_no = fvp.pack_no
        where
            fvp.relation_category = 1
            and fvp.created_at < date_sub(t1.created_at, interval 8 hour)
            and fvp.created_at > '2023-10-30'
    ) pack on pack.pno = t1.pno and pack.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
    ) scan_no on scan_no.pno = t1.pno and  scan_no.rk = 1
left join
    (
        select
            t1.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.staff_info_id = 136770
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
        group by 1
    ) mac on mac.pno = t1.pno
left join
    (
        select -- 分拨揽收丢失
            pi.pno
            ,'分拨揽收后丢失' type
        from my_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pi.created_at > '2023-10-31'
            and pi.ticket_pickup_store_id = t1.last_valid_action
            and pi.ticket_pickup_store_id = t1.store_id
            and pr.pno is null
        group by 1,2
    ) 1st on 1st.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'到港分拨后遗失' type
        from t t1
        left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = t1.store_id
        where
            pssn.van_arrived_at is not null
            and (pssn.first_valid_routed_at is null or pssn.first_valid_routed_at > date_sub(t1.created_at, interval  8 hour))
        group by 1,2
    ) 2nd on 2nd.pno = t1.pno
left join
    (
        select
            t1.pno
           ,'分拨到件入仓后丢失' type
        from t t1
        where
            t1.last_valid_store_id = t1.store_id
            and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
        group by 1,2
    ) 3rd on 3rd.pno = t1.pno
left join
    (
        select -- 判给发件出仓网点
            t1.pno
            ,'分拨发件出仓后丢失' type
        from t t1
        left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pr.pno is not null
        group by 1,2
    ) 4th on 4th.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'分拨交接后丢失' type
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from t t1
        join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            t1.last_valid_store_id = t1.store_id
            and pr.pno is not null
    ) 5th on 5th.pno = t1.pno  and 5th.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select
    t1.pno 运单号
    ,pi.client_id 客户ID
    ,oi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,case
        when 1st.pno is not null then 1st.type
        when 1st.pno is null and 2nd.pno is not null then 2nd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is not null then 3rd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is not null then 4th.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is null and 5th.pno is not null then 5th.type
        else 'other'
    end 环节
    ,if(pi.returned = 0, '正向', '逆向') '正向/逆向'
    ,if(pi.returned = 1, ss_custom.name, ss2.name) 正向揽收网点
    ,if(pi.returned = 1, ss2.name, null) 退件揽收网点
    ,ps1.store_name 上游网点
    ,ss4.name 最后有效路由网点
    ,ss3.name 判责网点
    ,ps1.van_in_line_name 车线名称
    ,ps1.van_arrived_at 车货到港时间
    ,if(pack.pno is null, '是', '否') 是否集包
    ,pack.seal_store_name 集包网点
    ,pack.es_unseal_store_name 应拆包网点
    ,pack.pack_no 集包号
    ,ps1.last_valid_route_action '车货到港后最后有效路由'
    ,ps1.last_valid_routed_at '车货到港后最后有效路由时间'
    ,if(scan_no.pno is not null, '是', '否')  是否上报有发无到
    ,scan_no.store_name 上报有发无到网点
    ,scan_no.route_time  上报有发无到时间
    ,if(mac.pno is not null, '是', '否') 是否上分拣机
    ,5th.staff_info_id 最后交接员工id
from  t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-10-30'
left join my_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join my_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join my_staging.sys_store ss_custom on ss_custom.id = pi2.ticket_pickup_store_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss3 on ss3.id = t1.store_id
left join my_staging.sys_store ss4 on ss4.id = t1.last_valid_store_id
left join
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,ft.store_id
            ,ft.store_name
            ,pssn.van_in_line_name
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.van_arrived_at desc) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        left join my_bi.fleet_time ft on pssn.van_in_proof_id = ft.proof_id and pssn.store_id = ft.next_store_id and ft.arrive_type in (3,5)
        where
            pssn.van_arrived_at < t1.created_at
    ) ps1 on ps1.pno = t1.pno and ps1.rk = 1
left join
    (
        select
            t1.pno
            ,pi.seal_store_name
            ,pi.es_unseal_store_name
            ,pi.pack_no
            ,row_number() over (partition by t1.pno order by fvp.created_at desc) rk
        from my_staging.fleet_van_proof_parcel_detail fvp
        join t t1 on t1.pno = fvp.relation_no
        left join my_staging.pack_info pi on pi.pack_no = fvp.pack_no
        where
            fvp.relation_category = 1
            and fvp.created_at < date_sub(t1.created_at, interval 8 hour)
            and fvp.created_at > '2023-10-30'
    ) pack on pack.pno = t1.pno and pack.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
    ) scan_no on scan_no.pno = t1.pno and  scan_no.rk = 1
left join
    (
        select
            t1.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.staff_info_id = 136770
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
        group by 1
    ) mac on mac.pno = t1.pno
left join
    (
        select -- 分拨揽收丢失
            pi.pno
            ,'分拨揽收后丢失' type
        from my_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pi.created_at > '2023-10-31'
            and pi.ticket_pickup_store_id = t1.last_valid_store_id
            and pi.ticket_pickup_store_id = t1.store_id
            and pr.pno is null
        group by 1,2
    ) 1st on 1st.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'到港分拨后遗失' type
        from t t1
        left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = t1.store_id
        where
            pssn.van_arrived_at is not null
            and (pssn.first_valid_routed_at is null or pssn.first_valid_routed_at > date_sub(t1.created_at, interval  8 hour))
        group by 1,2
    ) 2nd on 2nd.pno = t1.pno
left join
    (
        select
            t1.pno
           ,'分拨到件入仓后丢失' type
        from t t1
        where
            t1.last_valid_store_id = t1.store_id
            and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
        group by 1,2
    ) 3rd on 3rd.pno = t1.pno
left join
    (
        select -- 判给发件出仓网点
            t1.pno
            ,'分拨发件出仓后丢失' type
        from t t1
        left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pr.pno is not null
        group by 1,2
    ) 4th on 4th.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'分拨交接后丢失' type
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from t t1
        join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            t1.last_valid_store_id = t1.store_id
            and pr.pno is not null
    ) 5th on 5th.pno = t1.pno  and 5th.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select
    t1.pno 运单号
    ,pi.client_id 客户ID
    ,oi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,case
        when 1st.pno is not null then 1st.type
        when 1st.pno is null and 2nd.pno is not null then 2nd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is not null then 3rd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is not null then 4th.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is null and 5th.pno is not null then 5th.type
        else 'other'
    end 环节
    ,if(pi.returned = 0, '正向', '逆向') '正向/逆向'
    ,if(pi.returned = 1, ss_custom.name, ss2.name) 正向揽收网点
    ,if(pi.returned = 1, ss2.name, null) 退件揽收网点
    ,ps1.store_name 上游网点
    ,ss4.name 最后有效路由网点
    ,ss3.name 判责网点
    ,ps1.van_in_line_name 车线名称
    ,ps1.van_arrived_at 车货到港时间
    ,if(pack.pno is not null, '是', '否') 是否集包
    ,pack.seal_store_name 集包网点
    ,pack.es_unseal_store_name 应拆包网点
    ,pack.pack_no 集包号
    ,ps1.last_valid_route_action '车货到港后最后有效路由'
    ,ps1.last_valid_routed_at '车货到港后最后有效路由时间'
    ,if(scan_no.pno is not null, '是', '否')  是否上报有发无到
    ,scan_no.store_name 上报有发无到网点
    ,scan_no.route_time  上报有发无到时间
    ,if(mac.pno is not null, '是', '否') 是否上分拣机
    ,5th.staff_info_id 最后交接员工id
from  t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-10-30'
left join my_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join my_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join my_staging.sys_store ss_custom on ss_custom.id = pi2.ticket_pickup_store_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss3 on ss3.id = t1.store_id
left join my_staging.sys_store ss4 on ss4.id = t1.last_valid_store_id
left join
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,ft.store_id
            ,ft.store_name
            ,pssn.van_in_line_name
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.van_arrived_at desc) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        left join my_bi.fleet_time ft on pssn.van_in_proof_id = ft.proof_id and pssn.store_id = ft.next_store_id and ft.arrive_type in (3,5)
        where
            pssn.van_arrived_at < t1.created_at
    ) ps1 on ps1.pno = t1.pno and ps1.rk = 1
left join
    (
        select
            t1.pno
            ,pi.seal_store_name
            ,pi.es_unseal_store_name
            ,pi.pack_no
            ,row_number() over (partition by t1.pno order by fvp.created_at desc) rk
        from my_staging.fleet_van_proof_parcel_detail fvp
        join t t1 on t1.pno = fvp.relation_no
        left join my_staging.pack_info pi on pi.pack_no = fvp.pack_no
        where
            fvp.relation_category = 3
            and fvp.created_at < date_sub(t1.created_at, interval 8 hour)
            and fvp.created_at > '2023-10-30'
    ) pack on pack.pno = t1.pno and pack.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
    ) scan_no on scan_no.pno = t1.pno and  scan_no.rk = 1
left join
    (
        select
            t1.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.staff_info_id = 136770
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
        group by 1
    ) mac on mac.pno = t1.pno
left join
    (
        select -- 分拨揽收丢失
            pi.pno
            ,'分拨揽收后丢失' type
        from my_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pi.created_at > '2023-10-31'
            and pi.ticket_pickup_store_id = t1.last_valid_store_id
            and pi.ticket_pickup_store_id = t1.store_id
            and pr.pno is null
        group by 1,2
    ) 1st on 1st.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'到港分拨后遗失' type
        from t t1
        left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = t1.store_id
        where
            pssn.van_arrived_at is not null
            and (pssn.first_valid_routed_at is null or pssn.first_valid_routed_at > date_sub(t1.created_at, interval  8 hour))
        group by 1,2
    ) 2nd on 2nd.pno = t1.pno
left join
    (
        select
            t1.pno
           ,'分拨到件入仓后丢失' type
        from t t1
        where
            t1.last_valid_store_id = t1.store_id
            and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
        group by 1,2
    ) 3rd on 3rd.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'分拨交接后丢失' type
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from t t1
        join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            t1.last_valid_store_id = t1.store_id
            and pr.pno is not null
    ) 4th on 4th.pno = t1.pno
left join
    (
        select -- 判给发件出仓网点
            t1.pno
            ,'分拨发件出仓后丢失' type
        from t t1
        left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pr.pno is not null
        group by 1,2
    ) 5th on 5th.pno = t1.pno  and 5th.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select
    t1.pno 运单号
    ,pi.client_id 客户ID
    ,oi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,case
        when 1st.pno is not null then 1st.type
        when 1st.pno is null and 2nd.pno is not null then 2nd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is not null then 3rd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is not null then 4th.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is null and 5th.pno is not null then 5th.type
        else 'other'
    end 环节
    ,if(pi.returned = 0, '正向', '逆向') '正向/逆向'
    ,if(pi.returned = 1, ss_custom.name, ss2.name) 正向揽收网点
    ,if(pi.returned = 1, ss2.name, null) 退件揽收网点
    ,ps1.store_name 上游网点
    ,ss4.name 最后有效路由网点
    ,ss3.name 判责网点
    ,ps1.van_in_line_name 车线名称
    ,ps1.van_arrived_at 车货到港时间
    ,if(pack.pno is not null, '是', '否') 是否集包
    ,pack.seal_store_name 集包网点
    ,pack.es_unseal_store_name 应拆包网点
    ,pack.pack_no 集包号
    ,ps1.last_valid_route_action '车货到港后最后有效路由'
    ,ps1.last_valid_routed_at '车货到港后最后有效路由时间'
    ,if(scan_no.pno is not null, '是', '否')  是否上报有发无到
    ,scan_no.store_name 上报有发无到网点
    ,scan_no.route_time  上报有发无到时间
    ,if(mac.pno is not null, '是', '否') 是否上分拣机
    ,5th.staff_info_id 最后交接员工id
from  t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-10-30'
left join my_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join my_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join my_staging.sys_store ss_custom on ss_custom.id = pi2.ticket_pickup_store_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss3 on ss3.id = t1.store_id
left join my_staging.sys_store ss4 on ss4.id = t1.last_valid_store_id
left join
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,ft.store_id
            ,ft.store_name
            ,pssn.van_in_line_name
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.van_arrived_at desc) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        left join my_bi.fleet_time ft on pssn.van_in_proof_id = ft.proof_id and pssn.store_id = ft.next_store_id and ft.arrive_type in (3,5)
        where
            pssn.van_arrived_at < t1.created_at
    ) ps1 on ps1.pno = t1.pno and ps1.rk = 1
left join
    (
        select
            t1.pno
            ,pi.seal_store_name
            ,pi.es_unseal_store_name
            ,pi.pack_no
            ,row_number() over (partition by t1.pno order by fvp.created_at desc) rk
        from my_staging.fleet_van_proof_parcel_detail fvp
        join t t1 on t1.pno = fvp.relation_no
        left join my_staging.pack_info pi on pi.pack_no = fvp.pack_no
        where
            fvp.relation_category = 3
            and fvp.created_at < date_sub(t1.created_at, interval 8 hour)
            and fvp.created_at > '2023-10-30'
    ) pack on pack.pno = t1.pno and pack.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
    ) scan_no on scan_no.pno = t1.pno and  scan_no.rk = 1
left join
    (
        select
            t1.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.staff_info_id = 136770
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
        group by 1
    ) mac on mac.pno = t1.pno
left join
    (
        select -- 分拨揽收丢失
            pi.pno
            ,'分拨揽收后丢失' type
        from my_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pi.created_at > '2023-10-31'
            and pi.ticket_pickup_store_id = t1.last_valid_store_id
            and pi.ticket_pickup_store_id = t1.store_id
            and pr.pno is null
        group by 1,2
    ) 1st on 1st.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'到港分拨后遗失' type
        from t t1
        left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = t1.store_id
        where
            pssn.van_arrived_at is not null
            and (pssn.first_valid_routed_at is null or pssn.first_valid_routed_at > date_sub(t1.created_at, interval  8 hour))
        group by 1,2
    ) 2nd on 2nd.pno = t1.pno
left join
    (
        select
            t1.pno
           ,'分拨到件入仓后丢失' type
        from t t1
        where
            t1.last_valid_store_id = t1.store_id
            and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
        group by 1,2
    ) 3rd on 3rd.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'分拨交接后丢失' type
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from t t1
        join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            t1.last_valid_store_id = t1.store_id
            and pr.pno is not null
    ) 4th on 4th.pno = t1.pno and 4th.rk = 1
left join
    (
        select -- 判给发件出仓网点
            t1.pno
            ,'分拨发件出仓后丢失' type
        from t t1
        left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pr.pno is not null
        group by 1,2
    ) 5th on 5th.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select
    t1.pno 运单号
    ,pi.client_id 客户ID
    ,oi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,case
        when 1st.pno is not null then 1st.type
        when 1st.pno is null and 2nd.pno is not null then 2nd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is not null then 3rd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is not null then 4th.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is null and 5th.pno is not null then 5th.type
        else 'other'
    end 环节
    ,if(pi.returned = 0, '正向', '逆向') '正向/逆向'
    ,if(pi.returned = 1, ss_custom.name, ss2.name) 正向揽收网点
    ,if(pi.returned = 1, ss2.name, null) 退件揽收网点
    ,ps1.store_name 上游网点
    ,ss4.name 最后有效路由网点
    ,ss3.name 判责网点
    ,ps1.van_in_line_name 车线名称
    ,ps1.van_arrived_at 车货到港时间
    ,if(pack.pno is not null, '是', '否') 是否集包
    ,pack.seal_store_name 集包网点
    ,pack.es_unseal_store_name 应拆包网点
    ,pack.pack_no 集包号
    ,ps1.last_valid_route_action '车货到港后最后有效路由'
    ,ps1.last_valid_routed_at '车货到港后最后有效路由时间'
    ,if(scan_no.pno is not null, '是', '否')  是否上报有发无到
    ,scan_no.store_name 上报有发无到网点
    ,scan_no.route_time  上报有发无到时间
    ,if(mac.pno is not null, '是', '否') 是否上分拣机
    ,4th.staff_info_id 最后交接员工id
from  t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-10-30'
left join my_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join my_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join my_staging.sys_store ss_custom on ss_custom.id = pi2.ticket_pickup_store_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss3 on ss3.id = t1.store_id
left join my_staging.sys_store ss4 on ss4.id = t1.last_valid_store_id
left join
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,ft.store_id
            ,ft.store_name
            ,pssn.van_in_line_name
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.van_arrived_at desc) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        left join my_bi.fleet_time ft on pssn.van_in_proof_id = ft.proof_id and pssn.store_id = ft.next_store_id and ft.arrive_type in (3,5)
        where
            pssn.van_arrived_at < t1.created_at
    ) ps1 on ps1.pno = t1.pno and ps1.rk = 1
left join
    (
        select
            t1.pno
            ,pi.seal_store_name
            ,pi.es_unseal_store_name
            ,pi.pack_no
            ,row_number() over (partition by t1.pno order by fvp.created_at desc) rk
        from my_staging.fleet_van_proof_parcel_detail fvp
        join t t1 on t1.pno = fvp.relation_no
        left join my_staging.pack_info pi on pi.pack_no = fvp.pack_no
        where
            fvp.relation_category = 3
            and fvp.created_at < date_sub(t1.created_at, interval 8 hour)
            and fvp.created_at > '2023-10-30'
    ) pack on pack.pno = t1.pno and pack.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
    ) scan_no on scan_no.pno = t1.pno and  scan_no.rk = 1
left join
    (
        select
            t1.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.staff_info_id = 136770
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
        group by 1
    ) mac on mac.pno = t1.pno
left join
    (
        select -- 分拨揽收丢失
            pi.pno
            ,'分拨揽收后丢失' type
        from my_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pi.created_at > '2023-10-31'
            and pi.ticket_pickup_store_id = t1.last_valid_store_id
            and pi.ticket_pickup_store_id = t1.store_id
            and pr.pno is null
        group by 1,2
    ) 1st on 1st.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'到港分拨后遗失' type
        from t t1
        left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = t1.store_id
        where
            pssn.van_arrived_at is not null
            and (pssn.first_valid_routed_at is null or pssn.first_valid_routed_at > date_sub(t1.created_at, interval  8 hour))
        group by 1,2
    ) 2nd on 2nd.pno = t1.pno
left join
    (
        select
            t1.pno
           ,'分拨到件入仓后丢失' type
        from t t1
        where
            t1.last_valid_store_id = t1.store_id
            and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
        group by 1,2
    ) 3rd on 3rd.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'分拨交接后丢失' type
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from t t1
        join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            t1.last_valid_store_id = t1.store_id
            and pr.pno is not null
    ) 4th on 4th.pno = t1.pno and 4th.rk = 1
left join
    (
        select -- 判给发件出仓网点
            t1.pno
            ,'分拨发件出仓后丢失' type
        from t t1
        left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pr.pno is not null
        group by 1,2
    ) 5th on 5th.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 < 24 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-24'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 < 36 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-36'
    ,count(if(timestampdiff(second, acc.created_at, acc.store_callback_at)/3600 < 48 and acc.store_callback_expired = 0, acc.id, null)) '任务生成时间-道歉时间-48'
    ,count(if(timestampdiff(second, am.created_at, acc.store_callback_at)/3600 < 24 and acc.store_callback_expired = 0, acc.id, null)) '任务发放时间-道歉时间-24'
    ,count(if(timestampdiff(second, am.created_at, acc.store_callback_at)/3600 < 36 and acc.store_callback_expired = 0, acc.id, null)) '任务发放时间-道歉时间-36'
    ,count(if(timestampdiff(second, am.created_at, acc.store_callback_at)/3600 < 48 and acc.store_callback_expired = 0, acc.id, null)) '任务发放时间-道歉时间-48'
    ,count(distinct acc.id) 投诉量
    ,count(if(acc.store_callback_expired = 0 and acc.store_callback_at is not null, acc.id, null)) 有道歉量
    ,count(if(acc.store_callback_expired != 0 or  acc.store_callback_at is null, acc.id, null)) 无道歉量
from my_bi.abnormal_customer_complaint acc
left join my_bi.abnormal_message am on am.id = acc.abnormal_message_id
where
    acc.complaints_type = 1
    and acc.created_at >= '2023-09-01'
    and acc.created_at < '2023-10-01';
;-- -. . -..- - / . -. - .-. -.--
select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-11-01'
            and plt.parcel_created_at < '2023-12-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select
    t1.pno 运单号
    ,pi.client_id 客户ID
    ,oi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,case
        when 1st.pno is not null then 1st.type
        when 1st.pno is null and 2nd.pno is not null then 2nd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is not null then 3rd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is not null then 4th.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is null and 5th.pno is not null then 5th.type
        else 'other'
    end 环节
    ,if(pi.returned = 0, '正向', '逆向') '正向/逆向'
    ,if(pi.returned = 1, ss_custom.name, ss2.name) 正向揽收网点
    ,if(pi.returned = 1, ss2.name, null) 退件揽收网点
    ,ps1.store_name 上游网点
    ,ss4.name 最后有效路由网点
    ,ss3.name 判责网点
    ,ps1.van_in_line_name 车线名称
    ,ps1.van_arrived_at 车货到港时间
    ,if(pack.pno is not null, '是', '否') 是否集包
    ,pack.seal_store_name 集包网点
    ,pack.es_unseal_store_name 应拆包网点
    ,pack.pack_no 集包号
    ,ps1.last_valid_route_action '车货到港后最后有效路由'
    ,ps1.last_valid_routed_at '车货到港后最后有效路由时间'
    ,if(scan_no.pno is not null, '是', '否')  是否上报有发无到
    ,scan_no.store_name 上报有发无到网点
    ,scan_no.route_time  上报有发无到时间
    ,if(mac.pno is not null, '是', '否') 是否上分拣机
    ,4th.staff_info_id 最后交接员工id
from  t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-10-30'
left join my_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join my_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join my_staging.sys_store ss_custom on ss_custom.id = pi2.ticket_pickup_store_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss3 on ss3.id = t1.store_id
left join my_staging.sys_store ss4 on ss4.id = t1.last_valid_store_id
left join
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,ft.store_id
            ,ft.store_name
            ,pssn.van_in_line_name
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.van_arrived_at desc) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        left join my_bi.fleet_time ft on pssn.van_in_proof_id = ft.proof_id and pssn.store_id = ft.next_store_id and ft.arrive_type in (3,5)
        where
            pssn.van_arrived_at < t1.created_at
    ) ps1 on ps1.pno = t1.pno and ps1.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name seal_store_name
            ,json_extract(pr.extra_value, '$.esUnsealStoreName') es_unseal_store_name
            ,json_extract(pr.extra_value, '$.packPno') pack_no
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SEAL'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
            and pr.routed_at > '2023-10-30'
    ) pack on pack.pno = t1.pno and pack.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
    ) scan_no on scan_no.pno = t1.pno and  scan_no.rk = 1
left join
    (
        select
            t1.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-10-30'
            and pr.staff_info_id = 136770
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
        group by 1
    ) mac on mac.pno = t1.pno
left join
    (
        select -- 分拨揽收丢失
            pi.pno
            ,'分拨揽收后丢失' type
        from my_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pi.created_at > '2023-10-31'
            and pi.ticket_pickup_store_id = t1.last_valid_store_id
            and pi.ticket_pickup_store_id = t1.store_id
            and pr.pno is null
        group by 1,2
    ) 1st on 1st.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'到港分拨后遗失' type
        from t t1
        left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = t1.store_id
        where
            pssn.van_arrived_at is not null
            and (pssn.first_valid_routed_at is null or pssn.first_valid_routed_at > date_sub(t1.created_at, interval  8 hour))
        group by 1,2
    ) 2nd on 2nd.pno = t1.pno
left join
    (
        select
            t1.pno
           ,'分拨到件入仓后丢失' type
        from t t1
        where
            t1.last_valid_store_id = t1.store_id
            and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
        group by 1,2
    ) 3rd on 3rd.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'分拨交接后丢失' type
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from t t1
        join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            t1.last_valid_store_id = t1.store_id
            and pr.pno is not null
    ) 4th on 4th.pno = t1.pno and 4th.rk = 1
left join
    (
        select -- 判给发件出仓网点
            t1.pno
            ,'分拨发件出仓后丢失' type
        from t t1
        left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pr.pno is not null
        group by 1,2
    ) 5th on 5th.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
    (
        select
            plt.pno
            ,plr.store_id
            ,plt.last_valid_store_id
            ,plt.last_valid_action
            ,plt.created_at
        from my_bi.parcel_lose_task plt
        left join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plt.parcel_created_at >= '2023-12-01'
            and plt.parcel_created_at < '2024-01-01'
            and plt.state = 6
            and plt.penalties > 0
            and plt.duty_result = 1
            and ss.category in (8,12) -- hub
        group by 1,2,3,4,5
    )
select
    t1.pno 运单号
    ,pi.client_id 客户ID
    ,oi.cod_amount/100 cod金额
    ,oi.cogs_amount/100 cogs金额
    ,case
        when 1st.pno is not null then 1st.type
        when 1st.pno is null and 2nd.pno is not null then 2nd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is not null then 3rd.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is not null then 4th.type
        when 1st.pno is null and 2nd.pno is null and 3rd.pno is null and 4th.pno is null and 5th.pno is not null then 5th.type
        else 'other'
    end 环节
    ,if(pi.returned = 0, '正向', '逆向') '正向/逆向'
    ,if(pi.returned = 1, ss_custom.name, ss2.name) 正向揽收网点
    ,if(pi.returned = 1, ss2.name, null) 退件揽收网点
    ,ps1.store_name 上游网点
    ,ss4.name 最后有效路由网点
    ,ss3.name 判责网点
    ,ps1.van_in_line_name 车线名称
    ,ps1.van_arrived_at 车货到港时间
    ,if(pack.pno is not null, '是', '否') 是否集包
    ,pack.seal_store_name 集包网点
    ,pack.es_unseal_store_name 应拆包网点
    ,pack.pack_no 集包号
    ,ps1.last_valid_route_action '车货到港后最后有效路由'
    ,ps1.last_valid_routed_at '车货到港后最后有效路由时间'
    ,if(scan_no.pno is not null, '是', '否')  是否上报有发无到
    ,scan_no.store_name 上报有发无到网点
    ,scan_no.route_time  上报有发无到时间
    ,if(mac.pno is not null, '是', '否') 是否上分拣机
    ,4th.staff_info_id 最后交接员工id
from  t t1
left join my_staging.parcel_info pi on pi.pno = t1.pno and pi.created_at > '2023-11-30'
left join my_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join my_staging.parcel_info pi2 on pi2.pno = pi.customary_pno
left join my_staging.sys_store ss_custom on ss_custom.id = pi2.ticket_pickup_store_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss3 on ss3.id = t1.store_id
left join my_staging.sys_store ss4 on ss4.id = t1.last_valid_store_id
left join
    (
        select
            pssn.pno
            ,pssn.van_arrived_at
            ,ft.store_id
            ,ft.store_name
            ,pssn.van_in_line_name
            ,pssn.last_valid_route_action
            ,pssn.last_valid_routed_at
            ,row_number() over (partition by t1.pno order by pssn.van_arrived_at desc) rk
        from dwm.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        left join my_bi.fleet_time ft on pssn.van_in_proof_id = ft.proof_id and pssn.store_id = ft.next_store_id and ft.arrive_type in (3,5)
        where
            pssn.van_arrived_at < t1.created_at
    ) ps1 on ps1.pno = t1.pno and ps1.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name seal_store_name
            ,json_extract(pr.extra_value, '$.esUnsealStoreName') es_unseal_store_name
            ,json_extract(pr.extra_value, '$.packPno') pack_no
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'SEAL'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
            and pr.routed_at > '2023-11-30'
    ) pack on pack.pno = t1.pno and pack.rk = 1
left join
    (
        select
            t1.pno
            ,pr.store_name
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-11-30'
            and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
    ) scan_no on scan_no.pno = t1.pno and  scan_no.rk = 1
left join
    (
        select
            t1.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-11-30'
            and pr.staff_info_id = 136770
            and pr.routed_at < date_sub(t1.created_at, interval 8 hour)
        group by 1
    ) mac on mac.pno = t1.pno
left join
    (
        select -- 分拨揽收丢失
            pi.pno
            ,'分拨揽收后丢失' type
        from my_staging.parcel_info pi
        join t t1 on t1.pno = pi.pno
        left join my_staging.parcel_route pr on pr.pno = t1.pno and pr.created_at > '2023-11-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pi.created_at > '2023-11-31'
            and pi.ticket_pickup_store_id = t1.last_valid_store_id
            and pi.ticket_pickup_store_id = t1.store_id
            and pr.pno is null
        group by 1,2
    ) 1st on 1st.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'到港分拨后遗失' type
        from t t1
        left join dwm.parcel_store_stage_new pssn on pssn.pno = t1.pno and pssn.store_id = t1.store_id
        where
            pssn.van_arrived_at is not null
            and (pssn.first_valid_routed_at is null or pssn.first_valid_routed_at > date_sub(t1.created_at, interval  8 hour))
        group by 1,2
    ) 2nd on 2nd.pno = t1.pno
left join
    (
        select
            t1.pno
           ,'分拨到件入仓后丢失' type
        from t t1
        where
            t1.last_valid_store_id = t1.store_id
            and t1.last_valid_action = 'ARRIVAL_WAREHOUSE_SCAN'
        group by 1,2
    ) 3rd on 3rd.pno = t1.pno
left join
    (
        select
            t1.pno
            ,'分拨交接后丢失' type
            ,pr.staff_info_id
            ,row_number() over (partition by t1.pno order by pr.routed_at desc) rk
        from t t1
        join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and t1.store_id = pr.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            t1.last_valid_store_id = t1.store_id
            and pr.pno is not null
    ) 4th on 4th.pno = t1.pno and 4th.rk = 1
left join
    (
        select -- 判给发件出仓网点
            t1.pno
            ,'分拨发件出仓后丢失' type
        from t t1
        left join my_staging.parcel_route pr on t1.pno = pr.pno and pr.created_at > '2023-10-30' and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and t1.store_id = pr.store_id and t1.last_valid_store_id = t1.store_id and pr.routed_at < date_sub(t1.created_at, interval  8 hour)
        where
            pr.pno is not null
        group by 1,2
    ) 5th on 5th.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when pi.cod_enabled = 1 and pi.cod_amount > 0 and pi.cod_amount <= 10000 then '1-100'
        when pi.cod_enabled = 1 and pi.cod_amount > 10000 and pi.cod_amount <= 20000 then '101-200'
        when pi.cod_enabled = 1 and pi.cod_amount > 20000 and pi.cod_amount <= 30000 then '201-300'
        when pi.cod_enabled = 1 and pi.cod_amount > 30000 and pi.cod_amount <= 40000 then '301-400'
        when pi.cod_enabled = 1 and pi.cod_amount > 40000 and pi.cod_amount <= 50000 then '401-500'
        when pi.cod_enabled = 1 and pi.cod_amount > 50000  then '500以上'
        when pi.cod_enabled = 0 then '0'
    end COD分段
    ,count(pi.pno) 包裹数
from my_staging.parcel_info pi
left join my_staging.order_info oi on pi.pno = oi.pno
where
    pi.returned = 0
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-12-31 16:00:00'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when oi.cogs_amount > 0 and oi.cogs_amount <= 10000 then '1-100'
        when oi.cogs_amount > 10000 and oi.cogs_amount <= 20000 then '101-200'
        when oi.cogs_amount > 20000 and oi.cogs_amount <= 30000 then '201-300'
        when oi.cogs_amount > 30000 and oi.cogs_amount <= 40000 then '301-400'
        when oi.cogs_amount > 40000 and oi.cogs_amount <= 50000 then '401-500'
        when oi.cogs_amount > 50000  then '500以上'
        when oi.cogs_amount = 0 or oi.cogs_amount is null then '0'
    end COD分段
    ,count(pi.pno) 包裹数
from my_staging.parcel_info pi
left join my_staging.order_info oi on pi.pno = oi.pno
where
    pi.returned = 0
    and pi.created_at >= '2023-10-31 16:00:00'
    and pi.created_at < '2023-12-31 16:00:00'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from my_staging.parcel_info pi
join my_bi.parcel_lose_task plt on plt.pno = pi.pno
where
    plt.state = 6
    and pi.state = 2;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from my_staging.parcel_info pi
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
join my_bi.parcel_lose_task plt on plt.pno = pi.pno
where
    plt.state = 6
    and pi.state = 2
    and bc.client_id is null
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from my_staging.parcel_info pi
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
join my_bi.parcel_lose_task plt on plt.pno = pi.pno
where
    plt.state = 6
    and pi.state = 2
    and plt.duty_result = 1
    and bc.client_id is null
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from my_staging.parcel_info pi
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join my_bi.parcel_lose_task plt on plt.pno = pi.pno
join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 4
where
    pi.state = 2
    and plt.duty_result = 1
    and bc.client_id is null
    and pcol.created_at < date_sub(pi.state_change_at, interval 8 hour )
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from my_staging.parcel_info pi
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join my_bi.parcel_lose_task plt on plt.pno = pi.pno
join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 4
where
    pi.state = 2
    and plt.duty_result = 1
    and bc.client_id is null
    and pcol.created_at < date_sub(pi.state_change_at, interval 8 hour );
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from my_staging.parcel_info pi
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join my_bi.parcel_lose_task plt on plt.pno = pi.pno
join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action = 4
where
    pi.state = 2
    and plt.duty_result = 1
#     and bc.client_id is null
    and pcol.created_at < date_sub(pi.state_change_at, interval 8 hour )
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from my_staging.parcel_info pi
left join my_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
where
    pi2.state = 9;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
from my_staging.parcel_info pi
left join my_staging.parcel_info pi2 on pi2.pno = pi.returned_pno
where
    pi2.state = 9
    and pi.state = 2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,a.工号 '工号/Employee ID'
    ,a.日期 '违规日期/Violation date'
    ,'4' '违规类型/Violation type'
    ,json_object('late_detail', a.late_detail, 'late_minutes', a.late_minutes) '违规详情/Violation details'
from
    (
                select
        adv.stat_date '日期'
        ,hsi.staff_info_id '工号'
        ,hsi.name '姓名'
        ,hsi.mobile '电话号码'
        ,case when hsi.formal=1 and hsi.hire_type=13 and hsi.is_sub_staff=0 then '个人代理'
        when hsi.formal=1 and hsi.is_sub_staff=0 then '正式员工'
        when hsi.formal=1 and hsi.is_sub_staff=1 then '子账号支援'
        when hsi.formal=0 then '非正式员工'
        else hsi.formal
        end '员工类型'
        ,hjt.job_name '职位'
        ,case  when hsi.`state`=1  then '在职'
              when hsi.`state`=2 then '离职'
              when hsi.`state`=3 then '停职'
              end as '在职状态'
        ,ifnull(smr.name,smr1.name,smr2.name) '大区'
        ,ifnull(smp.name,smp1.name) '片区'
        ,ss.name '网点'
        ,adv.attendance_started_at '上班打卡时间'
        ,adv.shift_start '应上班打卡时间'
        ,round(datediff('second',adv.shift_start,adv.attendance_started_at)/60,1) '迟到分钟数'
        ,dd.num '累计(10min内)迟到次数'
        ,hsi.hire_date '入职日期'
        ,date_diff(current_date(),hsi.hire_date) '入职天数'
        ,concat(date_format(adv.stat_date, '%d/%m/%Y'),'[', adv.shift_start1, '-', adv.shift_end1, ']', date_format(adv.attendance_started_at, '%H:%i'), ' Lewat ', timestampdiff(minute , concat(adv.stat_date, ' ', adv.shift_start1), adv.attendance_started_at), ' minit' ) late_detail
            ,timestampdiff(minute , concat(adv.stat_date, ' ', adv.shift_start1), adv.attendance_started_at)  late_minutes
        from
        (select
        adv.stat_date
        ,staff_info_id
        ,adv.attendance_time
        ,adv.attendance_started_at
        ,adv.attendance_end_at
        ,adv.shift_start as shift_start1
        ,adv.shift_end as shift_end1
        ,concat(stat_date,' ',adv.shift_start)  'shift_start'
        ,concat(stat_date,' ',adv.shift_end)  'shift_end'
        from my_bi.attendance_data_v2 adv
        where adv.stat_date =current_date()-interval 1 day
        and adv.display_data<>'REST'
        )adv
        join my_bi.hr_staff_info hsi on hsi.staff_info_id=adv.staff_info_id
        and  hsi.sys_department_id in ('320','316','15084')
        and hsi.state=1
        and hsi.formal<>4

        left join my_bi.hr_job_title hjt on hjt.id=hsi.job_title
        left join my_staging.sys_store ss on ss.id=hsi.sys_store_id
        left join my_staging.sys_manage_region smr on smr.id=ss.manage_region
        left join my_staging.sys_manage_piece smp on smp.id=ss.manage_piece
        left join my_staging.sys_manage_region smr1 on smr1.manager_id=hsi.staff_info_id
        left join my_staging.sys_manage_piece smp1 on smp1.manager_id=hsi.staff_info_id
        left join my_staging.sys_manage_region smr2 on smr2.id=smp1.manage_region_id
        left join
        (select  adv.staff_info_id
        ,count(*) num
        from my_bi.attendance_data_v2 adv
        where adv.stat_date>= date_sub(current_date()-interval 1 day,interval weekday(current_date()-interval 1 day) day)
        and adv.stat_date<current_date()
        and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)>60 and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)<600
        group by 1
        having count(*)>=3
        )dd on dd.staff_info_id=adv.staff_info_id
        left join
        (select  adv.staff_info_id
        from my_bi.attendance_data_v2 adv
        where adv.stat_date=current_date()-interval 1 day
        and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)>60 and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)<600
        )dd1 on dd1.staff_info_id=adv.staff_info_id
        left join
                (# 剔除排休快递员
                    select
                        hw.date_at
                        ,hw.staff_info_id
                    from my_backyard.hr_staff_work_days hw
                    where hw.date_at=date_sub(current_date,interval 1 day)
                )f3 on f3.staff_info_id=adv.staff_info_id
        left join
        (select
        dd.staff_info_id
        ,dd.leave_start_time
        ,dd. leave_end_time
        from my_backyard.staff_audit dd
        WHERE `audit_type` = 2
        and status =2
        and dd.leave_start_time<=current_date()-interval 1 day
        and dd.leave_end_time>=current_date()-interval 1 day
        )dd2 on dd2.staff_info_id=adv.staff_info_id


        where ((datediff('second',adv.shift_start,adv.attendance_started_at)/60>=10)
        or (dd.num>=3 and dd1.staff_info_id is not null))
        and f3.staff_info_id is null
        and dd2.staff_info_id is null
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,a.工号 '工号/Employee ID'
    ,a.日期 '违规日期/Violation date'
    ,4 '违规类型/Violation type'
    ,json_object('late_detail', a.late_detail, 'late_minutes', a.late_minutes) '违规详情/Violation details'
from
    (
                select
        adv.stat_date '日期'
        ,hsi.staff_info_id '工号'
        ,hsi.name '姓名'
        ,hsi.mobile '电话号码'
        ,case when hsi.formal=1 and hsi.hire_type=13 and hsi.is_sub_staff=0 then '个人代理'
        when hsi.formal=1 and hsi.is_sub_staff=0 then '正式员工'
        when hsi.formal=1 and hsi.is_sub_staff=1 then '子账号支援'
        when hsi.formal=0 then '非正式员工'
        else hsi.formal
        end '员工类型'
        ,hjt.job_name '职位'
        ,case  when hsi.`state`=1  then '在职'
              when hsi.`state`=2 then '离职'
              when hsi.`state`=3 then '停职'
              end as '在职状态'
        ,ifnull(smr.name,smr1.name,smr2.name) '大区'
        ,ifnull(smp.name,smp1.name) '片区'
        ,ss.name '网点'
        ,adv.attendance_started_at '上班打卡时间'
        ,adv.shift_start '应上班打卡时间'
        ,round(datediff('second',adv.shift_start,adv.attendance_started_at)/60,1) '迟到分钟数'
        ,dd.num '累计(10min内)迟到次数'
        ,hsi.hire_date '入职日期'
        ,date_diff(current_date(),hsi.hire_date) '入职天数'
        ,concat(date_format(adv.stat_date, '%d/%m/%Y'),'[', adv.shift_start1, '-', adv.shift_end1, ']', date_format(adv.attendance_started_at, '%H:%i'), ' Lewat ', timestampdiff(minute , concat(adv.stat_date, ' ', adv.shift_start1), adv.attendance_started_at), ' minit' ) late_detail
            ,timestampdiff(minute , concat(adv.stat_date, ' ', adv.shift_start1), adv.attendance_started_at)  late_minutes
        from
        (select
        adv.stat_date
        ,staff_info_id
        ,adv.attendance_time
        ,adv.attendance_started_at
        ,adv.attendance_end_at
        ,adv.shift_start as shift_start1
        ,adv.shift_end as shift_end1
        ,concat(stat_date,' ',adv.shift_start)  'shift_start'
        ,concat(stat_date,' ',adv.shift_end)  'shift_end'
        from my_bi.attendance_data_v2 adv
        where adv.stat_date =current_date()-interval 1 day
        and adv.display_data<>'REST'
        )adv
        join my_bi.hr_staff_info hsi on hsi.staff_info_id=adv.staff_info_id
        and  hsi.sys_department_id in ('320','316','15084')
        and hsi.state=1
        and hsi.formal<>4

        left join my_bi.hr_job_title hjt on hjt.id=hsi.job_title
        left join my_staging.sys_store ss on ss.id=hsi.sys_store_id
        left join my_staging.sys_manage_region smr on smr.id=ss.manage_region
        left join my_staging.sys_manage_piece smp on smp.id=ss.manage_piece
        left join my_staging.sys_manage_region smr1 on smr1.manager_id=hsi.staff_info_id
        left join my_staging.sys_manage_piece smp1 on smp1.manager_id=hsi.staff_info_id
        left join my_staging.sys_manage_region smr2 on smr2.id=smp1.manage_region_id
        left join
        (select  adv.staff_info_id
        ,count(*) num
        from my_bi.attendance_data_v2 adv
        where adv.stat_date>= date_sub(current_date()-interval 1 day,interval weekday(current_date()-interval 1 day) day)
        and adv.stat_date<current_date()
        and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)>60 and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)<600
        group by 1
        having count(*)>=3
        )dd on dd.staff_info_id=adv.staff_info_id
        left join
        (select  adv.staff_info_id
        from my_bi.attendance_data_v2 adv
        where adv.stat_date=current_date()-interval 1 day
        and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)>60 and datediff('second',concat(stat_date,' ',adv.shift_start),adv.attendance_started_at)<600
        )dd1 on dd1.staff_info_id=adv.staff_info_id
        left join
                (# 剔除排休快递员
                    select
                        hw.date_at
                        ,hw.staff_info_id
                    from my_backyard.hr_staff_work_days hw
                    where hw.date_at=date_sub(current_date,interval 1 day)
                )f3 on f3.staff_info_id=adv.staff_info_id
        left join
        (select
        dd.staff_info_id
        ,dd.leave_start_time
        ,dd. leave_end_time
        from my_backyard.staff_audit dd
        WHERE `audit_type` = 2
        and status =2
        and dd.leave_start_time<=current_date()-interval 1 day
        and dd.leave_end_time>=current_date()-interval 1 day
        )dd2 on dd2.staff_info_id=adv.staff_info_id


        where ((datediff('second',adv.shift_start,adv.attendance_started_at)/60>=10)
        or (dd.num>=3 and dd1.staff_info_id is not null))
        and f3.staff_info_id is null
        and dd2.staff_info_id is null
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a2.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
              pc.*
              ,store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as store_id
    ) a1
cross join
    (
        select
            *
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
left join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
            and prr.state = 2
        group by 1
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
              pc.*
              ,store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as store_id
    ) a1
cross join
    (
        select
            *
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
left join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
            and prr.state = 2
        group by 1
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    a2.*
from
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2

union all

select
    a2.*
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
left join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
            prr.pno
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
            and pi.client_id is null;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
              pc.*
              ,store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as store_id
    ) a1
cross join
    (
        select
            *
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
left join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,coalesce(pi.client_id, pi2.client_id) client_id
            ,coalesce(pi.cod_amount, pi2.cod_amount) cod_amount
            ,coalesce(pi.insure_declare_value, pi2.insure_declare_value) insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = prr.pno
        left join my_staging.parcel_info pi2 on pi2.recent_pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
            and prr.state = 2
        group by 1
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,coalesce(pi.client_id, pi2.client_id) client_id
            ,coalesce(pi.cod_amount, pi2.cod_amount) cod_amount
            ,coalesce(pi.insure_declare_value, pi2.insure_declare_value) insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = prr.pno
        left join my_staging.parcel_info pi2 on pi2.recent_pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,coalesce(pi.client_id, pi2.client_id) client_id
            ,coalesce(pi.cod_amount, pi2.cod_amount) cod_amount
            ,coalesce(pi.insure_declare_value, pi2.insure_declare_value) insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = upper(prr.pno)
        left join my_staging.parcel_info pi2 on pi2.recent_pno = upper(prr.pno)
        where
            prr.created_at >= '2024-01-14 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2

union all

select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a2.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from my_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join my_staging.sys_store ss
    ) a1
cross join
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a2
join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,coalesce(pi.client_id, pi2.client_id) client_id
            ,coalesce(pi.cod_amount, pi2.cod_amount) cod_amount
            ,coalesce(pi.insure_declare_value, pi2.insure_declare_value) insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = upper(prr.pno)
        left join my_staging.parcel_info pi2 on pi2.recent_pno = upper(prr.pno)
        where
            prr.created_at >= '2024-01-14 16:00:00'
    ) a3 on a3.store_id = a1.store_id and a3.client_id = a2.client_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5

union all


select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from my_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join my_staging.sys_store ss
    ) a1
cross join
    (
        select
            *
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
cross join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,coalesce(pi.client_id, pi2.client_id) client_id
            ,coalesce(pi.cod_amount, pi2.cod_amount) cod_amount
            ,coalesce(pi.insure_declare_value, pi2.insure_declare_value) insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = upper(prr.pno)
        left join my_staging.parcel_info pi2 on pi2.recent_pno = upper(prr.pno)
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all';
;-- -. . -..- - / . -. - .-. -.--
select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            coalesce(pi.client_id, pi2.client_id) client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_info pi on pi.pno = prr.pno
        left join my_staging.parcel_info pi2 on pi2.recent_pno = prr.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2;
;-- -. . -..- - / . -. - .-. -.--
select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = prr.pno
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, prr.pno) = pi.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2

union all

select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a2.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from my_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join my_staging.sys_store ss
    ) a1
cross join
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a2
join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
    ) a3 on a3.store_id = a1.store_id and a3.client_id = a2.client_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5

union all


select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from my_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join my_staging.sys_store ss
    ) a1
cross join
    (
        select
            *
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
cross join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-14 16:00:00'
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    pct.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case pct.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,case pct.state
        when 1 then '待协商'
        when 2 then '协商不一致，待重新协商'
        when 3 then '待财务核实'
        when 4 then '核实通过，待财务支付'
        when 5 then '财务驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止'
        when 8 then '异常关闭'
        when 9 then' 待协商（搁置）'
        when 10 then '等待再次联系'
    end 理赔状态
    ,pi.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
    ,case
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) < 24 then '0-24小时内处理'
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) >= 24 and timestampdiff(hour, pct.created_at, pct.updated_at) < 48 then '24-48小时内处理'
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) >= 48 and timestampdiff(hour, pct.created_at, pct.updated_at) < 72 then '48-72小时内处理'
        when pct.state = 6 and timestampdiff(hour, pct.created_at, pct.updated_at) >= 72 then '72小时以上处理'
        else null
    end 理赔处理时间
from my_bi.parcel_claim_task pct
join my_staging.parcel_info pi on pi.pno = pct.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pct.client_id
left join my_staging.ka_profile kp on kp.id = pct.client_id
left join my_staging.parcel_additional_info pai on pai.pno = pct.pno
where
    pct.created_at > '2023-11-01'
    and pct.created_at < '2024-01-16'
    and pi.state = 5;
;-- -. . -..- - / . -. - .-. -.--
select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >=  date_sub(curdate(), interval 8 hour)
           -- and prr.state = 2
        group by 1
    ) a2

union all

select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >=  date_sub(curdate(), interval 8 hour)
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a2.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from my_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join my_staging.sys_store ss
    ) a1
cross join
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a2
join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >=  date_sub(curdate(), interval 8 hour)
    ) a3 on a3.store_id = a1.store_id and a3.client_id = a2.client_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5

union all


select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from my_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join my_staging.sys_store ss
    ) a1
cross join
    (
        select
            *
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
cross join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >=  date_sub(curdate(), interval 8 hour)
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 16:00:00'
            and prr.created_at < '2024-01-18 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2

union all

select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 16:00:00'
            and prr.created_at < '2024-01-18 16:00:00'
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a2.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from my_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join my_staging.sys_store ss
    ) a1
cross join
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a2
join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 16:00:00'
            and prr.created_at < '2024-01-18 16:00:00'
    ) a3 on a3.store_id = a1.store_id and a3.client_id = a2.client_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5

union all


select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from my_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from my_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join my_staging.sys_store ss
    ) a1
cross join
    (
        select
            *
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
cross join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from my_staging.parcel_reject_report_info prr
        left join my_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join my_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 16:00:00'
            and prr.created_at < '2024-01-18 16:00:00'
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from my_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_my_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join my_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5;