select
    pr.pno
    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) 'Delivery date'
    ,pr.staff_info_id Courier
from ph_staging.parcel_route pr
where
    pr.route_action = 'DELIVERY_CONFIRM'
    and pr.pno in ('P610148JJ2WBX','P610148KRECAI','P610148MUGJAI','P610148ZAZSAI','P6101492M86GR','P6101499265AI','P610149C21CBX','P610149E5XGBX','P610149TJJHBX','P610149TY6DGR','P610149UUKSBX','P610149UX16BX','P610149UZWFBX','P610149V4UMAI','P610149Y3EYGR','P610149YGMCBX','P61014A56MSBX','P61014A6BDCBX','P61014A7BBGBX','P610247ZJHFAF','P6102480T4BAF','P6102484AF7AF','P6102485390AF','P6102485CDUAC','P6102485U15AG','P6102485UM7AC','P6102485VRHAE','P6102485YMDAC','P610248627CAG','P61024864HYAC','P610248673RAC','P610248688YAC','P6102486F3HAA','P6102486WREAC','P610248701DAE','P610248707QAC','P61024870QCAC','P61024899MMAC','P6102489A7VAC','P6102489GTDAF','P610248ABG1AG','P610248DJU0AJ','P610248E7Q4AE','P610248KC0SAC','P610248KFCVAG','P610248KFQ1AC','P610248KGDNAE','P610248KPXRAC','P610248KS25AC','P610248M9STAF','P610248MAEFAD','P610248MDXNAJ','P610248MJRQAF','P610248MJYAAF','P610248N3ZBAG','P610248NMH9AC','P610248PRMKAC','P610248PXMSAA','P610248V67WAC','P610248ZFU5AC','P610248ZG41AE','P610248ZYCPAF','P610248ZZXJAD','P61024921XCAD','P61024955RUAC','P61024955VEAC','P6102498RKAAC','P6102498W8JAF','P6102484AWQAA','P610248N6G7AC')


;

select
    pi.pno
    ,pi.returned_pno
from ph_staging.parcel_info pi
where
    pi.pno in ('P83014BBTA8AE','P131847XEWUAC','P81164FAKXNBP','P81164F5V3MAE','P49094FA4SZAA','P40304FSFVXAY','P74084EMEBBAK','P81164CPFNQCL','P81164D1K0YBU','P61014DNM6TDO','P21054C3MVSAB','P07354AW5ZEAF','P81164D1XSPAH','P40074F6D8UAS','P81164CQDEDBU','P35174FC97QAC','P35174BH1PGAC','P81164CF5ZZBG','P61284AK66ZHJ','P81164ETA6PCL','P81244FJD89AF','P61104ER634AI','P81164G4FRUBX','P81164CSZVTAE','P81164CSSEXAX','P60114C1Y28AL','P81184D255AAN','P73024EVEBFBO','P40414FKB4MAO','P61104EF2GPAZ','P11064F4TKAAK','P49044DSQ51AJ','P14014DAT05AZ','P21024B58RCAB','P49044AVVA9AU','P45214BCTENAO','P81154B7A3YAS','P81164D3CQSAU','P81184B3VUAZZ','P81164E1HFGBQ','P47124F5ZYKBH','P35174CSYGCAZ','P81164AR53VBA','P60044D36PYAH','P81164CBK2CBZ','P21054C3USRAG','P81164B2J3XAH','P81164CNTMWAH','P81164DGNJAAH','P81164CQS48CL','P59064ETTCRAJ','P81164B832CCL','P49224D3SADAS','P21054B0UG4AB','P81014G018AAM','P74114D08A4AH','P19044G3RU9AH','P81154FHWKPAA','P81164BRHG8CL','P81164B3UFWBU','P81164CRZRHAX','P33014DSV8GAZ','P33024DFS02AF','P81164CPFJWBA','P36204AC4TZAF','P35264F36DYAB','P49054FAJ9BAP','P81164DBDZUBX','P53024E1156DX','P77184CNFJ8AL')


;









select
    ddd.CN_element
    ,count(pr.id) 动作量
    ,count(distinct pr.pno) 单量
from ph_staging.parcel_route pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.remark and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.routed_at > '2024-05-16 18:00:00'
    and pr.routed_at < '2024-06-17 18:00:00'
    and pr.route_action = 'FORCE_TAKE_PHOTO'
group by ddd.CN_element
;




select
    ri.issues_id
    ,ri.ss_pno
from ph_bi.receivables_issues ri
join tmpale.tmp_ph_issues_lj_0621 t on t.issues_id = ri.issues_id


;






select
    pr.pno
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 扫描时间
from ph_staging.parcel_route pr
where
    pr.store_name = 'SFB_SP'
    and pr.routed_at > '2024-06-15 10:00:00'
    and pr.routed_at < '2024-06-15 15:00:00'
    and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'


;





select
    t.pno
    ,case
        when bc.client_id is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.id is null then '小c'
    end as  客户类型
from tmpale.tmp_ph_pno_lj_0702 t
left join ph_staging.parcel_info pi on t.pno = pi.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id

select *  from tmpale.tmp_ph_pno_lj_0702 t

;


select
    t.client_id
    ,case
        when bc.client_id is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.id is null then '小c'
    end as  客户类型
from tmpale.tmp_ph_client_lj_0702 t
left join ph_staging.ka_profile kp on kp.id = t.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t.client_id



;


SELECT
    date(convert_tz(cdt.updated_at,'+00:00','+08:00')) 'DATE'
    ,pi.out_trade_no 'ORDER ID'
    ,dps.item_name 'Item Description'
    ,pr.pno 'Tracking number'
    ,pi.client_id 'Seller User ID'
    ,bc.client_name 'Seller username'
    ,case pi.article_category
        when 0 then '文件/document'
        when 1 then '干燥食品/dry food'
        when 2 then '日用品/daily necessities'
        when 3 then '数码产品/digital product'
        when 4 then '衣物/clothes'
        when 5 then '书刊/Books'
        when 6 then '汽车配件/auto parts'
        when 7 then '鞋包/shoe bag'
        when 8 then '体育器材/sports equipment'
        when 9 then '化妆品/cosmetics'
        when 10 then '家居用具/Houseware'
        when 11 then '水果/fruit'
        when 99 then '其它/other'
    end 'Goods name'
    ,cdt.remark 'Reason'
    ,if(cdt.negotiation_result_category=3,'YES','NO') 'PACKAGE STILL RETURNABLE, YES OR NO?'
    ,if(cdt.negotiation_result_category in (12),'Valid','Invalid') 'Valid/Invalid for Claims'
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key) order by sa.id separator ',') Proof
    ,pr.store_name 'Concerned hub'
    ,null 'PROOF OF DISPOSA'
    ,convert_tz(cdt.updated_at,'+00:00','+08:00') 'DISPOSAL DATE'
    ,di.ct 'times'
    ,cdt.operator_id 'Operation ID'
    ,count(pr.pno)over(partition by date(convert_tz(cdt.updated_at,'+00:00','+08:00'))) 'Processing quantity'
from
    (
        select pr.*
        from
        (
        select
            pr.pno
            ,pr.store_name
            ,json_extract(pr.extra_value,'$.diffInfoId') diffInfoId
            ,json_extract(pr.extra_value,'$.routeExtraId') routeExtraId
            ,row_number()over(partition by pr.pno order by pr.routed_at) rn
        from ph_staging.parcel_route pr
        where pr.route_action ='DIFFICULTY_HANDOVER'
        and pr.marker_category in (20,21)
        and pr.routed_at>=date_sub(curdate(),interval 10 day)

        )pr where pr.rn=1
    )pr
left join ph_staging.parcel_info pi on pi.pno=pr.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id =pi.client_id
left join dwm.drds_ph_shopee_item_info dps on dps.pno = pr.pno
left JOIN
    (
        select
            di.pno
            ,count() ct
        from ph_staging.diff_info di
        where di.created_at>=date_sub(curdate(),interval 10 day)
        group by 1
    )di on pr.pno=di.pno
left join
    (
        select
            pre.pno
            ,pre.route_extra_id
            ,c
        from
        (
            select
                pre.pno
                ,pre.route_extra_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') value
            from dwm.drds_ph_parcel_route_extra pre
            where pre.created_at>=date_sub(curdate(),interval 10 day)
        )pre
        lateral view explode(split(pre.value, ',')) id as c
    )pre on pr.routeExtraId=pre.route_extra_id
left join ph_staging.sys_attachment sa on sa.id=pre.c
left join ph_staging.customer_diff_ticket cdt on pr.diffInfoId=cdt.diff_info_id
where
    1=1
    -- pr.pno='PD10011QQYB1AJ'
    and cdt.updated_at>=date_sub(date_sub(curdate(),interval 1 day),interval 8 hour)
    and cdt.updated_at<date_sub(curdate(),interval 8 hour)
    -- and cdt.negotiation_result_category in (3,8,12)
    and cdt.organization_type=2 -- (KAM客服组)
    and cdt.vip_enable=0
    and cdt.service_type = 4
group by 1,2,3,4




















/*=====================================================================+
        表名称：  1320d_ph_operation_monitoring
        功能描述： PH 操作监控数据

        需求来源：PH
        编写人员: 马勇
        设计日期：2023/03/06
      	修改日期:2023/11/09
      	修改人员:吕杰
      	修改原因:部分 minihub
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
    ,seal.应该集包包裹量 应该集包包裹量
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
            v2.`stat_date`= '2024-06-29'
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
            and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
			and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')


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
          --  and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
			and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
			and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')

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
					,date_add(pr.`routed_at`,interval 4 hour) routed_at1
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                   -- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
                    and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
					and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')

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
                    and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= pr.routed_at1
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
            dc.`stat_date`= date_sub('2024-06-30',interval 1 day)
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
        --    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
            and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
			and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')
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
						join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
						and pi.created_at>=date_sub(now(),interval 5 month) and pi.state in (1,2,3,4,6)
                        where
                          --  DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)

							pr.`routed_at`<CONVERT_TZ('2024-06-30', '+00:00', '+08:00')
							and pr.`routed_at`>=date_sub(now(),interval 200 day)
							-- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
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
						and pr.`routed_at`<CONVERT_TZ('2024-06-30', '+00:00', '+08:00')
						and pr.`routed_at`>=date_sub(now(),interval 200 day)
                      --  and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                      --  and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 120 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
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
            -- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
			and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')
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
                JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add ('2024-06-30' , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add ('2024-06-30' , INTERVAL -8 HOUR)
                    AND pi.pno = pss.pno
                    AND pss.store_category IN (8, 12)
                    AND pss.store_name != '66 BAG_HUB_Maynila'
                    AND pss.store_name NOT REGEXP '^Air|^SEA'
                LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
                WHERE
                    1 = 1
                    AND pi.state < 9
                    AND pi.returned = 0
					and pi.created_at>=date_sub(now(),interval 4 month)
            ) a
        GROUP BY 1, 2
       -- ORDER BY 1, 2
    ) seal on seal.store_id = ss.id
group by 1,2,3,4
order by 2;

SELECT
	date_sub('2024-06-30',interval 1 day) 日期
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
           	 where v2.`stat_date`=date_sub('2024-06-30',interval 1 day)
             and (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
           GROUP BY 1
           )v2 on v2.`sys_store_id`=ss.`id`
LEFT JOIN ( SELECT #妥投

           			 pr.`store_id`
           			 ,COUNT(DISTINCT(pr.`pno`)) 妥投量
             FROM `ph_staging`.`parcel_route` pr

           	 where pr.`route_action` in ('DELIVERY_CONFIRM')
           --  and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
             and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
			 and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')
			 GROUP BY 1
           )pr on pr.`store_id`=ss.`id`
LEFT JOIN ( SELECT #应到

           			 pr.`store_id`
           			 ,COUNT(DISTINCT(pr.`pno`)) 应到量
             FROM `ph_staging`.`parcel_route` pr
           	 join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno` and pi.created_at>=date_sub(now(),interval 2 month)
           	 where pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            -- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
             and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
			and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')
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
					 ,date_add(pr.`routed_at`,interval 4 hour) routed_at1
             FROM `ph_staging`.`parcel_route` pr

           	 where pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            -- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
            and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
			and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')
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
                     -- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')>=date_sub(curdate(),interval 1 day)
                              and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
                                and pr.routed_at < convert_tz('2024-06-30', '+08:00', '+00:00')


				  ) pr1 on pr1.pno=pr.`pno`
              where pr1.store_id=pr.store_id
              and pr1.`routed_at`<= pr.routed_at1
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
            -- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
            and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
			and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')


		   )pr on pr.pno=dc.pno
           	 where dc.`stat_date`= date_sub('2024-06-30',interval 1 day)
            GROUP BY 1
           ) dc on dc.`store_id`=ss.`id`
LEFT JOIN ( SELECT #交接

           			 pr.`store_id`
           			,COUNT(DISTINCT(pr.`pno`)) 实际交接量
             FROM `ph_staging`.`parcel_route` pr

           	 where pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
           --  and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
              and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
			and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')
			  GROUP BY 1
           )pr3 on pr3.`store_id`=ss.`id`
LEFT JOIN (


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
						join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
						and pi.created_at>=date_sub(now(),interval 5 month) and pi.state in (1,2,3,4,6)
                        where
                          --  DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)

							pr.`routed_at`<CONVERT_TZ('2024-06-30', '+00:00', '+08:00')
							and pr.`routed_at`>=date_sub(now(),interval 200 day)
							-- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
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
						and pr.`routed_at`<CONVERT_TZ('2024-06-30', '+00:00', '+08:00')
						and pr.`routed_at`>=date_sub(now(),interval 200 day)
                      --  and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                      --  and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 120 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
        group by 1



              )pr4 on pr4.`store_id`=ss.`id`
LEFT JOIN ( SELECT #实际盘点

           			 pr.`store_id`
           			,COUNT(DISTINCT(pr.`pno`)) 实际盘点量
             FROM `ph_staging`.`parcel_route` pr
           	 LEFT JOIN `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
           	 where pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
             and pr.`routed_at`>=concat(date_sub('2024-06-30',interval 1 day),' 08:00:00')
             and pr.`routed_at`<=concat(date_sub('2024-06-30',interval 1 day),' 15:59:59')
             and pi.state in (1,2,3,4,6)
             GROUP BY 1
           )pr5 on pr5.`store_id`=ss.`id`
LEFT JOIN
    (
        SELECT #应集包
             pr.`store_id`
            ,COUNT(DISTINCT(pr.`pno`)) 应集包量
        FROM `ph_staging`.`parcel_route` pr
        LEFT JOIN `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
        where pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
        -- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
            and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
            and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')
            and pr.store_name not in ('DMT_SP','BOH_SP','RDJ_SP','CLP_SP','MBT_SP','NBC_SP','MRE_SP','RBL_SP','GEL_SP','PRC_SP','LCN_SP','BUT_SP','SRG_SP','BON_SP','LBC_SP','MAA_SP','CLU_SP','MBA_SP','OEF_SP','PMY_SP','PAS_SP','MOZ_SP','CTN_SP')
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
            -- and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
            and pr.`routed_at`>=convert_tz(date_sub('2024-06-30',interval 1 day), '+08:00', '+00:00')
			and pr.`routed_at`<convert_tz('2024-06-30', '+08:00', '+00:00')
			 GROUP BY 1
           )pr7 on pr7.`store_id`=ss.`id`

group by 1,2,3,4
ORDER BY 2



;




select
    pi.pno PNO
    ,ss.name Destination_Branch
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id  = pi.dst_store_id
where
    pi.pno in ('P81164SKEKTAH','PH2430036712977','FLPHM000005188303','FLPHM000005188157','FLPHM000005188313','P53024TTNZUFD','PH246388103326U','PH246086634086I','PH242918858054I','FLPHM000005188452','PH248885441991Q','PH248610004995P','PH247184666608N','FLPHM000005188551','PH249465863592N','P35174V5XFABE','P35174U1QEUBE','PH249831893652V','PH249102861364Y','PH248240142773N','P64024VCM15DM','P70044V47GPAV','P14014WH28ZAM','LEXST003744080PHGFC','P19054SEEBECA','P15164WM3VRCT','P24334T5WTGAD','P61254WW712AB','PH247822798652U','PH2402256005500','P40314W4J49AT','PH242731115805H','P44084VHCYBAJ','P06164WSFV0AW','P01174VVHR1AR','PH246935601500P','P38064VNP6SAJ','P51054TX6T5AR','P17054WYQB6BD','PH249281182924U','PH241902706688H','PH247660796054P','PH2482279207383','P20174WKQUDAI','PH248165724161O','PH248499812009D','PH243049017735P','P45214VUK0BCF','PH240627465222K','P73024V9QYRAM','P35174VXP42CY','P51054UB3AMCB','P45214V1VYRAN','P32214XTUPPDO','P20074X3V3QAP','P35174WEUPVAZ','PH244235392984Q','PH248533754870V','P03024WZPJXAN','P51054VZSEMBR','PH244346743572K','FLPHM000005189544','LEXST003104703PHGFC','P35514WT7FVAQ','P47144Y9BYFAF','PH248706399457V','PH2459557992311','PH247082692585G','PH249085944795Q','P35174WGWZ3AS','P49044VSUUSAP','P73024V4ZUACM','PH249035910065C','PH242573971150S','PH246673847292H','P73024V4P0FAM','P35174VSX61CQ','P51054UK622AE','P61274WENYQAP','PH248163223235H','PD33244YXDT7AH','P24224ZNR7YAC','P47174YF7EVAW','PH247060071830F','P61174QE700AL','P19044V3DJDAO','PH2430890087667','P06154Y7YKFAG','P70104YC4E1AH','P17144ZE8FTCN','P24244Z3W9CAQ','PH2460022912017','P35074VXNPVAO','PH2415700141506','PH244695280771A','P17144YAVANCN','FLPHM000005188788','FLPHM000005188674','FLPHM000005190330','FLPHM000005189017','P81193EFB30AI','P14144X73NHAB','LEXST183842498PH','P45214XUBVJBM','P61184ZHV1UAX','P32024YU8S6AH','P19044VSPEEAO','PH244491798800T','P19044U41UFAO','PH249334304023G','PH249812523150E','"P18034ZA8RCBF','P3328502GKGAJ','P1919502GKFAN"','P40254XXT5RAY','P3517529JCXBZ','PH249057027621O','PH2472868816482','P51054W7B38CN','PH240642813467H','PH249763888618D','P58064X9PNGAK','P53024XFRZBFX','PH242188404161O','P172050QVS1AF','P53024YK9FNBP','PH241293217813W','PH247200965832E','PH2418369254413','P32215062FBGC','P60084YHUPCAK','P612551K3AMBB','P33164YDXUBAK','PH2483995877659','PH243872296773E','P56054Z5YX3AB','PH2441903563890','PH2478462527835','PH244014541477N','P78054Q5PPEBY','P27154SVD70AF','P08044SSN6HAI','PH2432363221703','PH249598462386C','P650251ZXG6AF','P530251G70DAE','PH2416680956190','P53024Z6JRFAU','PH244524210577N','PH2401243211873','PH240842791662B','P260152268NBF','P33014ZR4V1BG','P241551QJ8ABB','P19044XQ454AO','P19044ZYQXHAO','PH2425124448369','PH2406225256285','PH2496560276502','P510551TQFWCK','P3551509R7QBJ','P141051RU3KAX','P170552KXFQBP','PH244563311311L','P070251QCX6CG','P350651296PAV','PH246774081956Y','PH241646368102Y','PH242073725324Y','PH244995104836F','PH2407128842587','P5302531P1GAT','P612852QKV5HS','PT6127B9BKF3Z','P611853YQJUBO','P352354MBTM','P61184SW8M2ED','P14014TAG53AB','PH248050740087D','P19044XJYARAO','P19044WKCU8AO','P19044UQNGFAO','PH243567695294E','P321553BUDXAW','P2105530HK0AC','PH241592928052M','P022252TT28AT','P071650ZJEPAF','P062950T4P5AP','PH2496880328751','P331452K518AO','P073053CQR2AJ','PH243395977858A','PH247950333127Q','PH240428971085Q','PT3603B8V428Z','FLPHM000005189288','P073254YUF6AR','P52084NYQ2JAI','FLPHM000005190660','FLPHM000005188879','FLPHM000005191104','FLPHM000005191052','FLPHM000005189098','P062955K4YJAN','FLPHM000005190728','P281656M999AN','P83014N11E3AP','P132656B0QRAB','FLPHM000005190887','FLPHM000005189299','P021456E9NFAW','FLPHM000005191085','FLPHM000005191367','LXBPH000172220583','PH244277714730O','PH249105581246R','P612752T0EFAA','PH2433069186815','P042754D8B2BA','P611555NP1QAE','P530250RQFPAJ','P070353NN6CBF','P5302510ZDWGW','P4203549V4RFL','P332052QQ7BAT','PH244467743434Q','P5607526FAZAT','P041052YHCKAO','PH246991912922C','PH244956424722R','P172054TDF8AA','PH2424183684197','P130854F2YBAF','PH241051441092D','P530252WQ1DEU','PH2420352089149','PH246651881026N','PH247530406628M','PH246954724981W','P530254M6PWAA','P202154HJ23AU','PH249096731659G','P071455FU0ZDK','P3530541FHDAC','P612855HZH6DY','PT4521B43362Z','FLPHM000005190741','PH248773248400T','PH240528832033V','PH240307662696E','P640255EUKGCL','P351754M0X9CQ','PH2453095622089','PH241781841526C','P172056PSMNAK')





;


select
    pr.pno
    ,count(pr.id) Handovers
from ph_staging.parcel_route pr
where
    pr.pno in ('P5105511588CA','P590251UQTSAQ','P5409529NRYAS','P510551157MAE','P640253BWS6DI','P3517521JSAAK','P7302521JR0CD','P4710529NQ1AC','P132653BWQRBD','P612153BWT1AJ','P520551UQXKAM','P5302521JT0FJ','P044252SC85AL','P612850VKQ0CJ','P3704521JRDAF','P4120511KV1AD','P331152SC7WAV','P530251ECHTCV','P420352FCJWEJ','P323351WVF0AE','P32215180GEFD','P770150NSQPAE','P242852SC9JAP','P180850VKQ9AS','P370451UQUBAP','P07265180FKAG','P301451WVFHAD','P591251ECH8AR','P53025180G5BT','P612650NSQKAE','P061653BWQ6BF','P210353BWQDAJ','P071453BWSWAP','P150552JRU6AA','P270752FCK9AA','P332350VKQ5AD','P281652SCAQAD','P121750VKQEAM','P5307521JRWAC','P241552SC9GAW','P010552SC9NBI','P090452FCK0BC','P044652ZPXXBE','P452251WVF7AH','P3526529NR8AS','P220152ZPY5AB','P230652SCA2BE','P760151UQUSAB','P181453BWR1AB','P451251ECHXAL','P342551UQV4AM','P412451WVFSAM','P190552FCKJBD','P041753BWSVAQ','P190553BWQPBD','P131752JRTSBG','P132652FCK8BD','P5409511573AE','P391551UQXNAH','P320652FCJHAE','P361051UQY9AY','P52085180FDAC','P612751UQSZAK','P501651ECHVBF','P501051156ZAF','P172052SC87AL','P471251UQWJAH','P471250VKQ7BI','P190253BWQ8AG','P401251UQVFBO','P520751UQV3AK','P512551UQT6AL','P611852FCMAEF','P6127529NRXAK','P520551WVFUAH','P110753BWT8AQ','P192451157KCI','P610650EKNMHC','P452151UQX4DR','P180352FCM5BU','P612353BWSDAD','P073752SC8FAS','P3517521JRRBC','P530251UQW8FY','P230752SC7VAJ','P612852FCJ4FC','P800952SC9RAO','P121953BWS4AY','P070852JRU0AZ','P1221521JTDBM','P073252ZPXWAK','P4521511JE4DA','P100752SC8VAE','P100752FCJZBE','P612152FCJ6AF','P520651UQUFAK','P611952FCK6AJ','P132352SCAXAT','P150551ECJ5AZ','P231052SCAZAF','P190452FCHVAM','P530251UQXFDB','P172852ZPXEAF','P612353BWQWAP','P5105511574CE','P210153BWQCAJ','P611452FCMHBD','P4521511KV0AH','P570951UQT4AW','P571851FDRFAR','P570351ECH0AS','P52065180EUBB','P590251UQWTAD','P161353BWSAAX','P130152FCJ1AX','P010352SCADAQ','P530451ECJ4AQ','P192452SCANBV','P071452ZPYFAC','P530451FDR9AP','P160552SCAYAN','P40115180FPAP','P452351UQUWAH','P210252SCAMAD','P181452FCHPAX','P190552SC90AD','P612752SC9PAM','P3527521JRVAC','P210252JRUMAB','P530250NSQSGJ','P351651WVFQAO','P451451UQVNBG','P140252FCKBAL','P350651UQUJAP','P190652ZPW5AQ','P151652ZPXFCM','P40125180FWBZ','P612052ZPWNAN','P210252SC97AK','P182252FCJSAK','P121052ZPXSBS','P151552FCKZAI','P3221529NR5FH','P151452FCM4AC','P612052JRUXGK','P612552SC9EAP','P612652FCHYAA','P612052SC9UAN','P612252FCMCAO','P612552ZPX5AJ','P140852FCJEAY','P3014521JSJBE','P351151WVFGAU','P401251UQUDBX','P200952SCARAO','P191952ZPXMAP','P181852FCJGAS','P170552FCHSAQ','P612752ZPY7AH','P612752FCJ5AH','P062951UQVRAP','P192552SC8AAN','P140152SC8BAC','P6127529NRFAD','P140152ZPX7AN','P190652FCHNAC','P612752FCJYAF','P3521521JQTAC','P332351UQTKAX','P403251156BBJ','P612052ZPXQBA','P611652SC95AH','P173052SC84AQ','P041852FCM2AX','P190352FCHXAS','P121052FCHQBV','P122052FCKSBS','P211352JRU9AA','P612052ZPXPGT','P140152ZPY6AX','P612352FCM8BD','P210252FCHMAO','P173152ZPWCBE','P611552FCKKBA','P060151FDRDAE','P612352JRU5AB','P612052JRTPGO','P081351202SAE','P570950NSQHBI','P6118521JT2EL','P1208521JR5AK','P612352SC8MAH','P140352FCKEAF','P130351WVFRBV','P612352FCJNAN','P122052SC8PCD','P610152FCM7EY','P120352SC9KAG','P171452ZPX4AI','P221451157UBJ','P170752FCKWBH','P122052JRTUAD','P041952SCB2AC','P611852SC91CR','P390551156DAT','P0434529NQUAD','P291351UQWBAG','P350551UQY1AA','P2406521JRXAQ','P172351UQTTAR','P331051UQU5AS','P1607529NQVAJ','P07025180G2AY','P0735521JTNAF','P610651157PCR','P1719521JRNBM','P180651UQY7AQ','P2018529NRRAE','P6118521JT1FI','P322151UQWKFP','P355151ECGWAP','P1714521JSHBG','P220651UQTNAE','P322151202RAI','P1109521JS4AZ','P140451ECHFAQ','P612750VKQ2AG','P180651WVF4CD','P1806521JT5CH','P0117529NQMAI','P1327521JR1AN','P1317529NQBAJ','P210551UQUHAA','P6118506TCXEK','P1705529NQZBH','P043051UQX6AY','P6118521JSFFI','P611851UQUPCO','P611851UQWCEZ','P20185180G3AT','P01154YDW09AN','P1211521JS2AD','P1413521JSMAI','P1721521JT8AH','P6130521JTKAR','P161451UQWZAN','P042851FDRAAE','P1924529NRVCJ','P1214521JT6AI','P2040521JRSAP','P611351UQW6AA','P1817529NQ7AQ','P1820521JR9AB','P080251WVFCAH','P130351UQWEAQ','P6116529NR4AJ','P611751UQT2AR','P0438521JRGAQ','P130351UQWSAL','P1511529NSAAG','P192451FDQ9CB','P271551UQUVAF','P331151ECH2AF','P080551UQVXAM','P1403521JQZAZ','P640251UQSVEC','P173051UQUAAA','P160351WVF1AE','P6123521JRMAA','P32215180F4DA','P060751158CAF','P780151UQWMBB','P150551WVF8AZ','P1104529NRJAW','P2013521JSCBI','P6118529NS0EP','P2104521JSPAM','P612351158KAK','P6123521JS3BD','P011851157DAF','P1220521JQVAB','P2102521JQYAC','P270851UQW2AR','P61164YDVZYAJ','P61234YMW7PAA','P23035180GCAG','P070151158HAO','P190551WVF6BD','P190551UQSXBD','P181451UQVTAU','P612051UQY6FC','P79054YDW0XAK','P181751UQT0AI','P210251UQY8AI','P180351UQVVBN','P211351WVFDAB','P160751157RAC','P171451UQWDBB','P210651UQX9AH','P61185180GBDC','P612351UQVSBD','P612751FDRCAI','P141651158JAT','P192551156KAH','P192851UQVPAC','P19235180G6AI','P140151UQXZBF','P611851UQSYEQ','P18065180FNBX','P610150NSQTED','P612551UQTEBC','P182051158NAB','P1928511JE2AQ','P042850VKQ6AG','P612051UQXSGE','P18034YDW2EBQ','P61194YDW12AP','P1311511578CC','P270851157FAX','P5910506TCZAM','P173051156TAI','P141451FDQCAK','P612351ECGZAN','P612351UQWVBD','P211351UQTZAD','P12055180GFAH','P191951UQXDAK','P17085180FTAL','P121051WVFKBX','P230751ECHSAC','P16075180GHAN','P333150NSR2AW','P122051UQX2BH','P122351FDQAAD','P612951UQXXAA','P192651ECHAAX','P611851ECH7CH','P07265180GAAH','P192051UQXRAG','P141651UQTCAH','P611851UQT1EO','P612451UQTGAK','P131251UQW9AR','P171951UQVQAP','P0418511583AK','P141051ECJ9AT','P041851156PAG','P81164YDW0YCE','P110151ECHDAB','P180351ECHYBT','P142051FDRGAD','P801250VKQCAN','P612851202WGP','P61305115JNAY','P181151156UAJ','P61275180FEAM','P20354YDW2GAO','P21135180FZAD','P21115180FSAA','P6118511589CY','P131150VKNSAV','P612051ECJ6BB','P17105115JGAJ','P611951156RAO','P192451ECHEBQ','P1806511580CW','P171951ECHZBM','P2101511576AB','P611851158DAV','P140651ECHGAM','P612351ECHMAD','P070150NSQVAP','P121250NSQWAQ','P2105511586AC','P14065180FHAN','P14015180F1BC','P6117511DFHAV','P120851ECHRAN','P61215180FYAD','P21145180FFAB','P182351ECHJAX','P150251157EAG','P012250VKQ8AP','P121051158AAV','P14164XM151BA','P53024YMW83EV','P61264XM15YAF','P3537506TCKAZ','P612550VKPJAA','P141150VKPYAV','P110650EKNKAG','P220650EKNPBU','P190350P740AI','P610450NSR3AN','P191550VKPPAT','P611450NSQUCQ','P170250VKPNAK','P242050NSQ9AM','P171150VKPRAR','P19044XUKDHAM','P47214YMW7JAS','P6118506TCREU','P210850EKNJAI','P220850EKM5BZ','P2814506TCPAP','P221750NSQDAQ','P66064YDW1EAV','P61184XCJM2FI','P35174VAZ7EDB','P74084YDW0QAK','P45174XM155AN','P59024YDW17AP','P46054YDW24BA','P60044YDW0CAG','P70234XM15SAF','P53024XM15WAW','P59024YMW80AG','P53034VAZ9YAY','P53024YDW20EB','P40394YDVZWEN','P51084XM15FBI','P2108506TCGAI','P1502506TCCAJ','P06254YMW81AC','P57154XM150AK','P1220506TCJAS','P17054YMW7KBI','P06174YDW04BB','P52084XM15NAE','P59104XM157AE','P53024XM15TCV','P01124YMW7SAG','P06104YDW27AT','P61204XUKEAGO','P35114XUKEFAI','P21114XUKDFAO','P83014XCJM7BC','P61164XM15JAD','P07264YDW1GAI','P18064YDW14AH','P02184VAZ8FAH','P35174XUKEGCF','P03204YDW01AB','P66054VAZ8JAC','P14074YMW87AQ','P03074XM15EAY','P61204YDW2BGG','P64024YDW03AD','P08134YDW1CAK','P03014YDW26AE','P07354YDW1NAO','P61204YDW0MGL','P04214XCJMAAA','P61304VAZAMAV','P17144YDW1SCD','P18064VAZ8ZAE','P61184XM15MCZ','P61184YDW08EQ','P60014VAZ6KAK','P15164YDW1XBJ','P07124XUKEVAK','P19034YDW0VAE','P64024XM153DB','P18064YDW2KAI','P61204YDW05GL','P59024VAZ6RAG','P07144XCJM5AE','P51054VAZ83BR','P61184XM15VFH','P20184XCJMCAS','P11044XUKDNAZ','P74124VAZBXAF','P49044VAZ9VAD','P17124XUKERBG','P17084XCJKXAL','P46024VAZA4AO','P14084XUKDWAF','P18034XM15AAR','P20144VAZA3AP','P61204XUKDMGT','P12204XUKENBO','P12204XM15XAD','P59054VAZ9GAL','P34224VAZ6PAX','P61244XCJMGAH','P19264XCJM0AZ','P52084VAZ91AU','P61044XCJMBAA','P33014VAZ77CG','P73024VAZ73AP','P34424VAZ96AB','P54024VAZ8RAC','P45124VAZ70AB','P47214VAZ93AO','P57104VAZBWAA','P53024VAZ8CCV','P53024VAZ9CEU','P57044VAZ69BK','P52014VAZAXAD','P32274VAZ9WAH','P53024VAZAWCE','P12124VAZ68AO','P33014VAZ9UBU','P33314VAZBCAM','P38084VAZ8DAW','P53024VAZBYDL','P28074VAZ82AM','P15164VAZ65AI')
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1


;

select
    a.pno
    ,ss.name 最后一次换单前目的地网点
from
    (
        select
            pcd.pno
            ,pcd.old_value
            ,row_number() over (partition by pcd.pno order by pcd.created_at desc) rk
        from ph_staging.parcel_change_detail pcd
        where
            pcd.pno in ('PT1803B6FUD4Z','P612451PNN1AQ','PH240937716920I','PT6124BKEK63Z','PH246352012480L','P613054WKZTAT','PT1925BG16M4Z','PT6116BHERE2Z','PT6127B5DB90Z','PT1808BHJSE6Z','PT1905BJW8W0Z','P6127550972AK','PT6124BKF901Z','PT6117BKB621Z','PT6116BK12J5Z','P612754SMSHAH','PH241484014867Q','PT6117BJQGX4Z','PT3602BKP456Z','PT1805BEP9Q8Z','PT1815BHBFB9Z','PT6127BKWJE9Z','PT6115BMU960Z','PH249885369717P','PT6124BH7WX2Z','PH2416070355223','PT6130BK6CG5Z','PT1808BHX194Z','PT6117BJUQ90Z','PT6117BMJ6B7Z','PT1909BFSAT4Z','PT6117BMT6F7Z','PT6115BHUMK8Z','P180654TGN7AF','PT6115BHE5S7Z','PT6115BH1962Z','PH245761410786T','PT6127BGH953Z','P192654RF6BAT','PT1904BJ5FA3Z','PT1808BH7D67Z','PT1928BJ9ZE2Z','PT6117BHMXW2Z','P180354RD42AL','PT1805BJKPR1Z','PT1815BH71R5Z','PT1905BJQVB0Z','PT6124BHPQ62Z','PT6115BK8PP4Z','PT1817BJHQA7Z','PT6124BF5C29Z','PT1905BHFH51Z','P61164XAEVNAN','PT6125BJQ2K8Z','PT6117BMKFK3Z','PT1905BMQAT8Z','PH242109131718Z','PT6117BG0GN4Z','P611554UT56AE','PT1904BJQ4D8Z','PT1805BH2S13Z','PT6130BKVMZ2Z','PH245091055136C','PT6116BNAPE2Z','PT6117BKPT48Z','PT6117BE41F4Z','PT6115BM14C6Z','PT6126BKFWW0Z','PT6117BKTXK6Z','PT6115BJV6J9Z','PT1815BJ3DH0Z','PT6127BJ2H20Z','PT6124BJJ9W3Z','PT6115BJAV49Z','PT1815BJ3HT7Z','P611654X5PQAN','P611554WBR9AZ','P611554NSFAAA','P190453XSDAAO')
            and pcd.field_name = 'dst_store_id'
    ) a
left join ph_staging.sys_store ss on ss.id = a.old_value
where
    a.rk = 1




;


select
    count(distinct plt.pno)
    ,count(plt.id)
from ph_bi.parcel_lose_task plt
join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
where
    plt.state = 6
    and plt.duty_result = 2
    and plt.updated_at >= '2024-06-01'
    and plt.updated_at < '2024-07-01'
    and bc.client_name = 'shopee'


;


select
#     ds.store_id
#     ,ds.pno
#     ,pi.state
#     ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) pri_date
    count(1)
from ph_bi.dc_should_delivery_today ds
join ph_staging.parcel_info pi on pi.pno = ds.pno
left join ph_staging.parcel_priority_delivery_detail ppd on ds.pno = ppd.pno
where
    ds.is_pri_package = 2
    and ds.stat_date = '2024-08-27'
;



/*
  =====================================================================+
  表名称：1816d_ph_high_value_monitor
  功能描述：菲律宾高价值包裹监控

  需求来源：
  编写人员: 吕杰
  设计日期：2023-10-30
  修改日期:
  修改人员:
  修改原因:
  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
  +=====================================================================
*/


with t as
    (
        select
            pi.pno
            ,pi.cod_amount/100 cod
            ,pi.created_at
        from ph_staging.parcel_info pi
        where
            pi.created_at > date_sub(curdate(), interval 3 month )
            and pi.state not in (5,7,8,9)
            and pi.cod_amount > 200000
            and pi.returned = 0

        union all

        select
            pi2.pno
            ,pi3.cod_amount/100 cod
            ,pi3.created_at
        from ph_staging.parcel_info pi2
        join ph_staging.parcel_info pi3 on pi3.returned_pno = pi2.pno and pi3.created_at > date_sub(curdate(), interval 100 day)
        where
            pi2.state not in (5,7,8,9)
            and pi2.returned = 1
            and pi3.cod_amount > 200000
            and pi2.created_at > date_sub(curdate(), interval 3 month )
    )
# select
#     convert_tz(t1.created_at, '+00:00', '+08:00') 'Pick up date'
#     ,concat(kp.id, '-', kp.name) Customer
#     ,t1.pno 'Tracking number'
#     ,ss_pick.name 'Pickup branch'
#     ,pi.ticket_pickup_staff_info_id 'Pickup courier'
#     ,ss_dst.name 'Destination branch'
#     ,t1.cod as 'COD_AMOUNT'
#     ,pi.exhibition_weight/1000 'Weight/kg'
#     ,case pi.state
#         when 1 then 'RECEIVED'
#         when 2 then 'IN_TRANSIT'
#         when 3 then 'DELIVERING'
#         when 4 then 'STRANDED'
#         when 5 then 'SIGNED'
#         when 6 then 'IN_DIFFICULTY'
#         when 7 then 'RETURNED'
#         when 8 then 'ABNORMAL_CLOSED'
#         when 9 then 'CANCEL'
#     end 'Status'
#     ,pi.src_name Seller
#    --   ,pi.src_phone 'Seller number'
#     ,pi.dst_name Consignee
#   --    ,pi.dst_phone 'Consignee number'
#     ,sp.name 'Consignee province'
#     ,sc.name 'Consignee city'
#     ,sd.name 'Consignee barangay'
#     ,datediff(curdate(), ps.first_valid_routed_at) days
#     ,las.EN_element 'Last operation'
#     ,convert_tz(las.routed_at, '+00:00', '+08:00') 'Operation time'
#     ,las.store_name 'Operator hub'
#     ,las.staff_info_id 'Operator'
#     ,scan.scan_count Handover
#     ,res.scan_count Reschedule
#     ,if(cal.pno is not null, 'yes', 'no') 'Call record'
# from ph_staging.parcel_info pi
# join t t1 on t1.pno = pi.pno
# left join ph_staging.ka_profile kp on kp.id = pi.client_id
# left join ph_staging.sys_store ss_pick on ss_pick.id = pi.ticket_pickup_store_id
# left join ph_staging.sys_store ss_dst on ss_dst.id = pi.dst_store_id
# left join ph_staging.sys_province sp on sp.code = pi.dst_province_code
# left join ph_staging.sys_city sc on sc.code = pi.dst_city_code
# left join ph_staging.sys_district sd on sd.code = pi.dst_district_code
# left join
#     (-- 包裹最新网点
#         select
#             pssn.*
#             ,row_number() over (partition by pssn.pno order by pssn.valid_store_order desc) rk
#         from dw_dmd.parcel_store_stage_new pssn
#         join t t1 on t1.pno = pssn.pno
#         where
#             pssn.created_at > date_sub(curdate(), interval 3 month )
#     ) ps on ps.pno = t1.pno and ps.rk = 1
# left join
#     (-- 最新有效路由
#         select
#             pr.pno
#             ,pr.routed_at
#             ,pr.store_name
#             ,pr.route_action EN_element
#             ,pr.staff_info_id
#             ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
#         from ph_staging.parcel_route pr
#         join t t1 on t1.pno = pr.pno
#        -- left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
#         where
#             pr.routed_at > date_sub(curdate(), interval 3 month )
#             and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
#     ) las on las.pno = t1.pno and las.rk = 1
# left join
#     (-- 交接扫描次数
#         select
#             pr.pno
#             ,count(pr.id) scan_count
#         from ph_staging.parcel_route pr
#         join t t1 on t1.pno = pr.pno
#         where
#             pr.routed_at > date_sub(curdate(), interval 3 month )
#             and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#         group by 1
#     ) scan on scan.pno = t1.pno
# left join
#     ( -- 改约次数
#         select
#             pr.pno
#             ,count(pr.id) scan_count
#         from ph_staging.parcel_route pr
#         join t t1 on t1.pno = pr.pno
#         where
#             pr.routed_at > date_sub(curdate(), interval 3 month )
#             and pr.route_action = 'DELIVERY_MARKER' -- 派件标记
#             and pr.marker_category  in (9,14,70) -- 改约时间
#         group by 1
#     ) res on res.pno = t1.pno
# left join
#     ( --   电话
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 3 month )
            and pr.route_action in ('PHONE', 'INCOMING_CALL')
            and json_extract(pr.extra_value, '$.callDuration') > '0'
        group by 1
    ) cal on cal.pno = t1.pno
where
    pi.created_at > date_sub(curdate(), interval 3 month )



;






with t as
    (
        select
            pi.pno
            ,pi.dst_name
            ,pi.dst_phone
            ,pi.dst_detail_address
            ,pi.dst_store_id
            ,pi.src_name
            ,pi.client_id
            ,pi.cod_amount/100 cod
            ,pi.src_phone
            ,pi.src_detail_address
            ,dai.delivery_attempt_num
        from ph_staging.delivery_attempt_info dai
        join ph_staging.parcel_info pi on pi.pno = dai.pno
        where
            dai.delivery_attempt_num >= 3
            and pi.created_at > '2024-09-01'
            and pi.state = 7
    )
select
    t1.*
    ,ss.name  目的地网点
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,dp.item_name 产品明细
from t t1
left join ph_staging.sys_store ss on ss.id = t1.dst_store_id
left join ph_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.drds_ph_lazada_order_info_d dp on dp.pno = t1.pno
join
    (
        select
            pr.pno
            ,count(pr.pno) pr_cnt
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-09-01'
            and pr.marker_category = 40
        group by 1
    ) t2 on t2.pno = t1.pno and pr_cnt >= 3
join ph_staging.parcel_route pr on pr.pno = t1.pno and pr.route_action = 'PENDING_RETURN' and pr.remark = 'DELIVERY_NUM_OVER_3' and pr.routed_at > '2024-09-01'


;


select
    t.pno
    ,count(distinct date(convert_tz(pr.routed_at, '+00:00', '+08:00'))) handover_cnt
from ph_staging.parcel_route pr
join tmpale.tmp_ph_pno_lj_1118 t on t.pno = pr.pno
where
    pr.routed_at > date_sub(curdate(), interval 3 month)
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1

;
select
    pi.pno
    ,pi.dst_name
    ,pi.state
    ,pi.created_at
from ph_staging.parcel_info  pi
where
    pi.created_at >= '2022-01-01'
    and pi.dst_phone = '09157158921'
   -- and pi.state < 9





   ;





with t as
    (
        select
            oi.pno
            ,oi.insure_declare_value/100 cogs
            ,oi.cod_amount/100 cod
            ,oi.remark
            ,pi.client_id
            ,pi.ticket_pickup_store_id
            ,pi.dst_store_id
            ,pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
            ,pi.created_at
            ,pi.ticket_pickup_staff_info_id
            ,oi.src_name
            ,oi.src_phone
            ,oi.dst_name
            ,oi.dst_phone
            ,oi.dst_store_id oi_dst_store_id
            ,oi.dst_detail_address
            ,pi.state
            ,oi.weight
            ,pi.exhibition_weight
        from ph_staging.order_info oi
        join dwm.dwd_dim_bigClient bc on bc.client_id = oi.client_id
        left join ph_staging.parcel_info pi on oi.pno = pi.pno and pi.created_at > date_sub(curdate(), interval 3 month)
        where
            oi.cod_amount > 500000
            and bc.client_name = 'lazada'
            and oi.created_at > date_sub(curdate(), interval 3 month)
            and oi.state < 3
            and ( pi.state is null or pi.state in (1,2,3,4,6))
    )
select
    convert_tz(t1.created_at, '+00:00', '+08:00') 'Pick up date'
    ,concat(kp.id, '-', kp.name) Customer
    ,t1.pno 'Tracking number'
    ,dp.item_name 'Item name'
    ,ss_pick.name 'Pickup branch'
    ,t1.ticket_pickup_staff_info_id 'Pickup courier'
    ,ss_dst.name 'Destination branch'
    ,t1.dst_detail_address 'Recipient address'
    ,t1.cod as 'COD_AMOUNT'
    ,t1.cogs as 'COGS_AMOUNT'
    ,t1.weight/1000 'Order weight/kg'
    ,t1.exhibition_weight/1000 'Weight/kg'
    ,case t1.state
        when 1 then 'RECEIVED'
        when 2 then 'IN_TRANSIT'
        when 3 then 'DELIVERING'
        when 4 then 'STRANDED'
        when 5 then 'SIGNED'
        when 6 then 'IN_DIFFICULTY'
        when 7 then 'RETURNED'
        when 8 then 'ABNORMAL_CLOSED'
        when 9 then 'CANCEL'
    end 'Status'
    ,t1.src_name Seller
    ,t1.src_phone 'Seller number'
    ,t1.dst_name Consignee
    ,t1.dst_phone 'Consignee number'
    ,sp.name 'Consignee province'
    ,sc.name 'Consignee city'
    ,sd.name 'Consignee barangay'
    ,datediff(curdate(), ps.first_valid_routed_at) days
    ,las.EN_element 'Last operation'
    ,convert_tz(las.routed_at, '+00:00', '+08:00') 'Operation time'
    ,las.store_name 'Operator hub'
#     ,if(bc.client_name = 'lazada', oi.remark, null) lazada_order_id
    ,substring(t1.remark, -5) lazada_order_id
    ,cd.third_sorting_code 'Delivery code'
from t t1
# left join ph_staging.parcel_info pi on t1.pno = pi.pno and pi.created_at > date_sub(curdate(), interval 3 month )
left join ph_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.drds_ph_lazada_order_info_d dp on dp.pno = t1.pno
left join ph_staging.sys_store ss_pick on ss_pick.id = t1.ticket_pickup_store_id
left join ph_staging.sys_store ss_dst on ss_dst.id = coalesce(t1.dst_store_id, t1.oi_dst_store_id)
left join ph_staging.sys_province sp on sp.code = t1.dst_province_code
left join ph_staging.sys_city sc on sc.code = t1.dst_city_code
left join ph_staging.sys_district sd on sd.code = t1.dst_district_code
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join
    (-- 包裹最新网点
        select
            pssn.*
            ,row_number() over (partition by pssn.pno order by pssn.valid_store_order) rk
        from dw_dmd.parcel_store_stage_new pssn
        join t t1 on t1.pno = pssn.pno
        where
            pssn.created_at > date_sub(curdate(), interval 3 month )
    ) ps on ps.pno = t1.pno and ps.rk = 1
left join
    (-- 最新有效路由
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_name
            ,pr.route_action EN_element
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
       -- left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 3 month )
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) las on las.pno = t1.pno and las.rk = 1
left join
    (
        select
            t1.pno
            ,dp.third_sorting_code
            ,row_number() over (partition by t1.pno order by dp.created_at desc) rk
        from dwm.drds_ph_parcel_sorting_code_info dp
        join t t1 on t1.pno = dp.pno
        where
            dp.created_at > date_sub(curdate(), interval 3 month )
    ) cd on cd.pno = t1.pno and cd.rk = 1



;


select
    pi.pno
    ,pi.ticket_delivery_staff_info_id
from ph_staging.parcel_info pi
where
    pi.state = 5
    and pi.finished_at > '2024-09-30 16:00:00'
    and pi.finished_at < '2024-10-30 16:00:00'
    and pi.ticket_delivery_staff_info_id in ('159817')



;




select
    t.pno
    ,count(distinct date (convert_tz(pr.routed_at, '+00:00', '+08:00'))) 交接次数
from ph_staging.parcel_route pr
join tmpale.tmp_ph_pno_lj_1213 t on t.pno = pr.pno
where
    pr.routed_at > '2024-09-01'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by t.pno


;




刘章
select
		pi.client_id
		, spco_109.pno
		, pi.returned_pno
		, case when pi.exhibition_length > 35 or pi.exhibition_width > 35 or pi.exhibition_height > 35 then 'bulky' else null end as type
		, ssd.last_en_marker_category as reason_for_rts
		, spco_102.status_update_time as forward_pickup_date
		, spco_109.status_update_time as return_pickup_date
		, ssd.cogs_amount / 100 as cogs_amount
		, spco_last.store_name as current_location
		, pi.exhibition_length as Actual_package_length
		, pi.exhibition_width as Actual_package_width
		, pi.exhibition_height as Actual_package_height
		, round(pi.exhibition_weight/1000,2) as Actual_Weight
		, spco_arrival.store_name as returned_hub_name
		, spco_arrival.status_update_time as returned_hub_arrival_time
		, case when hour(spco_arrival.status_update_time) >= 17 then DATE_ADD(date(spco_arrival.status_update_time),INTERVAL 1 DAY)
				else date(spco_arrival.status_update_time) end as p_date
        , now() as update_at
from
(  -- 109
		select
			 ca.pno
			,min(convert_tz(ca.status_update_time,'+00:00','+08:00')) status_update_time
		from ph_drds.shopee_callback_record ca
		where ca.callback_type=1
		and ca.status_code in ('109')
		and ca.status_update_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
		group by 1
) spco_109
left join
( -- '107','110','126','111','120'
		select
			 ca.pno
			,min(convert_tz(ca.status_update_time,'+00:00','+08:00')) status_update_time
		from ph_drds.shopee_callback_record ca
		where ca.callback_type=1
		and ca.status_code in ('107','110','126','111','120')
		and ca.status_update_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
		group by 1
) spco_final on spco_109.pno = spco_final.pno
left join
(  -- 到达
		select
			 ca.pno
			,SUBSTRING_INDEX(ca.location,",",-1) store_name
			,convert_tz(ca.status_update_time,'+00:00','+08:00') status_update_time
			,ROW_NUMBER() OVER(PARTITION BY ca.pno ORDER BY ca.status_update_time desc) as rn
		from ph_drds.shopee_callback_record ca
		left join
		(  -- 109
				select
					 ca.pno
					,min(convert_tz(ca.status_update_time,'+00:00','+08:00')) status_update_time
				from ph_drds.shopee_callback_record ca
				where ca.callback_type=1
				and ca.status_code in ('109')
				and ca.status_update_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
				group by 1
		) spco_109 on ca.pno = spco_109.pno
		where ca.callback_type=1
				and ca.status_update_time > spco_109.status_update_time
				and SUBSTRING_INDEX(ca.location,",",-1) in ('01 PN1-HUB_Maynila', 'PN5-CS3', 'PN1-CS3')
) spco_arrival on spco_109.pno = spco_arrival.pno and spco_arrival.rn = 1
left join ph_staging.parcel_info pi on spco_109.pno = pi.pno
left join dwm.dwd_ex_ph_shopee_sla_detail ssd on spco_109.pno = ssd.pno
left join
(  -- 109
		select
			 ca.pno
			,min(convert_tz(ca.status_update_time,'+00:00','+08:00')) status_update_time
		from ph_drds.shopee_callback_record ca
		where ca.callback_type=1
		and ca.status_code in ('102')
		and ca.status_update_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
		group by 1
) spco_102 on spco_109.pno = spco_102.pno
left join
(
		select
				ca.*
		from
		(
				select
					 ca.pno
					,SUBSTRING_INDEX(ca.location,",",-1) store_name
					,convert_tz(ca.status_update_time,'+00:00','+08:00') status_update_time
					,ROW_NUMBER() OVER(PARTITION BY ca.pno ORDER BY ca.status_update_time desc) as rn
				from ph_drds.shopee_callback_record ca
				where ca.callback_type=1
				and ca.status_update_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
		) ca
		where rn = 1
) spco_last on spco_109.pno = spco_last.pno
where pi.client_id = 'AA0164'
	and spco_final.pno is null
	and spco_arrival.pno is not null



;


select
    di.pno
from ph_staging.diff_info di
join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
where
    di.diff_marker_category = 23
    and di.created_at > date_sub(curdate(), interval 7 day)
    and cdt.negotiation_result_category in (3,4)



;


select
    srb.staff_info_id
    ,srb.pno
from ph_staging.store_receivable_bill_detail srb
where
    srb.receivable_type_category = 5
    and srb.state = 0
    and srb.staff_info_id in ('188463', '120875')

;



        select
            mw.staff_info_id
            ,count(mw.id) mw_cnt
        from ph_backyard.message_warning mw
        join ph_bi.hr_staff_info hsi on hsi.staff_info_id = mw.staff_info_id
        where
            mw.is_delete = 0
            and hsi.state = 1
            and mw.date_ats >= date_sub(curdate(), interval 6 month)
        having
            count(mw.id) >= 3

;

with t as
    (
        select
            hsi.staff_info_id
            ,hsi.name
            ,hsi.state
            ,hsi.wait_leave_state
            ,hjt.job_name
            ,dp.store_name
            ,dp.piece_name
            ,dp.region_name
            ,swd.warning_count
            ,swd.warning_pending_count
            ,mw.created_at
            ,mw.warning_type
            ,a1.mw_cnt
            ,row_number() over (partition by swd.staff_info_id order by mw.created_at ) rk
        from ph_backyard.staff_warning_dismiss swd
        join ph_bi.hr_staff_info hsi on hsi.staff_info_id = swd.staff_info_id and hsi.state = 1
        join
            (
                select
                    mw.staff_info_id
                    ,count(mw.id) mw_cnt
                from ph_backyard.message_warning mw
                join ph_bi.hr_staff_info hsi on hsi.staff_info_id = mw.staff_info_id
                where
                    mw.is_delete = 0
                    and hsi.state = 1
                    and mw.warning_type > 1
                    and mw.date_ats >= date_sub(curdate(), interval 6 month)
                group by 1
                having
                    count(mw.id) >= 3
            ) a1 on a1.staff_info_id = swd.staff_info_id
        left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        left join ph_backyard.message_warning mw on mw.staff_info_id = swd.staff_info_id and mw.warning_type > 1

    )
select
    t1.staff_info_id 员工工号
    ,t1.name 员工名字
    ,case
        when t1.state = 1 and t1.wait_leave_state = 0 then '在职'
        when t1.state = 1 and t1.wait_leave_state = 1 then '待离职'
        when t1.state = 2 then '离职'
        when t1.state = 3 then '停职'
    end 在职状态
    ,t1.job_name 职位
    ,t1.store_name 所属网点
    ,t1.region_name 大区
    ,t1.piece_name 片区
    ,t1.warning_count 警告书总次数
    ,t1.warning_pending_count '严厉&最后警告次数'
    ,t1.mw_cnt '近6个月严厉&最后警告次数'
    ,t1.created_at 第一次
    ,t2.created_at 第二次
    ,t3.created_at 第三次
    ,t4.created_at 第四次
    ,t5.created_at 第五次
from t t1
left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = 2
left join t t3 on t3.staff_info_id = t1.staff_info_id and t3.rk = 3
left join t t4 on t4.staff_info_id = t1.staff_info_id and t4.rk = 4
left join t t5 on t5.staff_info_id = t1.staff_info_id and t5.rk = 5
where
    t1.rk = 1



;



select
    *
from nl_production.violation_return_visit vrv
where
    vrv.type = 2
    and vrv.created_at >= '2024-11-19'
    and vrv.created_at < '2024-11-26'
    and vrv.visit_state = 4

;


select
    pi.pno
    ,pi.dst_store_id
    ,ss.name dst_store
    ,if(bc.client_name is not null , bc.client_name, 'ka&c') client_name
    ,datediff(curdate(), ps.arrive_dst_route_at) days
    ,pi.cod_enabled
from ph_staging.parcel_info pi
join ph_bi.parcel_sub ps on ps.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    pi.created_at > date_sub(curdate(), interval 3 month)
    and pi.state in (1,2,3,4,6)
    and ps.arrive_dst_route_at != '1970-01-01 00:00:00'


;



select
    date (convert_tz(di.created_at, '+00:00', '+08:00')) p_date
    ,count(di.id)
from ph_staging.diff_info di
where
    di.created_at > '2024-12-20 16:00:00'
group by 1


;



select
    ri.ss_pno
    ,ri.created_at
    ,ri.staff_id
    ,hjt.job_name
    ,ss.name store_name
from ph_bi.receivables_issues ri
left join ph_bi.hr_job_title hjt on hjt.id = ri.staff_job_title
left join ph_staging.sys_store ss on ss.id = ri.sys_store_id
where
    ri.origin = 2
    and ri.created_at > '2024-01-01'
    and ri.issues_type = 3


;


select
    hsi.staff_info_id
    ,hsi.manger
    ,hsi2.name
    ,hsi2.state
from ph_bi.hr_staff_info hsi
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = hsi.manger
where
    hsi.staff_info_id = '139115'


;


select
    pr.pno
    ,pr.staff_info_id
    ,pr.store_name 操作网点
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 操作时间
    ,ddd.CN_element 路由动作
from ph_staging.parcel_route pr
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pr.routed_at > '2025-02-03 16:00:00'
    and pr.routed_at < '2025-02-04 16:00:00'
    and pr.staff_info_id = '169274'


;


select
    pi.pno
    ,opt >> 4 & 1
    ,opt >> 8 & 1
    ,pi.created_at
from ph_staging.parcel_info pi
where
    opt >> 4 & 1 = 1
;


select
    pi.pno
    ,pi.dst_name 收件人姓名
    ,pi.dst_detail_address 收件人地址
    ,pi.dst_phone 收件人电话
    ,pi.src_name 寄件人姓名
    ,pi.src_detail_address 寄件人地址
    ,pi.src_phone 寄件人电话
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
        ELSE '其他'
	end as '包裹状态'
from  ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    ss.name = 'PSS_SP'
    and pi.dst_name regexp 'Elena'


;




    /*
        =====================================================================+
        表名称：1615d_ph_parcel_lose_sub_c
        功能描述：疑似丢失网点数据

        需求来源：
        编写人员: 吕杰
        设计日期：2023-07-15
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================
      */


      with t as
    (
         select
            dp.store_name 网点Branch
            ,dp.piece_name 片区District
            ,dp.region_name 大区Area
            ,plt.pno 运单Tracking_Number
            ,pi.exhibition_weight 重量
            ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
            ,pi2.cod_amount/100 COD
            ,plt.created_at 任务创建时间Task_Generation_time
            ,plt.parcel_created_at 包裹揽收时间Receive_time
            ,concat(ddd.element, ddd.CN_element) 最后有效路由Last_effective_route
            ,plt.last_valid_routed_at 最后有效路由操作时间Last_effective_routing_time
            ,plt.last_valid_staff_info_id 最后有效路由操作员工Last_effective_route_operate_id
            ,ss.name 最后有效路由操作网点Last_operate_branch
            ,case when pi.state = 1 then '已揽收'
                when pi.state = 2 then '运输中'
                when pi.state = 3 then '派送中'
                when pi.state = 4 then '已滞留'
                when pi.state = 5 then '已签收'
                when pi.state = 6 then '疑难件处理中'
                when pi.state = 7 then '已退件'
                when pi.state = 8 then '异常关闭'
                when pi.state = 9 then '已撤销'
                end as 包裹最新状态latest_parcel_status
            ,if(rd3.store_name = rd.store_name, rd2.store_name, rd3.store_name) AS "理论下一站网点 Theoretically_Destination_Store"
            ,rd2.store_name 目的地网点Dst_Store_Name
        from ph_bi.parcel_lose_task plt
        left join ph_bi.parcel_detail pd on pd.pno = plt.pno
        left join ph_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > date_sub(curdate(), interval 3 month )
        left join  ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = plt.last_valid_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
        left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
        left join dwm.dim_ph_sys_store_rd rd on rd.store_id = pi.duty_store_id and rd.store_category in (8,12)  and rd.stat_date = date_sub(curdate(),interval 1 day)  and rd.state_desc = '激活' and rd.is_close = 0
        left join dwm.dim_ph_sys_store_rd rd2 on rd2.store_id = pi.dst_store_id and rd2.stat_date = date_sub(curdate(),interval 1 day) and rd2.state_desc = '激活' and rd2.is_close = 0
        left join dwm.dim_ph_sys_store_rd rd3 on rd3.store_id = rd2.par_store_id and rd3.stat_date = date_sub(curdate(),interval 1 day) and rd3.state_desc = '激活' and rd3.is_close = 0
        where
            plt.source in (3,33)
            and plt.state in (1,2,3,4)
          --  and plt.pno = 'P1904957D46AO'
    )
select
   t1.*
    ,convert_tz(a.first_valid_routed_at, '+00:00', '+08:00') 到达网点时间
    ,sor.sorting_code 三段码
    ,a2.next_store_name 实际下一站网点
    ,a3.store_name 上一站网点
from t t1
left join
    (
        select
            pr.first_valid_routed_at
            ,pr.pno
            ,row_number() over (partition by pr.pno order by pr.first_valid_routed_at desc ) rn
        from dw_dmd.parcel_store_stage_new  pr
        join t t1 on t1.运单Tracking_Number = pr.pno and t1.网点Branch = pr.store_name
        where
            pr.first_valid_routed_at > date_sub(curdate(), interval 2 month)
    ) a on a.pno = t1.运单Tracking_Number and a.rn = 1
left join
    (
        select
            ps.pno
            ,ps.sorting_code
            ,row_number() over (partition by ps.pno order by ps.created_at desc) rn
        from ph_drds.parcel_sorting_code_info ps
        join t t1 on t1.运单Tracking_Number = ps.pno
        where
            ps.created_at > date_sub(curdate(), interval 3 month)
    ) sor on sor.pno = t1.运单Tracking_Number and sor.rn = 1
left join
    (
        select
            pr.routed_at
            ,pr.pno
            ,pr.next_store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join t t1 on t1.运单Tracking_Number = pr.pno and t1.网点Branch = pr.store_name
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action in ('SHIPMENT_WAREHOUSE_SCAN')
    ) a2 on a2.pno = t1.运单Tracking_Number and a2.rn = 1
left join
    (
         select
             pssn.pno
            ,pssn.store_name
            ,row_number() over (partition by pssn.pno order by pssn.last_valid_routed_at desc) rn
         from dw_dmd.parcel_store_stage_new pssn
         join  t t1 on t1.运单Tracking_Number = pssn.pno
         where
             pssn.last_valid_routed_at < date_sub(t1.任务创建时间Task_Generation_time, interval 8 hour)
    ) a3 on a3.pno = t1.运单Tracking_Number and a3.rn = 1


      ;


select * from tmpale.tmp_ph_w_phone_lei


;


select
    fvp.proof_id
    ,fvp.relation_no
    ,case fvp.relation_category
        when 1 then 'waybills'
        when 2 then 'bagging codds'
        when 3 then 'waybills'
    end as relation_type
from ph_staging.fleet_van_proof_parcel_detail fvp
where
    fvp.proof_id in ('PC3SR251099C', 'PC3SR2510985' ,'PC3SR251097R', 'PC3SR251097N', 'PC3SR251098V')
    and fvp.state < 3