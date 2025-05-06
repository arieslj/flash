select
    ss.creat_month 日期
    /*,ss.name 上报HUB
    ,ss.id*/
    ,sum(a.上报丢失量) 上报丢失量
    ,sum(a.认领成功量_继续派送) 认领成功量_继续派送
    ,sum(a.认领成功量_继续派送)/sum(a.上报丢失量) 匹配成功率1（继续派送）
    ,sum(a.认领成功量_继续派送_理赔失效) 认领成功量_继续派送_理赔失效
    ,(sum(a.认领成功量_继续派送)+sum(a.已认领_认领有理赔_理赔失效))/sum(a.上报丢失量) '匹配成功率2(继续派送+理赔失效)'
    ,sum(a.HUB待认领量) HUB待认领量
    ,sum(a.HUB未认领_定时任务失效) HUB未认领_定时任务失效
    ,sum(a.已认领_认领有理赔_理赔失效) 已认领_认领有理赔_理赔失效

,sum(a.认领成功量_继续派送_diff_day)/sum(a.认领成功量_继续派送) 认领成功量_继续派送_diff
    ,sum(a.认领成功量_继续派送_理赔失效_diff_day)/sum(a.认领成功量_继续派送_理赔失效) 认领成功量_继续派送_理赔失效_diff

    ,sum(a.包裹认领处_认领成功继续派送) 包裹认领处_认领成功继续派送
    ,sum(a.包裹认领处_认领成功理赔失效) 包裹认领处_认领成功理赔失效
    ,sum(a.HUB无头包裹匹配_匹配成功继续派送) HUB无头包裹匹配_匹配成功继续派送
    ,sum(a.HUB无头包裹匹配_匹配成功理赔失效) HUB无头包裹匹配_匹配成功理赔失效
    ,sum(b.访问人次) 访问人次
    ,sum(b.点击搜索量) 点击搜索量
    ,sum(b.点击匹配量) 点击匹配量

from
(
    select
    ss.name
    ,ss.id
    ,c.creat_month
    from fle_staging.sys_store ss
    cross join
   (
    select
    substr(ph.created_at, 1, 4) creat_month
    from fle_staging.parcel_headless ph
    where ph.created_at >= '2023-01-01'
    group by 1
    ) c
    where ss.category in (8,12)
    and state=1
)ss
left join
    (
        select
            a.creat_month 日期
            ,a.submit_store_name 上报HUB
            ,a.submit_store_id
            ,count(distinct a.hno) 上报丢失量
            ,count(distinct if(a.head_state = '认领成功', a.hno, null)) + count(distinct if(a.head_state = '认领成功_已失效', a.hno, null)) 认领成功量_继续派送
        ,count(distinct if(a.head_state = '认领成功' , a.hno, null)) + count(distinct if(a.head_state = '认领成功_已失效' , a.hno, null)) + count(distinct if(a.head_state = '认领失败_已失效' , a.hno, null)) 认领成功量_继续派送_理赔失效
        ,count(distinct if(a.head_state = '未认领_待认领', a.hno, null)) HUB待认领量
        ,count(distinct if(a.head_state = '未认领_已失效', a.hno, null)) HUB未认领_定时任务失效
        ,count(distinct if(a.head_state = '认领失败_已失效' , a.hno, null)) 已认领_认领有理赔_理赔失效

        --  ,count(distinct if(a.head_state = '认领成功' and a.final_state is null, a.hno, null)) + count(distinct if(a.head_state = '认领成功_已失效' and a.final_state is null, a.hno, null))
        --    + count(distinct if(a.final_state in (1,5),a.hno,null)) 认领成功量_继续派送

        --  ,count(distinct if(a.head_state = '认领成功' and a.final_state is null, a.hno, null)) + count(distinct if(a.head_state = '认领成功_已失效' and a.final_state is null, a.hno, null)) + count(distinct if(a.head_state = '认领失败_已失效' and a.final_state is null, a.hno, null))
        --    + count(distinct if(a.final_state in (1,2,5,6),a.hno,null))   认领成功量_继续派送_理赔失效

        --  ,count(distinct if(a.head_state = '未认领_待认领', a.hno, null)) HUB待认领量

        --  ,count(distinct if(a.head_state = '未认领_已失效' and a.final_state is null , a.hno, null))
        --    + count(distinct if(a.final_state in (3,4),a.hno,null)) HUB未认领_定时任务失效

        --  ,count(distinct if(a.head_state = '认领失败_已失效' and a.final_state is null , a.hno, null))
        --    + count(distinct if(a.final_state in (2,6),a.hno,null)) 已认领_认领有理赔_理赔失效

 ,sum( if(a.head_state in( '认领成功','认领成功_已失效'), a.diff_day, null)) 认领成功量_继续派送_diff_day
        ,sum( if(a.head_state in( '认领成功','认领成功_已失效','认领失败_已失效') , a.diff_day, null))  认领成功量_继续派送_理赔失效_diff_day



            ,count(distinct if(a.final_state=1,a.hno,null)) 包裹认领处_认领成功继续派送
            ,count(distinct if(a.final_state=2,a.hno,null)) 包裹认领处_认领成功理赔失效
            ,count(distinct if(a.final_state=5,a.hno,null)) HUB无头包裹匹配_匹配成功继续派送
            ,count(distinct if(a.final_state=6,a.hno,null)) HUB无头包裹匹配_匹配成功理赔失效


        from
            (
                select
                    ph.hno
                    ,substr(ph.created_at, 1, 4) creat_month
                    ,ph.final_state
                    ,ph.submit_store_name
                    ,ph.submit_store_id
                    ,TIMESTAMPDIFF(day,ph.created_at,ph.claim_at) diff_day
                    ,ph.pno
                    ,case
                        when ph.state = 0 then '未认领_待认领'
                        when ph.state = 2 then '认领成功'
                        when ph.state = 3 and ph.claim_store_id is null then '未认领_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at < coalesce(sx.claim_time,curdate()) then '认领成功_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at >= coalesce(sx.claim_time,curdate()) then '认领失败_已失效' -- 理赔失效
                    end head_state
                    ,ph.state
                    ,ph.claim_store_id
                    ,ph.claim_store_name
                    ,ph.claim_at
                from  fle_staging.parcel_headless ph
                left join fle_staging.sys_store ss on ss.id=ph.submit_store_id
                left join
                    (
                        select
                            ph.pno
                            ,min(pct.created_at) claim_time
                        from fle_staging.parcel_headless ph
                        join bi_pro.parcel_claim_task pct on pct.pno = ph.pno
                        where ph.state = 3 -- 时效
                        group by 1
                    ) sx on sx.pno = ph.pno
                where ph.state < 4
                and ph.created_at >= '2023-01-01'
                and ss.category in (8,12)
            ) a
        group by 1,2,3
    ) a on ss.name =a.上报HUB and ss.creat_month=a.日期
group by 1
order by 1
