select
 	pi.kind DC
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
# left join
#     (
#         select
#             case
#                 when ss.name like '%HUB%' then 'HUB'
#                 when ss.name like 'FH%' then 'FH'
#                 when ss.name like 'OS%' then 'ONSITE'
#                 else 'SP'
#             end as kind
#             ,date(plt.updated_at) updated_at
#             ,ss.name
#             ,sum(plr.duty_ratio/100) pnt
#         from
#             (
#                 select
#                     plt.*
#                 from
#                     (
#                         select
#                             plt.pno
#                             ,plt.created_at
#                             ,plt.updated_at
#                             ,plt.id
#                             ,row_number() over (partition by plt.pno order by plt.created_at) rk
#                         from my_bi.parcel_lose_task plt
#                         where
#                             plt.updated_at >= '${sdate}'
#                             and plt.state = 6
#                             and plt.duty_result = 1
#                             and plt.penalties > 0
#                     ) plt
#                 where
#                     plt.rk = 1
#             ) plt
#         join my_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
#         left join my_staging.sys_store ss on ss.id = plr.store_id
#         where
#             ss.name != 'Autoqaqc'
#         group by 1,2,3
#     ) lt on pi.pickup_date=lt.updated_at and pi.kind=lt.kind and pi.name=lt.name
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
                    and lt.duty_result = 1
                    -- and sy.name like '%HUB%'
                group by 1
                order by 1
            )pr on lt.pno=pr.pno
        group by 1,2,3
        order by 1,2,3
    )lt on pi.pickup_date=lt.updated_at and pi.kind=lt.kind and pi.name=lt.name
group by 1
order by 1



;








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
                and lt.duty_result = 1
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
                    and lt.duty_result = 1
                    -- and sy.name like '%HUB%'
                group by 1
                order by 1
            )pr on lt.pno=pr.pno
        group by 1,2,3
        order by 1,2,3
    )lt on pi.pickup_date=lt.updated_at and pi.kind=lt.kind and pi.name=lt.name
group by 1,2
order by 1,2


;




 select
    prn.kind
    ,prn.name
    ,lt.updated_at
    ,lt.pno
    ,pr.dcs
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
        and lt.duty_result = 1
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


 ;




select
    '异常包裹判责【禁运品】/Abnormal - Contraband ' type
    ,count(c.id) pnt
from my_bi.contraband c
where
    c.status = 1

union all

select
     '异常包裹判责【违规件举报】/Abnormal - unqualified Parcel Report' type
    ,count(pvr.id) pnt
from my_bi.parcel_violate_rules pvr
where
    pvr.status = 1

union all

select
    case put.punishment_type
        when 1 then '异常包裹判责【漏揽收扫描】/Abnormal - Missed Scanning'
        when 2 then '异常包裹判责【虚假撤销】/ Abnormal - Fake Recall'
    end type
    ,count(distinct put.id) pnt
from my_bi.parcel_unpickup_task put
where
    put.process_status in (1,2,3)
group by 1

--union all
--
--select
--    '虚假标记审核【标记电话号码空号】/Fal se Mark Review - Mark Empty Phone ' type
--    ,count(distinct tfa.id) pnt
--from my_bi.ticket_fake_audit_marker tfa
--where
--    tfa.state = 1

--union all
--
--select
--    '虚假标记审核【标记超大件，违禁物品审核】/ Fal se Mark Review - Mark Oversized & Forbidden Goods for Review ' type
--    ,count(distinct tcf.id) pnt
--from my_bi.ticket_cancel_fake_mark tcf
--where
--    tcf.state = 1

union all

select
    '网络申述处理【集体罚款】/ Complain Handling - Individual Penalties' type
    ,count(distinct am.average_merge_key) pnt
from my_bi.abnormal_message am
left join my_bi.abnormal_qaqc aq on aq.qaqc_merge_key = am.average_merge_key
where
    am.abnormal_object = 1
    and aq.type = 1
    and coalesce(am.isappeal ,aq.isappeal) = 2
    and am.isdel = 0
group by 1

union all

select
    case am.`abnormal_object`
        when 0 then '网络申述处理【个人罚款】/ Complain Handling - Collective Penalties'
        when 1 then '网络申述处理【集体罚款】/ Complain Handling - Individual Penalties'
        when 2 then '网络申述处理【加盟商罚款】/ Complain Handling - Flash Home Penalties'
    end as type
    ,count(distinct am.id) pnt
from my_bi.abnormal_message am
left join my_bi.abnormal_qaqc aq on am.id = aq.abnormal_message_id
where
    am.abnormal_object in (2,0)
    and aq.type in (2,3)
    and coalesce(am.isappeal ,aq.isappeal) = 2
    and am.isdel = 0
group by 1