  /* =====================================================================+
        表名称:dwd_th_inp_sub_staff_info_rt
        功能描述：快递员子账号信息日表-准实时

        需求来源：
        编写人员: zhangqiao
        设计日期：2022-06-09
      	修改记录:

      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
Drop table if exists tmpale.`dwd_th_inp_sub_staff_info_rt`;
Create Table tmpale.`dwd_th_inp_sub_staff_info_rt` (
 `stat_date` date COMMENT '统计日期',
 `staff_info_id` bigint COMMENT '员工工号',
 `staff_info_name` varchar COMMENT '员工姓名',
 `store_id` varchar COMMENT '员工归属网点ID',
 `store_name` varchar COMMENT '员工归属网点名称',
 `master_staff` bigint COMMENT '主账号',
 `master_hire_date` date COMMENT '主账号入职日期',
 `master_store_id` varchar COMMENT '主账号归属网点ID',
 `master_store_name` varchar COMMENT '主账号归属网点名称',
 `is_sub_staff` varchar COMMENT '是否子账号',
 `is_vir` varchar(1) COMMENT '是否虚拟',
 `work_store_id` varchar COMMENT '工作网点ID',
 `work_store_name` varchar COMMENT '工作网点名称',
 `hire_date` date COMMENT '入职日期',
 `on_days` bigint COMMENT '在职天数',
 `leave_date` date COMMENT '离职日期',
 `status` int COMMENT '在职状态',
 `status_desc` varchar(10) COMMENT '在职状态描述',
 `job_title` bigint COMMENT '岗位',
 `job_title_desc` varchar(10) COMMENT '岗位描述',
 `formal` int COMMENT '员工属性 ',
 `formal_desc` varchar(10) COMMENT '员工属性 正式or外协',
 `attendance_hour` double COMMENT '打卡时长 单位小时',
 `attendance_started_at` datetime COMMENT '上班打卡时间',
 `attendance_end_at` datetime COMMENT '下班打卡时间',
 `attendance_store_id` varchar COMMENT '打卡网点ID',
 `attendance_store_name` varchar COMMENT '打卡网点名称',
 `handover_par_cnt` bigint COMMENT '今交接量',
 `fns_par_cnt` bigint COMMENT '妥投量',
 `norm_fns_par_cnt` bigint COMMENT '正常件妥投量',
 `first_fns_time` datetime COMMENT '首次妥投时间',
 `last_fns_time` datetime COMMENT '末次妥投时间',
 `pickup_task_cnt` bigint COMMENT '揽收任务数',
 `pickup_par_cnt` bigint COMMENT '揽收单量',
 `first_pickup_time` datetime COMMENT '首次揽件时间',
 `last_pickup_time` datetime COMMENT '末次揽件时间',
 `pick_fns_cnt` bigint COMMENT '揽派量',
 `supply_store_id` varchar COMMENT '支援网点ID',
 `supply_store_name` varchar COMMENT '支援网点名称',
 `employment_begin_date` date COMMENT '支援计划开始日期',
 `employment_end_date` date COMMENT '支援计划结束日期',
 `actual_begin_date` date COMMENT '支援实际开始日期',
 `actual_end_date` date COMMENT '支援实际结束日期',
 `plan_work_status` varchar(3) COMMENT '支援状态',
 `plan_work_store` varchar COMMENT '支援网点',
 `is_att` varchar(1) COMMENT '是否出勤'
) INDEX_ALL='Y' STORAGE_POLICY='HOT' COMMENT='快递员子账号信息日表-准实时'
;

*/

truncate table tmpale.`dwd_th_inp_sub_staff_info_rt`;
insert into tmpale.`dwd_th_inp_sub_staff_info_rt`
SELECT
CURRENT_DATE as stat_date
,hi.id as staff_info_id  -- 员工工号
,hi.name as staff_info_name -- 员工姓名
,hi.organization_id as store_id -- 员工归属网点ID
,ss.name as store_name -- 员工归属网点名称

,coalesce(hi.master_staff,hi.id) as master_staff -- 主账号
,mas.master_hire_date -- 主账号入职日期
,mas.master_store_id -- 主账号归属网点ID
,mas.master_store_name -- 主账号归属网点名称
,CASE when  hi.`is_sub_staff` =1 then '是'
      when  hi.`is_sub_staff` =0 then '否' end as is_sub_staff -- 是否子账号

,case when (ss.name in ('TEST CES','Testing（北京团队测试用）') or ss.`name`  LIKE '3PL_Vir%'  or hi.name like '%虚拟%' ) then '是' else '否' end as is_vir -- 是否虚拟
,wk.work_store_id -- 工作网点ID
,wk.name as work_store_name -- 工作网点名称
,date(hi.`hire_date`) as hire_date -- 入职日期
,date_diff(curdate(), hi.`hire_date`) as on_days -- 在职天数
,if(hi.state=1,null,date(hi.leave_date)) as leave_date -- 离职日期

,hi.`state`
,case hi.`state`  when 1 then "在职" when 2 then "离职" when 3 then "停职" end as status_desc -- 在职状态
,hi.`job_title`
,jb.job_name as job_title_desc -- 岗位
,hi.`formal`
,CASE when  hi.`formal` =1 then '正式'
      when  hi.`formal` =0 then '外协' end as formal_desc -- 正式or外协

,ad.attendance_hour  -- 打卡时长 单位小时
,ad.attendance_started_at -- 上班打卡时间
,ad.attendance_end_at  -- 下班打卡时间
,ad.attendance_store_id -- 打卡网点
,ad.attendance_store_name -- 打卡网点


,wk.handover_par_cnt -- 今日个人交接量
,wk.fns_par_cnt           -- 今日个人妥投量
,wk.norm_fns_par_cnt           -- 正常件妥投量
,wk.first_fns_time -- 首次妥投时间
,wk.last_fns_par_time   -- 末次妥投时间
,wk.pickup_task_cnt   -- 揽收任务数
,wk.pickup_par_cnt     --  揽收单量

,wk.first_pickup_time -- 首次揽件时间
,wk.last_pickup_time -- 末次揽件时间

,coalesce(wk.pickup_par_cnt,0)+coalesce(wk.fns_par_cnt,0) as pick_fns_cnt -- 揽派量
,sup.store_id as supply_store_id -- 支援网点ID
,sup.store_name as supply_store_name -- 支援网点名称
,sup.employment_begin_date -- 支援计划开始日期
,sup.employment_end_date   -- 支援计划结束日期
,sup.actual_begin_date  -- 支援实际开始日期
,sup.actual_end_date    -- 支援实际结束日期

,case when hi.`is_sub_staff` =1 and sup.store_id is not null then '支援' else '非支援' end as plan_work_status -- 实际工作状态
,case when hi.`is_sub_staff` =1 and sup.store_id is not null then sup.store_name else wk.name end as plan_work_store -- 实际工作网点

,case when (ad.attendance_started_at is not null or ad.attendance_end_at is not null   or wk.pickup_par_cnt>0 or wk.fns_par_cnt>0 or handover_par_cnt>0) then '是' else '否' end as is_att -- 是否出勤

,case when hi.is_sub_staff =1 and ps.store_id is not null then '支援' else '非支援' end as pl_work_status -- 计划工作状态
,case when hi.is_sub_staff =1 and ps.store_id is not null then ps.store_name else wk.name end as pl_work_store -- 计划工作网点
,ps.store_id as pl_supply_store_id -- 计划支援网点ID
,ps.store_name as pl_supply_store_name -- 计划支援网点名称


,if(hi.`job_title` in (13,110,452) ,'是','否') as is_delivery -- 是否快递员
from `fle_staging`.`staff_info` hi
inner join `bi_pro`.`hr_staff_info` hs
on hi.id=hs.staff_info_id
LEFT JOIN `fle_staging`.`sys_store` ss
on hi.organization_id=ss.`id`
LEFT JOIN  (select *,row_number() over(partition by staff_info_id order by attendance_started_at) as rn
            from (#今日出勤
                  select wd.`staff_info_id` ,
                  started_store_id as attendance_store_id,
                  ss.`name` as attendance_store_name,
                  convert_tz(wd.`started_at`,'+00:00','+08:00') as attendance_started_at,  -- 上班打卡时间,
                  convert_tz(wd.`end_at`,'+00:00','+08:00')     as attendance_end_at,  -- 下班打卡时间,
                  round(timestampdiff(second,convert_tz(wd.`started_at`,'+00:00','+08:00'),convert_tz(wd.`end_at`,'+00:00','+08:00')) / 3600,2) as attendance_hour -- 打卡时长
                  from backyard_pro.staff_work_attendance wd
                  LEFT JOIN `fle_staging`.`sys_store` ss
                  on ss.`id` =wd.`started_store_id`
                  where wd.`attendance_date`>=date_sub( CURRENT_DATE() , INTERVAL 7 HOUR )
                  union all
                  select bt.`staff_info_id` ,
                  '' as attendance_store_id,
                  '' as attendance_store_name,
                  convert_tz(`start_time`,'+00:00','+08:00') as attendance_started_at,  -- 上班打卡时间,
                  convert_tz(`end_time`,'+00:00','+08:00')     as attendance_end_at,  -- 下班打卡时间,
                  round(timestampdiff(second,convert_tz(`start_time`,'+00:00','+08:00'),convert_tz(`end_time`,'+00:00','+08:00')) / 3600,2) as attendance_hour -- 打卡时长
                  from `backyard_pro`.`staff_audit_reissue_for_business`  bt
                  where  bt.`attendance_date`>=date_sub( CURRENT_DATE() , INTERVAL 7 HOUR )
                  and bt.`status` <3
                  )t
            ) ad
on hi.id=ad.`staff_info_id`
and ad.rn=1
left join (select staff_info_id
           ,store_id AS work_store_id
           ,ss.name
           ,max(handover_par_cnt) as handover_par_cnt   -- 今日个人交接量
           ,max(pickup_task_cnt) as pickup_task_cnt     -- 揽收任务数
           ,max(pickup_par_cnt) as pickup_par_cnt       --  揽收单量
           ,max(first_pickup_time) AS first_pickup_time -- 首次揽件时间
           ,max(last_pickup_time) AS last_pickup_time   -- 末次揽件时间
           ,max(delivery_par_cnt) as fns_par_cnt             -- 妥投量

           ,max(delivery_par_cnt_not_returned) as norm_fns_par_cnt     -- 正常件妥投量
           ,max(first_delivery_par_time) AS first_fns_time -- 首次妥投时间
           ,max(last_delivery_par_time) AS last_fns_par_time   -- 末次妥投时间
           from (
                 -- 揽收包裹数
                 SELECT
                     pi2.ticket_pickup_store_id as store_id,
                     pi2.ticket_pickup_staff_info_id as staff_info_id,
                     count(DISTINCT pi2.pno) as pickup_par_cnt,
                     0 as pickup_task_cnt,
                     MIN(date_add(pi2.created_at, INTERVAL 7 HOUR)) AS 'first_pickup_time',
                     MAX(date_add(pi2.created_at, INTERVAL 7 HOUR)) AS 'last_pickup_time',
                     0 as delivery_par_cnt,
                     0 as delivery_par_cnt_not_returned,
                     0 as handover_par_cnt,
                     NULL as first_delivery_par_time,
                     NULL as last_delivery_par_time

                 from
                     fle_staging.parcel_info pi2
                 WHERE
                     pi2.state != 9
                     AND pi2.returned = 0
                     AND pi2.created_at >= date_sub( CURRENT_DATE() , INTERVAL 7 HOUR )
                 GROUP BY
                     pi2.ticket_pickup_store_id ,
                     pi2.ticket_pickup_staff_info_id

                 UNION ALL
                 -- 揽收任务数
                 SELECT
                     tp.store_id,
                     tp.staff_info_id ,
                     0 as pickup_par_cnt,
                      COUNT(DISTINCT tp.id) as pickup_task_cnt ,
                     NULL AS 'first_pickup_time',
                     NULL AS 'last_pickup_time',
                     0 as delivery_par_cnt,
                     0 as delivery_par_cnt_not_returned,
                     0 as handover_par_cnt,
                     NULL as first_delivery_par_time,
                     NULL as last_delivery_par_time

                 FROM
                     fle_staging.ticket_pickup tp
                 WHERE tp.finished_at  >= date_sub( CURRENT_DATE() , INTERVAL 7 HOUR )
                 and tp.state  = 2
                 GROUP BY
                     tp.store_id,
                     tp.staff_info_id

                 UNION ALL
                 -- 派送包裹数
                 SELECT
                     pi2.ticket_delivery_store_id as store_id,
                     pi2.ticket_delivery_staff_info_id  as staff_info_id,
                     0 as pickup_par_cnt,
                     0 as pickup_task_cnt,
                     NULL as first_pickup_time,
                     NULL as last_pickup_time,
                     count(DISTINCT pi2.pno) as delivery_par_cnt,
                     count(DISTINCT IF(pi2.returned = 0 ,pi2.pno, NULL)) as delivery_par_cnt_not_returned,
                     0 as handover_par_cnt,
                     MIN(date_add(pi2.finished_at, INTERVAL 7 HOUR)) AS 'first_delivery_par_time',
                     MAX(date_add(pi2.finished_at, INTERVAL 7 HOUR)) AS 'last_delivery_par_time'
                 from
                     fle_staging.parcel_info pi2
                 WHERE
                     pi2.state = 5
                     AND pi2.finished_at >= date_sub( CURRENT_DATE() , INTERVAL 7 HOUR )
                 GROUP BY
                     pi2.ticket_delivery_store_id ,
                     pi2.ticket_delivery_staff_info_id
                 UNION ALL

                 -- 有效交接包裹数
                 SELECT `store_id` ,
                      `staff_info_id`,
                      0 as pickup_par_cnt,
                      0 as pickup_task_cnt,
                      NULL as first_pickup_time,
                      NULL as last_pickup_time,
                      0 as delivery_par_cnt,
                      0 as delivery_par_cnt_not_returned,
                      COUNT(DISTINCT pno) AS handover_par_cnt,
                      NULL as first_delivery_par_time,
                      NULL as last_delivery_par_time
                 FROM (
                       SELECT `store_id`, `staff_info_id`, pno, id AS ticket_delivery_id, row_number() OVER (PARTITION BY pno ORDER BY created_at DESC) AS rn
                       FROM `fle_staging`.`ticket_delivery`
                       WHERE `created_at` >= date_sub(CURRENT_DATE(), INTERVAL 7 HOUR)
                      ) t
                 WHERE rn = 1
                 GROUP BY `store_id`
                     , `staff_info_id`
                )t1
           LEFT JOIN `fle_staging`.`sys_store` ss
           on t1.store_id=ss.`id`
           GROUP BY 1,2,3
           ) wk
on hi.id=wk.staff_info_id
left join (select  t1.id as master_staff
           ,t1.organization_id as master_store_id
           ,t1.hire_date as master_hire_date
           ,t2.name as master_store_name
           from `fle_staging`.`staff_info`  t1
           left join `fle_staging`.`sys_store` t2
           on t1.organization_id=t2.id
           where t1.is_sub_staff =0
           group by 1,2,3
           )mas
on coalesce(hi.master_staff,hi.id)=mas.master_staff

left join (select staff_info_id,sub_staff_info_id,employment_begin_date,employment_end_date,store_id,store_name,actual_begin_date,actual_end_date
           from `backyard_pro`.hr_staff_apply_support_store
           where support_status in(2,3)
           and sub_staff_info_id>0
           and date(created_at)>='2022-06-02' -- 上线日期
           and CURRENT_DATE between actual_begin_date and coalesce(actual_end_date,'2099-12-31')
           )sup
on hi.id = sup.sub_staff_info_id

left join (select staff_info_id,sub_staff_info_id,employment_begin_date,employment_end_date,store_id,store_name,actual_begin_date,actual_end_date
           from backyard_pro.hr_staff_apply_support_store
           where support_status in(2,3)
           and sub_staff_info_id>0
           and date(created_at)>='2022-06-02' -- 上线日期
           and CURRENT_DATE between employment_begin_date and employment_end_date
           )ps
on hi.id = ps.sub_staff_info_id

left join bi_pro.hr_job_title jb
on hi.job_title=jb.id
where hi.state=1

