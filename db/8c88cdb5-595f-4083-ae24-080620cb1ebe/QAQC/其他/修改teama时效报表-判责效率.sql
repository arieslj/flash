with t as
    (
        select
            distinct
            plt.source
            ,case
                when plt.source in (1) then 9
                when plt.source in (2,4,5,8,12) then 0
                when plt.source in (6,7) then 4
                when plt.source in (11) then 6
            end sla
            ,case plt.source
                when 1 then '各业务组织从KIT/MS上面提交的丢失问题件。5天不更新自动升级'
                when 2 then '客服或者PMD在MS记录本中创建的丢失问题件或客户在App上提交的丢失问题件'
                when 4 then '各业务组织从KIT/MS上面提交的破损短少问题件。（QAQC判责与理赔同时进行互不影响）'
                when 5 then '客服或者PMD确认需要理赔后在MS记录本中提交的丢失问题件。（QAQC判责后方可理赔）'
                when 6 then '客服或者PMD确认需要理赔后在MS记录本中提交的破损短少问题件（QAQC判责与理赔同时进行互不影响）'
                when 7 then '客服或者PMD确认需要理赔后在MS记录本中创建的问题件，一般是内物不符的包裹。（QAQC判责与理赔同时进行互不影响）'
                when 8 then '平台客户在与我们公司交接流程[IPC-计数]后遗失的包裹或揽收前遗失的包裹'
                when 11 then 'Lazada/Shopee/TikTok包裹超过规定时效后会被抓进闪速系统判定责任人（QAQC判责与理赔同时进行互不影响）'
                when 12 then '当包裹在任意网点滞留>=5个自然日，且包裹在该网点产生的历史路由动作均发生在距离网点100m内（只看系统有记录位置的即可），即打上“强制拍照”标记之后，AI疑似丢失稽查程序返回结果值中，筛选结果为“无实体包裹”或“面单不清晰”的运单，生成判责任务进入闪速认定'
            end def
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at > date_sub(curdate(), interval 1 month)
            and plt.source in (1,2,4,5,6,7,8,10,11,12)
    )
select
    concat(a1.sla, 'D') 时效要求
    ,case a1.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-无运单号包裹丢失'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,a1.def 定义
    ,tod.plt_cnt  今日新增量
    ,del.duty_cnt_auto 自动判责量
    ,del.duty_cnt_man 人工判责量
    ,del.no_duty_cnt_auto 自动无需追责量
    ,del.no_duty_cnt_man 人工无需追责量
    ,del.duty_cnt 判责量
    ,del.no_duty_cnt 无需追责量
    ,del.total_cnt 总计
    ,pnd.plt_cnt 待处理量
    ,d1.delay_cnt 超时待处理
    ,d2.over_deal_cnt 超时已处理
from t a1
left join
    (
        select
            plt.source
            ,count(plt.id) plt_cnt
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at >= curdate()
        group by 1
    ) tod on a1.source = tod.source
left join
    (
        select
            plt.source
            ,count(distinct if(pcol.action = 3 and pcol.operator_id > 10001, plt.id, null)) no_duty_cnt_man
            ,count(distinct if(pcol.action = 4 and pcol.operator_id > 10001, plt.id, null)) duty_cnt_man
            ,count(distinct if(pcol.action = 3 and pcol.operator_id in (10000, 10001), plt.id, null)) no_duty_cnt_auto
            ,count(distinct if(pcol.action = 4 and pcol.operator_id in (10000, 10001), plt.id, null)) duty_cnt_auto
            ,count(distinct if(pcol.action = 3, plt.id, null)) no_duty_cnt
            ,count(distinct if(pcol.action = 4, plt.id, null)) duty_cnt
            ,count(distinct plt.id) total_cnt
        from bi_pro.parcel_lose_task plt
        join bi_pro.parcel_cs_operation_log pcol on pcol.task_id = plt.id
        where
            pcol.action in (3,4)
            and pcol.created_at > curdate()
        group by 1
    ) del on a1.source = del.source
left join
    (
        select
            plt.source
            ,count(plt.id) plt_cnt
        from bi_pro.parcel_lose_task plt
        where
            plt.created_at > date_sub(curdate(), interval 3 month)
            and plt.state < 5
        group by 1
    ) pnd on a1.source = pnd.source
left join
    (
        select
            plt.source
            ,count(distinct if(plt.created_at < date_sub(curdate(), interval t1.sla day), plt.id, null)) delay_cnt
        from bi_pro.parcel_lose_task plt
        left join t t1 on t1.source = plt.source
        where
            plt.created_at > date_sub(curdate(), interval 3 month)
            and plt.state < 5
        group by 1
    ) d1 on a1.source = d1.source
left join
    (
        select
            a1.source
            ,count(distinct if(a1.created_at < date_sub(curdate(), interval a1.sla day) and a1.deal_at > curdate(), a1.id, null)) over_deal_cnt
        from
            (
                select
                    plt.id
                    ,plt.source
                    ,plt.created_at
                    ,pcol.created_at deal_at
                    ,t1.sla
                    ,row_number() over (partition by plt.id order by pcol.created_at) rk
                from bi_pro.parcel_lose_task plt
                join t t1 on t1.source = plt.source
                left join bi_pro.parcel_cs_operation_log pcol on pcol.task_id = plt.id and pcol.action in (3,4) and pcol.type = 1
                where
                    plt.updated_at > curdate()
                    and plt.state in (5,6)
            ) a1
        where
            a1.rk = 1
        group by 1
    ) d2 on a1.source = d2.source
order by 2



