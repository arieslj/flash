with t as
    (
        select
            ph.hno
            ,ph.parcel_discover_date
            ,ph.parcel_discover_time
            ,ph.state
            ,ph.final_state
            ,ph.print_state
            ,ph.submit_store_id
            ,ph.pno
            ,ph.claim_at
            ,ph.created_at
        from my_staging.parcel_headless ph
        where
            ph.parcel_discover_date >= '${sdate}'
            and ph.parcel_discover_date <= '${edate}'
    )
select
    t1.parcel_discover_date 无头件发现日期
    ,case ss.category
          when 1 then 'SP'
          when 2 then 'DC'
          when 4 then 'SHOP'
          when 5 then 'SHOP'
          when 6 then 'FH'
          when 7 then 'SHOP'
          when 8 then 'Hub'
          when 9 then 'Onsite'
          when 10 then 'BDC'
          when 11 then 'fulfillment'
          when 12 then 'B-HUB'
          when 13 then 'CDC'
          when 14 then 'PDC'
    end 网点类型
    ,count(distinct t1.hno) 无头件上报数量
    ,count(distinct if(t1.state = 5, t1.hno, null)) 待登记
    ,count(distinct if(t1.state = 0, t1.hno, null)) 未认领
    ,count(distinct if(t1.state = 2, t1.hno, null)) 已认领
    ,count(distinct if(t1.state = 3, t1.hno, null)) 已失效
    ,count(distinct if(t1.state = 4, t1.hno, null)) 已撤销
    ,avg(timestampdiff(minute, t1.parcel_discover_time, t1.created_at)) 平均处理时长_min
    ,count(distinct if(t1.final_state in (1,2), t1.hno, null)) 人工匹配
    ,count(distinct if(t1.final_state in (5,6), t1.hno, null)) 使用系统匹配
    ,count(distinct if(t1.final_state in (1,2,5,6), t1.hno, null)) 认领总量
    ,count(distinct if(t1.state in (1,2), t1.hno, null)) 认领成功量
    ,count(distinct if(t1.final_state in (2,6), t1.hno, null)) 认领成功但已失效
    ,count(distinct if(t1.state in (1,2) and t1.print_state in (1,2), t1.hno, null)) 认领成功且实际已打单
    ,count(distinct if(t1.state in (1,2) and t1.print_state in (1,2), t1.hno, null)) / count(distinct if(t1.state in (1,2), t1.hno, null)) 已认领打单率
    ,count(distinct if(t1.state = 3, t1.hno, null)) 已失效需打单总量
    ,count(distinct if(t1.state = 3 and t1.print_state in (1,2), t1.hno, null)) 失效且实际已打单
    ,count(distinct if(t1.state = 3 and t1.print_state in (1,2), t1.hno, null)) / count(distinct if(t1.state = 3, t1.hno, null)) 已失效打单率
    ,count(distinct ci.pno) 不准确认领量
    ,count(distinct if(t1.state in (1,2) and pi.state = 5, t1.hno, null)) 认领成功_已妥投
    ,count(distinct if(t1.state in (1,2) and pi.state = 8 and plt.pno is not null, t1.hno, null)) 认领成功_异常关闭_丢失
    ,count(distinct if(t1.state in (1,2) and pi.state = 8 and plt.pno is null and pi.dst_store_id = 'MY04040319', t1.hno, null)) 认领成功_异常关闭_拍卖仓
    ,count(distinct if(t1.state in (1,2) and k.pno is not null, t1.hno, null)) 认领成功但后续超时效
    ,count(distinct if(t1.state = 3 and pi.state = 8 and plt.pno is not null, t1.hno, null)) 已失效_异常关闭_丢失
    ,count(distinct if(t1.state = 3 and pi.state = 8 and plt.pno is null and pi.dst_store_id = 'MY04040319', t1.hno, null)) 已失效_异常关闭_拍卖仓
from t t1
left join my_staging.sys_store ss on ss.id = t1.submit_store_id
left join my_staging.customer_issue ci on ci.pno = t1.pno and ci.request_sup_type = 14 and ci.request_sub_type = 144
left join my_staging.parcel_info pi on pi.pno = t1.pno
left join
    (
        select
            distinct
            plt.pno
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at > date_sub(curdate(), interval 3 month)
            and plt.state = 6
            and plt.duty_result = 1
            and plt.penalties > 0
    ) plt on plt.pno = t1.pno
left join
    (
        select
            distinct
            plt.pno
        from my_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at > date_sub(curdate(), interval 3 month)
            and plt.source = 11
            and plt.created_at > date_add(t1.claim_at, interval 8 hour)
    ) k on k.pno = t1.pno
group by 1,2



