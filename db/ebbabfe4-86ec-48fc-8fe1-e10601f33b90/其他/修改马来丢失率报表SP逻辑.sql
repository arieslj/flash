        select
            tmp.date pickup_date
            ,cast('SP' as string) as kind
            ,tmp.name
            ,dm.region_name
            ,dm.piece_name
            ,sum(coalesce(pi.pnt, 0) + coalesce(sd.sd_pnt,0)) pnt
        from
            (
                select
                    ss.name
                    ,om.date
                    ,ss.id
                from tmpale.ods_my_dim_date om
                cross join my_staging.sys_store ss
                where
                    om.date >= '${sdate}'
                    and om.date <= '${edate}'
                    and ss.category = 1 -- SP
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
        left join dwm.dim_my_sys_store_rd dm on dm.store_id = tmp.id and dm.stat_date = date_sub(curdate(), interval 1 day)
        where
            pi.name is not null
            or sd.name is not null
        group by 1,2,3

        union all

        select
            tmp.date pickup_date
            ,cast('BDC' as string) as kind
            ,tmp.name
            ,dm.region_name
            ,dm.piece_name
            ,sum(coalesce(pi.pnt, 0) + coalesce(sd.sd_pnt,0)) pnt
        from
            (
                select
                    ss.name
                    ,om.date
                    ,ss.id
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
        left join dwm.dim_my_sys_store_rd dm on dm.store_id = tmp.id and dm.stat_date = date_sub(curdate(), interval 1 day)
        where
            pi.name is not null
            or sd.name is not null
        group by 1,2,3


;

        select
            pi.pickup_date
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
                    and ss.category = 6 -- BDC
                    and ss.name like 'FH%'
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
                    and sy.name like 'FH%'
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
                    sy.name like 'FH%'
                    and sd.stat_date>='${sdate}'
                group by 1,2
            )sd on tmp.date = sd.stat_date and tmp.name = sd.name
        where
            pi.name is not null
            or sd.name is not null
        group by 1,2,3

        ;

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
                and lt.duty_result = 1