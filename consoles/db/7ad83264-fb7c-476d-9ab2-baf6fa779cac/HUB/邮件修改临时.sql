/*=====================================================================+
    表名称：  952_ph_hub_exist
    功能描述： HUB在仓未发件出仓监控

    需求来源：
    编写人员: 田策
    设计日期：2022/3/24
      修改日期: 2022-10-19
      修改人员:  杨京高
      修改原因:
      修改日期: 2023-07-21
      修改人员:  唐少鹏
      修改原因: 新增字段：上一站是否集包、上一站集包号、是否需要拆包、拆包时间、新集包号、集包时间、是否已集包、包裹重量
      修改日期: 2023-08-15
      修改人员:  唐少鹏
      修改原因: 新增字段：分拨节点、是否当天需要中转；更新字段：上一站网点从简称变全称
      修改日期: 2023-09-22
      修改人员: 罗名胜
      修改原因：明细数据，保留最后一次集包时间
      修改日期: 2024-04-22
      修改人员:  唐少鹏
      修改原因: 新增PS、PC分拨的截点，判断是否需要转出，并根据15点切换截点


  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
+=====================================================================*/


SELECT
     now() AS "Update_Time"
    , ss.name AS "Origin_Hub"
    , IF(ss3.name = ss.name, ss2.name, ss3.name) AS "Destination_Store"
    , count(DISTINCT pi2.pno) AS "Total_Pending_Volume"
    , count(DISTINCT IF(timestampdiff(HOUR,pr.routed_at,NOW())>=24, pi2.pno,NULL)) AS  "Pending_Over_24Hours_Volume"

    , count(DISTINCT IF(te.client_name ='tiktok',pi2.pno,NULL)) AS "Tiktok_Pending_Volume"
    , count(DISTINCT IF(timestampdiff(HOUR,pr.routed_at,NOW())>=24 AND te.client_name ='tiktok', pi2.pno,NULL)) AS  "Tiktok_Pending_Over_24Hours_Volume"
    , count(DISTINCT IF(te.client_name ='lazada',pi2.pno,NULL)) AS "Lazada_Pending_Volume"
    , count(DISTINCT IF(timestampdiff(HOUR,pr.routed_at,NOW())>=24 AND te.client_name ='lazada', pi2.pno,NULL)) AS  "Lazada_Pending_Over_24Hours_Volume"
    , count(DISTINCT IF(te.client_name ='shopee',pi2.pno,NULL)) AS "Shopee_Pending_Volume"
    , count(DISTINCT IF(timestampdiff(HOUR,pr.routed_at,NOW())>=24 AND te.client_name ='shopee', pi2.pno,NULL)) AS  "Shopee_Pending_Over_24Hours_Volume"

FROM ph_staging.parcel_info pi2
 INNER JOIN (
  SELECT pr.pno, pr.store_id,DATE_ADD(routed_at,INTERVAL 8 HOUR) as routed_at
  ,JSON_EXTRACT(pr.extra_value , '$.proofId') as proofId
  ,JSON_EXTRACT(pr.extra_value , '$.leaveStoreName') leaveStoreName
  ,JSON_EXTRACT(pr.extra_value , '$.vanLineId') as vanLineId
  ,row_number() over(partition by pno,store_id order by routed_at) as rn
  FROM ph_staging.parcel_route pr
  WHERE pr.store_category = 8
   and pr.store_id <> 6
    and pr.deleted =0
   AND pr.route_action IN (
							'RECEIVED',
							'RECEIVE_WAREHOUSE_SCAN',
							'SORTING_SCAN',
							'DELIVERY_TICKET_CREATION_SCAN',
							'ARRIVAL_WAREHOUSE_SCAN',
							'SHIPMENT_WAREHOUSE_SCAN',
							'DETAIN_WAREHOUSE',
							'DELIVERY_CONFIRM',
							'DIFFICULTY_HANDOVER',
							'DELIVERY_MARKER',
							'REPLACE_PNO',
							'SEAL',
							'UNSEAL',
							'PARCEL_HEADLESS_PRINTED',
							'STAFF_INFO_UPDATE_WEIGHT',
							'STORE_KEEPER_UPDATE_WEIGHT',
							'STORE_SORTER_UPDATE_WEIGHT',
							'DISCARD_RETURN_BKK',
							'DELIVERY_TRANSFER',
							'PICKUP_RETURN_RECEIPT',
							'FLASH_HOME_SCAN',
							'ARRIVAL_WAREHOUSE_SCAN',
							'ARRIVAL_GOODS_VAN_CHECK_SCAN')
   and pr.routed_at> DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
 ) pr
 ON pr.pno = pi2.pno
  AND pr.store_id = pi2.duty_store_id
  and pr.rn=1
 LEFT JOIN (
  SELECT DISTINCT pr.pno, pr.store_id
  FROM ph_staging.parcel_route pr
  WHERE pr.store_category = 8
   AND pr.route_action IN ('SHIPMENT_WAREHOUSE_SCAN', 'DEPARTURE_GOODS_VAN_CK_SCAN')
   and pr.routed_at> DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
 ) pr1
 ON pr1.pno = pi2.pno
  AND pr1.store_id = pi2.duty_store_id
 INNER JOIN ph_staging.sys_store ss
 ON ss.id = pi2.duty_store_id
  AND ss.category = 8
 LEFT JOIN ph_staging.sys_store ss2 ON ss2.id = pi2.dst_store_id
 LEFT JOIN ph_staging.sys_store ss3 ON ss3.id = ss2.ancestry
 LEFT JOIN dwm.dwd_dim_bigClient te ON pi2.client_id = te.client_id
WHERE pi2.state NOT IN (5, 7, 8, 9)
and pi2.created_at > DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
 AND pr1.pno IS NULL
 GROUP BY ss.name
 , IF(ss3.name = ss.name, ss2.name, ss3.name)
 order by 2,3
;

-- 明细
SELECT pi2.pno AS "PNO"
    , pi2.client_id
    , CASE
        WHEN te.client_id IS NOT NULL THEN te.client_name
        WHEN pi2.customer_type_category = 2 THEN 'KA'
        WHEN pi2.customer_type_category = 1 THEN '小C'
      END AS client_name
    , rd4.store_name AS "Previous_Store"
    , pr.proofId AS "ProofId"
    , pr.routed_at AS "Arrival_Time"
    , prr.routed_at AS "Hub_first_operator_Time"
    , IF(sec.store_id IS NULL,'',IF(rd4.store_category = 1, IF(NOW()<= concat(curdate(),' ',DATE_FORMAT('15:00','%T')),sec.zhixian_latest_arr_at,DATE_SUB(sec.zhixian_latest_arr_at,-1)), IF(NOW()<= concat(curdate(),' ',DATE_FORMAT('15:00','%T')),sec.ganxian_latest_arr_at,DATE_SUB(sec.ganxian_latest_arr_at,-1)))) AS "Hub_Cutoff_Time"
    , IF(sec.store_id IS NULL,'',IF(pr.routed_at <= IF(rd4.store_category = 1, IF(NOW()<= concat(curdate(),' ',DATE_FORMAT('15:00','%T')),sec.zhixian_latest_arr_at,DATE_SUB(sec.zhixian_latest_arr_at,-1)), IF(NOW()<= concat(curdate(),' ',DATE_FORMAT('15:00','%T')),sec.ganxian_latest_arr_at,DATE_SUB(sec.ganxian_latest_arr_at,-1))),'YES','NO')) AS "Is_Need_To_Transfer_Today"
    , rd.store_name AS "Hub_Name"
    , IF(rd3.store_name = rd.store_name, rd2.store_name, rd3.store_name) AS "Destination_Store"
    , rd2.store_name AS "Dst_Store_Name"
    , IF(timestampdiff(HOUR,pr.routed_at,NOW())>=24,"YES","NO") AS "Is_More_Than_24Hours"
    , timestampdiff(HOUR,pr.routed_at,NOW()) AS "Hours"
    , IF(pr.Previous_packPno IS NOT NULL,"YES","NO") AS "Is_Sealed_By_Previous_Store"
    , pr.Previous_packPno AS "Previous_PackPno"
    , IF(pr.Previous_packPno IS NOT NULL,IF(rd3.store_name = rd.store_name, "YES", "NO"),NULL) AS "Is_Need_To_Unseal"
    , pr3.unseal_at AS "Unseal_At"
    , pr2.packPno AS "New_PackPno"
    , pr2.seal_at AS "Seal_At"
    , IF(pr2.packPno IS NOT NULL OR pr2.seal_at IS NOT NULL,"YES","NO") "Is_Seal"
    , pi2.weight AS "Parcel_Weight"

FROM ph_staging.parcel_info pi2
join
    (
        SELECT
            pr.pno, pr.store_id,DATE_ADD(routed_at,INTERVAL 8 HOUR) as routed_at
            ,pr.route_action
            ,pr.extra_value
            ,REPLACE(JSON_EXTRACT(pr.extra_value , '$.proofId'),'"','') as proofId
            ,REPLACE(JSON_EXTRACT(pr.extra_value , '$.leaveStoreId'),'"','') as leaveStoreId
            ,REPLACE(JSON_EXTRACT(pr.extra_value , '$.leaveStoreName'),'"','') leaveStoreName
            ,REPLACE(JSON_EXTRACT(pr.extra_value , '$.vanLineId'),'"','') as vanLineId
            ,REPLACE(JSON_EXTRACT(pr.extra_value , '$.packPno'),'"','') as Previous_packPno
            ,row_number() over(partition by pno,store_id order by routed_at) as rn
        FROM ph_staging.parcel_route pr
        WHERE pr.store_category = 8
        and pr.store_id <> 6
        -- and pr.pno = 'PT660622NXDA9AL'
        and pr.deleted =0
        AND pr.route_action IN (
                            'RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN',
                            'SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER',
                            'DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT',
                            'STORE_KEEPER_UPDATE_WEIGHT',
                            'STORE_SORTER_UPDATE_WEIGHT',
                            'DISCARD_RETURN_BKK',
                            'DELIVERY_TRANSFER',
                            'PICKUP_RETURN_RECEIPT',
                            'FLASH_HOME_SCAN',
                            'ARRIVAL_WAREHOUSE_SCAN',
                            'ARRIVAL_GOODS_VAN_CHECK_SCAN')
        and pr.routed_at> DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
    ) pr ON pr.pno = pi2.pno AND pr.store_id = pi2.duty_store_id  and pr.rn=1
left JOIN
    (
        SELECT pr.pno,
            pr.store_id,
            DATE_ADD(min(routed_at),INTERVAL 8 HOUR) as routed_at
        FROM ph_staging.parcel_route pr
        WHERE pr.store_category = 8
        and pr.store_id <> 6
        -- and pr.pno = 'PT660622NXDA9AL'
        and pr.deleted =0
        AND pr.route_action IN (
                            'RECEIVED',
                            'RECEIVE_WAREHOUSE_SCAN',
                            'SORTING_SCAN',
                            'DELIVERY_TICKET_CREATION_SCAN',
                            'ARRIVAL_WAREHOUSE_SCAN',
                            'SHIPMENT_WAREHOUSE_SCAN',
                            'DETAIN_WAREHOUSE',
                            'DELIVERY_CONFIRM',
                            'DIFFICULTY_HANDOVER',
                            'DELIVERY_MARKER',
                            'REPLACE_PNO',
                            'SEAL',
                            'UNSEAL',
                            'PARCEL_HEADLESS_PRINTED',
                            'STAFF_INFO_UPDATE_WEIGHT',
                            'STORE_KEEPER_UPDATE_WEIGHT',
                            'STORE_SORTER_UPDATE_WEIGHT',
                            'DISCARD_RETURN_BKK',
                            'DELIVERY_TRANSFER',
                            'PICKUP_RETURN_RECEIPT',
                            'FLASH_HOME_SCAN',
                            'ARRIVAL_WAREHOUSE_SCAN')
        and pr.routed_at> DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
        group by 1,2
    ) prr ON prr.pno = pi2.pno AND prr.store_id = pi2.duty_store_id
LEFT JOIN
    (
        SELECT
            DISTINCT pr.pno, pr.store_id
        FROM ph_staging.parcel_route pr
        WHERE pr.store_category = 8
        AND pr.route_action IN ('SHIPMENT_WAREHOUSE_SCAN', 'DEPARTURE_GOODS_VAN_CK_SCAN')
        and pr.routed_at> DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
 ) pr1 ON pr1.pno = pi2.pno AND pr1.store_id = pi2.duty_store_id
  #集包时间
LEFT JOIN
    (
        select
            *
        from
            (
                SELECT  pr.pno, pr.store_id
                    , JSON_EXTRACT(pr.extra_value , '$.packPno') as packPno
                    , DATE_ADD(pr.routed_at, INTERVAL 8 HOUR) AS seal_at
                    ,rank() over (partition by pno,store_id order by routed_at desc ) rk

                FROM ph_staging.parcel_route pr
                WHERE pr.store_category = 8
                AND pr.route_action IN ('SEAL')
                and pr.routed_at> DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
            ) seal
        where seal.rk=1
    ) pr2 ON pr2.pno = pi2.pno AND pr2.store_id = pi2.duty_store_id
LEFT JOIN
    (
        SELECT
            DISTINCT
            pr.pno, pr.store_id
            , DATE_ADD(min(pr.routed_at), INTERVAL 8 HOUR) AS unseal_at
        FROM ph_staging.parcel_route pr
        WHERE pr.store_category = 8
        AND pr.route_action IN ('UNSEAL','UNSEAL_NOT_SCANNED') # 拆包到件、集包已拆包，此包裹未被扫描
        AND pr.routed_at> DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
        GROUP BY 1,2
    ) pr3 ON pr3.pno = pi2.pno AND pr3.store_id = pi2.duty_store_id
LEFT JOIN
    (
    SELECT rd.store_id,rd.store_name
        ,CASE
            WHEN rd.store_name = '01 PN1-HUB_Maynila' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:30','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '02 PN2-HUB_Pangasinan' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('1:30','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '03 PN3-HUB_Isabela' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '04  PN4-HUB_Bicol' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('1:30','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '11 PN5-HUB_Santa Rosa' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:30','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '14 PN6-HUB_Vigan' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('22:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '15 PN7-HUB_Tuguegarao' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('22:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '16 PN8-HUB_Bulacan' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('2:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '05 PC1-HUB_Cebu' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('1:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '06 PC2-HUB_Iloilo' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '07 PC3-HUB_Tacloban' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('1:30','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '12 PC4-HUB_Bacolod' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '13 PC5-HUB_Kalibo' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('0:01','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '17 PC6-HUB_Calbayog' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:30','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '19 PC7-HUB_Masbate' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '08 PS1-HUB_Davao' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '09 PS2-HUB_Zamboanga' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('0:01','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '10 PS3-HUB_Cagayan de Oro' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '18 PS4-HUB_Butuan' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:30','%T')),'%Y-%m-%d %T')
        END zhixian_latest_arr_at #每天早上9点更新数据可用，如果其他时间，可能需要调整date_sub的天数
        ,CASE
            WHEN rd.store_name = '01 PN1-HUB_Maynila' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('2:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '02 PN2-HUB_Pangasinan' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('1:30','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '03 PN3-HUB_Isabela' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '04  PN4-HUB_Bicol' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('1:30','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '11 PN5-HUB_Santa Rosa' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('2:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '14 PN6-HUB_Vigan' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('22:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '15 PN7-HUB_Tuguegarao' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '16 PN8-HUB_Bulacan' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('2:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '05 PC1-HUB_Cebu' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('2:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '06 PC2-HUB_Iloilo' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('15:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '07 PC3-HUB_Tacloban' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('2:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '12 PC4-HUB_Bacolod' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '13 PC5-HUB_Kalibo' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('0:01','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '17 PC6-HUB_Calbayog' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '19 PC7-HUB_Masbate' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('21:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '08 PS1-HUB_Davao' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('22:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '09 PS2-HUB_Zamboanga' THEN DATE_FORMAT(concat(date_sub(curdate(),0),' ',DATE_FORMAT('0:01','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '10 PS3-HUB_Cagayan de Oro' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('23:00','%T')),'%Y-%m-%d %T')
            WHEN rd.store_name = '18 PS4-HUB_Butuan' THEN DATE_FORMAT(concat(date_sub(curdate(),1),' ',DATE_FORMAT('21:00','%T')),'%Y-%m-%d %T')
        END ganxian_latest_arr_at #每天早上9点更新数据可用，如果其他时间，可能需要调整date_sub的天数
    FROM dwm.dim_ph_sys_store_rd rd
    WHERE 1=1
    AND rd.store_type = 'Hub'
    AND rd.store_name NOT IN ('PN-PAL','VR-Minihub-MBT(PN4)','66 BAG_HUB_Maynila','99 AGS-Mini HUB')
    AND rd.stat_date = DATE_SUB(CURDATE(),INTERVAL 1 DAY)
    AND rd.state_desc = '激活'
    AND rd.is_close = 0
    ) sec  ON sec.store_id = pi2.duty_store_id
INNER JOIN dwm.dim_ph_sys_store_rd rd ON rd.store_id = pi2.duty_store_id AND rd.store_category = 8  AND rd.stat_date = DATE_SUB(CURDATE(),INTERVAL 1 DAY)  AND rd.state_desc = '激活' AND rd.is_close = 0
LEFT JOIN dwm.dim_ph_sys_store_rd rd2 ON rd2.store_id = pi2.dst_store_id AND rd2.stat_date = DATE_SUB(CURDATE(),INTERVAL 1 DAY) AND rd2.state_desc = '激活' AND rd2.is_close = 0
LEFT JOIN dwm.dim_ph_sys_store_rd rd3 ON rd3.store_id = rd2.par_store_id AND rd3.stat_date = DATE_SUB(CURDATE(),INTERVAL 1 DAY) AND rd3.state_desc = '激活' AND rd3.is_close = 0
LEFT JOIN dwm.dim_ph_sys_store_rd rd4 ON rd4.store_id = pr.leaveStoreId AND rd4.stat_date = DATE_SUB(CURDATE(),INTERVAL 1 DAY) AND rd4.state_desc = '激活' AND rd4.is_close = 0
LEFT JOIN dwm.dwd_dim_bigClient te ON pi2.client_id = te.client_id
WHERE pi2.state NOT IN (5, 7, 8, 9)
AND pi2.created_at > DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
 AND pr1.pno IS NULL



;
##同时存在发件出仓扫描，但是没有关联车货出港的路由动作
SELECT pi2.pno AS "PNO"
    , pi2.client_id
    , CASE
        WHEN te.client_id IS NOT NULL THEN te.client_name
        WHEN pi2.customer_type_category = 2 THEN 'KA'
        WHEN pi2.customer_type_category = 1 THEN '小C'
      END AS client_name
    , pr.leaveStoreName AS "Previous_Store"
    , pr.proofId AS "ProofId"
    , pr.routed_at AS "Arrival_Time"

    , ss.name AS "Hub_Name"
    #,last_valid_store.第一条有效路由时间
    #,last_valid_store.store_name
    , IF(ss3.name = ss.name, ss2.name, ss3.name) AS "Destination_Store"
    , ss2.name AS "Dst_Store_Name"
    , IF(timestampdiff(HOUR,pr.routed_at,NOW())>=24,"YES","NO") AS "Is_More_Than_24Hours"
    , timestampdiff(HOUR,pr.routed_at,NOW()) AS "Hours"

FROM ph_staging.parcel_info pi2
 INNER JOIN (
  SELECT pr.pno, pr.store_id,DATE_ADD(routed_at,INTERVAL 8 HOUR) as routed_at
  ,JSON_EXTRACT(pr.extra_value , '$.proofId') as proofId
  ,JSON_EXTRACT(pr.extra_value , '$.leaveStoreName') leaveStoreName
  ,JSON_EXTRACT(pr.extra_value , '$.vanLineId') as vanLineId
  ,row_number() over(partition by pno,store_id order by routed_at) as rn
  FROM ph_staging.parcel_route pr
  WHERE pr.store_category = 8
  and pr.store_id <> 6
   and pr.deleted =0
   AND pr.route_action IN (
							'RECEIVED',
							'RECEIVE_WAREHOUSE_SCAN',
							'SORTING_SCAN',
							'DELIVERY_TICKET_CREATION_SCAN',
							'ARRIVAL_WAREHOUSE_SCAN',
							'SHIPMENT_WAREHOUSE_SCAN',
							'DETAIN_WAREHOUSE',
							'DELIVERY_CONFIRM',
							'DIFFICULTY_HANDOVER',
							'DELIVERY_MARKER',
							'REPLACE_PNO',
							'SEAL',
							'UNSEAL',
							'PARCEL_HEADLESS_PRINTED',
							'STAFF_INFO_UPDATE_WEIGHT',
							'STORE_KEEPER_UPDATE_WEIGHT',
							'STORE_SORTER_UPDATE_WEIGHT',
							'DISCARD_RETURN_BKK',
							'DELIVERY_TRANSFER',
							'PICKUP_RETURN_RECEIPT',
							'FLASH_HOME_SCAN',
							'ARRIVAL_WAREHOUSE_SCAN',
							'ARRIVAL_GOODS_VAN_CHECK_SCAN')
   and pr.routed_at> DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
 ) pr
 ON pr.pno = pi2.pno
  AND pr.store_id = pi2.duty_store_id
  and pr.rn=1
 LEFT JOIN (
  SELECT DISTINCT pr.pno, pr.store_id
  FROM ph_staging.parcel_route pr
  WHERE pr.store_category = 8
   AND pr.route_action='DEPARTURE_GOODS_VAN_CK_SCAN'  #做了车货出港的网点

   and pr.routed_at> DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
 ) pr1
 ON pr1.pno = pi2.pno
  AND pr1.store_id = pi2.duty_store_id


  LEFT JOIN (
  SELECT DISTINCT pr.pno, pr.store_id
  FROM ph_staging.parcel_route pr
  WHERE pr.store_category = 8
   AND pr.route_action='SHIPMENT_WAREHOUSE_SCAN'  #发件出仓扫描

   and pr.routed_at> DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
 ) pr1_SHIPMENT_WAREHOUSE_SCAN
 ON pr1_SHIPMENT_WAREHOUSE_SCAN.pno = pi2.pno
  AND pr1_SHIPMENT_WAREHOUSE_SCAN.store_id = pi2.duty_store_id




 INNER JOIN ph_staging.sys_store ss
 ON ss.id = pi2.duty_store_id
  AND ss.category = 8

   #最新有效网点
  left join ( select
 convert_tz(first_valid_routed_at, '+00:00', '+08:00' ) 第一条有效路由时间
 ,*
 from
 (

select
*
,rank() over (PARTITION by pno order by first_valid_routed_at desc ) rk
from dw_dmd.parcel_store_stage_new pssn
where first_valid_routed_at>DATE_SUB(DATE_SUB(DATE(NOW()), 20), INTERVAL 8 HOUR)
) temp
where temp.rk=1) last_valid_store

 on  last_valid_store.pno=pi2.pno



 LEFT JOIN ph_staging.sys_store ss2 ON ss2.id = pi2.dst_store_id
 LEFT JOIN ph_staging.sys_store ss3 ON ss3.id = ss2.ancestry
 LEFT JOIN dwm.dwd_dim_bigClient te ON pi2.client_id = te.client_id
WHERE pi2.state NOT IN (5, 7, 8, 9)
and pi2.created_at > DATE_SUB(DATE_SUB(DATE(NOW()), 15), INTERVAL 8 HOUR)
 AND pr1.pno IS NULL
 and pr1_SHIPMENT_WAREHOUSE_SCAN.pno is not null
and  case when last_valid_store.store_name!=ss.name and  last_valid_store.第一条有效路由时间>pr.routed_at then 1 else null end is null
#最新有效网点不等于当前网点，且该有效网点的第一条有效路由大于目前的到港时间
#主要是为了剔除，做了发件出仓，没有做出港，但是包裹其实已经发出去了，并且到了其他网点







