
with t as
    (
        select
            plt.id
            ,plt.created_at
            ,date(plt.created_at) plt_date
            ,plt.source
            ,plt.state
            ,plt.operator_id
            ,plt.pno
            ,plt.updated_at
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at >= '${date}'
            and plt.created_at < date_add('${date}', interval 1 day)
    )
select
    a1.plt_date 日期
    ,case a1.source
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
    ,a1.all_num 当日生成的任务总量
    ,a2.all_num 任务重复量
    ,a1.wait_deal_num 待处理的任务总量
    ,a1.dealed_num 当日已判责的任务量
    ,a1.noneed_deal_num 当日无需追责的任务量
    ,a1.auto_no_deal_num 当日系统自动处理的量
    ,a1.deal_with_order_num 当日已发工单未判责的任务量
    ,a1.deal_ratio 处理进度
    ,ag90.ag90_num '待处理任务总量（90天内）'
    ,ag1.plt_num aging1天未处理量
    ,ag2.plt_num aging2天未处理量
    ,ag3.plt_num aging3天未处理量
    ,ag4.plt_num aging4天未处理量
    ,ag5_10.plt_num 'aging5-10天未处理量'
    ,ag11_30.plt_num 'aging11-30天未处理量'
    ,ag30.plt_num aging30天以上未处理量
    ,pcol.today_duty_num 本日已判责的任务量
    ,pcol3.today_no_duty_num 本日无需追责的任务量
    ,pcol4.today_auto_deal_num 本日系统自动处理的量
    ,pcol2.today_order_no_deal_num 本日已发工单未判责的任务量
    ,ag90.ag90_backlog_remaining_num 剩余积压量
    ,ag90.backlog_deal_progress 积压任务处理进度
    ,per.per_ratio 整体时效内达成率
from
    (
        select
            t1.plt_date
            ,t1.source
            ,count(t1.id) all_num
            ,count(if(t1.state in (1,2), t1.id, null)) wait_deal_num
            ,count(if(t1.state in (6), t1.id, null)) dealed_num
            ,count(if(t1.state in (5), t1.id, null)) noneed_deal_num
            ,count(if(t1.state = 5 and t1.operator_id in (10000,10001), null)) auto_no_deal_num
            ,count(if(t1.state in (3,4), t1.id, null)) deal_with_order_num
            ,count(if(t1.state in (3,4,5,6), t1.id, null))/count(t1.id) deal_ratio
        from t t1
        group by 1,2
    ) a1
left join
    (
        select
            t1.plt_date
            ,t1.source
            ,count(distinct t1.id) all_num
        from bi_pro.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 6
            and plt.updated_at < t1.created_at
        group by 1,2
    ) a2 on a2.plt_date = a1.plt_date and a2.source = a1.source
left join
    (
        select
            '${date}' p_date
            ,plt.source
            ,count(distinct plt.id) plt_num
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at <  date_add('${date}', interval 1 day)
            and plt.state in (1,2,3,4)
        group by 1,2
    ) a3 on a3.p_date = a1.plt_date and a3.source = a1.source
left join
    (
        select
            '${date}' p_date
            ,plt.source
            ,count(distinct plt.id) plt_num
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at <  date_sub('${date}', interval 0 day)
            and plt.created_at >= date_sub('${date}', interval 1 day)
            and plt.state in (1,2)
        group by 1,2
    ) ag1 on ag1.p_date = a1.plt_date and ag1.source = a1.source
left join
    (
        select
            '${date}' p_date
           ,plt.source
           ,count(distinct plt.id) plt_num
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at <  date_sub('${date}', interval 1 day)
            and plt.created_at >= date_sub('${date}', interval 2 day)
            and plt.state in (1,2)
        group by 1,2
    ) ag2 on ag2.p_date = a1.plt_date and ag2.source = a1.source
left join
    (
        select
            '${date}' p_date
           ,plt.source
           ,count(distinct plt.id) plt_num
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at <  date_sub('${date}', interval 2 day)
            and plt.created_at >= date_sub('${date}', interval 3 day)
            and plt.state in (1,2)
        group by 1,2
    ) ag3 on ag3.p_date = a1.plt_date and ag3.source = a1.source
left join
    (
        select
            '${date}' p_date
          ,plt.source
          ,count(distinct plt.id) plt_num
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at <  date_sub('${date}', interval 3 day)
            and plt.created_at >= date_sub('${date}', interval 4 day)
            and plt.state in (1,2)
        group by 1,2
    ) ag4 on ag4.p_date = a1.plt_date and ag4.source = a1.source
left join
        (
            select
                '${date}' p_date
                ,plt.source
                ,count(distinct plt.id) plt_num
            from bi_pro.parcel_lose_task plt
            where
                plt.created_at <  date_sub('${date}', interval 4 day)
                and plt.created_at >= date_sub('${date}', interval 9 day)
                and plt.state in (1,2)
            group by 1,2
    ) ag5_10 on ag5_10.p_date = a1.plt_date and ag5_10.source = a1.source
left join
    (
        select
            '${date}' p_date
           ,plt.source
           ,count(distinct plt.id) plt_num
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at <  date_sub('${date}', interval 9 day)
            and plt.created_at >= date_sub('${date}', interval 29 day)
            and plt.state in (1,2)
        group by 1,2
    ) ag11_30 on ag11_30.p_date = a1.plt_date and ag11_30.source = a1.source
left join
    (
        select
            '${date}' p_date
           ,plt.source
           ,count(distinct plt.id) plt_num
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at <  date_sub('${date}', interval 29 day)
            and plt.state in (1,2)
        group by 1,2
    ) ag30 on ag30.p_date = a1.plt_date and ag30.source = a1.source
left join
    (
        select
            '${date}' p_date
            ,plt.source
            ,count(distinct if(pcol.action = 4, pcol.task_id, null)) today_duty_num
        from bi_pro.parcel_cs_operation_log pcol
        left join bi_pro.parcel_lose_task plt on pcol.task_id = plt.id
        where
            pcol.created_at >= '${date}'
            and pcol.created_at < date_add('${date}', interval 1 day)
            and pcol.type = 1 -- 闪速认定
            and plt.created_at <  '${date}'
        group by 1,2
    ) pcol on pcol.p_date = a1.plt_date and pcol.source = a1.source
left join
    (
        select
            a1.p_date
            ,a1.source
            ,count(distinct a1.id) today_order_no_deal_num
        from
            (
                select
                    '${date}' p_date
                    ,plt.source
                    ,plt.id
                from bi_pro.parcel_cs_operation_log pcol
                left join bi_pro.parcel_lose_task plt on pcol.task_id = plt.id
                where
                    pcol.created_at >= '${date}'
                    and pcol.created_at < date_add('${date}', interval 1 day)
                    and pcol.type = 1 -- 闪速认定
                    and plt.created_at <  '${date}'
                    and pcol.action = 1 -- 发工单
            ) a1
        left join
            (
                select
                    '${date}' p_date
                   ,plt.source
                   ,plt.id
                from bi_pro.parcel_cs_operation_log pcol
                left join bi_pro.parcel_lose_task plt on pcol.task_id = plt.id
                where
                    pcol.created_at >= '${date}'
                    and pcol.created_at < date_add('${date}', interval 1 day)
                    and pcol.type = 1 -- 闪速认定
                    and plt.created_at <  '${date}'
                    and pcol.action in (3,4) -- 判责/无责
            ) a2 on a2.id = a1.id
        where
            a2.id is null
        group by 1,2
    ) pcol2 on pcol2.p_date = a1.plt_date and pcol2.source = a1.source
left join
    (
        select
            a1.p_date
            ,a1.source
            ,count(distinct a1.id) today_no_duty_num
        from
            (
                select
                    '${date}' p_date
                    ,plt.source
                    ,plt.id
                from bi_pro.parcel_cs_operation_log pcol
                left join bi_pro.parcel_lose_task plt on pcol.task_id = plt.id
                where
                    pcol.created_at >= '${date}'
                    and pcol.created_at < date_add('${date}', interval 1 day)
                    and pcol.type = 1 -- 闪速认定
                    and pcol.action = 3 -- 无责
                    and plt.created_at <  '${date}'

                union

                select
                    '${date}' p_date
                    ,plt.source
                    ,plt.id
                from bi_pro.parcel_lose_task plt
                where
                    plt.created_at <  '${date}'
                    and plt.state = 5
                    and plt.updated_at >= '${date}'
                    and plt.updated_at < date_add('${date}', interval 1 day)
                    and plt.operator_id in (10000,10001)
            ) a1
        group by 1,2
    ) pcol3 on pcol3.p_date = a1.plt_date and pcol3.source = a1.source
left join
    (
        select
            a1.p_date
            ,a1.source
            ,count(distinct a1.id) today_auto_deal_num
        from
            (
                select
                     '${date}' p_date
                    ,plt.source
                    ,plt.id
                from bi_pro.parcel_cs_operation_log pcol
                left join bi_pro.parcel_lose_task plt on pcol.task_id = plt.id
                where
                    pcol.created_at >= '${date}'
                    and pcol.created_at < date_add('${date}', interval 1 day)
                    and pcol.type = 1 -- 闪速认定
                    and pcol.operator_id in (10000,10001) -- 自动
                    and plt.created_at <  '${date}'

                union

                select
                    '${date}' p_date
                    ,plt.source
                    ,plt.id
                from bi_pro.parcel_lose_task plt
                where
                    plt.created_at <  '${date}'
                    and plt.state = 5
                    and plt.updated_at >= '${date}'
                    and plt.updated_at < date_add('${date}', interval 1 day)
                    and plt.operator_id in (10000,10001)
            ) a1
        group by 1,2
    ) pcol4 on pcol4.p_date = a1.plt_date and pcol4.source = a1.source
left join
    (
        select
            a1.p_date
            ,a1.source
            ,count(distinct a1.id) ag90_num
            ,count(distinct if(a1.pcol_time is null, a1.id, null)) ag90_backlog_remaining_num
            ,count(distinct if(a1.pcol_time is not null, a1.id, null))/count(distinct a1.id) backlog_deal_progress
        from
            (
                select
                    '${date}' p_date
                    ,plt.source
                    ,plt.id
                    ,plt.created_at
                    ,plt.state
                    ,min(pcol.created_at) pcol_time
                from bi_pro.parcel_lose_task plt
                left join bi_pro.parcel_cs_operation_log pcol on pcol.task_id = plt.id
                where
                    plt.created_at < '${date}'
                    and plt.created_at >= date_sub('${date}', interval 89 day)
                group by 1,2,3,4,5
            ) a1
        where
            if(a1.state in (1,2), 1 = 1, a1.pcol_time >= '${date}')
        group by 1,2
    ) ag90 on ag90.p_date = a1.plt_date and ag90.source = a1.source
left join
    (
        select
            '${date}' plt_date
            ,plt.source
            ,count(distinct if(plt.state in (5,6), plt.id, null))/count(distinct plt.id) per_ratio
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at >= date_sub('${date}', interval 4 day)
            and plt.created_at < date_add('${date}', interval 1 day)
        group by 1,2
    ) per on per.plt_date = a1.plt_date and per.source = a1.source



;

select
    a.plt_date 进入闪速日期
    ,case a.source
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
    ,count(a.id) 总量
    ,count(if(a.state in (3,4,5,6) and datediff(a.created_at, coalesce(a.pcol_time, a.updated_at)) <= 5, a.id, null)) 时效内处理量
    ,count(if(a.state in (3,4,5,6) and datediff(a.created_at, coalesce(a.pcol_time, a.updated_at)) > 5, a.id, null)) 时效外处理量
    ,count(if(a.state in (1,2) , a.id, null)) 待处理量
    ,count(if(a.state in (3,4,5,6) and datediff(a.created_at, coalesce(a.pcol_time, a.updated_at)) <= 5, a.id, null))/count(a.id) 时效内达成率
from
    (
        select
            a1.*
        from
            (
                select
                    date(plt.created_at) plt_date
                    ,plt.source
                    ,plt.id
                    ,plt.state
                    ,plt.created_at
                    ,plt.updated_at
                    ,pcol.created_at pcol_time
                    ,row_number() over (partition by plt.id order by plt.created_at ) rk
                from bi_pro.parcel_lose_task plt
                left join bi_pro.parcel_cs_operation_log pcol on pcol.task_id = plt.id
                where
                    plt.created_at >= '${date}'
                    and plt.created_at < date_add('${date}', interval 1 day)
            ) a1
        where
            a1.rk = 1
    ) a
group by 1,2
