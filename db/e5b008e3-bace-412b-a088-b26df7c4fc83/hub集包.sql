/*=====================================================================+
        表名称：  1320d_ph_operation_monitoring
        功能描述： PH 操作监控数据

        需求来源：PH
        编写人员: 马勇
        设计日期：2023/03/06
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================*/
SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,v2.出勤收派员人数
    ,v2.出勤仓管人数
    ,v2.出勤主管人数
    ,pr.妥投量
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
    ,dc.应派量
    ,pr3.交接量
    ,concat(round(pr3.交接量/dc.应派量,4)*100,'%') 交接率
    ,pr4.应盘点量
    ,pr5.实际盘点量
    ,pr4.应盘点量- pr5.实际盘点量 未盘点量
    ,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
    ,seal.应该集包包裹量
    ,seal.应集包且实际集包的总包裹量 实际集包量
    ,seal.集包率 集包率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
left join
    (
        select #出勤
            hi.`sys_store_id`
            ,count(distinct(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
            ,count(distinct(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
            ,count(distinct(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
        from `ph_bi`.`attendance_data_v2` v2
        left join `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
        join ph_staging.sys_store ss on ss.id = hi.sys_store_id and ss.category in (8,12)
        where
            v2.`stat_date`=date_sub(curdate(),interval 1 day)
            and
                (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
        group by 1
    )v2 on v2.`sys_store_id`=ss.`id`
left join
    (
        select #妥投
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 妥投量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('DELIVERY_CONFIRM')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr on pr.`store_id`=ss.`id`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            )pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') >= date_sub(curdate(),interval 1 day)
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`
left join
    (
        select #应派
            dc.`store_id`
            ,count(distinct(dc.`pno`)) 应派量
        from `ph_bi`.`dc_should_delivery_today` dc
        join ph_staging.sys_store ss on ss.id = dc.store_id and ss.category in (8,12)
        where
            dc.`stat_date`= date_sub(curdate(),interval 1 day)
        group by 1
    ) dc on dc.`store_id`=ss.`id`
left join
    (
        select #交接
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 交接量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr3 on pr3.`store_id`=ss.`id`
left join
    (
        select #应盘
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应盘点量
        from
            (
                select #最后一条有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`state`
                    ,pr.`routed_at`
                from
                    (
                        select
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`state`
                             ,pr.`routed_at`
                             ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                        from `ph_staging`.`parcel_route` pr
                        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                        where
                            DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
            left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
            left join
                (
                    select #车货关联出港
                        pr.`pno`
                        ,pr.`store_id`
                        ,pr.`routed_at`
                    from `ph_staging`.`parcel_route` pr
                    join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                    where
                        pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
            and pi.state in (1,2,3,4,6)
        group by 1
    )pr4 on pr4.`store_id`=ss.`id`
left join
    (
        select #实际盘点
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际盘点量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        GROUP BY 1
    )pr5 on pr5.`store_id`=ss.`id`
left join
    (
        SELECT
            a.store_id
            ,date(a.van_arrive_phtime) AS '到港日期'
            ,SUM(a.hub_should_seal) AS '应该集包包裹量'
            ,SUM(IF (a.hub_should_seal = 1 AND a.seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
            ,SUM(IF (a.hub_should_seal = 1  AND a.seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
        FROM
            (
                SELECT
                    pi.pno
                    , pss.store_name AS 'hub_name'
                    ,pss.store_id
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                            8 HOUR) AS 'van_arrive_phtime'
                    , pss.arrival_pack_no
                    , pack.es_unseal_store_name
                    ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
            -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                         AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
                    , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
                FROM ph_staging.parcel_info pi
                JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
                    AND pi.pno = pss.pno
                    AND pss.store_category IN (8, 12)
                    AND pss.store_name != '66 BAG_HUB_Maynila'
                    AND pss.store_name NOT REGEXP '^Air|^SEA'
                LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
                WHERE
                    1 = 1
                    AND pi.state < 9
                    AND pi.returned = 0
            ) a
        GROUP BY 1, 2
        ORDER BY 1, 2
    ) seal on seal.store_id = ss.id
group by 1,2,3,4
order by 2;




SELECT
	date_sub(curdate(),interval 1 day) 日期
	,ss.`name` 网点名称
	,smr.`name` 大区
	,smp.`name` 片区
	,v2.出勤收派员人数
	,v2.出勤仓管人数
	,v2.出勤主管人数
	,pr.妥投量
	,pr1.应到量
	,pr2.实到量
	,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
	,dc.应派量
	,dc.应派交接量
	,pr3.实际交接量
	,concat(round(dc.应派交接量/dc.应派量,4)*100,'%') 应派交接率
	,pr4.应盘点量
	,pr5.实际盘点量
	,pr4.应盘点量- pr5.实际盘点量 未盘点量
	,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
	,pr6.应集包量
	,pr7.实际集包量
	,concat(round(pr7.实际集包量/pr6.应集包量,4)*100,'%') 集包率
FROM ( SELECT * FROM `ph_staging`.`sys_store` ss where ss.category  in (1,6,14)) ss
LEFT JOIN `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
LEFT JOIN `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
LEFT JOIN ( SELECT #出勤

           			 hi.`sys_store_id`
           			 ,COUNT(DISTINCT(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
                    ,COUNT(DISTINCT(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
                    ,COUNT(DISTINCT(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
             FROM `ph_bi`.`attendance_data_v2` v2
           	 LEFT JOIN `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
           	 where v2.`stat_date`=date_sub(curdate(),interval 1 day)
             and (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
           GROUP BY 1
           )v2 on v2.`sys_store_id`=ss.`id`
LEFT JOIN ( SELECT #妥投

           			 pr.`store_id`
           			 ,COUNT(DISTINCT(pr.`pno`)) 妥投量
             FROM `ph_staging`.`parcel_route` pr

           	 where pr.`route_action` in ('DELIVERY_CONFIRM')
             and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
             GROUP BY 1
           )pr on pr.`store_id`=ss.`id`
LEFT JOIN ( SELECT #应到

           			 pr.`store_id`
           			 ,COUNT(DISTINCT(pr.`pno`)) 应到量
             FROM `ph_staging`.`parcel_route` pr
           	 join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
           	 where pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
             and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
              and pr.`store_id` =pi.`dst_store_id`
             GROUP BY 1
           )pr1 on pr1.`store_id`=ss.`id`
LEFT JOIN ( SELECT #实到
                     pr.`store_id`
           			,COUNT(DISTINCT(pr.`pno`)) 实到量
             from ( SELECT #车货关联到港
                     pr.`pno`
           			 ,pr.`store_id`
           			 ,pr.`routed_at`
             FROM `ph_staging`.`parcel_route` pr

           	 where pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
             and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
                    )pr
             JOIN (select #有效路由
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`routed_at`
                             ,pr.route_action
                             ,pr.store_name
                             ,pr.staff_info_id
                             ,pr.staff_info_phone
                             ,pr.staff_info_name
                             ,pr.extra_value
                     from `ph_staging`.`parcel_route` pr
                     where pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                      and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')>=date_sub(curdate(),interval 1 day)
                  ) pr1 on pr1.pno=pr.`pno`
              where pr1.store_id=pr.store_id
              and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
           GROUP BY 1
             )pr2 on  pr2.`store_id`=ss.`id`
LEFT JOIN ( SELECT #应派

           			 dc.`store_id`
           			 ,COUNT(DISTINCT(dc.`pno`)) 应派量
           			 ,COUNT(DISTINCT(pr.`pno`)) 应派交接量
             FROM `ph_bi`.`dc_should_delivery_today` dc
             LEFT JOIN ( SELECT #交接
			           			 pr.`store_id`
			           			,pr.`pno`
             FROM `ph_staging`.`parcel_route` pr

           	 where pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
             and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
           )pr on pr.pno=dc.pno
           	 where dc.`stat_date`= date_sub(curdate(),interval 1 day)
            GROUP BY 1
           ) dc on dc.`store_id`=ss.`id`
LEFT JOIN ( SELECT #交接

           			 pr.`store_id`
           			,COUNT(DISTINCT(pr.`pno`)) 实际交接量
             FROM `ph_staging`.`parcel_route` pr

           	 where pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
             and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
              GROUP BY 1
           )pr3 on pr3.`store_id`=ss.`id`
LEFT JOIN ( SELECT #应盘

           			 pr.`store_id`
           			  ,COUNT(DISTINCT(pr.`pno`)) 应盘点量
              from  (
                         select #最后一条有效路由
                               pr.`pno`
                               ,pr.store_id
                               ,pr.`state`
                               ,pr.`routed_at`
                           from (select
                                         pr.`pno`
                                         ,pr.store_id
                                         ,pr.`state`
                                 		 ,pr.`routed_at`
                                         ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                                    from `ph_staging`.`parcel_route` pr

                                     where  DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')<=date_sub(curdate(),interval 1 day)
                                     and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')>=date_sub(curdate(),interval 200 day)
                                       and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                                 ) pr
                         where pr.rn = 1
                        ) pr
           		 LEFT JOIN `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
           		 LEFT JOIN ( SELECT #车货关联出港
                                         pr.`pno`
                                         ,pr.`store_id`
										 ,pr.`routed_at`
                                 FROM `ph_staging`.`parcel_route` pr

                                 where pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                                 and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')<=date_sub(curdate(),interval 1 day)
             					 and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')>=date_sub(curdate(),interval 200 day)
                       )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`

				where pr1.pno is null
           		 and pi.state in (1,2,3,4,6)
                GROUP BY 1
              )pr4 on pr4.`store_id`=ss.`id`
LEFT JOIN ( SELECT #实际盘点

           			 pr.`store_id`
           			,COUNT(DISTINCT(pr.`pno`)) 实际盘点量
             FROM `ph_staging`.`parcel_route` pr
           	 LEFT JOIN `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
           	 where pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
             and CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00')>=concat(date_sub(curdate(),interval 1 day),' 16:00:00')
             and CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00')<=concat(date_sub(curdate(),interval 1 day),' 23:59:59')
             and pi.state in (1,2,3,4,6)
             GROUP BY 1
           )pr5 on pr5.`store_id`=ss.`id`
LEFT JOIN ( SELECT #应集包

           			 pr.`store_id`
           			,COUNT(DISTINCT(pr.`pno`)) 应集包量
             FROM `ph_staging`.`parcel_route` pr
           	  LEFT JOIN `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
           	 where pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
             and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
             and pi.`exhibition_weight`<=3000
             and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
           	 and pi.`exhibition_length` <=30
             and pi.`exhibition_width` <=30
             and pi.`exhibition_height` <=30
           GROUP BY 1
           )pr6 on pr6.`store_id`=ss.`id`
LEFT JOIN ( SELECT #实际集包

           			 pr.`store_id`
                     ,COUNT(DISTINCT(pr.`pno`)) 实际集包量
             FROM `ph_staging`.`parcel_route` pr
           	 where pr.`route_action` in ( 'SEAL')
             and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
             GROUP BY 1
           )pr7 on pr7.`store_id`=ss.`id`

group by 1,2,3,4
ORDER BY 2;

















-- 0394
        SELECT
            a.store_id
            ,date(a.van_arrive_phtime) AS '到港日期'
            ,SUM(a.hub_should_seal) AS '应该集包包裹量'
            ,SUM(IF (a.hub_should_seal = 1 AND a.seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
            ,SUM(IF (a.hub_should_seal = 1  AND a.seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
        FROM
            (
                SELECT
                    pi.pno
                    , pss.store_name AS 'hub_name'
                    ,pss.store_id
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                            8 HOUR) AS 'van_arrive_phtime'
                    , pss.arrival_pack_no
                    , pack.es_unseal_store_name
                    ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
            -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                         AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
                    , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
                FROM ph_staging.parcel_info pi
                JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
                    AND pi.pno = pss.pno
                    AND pss.store_category IN (8, 12)
                    AND pss.store_name != '66 BAG_HUB_Maynila'
                    AND pss.store_name NOT REGEXP '^Air|^SEA'
                LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
                WHERE
                    1 = 1
                    AND pi.state < 9
                    AND pi.returned = 0
            ) a
        GROUP BY 1, 2
        ORDER BY 1, 2

;

select
        fp.p_date 日期
        ,ss.name 网点
        ,ss.id 网点ID
        ,fp.view_num 访问人次
    #     ,fp.view_staff_num uv
        ,fp.match_num 点击匹配量
        ,fp.search_num 点击搜索量
        ,fp.sucess_num 成功匹配量
    from
        (
            select
                json_extract(ext_info,'$.organization_id') store_id
                ,fp.p_date
                ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
                ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
                ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
                ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
                ,count(if(json_unquote(json_extract(ext_info,'$.matchResult')) = 'true', fp.user_id, null)) sucess_num
            from dwm.dwd_ph_sls_pro_flash_point fp
            where
                fp.p_date >= '2023-03-01'
            group by 1,2
        ) fp
    left join ph_staging.sys_store ss on ss.id = fp.store_id
    where
        ss.category in (8,12)