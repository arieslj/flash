select
    pi.kind DC
    ,pi.pickup_date
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
            and pr.store_category in (8,12)
        group by 1,2,3

        union all


        select
            tmp.date pickup_date
            ,cast('FH' as string) as kind
            ,pi.name
            ,sum(coalesce(pi.pnt， 0) + coalesce(sd.sd_pnt,0)) pnt
        from
            (
                select
                    ss.name
                    ,om.date
                from tmpale.ods_my_dim_date om
                cross join my_staging.sys_store ss
                where
                    om.date >= '${sdate}'
                    and om.date <= '${edate}'
                    and ss.category = 6 -- FH
                    -- and ss.name like 'FH%'
            ) tmp
        left join
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
                    and sy.category = 6
                group by 1,2
            )pi on tmp.date = pi.pickup_date and tmp.name = pi.name
        left join
            (
                select
                    sd.stat_date
                    ,sy.name
                    ,count(distinct sd.pno) sd_pnt
                from dwm.dwd_my_dc_should_delivery_d sd
                left join my_staging.sys_store sy on sd.store_id=sy.id
                where
                    sy.category = 6
                    and sd.stat_date>='${sdate}'
                group by 1,2
            )sd on tmp.date = sd.stat_date and tmp.name = sd.name
        where
            pi.name is not null
            or sd.name is not null
        group by 1,2,3

        union all


        select
            tmp.date pickup_date
            ,cast('SP' as string) as kind
            ,tmp.name
            ,sum(coalesce(pi.pnt, 0) + coalesce(sd.sd_pnt,0)) pnt
        from
            (
                select
                    ss.name
                    ,om.date
                from tmpale.ods_my_dim_date om
                cross join my_staging.sys_store ss
                where
                    om.date >= '${sdate}'
                    and om.date <= '${edate}'
                    and ss.category = 1 -- SP
                    and ss.name not like 'FH%'
                    and ss.name not like '%HUB%'
                    and ss.name not like 'OS%'
                    and ss.manage_region != 15
            ) tmp
        left join
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
            )pi on tmp.date = pi.pickup_date and tmp.name = pi.name
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
            )sd on tmp.date = sd.stat_date and tmp.name = sd.name
        where
            pi.name is not null
            or sd.name is not null
        group by 1,2,3

        union all

        select
            tmp.date pickup_date
            ,cast('BDC' as string) as kind
            ,tmp.name
            ,sum(coalesce(pi.pnt, 0) + coalesce(sd.sd_pnt,0)) pnt
        from
            (
                select
                    ss.name
                    ,om.date
                from tmpale.ods_my_dim_date om
                cross join my_staging.sys_store ss
                where
                    om.date >= '${sdate}'
                    and om.date <= '${edate}'
                    and ss.category = 10 -- BDC
                    and ss.name not like 'FH%'
                    and ss.name not like '%HUB%'
                    and ss.name not like 'OS%'
            ) tmp
        left join
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
            )pi on tmp.date = pi.pickup_date and tmp.name = pi.name
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
            )sd on tmp.date = sd.stat_date and tmp.name = sd.name
        where
            pi.name is not null
            or sd.name is not null
        group by 1,2,3

        union all


        select
            pi.pickup_date
            ,cast('ONSITE' as string) as kind
            ,pi.name
            ,sum(pi.pnt) pnt
        from
            (
                select
                    date(convert_tz(pi.created_at,'+00:00','+08:00')) pickup_date
                    ,sy.name
                    ,sy.id
                    ,count(distinct pi.pno) pnt
                from my_staging.parcel_info pi
                left join my_staging.sys_store sy on pi.ticket_pickup_store_id=sy.id
                where
                    pi.returned=0
                    and pi.state<9
                    and pi.created_at>=convert_tz('${sdate}','+08:00','+00:00')
                    and pi.created_at<date_add(convert_tz('${edate}','+08:00','+00:00'),interval 1 day)
                    and sy.category = 9
                    and sy.name <>'Autoqaqc'
                group by 1,2
            )pi
        left join dwm.dim_my_sys_store_rd dm on dm.store_id = pi.id and dm.stat_date = date_sub(curdate(), interval 1 day)
        group by 1,2,3

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
                where lt.duty_result=2
                    and lt.state=6
                    and lt.updated_at>='${sdate}'
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
                        when sy.category = 1 then 'SP'
                        when sy.category = 10 and sy.name not like 'OS%' then 'BDC'
                        else null
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
            )pr on lt.pno=pr.pno
        group by 1,2,3
    )lt on pi.pickup_date=lt.updated_at and pi.kind=lt.kind and pi.name=lt.name
group by 1,2
order by 1,2



