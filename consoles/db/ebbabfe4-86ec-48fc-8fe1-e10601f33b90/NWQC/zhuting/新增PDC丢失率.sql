
select
    pi.pickup_date
    ,pi.name DC
    ,sum(pi.pnt) 操作量
    ,sum(nvl(lt.pnt,0)) 丢失量
    ,(sum(nvl(lt.pnt,0))/sum(pi.pnt))*100000 丢失率_判责维度
from
    (
        select
            pi.pickup_date
            ,cast('fleet' as string) as kind
            ,pi.name
            ,pi.pnt
        from
            (
                select
                    date(convert_tz(pi.created_at,'+00:00','+08:00')) pickup_date
                    ,sy.name
                    ,sy.id
                    ,count(distinct pi.pno) pnt
                from my_staging.parcel_info pi
                join my_staging.sys_store sy on pi.ticket_pickup_store_id = sy.id
                where
                    pi.returned = 0
                    and pi.state < 9
                    and pi.created_at >= convert_tz('${sdate}','+08:00','+00:00')
                    and pi.created_at < date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
                    and sy.category = 14
                    and sy.name <>'Autoqaqc'
                group by 1,2
            )pi
    )pi
left join
    (
        select
            prn.kind
            ,prn.name
            ,lt.updated_at
            ,sum(1/pr.dcs) pnt
        from
            (
                select
                    lt.pno
                    ,max(date(lt.updated_at)) updated_at
                from my_bi.parcel_lose_task lt
                where
                    lt.duty_result = 1
                    and lt.state = 6
                    and lt.updated_at >= '${sdate}'
                    and lt.penalties > 0
                --  and lt.updated_at<date_add('${edate}',interval 1 day)
                group by 1
            )lt
        join
            (
                SELECT
                    distinct
                    lt.pno
                    ,sy.name
                    ,case when sy.name like '%HUB%' then 'HUB'
                        when sy.name like 'FH%' then 'FH'
                        when sy.name like 'OS%' then 'ONSITE'
                        when sy.category = 14 then 'fleet'
                        else 'SP'
                    end as kind
                from my_bi.parcel_lose_responsible pr
                join my_bi.parcel_lose_task lt on pr.lose_task_id =lt.id
                left join my_staging.sys_store sy on pr.store_id=sy.id
                where pr.created_at >='${sdate}'
                    and lt.duty_result = 1
                and sy.name <>'Autoqaqc'
                -- and sy.name like '%HUB%'
            )prn on lt.pno = prn.pno
        left join
            (
                SELECT
                    lt.pno
                    ,count(distinct sy.name) dcs
                from my_bi.parcel_lose_responsible pr
                left join my_bi.parcel_lose_task lt on pr.lose_task_id =lt.id
                left join my_staging.sys_store sy on pr.store_id=sy.id
                where
                    pr.created_at >='${sdate}'
                    -- and sy.name like '%HUB%'
                group by 1
                order by 1
            )pr on lt.pno = pr.pno
        group by 1,2,3
        order by 1,2,3
    )lt on pi.pickup_date=lt.updated_at and pi.kind=lt.kind and pi.name=lt.name
group by 1,2
order by 1,2

;


select
    a.*
from
    (
        select
            distinct
            prn.name
            ,lt.updated_at
            ,lt.pno
        from
            (
                select
                    lt.pno
                    ,max(date(lt.updated_at)) updated_at
                from my_bi.parcel_lose_task lt
                where lt.duty_result=1
                and lt.state=6
                and lt.updated_at>='${sdate}'
                and lt.updated_at<date_add('${edate}',interval 1 day)
                group by 1
            )lt
        join
            (
                SELECT
                    distinct
                    pr.lose_task_id
                    ,lt.pno
                    ,sy.name
                from my_bi.parcel_lose_responsible pr
                join my_bi.parcel_lose_task lt on pr.lose_task_id =lt.id
                left join my_staging.sys_store sy on pr.store_id=sy.id
                where pr.created_at >='${sdate}'
                and sy.category = 14
            )prn on lt.pno=prn.pno
    ) a
where
    1=1 ${if(len(store)==0,"","and a.name = '" + store +"'")}
	and 1=1 ${if(len(dated)==0,"","and a.updated_at = '" + dated +"'")}

;


-- 全网daily

select
    pi.pickup_date
    ,pi.kind DC
    ,sum(pi.pnt) 操作量
    ,sum(nvl(lt.pnt,0)) 丢失量
    ,(sum(nvl(lt.pnt,0))/sum(pi.pnt))*100000 丢失率_判责维度
from
    (
        select
            date(convert_tz(pr.routed_at,'+00:00','+08:00')) pickup_date
            ,cast('HUB' as string) as kind
            ,pr.store_name name
            ,count(distinct pr.pno) pnt
        from my_staging.parcel_route pr
        where
            pr.routed_at>=convert_tz('${sdate}','+08:00','+00:00')
            and pr.routed_at<date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
            and pr.route_action='SHIPMENT_WAREHOUSE_SCAN'
            and pr.store_name like '%HUB%'
        group by 1,2,3

        union all


        select
            pi.pickup_date
            ,cast('FH' as string) as kind
            ,pi.name
            ,sum(pi.pnt+nvl(sd.sd_pnt,0)) pnt
        from
            (
                select
                    date(convert_tz(pi.created_at,'+00:00','+08:00')) pickup_date
                    ,sy.name
                    ,count(distinct pi.pno) pnt
                from my_staging.parcel_info pi
                left join my_staging.sys_store sy on pi.ticket_pickup_store_id=sy.id
                where
                    pi.returned=0
                    and pi.state<9
                    and pi.created_at>=convert_tz('${sdate}','+08:00','+00:00')
                    and pi.created_at<date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
                    and sy.name like 'FH%'
                group by 1,2
            )pi
        left join
            (
                select
                    sd.stat_date
                    ,sy.name
                    ,count(distinct sd.pno) sd_pnt
                from dwm.dwd_my_dc_should_delivery_d sd
                left join my_staging.sys_store sy on sd.store_id=sy.id
                where
                    sy.name like 'FH%'
                    and sd.stat_date>='${sdate}'
                group by 1,2
            )sd on pi.pickup_date=sd.stat_date and pi.name=sd.name
        group by 1,2,3

        union all


        select
            pi.pickup_date
            ,cast('SP' as string) as kind
            ,pi.name
            ,sum(pi.pnt+nvl(sd.sd_pnt,0)) pnt
        from
            (
                select
                    date(convert_tz(pi.created_at,'+00:00','+08:00')) pickup_date
                    ,sy.name
                    ,count(distinct pi.pno) pnt
                from my_staging.parcel_info pi
                left join my_staging.sys_store sy on pi.ticket_pickup_store_id=sy.id
                where
                    pi.returned=0
                    and pi.state<9
                    and pi.created_at>=convert_tz('${sdate}','+08:00','+00:00')
                    and pi.created_at<date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
                    and sy.name not like 'FH%'
                    and sy.name not like '%HUB%'
                    and sy.name <>'Autoqaqc'
                group by 1,2
            )pi
        left join
            (
                select
                    sd.stat_date
                    ,sy.name
                    ,count(distinct sd.pno) sd_pnt
                from dwm.dwd_my_dc_should_delivery_d sd
                left join my_staging.sys_store sy on sd.store_id=sy.id
                where
                    sy.name not like 'FH%'
                    and sy.name not like '%HUB%'
                    and sy.name <>'Autoqaqc'
                    and sd.stat_date>='${sdate}'
                group by 1,2
            )sd on pi.pickup_date=sd.stat_date and pi.name=sd.name
        group by 1,2,3

        union all


        select
            date(convert_tz(pc.`created_at`,'+00:00','+08:00')) pickup_date
            ,cast('ONSITE' as string) as kind
            ,ss.name
            ,count(distinct pc.pno ) pnt
            From my_staging.parcel_info pc
        LEFT JOIN `my_staging`.sys_store ss on ss.id = pc.ticket_pickup_store_id
        JOIN dwm.`tmp_ex_big_clients_id_detail` bi  on bi.`client_id` =pc.`client_id`
        where
            pc.created_at >=convert_tz('${sdate}','+08:00','+00:00')
            and pc.created_at < date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
            and (ss.name like 'OS%' or ss.name='01 MS1_HUB Klang')
            and bi.`client_id` in ('AA0006','AA0127','AA0056')
        group by 1,2,3
        order by 1,2,3

        union all

        select
            pi.pickup_date
            ,cast('FLEET' as string) as kind
            ,pi.name
            ,pi.pnt
        from
            (
                select
                    date(convert_tz(pi.created_at,'+00:00','+08:00')) pickup_date
                    ,sy.name
                    ,sy.id
                    ,count(distinct pi.pno) pnt
                from my_staging.parcel_info pi
                join my_staging.sys_store sy on pi.ticket_pickup_store_id = sy.id
                where
                    pi.returned = 0
                    and pi.state < 9
                    and pi.created_at >= convert_tz('${sdate}','+08:00','+00:00')
                    and pi.created_at < date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
                    and sy.category = 14
                    and sy.name <>'Autoqaqc'
                group by 1,2
            )pi
    )pi
left join
    (
        select
            prn.kind
            ,prn.name
            ,lt.updated_at
            ,sum(1/pr.dcs) pnt
        from
            (
                select
                    lt.pno
                    ,max(date(lt.updated_at)) updated_at
                from my_bi.parcel_lose_task lt
                where
                    lt.duty_result=1
                    and lt.state = 6
                    and lt.updated_at>='${sdate}'
                    and lt.penalties > 0
                --  and lt.updated_at<date_add('${edate}',interval 1 day)
                group by 1
            )lt
        join
            (
                SELECT
                    distinct
                    lt.pno
                    ,sy.name
                    ,case when sy.name like '%HUB%' then 'HUB'
                        when sy.name like 'FH%' then 'FH'
                        when sy.name like 'OS%' then 'ONSITE'
                        when sy.category = 14 then 'FLEET'
                        else 'SP'
                    end as kind
                from my_bi.parcel_lose_responsible pr
                left join my_bi.parcel_lose_task lt on pr.lose_task_id =lt.id
                left join my_staging.sys_store sy on pr.store_id=sy.id
                where pr.created_at >='${sdate}'
                and sy.name <>'Autoqaqc'
                -- and sy.name like '%HUB%'
            )prn on lt.pno=prn.pno
        left join
            (
                SELECT
                    lt.pno
                    ,count(distinct sy.name) dcs
                from my_bi.parcel_lose_responsible pr
                left join my_bi.parcel_lose_task lt on pr.lose_task_id =lt.id
                left join my_staging.sys_store sy on pr.store_id=sy.id
                where
                    pr.created_at >='${sdate}'
                    -- and sy.name like '%HUB%'
                group by 1
                order by 1
            )pr on lt.pno=pr.pno
        group by 1,2,3
        order by 1,2,3
    )lt on pi.pickup_date=lt.updated_at and pi.kind=lt.kind and pi.name=lt.name
group by 1,2
order by 1,2