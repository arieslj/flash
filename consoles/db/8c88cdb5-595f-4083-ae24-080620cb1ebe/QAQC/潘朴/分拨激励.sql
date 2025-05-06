-- 修复转运比例
with t as
    (
        select
            dor.pno
            ,dor.state
            ,dor.id
            ,dor.store_id
            ,dor.updated_at
        from fle_staging.diff_operation_record dor
        join fle_staging.diff_info di on di.id = dor.diff_info_id
        where
            dor.created_at > '2024-10-31 17:00:00'
            and dor.created_at < '2024-11-30 17:00:00'
    )
select
    ss.name HUB
    ,count(distinct t1.pno) 上报包裹数
    ,count(distinct if(a.pno is not null, t1.pno, null)) 转运包裹数
    ,count(distinct if(a.pno is not null, t1.pno, null)) / count(distinct t1.pno) 修复转运比
from t t1
left join fle_staging.sys_store ss on ss.id = t1.store_id
left join
    (
        select
            pr.pno
            ,pr.store_id
        from rot_pro.parcel_route pr
        join
            (
                select
                    t1.pno
                    ,t1.store_id
                from t t1
                where
                    t1.state = 4
            ) t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) a on a.pno = t1.pno
group by ss.name
;

-- parcel_lose_duty_damaged_reasons_9
select
    ss.name HUB
    ,count(distinct plt.pno) 破损判责数量
    ,count(distinct if(plt.duty_reasons = 'parcel_lose_duty_damaged_reasons_9', plt.pno, null)) 二次包装无上报判责数量
    ,count(distinct if(plt.duty_reasons = 'parcel_lose_duty_damaged_reasons_9', plt.pno, null)) / count(distinct plt.pno) 二次包装无上报比例
from bi_pro.parcel_lose_task plt
join fle_staging.customer_diff_ticket cdt on cdt.id = plt.source_id
left join fle_staging.diff_info di on di.id = cdt.diff_info_id
left join fle_staging.sys_store ss on ss.id = di.store_id
where
    cdt.created_at > '2024-10-31 17:00:00'
    and cdt.created_at < '2024-11-30 17:00:00'
    and plt.source = 4
    and plt.state = 6
    and plt.duty_result = 2
group by ss.name


;


with t as
    (
        select
            dor.pno
            ,dor.state
            ,dor.id
            ,dor.store_id
            ,dor.created_at
            ,dor.updated_at
        from fle_staging.diff_operation_record dor
        join fle_staging.diff_info di on di.id = dor.diff_info_id
        where
            dor.created_at > '2024-10-31 17:00:00'
            and dor.created_at < '2024-11-30 17:00:00'
    )
select
    ss.name HUB
    ,count(distinct t1.pno) 上报包裹数
    ,count(distinct if(a.pno is not null, t1.pno, null)) 转运包裹数
    ,count(distinct if(a.pno is not null, t1.pno, null)) / count(distinct t1.pno) 修复转运比
from t t1
left join fle_staging.sys_store ss on ss.id = t1.store_id
left join
    (
        select
            pr.pno
            ,pr.store_id
        from rot_pro.parcel_route pr
        join
            (
                select
                    t1.pno
                    ,t1.store_id
                from t t1
                where
                    t1.state = 4
                    and timestampdiff(hour, t1.created_at, t1.updated_at) <= 24
            ) t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) a on a.pno = t1.pno
group by ss.name

;


select
    ph.submit_store_name
    ,count(distinct ph.hno) 提交无头件数
    ,count(distinct if(ph.state = 2, ph.hno, null)) 已处理无头件数
    ,count(distinct if(ph.state = 2, ph.hno, null)) / count(distinct ph.hno) 已处理比例
from fle_staging.parcel_headless ph
where
    ph.created_at > '2024-10-31 17:00:00'
    and ph.created_at < '2024-11-30 17:00:00'
group by ph.submit_store_name


;


select
    ph.submit_store_name
    ,count(distinct ph.hno) 认领无头件数
    ,count(distinct if(pi.state = 5, ph.hno, null)) 妥投无头件数
    ,count(distinct if(pi.state = 5, ph.hno, null)) / count(distinct ph.hno) 妥投比例
from fle_staging.parcel_headless ph
left join fle_staging.parcel_info pi on pi.pno = ph.pno
where
    ph.created_at > '2024-10-31 17:00:00'
    and ph.created_at < '2024-11-30 17:00:00'
    and ph.state = 2
group by ph.submit_store_name