with s1 as
(
    select
        t1.dst_store_id store_id
        ,t1.dst_store store_name
        ,count(t1.pno) 在仓包裹数
        ,count(if(t1.cod_enabled = 'YES', t1.pno, null)) 在仓COD包裹数
        ,count(if(t1.days <= 3, t1.pno, null)) 3日内滞留
        ,count(if(t1.days <= 3 and t1.cod_enabled = 'YES', t1.pno, null)) 3日内COD滞留
        ,count(if(t1.days <= 5, t1.pno, null)) 5日内滞留
        ,count(if(t1.days <= 5 and t1.cod_enabled = 'YES', t1.pno, null)) 5日内COD滞留
        ,count(if(t1.days <= 7, t1.pno, null)) 7日内滞留
        ,count(if(t1.days <= 7 and t1.cod_enabled = 'YES', t1.pno, null)) 7日内COD滞留
        ,count(if(t1.days > 7, t1.pno, null)) 超7天滞留
        ,count(if(t1.days > 7 and t1.cod_enabled = 'YES', t1.pno, null)) 超7天COD滞留
        ,count(if(t1.client_name = 'lazada', t1.pno, null)) lazada在仓
        ,count(if(t1.client_name = 'lazada' and t1.cod_enabled = 'YES', t1.pno, null)) lazadaCOD在仓
        ,count(if(t1.client_name = 'shopee', t1.pno, null)) shopee在仓
        ,count(if(t1.client_name = 'shopee' and t1.cod_enabled = 'YES', t1.pno, null)) shopeeCOD在仓
        ,count(if(t1.client_name = 'tiktok', t1.pno, null)) tt在仓
        ,count(if(t1.client_name = 'tiktok' and t1.cod_enabled = 'YES', t1.pno, null)) ttCOD在仓
        ,count(if(t1.client_name = 'ka&c', t1.pno, null)) 'KA&小C在仓'
        ,count(if(t1.client_name = 'ka&c' and t1.cod_enabled = 'YES', t1.pno, null)) 'KA&小CCOD在仓'
    from
        (
            select
                de.pno
                ,de.dst_store_id
                ,de.dst_store
                ,if(bc.client_name is not null , bc.client_name, 'ka&c') client_name
                ,datediff(curdate(), de.dst_routed_at) days
                ,de.cod_enabled
            from dwm.dwd_ex_ph_parcel_details de
            left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
            where
                de.parcel_state not in (5,7,8,9)
                and de.dst_routed_at is not null
        ) t1
    group by 1
)
,s2 as
(
    select
        a1.dst_store_id store_id
        ,a1.dst_store store_name
        ,a1.num 当日到达COD包裹
        ,a2.num 当日交接COD包裹
        ,a3.num 当日妥投COD包裹
        ,a3.num/a1.num 当日到站COD妥投率
        ,a4.last_3day_num 3日内COD妥投包裹
        ,a4.last_3day_rate 3日COD妥投率
        ,a5.last_3_5day_num 5日COD妥投包裹
        ,a5.last_3_5day_rate 5日COD妥投率
        ,a6.last_5_7day_num 7日内COD包裹妥投数
        ,a6.last_5_7day_rate 7日COD妥投率
        ,a7.over_7day_num 超7日COD包裹妥投数
        ,a7.over_7day_rate 超7日COD妥投率
    from
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a1
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.first_scan_time >= date_sub(curdate(), interval 8 hour )
                and de.first_scan_time < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a2  on a2.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.finished_date = curdate()
                and de.parcel_state = 5
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a3 on a3.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 3 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 3 day), interval 16 hour) -- 3天前到达
            group by 1,2
         ) a4 on a4.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3_5day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3_5day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 5 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 5 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a5 on a5.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_5_7day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_5_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 7 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a6 on a6.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null)) over_7day_num
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null))/count(de.pno) over_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.parcel_state < 9
                and
                    (
                        ( de.parcel_state not in (5,7,8,9) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                        or ( de.parcel_state in (5,7,8) and de.updated_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                    )
            group by 1,2
        ) a7 on a7.dst_store_id = a1.dst_store_id
)
,s3 as
-- 应退件
(
    select
        de.dst_store_id store_id
        ,de.dst_store  store_name
        ,count(t.pno)  应退件包裹
        ,count(if(de.cod_enabled = 'YES', de.pno, null)) 应退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null)) 实际退件包裹
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null)) 实际退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null))/count(t.pno) 退件操作完成率
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null))/count(if(de.cod_enabled = 'YES', de.pno, null)) COD退件操作完成率
    from
        (
            select
                pr.pno
            from ph_staging.parcel_route pr
            where
                pr.routed_at > date_sub(curdate(), interval 8 hour)
                and pr.route_action = 'PENDING_RETURN' -- 待退件
            group by 1
        ) t
    join dwm.dwd_ex_ph_parcel_details de on t.pno = de.pno
    group by 1,2
)
,s4 as
(
    select
        pr.next_store_id store_id
        ,pr.next_store_name store_name
        ,count(pr.pno) 应到退件包裹
        ,count(if(pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
        ,count(if(de.dst_routed_at is not null , pr.pno, null)) 实到退件包裹
        ,count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) 实到退件COD包裹
        ,count(if(pi.state = 5, pr.pno, null)) 退件妥投包裹
        ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null)) 退件妥投COD包裹
        ,count(if(pi.state = 5, pr.pno, null))/count(if(de.dst_routed_at is not null , pr.pno, null)) 退件妥投完成率
        ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null))/count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) COD退件妥投完成率
    from ph_staging.parcel_route pr
    left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    left join ph_staging.parcel_info pi2 on  pi2.returned_pno = pi.pno
    left join dwm.dwd_ex_ph_parcel_details de on de.pno = pr.pno
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day)
        and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
        and pi.returned = 1
        and pr.next_store_id = pi.dst_store_id
    group by 1,2
)
select
    ss.store_id
    ,ss.store_name
    ,s1.在仓包裹数, s1.在仓COD包裹数, s1.`3日内滞留`, s1.`3日内COD滞留`, s1.`5日内滞留`, s1.`5日内COD滞留`, s1.`7日内滞留`, s1.`7日内COD滞留`, s1.超7天滞留, s1.超7天COD滞留, s1.lazada在仓, s1.lazadaCOD在仓, s1.shopee在仓, s1.shopeeCOD在仓, s1.tt在仓, s1.ttCOD在仓, s1.`KA&小C在仓`, s1.`KA&小CCOD在仓`
    ,s2.当日到达COD包裹, s2.当日交接COD包裹, s2.当日妥投COD包裹, s2.当日到站COD妥投率, s2.`3日内COD妥投包裹`, s2.`3日COD妥投率`, s2.`5日COD妥投包裹`, s2.`5日COD妥投率`, s2.`7日内COD包裹妥投数`, s2.`7日COD妥投率`, s2.超7日COD包裹妥投数, s2.超7日COD妥投率
    ,s3.应退件包裹, s3.应退件COD包裹, s3.实际退件包裹, s3.实际退件COD包裹, s3.退件操作完成率, s3.COD退件操作完成率
    ,s4.应到退件包裹, s4.应到退件COD包裹, s4.实到退件包裹, s4.实到退件COD包裹, s4.退件妥投包裹, s4.退件妥投COD包裹, s4.退件妥投完成率, s4.COD退件妥投完成率
from
    (
        select s1.store_id,s1.store_name from s1 group by 1,2
        union
        select s2.store_id,s2.store_name from s2 group by 1,2
        union
        select s3.store_id,s3.store_name from s3 group by 1,2
        union
        select s4.store_id,s4.store_name from s4 group by 1,2
    ) ss
left join s1 on s1.store_id = ss.store_id
left join s2 on s2.store_id = ss.store_id
left join s3 on s3.store_id = ss.store_id
left join s4 on s4.store_id = ss.store_id
;




