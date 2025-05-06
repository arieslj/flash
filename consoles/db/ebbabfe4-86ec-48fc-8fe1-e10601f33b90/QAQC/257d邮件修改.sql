SELECT
    pi2.pno
    , ss3.name AS '揽收网点'
    , s7.name 始发分拨
	, concat(pi2.`exhibition_length`, '*', pi2.`exhibition_width`, '*', pi2.`exhibition_height`) AS '尺寸(长*高*宽)'
	, pi2.`exhibition_weight` * 0.001 AS '实际重量kg', pi2.store_weight * 0.001 AS 计费重量kg
	, pi2.dst_postal_code
	, if(pi2.returned = 1, 'Yes', 'No') AS '是否退件'
	, pi2.returned_pno AS '退件单号', pi2.customary_pno AS '运单号'
	, convert_tz(pi2.created_at, '+00:00', '+08:00') AS 'pick_time'
	, convert_tz(pi2.finished_at,'+00:00','+08:00') as 'delivery_time'
	, ss.name AS 'dst_store_name'
	, CASE pi2.state
		WHEN 1 THEN 'RECEIVED'
		WHEN 2 THEN 'IN_TRANSIT'
		WHEN 3 THEN 'DELIVERING'
		WHEN 4 THEN 'STRANDED'
		WHEN 5 THEN 'SIGNED'
		WHEN 6 THEN 'IN_DIFFICULTY'
		WHEN 7 THEN 'RETURNED'
		WHEN 8 THEN 'ABNORMAL_CLOSED'
		WHEN 9 THEN 'CANCEL'
	END AS "包裹状态"
	, pi2.client_id AS '客户ID', ss2.name AS '当前所在网点', smr.name AS '所在大区', smp.name AS '所在片区'
-- 	, DATE_ADD(pss.last_valid_routed_at, INTERVAL 8 HOUR ) AS '最后有效路由时间'
	, DATE_ADD(ps.routed_at, INTERVAL 8 HOUR ) AS '最后有效路由时间'
-- 	, CASE pss.last_valid_route_action # 路由动作
	, ps.最后一条有效路由动作 AS 最后有效路由动作
	, ps.staff_info_name
	, ps.staff_info_id
	, DATE_ADD(pss.last_routed_at, INTERVAL 8 HOUR) AS '最后一条路由时间'
	, pss.最后一条路由动作
	, ps1.third_sorting_code AS '网格'
	, ss9.name '初始目的地网点'
    , s9.name 目的地分拨
	, pss1.store_name AS 所在网点
	, pss1.最后一条路由动作 AS 所在网点最后一条路由动作
	,ifnull(lcr.'正向尝试派送次数',dm.'正向尝试派送次数') '正向尝试派送次数'
	,ifnull(lcr.'首次尝试派送日期',dm.'首次尝试派送日期') '首次尝试派送日期'
	,ifnull(de.attempt_end_date,de1.attempt_end_date) '首次尝试派送时效日期'
	,if(ifnull(lcr.'首次尝试派送日期',dm.'首次尝试派送日期')<=ifnull(de.attempt_end_date,de1.attempt_end_date),'是','否') '是否时效内尝试派送'
	,ifnull(lcr1.status,dm1.status_code,dm2.action_code) '最终回调状态'
	,oi.cogs_amount/100 'COGS'
	,oi.cod_amount/100 'COD'
FROM my_staging.parcel_info pi2
	LEFT JOIN my_staging.order_info oi on oi.pno= IF(pi2.returned=0,pi2.pno,pi2.customary_pno)
		AND oi.pno IN ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
	LEFT JOIN my_staging.sys_store ss9 on ss9.id=oi.dst_store_id

	LEFT JOIN dwm.tmp_ex_big_clients_id_detail te ON pi2.client_id = te.client_id
	JOIN my_staging.sys_store ss ON ss.id = pi2.dst_store_id
    left join my_staging.sys_store s9 on s9.id = if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', -1))
	LEFT JOIN my_staging.sys_store ss3 ON ss3.id = pi2.ticket_pickup_store_id
    left join my_staging.sys_store s7 on s7.id = if(ss3.category in (8,12), ss3.id, substring_index(ss3.ancestry, '/', -1))
	LEFT JOIN (
		SELECT pss.*
				, lrc.cn_element AS 最后一条路由动作
			FROM dwm.parcel_store_stage_new pss
			LEFT JOIN dwm.dwd_dim_dict lrc
			    ON pss.last_route_action = lrc.element
			    AND lrc.db = 'my_staging'
			    AND lrc.tablename = 'parcel_route'
			    AND lrc.fieldname = 'route_action'
			INNER JOIN (
				SELECT pss.pno, MAX(pss.store_order) AS max_store_order
				FROM dwm.parcel_store_stage_new pss
				WHERE pss.valid_store_order IS NOT NULL
					AND pss.first_valid_route_action IS NOT NULL
					AND pss.pno_created_at > DATE_SUB(DATE_SUB(CURRENT_DATE(), 120), INTERVAL 8 HOUR)
				GROUP BY pss.pno
			) rn
			ON rn.pno = pss.pno
				AND rn.max_store_order = pss.store_order
		WHERE pss.pno IN ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
			AND pss.pno_created_at > DATE_SUB(DATE_SUB(CURRENT_DATE(), 120), INTERVAL 8 HOUR)
	)pss ON pss.pno = pi2.pno
	LEFT JOIN (
		SELECT pss.*
				, lrc.cn_element AS 最后一条路由动作
				, ROW_NUMBER() OVER(PARTITION BY pss.pno ORDER BY pss.store_order DESC) AS rn
			FROM dwm.parcel_store_stage_new pss
			LEFT JOIN dwm.dwd_dim_dict lrc
			    ON pss.last_route_action = lrc.element
			    AND lrc.db = 'my_staging'
			    AND lrc.tablename = 'parcel_route'
			    AND lrc.fieldname = 'route_action'
		WHERE pss.pno IN ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
			AND pss.pno_created_at > DATE_SUB(DATE_SUB(CURRENT_DATE(), 120), INTERVAL 8 HOUR)
	)pss1 ON pss1.pno = pi2.pno
		AND pss1.rn =1
	LEFT JOIN (
		SELECT pr.pno, pr.store_id, pr.staff_info_name, pr.staff_info_id, pr.route_action
			, lrc.cn_element AS 最后一条有效路由动作
			, pr.routed_at, row_number() OVER (PARTITION BY pr.pno ORDER BY pr.routed_at DESC) AS rank
		FROM my_staging.parcel_route pr
		LEFT JOIN dwm.dwd_dim_dict lrc
		    ON pr.route_action = lrc.element
		    AND lrc.db = 'my_staging'
		    AND lrc.tablename = 'parcel_route'
		    AND lrc.fieldname = 'route_action'
		WHERE pr.routed_at >= current_date() - INTERVAL 120 DAY
		AND pr.pno IN ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
			AND pr.route_action IN (
				'RECEIVED',
				'RECEIVE_WAREHOUSE_SCAN',
				'SORTING_SCAN',
				'DELIVERY_TICKET_CREATION_SCAN',
				'ARRIVAL_WAREHOUSE_SCAN',
				'SHIPMENT_WAREHOUSE_SCAN',
				'DETAIN_WAREHOUSE',
				'DELIVERY_CONFIRM',
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
				'SORTING_SCAN',
-- 				'INVENTORY',
				'SYSTEM_AUTO_RETURN'
			)
	) ps
	ON ps.pno = pi2.pno
		AND ps.rank = 1
	LEFT JOIN my_staging.sys_store ss2 ON ss2.id = ps.store_id
	LEFT JOIN my_staging.sys_manage_piece smp ON smp.id = ss2.manage_piece
	LEFT JOIN my_staging.sys_manage_region smr ON smr.id = ss2.manage_region
	LEFT JOIN (
		SELECT ps.pno, ps.third_sorting_code, row_number() OVER (PARTITION BY ps.pno ORDER BY ps.created_at DESC) AS rank
		FROM my_drds_pro.parcel_sorting_code_info ps
		WHERE ps.created_at > current_date() - INTERVAL 120 DAY
			AND ps.pno IN ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
	) ps1
	ON ps1.pno = pi2.pno
		AND ps1.rank = 1

left join
(select
lcr.pno
,count(distinct date(convert_tz(lcr.status_update_time,'+00:00','+08:00'))) '正向尝试派送次数'
,min(date(convert_tz(lcr.status_update_time,'+00:00','+08:00'))) '首次尝试派送日期'

from my_drds_pro.lazada_callback_record lcr
where lcr.status_update_time >= current_date() - INTERVAL 90 DAY
and lcr.status in ('domestic_1st_attempt_failed','domestic_reattempts_failed','domestic_delivery_failed','domestic_delivered')
and lcr.pno  in ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
group by 1
)lcr on lcr.pno=pi2.pno


left join
(select dm.pno
,count(distinct date(convert_tz(dm.status_update_time,'+00:00','+08:00'))) '正向尝试派送次数'
,min(date(convert_tz(dm.status_update_time,'+00:00','+08:00')))  '首次尝试派送日期'
from dwm.drds_my_shopee_callback_record dm
where dm.status_update_time >= current_date() - INTERVAL 90 DAY
and dm.status_code in  ('DELIVERY_1ST_FAILED','DELIVERY_REATTEMPTS_FAILED','DELIVERY_FAILED','DELIVERY_CONFIRM')
and dm.pno in ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
group by 1
)dm on dm.pno=pi2.pno


left join
(select
lcr.pno
,status
,row_number()over(partition by lcr.pno order by lcr.status_update_time desc) rank
from my_drds_pro.lazada_callback_record lcr
where lcr.status_update_time >= current_date() - INTERVAL 90 DAY
and lcr.pno  in ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
)lcr1 on lcr1.pno=pi2.pno and lcr1.rank=1


left join
(select dm.pno
,dm.status_code
,row_number()over(partition by dm.pno order by dm.status_update_time desc) rank
from dwm.drds_my_shopee_callback_record dm
where dm.status_update_time >= current_date() - INTERVAL 90 DAY
and dm.pno in ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
)dm1 on dm1.pno=pi2.pno and dm1.rank=1

left join

(select dm.tracking_no
,dm.action_code
,row_number()over(partition by dm.tracking_no order by dm.operate_time desc) rank

from dwm.dwd_my_tiktok_parcel_route_callback_record dm
where dm.operate_time>= current_date() - INTERVAL 90 DAY
and dm.tracking_no in ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}')
)dm2 on dm2.tracking_no=pi2.pno and dm2.rank=1

left join dwm.dwd_ex_my_lazada_pno_period de on de.pno=pi2.pno and de.pick_date>=current_date()-interval 90 day
left join dwm.dwd_ex_my_shopee_pno_period de1 on de1.pno=pi2.pno and de1.pick_date >=current_date()-interval 90 day
WHERE pi2.created_at >= current_date() - INTERVAL 120 DAY
	AND pi2.pno IN ('${SUBSTITUTE(SUBSTITUTE(p4,"
",","),",","','")}');

