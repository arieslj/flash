select
    a.creat_month
    ,count(a.hno) 上报丢失量
    ,count(if(a.head_state = '未认领-待认领', a.hno, null)) '待认领'
    ,count(if(a.head_state = '未认领-已失效', a.hno, null)) '未认领-定时任务失效'
    ,count(if(a.head_state = '认领成功', a.hno, null)) '认领成功-未失效'
    ,count(if(a.head_state = '认领成功-已失效', a.hno, null)) '无理赔认领-定时任务失效'
    ,count(if(a.head_state = '认领失败-已失效', a.hno, null)) '有理赔认领-理赔失效'
    ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功-已失效', a.hno, null)))/count(a.hno) 匹配成功率1
    ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功-已失效', a.hno, null)) + count(if(a.head_state = '认领失败-已失效', a.hno, null)))/count(a.hno) 匹配成功率2
from
    (
        select
            ph.hno
            ,substr(ph.created_at, 1, 4) creat_month
            ,ph.pno
            ,case
                when ph.state = 0 then '未认领-待认领'
                when ph.state = 2 then '认领成功'
                when ph.state = 3 and ph.pno is null then '未认领-已失效'
                when ph.state = 3 and ph.pno is not null and ph.updated_at < coalesce(sx.claim_time,curdate()) then '认领成功-已失效'
                when ph.state = 3 and ph.pno is not null and ph.updated_at >= coalesce(sx.claim_time,curdate()) then '认领失败-已失效'
            end head_state
        from  fle_staging.parcel_headless ph
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
            and ph.created_at < '2023-04-01'
    ) a
group by 1
