select
    a.*
    ,case
        when hour(a.real_real_arrive_time) < 9 then '9点前'
        when hour(a.real_real_arrive_time) >= 9 and hour(a.real_real_arrive_time) < 13 then '9-13点'
        when hour(a.real_real_arrive_time) >= 13 and hour(a.real_real_arrive_time) < 17 then '13-17点'
        when hour(a.real_real_arrive_time) >= 17 then '17点之后'
    end 到达时间段
from
    (
         select
            ft.line_id
            ,ft.line_name
            ,ft.real_arrive_time
            ,ft.next_store_id
            ,ft.next_store_name
            ,ft.sign_time
            ,ft.plan_arrive_time
            ,ft.proof_id
            ,ft.sign_time
            ,ft.real_arrive_time
            # 车辆到港时间与司机签到时间取小值作为车考勤时间
            ,case when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time > ft.sign_time then ft.real_arrive_time
                  when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time < ft.sign_time then ft.sign_time
                  when ft.real_arrive_time is not null then ft.real_arrive_time
                  when ft.real_arrive_time is null then ft.sign_time else null end as adjust_real_arrive_time

            ,case when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time < ft.sign_time then ft.real_arrive_time
                  when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time > ft.sign_time then ft.sign_time
                  when ft.real_arrive_time is not null then ft.real_arrive_time
                  when ft.real_arrive_time is null then ft.sign_time else null end as real_real_arrive_time

            ,case when ft.line_mode=1 then '常规车'
                  when ft.line_mode=2 then '临时加班车'
                  when ft.line_mode=3 then '虚拟车线' else null end as mode_type

        from ph_staging.fleet_van_line fvl
        join ph_staging.fleet_van_line_timetable fvlt on fvl.id=fvlt.line_id and fvlt.deleted=0 and fvlt.order_no>=2
        join ph_bi.fleet_time ft on ft.line_id=fvlt.line_id
            and ft.next_store_id=fvlt.store_id
            and ft.line_mode in(1,2,3)
            and ft.fleet_status=1
            and ft.arrive_type in(3,5) #3:经停到达考勤; 5:目的地到达考勤
            and ft.line_name not like '%RS2%' # 完成
        join ph_staging.sys_store ss on fvl.origin_id=ss.id
            and (ss.category=8 or ss.id in ( 'PH20180101', 'PH26110100', 'PH59020701','PH42030J00', 'PH36100100','PH76190100', 'PH34420100', 'PH73020100', 'PH81161D00', 'PH80050100'))
        join ph_staging.sys_store ss1 on fvl.target_id=ss1.id and ss1.category in(1,14)
        join ph_staging.sys_store ss2 on fvlt.store_id=ss2.id and ss2.category in(1,14)
        where date(case when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time < ft.sign_time then ft.real_arrive_time
                    when ft.real_arrive_time is not null and ft.sign_time is not null and ft.real_arrive_time > ft.sign_time then ft.sign_time
                    when ft.real_arrive_time is not null then ft.real_arrive_time
                    when ft.real_arrive_time is null then ft.sign_time else null end)=date_sub(current_date,interval 2 day)
            and fvl.deleted=0
            and fvl.mode in(1,2,3)
            and fvl.name not like '%RS2%'
    ) a
