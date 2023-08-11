create table dwm.dwm_ph_fleet_plan_arrive_time as
 with  vehicle_plan_line  as
    (
       select
           dp.store_id
           ,dp.store_name
           ,dp.area_name
           ,dp.piece_name
           ,dp.region_name
           ,fvl.id
          ,fvl.name
           ,fvl.origin_id
          ,fvl.origin_name
          ,fvl.target_id
          ,fvl.target_name
          ,fvl.mode
          ,concat(current_date,' ',substr(fvl.plan_arrive_time,4,5),':00') as plan_arrive_time
           ,if(fvl.store_name in('MTS_SP','MTI_SP','TAB_SP','WTB_SP','SMO_SP','MNT_SP','MTG_SP','SCZ_SP','WTG_SP','PSC_SP','NAV_SP','PST_SP','TAU_SP','BAH_SP','CBA_SP','DLM_SP'),'2派网点','1派网点') as store_type
          ,if(fvl.store_name in('MTS_SP','MTI_SP','TAB_SP','WTB_SP','SMO_SP','MNT_SP','MTG_SP','SCZ_SP','WTG_SP','PSC_SP','NAV_SP','PST_SP','TAU_SP','BAH_SP','CBA_SP','DLM_SP') and fvl.name like '%2WV-%', '2派车线','1派车线') as line_type
       from
           (
              select
                  dp.store_id
                  ,dp.store_name
                  ,dp.area_name
                  ,dp.piece_name
                  ,dp.region_name
             from dwm.dim_ph_sys_store_rd dp
             where  dp.opening_at is not null
             and dp.state_desc='激活'
             and dp.stat_date = date_sub(curdate(), interval 1 day)
             and dp.store_category in(1,14)
           )dp
       left join
          (
             select
                  fvl.origin_id
                  ,fvl.origin_name
                  ,fvl.target_id
                  ,fvl.target_name
                  ,fvl.mode
                  ,fvl.name
                  ,fvl.id
                  ,fvl.deleted
                  ,fvlt.store_id
                  ,fvlt.store_name
                ,if(fvlt.estimate_end_time>1440,sec_to_time(fvlt.estimate_end_time-1440),sec_to_time(fvlt.estimate_end_time)) as plan_arrive_time
                ,fvlt.order_no
              from ph_staging.fleet_van_line fvl
             left join ph_staging.sys_store ss on fvl.origin_id=ss.id
             left join ph_staging.sys_store ss1 on fvl.target_id=ss1.id
              left join ph_staging.fleet_van_line_timetable fvlt on fvl.id=fvlt.line_id and fvlt.deleted=0
              left join ph_staging.sys_store ss2 on fvlt.store_id=ss2.id
             where fvl.deleted=0
               and fvl.mode in(1,3)
               and ss1.category in(1,14)
               and (ss.category=8 or ss.id in ( 'PH20180101', 'PH26110100', 'PH59020701','PH42030J00', 'PH36100100','PH76190100', 'PH34420100', 'PH73020100', 'PH81161D00', 'PH80050100'))
               and fvlt.order_no>=2
               and ss2.category in(1,14)
          )fvl on dp.store_id=fvl.store_id
    )

select
    f1.store_id
    ,f1.store_name
    ,f1.area_name
    ,f1.piece_name
    ,f1.region_name
    ,f1.id as line_1_latest_id
    ,f1.name as line_1_latest_name
    ,f1.origin_id
    ,f1.origin_name
    ,f1.target_id
    ,f1.target_name
    ,f1.mode as line_1_latest_mode
    ,f1.plan_arrive_time as line_1_latest_plan_arrive_time
    ,case when f1.name is null then null
        when f1.plan_arrive_time>concat(current_date,' 09:20:00') then f1.plan_arrive_time else concat(current_date,' 09:20:00') end  as adjust_line_1_latest_plan_arrive_time
    ,f2.name as line_2_latest_name
    ,f2.plan_arrive_time as line_2_latest_plan_arrive_time
   ,case when f2.name is null then null
       when f2.plan_arrive_time>concat(current_date,' 13:20:00') then f2.plan_arrive_time else concat(current_date,' 13:20:00') end  as adjust_line_2_latest_plan_arrive_time
    from
    (
        select
            vpl.*
            , row_number() over (partition by vpl.store_id order by vpl.plan_arrive_time desc) as rk
          from vehicle_plan_line vpl
          where vpl.line_type = '1派车线'
    )f1
    left join
    (
       select
           vpl.*
           , row_number() over (partition by vpl.store_id order by vpl.plan_arrive_time desc) as rk
         from vehicle_plan_line vpl
         where vpl.line_type = '2派车线'
    )f2 on f1.store_id=f2.store_id and f2.rk=1
where f1.rk=1;





drop table dwm.dwd_ph_ex_should_delivery;
create table dwm.dwd_ph_ex_should_delivery  as
select
    a.pno
    ,a.store_id as dst_store_id-- 包裹目的地网点
    ,a.parcel_type -- 包裹类型今日包裹/历史包裹
    ,a.first_valid_routed_at -- 目的地网点第一条有效路由时间
    ,a.first_route_action -- 目的地网点第一条有效路由名称
    ,b.arrival_warehouse_time -- 目的地网点的第一条到件入仓时间
    ,c.receive_warehouse_time -- 自揽自派收件入仓
    ,if(ticket_pickup_store_id<>dst_store_id,'非自揽自派','自揽自派') delivery_type
from
(
-- 当日到达目的地网点的第一条有效路由
    select
        c.pno
        ,c.store_id
        ,'当日包裹' parcel_type
        ,c.first_valid_routed_at
        ,c.route_action as first_route_action
       ,c.ticket_pickup_store_id
       ,c.dst_store_id
    from
    (
         select
             pr.pno
            ,pr.store_id
            ,pr.route_action
          ,pi.ticket_pickup_store_id
          ,pi.dst_store_id
            ,date_add(pr.routed_at,interval 8 hour) first_valid_routed_at
            ,row_number() OVER (PARTITION BY pr.pno,pr.store_id ORDER BY pr.routed_at  ) AS 'rk'
         from ph_staging.parcel_route pr
         join dwm.dwd_dim_dict dc on dc.element=pr.route_action and dc.remark='valid'
         join ph_staging.parcel_info pi on pr.pno=pi.pno and pr.store_id=pi.dst_store_id
         and pr.routed_at>=convert_tz(date_sub(CURDATE(),interval 20 day) , '+08:00', '+00:00')
         and pi.state<9
    ) as c where c.rk=1 and  c.first_valid_routed_at>=curdate()
-- 历史到达目的地网点的第一条有效路由
   union all
    select
        c.pno
        ,c.store_id
        ,'历史包裹' parcel_type
        ,c.first_valid_routed_at
        ,c.route_action as first_route_action
       ,c.ticket_pickup_store_id
       ,c.dst_store_id
    from
    (
        select
             pr.pno
             ,pr.store_id
             ,pr.route_action
           ,pi.ticket_pickup_store_id
           ,pi.dst_store_id
             ,date_add(pr.routed_at,interval 8 hour) first_valid_routed_at
             ,row_number() OVER (PARTITION BY pr.pno,pr.store_id ORDER BY pr.routed_at  ) AS 'rk'
         from ph_staging.parcel_route pr
         join dwm.dwd_dim_dict dc on dc.element=pr.route_action and dc.remark='valid'
         join
          (
            select *
           from dwm.dwd_ph_pno_on_warhouse_detl_d ss
           where ss.stat_date = date_sub(current_date, interval 1 day)
           ) ss on pr.pno=ss.pno
         join ph_staging.parcel_info pi
        on pr.pno=pi.pno and pr.store_id=pi.dst_store_id
         where pr.routed_at>=convert_tz(date_sub(CURDATE(),interval 60 day) , '+08:00', '+00:00')
    ) as c where rk=1 and c.first_valid_routed_at<curdate()
)a
-- 目的地网点的第一条到件入仓有效路由
left join
(
    select
        c.pno
        ,c.store_id
        ,c.arrival_warehouse_time
    from
    (
         select
             pr.pno
             ,pr.store_id
             ,date_add(pr.routed_at,interval 8 hour) arrival_warehouse_time
             ,row_number() OVER (PARTITION BY pr.pno,pr.store_id ORDER BY pr.routed_at  ) AS 'rk'
         from ph_staging.parcel_route pr
         join ph_staging.parcel_info pi on pr.pno=pi.pno and pi.dst_store_id=pr.store_id
         and pr.routed_at>=convert_tz(date_sub(CURDATE(),interval 60 day) , '+08:00', '+00:00')
         and pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN')
    ) as c where rk=1
) b
on a.pno=b.pno and a.store_id=b.store_id
left join
-- 包裹第一次收件入仓时间
(
    select
        c.pno
        ,c.store_id
        ,c.receive_warehouse_time
    from
    (
         select
             pr.pno
             ,pr.store_id
             ,date_add(pr.routed_at,interval 8 hour) receive_warehouse_time
             ,row_number() OVER (PARTITION BY pr.pno,pr.store_id ORDER BY pr.routed_at  ) AS 'rk'
         from ph_staging.parcel_route pr
         join ph_staging.parcel_info pi on pr.pno=pi.pno and pi.dst_store_id=pr.store_id and pi.ticket_pickup_store_id=pi.dst_store_id
         and pr.routed_at>=convert_tz(date_sub(CURDATE(),interval 60 day) , '+08:00', '+00:00')
         and  pr.route_action in ('RECEIVE_WAREHOUSE_SCAN')
    ) as c where rk=1
) c on a.pno=c.pno and a.store_id=c.store_id



-- drop table dwm.dwd_ph_dc_should_be_delivery;
create table dwm.dwd_ph_dc_should_be_delivery as
select
sd.pno
,sd.dst_store_id
,sd.parcel_type
,sd.delivery_type
,sd.first_valid_routed_at
,sd.arrival_warehouse_time -- 到件入仓时间
,sd.receive_warehouse_time -- 收件入仓
,sd.first_route_action  -- 有效路由动作
,fp.line_1_latest_name -- 一派车线
,fp.line_1_latest_plan_arrive_time -- 一派车线的计划到达时间
,fp.adjust_line_1_latest_plan_arrive_time -- 一派车线的计划到达时间（修正后的）
,fp.line_2_latest_name -- 二派车线
,fp.line_2_latest_plan_arrive_time -- 二派车线的计划到达时间
,fp.adjust_line_2_latest_plan_arrive_time -- 二派车线的计划到达时间（修正后的）
,ftd.real_arrived_at  -- 包裹到港时间
,ftd.sign_time -- 司机打卡时间
,pr_hvo.have_hair_date  -- 有发无到时间
,pr_hvo.fei_route_date  -- 非目的地网点有效路由时间
,if(diff.pno is null,'错分','') diff_pno  -- 是否错分包裹
,pr2.reschedule_marker_time -- 标记改约时间
,pr2.desire_date -- 改约后的时间
,lt.updated_at as lost_time -- 丢失包裹时间
from
dwm.dwd_ph_ex_should_delivery sd


left join
dwm.dwm_ph_fleet_plan_arrive_time fp on sd.dst_store_id=fp.store_id
left join
(
    select
    relation_no pno
    ,next_store_id store_id
    ,min(real_arrived_at) real_arrived_at -- 包裹到港时间
    ,min(sign_time) sign_time -- 打卡时间
    from
     (
       --  当日到港包裹、出车凭证
       select
          dd.relation_no,
          dd.proof_id,
          dd.next_store_id,
          min(convert_tz(fvr.created_at,'+00:00','+08:00')) real_arrived_at
       from  ph_staging.fleet_van_proof_parcel_detail dd

       join ph_staging.fleet_van_route fvr
       on dd.next_store_id=fvr.store_id
       and dd.proof_id=fvr.proof_id
       where
       dd.relation_category in (1,3)
       and dd.state in (1,2)
       and fvr.event =1
       and fvr.deleted =0
       group by dd.relation_no,dd.proof_id,dd.next_store_id
     ) ft
     left join
    (   -- 司机app打卡时间
       select
          fd.proof_id
          ,fd.store_id
          ,date_add(max(fd.operator_time), interval 8 hour) as sign_time
       from ph_staging.fleet_driver_route fd
       where fd.event = 1
       and fd.state != 2
       -- and fd.operator_time >= date_sub(curdate(), interval 8 hour)
       group by fd.proof_id, fd.store_id
     ) fd on  fd.store_id = ft.next_store_id and fd.proof_id = ft.proof_id
     group by 1,2
 ) ftd on ftd.pno=sd.pno and ftd.store_id=sd.dst_store_id
left join
(   -- 有发无到
    select
    pi.pno ,
    pr.route_date have_hair_date,  -- 有发无到时间
    pr_vo.route_date  fei_route_date -- 非目的地网点有效路由时间
    from
    dwm.dwd_ph_ex_should_delivery pi
    left join
    ( -- 提交有发无到
       select
       pr.pno,
       pr.store_id,
       max(date(convert_tz(pr.routed_at,'+00:00','+08:00'))) route_date,
       max(convert_tz(pr.routed_at,'+00:00','+08:00')) route_time
       from ph_staging.parcel_route pr
       where pr.routed_at>=convert_tz(date_sub( CURRENT_DATE,interval 30 day),'+08:00','+00:00')
       and pr.routed_at<convert_tz(date_add( CURRENT_DATE,interval 1 day),'+08:00','+00:00')
       and pr.route_action='HAVE_HAIR_SCAN_NO_TO'
       group by 1,2
    ) pr
    on pr.pno=pi.pno and pr.store_id=pi.dst_store_id

    left join
    ( -- 目的地网点有效路由
       select
       pr.pno,
       pr.store_id,
       min(date(convert_tz(pr.routed_at,'+00:00','+08:00'))) route_date
       from ph_staging.parcel_route pr
       join dwm.dwd_dim_dict ddd
       on ddd.element=pr.route_action and ddd.tablename='parcel_route' and ddd.remark='valid'
       where pr.routed_at>=convert_tz(date_sub( CURRENT_DATE,interval 30 day),'+08:00','+00:00')
       and pr.routed_at<convert_tz(date_add( CURRENT_DATE,interval 1 day),'+08:00','+00:00')
       group by 1,2
    ) pr_v
    on pr_v.pno=pi.pno and pr_v.store_id=pi.dst_store_id

    left join
    ( -- 非目的地网点有效路由
       select
       pr.pno,
       max(date(convert_tz(pr.routed_at,'+00:00','+08:00'))) route_date,
       max(convert_tz(pr.routed_at,'+00:00','+08:00')) route_time
       from ph_staging.parcel_route pr
       join dwm.dwd_dim_dict ddd
       on ddd.element=pr.route_action and ddd.tablename='parcel_route' and ddd.remark='valid'
       left join ph_staging.parcel_info pi
       on pi.pno=pr.pno and pr.store_id<>pi.dst_store_id
       where pr.routed_at>=convert_tz(date_sub( CURRENT_DATE,interval 30 day),'+08:00','+00:00')
       and pr.routed_at<convert_tz(date_add( CURRENT_DATE,interval 1 day),'+08:00','+00:00')
       and pr.store_category in (1,10)
       group by 1
    ) pr_vo
    on pr_vo.pno=pi.pno and pr_vo.route_time>pr.route_time
    where pr.pno is not null
    and pr_v.pno is null
    and pr_vo.pno is not null
) pr_hvo on pr_hvo.pno=sd.pno
left join
(
-- 错分
-- 疑难件结果是继续派送，当前网点未发件出仓，无新增其他网点有效路由
    select
       di.pno

    from ph_staging.diff_info di
    left join ph_staging.parcel_info pi on di.pno = pi.pno
    left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
    join ph_staging.parcel_change_detail pcd on pcd.pno = di.pno and pcd.field_name = 'dst_store_id' and pcd.created_at > di.created_at
    left join ph_staging.parcel_route pr on pr.pno = di.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    left join ph_staging.parcel_route pr2 on pr2.pno = di.pno and pr2.routed_at > cdt.updated_at and pr2.store_id != di.store_id and pr2.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
    where
       di.diff_marker_category = 31
       and cdt.negotiation_result_category in (5,6)
       and pr.pno is null
       and pi.state not in (5,7,8,9)
       and di.created_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour )
       and pr2.pno is null
    group by 1
) diff on diff.pno=sd.pno
left join
(
    -- 客户改约时间
    select
    *
    from
    (
       select
          pr.pno
          ,convert_tz(pr.routed_at,'+00:00','+07:00') reschedule_marker_time
          ,date(date_sub(FROM_UNIXTIME(json_extract(pr.extra_value,'$.desiredAt')),interval 1 hour)) desire_date
          ,row_number() over(partition by pr.pno order by pr.routed_at desc) rk
       from ph_staging.parcel_route pr
       where 1=1
       and pr.routed_at >= date_sub(DATE(DATE_SUB(NOW(), INTERVAL 1 HOUR)),16)
       and pr.routed_at <  date_sub(DATE(DATE_SUB(NOW(), INTERVAL 1 HOUR)),interval 8 hour) #限定当日之前的改约
       and pr.route_action = 'DETAIN_WAREHOUSE'
       -- and date(date_sub(FROM_UNIXTIME(json_extract(pr.extra_value,'$.desiredAt')),interval 1 hour))>current_date
       and pr.marker_category in (9,14,70) ##客户改约时间
   ) as b where rk=2 and desire_date>current_date
) pr2 on sd.pno=pr2.pno

left join
(-- 丢失
   select
       lt.pno
       , max(lt.updated_at) as updated_at
   from ph_bi.parcel_lose_task lt
   where lt.state = 6
    and lt.duty_result = 1
    and lt.updated_at>date_sub(CURRENT_DATE ,interval 31 day)
    and lt.updated_at < current_date()
   group by 1
) lt
on sd.pno=lt.pno