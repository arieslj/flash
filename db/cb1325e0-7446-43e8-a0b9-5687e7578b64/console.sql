/* =====================================================================+
        表名称:dwd_my_shd_del_pno_d
        功能描述：马来西亚包裹信息表

        需求来源：
        编写人员: liyue
        设计日期：2022-07-11
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +===================================================================== 	 */


-- drop table dwm.dwd_my_shd_del_pno_d;
/*
Create Table dwm.dwd_my_shd_del_pno_d (
 stat_date                      date         COMMENT    '统计日期',
 pno                            varchar      COMMENT    '运单号',
 client_id                      varchar      COMMENT    '客户ID',
 cod_enabled                    varchar      COMMENT    'COD标识',
 size_lvl                       varchar      COMMENT    '大小件标识',
 created_at                     varchar      COMMENT    '揽收时间',
 dst_store_id                   varchar      COMMENT    '目地网点',
 should_delivery_flg            varchar      COMMENT    '应派标识',
 handover_flg                   varchar      COMMENT    '当天交接标识',
 finished_flg                   varchar      COMMENT    '当天妥投标识',
 finished_at                    varchar      COMMENT    '妥投时间',
 state                          varchar      COMMENT    '状态',
 returned                       varchar      COMMENT    '退件标识' ,
 dst_store_type                 varchar      COMMENT    '目的地网点类型',
 mark_reason                    varchar      COMMENT    '昨日标记原因',
 td_mark_reason                 varchar      COMMENT    '今日标记原因',
 staff_info_id                  varchar      COMMENT    '交接员工号',
 noto_flg                       varchar      COMMENT    '有发无到标识',
 err_address_flg                varchar      COMMENT    '地址错分标识',
 arrive_duration                varchar      COMMENT    '在仓时长',
 arrive_time                    date         COMMENT    '到达目的网点时间',
 hurry_flg                      varchar      COMMENT    '催单标识',
 inventory_flg                  varchar      COMMENT    '今日盘库标识',
 desired_date                   date         COMMENT    '改约日期',
 shipment_time                  date         COMMENT    '揽收网点发件出仓时间',
 shipment_duration              varchar      COMMENT    '揽收网点发件出仓时长',
 in_warehouse_flg               varchar      COMMENT    '在仓标识',
 in_transit_flg                 varchar      COMMENT    '在途标识',
 should_Delivery_date           date         COMMENT    '正向应妥投时间',
 should_overall_date            date         COMMENT    'overall时间',
 client_belong                  varchar      COMMENT    '客户归属',
 attempts                       bigint       COMMENT    '失败次数',
 ticket_pickup_store_id         varchar      COMMENT    '揽收网点',
 near_flg                       varchar      COMMENT    '临近时效标识',
 delivery_store_id              varchar      COMMENT    '最近一次交接网点',
 ticket_delivery_staff_info_id  varchar      COMMENT    '派送员工号',
 ticket_pickup_staff_info_id    varchar      COMMENT    '揽收员工号',
 pri_flg                        varchar      COMMENT    'PRI标记',
 duty_store_id                  varchar      COMMENT    '最近一次责任网点',
 load_time datetime DEFAULT CURRENT_TIMESTAMP COMMENT   '数据加载时间',
 primary key (stat_date,pno)
) DISTRIBUTE BY HASH(stat_date,pno) INDEX_ALL='Y' STORAGE_POLICY='HOT';
*/

-- alter table dwm.dwd_my_shd_del_pno_d add staff_info_id varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add noto_flg varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add td_mark_reason varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add err_address_flg varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add arrive_time date;
-- alter table dwm.dwd_my_shd_del_pno_d add arrive_duration varchar ;
-- alter table dwm.dwd_my_shd_del_pno_d add  hurry_flg varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add inventory_flg varchar;

-- alter table dwm.dwd_my_shd_del_pno_d add desired_date date;
-- alter table dwm.dwd_my_shd_del_pno_d add shipment_time date  ;
-- alter table dwm.dwd_my_shd_del_pno_d add shipment_duration varchar  ;
-- alter table dwm.dwd_my_shd_del_pno_d add in_warehouse_flg varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add in_transit_flg varchar;

-- alter table dwm.dwd_my_shd_del_pno_d add client_belong varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add attempts bigint;
-- alter table dwm.dwd_my_shd_del_pno_d add should_Delivery_date date;
-- alter table dwm.dwd_my_shd_del_pno_d add should_overall_date date;

-- alter table dwm.dwd_my_shd_del_pno_d add ticket_pickup_store_id varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add near_flg varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add pri_flg varchar;

-- alter table dwm.dwd_my_shd_del_pno_d add delivery_store_id varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add ticket_delivery_staff_info_id varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add ticket_pickup_staff_info_id varchar;
-- alter table dwm.dwd_my_shd_del_pno_d add duty_store_id varchar;

delete from dwm.dwd_my_shd_del_pno_d where stat_date=CURRENT_DATE;
insert into dwm.dwd_my_shd_del_pno_d
( stat_date
 ,pno
 ,client_id
 ,cod_enabled
 ,size_lvl
 ,created_at
 ,dst_store_id
 ,should_delivery_flg
 ,handover_flg
 ,finished_flg
 ,finished_at
 ,state
 ,returned
 ,dst_store_type
 ,mark_reason
 ,td_mark_reason
 ,staff_info_id
 ,noto_flg
 ,err_address_flg
 ,arrive_time
 ,arrive_duration
 ,hurry_flg
 ,inventory_flg
 ,desired_date
 ,shipment_time
 ,shipment_duration
 ,in_warehouse_flg
 ,in_transit_flg
 ,should_Delivery_date
 ,should_overall_date
 ,client_belong
 ,attempts
 ,ticket_pickup_store_id
 ,near_flg
 ,pri_flg
 ,delivery_store_id
 ,ticket_delivery_staff_info_id
 ,ticket_pickup_staff_info_id
 ,duty_store_id
 ,load_time )
select CURRENT_DATE stat_date
      ,pi.pno
      ,pi.client_id
      ,pi.cod_enabled
      ,if((pi.exhibition_weight> 5000 or(pi.exhibition_length+ pi.exhibition_width+ pi.exhibition_height)> 80), 'Over_Size', 'Normal') size_lvl
      ,convert_tz(pi.created_At,'+00:00','+08:00') created_At
      ,pi.dst_store_id
      ,if(dc.pno is not null , 1 , 0  ) should_delivery_flg
      ,if(gr.pno is not null , 1 , 0  ) handover_flg
      ,if(pi.state=5 and date(convert_tz(pi.`finished_at`,'+00:00','+08:00'))= CURRENT_DATE , 1 , 0  ) finished_flg
      ,convert_tz(pi.finished_at,'+00:00','+08:00') finished_at
      ,pi.state
      ,pi.returned
      ,case when mpm.belong_type='fh' and pr1.pno is not null then 'fhy'  -- 发出FH
       when mpm.belong_type='fh' and pr1.pno is null then 'fhn'  -- 未发出FH
       when mpm.belong_type='py' then 'py'  -- 偏远
       else 'zc' end  dst_store_type   -- 本网点
      ,case when Holding_time is not null then 'hd' -- 上日holding
       when tdm.desired_date>CURRENT_DATE() AND tdm.mark_date<CURRENT_DATE() then 'gy' -- 上日改约
       when cf.routed_at<CURRENT_DATE() and cf.pno is not null then 'cf' -- 上日错分
       when diff.pno is not null then 'yn'  -- 上日疑难件
       else 'zc' end mark_reason  -- 上日正常件
      ,case when tdm.mark_date=CURRENT_DATE() and marker_id in ('14','70') then 'gy'  -- 今日改约
       when cf.routed_at=CURRENT_DATE() and cf.pno is not null then 'cf'  -- 今日错分
       when tdm.mark_date=CURRENT_DATE() and marker_id in ('2','17') then 'js'  -- 今日拒收
       when tdm.mark_date=CURRENT_DATE() and marker_id in ('1','40') then 'bzj'  -- 今日不在家
       when tdm.mark_date=CURRENT_DATE() and marker_id in ('15','71') then 'ylbz' -- 今日运力不足
       when diff1.pno is not null then 'yn' -- 今日疑难件
       else 'zc' end td_mark_reason  -- 今日正常件
      ,gr.staff_info_id
      ,case when noto.pno is not null then 1 else 0 end noto_flg
      ,case when cf.pno is not null then 1 else 0 end err_address_flg
      ,pr2.arrive_time
      ,datediff(CURRENT_DATE ,pr2.arrive_time) + 1 arrive_duration
      ,case when cda.pno is not null then 1 else 0 end hurry_flg
      ,case when inv.pno is not null then 1 else 0 end inventory_flg
      ,tdm.desired_date
      ,pr3.shipment_time
      ,if(pi.state in (1,2,3,4,6),datediff(current_date,date(convert_tz(pi.created_At,'+00:00','+08:00'))) + 1,null) shipment_duration
      ,if(pr2.pno is not null and pi.state IN(1,2,3,4,6) and pi.`duty_store_id`  = pi.`dst_store_id`,1,0) in_wardhouse_flg
      ,if((pr2.pno is null or pi.`duty_store_id`<> pi.`dst_store_id`) and pi.state IN(1,2,3,4,6),1,0) in_transit_flg
      ,nvl(lp.sla_end_date,null) should_Delivery_date
      ,nvl(lp.whole_end_date,null) should_overall_date
      ,eb.client_name client_belong
      ,nvl(lrr.delivery_failed_num,0) attempts
      ,pi.ticket_pickup_store_id
      ,case when pn.pno is not null then 1 else 0 end near_flg
      ,case when pri.pno is not null then 1 else 0 end pri_flg
      ,gr.store_id  delivery_store_id
      ,pi.ticket_delivery_staff_info_id
      ,pi.ticket_pickup_staff_info_id
      ,pi.duty_store_id
      ,now()
from my_staging.parcel_info pi
left join my_bi.`dc_should_delivery_today` dc
on pi.pno = dc.pno and dc.`stat_date` = CURRENT_DATE
left join  tmpale.dwd_my_postal_mapping mpm
on pi.dst_postal_code = mpm.postal_code

left join dwm.tmp_ex_big_clients_id_detail eb
on pi.client_id  = eb.client_id
left join ( ## 交接判断
          select dt.pno
                ,staff_info_id
                ,dt.store_id
                ,row_number()over(partition by dt.pno order by delivery_at desc) rn
          from `my_staging`.`ticket_delivery` dt

          where date(convert_tz(dt.`delivery_at`,'+00:00','+08:00'))= CURRENT_DATE
          and dt.`transfered` = 0
          and dt.`state` in (0,1,2)
          )gr
on pi.pno = gr.pno
and gr.rn=1
left join ( ## 发出FH判断
     SELECT PR.PNO
     FROM my_staging.parcel_route pr

     WHERE pr.route_action ='SHIPMENT_WAREHOUSE_SCAN'
     AND pr.state <>7
     and pr.routed_at >= date_sub(now(),interval 3 month)
     and pr.next_store_category in (4,5,6,7)
     group by 1)pr1
on pi.pno = pr1.pno
LEFT JOIN ( ## holding判断
    SELECT  pno
           ,max(convert_tz(routed_at,'+00:00','+08:00')) Holding_time
    FROM my_staging.parcel_route pr

    WHERE route_action='REFUND_CONFIRM'
    AND routed_at>= date_sub(now(),interval 3 month)

    AND routed_at < convert_tz(CURRENT_DATE(),'+08:00','+00:00')
    GROUP BY pno
    ) hold
ON pi.pno=hold.pno
LEFT JOIN ( ## 留仓标记、快递员标记原因（改约、拒收、不在家、运力不足）
       SELECT pr.pno,
          pr.marker_category as marker_id,
          date(convert_tz(pr.routed_at,'+00:00','+08:00')) mark_date,
          if(json_extract(pr.extra_value, '$.desiredAt') > 0
          ,date(convert_tz(from_unixtime(json_extract(pr.extra_value, '$.desiredAt') ),'+00:00','+08:00')),null) desired_date,
          row_number() over (partition by pr.pno order by pr.routed_at desc) rk
       FROM my_staging.parcel_route pr

       WHERE pr.`route_action` in ( 'DETAIN_WAREHOUSE','DELIVERY_MARKER')
       AND routed_at>= date_sub(now(),interval 3 month)
       AND pr.deleted = 0

       AND pr.marker_Category in ('14','70','2','17','1','40','15','71')
    ) tdm
ON pi.pno=tdm.pno
and tdm.rk=1
left join ( ## 上一日疑难件判断
        SELECT pno
        FROM dwm.dwd_my_shd_del_pno_d
        WHERE state =6
        and stat_date = date_sub(CURRENT_DATE,interval 1 day)
        GROUP BY pno
        ) diff
on pi.pno = diff.pno
left join ( ## 当前疑难件判断
        SELECT pno
        FROM my_staging.parcel_info
        WHERE state =6
		and created_at>= date_sub(now(),interval 3 month)
        GROUP BY pno
        ) diff1
on pi.pno = diff1.pno
LEFT JOIN ( ## 有发无到判断
    select pno from my_staging.parcel_route pr
    WHERE route_action='HAVE_HAIR_SCAN_NO_TO' -- 有发无到
    group by pno
    ) noto
ON pi.pno=noto.pno
LEFT JOIN ( ## 错分判断
   select
     pno
     ,store_id
     ,max(routed_at) routed_at -- 错分换单时间
    from my_staging.parcel_route
     where route_action in ('DELIVERY_MARKER','DIFFICULTY_HANDOVER','REPLACE_PNO')
     and marker_Category in ('31','3','18','30','79')
     and  routed_at>= date_sub(now(),interval 3 month)
     group by 1,2
    ) cf
ON pi.pno=cf.pno
and pi.dst_store_id = cf.store_id
left join ( ## 留仓日期计算
           select pr.`pno`
                 ,pr.`store_id`
                 ,min(date(convert_tz(pr.`routed_at`, '+00:00','+08:00'))) arrive_time
           FROM tmpale.tmp_valid_route pr



           group by 1,2) pr2
on  pi.`pno` = pr2.`pno`
AND pr2.`store_id` = pi.`dst_store_id`
LEFT JOIN ( ## 催单判断
    SELECT  pr.pno
    FROM my_staging.parcel_route pr

    WHERE route_action='HURRY_PARCEL'  -- 催单
    AND routed_at>= date_sub(now(),interval 4 month)
    AND routed_at < convert_tz(CURRENT_DATE(),'+08:00','+00:00')

    GROUP BY  pr.pno
    ) cda
ON pi.pno=cda.pno
LEFT JOIN ( ## 今日盘库判断
    SELECT  pr.pno
    FROM my_staging.parcel_route  pr

    WHERE route_action='INVENTORY'  -- 盘库
    AND date(convert_tz(routed_at,'+00:00','+08:00'))>=CURRENT_DATE()

    GROUP BY pr.pno
    ) inv
ON pi.pno=inv.pno
left join ( ## 揽收网点发件出仓日期计算
     SELECT pr.pno,pr.store_id,min(date(convert_tz(pr.`routed_at`, '+00:00','+08:00'))) shipment_time
     FROM my_staging.parcel_route pr

     WHERE pr.route_action ='SHIPMENT_WAREHOUSE_SCAN'   -- 发件出仓

      AND routed_at>= date_sub(now(),interval 4 month)
     group by 1,2)pr3
on pi.pno = pr3.pno
and pi.ticket_pickup_store_id = pr3.store_id
left join dwm.dwd_ex_my_lazada_pno_period  lp    ## delivery时效
on pi.pno = lp.pno

left join my_staging.lazada_route_record  lrr  ## 尝试派送失败的次数
on pi.pno = lrr.pno
left join my_staging.parcel_near_prescription_delivery_detail pn  ## 临近时效标识
on pi.pno = pn.pno
and pn.deleted =0
left join ( ## pri标识规则
      select pno
      from  my_staging.`parcel_priority_delivery_detail` dd
      where dd.`deleted` =0
      and dd.`screening_date` = CURRENT_DATE  )pri
on pi.pno = pri.pno
where pi.state in (1,2,3,4,6) or (pi.state in (5,8) and date(convert_tz(pi.`finished_at`,'+00:00','+08:00'))= CURRENT_DATE ) or (pi.state =7 and date(convert_tz(pi.`state_change_at`,'+00:00','+08:00'))= CURRENT_DATE)