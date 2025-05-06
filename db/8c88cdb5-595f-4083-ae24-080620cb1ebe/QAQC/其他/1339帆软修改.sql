
select

      pi.dat
        ,pi.total_num 达成终态包裹数量
        ,(pi.total_num-de.num) 时效内终态的包裹数
        ,(pi.total_num-de.num)/pi.total_num 时效达成率
        ,de2.days1 '1D时效要求量'
        ,de2.fnum1 '1D时效达成量'
        ,de2.rat '1D时效达成率'
        ,ds.should_del_num 应派包裹数
        -- 揽收
        ,pi2.ct 揽收
        ,pi2.ct1 标准
        ,pi2.ct2 SPEED
        ,pi2.ct3 Early_Flight电商服务
        ,pi2.ct4 大件特惠
        ,pi2.ct5 水果件
        ,pi2.ct6 happy_return标准
        ,pi2.ct7 happy_return大件
        ,plt.diushi
        ,plt.diushi1 标准_diushi
        ,plt.diushi2 SPEED_diushi
        ,plt.diushi3 Early_Flight电商服务_diushi
        ,plt.diushi4 大件特惠_diushi
        ,plt.diushi5 水果件_diushi
        ,plt.diushi6 happy_return标准_diushi
        ,plt.diushi7 happy_return大件_diushi
        ,plt.posun
        ,plt.posun1 标准_posun
        ,plt.posun2 SPEED_posun
        ,plt.posun3 Early_Flight电商服务_posun
        ,plt.posun4 大件特惠_posun
        ,plt.posun5 水果件_posun
        ,plt.posun6 happy_return标准_posun
        ,plt.posun7 happy_return大件_posun
        ,plt.sla
        ,plt.sla1 标准_sla
        ,plt.sla2 SPEED_sla
        ,plt.sla3 Early_Flight电商服务_sla
        ,plt.sla4 大件特惠_sla
        ,plt.sla5 水果件_sla
        ,plt.sla6 happy_return标准_sla
        ,plt.sla7 happy_return大件_sla
        ,ft.ct
        ,ft.normal_ct
        ,ft.start_ct
        ,ft.start_normal_ct
        ,ft.end_ct
        ,ft.end_normal_ct
/*from fle_staging.sys_store ss
left join dwm.dim_th_sys_store_rd dsr on dsr.store_id = ss.id and dsr.stat_date = date_sub(curdate(), interval 1 day )
left join fle_staging.franchisee_profile fp on ss.franchisee_id=fp.id and ss.category=6
left join
 */
from
(-- 妥投、退件
        select
          date(convert_tz(COALESCE(pi.finished_at, pi.state_change_at),'+00:00','+07:00')) dat
          ,pi.ticket_delivery_store_id
          ,count(distinct pi.pno) total_num
        from fle_staging.parcel_info pi
        where COALESCE(pi.finished_at, pi.state_change_at)>= '2024-10-27 17:00:00'
        and COALESCE(pi.finished_at, pi.state_change_at)< '2024-10-31 17:00:00'
        and pi.state in (5,7)
        -- and pi.ticket_delivery_store_id='TH01020103'
        group by 1
)pi
left join
(-- 理论时效内未妥投
    SELECT
      de.`date_id` dat
      , de.dst_store_id
      , COUNT(DISTINCT pno) AS num
    FROM dwm.`dwd_ex_delayed_parcel_daily_deatil` de
    WHERE de.`date_id` >= '2024-10-27'
    GROUP BY 1
)de on pi.dat=de.dat
left join
(-- 1D时效达成率
  SELECT
      de.created_at AS dat
      ,de.dst_store_id
      , COUNT(DISTINCT IF(de.timeline = 1, pno, NULL)) AS days1
      , COUNT(DISTINCT IF(de.state IN (5, 7) AND de.timeline = 1 AND de.days <= de.timeline + de.is_cut, de.pno, NULL)) AS fnum1
      ,COUNT(DISTINCT IF(de.state IN (5, 7) AND de.timeline = 1 AND de.days <= de.timeline + de.is_cut, de.pno, NULL))/COUNT(DISTINCT IF(timeline = 1, pno, NULL)) rat

  FROM
  (
      SELECT
          pi.`pno`
          , ss_src.`city_code` AS src_city_code
          , COALESCE(pi.`ticket_delivery_store_id`, pi.`dst_store_id`) AS dst_store_id
          , ss_dst.`city_code` AS dst_city_code
          , date(CONVERT_TZ(coalesce(pi.`finished_at`, pi.`state_change_at`), '+00:00', '+07:00')) AS finished_at
          , date(CONVERT_TZ(pi.`created_at`, '+00:00', '+07:00')) AS created_at
          , datediff(date(CONVERT_TZ(coalesce(pi.`finished_at`, pi.`state_change_at`), '+00:00', '+07:00')), date(CONVERT_TZ(pi.`created_at`, '+00:00', '+07:00'))) AS days
          , IF(DATE_FORMAT(CONVERT_TZ(pi.`created_at`, '+00:00', '+07:00'), '%T') > sec_to_time(coalesce(ss_src.`cut_time`, if(ss_src.`sorting_no` = 'B', 16 * 3600, 15 * 3600))), 1, 0) AS is_cut
          , tt.`days` AS timeline
          , pi.`state`
          , datediff(CURRENT_DATE(), date(CONVERT_TZ(pi.`created_at`, '+00:00', '+07:00'))) AS transit_days
      FROM `fle_staging`.`parcel_info` pi
      INNER JOIN `fle_staging`.`sys_store` ss_src ON ss_src.`id` = pi.`ticket_pickup_store_id`
      INNER JOIN `fle_staging`.`sys_store` ss_dst ON ss_dst.`id` = COALESCE(pi.`ticket_delivery_store_id`, pi.`dst_store_id`)
      INNER JOIN dwm.`tmp_timeline_lh` tt ON tt.`src_city_code` = ss_src.`city_code` AND tt.`dst_city_code` = ss_dst.`city_code`
      WHERE pi.created_at>= '2024-10-27 17:00:00'
      and pi.created_at< '2024-10-31 17:00:00'
      AND pi.`state` < 8
  )de
  GROUP BY 1
)de2 on pi.dat=de2.dat
left join
(-- 应派
    SELECT
    ds.`stat_date` dat
    ,ds.store_id
    ,sum(ds.should_del_num) should_del_num
  FROM dwm.dwd_ex_store_should_del_rate_daily ds
  LEFT JOIN fle_staging.sys_store ss on ss.id= ds.store_id
  WHERE ds.stat_date >= '2024-10-28'
  and ds.stat_date < '2024-11-01'
 and ss.category in (1,10)
 GROUP BY 1
)ds on pi.dat=ds.dat
left join
(-- 揽收
        select
          date(convert_tz(pi.created_at,'+00:00','+07:00')) dat
          ,pi.ticket_pickup_store_id
          ,count(distinct pi.pno) ct
          ,count(distinct if(pi.express_category=1,pi.pno,null)) ct1
          ,count(distinct if(pi.express_category=2,pi.pno,null)) ct2
          ,count(distinct if(pi.express_category=3,pi.pno,null)) ct3
          ,count(distinct if(pi.express_category=4,pi.pno,null)) ct4
          ,count(distinct if(pi.express_category=5,pi.pno,null)) ct5
          ,count(distinct if(pi.express_category=6,pi.pno,null)) ct6
          ,count(distinct if(pi.express_category=7,pi.pno,null)) ct7
        from fle_staging.parcel_info pi
        where pi.created_at>= '2024-10-27 17:00:00'
        and pi.created_at<'2024-10-31 17:00:00'
        and pi.state<8

        group by 1
)pi2 on pi.dat=pi2.dat
left join
(-- 丢失破损短少超时效
        select
                plt.dat
                #,plt.store_id
                ,sum(if(plt.duty_result=1 ,plt.num,0)) diushi
                ,sum(if(plt.duty_result=1 and plt.express_category=1,plt.num,0)) diushi1
                ,sum(if(plt.duty_result=1 and plt.express_category=2,plt.num,0)) diushi2
                ,sum(if(plt.duty_result=1 and plt.express_category=3,plt.num,0)) diushi3
                ,sum(if(plt.duty_result=1 and plt.express_category=4,plt.num,0)) diushi4
                ,sum(if(plt.duty_result=1 and plt.express_category=5,plt.num,0)) diushi5
                ,sum(if(plt.duty_result=1 and plt.express_category=6,plt.num,0)) diushi6
                ,sum(if(plt.duty_result=1 and plt.express_category=7,plt.num,0)) diushi7
                ,sum(if(plt.duty_result=2 ,plt.num,0)) posun
                ,sum(if(plt.duty_result=2 and plt.express_category=1,plt.num,0)) posun1
                ,sum(if(plt.duty_result=2 and plt.express_category=2,plt.num,0)) posun2
                ,sum(if(plt.duty_result=2 and plt.express_category=3,plt.num,0)) posun3
                ,sum(if(plt.duty_result=2 and plt.express_category=4,plt.num,0)) posun4
                ,sum(if(plt.duty_result=2 and plt.express_category=5,plt.num,0)) posun5
                ,sum(if(plt.duty_result=2 and plt.express_category=6,plt.num,0)) posun6
                ,sum(if(plt.duty_result=2 and plt.express_category=7,plt.num,0)) posun7
                ,sum(if(plt.duty_result=3,plt.num,0)) sla
                ,sum(if(plt.duty_result=3 and plt.express_category=1,plt.num,0)) sla1
                ,sum(if(plt.duty_result=3 and plt.express_category=2,plt.num,0)) sla2
                ,sum(if(plt.duty_result=3 and plt.express_category=3,plt.num,0)) sla3
                ,sum(if(plt.duty_result=3 and plt.express_category=4,plt.num,0)) sla4
                ,sum(if(plt.duty_result=3 and plt.express_category=5,plt.num,0)) sla5
                ,sum(if(plt.duty_result=3 and plt.express_category=6,plt.num,0)) sla6
                ,sum(if(plt.duty_result=3 and plt.express_category=7,plt.num,0)) sla7
        from
        (
          select
            date(plt.updated_at) dat
            ,plt.duty_result
            ,pi.express_category
            #,plt.store_id
            /*,sum(case
                    when plt.duty_type in (10,19,20,4) then 0.5
                    else 1 end) num*/
            ,count(distinct plt.pno) num
          from
          (
          	select
          		plt.updated_at
          		,plt.pno
          		,plt.duty_result
          		,duty_type
          		,plr.lose_task_id
          		,plr.store_id
          	from bi_pro.parcel_lose_task plt
          	left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id =plt.id
          	where plt.state=6
          	and plt.updated_at>= '2024-10-28'
          	and plt.updated_at< '2024-11-01'
          	#and plr.store_id is not null
          	#and plt.pno='TH01424NU2GC9A0'
          	group by 1,2,3,4,5
          )plt

          left join fle_staging.parcel_info pi on pi.pno=plt.pno and pi.created_at>date_sub(current_date,interval 4 month)
          #where pi.express_category is not null
          #and plr.store_id='TH02060106'

          group by 1,2,3
  		)plt
  group by 1
)plt on pi.dat=plt.dat
left join
(-- 班车准点率
	select
		ft.dat
		,ft.store_id
		,ft.store_name
		,count() ct -- 不需要去重
		,count(if(ft.real_time<=ft.plan_time,1,null)) normal_ct
		,count(if(ft.category='start',1,null)) start_ct
		,count(if(ft.category='start' and ft.real_time<=ft.plan_time,1,null)) start_normal_ct
		,count(if(ft.category='end',1,null)) end_ct
		,count(if(ft.category='end' and ft.real_time<=ft.plan_time,1,null)) end_normal_ct

	from
	(
		select
			date(ft.proof_at) dat
			,'start' category
			,ft.store_id
			,ft.store_name
			,ft.plan_leave_time plan_time
			,ft.real_leave_time real_time

		from bi_pro.fleet_time ft

		where ft.proof_at>= '2024-10-28'
		and ft.proof_at< '2024-11-01'
		and ft.fleet_status=1 -- 已完成
		and ft.line_mode=1 -- 常规
		and ft.plan_leave_time is not null
		and ft.real_leave_time is not null
		/*and ft.proof_id='AYUV4F627'
		and date(ft.proof_at)='2023-10-29'*/

		union all

		select
			date(ft.proof_at) dat
			,'end' category
			,ft.next_store_id store_id
			,ft.next_store_name store_name
			,ft.plan_arrive_time plan_time
			,ft.sign_time real_time

		from bi_pro.fleet_time ft

		where ft.proof_at>= '2024-10-28'
		and ft.proof_at< '2024-11-01'
		and ft.fleet_status=1 -- 已完成
		and ft.line_mode=1 -- 常规
		and ft.plan_arrive_time is not null
		and ft.sign_time is not null
		/*and ft.proof_id='AYUV4F627'
		and date(ft.proof_at)='2023-10-29'*/
	)ft
	group by 1
)ft on ft.dat=pi.dat

group by 1
order by 1