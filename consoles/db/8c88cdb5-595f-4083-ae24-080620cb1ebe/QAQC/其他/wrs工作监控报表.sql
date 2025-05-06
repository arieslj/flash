select
    *
from
    (
        -- 身份证审核
        select
            '身份证审核' program_zh
            ,'Identification Audit' program_en
            ,'24H' time_limit
            ,os.date 日期
            ,t1.cnt 当日新增案例
            ,t2.cnt 当日处理案例
            ,t4.total_cnt 时间段内累计处理
            ,t3.cnt 时间段内待处理量
            ,t4.delay_cnt 时间段内超时案例
            ,t4.rate 时效
        from
            (
                select
                    os.date
                from tmpale.ods_th_dim_date os
                where
                    os.date >= '${sdate}'
                    and os.date <= '${edate}'
            ) os
        left join
            (
                select
                    date(convert_tz(car.created_at, '+00:00', '+07:00')) p_date
                    ,count(car.id) cnt
                from fle_staging.customer_approve_record car
                where
                    car.created_at > date_sub('${sdate}', interval 7 hour)
                    and car.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1
            ) t1 on t1.p_date = os.date
        left join
            (
                select
                    date(convert_tz(car.operated_at, '+00:00', '+07:00')) p_date
                    ,count(car.id) cnt
                from fle_staging.customer_approve_record car
                where
                    car.operated_at > date_sub('${sdate}', interval 7 hour)
                    and car.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and car.state in (1,2)
                group by 1
            ) t2 on t2.p_date = os.date
        cross join
            (
                select
                    count(car.id) cnt
                from fle_staging.customer_approve_record car
                where
                    car.created_at > date_sub('${sdate}', interval 7 hour)
                    and car.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and car.state in (0)
            ) t3
        cross join
            (
                select
                    count(if(timestampdiff(minute , car.created_at, car.operated_at)/60 >= 24, car.id, null)) delay_cnt
                    ,count(car.id) total_cnt
                    ,count(if(timestampdiff(minute, car.created_at, car.operated_at) /60 < 24, car.id, null)) / count(car.id) rate
                from fle_staging.customer_approve_record car
                where
                    car.operated_at > date_sub('${sdate}', interval 7 hour)
                    and car.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and car.state in (1,2)
            ) t4

        union all
        -- 强制拍照审核
        select
            '强制拍照审核' program_zh
            ,'Compulsory photo review' program_en
            ,'24H' time_limit
            ,os.date 日期
            ,t1.cnt 当日新增案例
            ,t2.cnt 当日处理案例
            ,t4.total_cnt 时间段内累计处理
            ,t3.cnt 时间段内待处理量
            ,t4.delay_cnt 时间段内超时案例
            ,t4.rate 时效
        from
            (
                select
                    os.date
                from tmpale.ods_th_dim_date os
                where
                    os.date >= '${sdate}'
                    and os.date <= '${edate}'
            ) os
        left join
            (
                select
                    date(convert_tz(fpa.created_at, '+00:00', '+07:00')) p_date
                    ,count(fpa.id) cnt
                from wrs_production.force_photo_audit fpa
                where
                    fpa.created_at > date_sub('${sdate}', interval 7 hour)
                    and fpa.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1
            ) t1 on t1.p_date = os.date
        left join
            (
                select
                    date(convert_tz(fpa.updated_at, '+00:00', '+07:00')) p_date
                    ,count(fpa.id) cnt
                from wrs_production.force_photo_audit fpa
                where
                    fpa.updated_at > date_sub('${sdate}', interval 7 hour)
                    and fpa.status in (2,3)
                    and fpa.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1
            ) t2 on t2.p_date = os.date
        cross join
            (
                select
                    count(fpa.id) cnt
                from wrs_production.force_photo_audit fpa
                where
                    fpa.created_at > date_sub('${sdate}', interval 7 hour)
                    and fpa.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and fpa.status in (0,1)
            ) t3
        cross join
            (
                select
                    count(if(timestampdiff(minute, fpa.created_at, fpa.updated_at)/60 > 24, fpa.id, null)) delay_cnt
                    ,count(fpa.id) total_cnt
                    ,count(if(timestampdiff(minute, fpa.created_at, fpa.updated_at)/60 <= 24, fpa.id, null)) / count(fpa.id) rate
                from wrs_production.force_photo_audit fpa
                where
                    fpa.updated_at > date_sub('${sdate}', interval 7 hour)
                    and fpa.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and fpa.status in (2,3)
            ) t4

        union all

        -- 称重审核
        select
            os.program_zh
            ,os.program_en
            ,'24H' time_limit
            ,os.date 日期
            ,t1.cnt 当日新增案例
            ,t2.cnt 当日处理案例
            ,t4.total_cnt 时间段内累计处理
            ,t3.cnt 时间段内待处理量
            ,t4.delay_cnt 时间段内超时案例
            ,t4.rate 时效
        from
            (
                select
                    os.date
                    ,rr.program_zh
                    ,rr.program_en
                from tmpale.ods_th_dim_date os
                cross join
                    (
                        select
                            case
                                when rr.reweight_type in (3,4,5,6) then '量方读数审核'
                                when rr.reweight_type in (1) then '称重读数审核'
                                when rr.reweight_type in (2) then '单号一致性审核'
                            end program_zh
                            ,case
                                when rr.reweight_type in (3,4,5,6) then 'Measure size'
                                when rr.reweight_type in (1) then 'Weighting'
                                when rr.reweight_type in (2) then 'Label leaf'
                            end program_en
                        from wrs_production.reweight_record rr
                        where
                            rr.created_at > date_sub('${sdate}', interval 7 hour)
                        group by 1,2
                    ) rr
                where
                    os.date >= '${sdate}'
                    and os.date <= '${edate}'
            ) os
        left join
            (
                select
                    date(convert_tz(rr.created_at, '+00:00', '+07:00')) p_date
                    ,case
                        when rr.reweight_type in (3,4,5,6) then '量方读数审核'
                        when rr.reweight_type in (1) then '称重读数审核'
                        when rr.reweight_type in (2) then '单号一致性审核'
                    end program_zh
                    ,case
                        when rr.reweight_type in (3,4,5,6) then 'Measure size'
                        when rr.reweight_type in (1) then 'Weighting'
                        when rr.reweight_type in (2) then 'Label leaf'
                    end program_en
                    ,count(rr.id) cnt
                from wrs_production.reweight_record rr
                where
                    rr.created_at > date_sub('${sdate}', interval 7 hour)
                    and rr.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1,2,3
            ) t1 on t1.p_date = os.date and t1.program_zh = os.program_zh
        left join
            (
                select
                    date(convert_tz(rr.updated_at, '+00:00', '+07:00')) p_date
                    ,case
                        when rr.reweight_type in (3,4,5,6) then '量方读数审核'
                        when rr.reweight_type in (1) then '称重读数审核'
                        when rr.reweight_type in (2) then '单号一致性审核'
                    end program_zh
                    ,case
                        when rr.reweight_type in (3,4,5,6) then 'Measure size'
                        when rr.reweight_type in (1) then 'Weighting'
                        when rr.reweight_type in (2) then 'Label leaf'
                    end program_en
                    ,count(rr.id) cnt
                from wrs_production.reweight_record rr
                where
                    rr.updated_at > date_sub('${sdate}', interval 7 hour)
                    and rr.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and rr.status = 2
                group by 1,2,3
            ) t2 on t2.p_date = os.date and t2.program_zh = os.program_zh
        left join
            (
                select
                    case
                        when rr.reweight_type in (3,4,5,6) then '量方读数审核'
                        when rr.reweight_type in (1) then '称重读数审核'
                        when rr.reweight_type in (2) then '单号一致性审核'
                    end program_zh
                    ,case
                        when rr.reweight_type in (3,4,5,6) then 'Measure size'
                        when rr.reweight_type in (1) then 'Weighting'
                        when rr.reweight_type in (2) then 'Label leaf'
                    end program_en
                    ,count(rr.id) cnt
                from wrs_production.reweight_record rr
                where
                    rr.created_at > date_sub('${sdate}', interval 7 hour)
                    and rr.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and rr.status in (0,1)
                group by 1,2
            ) t3 on t3.program_zh = os.program_zh
        left join
            (
                select
                    case
                        when rr.reweight_type in (3,4,5,6) then '量方读数审核'
                        when rr.reweight_type in (1) then '称重读数审核'
                        when rr.reweight_type in (2) then '单号一致性审核'
                    end program_zh
                    ,case
                        when rr.reweight_type in (3,4,5,6) then 'Measure size'
                        when rr.reweight_type in (1) then 'Weighting'
                        when rr.reweight_type in (2) then 'Label leaf'
                    end program_en
                    ,count(if(timestampdiff(minute, rr.created_at, rr.updated_at)/60 > 24, rr.id, null)) delay_cnt
                    ,count(rr.id) total_cnt
                    ,count(if(timestampdiff(minute, rr.created_at, rr.updated_at)/60 <= 24, rr.id, null)) / count(rr.id) rate
                from wrs_production.reweight_record rr
                where
                    rr.updated_at > date_sub('${sdate}', interval 7 hour)
                    and rr.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and rr.status = 2
                group by 1,2
            ) t4 on t4.program_zh = os.program_zh

        union all
        -- 拒收审核
        select
            '包裹拒收验证和审查' program_zh
            ,'Rejection Verification and Review' program_en
            ,'24H' time_limit
            ,os.date 日期
            ,t1.cnt 当日新增案例
            ,t2.cnt 当日处理案例
            ,t4.total_cnt 时间段内累计处理
            ,t3.cnt 时间段内待处理量
            ,t4.delay_cnt 时间段内超时案例
            ,t4.rate 时效
        from
            (
                select
                    os.date
                from tmpale.ods_th_dim_date os
                where
                    os.date >= '${sdate}'
                    and os.date <= '${edate}'
            ) os
        left join
            (
                select
                    date(convert_tz(ra.created_at, '+00:00', '+07:00')) p_date
                    ,count(ra.id) cnt
                from wrs_production.reject_audit ra
                where
                    ra.created_at > date_sub('${sdate}', interval 7 hour)
                    and ra.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
            ) t1 on t1.p_date = os.date
        left join
            (
                select
                    date(convert_tz(ra.updated_at, '+00:00', '+07:00')) p_date
                    ,count(ra.id) cnt
                from wrs_production.reject_audit ra
                where
                    ra.updated_at > date_sub('${sdate}', interval 7 hour)
                    and ra.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and ra.status in (2,3)
            ) t2 on t2.p_date = os.date
        cross join
            (
                select
                    count(ra.id) cnt
                from wrs_production.reject_audit ra
                where
                    ra.created_at > date_sub('${sdate}', interval 7 hour)
                    and ra.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and ra.status in (0,1)
            ) t3
        cross join
            (
                select
                    count(if(timestampdiff(minute, ra.created_at, ra.updated_at)/60 > 24, ra.id, null)) delay_cnt
                    ,count(ra.id) total_cnt
                    ,count(if(timestampdiff(minute, ra.created_at, ra.updated_at)/60 <= 24, ra.id, null)) / count(ra.id) rate
                from wrs_production.reject_audit ra
                where
                    ra.updated_at > date_sub('${sdate}', interval 7 hour)
                    and ra.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and ra.status in (2,3)
            ) t4

        union all
        -- EPOP审核 epop_audit_record
        select
            'EPOP审核' program_zh
            ,'EPOP' program_en
            ,'24H' time_limit
            ,os.date 日期
            ,t1.cnt 当日新增案例
            ,t2.cnt 当日处理案例
            ,t4.total_cnt 时间段内累计处理
            ,t3.cnt 时间段内待处理量
            ,t4.delay_cnt 时间段内超时案例
            ,t4.rate 时效
        from
            (
                select
                    os.date
                from tmpale.ods_th_dim_date os
                where
                    os.date >= '${sdate}'
                    and os.date <= '${edate}'
            ) os
        left join
            (
                select
                    date(convert_tz(ear.task_cancel_time, '+00:00', '+07:00')) p_date
                    ,count(ear.id) cnt
                from wrs_production.epop_audit_record ear
                where
                    ear.task_cancel_time > date_sub('${sdate}', interval 7 hour)
                    and ear.task_cancel_time < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1
            ) t1 on t1.p_date = os.date
        left join
            (
                select
                    date(convert_tz(ear.updated_at, '+00:00', '+07:00')) p_date
                    ,count(ear.id) cnt
                from wrs_production.epop_audit_record ear
                where
                    ear.updated_at > date_sub('${sdate}', interval 7 hour)
                    and ear.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and ear.status in (2)
                group by 1
            ) t2 on t2.p_date = os.date
        cross join
            (
                select
                    count(ear.id) cnt
                from wrs_production.epop_audit_record ear
                where
                    ear.task_cancel_time > date_sub('${sdate}', interval 7 hour)
                    and ear.task_cancel_time < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and ear.status in (0,1)
            ) t3
        cross join
            (
                select
                    count(if(timestampdiff(minute , ear.task_cancel_time, ear.updated_at)/60 > 24, ear.id, null)) delay_cnt
                    ,count(ear.id) total_cnt
                    ,count(if(timestampdiff(minute , ear.task_cancel_time, ear.updated_at)/60 <= 24, ear.id, null)) / count(ear.id) rate
                from wrs_production.epop_audit_record ear
                where
                    ear.updated_at > date_sub('${sdate}', interval 7 hour)
                    and ear.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and ear.status in (2)
            ) t4

        union all
        -- 呼叫访问验证
        select
            '呼叫访问验证' program_zh
            ,'AI call Visit Verifcation' program_en
            ,'24H' time_limit
            ,os.date 日期
            ,t1.cnt 当日新增案例
            ,t2.cnt 当日处理案例
            ,t4.total_cnt 时间段内累计处理
            ,t3.cnt 时间段内待处理量
            ,t4.delay_cnt 时间段内超时案例
            ,t4.rate 时效
        from
            (
                select
                    os.date
                from tmpale.ods_th_dim_date os
                where
                    os.date >= '${sdate}'
                    and os.date <= '${edate}'
            ) os
        left join
            (
                select
                    date(convert_tz(ia.created_at, '+00:00', '+07:00')) p_date
                    ,count(ia.id) cnt
                from wrs_production.ivr_audit ia
                where
                    ia.created_at > date_sub('${sdate}', interval 7 hour)
                    and ia.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1
            ) t1 on t1.p_date = os.date
        left join
            (
                select
                    date(convert_tz(ia.updated_at, '+00:00', '+07:00')) p_date
                    ,count(ia.id) cnt
                from wrs_production.ivr_audit ia
                where
                    ia.updated_at > date_sub('${sdate}', interval 7 hour)
                    and ia.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and ia.status in (2)
                group by 1
            ) t2 on t2.p_date = os.date
        cross join
            (
                select
                    count(ia.id) cnt
                from wrs_production.ivr_audit ia
                where
                    ia.created_at > date_sub('${sdate}', interval 7 hour)
                    and ia.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and ia.status in (0,1)
            ) t3
        cross join
            (
                select
                    count(if(timestampdiff(minute, ia.created_at, ia.updated_at)/60 > 24, ia.id, null)) delay_cnt
                    ,count(ia.id) total_cnt
                    ,count(if(timestampdiff(minute, ia.created_at, ia.updated_at)/60 <= 24, ia.id, null)) / count(ia.id) rate
                from wrs_production.ivr_audit ia
                where
                    ia.updated_at > date_sub('${sdate}', interval 7 hour)
                    and ia.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and ia.status in (2)
            ) t4

        union all

        select
            '补单录入WRS' program_zh
            ,'WRS' program_en
            ,'24H' time_limit
            ,os.date 日期
            ,t1.cnt 当日新增案例
            ,t2.cnt 当日处理案例
            ,t4.total_cnt 时间段内累计处理
            ,t3.cnt 时间段内待处理量
            ,t4.delay_cnt 时间段内超时案例
            ,t4.rate 时效
        from
            (
                select
                    os.date
                from tmpale.ods_th_dim_date os
                where
                    os.date >= '${sdate}'
                    and os.date <= '${edate}'
            ) os
        left join
            (
                select
                    date(convert_tz(pf.created_at, '+00:00', '+07:00')) p_date
                    ,count(pf.id) cnt
                from wrs_production.pkg_form pf
                where
                    pf.created_at > date_sub('${sdate}', interval 7 hour)
                    and pf.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1
            ) t1 on t1.p_date = os.date
        left join
            (
                select
                    date (convert_tz(pf.updated_at, '+00:00', '+07:00')) p_date
                    ,count(pf.id) cnt
                from wrs_production.pkg_form pf
                where
                    pf.status in (3,4)
                    and pf.updated_at > date_sub('${sdate}', interval 7 hour)
                    and pf.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1
            ) t2 on t2.p_date = os.date
        cross join
            (
                select
                    count(pf.id) cnt
                from wrs_production.pkg_form pf
                where
                    pf.created_at > date_sub('${sdate}', interval 7 hour)
                    and pf.created_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                    and pf.status not in (3,4)
            ) t3
        cross join
            (
                select
                    count(pf.id) total_cnt
                    ,count(if(timestampdiff(minute, pf.created_at, pf.updated_at)/60 > 24, pf.id, null)) delay_cnt
                    ,count(if(timestampdiff(minute, pf.created_at, pf.updated_at)/60 <= 24, pf.id, null)) / count(pf.id) rate
                from wrs_production.pkg_form pf
                where
                    pf.status in (3,4)
                    and pf.updated_at > date_sub('${sdate}', interval 7 hour)
                    and pf.updated_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
            ) t4

        union all

        select
            '补单录入Audit' program_zh
            ,'Audit' program_en
            ,'24H' time_limit
            ,os.date 日期
            ,t1.cnt 当日新增案例
            ,t2.cnt 当日处理案例
            ,t4.total_cnt 时间段内累计处理
            ,t3.cnt 时间段内待处理量
            ,t4.delay_cnt 时间段内超时案例
            ,t4.rate 时效
        from
            (
                select
                    os.date
                from tmpale.ods_th_dim_date os
                where
                    os.date >= '${sdate}'
                    and os.date <= '${edate}'
            ) os
        left join
            (
                select
                    date(convert_tz(pfi.input_end, '+00:00', '+07:00')) p_date
                    ,count(pfi.id) cnt
                from wrs_production.pkg_form_input pfi
                where
                    pfi.status = 3
                    and pfi.input_end > date_sub('${sdate}', interval 7 hour)
                    and pfi.input_end < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1
            ) t1 on t1.p_date = os.date
        left join
            (
                select
                   date(convert_tz(pfi.audit_at, '+00:00', '+07:00')) p_date
                    ,count(pfi.id) cnt
                from wrs_production.pkg_form_input pfi
                where
                    pfi.audit_status in (3,4)
                    and pfi.status = 3
                    and pfi.audit_at > date_sub('${sdate}', interval 7 hour)
                    and pfi.audit_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
                group by 1
            ) t2 on t2.p_date = os.date
        cross join
            (
                select
                    count(pfi.id) cnt
                from wrs_production.pkg_form_input pfi
                where
                    pfi.status = 3
                    and pfi.audit_status != 3
                    and pfi.input_end > date_sub('${sdate}', interval 7 hour)
                    and pfi.input_end < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
            ) t3
        cross join
            (
                select
                    count(pfi.id) total_cnt
                    ,count(if(timestampdiff(minute, pfi.input_end, pfi.audit_at)/60 > 24, pfi.id, null)) delay_cnt
                    ,count(if(timestampdiff(minute, pfi.input_end, pfi.audit_at)/60 <= 24, pfi.id, null)) / count(pfi.id) rate
                from wrs_production.pkg_form_input pfi
                where
                    pfi.status = 3
                    and pfi.audit_status in (3,4)
                    and pfi.audit_at > date_sub('${sdate}', interval 7 hour)
                    and pfi.audit_at < date_add(date_sub('${edate}', interval 7 hour), interval 1 day)
            ) t4
    ) a
order by a.program_zh, a.日期