# with t as
# (

#        )
# select
#     a1.*
#     ,a2.plan_arrive_time 12点前最晚计划到达时间
#     ,a3.plan_arrive_time 12点后最晚计划到达时间
# from
#     (
#         select
#             t1.next_store_name
#             ,count(if(hour(t1.plan_arrive_time) < 12 and t1.line_mode = 1, t1.line_id, null )) 12点之前车辆数
#             ,count(if(hour(t1.plan_arrive_time) >= 12 and t1.line_mode = 1, t1.line_id, null )) 12点之后车辆数
#             ,max(if(hour(t1.plan_arrive_time) < 12 and t1.line_mode = 1, t1.plan_arrive_time, null)) 12点前最晚计划到达时间
#             ,max(if(hour(t1.plan_arrive_time) >= 12 and t1.line_mode = 1, t1.plan_arrive_time, null)) 12点后最晚计划到达时间
#         from t t1
#         group by 1
#     ) a1
# left join
#     (
#         select
#             a2.*
#         from
#             (
#                 select
#                     t1.*
#                     ,row_number() over (partition by t1.plan_arrive_time order by t1.plan_arrive_time desc ) rk
#                 from  t t1
#                 where
#                     hour(t1.plan_arrive_time) < 12
#             ) a2
#         where
#             a2.rk = 1
#     ) a2 on a2.next_store_name = a1.next_store_name
# left join
#     (
#         select
#             a3.*
#         from
#             (
#                 select
#                     t1.*
#                     ,row_number() over (partition by t1.plan_arrive_time order by t1.plan_arrive_time desc ) rk
#                 from  t t1
#                 where
#                     hour(t1.plan_arrive_time) >= 12
#             ) a3
#         where
#             a3.rk = 1
#     ) a3 on a3.next_store_name = a1.next_store_name
# ;select date_Sub(CURDATE(),interval 0 day)

#
select
    a.*
    ,flr1.parcel_count 到站网点1天前包裹数
    ,flr2.parcel_count 到站网点2天前包裹数
    ,flr3.parcel_count 到站网点3天前包裹数
    ,flr4.parcel_count 到站网点4天前包裹数
    ,flr5.parcel_count 到站网点5天前包裹数
    ,flr6.parcel_count 到站网点6天前包裹数
    ,flr7.parcel_count 到站网点7天前包裹数
    ,flr8.parcel_count 到站网点8天前包裹数
    ,flr9.parcel_count 到站网点9天前包裹数
    ,flr10.parcel_count 到站网点10天前包裹数
    ,flr14.parcel_count 到站网点11天前包裹数
    ,flr15.parcel_count 到站网点12天前包裹数
    ,flr13.parcel_count 到站网点13天前包裹数
    ,flr14.parcel_count 到站网点14天前包裹数
    ,flr15.parcel_count 到站网点15天前包裹数
from
    (
        select
            ft.line_id 线路ID, -- 线路ID
            ft.line_name 线路名称, -- 线路名称
            ft.line_mode 线路模式, -- 线路模式
            case when ft.line_mode=1 then '常规车'
                 when ft.line_mode=2 then '加班车'
                when ft.line_mode=3 then '虚拟车线'
                when ft.line_mode=4 then '常规车'
                end  线路模式描述, -- 线路模式描述
            ft.proof_id 出车凭证, -- 出车凭证
            flr.parcel_count 包裹数,
            ft.store_id 发车网点ID, -- 发车网点ID
            ft.store_name 发车网点名称, -- 发车网点名称
            ss3.id 到车网点ID, -- 到车网点ID
            ss3.name 到车网点名称, -- 到车网点名称
            case  ss3.delivery_frequency
                when 1 then '一派'
                when 2 then '二派'
                when 3 then '三派'
            end 到达网点派件频次,
            ft.plan_arrive_time 计划到港时间, -- 计划到港时间
            ft.real_arrive_time 实际到港时间, -- 实际到港时间
            ft.sign_time 考勤签到时间, -- 考勤签到时间
            case
               when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time < ft.sign_time then ft.real_arrive_time
               when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time > ft.sign_time then ft.sign_time
               when ft.real_arrive_time is not null then ft.real_arrive_time
               when ft.real_arrive_time is null then ft.sign_time
               else null
            end  最终到达时间  -- 最终到达时间 （实际到达和签到取最小）
       from  -- 车线
       (
                    select
                        t.*
                    from fle_staging.fleet_van_line t
                    join -- 限制车线始发网点 分拨HUB、或者迷你分拨
                    (
                            select *
                            from fle_staging.sys_store
                            where category in (8,12)
                    ) ss on t.origin_id=ss.id
                    join -- 限制车线目的网点 SP、PDC
                    (
                            select *
                            from fle_staging.sys_store
                            where category in(1,10)
                    ) ss1  on t.target_id=ss1.id
                    where  t.mode in(1,2,3,4) -- 1 常规模式 2 临时模式 3 '虚拟车线' 4 常规模式
                      and t.deleted=0
                        and t.name not like '%RS2%'

      ) fvl
       join  -- 实际车线运行fleet_time
       (
                    select *
                    from bi_pro.fleet_time
                    where line_mode in(1,2,4) -- 1:支线 2:班车
                    and fleet_status=1 -- 1已完成 0未完成
                    and arrive_type in(3,5)  -- 3:经停到达考勤; 5:目的地到达考勤
                    and line_name not like '%RS2%'
                    and date(plan_arrive_time)=date_Sub(CURDATE(),interval 1 day)

    #                 and  -- 当日达到
    #                 (date(real_arrive_time)=date_Sub(CURDATE(),interval 0 day) or date(sign_time)=date_Sub(CURDATE(),interval 0 day))
       ) ft  on fvl.id=ft.line_id
       left join fle_staging.sys_store_bdc_bsp sb1 on ft.next_store_id=sb1.bsp_id -- 目的地网点如果是BSP网点时、匹配实际BDC网点
       left join fle_staging.sys_store ss3 on coalesce(sb1.bdc_id,ft.next_store_id)=ss3.id
       left join bi_pro.fleet_loading_rate_and_cost flr on flr.proof_id = ft.proof_id and ft.store_id = flr.shuttle_begin_id and ft.next_store_id = flr.shuttle_end_id
#         where
#             flr.parcel_count < 50
    ) a
left join bi_pro.fleet_time ft1 on ft1.line_id = a.线路ID and ft1.next_store_id = a.到车网点ID and  date(ft1.plan_arrive_time) = date_sub(curdate(), interval 2 day)
left join bi_pro.fleet_loading_rate_and_cost flr1 on flr1.proof_id = ft1.proof_id and ft1.store_id = flr1.shuttle_begin_id and ft1.next_store_id = flr1.shuttle_end_id

left join bi_pro.fleet_time ft2 on ft2.line_id = a.线路ID and ft2.next_store_id = a.到车网点ID and  date(ft2.plan_arrive_time) = date_sub(curdate(), interval 3 day)
left join bi_pro.fleet_loading_rate_and_cost flr2 on flr2.proof_id = ft2.proof_id and ft2.store_id = flr2.shuttle_begin_id and ft2.next_store_id = flr2.shuttle_end_id

left join bi_pro.fleet_time ft3 on ft3.line_id = a.线路ID and ft3.next_store_id = a.到车网点ID and  date(ft3.plan_arrive_time) = date_sub(curdate(), interval 4 day)
left join bi_pro.fleet_loading_rate_and_cost flr3 on flr3.proof_id = ft3.proof_id and ft3.store_id = flr3.shuttle_begin_id and ft3.next_store_id = flr3.shuttle_end_id

left join bi_pro.fleet_time ft4 on ft4.line_id = a.线路ID and ft4.next_store_id = a.到车网点ID and  date(ft4.plan_arrive_time) = date_sub(curdate(), interval 5 day)
left join bi_pro.fleet_loading_rate_and_cost flr4 on flr4.proof_id = ft4.proof_id and ft4.store_id = flr4.shuttle_begin_id and ft4.next_store_id = flr4.shuttle_end_id

left join bi_pro.fleet_time ft5 on ft5.line_id = a.线路ID and ft5.next_store_id = a.到车网点ID and  date(ft5.plan_arrive_time) = date_sub(curdate(), interval 6 day)
left join bi_pro.fleet_loading_rate_and_cost flr5 on flr5.proof_id = ft5.proof_id and ft5.store_id = flr5.shuttle_begin_id and ft5.next_store_id = flr5.shuttle_end_id

left join bi_pro.fleet_time ft6 on ft6.line_id = a.线路ID and ft6.next_store_id = a.到车网点ID and  date(ft6.plan_arrive_time) = date_sub(curdate(), interval 7 day)
left join bi_pro.fleet_loading_rate_and_cost flr6 on flr6.proof_id = ft6.proof_id and ft6.store_id = flr6.shuttle_begin_id and ft6.next_store_id = flr6.shuttle_end_id

left join bi_pro.fleet_time ft7 on ft7.line_id = a.线路ID and ft7.next_store_id = a.到车网点ID and  date(ft7.plan_arrive_time) = date_sub(curdate(), interval 8 day)
left join bi_pro.fleet_loading_rate_and_cost flr7 on flr7.proof_id = ft7.proof_id and ft7.store_id = flr7.shuttle_begin_id and ft7.next_store_id = flr7.shuttle_end_id

left join bi_pro.fleet_time ft8 on ft8.line_id = a.线路ID and ft8.next_store_id = a.到车网点ID and  date(ft8.plan_arrive_time) = date_sub(curdate(), interval 9 day)
left join bi_pro.fleet_loading_rate_and_cost flr8 on flr8.proof_id = ft8.proof_id and ft8.store_id = flr8.shuttle_begin_id and ft8.next_store_id = flr8.shuttle_end_id

left join bi_pro.fleet_time ft9 on ft9.line_id = a.线路ID and ft9.next_store_id = a.到车网点ID and  date(ft9.plan_arrive_time) = date_sub(curdate(), interval 10 day)
left join bi_pro.fleet_loading_rate_and_cost flr9 on flr9.proof_id = ft9.proof_id and ft9.store_id = flr9.shuttle_begin_id and ft9.next_store_id = flr9.shuttle_end_id

left join bi_pro.fleet_time ft10 on ft10.line_id = a.线路ID and ft10.next_store_id = a.到车网点ID and  date(ft10.plan_arrive_time) = date_sub(curdate(), interval 11 day)
left join bi_pro.fleet_loading_rate_and_cost flr10 on flr10.proof_id = ft10.proof_id and ft10.store_id = flr10.shuttle_begin_id and ft10.next_store_id = flr10.shuttle_end_id

left join bi_pro.fleet_time ft11 on ft11.line_id = a.线路ID and ft11.next_store_id = a.到车网点ID and  date(ft11.plan_arrive_time) = date_sub(curdate(), interval 12 day)
left join bi_pro.fleet_loading_rate_and_cost flr11 on flr11.proof_id = ft11.proof_id and ft11.store_id = flr11.shuttle_begin_id and ft11.next_store_id = flr11.shuttle_end_id

left join bi_pro.fleet_time ft12 on ft12.line_id = a.线路ID and ft12.next_store_id = a.到车网点ID and  date(ft12.plan_arrive_time) = date_sub(curdate(), interval 13 day)
left join bi_pro.fleet_loading_rate_and_cost flr12 on flr12.proof_id = ft12.proof_id and ft12.store_id = flr12.shuttle_begin_id and ft12.next_store_id = flr12.shuttle_end_id

left join bi_pro.fleet_time ft13 on ft13.line_id = a.线路ID and ft13.next_store_id = a.到车网点ID and  date(ft13.plan_arrive_time) = date_sub(curdate(), interval 14 day)
left join bi_pro.fleet_loading_rate_and_cost flr13 on flr13.proof_id = ft13.proof_id and ft13.store_id = flr13.shuttle_begin_id and ft13.next_store_id = flr13.shuttle_end_id

left join bi_pro.fleet_time ft14 on ft14.line_id = a.线路ID and ft14.next_store_id = a.到车网点ID and  date(ft14.plan_arrive_time) = date_sub(curdate(), interval 15 day)
left join bi_pro.fleet_loading_rate_and_cost flr14 on flr14.proof_id = ft14.proof_id and ft14.store_id = flr14.shuttle_begin_id and ft14.next_store_id = flr14.shuttle_end_id

left join bi_pro.fleet_time ft15 on ft15.line_id = a.线路ID and ft15.next_store_id = a.到车网点ID and  date(ft15.plan_arrive_time) = date_sub(curdate(), interval 16 day)
left join bi_pro.fleet_loading_rate_and_cost flr15 on flr15.proof_id = ft15.proof_id and ft15.store_id = flr15.shuttle_begin_id and ft15.next_store_id = flr15.shuttle_end_id