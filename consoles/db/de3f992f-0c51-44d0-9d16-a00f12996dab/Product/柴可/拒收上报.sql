
-- 客户ID
select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
            sc.cfg_value
        from fle_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a1
cross join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from fle_staging.parcel_reject_report_info prr
        left join fle_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join fle_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 17:00:00'
            and prr.created_at < '2024-01-18 17:00:00'
           -- and prr.state = 2
        group by 1
    ) a2

union all

select
    a2.client_id 客户ID
    ,a2.当日拒收问题件量
    ,a2.当日提交拒收复核单量
from
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from fle_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a1
join
    (
        select
            pi.client_id
            ,count(distinct if(prr.state in (1,2), prr.pno, null)) 当日拒收问题件量
            ,count(distinct if(prr.state in (2), prr.pno, null)) 当日提交拒收复核单量
        from fle_staging.parcel_reject_report_info prr
        left join fle_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join fle_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 17:00:00'
            and prr.created_at < '2024-01-18 17:00:00'
           -- and prr.state = 2
        group by 1
    ) a2 on a2.client_id = a1.client_id

;

-- 网点

select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a2.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from fle_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from fle_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join fle_staging.sys_store ss
    ) a1
cross join
    (
        select
              pc.*
              ,client_id
        from
            (
                select
                    *
                from fle_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
                    and sc.cfg_value != 'all'
            ) pc
        lateral view explode(split(pc.cfg_value, ',')) id as client_id
    ) a2
join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from fle_staging.parcel_reject_report_info prr
        left join fle_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join fle_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
#             prr.created_at >= date_sub(curdate(), interval 7 hour)
            prr.created_at >= '2024-01-17 17:00:00'
            and prr.created_at < '2024-01-18 17:00:00'
    ) a3 on a3.store_id = a1.store_id and a3.client_id = a2.client_id
cross join
    (
        select
            sc.cfg_value
        from fle_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_th_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join fle_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5

union all


select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,a1.store_id 网点ID
    ,a3.client_id 客户ID
    ,count(distinct if(a3.state in (1,2), a3.pno, null)) 当日拒收问题件数量
    ,count(distinct if(a3.state in (1,2) and ( a3.cod_amount > val.cfg_value or a3.insure_declare_value > val.cfg_value or pai.cogs_amount > val.cfg_value ), a3.pno, null)) 当日满足强制拒收复核需上报的量
    ,count(distinct if(a3.state in (2), a3.pno, null)) 当日提交拒收复核单数量
from
    (
        select
            a.*
        from
            (
                select
                      pc.*
                      ,store_id
                from
                    (
                        select
                            *
                        from fle_staging.sys_configuration sc
                        where
                            sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                            and sc.cfg_value != 'all'
                    ) pc
                lateral view explode(split(pc.cfg_value, ',')) id as store_id
            ) a

        union all

        select
            pc.*
            ,ss.id store_id
        from
            (
                select
                    *
                from fle_staging.sys_configuration sc
                where
                    sc.cfg_key = 'reject.warehouse.report.by.storeId.enabled'
                    and cfg_value = 'all'
            ) pc
        cross join fle_staging.sys_store ss
    ) a1
cross join
    (
        select
            *
        from fle_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.warehouse.report.by.customerId.enabled'
            and sc.cfg_value = 'all'
    ) a2
cross join
    (
        select
            prr.pno
            ,prr.store_id
            ,prr.state
            ,pi.client_id
            ,pi.cod_amount
            ,pi.insure_declare_value
        from fle_staging.parcel_reject_report_info prr
        left join fle_staging.parcel_pno_log ppl on ppl.replace_pno = upper(prr.pno)
        left join fle_staging.parcel_info pi on coalesce(ppl.initial_pno, upper(prr.pno)) = pi.pno
        where
            prr.created_at >= '2024-01-17 17:00:00'
            and prr.created_at < '2024-01-18 17:00:00'
    ) a3 on a3.store_id = a1.store_id
cross join
    (
        select
            sc.cfg_value
        from fle_staging.sys_configuration sc
        where
            sc.cfg_key = 'reject.force.report.high.value.min.config'
    ) val
left join dwm.dim_th_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join fle_staging.parcel_additional_info pai on pai.pno = a3.pno
group by 1,2,3,4,5

