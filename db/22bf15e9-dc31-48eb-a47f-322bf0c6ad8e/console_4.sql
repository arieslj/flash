select
    a.creat_date
    ,a.submit_store_name
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
    ,count(distinct a.hno) 上报无头件总数
    ,count(distinct if(a.state = 5, a.hno, null)) 撤销数量
    ,count(distinct if(a.head_state in ('认领成功', '认领成功-已失效', '认领失败-已失效'), a.hno, null)) 认领成功数量
    ,count(distinct if(a.head_state in ('未认领-已失效'), a.hno, null)) 失效的数量
    ,count(distinct if(a.state = 3 and a.print_state in (1,2), a.hno, null)) 失效后已处理数量
from
    (
        select
            ph.hno
            ,date(ph.created_at) creat_date
            ,ph.submit_store_name
            ,ph.submit_store_id
            ,ph.pno
            ,case
                when ph.state = 0 then '未认领-待认领'
                when ph.state = 2 then '认领成功'
                when ph.state = 3 and ph.claim_store_id is null then '未认领-已失效'
                when ph.state = 3 and ph.claim_store_id is not null and ph.updated_at < coalesce(sx.claim_time,curdate()) then '认领成功-已失效'
                when ph.state = 3 and ph.claim_store_id is not null and ph.updated_at >= coalesce(sx.claim_time,curdate()) then '认领失败-已失效'
            end head_state
            ,ph.state
            ,ph.created_at
            ,ph.claim_store_id
            ,ph.claim_store_name
            ,ph.claim_at
            ,ph.updated_at
            ,ph.print_state
        from  fle_staging.parcel_headless ph
        left join
            (
                select
                    ph.pno
                    ,min(pct.created_at) claim_time
                from fle_staging.parcel_headless ph
                join bi_pro.parcel_claim_task pct on pct.pno = ph.pno
                where
                    ph.state = 3 -- 失效
                group by 1
            ) sx on sx.pno = ph.pno
        where
#             ph.state < 4
            ph.created_at >= '2023-04-05 17:00:00'
            and ph.created_at < '2023-05-06 17:00:00'
#             and ph.claim_store_id is not null -- 有认领动作
#             and ph.claim_staff_id is not null
    ) a
left join fle_staging.sys_store ss on ss.id = a.submit_store_id
group by 1,2,3;