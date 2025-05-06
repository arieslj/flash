select
    day_pick.p_date 日期
    ,day_pick.retail_day_cnt 当日retail收件总量
    ,day_pick.ge_day_cnt 当日小C收件总量
    ,month_pick.retail_month_cnt 本月合计retail收件量
    ,month_pick.ge_month_cnt 本月合计小C收件量

    ,day_return.retail_day_cnt as 当日retail自动退件量
    ,day_return.ge_day_cnt as 当日小C自动退件量
    ,month_return.retail_day_cnt as 本月retail自动退件量
    ,month_return.ge_day_cnt as 本月小C自动退件量
from
    (
        select
            date(convert_tz(pi.created_at, '+00:00', '+07:00')) as p_date
            ,date_format(convert_tz(pi.created_at, '+00:00', '+07:00'), '%Y-%m') p_month
            ,count(distinct if(kp.department_id = 13, pi.pno, null)) retail_day_cnt
            ,count(distinct if(kp.department_id is null, pi.pno, null)) as ge_day_cnt
        from fle_staging.parcel_info pi
        left join fle_staging.ka_profile kp on kp.id = pi.client_id
        where
            pi.created_at > '2025-03-07 17:00:00'
            and pi.created_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
            and pi.returned = 0
            and ( kp.department_id = 13 or kp.id is null )
        group by 1,2
    ) day_pick
left join
    (
        select
            date_format(convert_tz(pi.created_at, '+00:00', '+07:00'), '%Y-%m') p_month
            ,count(distinct if(kp.department_id = 13, pi.pno, null)) retail_month_cnt
            ,count(distinct if(kp.department_id is null, pi.pno, null)) as ge_month_cnt
        from fle_staging.parcel_info pi
        left join fle_staging.ka_profile kp on kp.id = pi.client_id
        where
            pi.created_at > '2025-03-07 17:00:00'
            and pi.created_at > date_sub(date_sub(date_sub(curdate(), interval day(curdate()) - 1 day), interval 1 month), interval 7 hour)
            and pi.returned = 0
            and ( kp.department_id = 13 or kp.id is null )
        group by 1
    ) month_pick on day_pick.p_month = month_pick.p_month
left join
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+07:00')) as p_date
            ,date_format(convert_tz(pr.routed_at, '+00:00', '+07:00'), '%Y-%m') p_month
            ,count(distinct if(kp.department_id = 13, pr.pno, null)) retail_day_cnt
            ,count(distinct if(kp.department_id is null, pr.pno, null)) as ge_day_cnt
        from rot_pro.parcel_route pr
        join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId') and dpr.pno = pr.pno
        left join fle_staging.parcel_info pi2 on pi2.pno = pr.pno
        left join fle_staging.ka_profile kp on kp.id = pi2.client_id
        where
            pr.routed_at > '2025-03-07 17:00:00'
            and pr.routed_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
            and dpr.created_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
            and pi2.created_at > date_sub(curdate(), interval 3 month)
            and pi2.returned = 0
            and ( kp.department_id = 13 or kp.id is null )
            and dpr.route_action = 'PENDING_RETURN'
            and pr.route_action = 'PENDING_RETURN'
            and json_extract(dpr.extra_value, '$.returnSourceCategory') = 11 -- retail和小c自动退件
        group by 1,2
    ) day_return on day_pick.p_date = day_return.p_date
left join
    (
         select
            date_format(convert_tz(pr.routed_at, '+00:00', '+07:00'), '%Y-%m') p_month
            ,count(distinct if(kp.department_id = 13, pr.pno, null)) retail_day_cnt
            ,count(distinct if(kp.department_id is null, pr.pno, null)) as ge_day_cnt
        from rot_pro.parcel_route pr
        left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
        left join fle_staging.parcel_info pi2 on pi2.pno = pr.pno
        left join fle_staging.ka_profile kp on kp.id = pi2.client_id
        where
            pr.routed_at > '2025-03-07 17:00:00'
            and pr.routed_at > date_sub(date_sub(date_sub(curdate(), interval day(curdate()) - 1 day), interval 1 month), interval 7 hour)
            and dpr.created_at > date_sub(date_sub(date_sub(curdate(), interval day(curdate()) - 1 day), interval 1 month), interval 7 hour)
            and pi2.created_at > date_sub(curdate(), interval 3 month)
            and pi2.returned = 0
            and ( kp.department_id = 13 or kp.id is null )
            and pr.route_action = 'PENDING_RETURN'
            and json_extract(dpr.extra_value, '$.returnSourceCategory') = 11 -- retail和小x自动退件
    ) month_return on day_pick.p_month = month_return.p_month




;


select
    p_day.p_date 日期
    ,p_day.retail_day_cnt 当日retail收件总量
    ,p_day.ge_day_cnt 当日小C收件总量
    ,p_month.retail_day_cnt 本月合计retail收件量
    ,p_month.ge_day_cnt 本月合计小C收件量
    ,p_day.retail_day_cnt_return 当日retail自动退件量
    ,p_day.ge_day_cnt_return 当日小C自动退件量
    ,p_month.retail_day_cnt_return 本月retail自动退件量
    ,p_month.ge_day_cnt_return 本月小C自动退件量
from
    (
        select
            date(convert_tz(pi.created_at, '+00:00', '+07:00')) as p_date
            ,date_format(convert_tz(pi.created_at, '+00:00', '+07:00'), '%Y-%m') p_month
            ,count(distinct if(kp.department_id = 13, pi.pno, null)) retail_day_cnt
            ,count(distinct if(kp.department_id is null, pi.pno, null)) as ge_day_cnt
            ,count(distinct if(kp.department_id = 13 and dpr.id is not null, pr.pno, null)) retail_day_cnt_return
            ,count(distinct if(kp.department_id is null and dpr.id is not null, pr.pno, null)) as ge_day_cnt_return
        from fle_staging.parcel_info pi
        left join fle_staging.ka_profile kp on kp.id = pi.client_id
        left join rot_pro.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'PENDING_RETURN' and pr.created_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
        left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId') and dpr.created_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
        where
            pi.created_at > '2025-03-07 17:00:00'
            and pi.created_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
            and pi.returned = 0
            and ( kp.department_id = 13 or kp.id is null )
        group by 1,2
    ) p_day
left join
    (
        select
            date_format(convert_tz(pi.created_at, '+00:00', '+07:00'), '%Y-%m') p_month
            ,count(distinct if(kp.department_id = 13, pi.pno, null)) retail_day_cnt
            ,count(distinct if(kp.department_id is null, pi.pno, null)) as ge_day_cnt
            ,count(distinct if(kp.department_id = 13 and dpr.id is not null, pr.pno, null)) retail_day_cnt_return
            ,count(distinct if(kp.department_id is null and dpr.id is not null, pr.pno, null)) as ge_day_cnt_return
        from fle_staging.parcel_info pi
        left join fle_staging.ka_profile kp on kp.id = pi.client_id
        left join rot_pro.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'PENDING_RETURN' and pr.created_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
        left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId') and dpr.created_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
        where
            pi.created_at > '2025-03-07 17:00:00'
            and pi.created_at > date_sub(date_sub(date_sub(curdate(), interval day(curdate()) - 1 day), interval 1 month), interval 7 hour)
            and pi.returned = 0
            and ( kp.department_id = 13 or kp.id is null )
        group by 1
    ) p_month on p_day.p_month = p_month.p_month





# ;
#
# select date_sub(date_sub(curdate(), interval day(curdate()) - 1 day), interval 1 month)
#
# ;
#
# select
#     *
# from rot_pro.parcel_route pr
# where
#     pr.routed_at > '2025-03-01'
#     and pr.route_action = 'PENDING_RETURN'
#     and pr.extra_value regexp 'returnSourceCategory'

