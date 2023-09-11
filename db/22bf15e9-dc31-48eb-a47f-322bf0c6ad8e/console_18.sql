with t as
(
   select
                ft.line_id, -- 线路ID
                ft.line_name, -- 线路名称
                ft.line_mode, -- 线路模式
                case when ft.line_mode=1 then '常规车'
                     when ft.line_mode=2 then '加班车'
                    when ft.line_mode=3 then '虚拟车线'
                    when ft.line_mode=4 then '常规车'
                    end line_mode_desc, -- 线路模式描述
                ft.proof_id, -- 出车凭证
                ft.store_id, -- 发车网点ID
                ft.store_name, -- 发车网点名称
                ss3.id next_store_id, -- 到车网点ID
                ss3.name next_store_name, -- 到车网点名称
                ft.plan_arrive_time, -- 计划到港时间
                ft.real_arrive_time, -- 实际到港时间
                ft.sign_time, -- 考勤签到时间
                case
                   when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time < ft.sign_time then ft.real_arrive_time
                   when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time > ft.sign_time then ft.sign_time
                   when ft.real_arrive_time is not null then ft.real_arrive_time
                   when ft.real_arrive_time is null then ft.sign_time
                   else null
                end  adjust_real_arrive_time  -- 最终到达时间 （实际到达和签到取最小）
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
                where line_mode in(1,2) -- 1:支线 2:班车
                and fleet_status=1 -- 1已完成 0未完成
                and arrive_type in(3,5)  -- 3:经停到达考勤; 5:目的地到达考勤
                and line_name not like '%RS2%'
                and date(plan_arrive_time)=date_Sub(CURDATE(),interval 1 day)
                and  -- 当日达到
                (date(real_arrive_time)=date_Sub(CURDATE(),interval 1 day) or date(sign_time)=date_Sub(CURDATE(),interval 1 day))
   ) ft  on fvl.id=ft.line_id
   left join fle_staging.sys_store_bdc_bsp sb1 on ft.next_store_id=sb1.bsp_id -- 目的地网点如果是BSP网点时、匹配实际BDC网点
   left join fle_staging.sys_store ss3 on coalesce(sb1.bdc_id,ft.next_store_id)=ss3.id
)
# select
#     a1.*
#     ,a2.plan_arrive_time 12点前最晚计划到达时间
#     ,a3.plan_arrive_time 12点后最晚计划到达时间
# from
#     (
        select
            t1.next_store_name
            ,count(if(hour(t1.plan_arrive_time) < 12 and t1.line_mode = 1, t1.line_id, null )) 12点之前车辆数
            ,count(if(hour(t1.plan_arrive_time) >= 12 and t1.line_mode = 1, t1.line_id, null )) 12点之后车辆数
            ,max(if(hour(t1.plan_arrive_time) < 12 and t1.line_mode = 1, t1.plan_arrive_time, null)) 12点前最晚计划到达时间
            ,max(if(hour(t1.plan_arrive_time) >= 12 and t1.line_mode = 1, t1.plan_arrive_time, null)) 12点后最晚计划到达时间
        from t t1
        group by 1
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