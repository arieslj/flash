# with t as
#     (
#         select
#              pr.id
#             ,pr.pno
#             ,pr.staff_info_id
#             ,pi.src_phone
#             ,pi.dst_phone
#             ,json_extract(pr.extra_value, '$.phone') phone
#             ,case
#                 when  json_extract(pr.extra_value, '$.phone') = pi.src_phone then'src'
#                 when json_extract(pr.extra_value, '$.phone') = pi.dst_phone then 'dst'
#                 else 'other'
#             end phone_source
#             ,case pr.route_action
#                 when 'PHONE' then 'out_going'
#                 when 'INCOMING_CALL' then 'in_coming'
#              end as phone_type
#             ,pr.routed_at
#             ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pho_date
#         #     ,json_extract(pr.extra_value, '$.callingChannel') calling_channel
#         #     ,json_extract(pr.extra_value, '$.callType') call_type
#             ,cast(json_extract(pr.extra_value, '$.callDuration') as int) call_num -- 通话
#             ,cast(json_extract(pr.extra_value, '$.diaboloDuration') as int) diao_num -- 响铃
#         from rot_pro.parcel_route pr
#         left join fle_staging.parcel_info pi on pi.pno = pr.pno
#         where
#             pr.route_action in ('PHONE', 'INCOMING_CALL')
# #             and pr.routed_at >= date_sub(date_sub(curdate(), interval 1 day), interval 7 hour)
# #             and pr.routed_at < date_add(date_sub(curdate(), interval 1 day), interval 17 hour)
#             and pr.routed_at >= '2023-11-23 17:00:00'
#              and pr.routed_at < '2023-12-03 17:00:00'
#              -- and pr.staff_info_id = '19194'
#     )
# select
#     dt.region_name  大区
#     ,dt.piece_name 片区
#     ,dt.store_name 网点
#     ,f1.pho_date 日期
#     ,f1.staff_info_id 快递员工号
# #     ,hsi.name 快递员名字
#     ,hjt.job_name 岗位
#     ,coalesce(hsi.mobile_company, hsi.mobile)  快递员号码
# #     ,case
# #         when hsi.formal = 1 and hsi.is_sub_staff = 0 then '正式'
# #         when hsi.formal = 1 and hsi.is_sub_staff = 1 then '支援'
# #         when hsi.formal = 0 then '外协'
# #         else '其他'
# #     end 员工类型
# #     ,if(hsi.is_sub_staff = 0, '否', '是') 是否是子账号
# #     ,f1.phone_source 电话来源
#     ,f1.in_coming_count 来电次数
#     ,f1.in_coming_on_count 有效接通次数
#     ,f3.valid_incoming_count 有效接通数量
#     ,f3.valid_incoming_count/f1.in_coming_count 来电有效接通率
#     ,f1.in_coming_on_count 来电接通次数
#     ,f1.in_coming_off_count 来电未接通次数
#     ,f2.call_back_count 回拨电话数
#     ,f2.call_back_on_count 回拨接通数
#     ,f1.out_going_count 外呼数量
# #     ,f1.out_going_on_count 外呼接通次数
# from
#     (
#         select
#             t1.staff_info_id
#             ,t1.pho_date
#             ,t1.phone_source
#             ,count(distinct if(t1.phone_type = 'in_coming', t1.phone, null))  in_coming_count
#             ,count(distinct if(t1.phone_type = 'in_coming' and t1.call_num >= 8, t1.phone, null))  in_coming_on_count
# #             ,count(distinct if(t1.phone_type = 'in_coming' and (t1.call_num is null or t1.call_num = 0), t1.phone, null))  in_coming_off_count
# #             ,count(distinct if(t1.phone_type = 'out_going', t1.phone, null))  out_going_count
# #             ,count(distinct if(t1.phone_type = 'out_going' and t1.call_num > 0, t1.phone, null))  out_going_on_count
#         from t t1
#         group by 1,2,3
#     ) f1
# left join
#     (
#         select
#             a2.staff_info_id
#             ,a2.phone_source
#             ,a2.pho_date
#             ,count(distinct a2.phone)  call_back_count
#             ,count(distinct if(a2.call_num > 0, a2.phone, null))  call_back_on_count
#         from
#             (
#                 select
#                     t1.staff_info_id
#                     ,t1.phone_source
#                     ,t1.phone
#                     ,t1.pho_date
#                     ,t1.routed_at
#                 from t t1
#                 where
#                     t1.phone_type = 'in_coming'
#                     and t1.call_num = 0 -- 未接通
#             ) a1
#         join
#             (
#                 select
#                     t1.staff_info_id
#                     ,t1.phone_source
#                     ,t1.routed_at
#                     ,t1.pho_date
#                     ,t1.phone
#                     ,t1.id
#                     ,t1.call_num
#                     ,t1.diao_num
#                 from t t1
#                 where
#                     t1.phone_type = 'out_going'
#                     -- and t1.diao_num > 0 -- 响铃>0 ,排除一些响铃为 0 的情况
#             ) a2 on a1.phone = a2.phone and a1.staff_info_id = a2.staff_info_id and a1.pho_date = a2.pho_date and a2.phone_source = a1.phone_source
#         where
#             a2.routed_at > a1.routed_at
#         group by 1,2,3
#     ) f2 on f1.staff_info_id = f2.staff_info_id and f1.pho_date = f2.pho_date and f2.phone_source = f1.phone_source
# left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = f1.staff_info_id
# left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
# left join dwm.dim_th_sys_store_rd dt on dt.store_id = hsi.sys_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
# left join
#     (
#         select
#             a3.staff_info_id
#             ,a3.phone_source
#             ,a3.pho_date
#             ,count(distinct a3.phone)  valid_incoming_count
#         from
#             (
#                 select -- 回拨打通了，限制回拨通话时长>0
#                     a1.staff_info_id
#                     ,a1.phone_source
#                     ,a1.phone
#                     ,a1.pho_date
#                 from
#                     (
#                         select
#                             t1.staff_info_id
#                             ,t1.phone_source
#                             ,t1.phone
#                             ,t1.pho_date
#                             ,t1.routed_at
#                         from t t1
#                         where
#                             t1.phone_type = 'in_coming'
#                             and (t1.call_num is null or t1.call_num = 0) -- 未接通
#                     ) a1
#                 join
#                     (
#                         select
#                             t1.staff_info_id
#                             ,t1.phone_source
#                             ,t1.routed_at
#                             ,t1.pho_date
#                             ,t1.phone
#                             ,t1.id
#                             ,t1.call_num
#                             ,t1.diao_num
#                         from t t1
#                         where
#                             t1.phone_type = 'out_going'
#                             and t1.call_num > 5
#                     ) a2 on a1.phone = a2.phone and a1.staff_info_id = a2.staff_info_id and a1.pho_date = a2.pho_date and a2.phone_source = a1.phone_source
#                 where
#                     a2.routed_at > a1.routed_at
#                 group by 1,2,3,4
#             ) a3
#         group by 1,2,3
#     ) f3 on f3.staff_info_id = f1.staff_info_id and f3.phone_source = f1.phone_source and f3.pho_date = f1.pho_date
# left join backyard_pro.staff_work_attendance swa on swa.staff_info_id = f1.staff_info_id and swa.attendance_date = f1.pho_date
# where
#     swa.started_at is not null
#     or swa.end_at is not null
#     and hsi.formal = 1
#     and hsi.is_sub_staff = 0
#
# ;


with t as
    (
        select
             pr.id
            ,pr.pno
            ,swa.staff_info_id
            ,pi.src_phone
            ,pi.dst_phone
            ,json_extract(pr.extra_value, '$.phone') phone
            ,case
                when  json_extract(pr.extra_value, '$.phone') = pi.src_phone then'src'
                when json_extract(pr.extra_value, '$.phone') = pi.dst_phone then 'dst'
                else 'other'
            end phone_source
            ,case pr.route_action
                when 'PHONE' then 'out_going'
                when 'INCOMING_CALL' then 'in_coming'
             end as phone_type
            ,pr.routed_at
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pho_date
            ,swa.attendance_date
            ,cast(json_extract(pr.extra_value, '$.callDuration') as int) call_num -- 通话
            ,cast(json_extract(pr.extra_value, '$.diaboloDuration') as int) diao_num -- 响铃
        from  backyard_pro.staff_work_attendance swa
        left join rot_pro.parcel_route pr on swa.staff_info_id = pr.staff_info_id  and pr.routed_at >= date_sub('${s_date}', interval 7 hour) and pr.routed_at >= date_sub(swa.attendance_date, interval 7 hour) and pr.routed_at < date_add(swa.attendance_date, interval 17 hour) and pr.route_action in ('PHONE', 'INCOMING_CALL')
        left join fle_staging.parcel_info pi on pi.pno = pr.pno
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = swa.staff_info_id
        where
            swa.attendance_date >= '${s_date}'
            and swa.attendance_date <= '${e_date}'
            and swa.job_title in (13,110,452)
            and (swa.started_at is not null or swa.end_at is not null)
            and hsi.formal = 1
            and hsi.is_sub_staff = 0
    )
, cb as
    (
        select -- 回拨
            a1.staff_info_id
            ,a1.phone
            ,a1.attendance_date
            ,a2.call_num
            ,a2.diao_num
        from
            (
                select
                    t1.staff_info_id
                    ,t1.phone
                    ,t1.attendance_date
                    ,t1.routed_at
                from t t1
                where
                    t1.phone_type = 'in_coming'
                    and (t1.call_num is null or t1.call_num = 0) -- 未接通
            ) a1
        join
            (
                select
                    t1.staff_info_id
                    ,t1.routed_at
                    ,t1.attendance_date
                    ,t1.phone
                    ,t1.id
                    ,t1.call_num
                    ,t1.diao_num
                from t t1
                where
                    t1.phone_type = 'out_going'
                    -- and t1.call_num > 5
            ) a2 on a1.phone = a2.phone and a1.staff_info_id = a2.staff_info_id and a1.attendance_date = a2.attendance_date
        where
            a2.routed_at > a1.routed_at
        group by 1,2,3,4,5
    )
select
    a1.attendance_date 日期
    ,dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.staff_info_id 快递员id
    ,coalesce(hsi.mobile_company, hsi.mobile) 快递员号码
    ,coalesce(t1.incoming_count, 0) 来电次数
    ,coalesce(ci.incoming_count, 0) 有效接通次数
    ,coalesce(c2.incoming_count, 0) 有效回拨次数
    ,(coalesce(ci.incoming_count, 0) + coalesce(c2.incoming_count, 0))/coalesce(t1.incoming_count, 0) 有效接线率
    ,case
        when a2.staff_info_id is not null and (a2.incoming_count = 0 or a2.incoming_count is null) then '否'
        when a2.staff_info_id is not null and a2.incoming_count > 0 then '异常'
        when a2.staff_info_id is null and (coalesce(ci.incoming_count, 0) + coalesce(c2.incoming_count, 0))/coalesce(t1.incoming_count, 0) < 0.5 then '异常'
        when a2.staff_info_id is null and (coalesce(ci.incoming_count, 0) + coalesce(c2.incoming_count, 0))/coalesce(t1.incoming_count, 0) >= 0.5 then '否'
        else null
    end 是否异常
    ,a2.staff_info_id
    ,a2.incoming_count
from
    (
        select
            swa.attendance_date
            ,swa.staff_info_id
        from backyard_pro.staff_work_attendance swa
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = swa.staff_info_id
        where
            swa.attendance_date >= '${s_date}'
            and swa.attendance_date <= '${e_date}'
            and swa.job_title in (13,110,452)
            and hsi.formal = 1
            and hsi.is_sub_staff = 0
            and (swa.started_at is not null or swa.end_at is not null)
    ) a1
left join
    (
        select
            t1.staff_info_id
            ,t1.attendance_date
            ,count(distinct t1.phone) incoming_count
        from t t1
        where
            t1.phone_type = 'in_coming'
        group by 1,2
    ) t1 on a1.staff_info_id = t1.staff_info_id and a1.attendance_date = t1.attendance_date
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = hsi.sys_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            c3.staff_info_id
            ,c3.attendance_date
            ,count(c3.phone) incoming_count
        from
            (
                select  -- 有效回拨：呼入通话大于 8，回拨接通或者响铃大于 10
                    c1.staff_info_id
                   ,c1.phone
                   ,c1.attendance_date
                from cb c1
                where
                    c1.call_num > 0
                    or c1.diao_num >= 10
                group by 1,2,3

                union

                select
                    c1.staff_info_id
                    ,c1.phone
                    ,c1.attendance_date
                from cb c1
                join t t1 on t1.phone = c1.phone and t1.staff_info_id = c1.staff_info_id and t1.attendance_date = c1.attendance_date
                where
                    t1.call_num >= 8
                group by 1,2,3
            ) c3
        group by 1,2
    ) c2 on  c2.staff_info_id = a1.staff_info_id and c2.attendance_date = a1.attendance_date
left join
    (
        select
            t1.staff_info_id
            ,t1.pho_date
            ,count(distinct t1.phone) incoming_count
        from t t1
        left join cb c1 on c1.phone = t1.phone and c1.staff_info_id = t1.staff_info_id and c1.attendance_date = t1.pho_date
        where
            c1.phone is null
            and t1.phone_type = 'in_coming'
            and t1.call_num >= 8
        group by 1,2
    ) ci on ci.staff_info_id = a1.staff_info_id and  ci.pho_date = a1.attendance_date
left join
    (
        select
            a1.staff_info_id
           ,a1.attendance_date
           ,count(pr.id) incoming_count
        from
            (
                select
                    t1.staff_info_id
                    ,t1.attendance_date
                    ,count(distinct if(t1.phone_type = 'in_coming', t1.phone, null)) phone_count
                from t t1
                group by 1,2
                having (count(distinct if(t1.phone_type = 'in_coming', t1.phone, null)) = 0 or count(distinct if(t1.phone_type = 'in_coming', t1.phone, null)) is null)
            ) a1
        left join rot_pro.parcel_route pr on pr.routed_at > date_sub(curdate(), interval 1 month ) and pr.staff_info_id = a1.staff_info_id and pr.route_action in ( 'INCOMING_CALL') and pr.routed_at < date_add(a1.attendance_date, interval 7 hour) and pr.routed_at >= date_add(date_sub(a1.attendance_date, interval 7 day), interval 17 hour)
        group by 1,2
    ) a2 on a2.staff_info_id = a1.staff_info_id and a2.attendance_date = a1.attendance_date


;