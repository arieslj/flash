with t as
    (
        select
            pi.pno
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) sc_date
            ,pi.state
            ,pi.cod_enabled
            ,pi.client_id
            ,bc.client_name
            ,kp.name
            ,ss.name ss_name
            ,sd.name sd_name
        from ph_staging.parcel_route pr
        left join ph_staging.parcel_info pi on pi.pno = pr.pno
        join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join dwm.dwd_dim_bigClient bc on pi.client_id = bc.client_id
        left join ph_staging.sys_store ss on ss.id = kp.store_id
        left join ph_staging.sys_department sd on sd.id = kp.department_id
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
            and pi.returned  = 0
            and bc.client_name is null

        union all

        select
            pi.pno
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) sc_date
            ,pi.state
            ,pi.cod_enabled
            ,pi.client_id
            ,'小C' client_name
            ,ui.name
            ,'' ss_name
            ,'' sd_name
        from ph_staging.parcel_route pr
        left join  ph_staging.parcel_info pi on pi.pno = pr.pno
        left join ph_staging.ka_profile kp on kp.id = pi.client_id
        left join ph_staging.user_info ui on ui.id = pi.client_id
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 1 month), interval 7 hour)
            and pi.returned  = 0
            and kp.id is null
    )
select
    t1.client_name 客户类型
    ,t1.name 客户名称
    ,count(t1.pno) 包裹量
    ,count(distinct if(t1.cod_enabled = 1, t1.pno, null)) COD包裹量
    ,count(distinct if(t1.cod_enabled = 1, t1.pno, null))/count(t1.pno) COD占比
    ,count(distinct if(t1.state = 7, t1.pno, null)) 退件包裹量
    ,count(distinct if(t1.state = 7 and t1.cod_enabled = 1, t1.pno, null)) COD退件包裹量
    ,count(distinct if(t1.state = 7 and t1.cod_enabled = 1, t1.pno, null))/count(distinct if(t1.state = 7, t1.pno, null)) COD退件率
    ,count(distinct if(re.pno is not null and t1.cod_enabled = 1 and t1.state in (1,2,3,4,6), t1.pno, null)) COD包裹拒收量
    ,count(distinct if(re.pno is not null and t1.cod_enabled = 1 and t1.state in (1,2,3,4,6), t1.pno, null))/count(t1.pno) 拒收率
    ,count(distinct if(re.pno is not null and t1.cod_enabled = 1 and re.rejection_category = 1 and t1.state in (1,2,3,4,6), t1.pno, null)) COD包裹拒收原因为未购买量
    ,count(distinct if(re.pno is not null and t1.cod_enabled = 1 and re.rejection_category = 1 and t1.state in (1,2,3,4,6), t1.pno, null))/count(distinct if(re.pno is not null and t1.cod_enabled = 1, t1.pno, null)) 未购买商品的拒收占比
    ,count(distinct if(t1.state = 5, t1.pno, null))/count(t1.pno) 妥投率
    ,count(distinct if(t1.state = 5 and t1.cod_enabled = 1, t1.pno, null))/count(t1.pno) COD妥投率
    ,count(distinct if(t1.state = 5 and t1.cod_enabled = 0, t1.pno, null))/count(t1.pno)  非COD妥投率
from t t1
left join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.rejectionCategory') rejection_category
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.routed_at > date_sub(t1.sc_date, interval 8 hour)
            and pr.routed_at < date_add(t1.sc_date, interval 16 hour)
            and pr.marker_category in (2,17)
    ) re on re.pno = t1.pno and re.rk = 1
group by 1,2

;
-- FH
with t as
    (
        select
            pi.pno
            ,pi.state
            ,pi.cod_enabled
            ,pi.client_id
            ,'FH' client_name
            ,ss.name
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        where
            pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.returned  = 0
            and ss.category = 6
    )
select
    t1.client_name 客户类型
    ,t1.name 客户名称
    ,count(t1.pno) 包裹量
    ,count(distinct if(t1.cod_enabled = 1, t1.pno, null)) COD包裹量
    ,count(distinct if(t1.cod_enabled = 1, t1.pno, null))/count(t1.pno) COD占比
    ,count(distinct if(t1.state = 7, t1.pno, null)) 退件包裹量
    ,count(distinct if(t1.state = 7 and t1.cod_enabled = 1, t1.pno, null)) COD退件包裹量
    ,count(distinct if(t1.state = 7 and t1.cod_enabled = 1, t1.pno, null))/count(distinct if(t1.state = 7, t1.pno, null)) COD退件率
    ,count(distinct if(re.pno is not null and t1.cod_enabled = 1 and t1.state in (1,2,3,4,6), t1.pno, null)) COD包裹拒收量
    ,count(distinct if(re.pno is not null and t1.cod_enabled = 1 and t1.state in (1,2,3,4,6), t1.pno, null))/count(t1.pno) 拒收率
    ,count(distinct if(re.pno is not null and t1.cod_enabled = 1 and re.rejection_category = 1 and t1.state in (1,2,3,4,6), t1.pno, null)) COD包裹拒收原因为未购买量
    ,count(distinct if(re.pno is not null and t1.cod_enabled = 1 and re.rejection_category = 1 and t1.state in (1,2,3,4,6), t1.pno, null))/count(distinct if(re.pno is not null and t1.cod_enabled = 1, t1.pno, null)) 未购买商品的拒收占比
    ,count(distinct if(t1.state = 5, t1.pno, null))/count(t1.pno) 妥投率
    ,count(distinct if(t1.state = 5 and t1.cod_enabled = 1, t1.pno, null))/count(t1.pno) COD妥投率
    ,count(distinct if(t1.state = 5 and t1.cod_enabled = 0, t1.pno, null))/count(t1.pno)  非COD妥投率
from t t1
left join
    (
        select
            pr.pno
            ,json_extract(pr.extra_value, '$.rejectionCategory') rejection_category
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.marker_category in (2,17)
    ) re on re.pno = t1.pno and re.rk = 1
group by 1,2