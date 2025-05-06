select
    a.creat_month 日期
    ,a.submit_store_name 上报HUB
    ,a.submit_store_id
    ,count(a.hno) 上报丢失量
    ,count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功_已失效', a.hno, null)) 认领成功量（继续派送）
    ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功_已失效', a.hno, null)))/count(a.hno) 匹配成功率1（继续派送）
    ,count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功_已失效', a.hno, null)) + count(if(a.head_state = '认领失败_已失效', a.hno, null)) '认领成功量（继续派送+理赔失效）'
    ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功_已失效', a.hno, null)) + count(if(a.head_state = '认领失败_已失效', a.hno, null)))/count(a.hno) '匹配成功率2(继续派送+理赔失效)'
    ,count(if(a.head_state = '未认领_待认领', a.hno, null)) 'HUB待认领量'
    ,count(if(a.head_state = '未认领_已失效', a.hno, null)) 'HUB未认领_定时任务失效'
    ,count(if(a.head_state = '认领成功', a.hno, null)) '已认领_认领无理赔_未失效'
    ,count(if(a.head_state = '认领成功_已失效', a.hno, null)) '已认领_认领无理赔_定时任务失效'
    ,count(if(a.head_state = '认领失败_已失效', a.hno, null)) '已认领_认领有理赔_理赔失效'
from
    (
        select
            ph.hno
            ,substr(convert_tz(ph.created_at, '+00:00', '+07:00'), 1, 11) creat_month
            ,ph.submit_store_name
            ,ph.submit_store_id
            ,ph.pno
            ,case
                when ph.state = 0 then '未认领_待认领'
                when ph.state = 2 then '认领成功'
                when ph.state = 3 and ph.claim_store_id is null then '未认领_已失效'
                when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at < date_sub(coalesce(sx.claim_time,curdate()), interval  7 hour) then '认领成功_已失效'
                when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at >= date_sub(coalesce(sx.claim_time,curdate()), interval  7 hour) then '认领失败_已失效' -- 理赔失效
            end head_state
            ,ph.state
            ,ph.claim_store_id
            ,ph.claim_store_name
            ,convert_tz(ph.claim_at, '+00:00', '+07:00') claim_at
        from  fle_staging.parcel_headless ph
        left join fle_staging.sys_store ss on ss.id=ph.submit_store_id
        left join
            (
                select
                    ph.pno
                    ,min(pct.created_at) claim_time
                from fle_staging.parcel_headless ph
                join bi_pro.parcel_claim_task pct on pct.pno = ph.pno
                where
                    ph.state = 3 -- 时效
                group by 1
            ) sx on sx.pno = ph.pno
        where
            ph.state < 4
            and ph.created_at >= '2024-08-31 17:00:00'
            and ss.category in (8,12)
    ) a
group by 1,2,3
order by 2,1

;


select
    ph.hno 无头件编号
    ,ph.pno  运单号
    ,substr(convert_tz(ph.created_at, '+00:00', '+07:00'), 1, 11) 无头件上报日期
    ,ph.submit_store_name 上报HUB
    ,ph.submit_store_id 上报网点ID
    ,case
        when ph.state = 0 then '未认领_待认领'
        when ph.state = 2 then '认领成功'
        when ph.state = 3 and ph.claim_store_id is null then '未认领_已失效'
        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at < coalesce(sx.claim_time,curdate()) then '认领成功_已失效'
        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at >= coalesce(sx.claim_time,curdate()) then '认领失败_已失效' -- 理赔失效
    end 认领状态
    ,ph.claim_store_id 认领网点ID
    ,ph.claim_store_name 认领网点
    ,ph.claim_at 认领时间
from  fle_staging.parcel_headless ph
left join fle_staging.sys_store ss on ss.id=ph.submit_store_id
left join
    (
        select
            ph.pno
            ,min(pct.created_at) claim_time
        from fle_staging.parcel_headless ph
        join bi_pro.parcel_claim_task pct on pct.pno = ph.pno
        where
            ph.state = 3 -- 时效
        group by 1
    ) sx on sx.pno = ph.pno
where
    ph.state < 4
    and ph.created_at >= '2024-07-31 17:00:00'
    and ss.category in (8,12)
