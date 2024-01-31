with t as
(
    select
        di.pno
        ,ddd.CN_element
        ,convert_tz(cdt.created_at, '+00:00', '+08:00') creat_time
        ,if(cdt.state = 1, convert_tz(cdt.updated_at, '+00:00', '+08:00'), null) deal_time
        ,if(cdt.state = 1, 'y', 'n') deal_or_not
        ,'PDC' ss_category
        ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 12 hour)), interval 2 hour), 'before_12', 'should_today') deal_select
        ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 12 hour)), interval 2 hour), date_add(date(date_add(cdt.created_at, interval 12 hour)),interval 12 hour), date_add(date(date_add(cdt.created_at, interval 12 hour)),interval 24 hour)) should_deal_time
        ,date(date_add(cdt.created_at, interval 12 hour)) date_d
    from ph_staging.customer_diff_ticket cdt
    left join ph_staging.diff_info di on di.id = cdt.diff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
    left join ph_staging.sys_store ss on ss.id = cdt.organization_id
    left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
    where
        cdt.organization_type = 1 -- FH&miniCS
        and bc.client_id is  null
        and ss.category in (14) -- PDC
        and date(date_add(cdt.created_at, interval 12 hour)) >= '${begin_date}'
        and date(date_add(cdt.created_at, interval 12 hour)) <= '${end_date}'
        and di.diff_marker_category not in (38,39,2,17,32,69,7,22)

    union all

    select
        di.pno
        ,ddd.CN_element
        ,convert_tz(cdt.created_at, '+00:00', '+08:00') creat_time
        ,if(cdt.state = 1, convert_tz(cdt.updated_at, '+00:00', '+08:00'), null) deal_time
        ,if(cdt.state = 1, 'y', 'n') deal_or_not
        ,if(ss.category = 1, 'SP', 'FH') ss_category
        ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 14 hour)), interval 2 hour), 'before_12', 'should_today') deal_select
        ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 14 hour)), interval 2 hour), date_add(date(date_add(cdt.created_at, interval 14 hour)),interval 12 hour), date_add(date(date_add(cdt.created_at, interval 14 hour)),interval 24 hour)) should_deal_time
        ,date(date_add(cdt.created_at, interval 14 hour)) date_d
    from ph_staging.customer_diff_ticket cdt
    left join ph_staging.diff_info di on di.id = cdt.diff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
    left join ph_staging.sys_store ss on ss.id = cdt.organization_id
    left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
    where
        cdt.organization_type = 1 -- FH&miniCS
        and bc.client_id is  null
        and ss.category in (1,6) -- PDC
        and di.diff_marker_category not in (38,39,2,17,32,69,7,22)
        and date(date_add(cdt.created_at, interval 14 hour)) >= '${begin_date}'
        and date(date_add(cdt.created_at, interval 14 hour)) <= '${end_date}'
)
select
    total.*

    , pdc.before_12总量 before_12总量_pdc
    , pdc.before_12已处理量 before_12已处理量_pdc
    , pdc.before_12处理率 before_12处理率_pdc
    , pdc.before_12及时量 before_12及时量_pdc
    , pdc.before_12及时率 before_12及时率_pdc
    , pdc.before_12未处理量 before_12未处理量_pdc
    , pdc.should_today总量 should_today总量_pdc
    , pdc.should_today已处理量 should_today已处理量_pdc
    , pdc.should_today处理率 should_today处理率_pdc
    , pdc.should_today及时量 should_today及时量_pdc
    , pdc.should_today及时率 should_today及时率_pdc
    , pdc.should_today未处理量 should_today未处理量_pdc

    , sp.before_12总量 before_12总量_sp
    , sp.before_12已处理量 before_12已处理量_sp
    , sp.before_12及时量 before_12及时量_sp
    , sp.before_12未处理量 before_12未处理量_sp
    , sp.should_today总量 should_today总量_sp
    , sp.should_today已处理量 should_today已处理量_sp
    , sp.should_today及时量 should_today及时量_sp
    , sp.should_today未处理量 should_today未处理量_sp
    , sp.before_12处理率 before_12处理率_sp
    , sp.before_12及时率 before_12及时率_sp
    , sp.should_today处理率 should_today处理率_sp
    , sp.should_today及时率 should_today及时率_sp

    , fh.before_12总量 before_12总量_fh
    , fh.before_12已处理量 before_12已处理量_fh
    , fh.before_12及时量 before_12及时量_fh
    , fh.before_12未处理量 before_12未处理量_fh
    , fh.should_today总量 should_today总量_fh
    , fh.should_today已处理量 should_today已处理量_fh
    , fh.should_today及时量 should_today及时量_fh
    , fh.should_today未处理量 should_today未处理量_fh
    , fh.before_12处理率 before_12处理率_fh
    , fh.before_12及时率 before_12及时率_fh
    , fh.should_today处理率 should_today处理率_fh
    , fh.should_today及时率 should_today及时率_fh
from
    (
        select
            t1.date_d
            ,t1.CN_element
            ,count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12总量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.pno, null)) before_12已处理量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.pno, null))/count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12处理率
            ,count(if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.pno, null)) before_12及时量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.pno, null))/count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12及时率
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.pno, null)) before_12未处理量
            ,count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today总量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.pno, null)) should_today已处理量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.pno, null))/count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today处理率
            ,count(if(t1.deal_select = 'should_today' and t1.deal_time < t1.should_deal_time, t1.pno, null)) should_today及时量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_time < t1.should_deal_time, t1.pno, null))/count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today及时率
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.pno, null)) should_today未处理量
        from t t1
        group by 1,2
        order by 1,2
    ) total
left join
    (
        select
            t1.date_d
            ,t1.CN_element
            ,count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12总量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.pno, null)) before_12已处理量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.pno, null))/count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12处理率
            ,count(if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.pno, null)) before_12及时量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.pno, null))/count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12及时率
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.pno, null)) before_12未处理量
            ,count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today总量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.pno, null)) should_today已处理量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.pno, null))/count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today处理率
            ,count(if(t1.deal_select = 'should_today' and t1.deal_time < t1.should_deal_time, t1.pno, null)) should_today及时量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_time < t1.should_deal_time, t1.pno, null))/count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today及时率
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.pno, null)) should_today未处理量
        from t t1
        where
            t1.ss_category = 'PDC'
        group by 1,2
        order by 1,2
    ) pdc on pdc.date_d = total.date_d and pdc.CN_element = total.CN_element
left join
    (
        select
            t1.date_d
            ,t1.CN_element
            ,count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12总量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.pno, null)) before_12已处理量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.pno, null))/count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12处理率
            ,count(if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.pno, null)) before_12及时量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.pno, null))/count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12及时率
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.pno, null)) before_12未处理量
            ,count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today总量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.pno, null)) should_today已处理量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.pno, null))/count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today处理率
            ,count(if(t1.deal_select = 'should_today' and t1.deal_time < t1.should_deal_time, t1.pno, null)) should_today及时量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_time < t1.should_deal_time, t1.pno, null))/count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today及时率
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.pno, null)) should_today未处理量
        from t t1
        where
            t1.ss_category = 'SP'
        group by 1,2
        order by 1,2
    ) sp on sp.date_d = total.date_d and sp.CN_element = total.CN_element
left join
    (
        select
            t1.date_d
            ,t1.CN_element
            ,count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12总量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.pno, null)) before_12已处理量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.pno, null))/count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12处理率
            ,count(if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.pno, null)) before_12及时量
            ,count(if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.pno, null))/count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12及时率
            ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.pno, null)) before_12未处理量
            ,count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today总量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.pno, null)) should_today已处理量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.pno, null))/count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today处理率
            ,count(if(t1.deal_select = 'should_today' and t1.deal_time < t1.should_deal_time, t1.pno, null)) should_today及时量
            ,count(if(t1.deal_select = 'should_today' and t1.deal_time < t1.should_deal_time, t1.pno, null))/count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today及时率
            ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.pno, null)) should_today未处理量
        from t t1
        where
            t1.ss_category = 'FH'
        group by 1,2
        order by 1,2
    ) fh on fh.date_d = total.date_d and fh.CN_element = total.CN_element
;
-- ------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------
with t as
(
    select
        di.pno
        ,ddd.CN_element
        ,ss.name ss_name
        ,convert_tz(cdt.created_at, '+00:00', '+08:00') creat_time
        ,if(cdt.state = 1, convert_tz(cdt.updated_at, '+00:00', '+08:00'), null) deal_time
        ,if(cdt.state = 1, 'y', 'n') deal_or_not
        ,'PDC' ss_category
        ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 12 hour)), interval 2 hour), 'before_12', 'should_today') deal_select
        ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 12 hour)), interval 2 hour), date_add(date(date_add(cdt.created_at, interval 12 hour)),interval 12 hour), date_add(date(date_add(cdt.created_at, interval 12 hour)),interval 24 hour)) should_deal_time
        ,date(date_add(cdt.created_at, interval 12 hour)) date_d
    from ph_staging.customer_diff_ticket cdt
    left join ph_staging.diff_info di on di.id = cdt.diff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
    left join ph_staging.sys_store ss on ss.id = cdt.organization_id
    left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
    where
        cdt.organization_type = 1 -- FH&miniCS
        and bc.client_id is  null
        and ss.category in (14) -- PDC
        and di.diff_marker_category not in (38,39,2,17,32,69,7,22)
        and date(date_add(cdt.created_at, interval 12 hour)) >= '${begin_date}'
        and date(date_add(cdt.created_at, interval 12 hour)) <= '${end_date}'

    union all

    select
        di.pno
        ,ddd.CN_element
        ,ss.name ss_name
        ,convert_tz(cdt.created_at, '+00:00', '+08:00') creat_time
        ,if(cdt.state = 1, convert_tz(cdt.updated_at, '+00:00', '+08:00'), null) deal_time
        ,if(cdt.state = 1, 'y', 'n') deal_or_not
        ,if(ss.category = 1, 'SP', 'FH') ss_category
        ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 14 hour)), interval 2 hour), 'before_12', 'should_today') deal_select
        ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 14 hour)), interval 2 hour), date_add(date(date_add(cdt.created_at, interval 14 hour)),interval 12 hour), date_add(date(date_add(cdt.created_at, interval 14 hour)),interval 24 hour)) should_deal_time
        ,date(date_add(cdt.created_at, interval 14 hour)) date_d
    from ph_staging.customer_diff_ticket cdt
    left join ph_staging.diff_info di on di.id = cdt.diff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
    left join ph_staging.sys_store ss on ss.id = cdt.organization_id
    left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
    where
        cdt.organization_type = 1 -- FH&miniCS
        and bc.client_id is  null
        and ss.category in (1,6) -- PDC
        and di.diff_marker_category not in (38,39,2,17,32,69,7,22)
        and date(date_add(cdt.created_at, interval 14 hour)) >= '${begin_date}'
        and date(date_add(cdt.created_at, interval 14 hour)) <= '${end_date}'
)
select
    t1.date_d
    ,t1.ss_name
    ,t1.ss_category
    ,count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12总量
    ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.pno, null)) before_12已处理量
    ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.pno, null))/count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12处理率
    ,count(if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.pno, null)) before_12及时量
    ,count(if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.pno, null))/count(if(t1.deal_select = 'before_12', t1.pno, null)) before_12及时率
    ,count(if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.pno, null)) before_12未处理量
    ,count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today总量
    ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.pno, null)) should_today已处理量
    ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.pno, null))/count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today处理率
    ,count(if(t1.deal_select = 'should_today' and t1.deal_time < t1.should_deal_time, t1.pno, null)) should_today及时量
    ,count(if(t1.deal_select = 'should_today' and t1.deal_time < t1.should_deal_time, t1.pno, null))/count(if(t1.deal_select = 'should_today', t1.pno, null)) should_today及时率
    ,count(if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.pno, null)) should_today未处理量
    ,count(if(t1.deal_or_not = 'n', t1.pno, null)) 未处理总量
    ,count(t1.pno) 总问题量
from t t1
group by 1,2,3
order by 16 desc

;

-- ------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------
select
    di.pno 运单号
    ,if(kp.id is not null, 'KA', 'GE') 客户类型
    ,ddd.CN_element 疑难件原因
    ,ss.name miniCS处理网点
    ,ss2.name 揽收网点
    ,ss3.name 上报网点
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,convert_tz(cdt.created_at, '+00:00', '+08:00') 疑难件上报时间
    ,date(convert_tz(cdt.created_at, '+00:00', '+08:00')) 疑难件上报日期
    ,if(cdt.state = 1, convert_tz(cdt.updated_at, '+00:00', '+08:00'), null) 处理完成时间
    ,if(cdt.state = 1, '是', '否') 是否时效内处理完成
    ,'PDC' miniCS处理网点类型
#     ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 12 hour)), interval 2 hour), 'before_12', 'should_today') deal_select
#     ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 12 hour)), interval 2 hour), date_add(date(date_add(cdt.created_at, interval 12 hour)),interval 12 hour), date_add(date(date_add(cdt.created_at, interval 12 hour)),interval 24 hour)) should_deal_time
    ,date(date_add(cdt.created_at, interval 12 hour)) 日期
from ph_staging.customer_diff_ticket cdt
left join ph_staging.diff_info di on di.id = cdt.diff_info_id
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join ph_staging.sys_store ss on ss.id = cdt.organization_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
left join ph_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join ph_staging.ka_profile kp on kp.id = cdt.client_id
left join ph_staging.sys_store ss3 on ss3.id = di.store_id
where
    cdt.organization_type = 1 -- FH&miniCS
    and bc.client_id is  null
    and ss.category = 14
    and di.diff_marker_category not in (38,39,2,17,32,69,7,22)
    and date(date_add(cdt.created_at, interval 12 hour)) >= '${begin_date}'
    and date(date_add(cdt.created_at, interval 12 hour)) <= '${end_date}'

union all

select
    di.pno 运单号
    ,if(kp.id is not null, 'KA', 'GE') 客户类型
    ,ddd.CN_element 疑难件原因
    ,ss.name miniCS处理网点
    ,ss2.name 揽收网点
    ,ss3.name 上报网点
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,convert_tz(cdt.created_at, '+00:00', '+08:00') 疑难件上报时间
    ,date(convert_tz(cdt.created_at, '+00:00', '+08:00')) 疑难件上报日期
    ,if(cdt.state = 1, convert_tz(cdt.updated_at, '+00:00', '+08:00'), null) 处理完成时间
    ,if(cdt.state = 1, '是', '否') 是否时效内处理完成
    ,if(ss.category = 1, 'SP', 'FH') miniCS处理网点类型
#     ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 14 hour)), interval 2 hour), 'before_12', 'should_today') deal_select
#     ,if(cdt.created_at < date_add(date(date_add(cdt.created_at, interval 14 hour)), interval 2 hour), date_add(date(date_add(cdt.created_at, interval 14 hour)),interval 12 hour), date_add(date(date_add(cdt.created_at, interval 14 hour)),interval 24 hour)) should_deal_time
    ,date(date_add(cdt.created_at, interval 14 hour)) 日期
from ph_staging.customer_diff_ticket cdt
left join ph_staging.diff_info di on di.id = cdt.diff_info_id
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join ph_staging.sys_store ss on ss.id = cdt.organization_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = cdt.client_id
left join ph_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join ph_staging.ka_profile kp on kp.id = cdt.client_id
left join ph_staging.sys_store ss3 on ss3.id = di.store_id
where
    cdt.organization_type = 1 -- FH&miniCS
    and bc.client_id is  null
    and ss.category in (1,6) -- PDC
    and di.diff_marker_category not in (38,39,2,17,32,69,7,22)
    and date(date_add(cdt.created_at, interval 14 hour)) >= '${begin_date}'
    and date(date_add(cdt.created_at, interval 14 hour)) <= '${end_date}'
