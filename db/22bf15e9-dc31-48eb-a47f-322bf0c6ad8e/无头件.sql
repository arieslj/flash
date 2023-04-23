# -- 网点认领率
#
# select
#     a.creat_month 日期
#     ,a.submit_store_name 上报网点
#     ,count(a.hno) 上报丢失量
#     ,count(a.pno) 网点认领量
#     ,count(if(a.pno is not null and a.claim_store_id is not null, a.hno, null)) 网点认领量
#     ,count(if(a.pno is not null and a.claim_store_id is null, a.hno, null)) 非网点人员认领量（总部）
#     ,count(if(a.head_state = '未认领-待认领', a.hno, null)) '待认领量'
#     ,count(if(a.head_state = '未认领-已失效', a.hno, null)) '未认领-定时任务失效量'
#     ,count(if(a.head_state = '认领成功', a.hno, null)) '认领成功-未失效量'
#     ,count(if(a.head_state = '认领成功-已失效', a.hno, null)) '无理赔认领-定时任务失效量'
#     ,count(if(a.head_state = '认领失败-已失效', a.hno, null)) '有理赔认领-理赔失效量'
#     ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功-已失效', a.hno, null)))/count(a.hno) 匹配成功率1
#     ,(count(if(a.head_state = '认领成功', a.hno, null)) + count(if(a.head_state = '认领成功-已失效', a.hno, null)) + count(if(a.head_state = '认领失败-已失效', a.hno, null)))/count(a.hno) 匹配成功率2
# from
#     (
#         select
#             ph.hno
#             ,substr(ph.created_at, 1, 4) creat_month
#             ,ph.submit_store_name
#             ,ph.pno
#             ,case
#                 when ph.state = 0 then '未认领-待认领'
#                 when ph.state = 2 then '认领成功'
#                 when ph.state = 3 and ph.pno is null then '未认领-已失效'
#                 when ph.state = 3 and ph.pno is not null and ph.updated_at < coalesce(sx.claim_time,curdate()) then '认领成功-已失效'
#                 when ph.state = 3 and ph.pno is not null and ph.updated_at >= coalesce(sx.claim_time,curdate()) then '认领失败-已失效'
#             end head_state
#             ,ph.state
#             ,ph.claim_store_id
#             ,ph.claim_store_name
#             ,ph.claim_at
#         from  fle_staging.parcel_headless ph
#         left join
#             (
#                 select
#                     ph.pno
#                     ,min(pct.created_at) claim_time
#                 from fle_staging.parcel_headless ph
#                 join bi_pro.parcel_claim_task pct on pct.pno = ph.pno
#                 where
#                     ph.state = 3 -- 时效
#                 group by 1
#             ) sx on sx.pno = ph.pno
#         where
#             ph.state < 4
#             and ph.created_at >= '2022-12-31 17:00:00'
#     ) a
# group by 1,2
# ;
-- 网点平均认领时长

select
    a.creat_month 日期
    ,a.submit_store_name 上报HUB
    ,count(if(a.head_state in ('认领成功', '认领成功-已失效'), a.pno, null)) 认领件数（继续派送）
    ,sum(if(a.head_state in ('认领成功', '认领成功-已失效'), timestampdiff(second , a.created_at, coalesce(a.claim_at, a.updated_at))/3600,null))/count(if(a.head_state in ('认领成功', '认领成功-已失效'), a.pno, null)) 认领平均时长（继续派送）
    ,count(if(a.head_state in ('认领成功', '认领成功-已失效','认领失败-已失效'), a.pno, null)) 认领件数（包含因理赔失效）
    ,sum(if(a.head_state in ('认领成功', '认领成功-已失效','认领失败-已失效'), timestampdiff(second , a.created_at, coalesce(a.claim_at, a.updated_at))/3600,null))/count(if(a.head_state in ('认领成功', '认领成功-已失效','认领失败-已失效'), a.pno, null)) 认领平均时长（包含因理赔失效）
from
    (
        select
            ph.hno
            ,substr(ph.created_at, 1, 7) creat_month
            ,ph.submit_store_name
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
            ph.state < 4
            and ph.created_at >= '2022-12-31 17:00:00'
            and ph.claim_store_id is not null -- 有认领动作
            and ph.claim_staff_id is not null
    ) a
group by 1,2
;

-- 访问人次
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
            json_extract(ext_info,'$.organization_id') store_id
            ,substr(fp.p_date, 1, 4) p_month
            ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
            ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
            ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
            ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
            ,count(if(json_unquote(json_extract(ext_info,'$.matchResult')) = 'true', fp.user_id, null)) sucess_num
        from dwm.dwd_th_sls_pro_flash_point fp
        where
            fp.p_date >= '2023-01-01'
#             and fp.page_id ='/package/packageMatch'
#             and fp.p_app = 'FLE-MS-UI'
        group by 1,2
    ) fp
left join fle_staging.sys_store ss on ss.id = fp.store_id
where
    ss.category in (8,12)
;

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
                    ,substr(ph.created_at, 1, 7) creat_month
                    ,ph.submit_store_name
                    ,ph.submit_store_id
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
                    and ph.created_at >= '2023-01-01'
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
                    json_extract(ext_info,'$.organization_id') store_id
                    ,substr(fp.p_date, 1, 7) p_month
                    ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
                    ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
                    ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
                    ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
                    ,count(if(json_unquote(json_extract(ext_info,'$.matchResult')) = 'true', fp.user_id, null)) sucess_num
                from dwm.dwd_th_sls_pro_flash_point fp
                where
                    fp.p_date >= '2023-01-01'
                group by 1,2
            ) fp
        left join fle_staging.sys_store ss on ss.id = fp.store_id
        where
            ss.category in (8,12)
    ) b on a.日期 = b.日期 and a.上报HUB = b.网点
left join
    (
        select
            plr.store_id
            ,substr(plt.created_at, 1, 7) creat_month
            ,count(distinct plt.pno) num
        from bi_pro.parcel_lose_task plt
        left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.created_at >= '2023-01-01'
        group by 1,2
    ) c on c.store_id = a.submit_store_id and a.日期 = c.creat_month
;

-- 分时段，按照继续派送的类型定义成功

select
    b.creat_month 日期
    ,b.submit_store_name 上报HUB
    ,count(if(b.use_time < 24, b.pno, null)) 认领包裹数_1天内
    ,count(if(b.use_time >= 24 and b.use_time < 48, b.pno, null)) 认领包裹数_1_2天
    ,count(if(b.use_time >= 48 and b.use_time < 72, b.pno, null)) 认领包裹数_2_3天
    ,count(if(b.use_time >= 72 and b.use_time < 168, b.pno, null)) 认领包裹数_3_7天
    ,count(if(b.use_time >= 168, b.pno, null)) 认领包裹数_超一周
    ,count(b.pno) 总认领包裹数
from
    (
        select
            a.creat_month
            ,a.submit_store_name
            ,a.pno
            ,timestampdiff(second , a.created_at, coalesce(a.claim_at, a.updated_at))/3600 use_time
            ,a.created_at
            ,a.claim_at
        from
            (
                select
                    ph.hno
                    ,substr(ph.created_at, 1, 7) creat_month
                    ,ph.submit_store_name
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
                    ph.state < 4
                    and ph.created_at >= '2022-12-31 17:00:00'
                    and ph.claim_store_id is not null -- 有认领动作
                    and ph.claim_staff_id is not null
            ) a
        where
            a.head_state in ('认领成功', '认领成功-已失效')
    ) b
group by 1,2

;

-- 网点月份丢失量（有责任）
-- 泰国产品需求

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
            and ph.created_at < '2023-04-18 17:00:00'
#             and ph.claim_store_id is not null -- 有认领动作
#             and ph.claim_staff_id is not null
    ) a
left join fle_staging.sys_store ss on ss.id = a.submit_store_id
group by 1,2,3

