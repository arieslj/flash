select
    a.p_date
    ,a.store_name
    ,count(distinct a.staff_info_id) as staff_count
    ,count(distinct a.id) as parcel_count
    ,count(distinct a.id) / count(distinct a.staff_info_id) as parcel_per_staff
from
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+07:00')) p_date
            ,pr.store_name
           -- ,ddd.CN_element
            ,pr.staff_info_id
            ,case
                when pr.route_action in ('ARRIVAL_GOODS_VAN_CHECK_SCAN', 'DEPARTURE_GOODS_VAN_CK_SCAN') then json_extract(pr.extra_value, '$.proofId')
                when pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN') and json_extract(pr.extra_value, '$.packPno') is not null then json_extract(pr.extra_value, '$.packPno')
                else pr.id
            end as id
        from rot_pro.parcel_route pr
        join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > '2024-07-19 17:00:00'
            and hsi.job_title in (661, 220, 1412)
    ) a
group by
    a.p_date
    ,a.store_name

;


select
    distinct
    date(convert_tz(pr.routed_at, '+00:00', '+07:00')) 日期
    ,pr.store_name 网点
    ,ddd.CN_element 路由动作
    ,pr.staff_info_id 员工
    ,case
        when pr.route_action in ('ARRIVAL_GOODS_VAN_CHECK_SCAN', 'DEPARTURE_GOODS_VAN_CK_SCAN') then json_extract(pr.extra_value, '$.proofId')
        when pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN') and json_extract(pr.extra_value, '$.packPno') is not null then json_extract(pr.extra_value, '$.packPno')
        else pr.pno
    end as 参考ID
from rot_pro.parcel_route pr
join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.routed_at > '2024-07-31 17:00:00'
    and hsi.job_title in (661, 220, 1412)

;
select
    ddd.CN_element 问题件类型
    ,pr.pno 包裹
    ,pr.staff_info_id 操作人
    ,hjt.job_name 操作人职位
    ,pr.store_name HUB
    ,convert_tz(pr.routed_at, '+00:00', '+07:00')  操作时间
from rot_pro.parcel_route pr
join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
where
    pr.routed_at > '2024-07-31 17:00:00'
    and pr.routed_at < '2024-08-05 17:00:00'
    and hsi.job_title in (661, 220, 1412)
    and pr.route_action = 'DIFFICULTY_HANDOVER'
;




select
    a1.staff_info_id
    ,a1.job_name 职位
    ,a1.ss_name HUB
    ,a1.date 日期
    ,p1.hn_cnt 上报无头件数
    ,p2.hn_cnt 认领无头件数
    ,di.id_cnt 提交问题件数
    ,co.id_cnt 禁运品件数
    ,pvr.id_cnt 违规品举报数
    ,put.id_cnt 漏揽收_虚假撤销处理件数
    ,wo.id_cnt 发起工单数
    ,wor.id_cnt 回复工单数
from
    (
        select
            hsi.staff_info_id
            ,hsi.sys_store_id
            ,da.date
            ,hsi.job_name
            ,hsi.name ss_name
        from
            (
                select
                    hsi.staff_info_id
                    ,hsi.sys_store_id
                    ,hjt.job_name
                    ,ss.name
                from bi_pro.hr_staff_info hsi
                left join bi_pro.hr_job_title hjt on hsi.job_title = hjt.id
                left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
                where
                    hsi.state = 1
                    and hsi.job_title in (661, 220, 1412)
            ) hsi
        cross join
            (
                select
                    ot.date
                from tmpale.ods_th_dim_date ot
                where
                    ot.date >= '2024-08-01'
                    and ot.date < '2024-08-14'
            ) da
    ) a1
left join
    (
        select
            date(convert_tz(ph.created_at, '+00:00', '+07:00')) p_date
            ,ph.submit_staff_id
            ,count(ph.hno) hn_cnt
        from fle_staging.parcel_headless ph
        where
            ph.created_at > '2024-07-31 17:00:00'
            and ph.created_at < '2024-08-13 17:00:00'
        group by 1,2
    ) p1 on p1.p_date = a1.date and p1.submit_staff_id = a1.staff_info_id
left join
    (
        select
            ph.claim_staff_id
            ,date(convert_tz(ph.claim_at, '+00:00', '+07:00')) p_date
            ,count(ph.hno) hn_cnt
        from fle_staging.parcel_headless ph
        where
            ph.claim_at > '2024-07-31 17:00:00'
            and ph.claim_at < '2024-08-13 17:00:00'
        group by 1,2
    ) p2 on p2.p_date = a1.date and p2.claim_staff_id = a1.staff_info_id
left join
    (
        select
            date(convert_tz(di.created_at, '+00:00', '+07:00')) p_date
            ,di.staff_info_id
            ,count(di.id) id_cnt
        from fle_staging.diff_info di
        where
            di.created_at > '2024-07-31 17:00:00'
            and di.created_at < '2024-08-13 17:00:00'
        group by 1,2
    ) di on di.p_date = a1.date and di.staff_info_id = a1.staff_info_id
left join
    ( -- 禁运品
        select
            co.report_staff_id
            ,date (co.created_at) p_date
            ,count(co.id) id_cnt
        from bi_pro.contraband co
        where
            co.created_at > '2024-08-01'
        group by 1,2
    ) co on co.p_date = a1.date and co.report_staff_id = a1.staff_info_id
left join
    ( -- 违规件举报
        select
            date (pvr.created_at) p_date
            ,pvr.operator_id
            ,count(pvr.id) id_cnt
        from bi_pro.parcel_violate_rules pvr
        where
            pvr.created_at > '2024-08-01'
        group by 1,2
    ) pvr on pvr.p_date = a1.date and pvr.operator_id = a1.staff_info_id
left join
    (
        select
            date (put.create_at) p_date
            ,put.communicator
            ,count(put.id) id_cnt
        from bi_pro.parcel_unpickup_task put
        where
            put.create_at > '2024-08-01'
        group by 1,2
    ) put on put.p_date = a1.date and put.communicator = a1.staff_info_id
left join
    (
        select
            date (wo.created_at) p_date
            ,wo.created_staff_info_id
            ,count(wo.id) id_cnt
        from bi_pro.work_order wo
        where
            wo.created_at > '2024-08-01'
        group by 1,2
    ) wo on wo.p_date = a1.date and wo.created_staff_info_id = a1.staff_info_id
left join
    (
        select
            date (wor.created_at) p_date
            ,wor.staff_info_id
            ,count(wor.id) id_cnt
        from bi_pro.work_order_reply wor
        where
            wor.created_at > '2024-08-01'
        group by 1,2
    ) wor on wor.p_date = a1.date and wor.staff_info_id = a1.staff_info_id
