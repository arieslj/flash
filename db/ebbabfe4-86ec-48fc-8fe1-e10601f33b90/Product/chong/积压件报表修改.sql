with t as
    (select pi.*
     from my_staging.parcel_info pi
     where pi.created_at >= convert_tz('${sdate}', '+08:00', '+00:00')
       and pi.created_at <= date_add(convert_tz('${edate}', '+08:00', '+00:00'), interval 1 day)
       and pi.state not in (5, 7, 8, 9))


   , b as
    (select b.pno
          , b.cn
          , count(distinct b.routed_at) cnt
     from (select a.pno
                , a.routed_at
                , date_sub(a.routed_at, rn) cn
           from (select pr.pno
                      , pr.routed_at                                                   routed_at
                      , row_number() over (partition by pr.pno order by pr.routed_at ) rn
                 from (select distinct pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+08:00')) routed_at
                       from my_staging.parcel_route pr
                                join (select pi.*
                                      from my_staging.parcel_info pi
                                      where pi.created_at >= convert_tz('${sdate}', '+08:00', '+00:00')
                                        and pi.created_at <=
                                            date_add(convert_tz('${edate}', '+08:00', '+00:00'), interval 1 day)
                                        and pi.state not in (5, 7, 8, 9)) t
                                     on pr.pno = t.pno and pr.store_id = t.dst_store_id
                       where pr.route_action = 'INVENTORY'
                         and pr.routed_at >= convert_tz('${sdate}', '+08:00', '+00:00')) pr
                          left join
                      (select distinct pr.pno
                                     , date(convert_tz(pr.routed_at, '+00:00', '+08:00')) routed_at
                       from my_staging.parcel_route pr
                                join (select pi.*
                                      from my_staging.parcel_info pi
                                      where pi.created_at >= convert_tz('${sdate}', '+08:00', '+00:00')
                                        and pi.created_at <=
                                            date_add(convert_tz('${edate}', '+08:00', '+00:00'), interval 1 day)
                                        and pi.state not in (5, 7, 8, 9)) t
                                     on pr.pno = t.pno and pr.store_id = t.dst_store_id
                       where pr.route_action <> 'INVENTORY'
                         and pr.routed_at >= convert_tz('${sdate}', '+08:00', '+00:00')) prin
                      on prin.pno = pr.pno and prin.routed_at = pr.routed_at
                 where prin.pno is null) a) b
     group by 1, 2)


select t1.pno
     , if(t1.returned = 1, '退件', '正向件')         方向
     , t1.client_id                                  客户ID
     , case
           when bc.`client_id` is not null then bc.client_name
           when kp.id is not null and bc.client_id is null then '普通ka'
           when kp.`id` is null then '小c'
    end                  as                          客户类型
     , case t1.state
           when 1 then '已揽收_RECEIVED'
           when 2 then '运输中_IN_TRANSIT'
           when 3 then '派送中_DELIVERING'
           when 4 then '已滞留_STRANDED'
           when 5 then '已签收_SIGNED'
           when 6 then '疑难件处理中_IN_DIFFICULTY'
           when 7 then '已退件_RETURNED'
           when 8 then '异常关闭_ABNORMAL_CLOSED'
           when 9 then '已撤销_CANCEL'
    end                  as                          包裹状态
     , case
           when lt_duty.pno is not null and pr.last_route_action <> 'CLOSE_ORDER' then '调度判责丢失后又解锁'
           when pr.last_valid_route_action = 'DISCARD_RETURN_BKK' then '回拍卖仓包裹，没有监控'
           when t1.state != 6 and datediff(now(), pr.routed_at) > 7 and plt2.pno is not null then '调度无须追责后长期无有效路由'
           when t1.state = 6 and (lts2.pno is not null or di.diff_marker_category in (32, 69, 7, 22)) then '疑似丢失待处理'
           when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
           when b.cnt >= 3 then '连续3天盘库无其他路由'
           when pr.store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
           else null end                             卡点原因
     , case
           when t1.state = 6 and cs.client_id is not null and
                (di.diff_marker_category not in (32, 69, 7, 22) or di.diff_marker_category is null) then '总部CS'
           when t1.state = 6 and lts.pno is not null then '总部CS'
           when t1.state = 6 and lts2.pno is not null then '调度'
           when t1.state = 6 and bc.client_name is null and kp.department_id = '388' and
                (di.diff_marker_category not in (32, 69, 7, 22) or di.diff_marker_category is null) then 'KAM'
           when t1.state = 6 and bc.client_name = 'lazada' and
                (di.diff_marker_category not in (32, 69, 7, 22) or di.diff_marker_category is null) then 'PMD_LAZ'
           when t1.state = 6 and bc.client_name = 'tiktok' and
                (di.diff_marker_category not in (32, 69, 7, 22) or di.diff_marker_category is null) then 'PMD_TT'
           when t1.state = 6 and di.diff_marker_category in (32, 69, 7, 22) then '调度'
           when t1.state = 6 then 'SP'
           when t1.state <> 6 and pr.store_id = t1.ticket_pickup_store_id and plt2.pno is null and
                (b.cnt < 3 or b.cnt is null)
               and t1.returned = 0 then '调度'
           when t1.state <> 6 and pr.category in (1, 4, 11) then 'SP'
           when t1.state <> 6 and pr.store_name like 'FH%' then 'FH'
           when t1.state <> 6 and pr.store_name like '%HUB%' then 'HUB'
           when t1.state <> 6 and pr.store_name like 'BDC%' then 'BDC'
           when t1.state <> 6 and pr.store_name in ('Auto调度') then '调度'
           when t1.state <> 6 and pr.store_name like 'SHOP%' then '调度'
           when t1.state <> 6 and pr.store_name like 'OS%' then '调度'
           when t1.state <> 6 and pr.store_name in ('IT&Products', 'Customer Service') and pr1.category in (1, 4, 11)
               then 'SP'
           when t1.state <> 6 and pr.store_name in ('IT&Products', 'Customer Service') and pr1.store_name like 'FH%'
               then 'FH'
           when t1.state <> 6 and pr.store_name in ('IT&Products', 'Customer Service') and pr1.store_name like '%HUB%'
               then 'HUB'
           when t1.state <> 6 and pr.store_name in ('IT&Products', 'Customer Service') and pr1.store_name like 'BDC%'
               then 'BDC'
           else null end as                          负责部门
     , datediff(now(), pr.routed_at)                 最后有效路由距今天数
     , pr.routed_at                                  最后一条有效路由时间
     , pr.last_valid_route_action                    最后一条路由
     , pr.store_name                                 最后一条路由网点
     , pr.piece_name                                 最后一条路由网点片区
     , pr.region_name                                最后一条网点大区
     , pr1.store_name                                前一条路由网点
     , sy1.name                                      目的地网点
     , sy.name                                       揽收网点
     , convert_tz(t1.created_at, '+00:00', '+08:00') 揽收时间
     , if(t1.cod_enabled = 1, 'COD', '非COD')        是否为COD
     , pr_time.sc_cnt '交接次数（有交接记录）'
     , pr_time.mark_cnt '快递员尝试派送次数（标记次数）'
     , pr_time.diff_cnt '有效尝试派送次数（有上报问题件/留仓）'
     ,wg.third_sorting_code 网格码
     , case
           when bc.client_name = 'lazada' then lp.whole_end_date
           when bc.client_name = 'tiktok' then lp1.end_7_plus_date
           else null end as                          超时效截止日
     , di_des.dates
from t t1
         left join my_staging.ka_profile kp on t1.client_id = kp.id
         left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
         left join my_staging.sys_store sy on t1.ticket_pickup_store_id = sy.id
         left join my_staging.sys_store sy1 on t1.dst_store_id = sy1.id
         left join dwm.dwd_ex_my_lazada_pno_period lp on t1.pno = lp.pno
         left join dwm.dwd_ex_my_tiktok_sla_detail lp1 on t1.pno = lp1.pno
         left join b on t1.pno = b.pno
         left join
     (select pc.*,
             client_id
      from (select *
            from my_staging.sys_configuration
            where cfg_key = 'diff.ticket.customer_service.ka_client_ids') pc lateral view explode(split(pc.cfg_value, ',')) id as client_id
      ) cs
     on t1.client_id = cs.client_id
         left join
     (select a.*
      from (select pr.pno
                 , pr.last_valid_route_action
                 , pr.last_route_action
                 , sy.name                                                                        store_name
                 , smp.name                                                                       piece_name
                 , smr.name                                                                       region_name
                 , sy.category
                 , pr.last_valid_store_id                                                         store_id
                 , convert_tz(pr.last_valid_routed_at, '+00:00', '+08:00')                        routed_at
                 , row_number() over (partition by pr.pno order by pr.last_valid_routed_at desc ) rk
            from dwm.parcel_store_stage_new pr
                     join t t3 on t3.pno = pr.pno
                     left join my_staging.sys_store sy on pr.last_valid_store_id = sy.id
                     left join my_staging.sys_manage_piece smp on smp.id = sy.manage_piece
                     left join my_staging.sys_manage_region smr on smr.id = sy.manage_region
            where pr.pno_created_at >= convert_tz('${sdate}', '+08:00', '+00:00')) a
      where rk = 1) pr on pr.pno = t1.pno
         left join
     (select *
      from (select pr.pno
                 , pr.store_name
                 , pr.store_id
                 , pr.routed_at
                 , pr.route_action
                 , sy.category
                 , row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from my_staging.parcel_route pr
                     join t t3 on t3.pno = pr.pno
                     left join my_staging.sys_store sy on pr.store_id = sy.id
            where pr.route_action in
                  ('INVENTORY', 'RECEIVED', 'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN',
                   'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM',
                   'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO', 'SEAL', 'UNSEAL',
                   'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT',
                   'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN',
                   'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE',
                   'REFUND_CONFIRM', 'ACCEPT_PARCEL')
              and pr.routed_at >= convert_tz('${sdate}', '+08:00', '+00:00'))
      where rk = 1) pr1 on pr1.pno = t1.pno

         left join
     (select plt.pno
      from my_bi.parcel_lose_task plt
               join t t1 on t1.pno = plt.pno
      where plt.state = 5
        and plt.operator_id not in (10000, 10001, 10002)
        and plt.created_at >= '${sdate}'
      group by 1) plt2 on plt2.pno = t1.pno
         left join
     (select t2.pno
           , cdt.negotiation_result_category
           , di.diff_marker_category
      from my_staging.diff_info di
               join t t2 on t2.pno = di.pno
               join my_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
               left join my_bi.parcel_lose_task plt on plt.source_id = cdt.id
      where cdt.negotiation_result_category is null
        and di.created_at >= convert_tz('${sdate}', '+08:00', '+00:00')) di on di.pno = t1.pno

left join
    (
        select
            a.pno
            ,count(distinct if(a.route_action in ('DELIVERY_TICKET_CREATION_SCAN'), a.routed_date, null)) sc_cnt
            ,count(distinct if(a.route_action in ('DELIVERY_MARKER'), a.routed_date, null)) mark_cnt
            ,count(distinct if(a.route_action in ('DIFFICULTY_HANDOVER','DETAIN_WAREHOUSE'), a.routed_date, null)) diff_cnt
        from
            (
                select
                    pr.pno
                    , date(convert_tz(pr.routed_at, '+00:00', '+08:00'))   routed_date
                    , pr.route_action
                from my_staging.parcel_route pr
                join t t3 on t3.pno = pr.pno
                where
                    pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN', 'DELIVERY_MARKER', 'DIFFICULTY_HANDOVER','DETAIN_WAREHOUSE')
                    and pr.routed_at >= convert_tz('${sdate}', '+08:00', '+00:00')
                group by 1,2,3
            ) a
        group by 1
    ) pr_time on pr_time.pno = t1.pno
left join
     (select lt.pno
           , date(lt.updated_at)                  updated_at
           , date(lt.created_at)                  created_at
           , lt.updated_at                        updated_time
           , if(lt.state = 6, '责任人认定', '无') is_resp
      from my_bi.parcel_lose_task lt
               join t on lt.pno = t.pno
      where lt.duty_result = 1
        and lt.state = 6
        and lt.created_at >= '${sdate}') lt_duty on t1.pno = lt_duty.pno
         left join
     (select *
      from (select di.pno
                 , date(convert_tz(di.created_at, '+00:00', '+08:00'))                  dates
                 , row_number() over (partition by di.pno order by di.created_at desc ) rk
            from my_staging.diff_info di
                     join t t3 on t3.pno = di.pno
            where di.created_at >= convert_tz('${sdate}', '+08:00', '+00:00')) di
      where di.rk = 1) di_des on t1.pno = di_des.pno
         left join my_bi.ss_court_task lts on t1.pno = lts.pno
         left join
     (select lt.pno
      from my_bi.parcel_lose_task lt
               join t on lt.pno = t.pno
      where lt.duty_result = 1
        and lt.created_at >= '${sdate}') lts2 on t1.pno = lts2.pno
left join
    (
        select
            distinct
            pr.pno
            , convert_tz(pr.`routed_at`, '+00:00', '+08:00') routed_at
            , pr.store_name
        from my_staging.parcel_route pr
        join t on pr.pno = t.pno
        where pr.route_action = 'REFUND_CONFIRM'
            and pr.routed_at >= convert_tz('${sdate}', '+08:00', '+00:00')
    ) pr_hold on t1.pno = pr_hold.pno
left join
    (
        select
            t1.pno
            ,ps.third_sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc) rk
        from my_drds_pro.parcel_sorting_code_info ps
        join t t1 on t1.pno = ps.pno
        where
            ps.created_at > date_sub('${sdate}', interval 10 day)
    ) wg on wg.pno = t1.pno and wg.rk = 1
where pr_hold.pno is null

group by t1.pno
