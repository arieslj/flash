with t as
    (
                select
            *
        from
            (
                select
                    di.pno
                    ,di.created_at
                    ,di.store_id
                    ,cdt.organization_id
                    ,cdt.operator_id
                    ,count() over (partition by di.pno) diff_count
                    ,cdt.updated_at
                from fle_staging.diff_info di
                join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
                join fle_staging.sys_store ss on ss.id = cdt.organization_id
                where
                    di.created_at > '2024-04-30 17:00:00'
                    and di.diff_marker_category in (2,17)
                    and cdt.negotiation_result_category in (5,6)
                    and ss.category in (5,7)
            ) a
        where
            a.diff_count > 1
    )
select
    t1.pno 收件人拒收运单号
    ,ss2.name 提交问题件网点
    ,sta.staff_info_id 标记收件人拒收的快递员工号
    ,convert_tz(t1.created_at, '+00:00', '+07:00') 快递员标记问题件日期
    ,ss.name 处理问题件网点
    ,t1.operator_id 处理问题件员工工号
    ,t1.diff_count 解锁继续派送次数
    ,t1.updated_at 处理日期
from t t1
left join fle_staging.sys_store ss on ss.id = t1.organization_id
left join fle_staging.sys_store ss2 on ss2.id = t1.store_id
left join
    (
        select
            td.pno
            ,td.staff_info_id
            ,row_number() over (partition by td.pno order by tdm.created_at desc) rk
        from fle_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join fle_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        where
            tdm.marker_id in (2,17)
            and tdm.created_at < t1.created_at
    ) sta on t1.pno = sta.pno and sta.rk = 1