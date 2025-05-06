with t as
(
    select
        di.pno
        ,cdt.diff_info_id id
        ,ddd.CN_element
        ,convert_tz(cdt.created_at, '+00:00', '+08:00') creat_time
        ,if(cdt.state = 1, convert_tz(cdt.updated_at, '+00:00', '+08:00'), null) deal_time
        ,if(cdt.state = 1, 'y', 'n') deal_or_not
        ,case
            when ss.category=1 then 'SP'
            when lower(ss.name) like '%fh%' then 'FH'
            when lower(ss.name) like '%hub%' then 'HUB'
            when ss.category = 10 then 'BDC'
            when ss.category = 9 then 'OS'
        else null end as  ss_category
        ,case when cdt.negotiation_result_category in (3,4) then '退货'
              when cdt.negotiation_result_category in (5,6,9) then '继续派送'
              when cdt.negotiation_result_category in (1,2,8,12) then '丢弃'
              when cdt.negotiation_result_category in (1,4,6,12) then '理赔数量'
              else null end as results
        ,if(convert_tz(cdt.created_at, '+00:00', '+08:00')< date_add(date(convert_tz(cdt.created_at, '+00:00', '+08:00')),interval 18 hour),  'should_today','before_12') deal_select
        ,if(convert_tz(cdt.created_at, '+00:00', '+08:00')< date_add(date(convert_tz(cdt.created_at, '+00:00', '+08:00')),interval 18 hour), date(convert_tz(cdt.created_at, '+00:00', '+08:00')),date_add(date(convert_tz(cdt.created_at, '+00:00', '+08:00')),interval 36 hour)) should_deal_time
    from my_staging.customer_diff_ticket cdt
    left join my_staging.diff_info di on di.id = cdt.diff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
    left join my_staging.sys_store ss on ss.id = cdt.organization_id
    left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
    where cdt.organization_type = 1 -- FH&miniCS
 --   and bc.client_id is null
 and if(bc.client_name='tiktok',di.diff_marker_category not in (2,17),1)
 and di.diff_marker_category not in (32,69,7,22,28)
and (cdt.operator_id <>'10001' or cdt.operator_id is null)
    and cdt.created_at>=date_sub(convert_tz('${sdate}','+08:00','+00:00'),interval 6 hour)
    and cdt.created_at<=date_add(convert_tz('${edate}','+08:00','+00:00'),interval 18 hour)
)






select
    total.*

    , HUB.before_12总量 before_12总量_HUB
    , HUB.before_12已处理量 before_12已处理量_HUB
    , HUB.before_12处理率 before_12处理率_HUB
    , HUB.before_12及时量 before_12及时量_HUB
    , HUB.before_12及时率 before_12及时率_HUB
    , HUB.before_12未处理量 before_12未处理量_HUB
    , HUB.should_today总量 should_today总量_HUB
    , HUB.should_today已处理量 should_today已处理量_HUB
    , HUB.should_today处理率 should_today处理率_HUB
    , HUB.should_today及时量 should_today及时量_HUB
    , HUB.should_today及时率 should_today及时率_HUB
    , HUB.should_today未处理量 should_today未处理量_HUB
    , HUB.退货量 退货量_HUB
    , HUB.继续派送量 继续派送量_HUB
    , HUB.丢弃量 丢弃量_HUB
    , HUB.理赔数量 理赔数量_HUB

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
    , sp.退货量 退货量_sp
    , sp.继续派送量 继续派送量_sp
    , sp.丢弃量 丢弃量_sp
    , sp.理赔数量 理赔数量_sp

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
    , fh.退货量 退货量_fh
    , fh.继续派送量 继续派送量_fh
    , fh.丢弃量 丢弃量_fh
    , fh.理赔数量 理赔数量_fh

    , bdc.before_12总量 before_12总量_bdc
    , bdc.before_12已处理量 before_12已处理量_bdc
    , bdc.before_12及时量 before_12及时量_bdc
    , bdc.before_12未处理量 before_12未处理量_bdc
    , bdc.should_today总量 should_today总量_bdc
    , bdc.should_today已处理量 should_today已处理量_bdc
    , bdc.should_today及时量 should_today及时量_bdc
    , bdc.should_today未处理量 should_today未处理量_bdc
    , bdc.before_12处理率 before_12处理率_bdc
    , bdc.before_12及时率 before_12及时率_bdc
    , bdc.should_today处理率 should_today处理率_bdc
    , bdc.should_today及时率 should_today及时率_bdc
    , bdc.退货量 退货量_bdc
    , bdc.继续派送量 继续派送量_bdc
    , bdc.丢弃量 丢弃量_bdc
    , bdc.理赔数量 理赔数量_bdc

    , os.before_12总量 before_12总量_os
    , os.before_12已处理量 before_12已处理量_os
    , os.before_12及时量 before_12及时量_os
    , os.before_12未处理量 before_12未处理量_os
    , os.should_today总量 should_today总量_os
    , os.should_today已处理量 should_today已处理量_os
    , os.should_today及时量 should_today及时量_os
    , os.should_today未处理量 should_today未处理量_os
    , os.before_12处理率 before_12处理率_os
    , os.before_12及时率 before_12及时率_os
    , os.should_today处理率 should_today处理率_os
    , os.should_today及时率 should_today及时率_os
    , os.退货量 退货量_os
    , os.继续派送量 继续派送量_os
    , os.丢弃量 丢弃量_os
    , os.理赔数量 理赔数量_os
from
    (
        select
             date(t1.should_deal_time) date_d
            ,t1.CN_element
            ,count(distinct if(t1.deal_select = 'before_12', t1.id, null)) before_12总量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null)) before_12已处理量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12处理率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null)) before_12及时量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12及时率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.id, null)) before_12未处理量
            ,count(distinct if(t1.deal_select = 'should_today', t1.id, null)) should_today总量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null)) should_today已处理量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today处理率
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null)) should_today及时量
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today及时率
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.id, null)) should_today未处理量
            ,count(distinct if(t1.results='退货',t1.id,null)) 退货量
            ,count(distinct if(t1.results='继续派送',t1.id,null)) 继续派送量
            ,count(distinct if(t1.results='丢弃',t1.id,null)) 丢弃量
            ,count(distinct if(t1.results='理赔数量',t1.id,null)) 理赔数量
        from t t1
        group by 1,2
        order by 1,2
    ) total
left join
    (
        select
             date(t1.should_deal_time) date_d
            ,t1.CN_element
            ,count(distinct if(t1.deal_select = 'before_12', t1.id, null)) before_12总量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null)) before_12已处理量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12处理率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null)) before_12及时量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12及时率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.id, null)) before_12未处理量
            ,count(distinct if(t1.deal_select = 'should_today', t1.id, null)) should_today总量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null)) should_today已处理量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today处理率
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null)) should_today及时量
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today及时率
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.id, null)) should_today未处理量
            ,count(distinct if(t1.results='退货',t1.id,null)) 退货量
            ,count(distinct if(t1.results='继续派送',t1.id,null)) 继续派送量
            ,count(distinct if(t1.results='丢弃',t1.id,null)) 丢弃量
            ,count(distinct if(t1.results='理赔数量',t1.id,null)) 理赔数量
        from t t1
        where
            t1.ss_category = 'HUB'
        group by 1,2
        order by 1,2
    ) HUB on HUB.date_d = total.date_d and HUB.CN_element = total.CN_element
left join
    (
        select
             date(t1.should_deal_time) date_d
            ,t1.CN_element
            ,count(distinct if(t1.deal_select = 'before_12', t1.id, null)) before_12总量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null)) before_12已处理量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12处理率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null)) before_12及时量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12及时率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.id, null)) before_12未处理量
            ,count(distinct if(t1.deal_select = 'should_today', t1.id, null)) should_today总量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null)) should_today已处理量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today处理率
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null)) should_today及时量
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today及时率
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.id, null)) should_today未处理量
            ,count(distinct if(t1.results='退货',t1.id,null)) 退货量
            ,count(distinct if(t1.results='继续派送',t1.id,null)) 继续派送量
            ,count(distinct if(t1.results='丢弃',t1.id,null)) 丢弃量
            ,count(distinct if(t1.results='理赔数量',t1.id,null)) 理赔数量
        from t t1
        where
            t1.ss_category = 'SP'
        group by 1,2
        order by 1,2
    ) sp on sp.date_d = total.date_d and sp.CN_element = total.CN_element
left join
    (
        select
             date(t1.should_deal_time) date_d
            ,t1.CN_element
            ,count(distinct if(t1.deal_select = 'before_12', t1.id, null)) before_12总量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null)) before_12已处理量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12处理率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null)) before_12及时量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12及时率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.id, null)) before_12未处理量
            ,count(distinct if(t1.deal_select = 'should_today', t1.id, null)) should_today总量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null)) should_today已处理量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today处理率
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null)) should_today及时量
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today及时率
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.pno, null)) should_today未处理量
            ,count(distinct if(t1.results='退货',t1.id,null)) 退货量
            ,count(distinct if(t1.results='继续派送',t1.id,null)) 继续派送量
            ,count(distinct if(t1.results='丢弃',t1.id,null)) 丢弃量
            ,count(distinct if(t1.results='理赔数量',t1.id,null)) 理赔数量
        from t t1
        where
            t1.ss_category = 'FH'
        group by 1,2
        order by 1,2
    ) fh on fh.date_d = total.date_d and fh.CN_element = total.CN_element
left join
    (
        select
             date(t1.should_deal_time) date_d
            ,t1.CN_element
            ,count(distinct if(t1.deal_select = 'before_12', t1.id, null)) before_12总量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null)) before_12已处理量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12处理率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null)) before_12及时量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12及时率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.id, null)) before_12未处理量
            ,count(distinct if(t1.deal_select = 'should_today', t1.id, null)) should_today总量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null)) should_today已处理量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today处理率
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null)) should_today及时量
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today及时率
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.pno, null)) should_today未处理量
            ,count(distinct if(t1.results='退货',t1.id,null)) 退货量
            ,count(distinct if(t1.results='继续派送',t1.id,null)) 继续派送量
            ,count(distinct if(t1.results='丢弃',t1.id,null)) 丢弃量
            ,count(distinct if(t1.results='理赔数量',t1.id,null)) 理赔数量
        from t t1
        where
            t1.ss_category = 'BDC'
        group by 1,2
        order by 1,2
    ) bdc on bdc.date_d = total.date_d and bdc.CN_element = total.CN_element
left join
    (
        select
             date(t1.should_deal_time) date_d
            ,t1.CN_element
            ,count(distinct if(t1.deal_select = 'before_12', t1.id, null)) before_12总量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null)) before_12已处理量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12处理率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null)) before_12及时量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_time < t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12及时率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.deal_or_not = 'n', t1.id, null)) before_12未处理量
            ,count(distinct if(t1.deal_select = 'should_today', t1.id, null)) should_today总量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null)) should_today已处理量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'y', t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today处理率
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null)) should_today及时量
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.deal_time) =t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today及时率
            ,count(distinct if(t1.deal_select = 'should_today' and t1.deal_or_not = 'n', t1.pno, null)) should_today未处理量
            ,count(distinct if(t1.results='退货',t1.id,null)) 退货量
            ,count(distinct if(t1.results='继续派送',t1.id,null)) 继续派送量
            ,count(distinct if(t1.results='丢弃',t1.id,null)) 丢弃量
            ,count(distinct if(t1.results='理赔数量',t1.id,null)) 理赔数量
        from t t1
        where
            t1.ss_category = 'OS'
        group by 1,2
        order by 1,2
    ) os on os.date_d = total.date_d and os.CN_element = total.CN_element
order by 1,2
;



select
distinct
    di.pno 运单号
    ,cdt.client_id 客户ID
    ,case when bc.client_name is not null then bc.client_name
           when kp.id is not null then 'KA'
           else 'GE' end as  客户类型
    ,ddd.CN_element 疑难件原因
    ,ss.name miniCS处理网点
    ,ss2.name 揽收网点
    ,sy1.name 目的地网点
    ,sr1.name 目的地大区
    ,sp1.name 目的地片区
    ,pr.routed_at 最后有效路由时间
    ,pr.route_action 最后有效路由动作
    ,prd.times 进入问题件次数
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
    ,if(cdt.state = 1, '是', '否') 是否处理完成
    ,case cdt.negotiation_result_category # 协商结果
        when 1 then '赔偿' -- 丢弃并赔偿（关闭订单，网点自行处理包裹）
        when 2 then '关闭订单(不赔偿不退货)' -- 丢弃（关闭订单，网点自行处理包裹）
        when 3 then '退货'
        when 4 then '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK' -- 丢弃（包裹发到内部拍卖仓）
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
        when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
        when 13 then 'TT退件新增“holding（15天后丢弃）”协商结果'
        end as negotiation_result_category
    ,case when ss.category=1 then 'SP'
          when lower(ss.name) like '%fh%' then 'FH'
          when lower(ss.name) like '%hub%' then 'HUB'
          else null end as miniCS处理网点类型
    ,if(convert_tz(cdt.created_at, '+00:00', '+08:00')< date_add(date(convert_tz(cdt.created_at, '+00:00', '+08:00')),interval 18 hour)
       ,date(convert_tz(cdt.created_at, '+00:00', '+08:00')),date(date_add(date(convert_tz(cdt.created_at, '+00:00', '+08:00')),interval 36 hour)) ) 日期
from my_staging.customer_diff_ticket cdt
left join my_staging.diff_info di on di.id = cdt.diff_info_id
left join my_staging.parcel_info pi on pi.pno = di.pno
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join my_staging.sys_store ss on ss.id = cdt.organization_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id
left join my_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join my_staging.ka_profile kp on kp.id = cdt.client_id
left join my_staging.sys_store sy1 on pi.dst_store_id=sy1.id
left join my_staging.sys_manage_piece sp1 on sp1.id= sy1.manage_piece
left join my_staging.sys_manage_region sr1 on sr1.id = sy1.manage_region
left join
(
  select
  distinct
    pr.pno
    ,convert_tz(pr.routed_at,'+00:00','+08:00') routed_at
    ,pr.route_action
    ,row_number()over(partition by pr.pno order by pr.routed_at desc) rnk
  from my_staging.parcel_route pr
  where pr.routed_at>=date_sub(convert_tz('${sdate}','+08:00','+00:00'),interval 5 day)
  and pr.route_action in ('RECEIVED'
                            ,'RECEIVE_WAREHOUSE_SCAN'
                            ,'SORTING_SCAN'
                            ,'DELIVERY_TICKET_CREATION_SCAN'
                            ,'ARRIVAL_WAREHOUSE_SCAN'
                            ,'SHIPMENT_WAREHOUSE_SCAN'
                            ,'DETAIN_WAREHOUSE'
                            ,'DELIVERY_CONFIRM'
                            ,'DIFFICULTY_HANDOVER'
                            ,'DELIVERY_MARKER'
                            ,'REPLACE_PNO'
                            ,'SEAL'
                            ,'UNSEAL'
                            ,'PARCEL_HEADLESS_PRINTED'
                            ,'STAFF_INFO_UPDATE_WEIGHT'
                            ,'STORE_KEEPER_UPDATE_WEIGHT'
                            ,'STORE_SORTER_UPDATE_WEIGHT'
                            ,'DISCARD_RETURN_BKK'
                            ,'DELIVERY_TRANSFER'
                            ,'PICKUP_RETURN_RECEIPT'
                            ,'FLASH_HOME_SCAN'
                            ,'seal.ARRIVAL_WAREHOUSE_SCAN'
                            ,'INVENTORY'
                            ,'SORTING_SCAN'
                            ,'DELIVERY_PICKUP_STORE_SCAN'
                            ,'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE'
                            ,'REFUND_CONFIRM'
                            ,'ACCEPT_PARCEL')
)pr on pi.pno=pr.pno and pr.rnk=1
left join
(
 select
   pno
   ,count(distinct routed_at) times
 from my_staging.parcel_route pr
 where pr.route_action in ('DIFFICULTY_HANDOVER')
 and pr.routed_at>=date_sub(convert_tz('${sdate}','+08:00','+00:00'),interval 15 day)
 group by 1
)prd on pi.pno=prd.pno

where cdt.organization_type = 1 -- FH&miniCS
-- and bc.client_id is  null
and if(bc.client_name='tiktok',di.diff_marker_category not in (2,17),1)
and di.diff_marker_category not in (32,69,7,22,28)
and (cdt.operator_id <>'10001' or cdt.operator_id is null)
and cdt.created_at>=date_sub(convert_tz('${sdate}','+08:00','+00:00'),interval 6 hour)
and cdt.created_at<=date_add(convert_tz('${edate}','+08:00','+00:00'),interval 18 hour)





