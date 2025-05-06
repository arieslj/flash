select
    case plt.source
        when 1 then 'A-问题件-丢失 / Problematic Item -Lost'
        when 2 then 'B-记录本-丢失 / Processing Record - Lost'
        when 3 then 'C-包裹状态未更新 / Status not updated'
        when 4 then 'D-问题件-破损/短少 / Processing Item - Damaged/Short'
        when 5 then 'E-记录本-索赔-丢失 / Processing Item - Claim - Lost'
        when 6 then 'F-记录本-索赔-破损/短少 / Processing Item - Claim - Damaged/Lost'
        when 7 then 'G-记录本-索赔-其他/ Processing Item - Claim - others'
        when 8 then 'H-包裹状态未更新-IPC计数/ Lost Parcel claims without Waybill Number'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹 / Breached Parcel'
        when 12 then 'L-高度疑似丢失 Highly uspected lost parcel'
    end 问题来源渠道
    ,count(distinct if(plt.state in (1,2), plt.id, null)) as 待处理任务量
    ,count(distinct if(plt.state in (3), plt.id, null)) as 待回复任务量
    ,count(distinct if(plt.state in (4), plt.id, null)) as 已回复任务量
    ,count(distinct plt.id) as 总待处理任务量
from my_bi.parcel_lose_task plt
where
    plt.state in (1,2,3,4)
group by 1
order by 1
;

select
    *
    ,row_number() over (partition by type)
from my_staging.diff_info di
-- teamB

select
    '异常包裹判责【禁运品】/Abnormal - Contraband ' type
    ,count(c.id) pnt
from my_bi.contraband c
where
    c.status = 1

union all

select
     '异常包裹判责【违规件举报】/Abnormal - unqualified Parcel Report' type
    ,count(pvr.id) pnt
from my_bi.parcel_violate_rules pvr
where
    pvr.status = 1

union all

select
    case put.punishment_type
        when 1 then '异常包裹判责【漏揽收扫描】/Abnormal - Missed Scanning'
        when 2 then '异常包裹判责【虚假撤销】/ Abnormal - Fake Recall'
    end type
    ,count(distinct put.id) pnt
from my_bi.parcel_unpickup_task put
where
    put.process_status in (1,2,3)
group by 1

union all

select
    '虚假标记审核【标记电话号码空号】/Fal se Mark Review - Mark Empty Phone ' type
    ,count(distinct tfa.id) pnt
from my_bi.ticket_fake_audit_marker tfa
where
    tfa.state = 1

union all

select
    '虚假标记审核【标记超大件，违禁物品审核】/ Fal se Mark Review - Mark Oversized & Forbidden Goods for Review ' type
    ,count(distinct tcf.id) pnt
from my_bi.ticket_cancel_fake_mark tcf
where
    tcf.state = 1

union all

select
    '网络申述处理【集体罚款】/ Complain Handling - Individual Penalties' type
    ,count(distinct am.average_merge_key) pnt
from my_bi.abnormal_message am
left join my_bi.abnormal_qaqc aq on aq.qaqc_merge_key = am.average_merge_key
where
    am.abnormal_object = 1
    and aq.type = 1
    and coalesce(am.isappeal ,aq.isappeal) = 2
    and am.isdel = 0
group by 1

union all

select
    case am.`abnormal_object`
        when 0 then '网络申述处理【个人罚款】/ Complain Handling - Collective Penalties'
        when 1 then '网络申述处理【集体罚款】/ Complain Handling - Individual Penalties'
        when 2 then '网络申述处理【加盟商罚款】/ Complain Handling - Flash Home Penalties'
    end as type
    ,count(distinct am.id) pnt
from my_bi.abnormal_message am
left join my_bi.abnormal_qaqc aq on am.id = aq.abnormal_message_id
where
    am.abnormal_object in (2,0)
    and aq.type in (2,3)
    and coalesce(am.isappeal ,aq.isappeal) = 2
    and am.isdel = 0
group by 1
;


-- teama 分类
select
    date(pcol.created_at) p_date
    ,pcol.operator_id
    ,hsi.name
    ,case pcol.action
        when 1 then '已发工单数量/ Ticket Replied'
        when 4 then '已判责数量 / Resonsible person had been Judged'
        when 3 then '无需追责数量/ No need for accountability'
    end as p_action
    ,count(distinct if(plt.source = 1, pcol.id, null)) A来源
    ,count(distinct if(plt.source = 2, pcol.id, null)) B来源
    ,count(distinct if(plt.source = 3, pcol.id, null)) C来源
    ,count(distinct if(plt.source = 4, pcol.id, null)) D来源
    ,count(distinct if(plt.source = 5, pcol.id, null)) E来源
    ,count(distinct if(plt.source = 6, pcol.id, null)) F来源
    ,count(distinct if(plt.source = 7, pcol.id, null)) G来源
    ,count(distinct if(plt.source = 8, pcol.id, null)) H来源
    ,count(distinct if(plt.source = 9, pcol.id, null)) I来源
    ,count(distinct if(plt.source = 10, pcol.id, null)) J来源
    ,count(distinct if(plt.source = 11, pcol.id, null)) K来源
    ,count(distinct if(plt.source = 12, pcol.id, null)) L来源
from my_bi.parcel_lose_task plt
left join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
left join my_bi.staff_info hsi on hsi.id = pcol.operator_id
where
    pcol.created_at > '${sdate}'
    and pcol.created_at < date_add('${edate}', interval 1 day)
    and pcol.operator_id not in (10000,10001)
    and pcol.action in (1,3,4)
group by 1,2,3,4

;

select
    date(pcol.created_at) p_date
    ,pcol.operator_id
    ,hsi.name
    ,count(distinct pcol.id) 处理合计
from my_bi.parcel_lose_task plt
left join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
left join my_bi.staff_info hsi on hsi.id = pcol.operator_id
where
    pcol.created_at > '${sdate}'
    and pcol.created_at < date_add('${edate}', interval 1 day)
    and pcol.operator_id not in (10000,10001)
    and pcol.action in (1,3,4)
group by 1,2,3

;

select
    date(pcol.created_at) p_date
    ,pcol.operator_id
    ,hsi.name
    ,case pcol.action
        when 1 then '已发工单数量/ Ticket Replied'
        when 4 then '已判责数量 / Resonsible person had been Judged'
        when 3 then '无需追责数量/ No need for accountability'
    end as p_action
    ,count(distinct pcol.id) 合计
from my_bi.parcel_lose_task plt
left join my_bi.parcel_cs_operation_log pcol on pcol.task_id = plt.id
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = pcol.operator_id
where
    pcol.created_at > '${sdate}'
    and pcol.created_at < date_add('${edate}', interval 1 day)
    and pcol.operator_id not in (10000,10001)
group by 1,2,3,4


;

-- teamB 分类
with a as
    (-- 禁运品
        select
            case
                when c.duty_level in (1,2) then '已判责数量 / Resonsible person had been Judged'
                when c.duty_level is null then '无需追责数量/ No need for accountability'
            end action
            ,'禁运品' type
            ,date(c.updated_at) p_date
            ,c.operator staff_info
            ,si.name staff_name
            ,count(c.pno) pnt
        from my_bi.contraband c
        left join my_bi.staff_info si on si.id = c.operator
        where
            c.status = 2
            and c.operator not in (0,10000,10001)
            and c.updated_at >= '${sdate}'
            and c.updated_at < date_add('${edate}', interval 1 day)
        group by 1,2,3,4
    )
, b as
    (
        select
            case
                when pvr.judgment_result in (0,1,3) then '已判责数量 / Resonsible person had been Judged'
                when pvr.judgment_result in (2) then '无需追责数量/ No need for accountability'
            end action
            ,'违规件举报' type
            ,date(pvr.handled_at) p_date
            ,pvr.handler_id staff_info
            ,pvr.handler_name  staff_name
            ,count(pvr.pno) pnt
        from my_bi.parcel_violate_rules pvr
        where
            pvr.status = 2
            and pvr.handler_id not in (0,10000,10001)
            and pvr.handled_at >= '${sdate}'
            and pvr.handled_at < date_add('${edate}', interval 1 day)
        group by 1,2,3,4
    )
, c as
    (
        select
            case
                when put.process_status = 4 then '已判责数量 / Resonsible person had been Judged'
                when put.process_status = 5 then '无需追责数量/ No need for accountability'
            end action
            ,case put.punishment_type
                when 1 then '漏揽收扫描'
                when 2 then '虚假撤销'
            end type
            ,date(put.process_time) p_date
            ,put.communicator staff_info
            ,si.name staff_name
            ,count(put.pno) pnt
        from my_bi.parcel_unpickup_task put
        left join my_bi.staff_info si on si.id = put.communicator
        where
            put.process_status in (4,5)
            and put.communicator not in (0,10000,10001)
            and put.process_time >= '${sdate}'
            and put.process_time < date_add('${edate}', interval 1 day)
        group by 1,2,3,4
    )
, d as
    (
        select
            case
                when tfa.state = 2 then '已判责数量 / Resonsible person had been Judged'
                when tfa.state = 3 then '无需追责数量/ No need for accountability'
            end action
            ,'标记超大件，违禁物品审核' type
            ,date(tfa.process_time) p_date
            ,tfa.operator_id staff_info
            ,tfa.operator_name staff_name
            ,count(tfa.id) pnt
        from my_bi.ticket_cancel_fake_mark tfa
        where
            tfa.process_time >= '${sdate}'
            and tfa.operator_id not in (0,10000,10001)
            and tfa.process_time < date_add('${edate}', interval 1 day)
            and tfa.state in (2,3)
        group by 1,2,3,4
    )
,  e as
    (
        select
            case
                when tfa.state = 2 then '已判责数量 / Resonsible person had been Judged'
                when tfa.state = 3 then '无需追责数量/ No need for accountability'
            end action
            ,'标记电话号码空号' type
            ,date(tfa.deal_time) p_date
            ,tfa.admin_id staff_info
            ,tfa.admin_name staff_name
            ,count(tfa.id) pnt
        from my_bi.ticket_fake_audit_marker tfa
        where
            tfa.deal_time >= '${sdate}'
            and tfa.admin_id not in (0,10000,10001)
            and tfa.deal_time < date_add('${edate}', interval 1 day)
            and tfa.state in (2,3)
        group by 1,2,3,4
    )
, f as
    ( -- 集体出发
        select
            case
                when aq.isappeal in (3,4) then '已判责数量 / Resonsible person had been Judged'
                when aq.isappeal = 5 or aq.isdel = 1 then '无需追责数量/ No need for accountability'
            end action
            ,'集体处罚' type
            ,date(aq.handle_time) p_date
            ,aq.handle_staff_id staff_info
            ,si.name staff_name
            ,count(distinct aq.qaqc_merge_key) pnt
        from my_bi.abnormal_message am
        left join my_bi.abnormal_qaqc aq on aq.qaqc_merge_key = am.average_merge_key
        left join my_bi.staff_info si on si.id = aq.handle_staff_id
        where
            am.abnormal_object = 1
            and aq.type = 1
            and aq.handle_staff_id not in (0,10000,10001)
            and aq.handle_time >= '${sdate}'
            and aq.handle_time < date_add('${edate}', interval 1 day)
            and (aq.isappeal in (3,4,5) or aq.isdel = 1)
            and aq.handle_staff_id not in (10000,10001)
        group by 1,2,3,4
    )
, g as
    (
        select
            case
                when aq.isappeal in (3,4) then '已判责数量 / Resonsible person had been Judged'
                when aq.isappeal = 5 or aq.isdel = 1 then '无需追责数量/ No need for accountability'
            end action
            ,case am.abnormal_object
                when 0 then '个人罚款'
                when 1 then '集体罚款'
                when 2 then '加盟商罚款'
            end as type
            ,date(aq.handle_time) p_date
            ,aq.handle_staff_id staff_info
            ,si.name staff_name
            ,count(distinct aq.abnormal_message_id) pnt
        from my_bi.abnormal_message am
        left join my_bi.abnormal_qaqc aq on aq.abnormal_message_id = am.id
        left join my_bi.staff_info si on si.id = aq.handle_staff_id
        where
            am.abnormal_object in (2,0)
            and aq.type in (2,3)
            and aq.handle_staff_id not in (0,10000,10001)
            and aq.handle_time >= '${sdate}'
            and aq.handle_time < date_add('${edate}', interval 1 day)
            and (aq.isappeal in (3,4,5) or aq.isdel = 1)
            and aq.handle_staff_id not in (10000,10001)
        group by 1,2,3,4
    )
select
    t1.p_date
    ,t1.staff_info
    ,t1.staff_name
    ,t1.action
    ,a1.pnt ‘禁运品’
    ,b1.pnt '违规件举报'
    ,c1.pnt '漏揽收扫描'
    ,c2.pnt '虚假撤销'
    ,d1.pnt '标记超大件，违禁物品审核'
    ,e1.pnt '标记电话号码空号'
    ,f1.pnt '集体处罚'
    ,g1.pnt '个人罚款'
    ,g2.pnt '加盟商罚款'
from
    (
        select
            a.action
            ,a.p_date
            ,a.staff_info
            ,a.staff_name
        from
            (
                select * from a a1
                union all
                select * from b b1
                union all
                select * from c c1
                union all
                select * from d d1
                union all
                select * from e e1
                union all
                select * from f f1
                union all
                select * from g g1
            ) a
        group by 1,2,3,4
    ) t1
left join a a1 on a1.action = t1.action and a1.p_date = t1.p_date and a1.staff_info = t1.staff_info and a1.staff_name = t1.staff_name
left join b b1 on b1.action = t1.action and b1.p_date = t1.p_date and b1.staff_info = t1.staff_info and b1.staff_name = t1.staff_name
left join c c1 on c1.action = t1.action and c1.p_date = t1.p_date and c1.staff_info = t1.staff_info and c1.staff_name = t1.staff_name and c1.type = '漏揽收扫描'
left join c c2 on c2.action = t1.action and c2.p_date = t1.p_date and c2.staff_info = t1.staff_info and c2.staff_name = t1.staff_name and c2.type = '虚假撤销'
left join d d1 on d1.action = t1.action and d1.p_date = t1.p_date and d1.staff_info = t1.staff_info and d1.staff_name = t1.staff_name
left join e e1 on e1.action = t1.action and e1.p_date = t1.p_date and e1.staff_info = t1.staff_info and e1.staff_name = t1.staff_name
left join f f1 on f1.action = t1.action and f1.p_date = t1.p_date and f1.staff_info = t1.staff_info and f1.staff_name = t1.staff_name
left join g g1 on g1.action = t1.action and g1.p_date = t1.p_date and g1.staff_info = t1.staff_info and g1.staff_name = t1.staff_name and g1.type = '个人罚款'
left join g g2 on g2.action = t1.action and g2.p_date = t1.p_date and g2.staff_info = t1.staff_info and g2.staff_name = t1.staff_name and g2.type = '加盟商罚款'
order by 1,2,3,4

;



with a as
    (-- 禁运品
        select
            case
                when c.duty_level in (1,2) then '已判责数量 / Resonsible person had been Judged'
                when c.duty_level is null then '无需追责数量/ No need for accountability'
            end action
            ,'禁运品' type
            ,date(c.updated_at) p_date
            ,c.operator staff_info
            ,si.name staff_name
            ,count(c.pno) pnt
        from my_bi.contraband c
        left join my_bi.staff_info si on si.id = c.operator
        where
            c.status = 2
            and c.operator not in (0,10000,10001)
            and c.updated_at >= '${sdate}'
            and c.updated_at < date_add('${edate}', interval 1 day)
        group by 1,2,3,4
    )
, b as
    (
        select
            case
                when pvr.judgment_result in (0,1,3) then '已判责数量 / Resonsible person had been Judged'
                when pvr.judgment_result in (2) then '无需追责数量/ No need for accountability'
            end action
            ,'违规件举报' type
            ,date(pvr.handled_at) p_date
            ,pvr.handler_id staff_info
            ,pvr.handler_name  staff_name
            ,count(pvr.pno) pnt
        from my_bi.parcel_violate_rules pvr
        where
            pvr.status = 2
            and pvr.handler_id not in (0,10000,10001)
            and pvr.handled_at >= '${sdate}'
            and pvr.handled_at < date_add('${edate}', interval 1 day)
        group by 1,2,3,4
    )
, c as
    (
        select
            case
                when put.process_status = 4 then '已判责数量 / Resonsible person had been Judged'
                when put.process_status = 5 then '无需追责数量/ No need for accountability'
            end action
            ,case put.punishment_type
                when 1 then '漏揽收扫描'
                when 2 then '虚假撤销'
            end type
            ,date(put.process_time) p_date
            ,put.communicator staff_info
            ,si.name staff_name
            ,count(put.pno) pnt
        from my_bi.parcel_unpickup_task put
        left join my_bi.staff_info si on si.id = put.communicator
        where
            put.process_status in (4,5)
            and put.communicator not in (0,10000,10001)
            and put.process_time >= '${sdate}'
            and put.process_time < date_add('${edate}', interval 1 day)
        group by 1,2,3,4
    )
, d as
    (
        select
            case
                when tfa.state = 2 then '已判责数量 / Resonsible person had been Judged'
                when tfa.state = 3 then '无需追责数量/ No need for accountability'
            end action
            ,'标记超大件，违禁物品审核' type
            ,date(tfa.process_time) p_date
            ,tfa.operator_id staff_info
            ,tfa.operator_name staff_name
            ,count(tfa.id) pnt
        from my_bi.ticket_cancel_fake_mark tfa
        where
            tfa.process_time >= '${sdate}'
            and tfa.operator_id not in (0,10000,10001)
            and tfa.process_time < date_add('${edate}', interval 1 day)
            and tfa.state in (2,3)
        group by 1,2,3,4
    )
,  e as
    (
        select
            case
                when tfa.state = 2 then '已判责数量 / Resonsible person had been Judged'
                when tfa.state = 3 then '无需追责数量/ No need for accountability'
            end action
            ,'标记电话号码空号' type
            ,date(tfa.deal_time) p_date
            ,tfa.admin_id staff_info
            ,tfa.admin_name staff_name
            ,count(tfa.id) pnt
        from my_bi.ticket_fake_audit_marker tfa
        where
            tfa.deal_time >= '${sdate}'
            and tfa.admin_id not in (0,10000,10001)
            and tfa.deal_time < date_add('${edate}', interval 1 day)
            and tfa.state in (2,3)
        group by 1,2,3,4
    )
, f as
    ( -- 集体出发
        select
            case
                when aq.isappeal in (3,4) then '已判责数量 / Resonsible person had been Judged'
                when aq.isappeal = 5 or aq.isdel = 1 then '无需追责数量/ No need for accountability'
            end action
            ,'集体处罚' type
            ,date(aq.handle_time) p_date
            ,aq.handle_staff_id staff_info
            ,si.name staff_name
            ,count(distinct aq.qaqc_merge_key) pnt
        from my_bi.abnormal_message am
        left join my_bi.abnormal_qaqc aq on aq.qaqc_merge_key = am.average_merge_key
        left join my_bi.staff_info si on si.id = aq.handle_staff_id
        where
            am.abnormal_object = 1
            and aq.type = 1
            and aq.handle_staff_id not in (0,10000,10001)
            and aq.handle_time >= '${sdate}'
            and aq.handle_time < date_add('${edate}', interval 1 day)
            and (aq.isappeal in (3,4,5) or aq.isdel = 1)
            and aq.handle_staff_id not in (10000,10001)
        group by 1,2,3,4
    )
, g as
    (
        select
            case
                when aq.isappeal in (3,4) then '已判责数量 / Resonsible person had been Judged'
                when aq.isappeal = 5 or aq.isdel = 1 then '无需追责数量/ No need for accountability'
            end action
            ,case am.abnormal_object
                when 0 then '个人罚款'
                when 1 then '集体罚款'
                when 2 then '加盟商罚款'
            end as type
            ,date(aq.handle_time) p_date
            ,aq.handle_staff_id staff_info
            ,si.name staff_name
            ,count(distinct aq.abnormal_message_id) pnt
        from my_bi.abnormal_message am
        left join my_bi.abnormal_qaqc aq on aq.abnormal_message_id = am.id
        left join my_bi.staff_info si on si.id = aq.handle_staff_id
        where
            am.abnormal_object in (2,0)
            and aq.type in (2,3)
            and aq.handle_staff_id not in (0,10000,10001)
            and aq.handle_time >= '${sdate}'
            and aq.handle_time < date_add('${edate}', interval 1 day)
            and (aq.isappeal in (3,4,5) or aq.isdel = 1)
            and aq.handle_staff_id not in (10000,10001)
        group by 1,2,3,4
    )
select
    a.p_date
    ,a.staff_info
    ,a.staff_name
    ,sum(a.pnt) pnt_total
from
    (
        select * from a a1
        union all
        select * from b b1
        union all
        select * from c c1
        union all
        select * from d d1
        union all
        select * from e e1
        union all
        select * from f f1
        union all
        select * from g g1
    ) a
group by 1,2,3