select
    a.*
    ,b.访问人次
    ,b.点击搜索量
    ,b.点击匹配量
    ,b.成功匹配量 HUB无头件匹配成功量
    ,a.`已认领_认领无理赔_定时任务失效` + a.`已认领_认领无理赔_未失效` - b.成功匹配量 包裹认领处认领数
    ,c.num 丢失包裹量
from
    (
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
                    ,substr(ph.created_at, 1, 4) creat_month
                    ,ph.submit_store_name
                    ,ph.submit_store_id
                    ,ph.pno
                    ,case
                        when ph.state = 0 then '未认领_待认领'
                        when ph.state in (1,2) then '认领成功'
                        when ph.state = 3 and ph.claim_store_id is null then '未认领_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at < coalesce(sx.claim_time,curdate()) then '认领成功_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at >= coalesce(sx.claim_time,curdate()) then '认领失败_已失效' -- 理赔失效
                    end head_state
                    ,ph.state
                    ,ph.claim_store_id
                    ,ph.claim_store_name
                    ,ph.claim_at
                from  ph_staging.parcel_headless ph
                left join
                    (
                        select
                            ph.pno
                            ,min(pct.created_at) claim_time
                        from ph_staging.parcel_headless ph
                        join ph_bi.parcel_claim_task pct on pct.pno = ph.pno
                        where
                            ph.state = 3 -- 时效
                        group by 1
                    ) sx on sx.pno = ph.pno
                where
                    ph.state < 4
                    and ph.created_at >= '2023-04-01'
                    and ph.submit_store_id = 'PH19280F01'
            ) a
        group by 1,2,3
    ) a
left join
    (
        select
            fp.p_month 日期
            ,ss.name 网点
            ,ss.id 网点ID
            ,fp.view_num 访问人次
        #     ,fp.view_staff_num uv
            ,fp.match_num 点击匹配量
            ,fp.search_num 点击搜索量
            ,fp.sucess_num 成功匹配量
        from
            (
                select
                *
#                     json_extract(ext_info,'$.organization_id') store_id
#                     ,substr(fp.p_date, 1, 4) p_month
#                     ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
#                     ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
#                     ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
#                     ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
#                     ,count(if(json_unquote(json_extract(ext_info,'$.matchResult')) = 'true', fp.user_id, null)) sucess_num
                from dwm.dwd_ph_sls_pro_flash_point fp
                where
                    fp.p_date >= '2023-01-01'
                    and json_extract(ext_info,'$.organization_id') = 'PH04470200'
                    and json_unquote(json_extract(ext_info,'$.matchResult')) = 'true'
                group by 1,2
            ) fp
        left join ph_staging.sys_store ss on ss.id = fp.store_id
        where
            ss.category in (8,12)
    ) b on a.日期 = b.日期 and a.上报HUB = b.网点
left join
    (
        select
            plr.store_id
            ,substr(plt.created_at, 1, 4) creat_month
            ,count(distinct plt.pno) num
        from ph_bi.parcel_lose_task plt
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.created_at >= '2023-01-01'
        group by 1,2
    ) c on c.store_id = a.submit_store_id and a.日期 = c.creat_month