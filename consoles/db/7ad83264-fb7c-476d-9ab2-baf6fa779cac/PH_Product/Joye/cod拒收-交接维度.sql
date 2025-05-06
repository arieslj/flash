with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,pr.pno
            ,pi.client_id
            ,pi.cod_enabled
            ,ifnull(pi.cod_amount, 0) cod
            ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+08:00')), null) fin_date
            ,date(convert_tz(pi2.created_at, '+00:00', '+08:00')) return_date
        from ph_staging.parcel_route pr
        join ph_staging.parcel_info pi on pi.pno = pr.pno
        left join ph_staging.parcel_info pi2 on pi2.pno = pi.recent_pno
        left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 1 month), interval 8 hour)
            and pi.returned = 0
            and bc.client_name is null -- KA&小C
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1,2,3,4,5,6,7
    )
select
    t1.pr_date 交接日期
    ,if(kp.id is not null , 'KA', '小C') 客户类型
    ,t1.client_id 客户ID
    ,sd.name 归属部门
    ,ss.name 归属网点
    ,count(distinct t1.pno) 包裹量
    ,count(distinct if(t1.cod_enabled = 1, t1.pno, null)) COD包裹量
    ,count(distinct if(t1.cod_enabled = 1, t1.pno, null))/count(t1.pno) COD占比
    ,count(distinct if(t1.cod_enabled = 1 and t1.return_date = t1.pr_date, t1.pno, null)) COD包裹退回量
    ,count(distinct if(t1.cod_enabled = 1 and t1.return_date = t1.pr_date, t1.pno, null))/count(distinct if(t1.cod_enabled = 1, t1.pno, null)) COD退件率
    ,count(distinct if(t1.cod_enabled = 1 and re.pno is not null, t1.pno, null)) COD包裹拒收量
    ,count(distinct if(t1.cod_enabled = 1 and re.pno is not null, t1.pno, null))/count(distinct if(t1.cod_enabled = 1, t1.pno, null)) COD拒收率
    ,count(distinct if(t1.cod_enabled = 1 and re.rejection_category = 1, t1.pno, null)) COD包裹拒收原因为未购买量
    ,count(distinct if(t1.cod_enabled = 1 and re.rejection_category = 1, t1.pno, null))/count(distinct if(t1.cod_enabled = 1 and re.pno is not null, t1.pno, null)) 未购买商品的拒收占比
    ,count(distinct if(t1.cod_enabled = 1 and t1.fin_date is not null, t1.pno, null)) COD包裹妥投量
    ,count(distinct if(t1.cod_enabled = 1 and t1.fin_date is not null, t1.pno, null))/count(distinct if(t1.cod_enabled = 1, t1.pno, null)) COD妥投率
    ,sum(if(t1.cod_enabled = 1, t1.cod/100, 0))/count(distinct if(t1.cod_enabled = 1, t1.pno, null)) 平均COD金额
from t t1
left join ph_staging.ka_profile kp on kp.id = t1.client_id
left join ph_staging.sys_department sd on sd.id = kp.department_id
left join ph_staging.sys_store ss on ss.id = kp.store_id
left join
    (
        select
            pr.pno
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,json_extract(pr.extra_value, '$.rejectionCategory') rejection_category
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.routed_at > date_sub(t1.pr_date, interval 8 hour)
            and pr.routed_at < date_add(t1.pr_date, interval 16 hour)
            and pr.marker_category in (2,17)
    ) re on re.pno = t1.pno and re.pr_date = t1.pr_date and re.rk = 1
group by 1,2,3,4,5


;


select
    pi.pno
    ,pi.cod_amount
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.routed_at > '2024-05-17 18:00:00'
    and pr.routed_at < '2024-05-18 18:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
  --  and pr.marker_category in (2,17)
    and pi.client_id = '269663'