-- minics处理
with t as
(
    select
        di.pno
        ,cdt.diff_info_id id
        ,ddd.CN_element
        ,convert_tz(cdt.created_at, '+00:00', '+08:00') creat_time
        ,if(cdt.state = 1, convert_tz(cdt.updated_at, '+00:00', '+08:00'), null) deal_time
        ,if(cdt.state = 1, 'y', 'n') deal_or_not
        ,case when ss.category=1 then 'SP'
              when lower(ss.name) like '%fh%' then 'FH'
              when lower(ss.name) like '%hub%' then 'HUB'
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
order by 1,2
