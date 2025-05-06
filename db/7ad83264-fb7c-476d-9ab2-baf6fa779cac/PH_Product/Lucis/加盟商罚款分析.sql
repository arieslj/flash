-- 1.1 工单处理情况

select
    a.*
    ,case
        when timestampdiff(minute , a.created_at, a.第一次回复时间)/60 < 24 then 0
        when timestampdiff(minute , a.created_at, a.第一次回复时间)/60 >= 24 and timestampdiff(minute , a.created_at, a.第一次回复时间)/60 < 48 then 1
        when timestampdiff(minute , a.created_at, a.第一次回复时间)/60 >= 48 and timestampdiff(minute , a.created_at, a.第一次回复时间)/60 < 72 then 2
        when timestampdiff(minute , a.created_at, a.第一次回复时间)/60 > 72 then 3
    end  回复时间
    ,case
        when timestampdiff(minute , a.created_at, a.工单关闭时间)/60 < 24 then 0
        when timestampdiff(minute , a.created_at, a.工单关闭时间)/60 >= 24 and timestampdiff(minute , a.created_at, a.工单关闭时间)/60 < 48 then 1
        when timestampdiff(minute , a.created_at, a.工单关闭时间)/60 >= 48 and timestampdiff(minute , a.created_at, a.工单关闭时间)/60 < 72 then 2
        when timestampdiff(minute , a.created_at, a.工单关闭时间)/60 > 72 then 3
    end  关闭时间
from
    (
        select
            wo.order_no 工单编号
            ,fp.id 加盟商ID
            ,wo.created_at
            ,case wo.order_type
                when 1 then '查找运单'
                when 2 then '加快处理'
                when 3 then '调查员工'
                when 4 then '其他'
                when 5 then '网点信息维护提醒'
                when 6 then '培训指导'
                when 7 then '异常业务询问'
                when 8 then '包裹丢失'
                when 9 then '包裹破损'
                when 10 then '货物短少'
                when 11 then '催单'
                when 12 then '有发无到'
                when 13 then '上报包裹不在集包里'
                when 16 then '漏揽收'
                when 50 then '虚假撤销'
                when 17 then '已签收未收到'
                when 18 then '客户投诉'
                when 19 then '修改包裹信息'
                when 20 then '修改 COD 金额'
                when 21 then '解锁包裹'
                when 22 then '申请索赔'
                when 23 then 'MS 问题反馈'
                when 24 then 'FBI 问题反馈'
                when 25 then 'KA System 问题反馈'
                when 26 then 'App 问题反馈'
                when 27 then 'KIT 问题反馈'
                when 28 then 'Backyard 问题反馈'
                when 29 then 'BS/FH 问题反馈'
                when 30 then '系统建议'
                when 31 then '申诉罚款'
                else wo.order_type
            end  工单类型
            ,pi.client_id
            ,coalesce(ss2.name, sd.name) 发起部门
            ,wo.closed_at 工单关闭时间
            ,min(wor.created_at) 第一次回复时间
        from ph_bi.work_order wo
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        left join ph_staging.franchisee_profile fp on fp.id= ss.franchisee_id -- 加盟商ID
        left join ph_staging.parcel_info pi on pi.pno = wo.pnos
        left join ph_staging.sys_store ss2 on ss2.id = wo.created_store_id
        left join ph_staging.sys_department sd on sd.id = wo.created_store_id
        left join ph_bi.work_order_reply wor on wo.id = wor.order_id
        where
            ss.category = 6
            and wo.created_at >= '2023-06-01'
            and wo.created_at < '2023-09-01'
        group by 1
    ) a


;
-- ---------------------------------------

-- 1.2 工单处理情况

select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,plt.updated_at 判责时间
    ,plt.pno
    ,case plt.source
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
    ,ss.name 责任网点
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.ka_profile kp on kp.id = plt.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.updated_at >= '2023-06-01'
    and plt.updated_at < '2023-09-01'
    and ss.category = 6
group by 1,2,3,4
;



-- --------------------------------------------------------
-- 1.3 包裹未及时中转

with t as
(
    select
        pi.pno
        ,case
            when bc.`client_id` is not null then bc.client_name
            when kp.id is not null and bc.client_id is null then '普通ka'
            when kp.`id` is null then '小c'
        end as client_type
        ,ss.name pick_store
        ,ss.id storeid
    from ph_staging.parcel_info pi
    left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
    left join ph_staging.ka_profile kp on kp.id = pi.client_id
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    where
        pi.created_at >= '2023-07-31 16:00:00'
        and pi.created_at < '2023-08-31 16:00:00'
        and ss.category = 6 -- FH
        and pi.state < 9
),
res as
    (
        select
            t1.*
            ,min(pr.routed_at) min_route_at
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.route_action = 'RECEIVED' and pr.store_id = t1.storeid
        where
            pr.routed_at > '2023-07-31 16:00:00'
        group by 1,2,3,4
    )

select
    t1.pno 包裹
    ,t1.client_type 客户类型
    ,t1.pick_store 揽收网点
    ,convert_tz(t2.min_route_at, '+00:00', '+08:00')  收件入仓时间
    ,a.route_action 揽收后第一个有效路由
    ,a.store_name 揽收后第一个有效路由网点
    ,convert_tz(a.routed_at, '+00:00', '+08:00')  揽收后第一个有效路由时间
    ,case
        when timestampdiff(minute , t2.min_route_at, a.routed_at)/60 < 24 then 0
        when timestampdiff(minute , t2.min_route_at, a.routed_at)/60 >= 24 and timestampdiff(minute , t2.min_route_at, a.routed_at)/60 < 48 then 1
        when timestampdiff(minute , t2.min_route_at, a.routed_at)/60 >= 48 and timestampdiff(minute , t2.min_route_at, a.routed_at)/60 < 72 then 2
        when timestampdiff(minute , t2.min_route_at, a.routed_at)/60 > 72 then 3
     end 揽收与后续第一个路由时间差
from t t1
left join res t2 on t2.pno = t1.pno
left join
    (
        select
            t2.*
            ,pr.route_action
            ,pr.store_id pr_store_id
            ,pr.store_name
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join res t2 on t2.pno = pr.pno
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action
        where
            pr.routed_at > t2.min_route_at
            and pr.routed_at > '2023-07-31 16:00:00'
            and pr.store_id != t2.storeid
    ) a on a.pno = t1.pno and a.rk = 1

;


select
    count(pi.pno)
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
where
    pi.created_at >= '2023-07-31 16:00:00'
    and pi.created_at < '2023-08-31 16:00:00'
    and ss.category = 6 -- FH
    and pi.state < 9