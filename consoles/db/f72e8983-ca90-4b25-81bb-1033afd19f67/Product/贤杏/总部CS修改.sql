with t as
(
    select
        di.pno
        ,cdt.diff_info_id id
        ,ddd.CN_element
        ,convert_tz(cdt.created_at, '+00:00', '+08:00') creat_time
        ,if(cdt.state = 2, convert_tz(cdt.updated_at, '+00:00', '+08:00'), null) ing_time
        ,if(cdt.state = 1, convert_tz(cdt.updated_at, '+00:00', '+08:00'), null) deal_time
        ,if(cdt.state = 1, 'y', 'n') deal_or_not
        ,if(cdt.state = 2, 'y', 'n') yes_no
        ,cdt.client_id
        ,cdt.state
        ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00') first_operated_at
        ,di.diff_marker_category
        ,case when cdt.negotiation_result_category in (3,4) then '退货'
              when cdt.negotiation_result_category in (5,6,9) then '继续派送'
              when cdt.negotiation_result_category in (1,2,8,12) then '丢弃'
              when cdt.negotiation_result_category in (1,4,6,12) then '理赔数量'
              else null end as results
        ,if(convert_tz(cdt.created_at, '+00:00', '+08:00')< date_add(date(convert_tz(cdt.created_at, '+00:00', '+08:00')),interval 18 hour),  'should_today','before_12') deal_select
        ,if(convert_tz(cdt.created_at, '+00:00', '+08:00')< date_add(date(convert_tz(cdt.created_at, '+00:00', '+08:00')),interval 18 hour), date(convert_tz(cdt.created_at, '+00:00', '+08:00')),date_add(date(convert_tz(cdt.created_at, '+00:00', '+08:00')),interval 36 hour)) should_deal_time
    from my_staging.customer_diff_ticket cdt
    left join
        (
              select
              pc.*,client_id
              from
              (select * from my_staging.sys_configuration
              where cfg_key ='diff.ticket.customer_service.ka_client_ids'
              )pc
              lateral view explode(split(pc.cfg_value, ',')) id as client_id
        )cs on cdt.client_id=cs.client_id
    left join my_staging.diff_info di on di.id = cdt.diff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'my_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
    left join my_staging.sys_store ss on ss.id = cdt.organization_id
    left join
        (
              select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') routed_at
                ,pr.store_name
                ,row_number()over(partition by pr.pno order by pr.routed_at desc) rnk
              from my_staging.parcel_route pr
              where pr.route_action='RECEIVED'
              and pr.routed_at>=date_sub(convert_tz('${sdate}','+08:00','+00:00'),interval 1 month)
        )prp on di.pno=prp.pno and prp.rnk=1
    where
        cdt.organization_type = 2
        and di.diff_marker_category not in (32,69,7,22,28)
        and (cdt.operator_id <>'10001' or cdt.operator_id is null)
        and (cs.client_id is not null or prp.store_name='Autoqaqc')
        and cdt.created_at>=date_sub(convert_tz('${sdate}','+08:00','+00:00'),interval 6 hour)
        and cdt.created_at<=date_add(convert_tz('${edate}','+08:00','+00:00'),interval 18 hour)
)






select
    total.*

    , t.总量 总量_t
    , t.before_12已沟通处理量
    , t.before_12沟通处理率
    , t.before_12及时沟通处理量
    , t.before_12及时沟通处理率
    , t.before_12未沟通未处理量

    , t.should_today已沟通处理量
    , t.should_today沟通处理率
    , t.should_today及时沟通处理量
    , t.should_today及时沟通处理率
    , t.should_today未沟通未处理量

    ,t.已处理量 已处理量_t
    ,t.处理率 处理率_t
    ,t.及时处理量 及时处理量_t
    ,t.及时处理率 及时处理率_t
    ,t.未处理量 未处理量_t
    , t.退货量 退货量_t
    , t.继续派送量 继续派送量_t
    , t.丢弃量 丢弃量_t
    , t.理赔数量 理赔数量_t

    , cs.before_12总量 before_12总量_cs
    , cs.before_12已处理量 before_12已处理量_cs
    , cs.before_12及时量 before_12及时量_cs
    , cs.before_12未处理量 before_12未处理量_cs
    , cs.should_today总量 should_today总量_cs
    , cs.should_today已处理量 should_today已处理量_cs
    , cs.should_today及时量 should_today及时量_cs
    , cs.should_today未处理量 should_today未处理量_cs
    , cs.before_12处理率 before_12处理率_cs
    , cs.before_12及时率 before_12及时率_cs
    , cs.should_today处理率 should_today处理率_cs
    , cs.should_today及时率 should_today及时率_cs
    , cs.退货量 退货量_cs
    , cs.继续派送量 继续派送量_cs
    , cs.丢弃量 丢弃量_cs
    , cs.理赔数量 理赔数量_cs


from
    (
        select
             date(t1.should_deal_time) date_d
            ,t1.CN_element
        from t t1
        group by 1,2
        order by 1,2
    ) total
left join
    (
        select
             date(t1.should_deal_time) date_d
            ,t1.CN_element
            ,count(distinct t1.id) 总量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.state in (1,2), t1.id, null)) before_12已沟通处理量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.state in (1,2), t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12沟通处理率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.first_operated_at < t1.should_deal_time, t1.id, null)) before_12及时沟通处理量
            ,count(distinct if(t1.deal_select = 'before_12' and t1.first_operated_at < t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'before_12', t1.id, null)) before_12及时沟通处理率
            ,count(distinct if(t1.deal_select = 'before_12' and t1.state not in (1,2), t1.id, null)) before_12未沟通未处理量

            ,count(distinct if(t1.deal_select = 'should_today' and t1.state in (1,2), t1.id, null)) should_today已沟通处理量
            ,count(distinct if(t1.deal_select = 'should_today' and t1.state in (1,2), t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today沟通处理率
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.first_operated_at) =t1.should_deal_time, t1.id, null)) should_today及时沟通处理量
            ,count(distinct if(t1.deal_select = 'should_today' and date(t1.first_operated_at) =t1.should_deal_time, t1.id, null))/count(if(t1.deal_select = 'should_today', t1.id, null)) should_today及时沟通处理率
            ,count(distinct if(t1.deal_select = 'should_today' and t1.state not in (1,2), t1.id, null)) should_today未沟通未处理量

            ,count(distinct if(t1.deal_or_not = 'y', t1.id, null)) 已处理量
            ,count(distinct if(t1.deal_or_not = 'y', t1.id, null))/count(distinct t1.id) 处理率
            ,count(distinct if(t1.deal_or_not = 'y' and date(t1.deal_time)<=date_add(date(t1.creat_time),interval 2 day), t1.id, null)) 及时处理量
            ,count(distinct if(t1.deal_or_not = 'y' and date(t1.deal_time)<=date_add(date(t1.creat_time),interval 2 day), t1.id, null))/count(distinct t1.id) 及时处理率
            ,count(distinct if(t1.deal_or_not = 'n', t1.id, null)) 未处理量

            ,count(distinct if(t1.results='退货',t1.id,null)) 退货量
            ,count(distinct if(t1.results='继续派送',t1.id,null)) 继续派送量
            ,count(distinct if(t1.results='丢弃',t1.id,null)) 丢弃量
            ,count(distinct if(t1.results='理赔数量',t1.id,null)) 理赔数量
        from t t1
        where t1.client_id = 'AA0123'
        group by 1,2
        order by 1,2
    )t on t.date_d = total.date_d and t.CN_element = total.CN_element

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
        where t1.client_id <> 'AA0123'
        group by 1,2
        order by 1,2
    )cs on cs.date_d = total.date_d and cs.CN_element = total.CN_element

order by 1,2
