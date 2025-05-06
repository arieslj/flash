-- 外呼
select
#     a1.团队回访率
    a2.WRS审核完成率
#     ,a3.揽件任务异常取消
    ,a4.派送类及其他回访
from
#     (
#         select
#             count(if(a1.fir_replay_at < a1.dead_line_time, a1.id, null)) / count(a1.id) 团队回访率
#         #     count(if(a1.fir_replay_at < a1.dead_line_time, a1.id, null)) as call_in_time_count
#         #     ,count(a1.id) total_count
#         from
#             (
#                 select -- 19-19回访任务在当日有回访
#                     a.id
#                     ,a.task_created_at
#                     ,date_add(date(date_add(a.task_created_at, interval 7 hour)), interval 1 day) dead_line_time
#                     ,a.fir_replay_at
#                 from
#                     (
#                         select -- 客户是否原谅道歉
#                             acc.id
#                             ,acc.store_callback_at task_created_at
#                             ,crl.created_at fir_replay_at
#                         from
#                             (
#                                 select
#                                     acc.id
#                                     ,acc.store_callback_at
#                                 from my_bi.abnormal_customer_complaint acc
#                                 where
#                                     acc.store_callback_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
#                                     and acc.store_callback_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
#                             ) acc
#                         left join
#                             (
#                                 select
#                                     acc.id
#                                     ,crl.created_at
#                                     ,row_number() over (partition by acc.id order by crl.created_at) rk
#                                 from my_bi.abnormal_customer_complaint acc
#                                 join my_bi.complaint_replay_log crl on crl.complaint_id = acc.id
#                                 where
#                                     acc.store_callback_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
#                                     and acc.store_callback_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
#                             )  crl on crl.id = acc.id and crl.rk = 1
#
#                         union all
#
#                         select -- 未收到包裹回访
#                             pci.id
#                             ,pci.qaqc_created_at task_created_at
#                             ,pci.qaqc_callback_at fir_replay_at
#                         from my_bi.parcel_complaint_inquiry pci
#                         where
#                             pci.qaqc_created_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
#                             and pci.qaqc_created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
#
#                         union all
#
#                         select
#                             vrv.id
#                             ,vrv.created_at task_created_at
#                             ,if(vrv.visit_state > 1, vrv.updated_at, null) fir_replay_at
#                         from my_nl.violation_return_visit vrv
#                         left join my_nl.violation_return_visit vrv2 on vrv2.id = vrv.id and vrv2.type = 4 and vrv2.client_id in ('AA0066','AA0178','AA0061','AA0175','AA0068','AA0185','AA0060','AA0062','AA0177') and vrv2.visit_staff_id not in (10001, 10000) and vrv2.gain_way = 2 and vrv2.created_at >  date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
#                         where
#                             vrv.type in (2,3,4)
#                             and vrv.created_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
#                             and vrv.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
#                             and ( vrv.visit_staff_id not in (10001,10002,10000) and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 )) -- 应人工回访
#                             and vrv.gain_way = 1
#                             and vrv2.id is null
#
#                         union all
#
#                         select
#                             vrv.id
#                             ,vrv.created_at task_created_at
#                             ,if(vrv.visit_state > 1, vrv.updated_at, null) fir_replay_at
#                         from my_nl.violation_return_visit vrv
#                         where
#                             vrv.type in (1)
#                             and vrv.data_source = 49 -- EPOP审核不通过
#                             and vrv.created_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
#                             and vrv.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
#                             and ( vrv.visit_staff_id not in (10001,10002,10000) and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 )) -- 应人工回访
#                             and vrv.gain_way = 1
#                     ) a
#             ) a1
#     ) a1
# cross join
    (
        -- WRS审核完成率
        select
        #     count(a.id) total_count
        #     ,count(if(a.deal_time < a.dead_line_time, a.id, null)) in_time_count
            count(if(a.deal_time < a.dead_line_time, a.id, null)) / count(a.id) WRS审核完成率
        from
            (
                select -- 揽收取消审核
                    ear.id
                    ,convert_tz(ear.input_begin, '+00:00', '+08:00') task_created_at
                    ,date_add(date_add(date(date_add(ear.input_begin, interval 14 hour)), interval 18 hour), interval 5 minute) dead_line_time
                    ,convert_tz(ear.input_end, '+00:00', '+08:00') deal_time
                from my_wrs.epop_audit_record ear
                where
                    ear.input_begin > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 14 hour) -- 0时区
                    and  ear.input_begin < date_sub(date_format(curdate(), '%Y-%m-01'), interval 14 hour)

                union all

                select -- 拒收审核
                    ra.id
                    ,convert_tz(ra.input_begin, '+00:00', '+08:00') task_created_at
                    ,date_add(date_add(date(date_add(ra.input_begin, interval 14 hour)), interval 18 hour), interval 5 minute) dead_line_time
                    ,convert_tz(ra.input_end, '+00:00', '+08:00') deal_time
                from my_wrs.reject_audit ra
                where
                    ra.input_begin > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 14 hour) -- 0时区
                    and  ra.input_begin < date_sub(date_format(curdate(), '%Y-%m-01'), interval 14 hour)

                union all

                select -- 留仓审核
                    waa.id
                    ,convert_tz(waa.input_begin, '+00:00', '+08:00') task_created_at
                    ,date_add(date_add(date(date_add(waa.input_begin, interval 14 hour)), interval 18 hour), interval 5 minute) dead_line_time
                    ,convert_tz(waa.input_end, '+00:00', '+08:00') deal_time
                from my_wrs.whats_app_audit waa
                where
                    waa.input_begin > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 14 hour)
                    and waa.input_begin < date_sub(date_format(curdate(), '%Y-%m-01'), interval 14 hour)
            ) a
    ) a2
# cross join
#     (
#         -- 揽件任务异常取消
#         select
#             count(if(a1.fir_replay_at < a1.dead_line_time, a1.id, null)) / count(a1.id) 揽件任务异常取消
#         #     ,count(if(a1.fir_replay_at < a1.dead_line_time, a1.id, null)) as call_in_time_count
#         #     ,count(a1.id) total_count
#         from
#             (
#                 select
#                     a.id
#                     ,a.task_created_at
#                     ,date_add(date(date_add(a.task_created_at, interval 7 hour)), interval 1 day) dead_line_time
#                     ,a.fir_replay_at
#                 from
#                     (
#                         select
#                             vrv.id
#                             ,vrv.created_at task_created_at
#                             ,if(vrv.visit_state > 1, vrv.updated_at, null) fir_replay_at
#                         from my_nl.violation_return_visit vrv
#                         where
#                             vrv.type in (1)
#                             and vrv.data_source = 49 -- EPOP 审核不通过
#                             and vrv.created_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
#                             and vrv.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
#                             and ( vrv.visit_staff_id != 10001 and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ))
#                     ) a
#             ) a1
#     ) a3
cross join
    (
                -- 派送类及其他回访
        select
            count(if(a1.fir_replay_at < a1.dead_line_time, a1.id, null)) / count(a1.id) 派送类及其他回访
        #     ,count(if(a1.fir_replay_at < a1.dead_line_time, a1.id, null)) as call_in_time_count
        #     ,count(a1.id) total_count
        from
            (
                select -- 19-19回访任务在当日有回访
                    a.id
                    ,a.task_created_at
                    ,date_add(date(date_add(a.task_created_at, interval 7 hour)), interval 1 day) dead_line_time
                    ,a.fir_replay_at
                from
                    (
                        select -- 客户是否原谅道歉
                            acc.id
                            ,acc.store_callback_at task_created_at
                            ,crl.created_at fir_replay_at
                        from
                            (
                                select
                                    acc.id
                                    ,acc.store_callback_at
                                from my_bi.abnormal_customer_complaint acc
                                where
                                    acc.store_callback_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
                                    and acc.store_callback_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
                            ) acc
                        left join
                            (
                                select
                                    acc.id
                                    ,crl.created_at
                                    ,row_number() over (partition by acc.id order by crl.created_at) rk
                                from my_bi.abnormal_customer_complaint acc
                                join my_bi.complaint_replay_log crl on crl.complaint_id = acc.id
                                where
                                    acc.store_callback_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
                                    and acc.store_callback_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
                            )  crl on crl.id = acc.id and crl.rk = 1

                        union all

                        select -- 未收到包裹回访
                            pci.id
                            ,pci.qaqc_created_at task_created_at
                            ,pci.qaqc_callback_at fir_replay_at
                        from my_bi.parcel_complaint_inquiry pci
                        where
                            pci.qaqc_created_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
                            and pci.qaqc_created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)

                        union all

                        select
                            vrv.id
                            ,vrv.created_at task_created_at
                            ,if(vrv.visit_state > 1, vrv.updated_at, null) fir_replay_at
                        from my_nl.violation_return_visit vrv
                        left join my_nl.violation_return_visit vrv2 on vrv2.id = vrv.id and vrv2.type = 4 and vrv2.client_id in ('AA0066','AA0178','AA0061','AA0175','AA0068','AA0185','AA0060','AA0062','AA0177') and vrv2.visit_staff_id not in (10001, 10000) and vrv2.gain_way = 2 and vrv2.created_at >  date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
                        where
                            vrv.type in (2,3,4)
                            and vrv.created_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
                            and vrv.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
                            and ( vrv.visit_staff_id not in (10001, 10002,10000)  and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ))
                            and vrv2.id is null
                            and vrv.gain_way = 1
                    ) a
            ) a1
    ) a4




;



select -- 19-19回访任务在当日有回访
                    a.id
                    ,a.pno
                    ,a.type
                    ,a.task_created_at
                    ,date_add(date(date_add(a.task_created_at, interval 7 hour)), interval 1 day) dead_line_time
                    ,a.fir_replay_at
                from
                    (
                        select -- 客户是否原谅道歉
                            acc.id
                            ,acc.pno
                            ,acc.store_callback_at task_created_at
                            ,crl.created_at fir_replay_at
                            ,'客户是否原谅道歉' type
                        from
                            (
                                select
                                    acc.id
                                    ,acc.store_callback_at
                                    ,acc.pno
                                from my_bi.abnormal_customer_complaint acc
                                where
                                    acc.store_callback_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
                                    and acc.store_callback_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
                            ) acc
                        left join
                            (
                                select
                                    acc.id
                                    ,crl.created_at
                                    ,row_number() over (partition by acc.id order by crl.created_at) rk
                                from my_bi.abnormal_customer_complaint acc
                                join my_bi.complaint_replay_log crl on crl.complaint_id = acc.id
                                where
                                    acc.store_callback_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
                                    and acc.store_callback_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
                            )  crl on crl.id = acc.id and crl.rk = 1

                        union all

                        select -- 未收到包裹回访
                            pci.id
                            ,pci.merge_column pno
                            ,pci.qaqc_created_at task_created_at
                            ,pci.qaqc_callback_at fir_replay_at
                            ,'未收到包裹回访' type
                        from my_bi.parcel_complaint_inquiry pci
                        where
                            pci.qaqc_created_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
                            and pci.qaqc_created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)

                        union all

                        select
                            vrv.id
                            ,vrv.link_id pno
                            ,vrv.created_at task_created_at
                            ,if(vrv.visit_state > 1, vrv.updated_at, null) fir_replay_at
                            ,'疑似违规回访' type
                        from my_nl.violation_return_visit vrv
                        left join my_nl.violation_return_visit vrv2 on vrv2.id = vrv.id and vrv2.type = 4 and vrv2.client_id in ('AA0066','AA0178','AA0061','AA0175','AA0068','AA0185','AA0060','AA0062','AA0177') and vrv2.visit_staff_id not in (10001, 10000) and vrv2.gain_way = 2 and vrv2.created_at >  date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
                        where
                            vrv.type in (2,3,4)
                            and vrv.created_at > date_sub(date_format(date_sub(curdate(), interval 1 month), '%Y-%m-01'), interval 7 hour)
                            and vrv.created_at < date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour)
                            and ( vrv.visit_staff_id not in (10001, 10002,10000)  and ( vrv.visit_staff_id != 0 or vrv.visit_state != 2 ))
                            and vrv2.id is null
                            and vrv.gain_way = 1
                        ) a