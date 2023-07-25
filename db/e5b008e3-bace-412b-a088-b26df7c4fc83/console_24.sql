/*=====================================================================+
表名称：dwm_ph_network_wide_s
功能描述：网点日宽表
需求来源: PH基础数据建设
编写人员: 张桥
设计日期: 2023-03-08
调度规则：依赖上游
生命周期：保留最近365天数据
数据回刷：
修改日期:
修改人员:
修改原因:
-----------------------------------------------------------------------
drop table if exists dwm.dwm_ph_network_wide_s;
create table dwm.dwm_ph_network_wide_s (
 stat_date varchar comment '统计日期',
 store_id varchar comment '网点id',
 store_name varchar  comment '网点名称',
 store_category varchar COMMENT '网点类型ID',
 store_category_desc varchar comment '网点类型描述',
 region_name varchar comment '大区',
 piece_name varchar comment '片区',
 area_name varchar comment '归属区域',

 province_code varchar COMMENT '省份编码',
 province_name varchar COMMENT '省份名称',
 city_code varchar COMMENT '城市编码',
 city_name varchar COMMENT '城市名称',
 opening_at date COMMENT '开业日期',
 sorting_no varchar COMMENT '分拣区编号',
 state_desc varchar COMMENT '网点状态 1:激活, 2:未激活',
 ancestry varchar COMMENT '父ID链',
 par_store_id varchar COMMENT '上级网点ID',
 par_store_name varchar COMMENT '上级网点名称',
 par_store_category varchar COMMENT '上级网点类型ID',
 par_store_type varchar COMMENT '上级网点类型',
 par_par_store_id varchar COMMENT '上上级网点ID',
 par_par_store_name varchar COMMENT '上上级网点名称',
 par_par_store_category varchar COMMENT '上上级网点类型ID',
 par_par_store_type varchar COMMENT '上上级网点类型',
 delivery_frequency varchar COMMENT '网点派件频次',
 lazada_area_name varchar COMMENT '归属区域[lazada]',
 shopee_area_name varchar COMMENT '归属区域[shopee]',
 tiktok_pickup_area_name varchar COMMENT '归属区域[tiktok揽件]',
 tiktok_delivery_area_name varchar COMMENT '归属区域[tiktok派件]',

 on_emp_cnt bigint  comment '在职员工',
 in_emp_cnt bigint  comment '入职员工',
 out_emp_cnt bigint  comment '离职员工',
 hc_appr_emp_cnt bigint  comment 'hc审批中人数',
 hc_demandnumber bigint  comment 'hc总需求人数',
 hc_surplusnumber bigint  comment '招聘中人数',
 offer_emp_cnt bigint  comment '已发offer数量',
 wait_in_emp_cnt bigint  comment '待入职数量',
 atd_emp_cnt bigint  comment '出勤人数',
 pb_emp_cnt bigint  comment '排休人数',

 on_dc_cnt bigint  comment 'dc在职员工',
 in_dc_cnt bigint  comment 'dc入职员工',
 out_dc_cnt bigint  comment 'dc离职员工',
 offer_dc_cnt bigint  comment 'dc已发offer数量',
 wait_in_dc_cnt bigint  comment 'dc待入职数量',
 atd_dc_cnt bigint  comment 'dc出勤人数',
 pb_dc_cnt bigint  comment 'dc排休人数',

 pickup_staff_cnt bigint  comment '揽收人数',
 self_pickup_staff_cnt bigint  comment '自有揽收人数',
 support_pickup_staff_cnt bigint  comment '支援揽收人数',
 unself_pickup_staff_cnt bigint  comment '外协揽收人数',
 pickup_par_cnt bigint  comment '揽收单量',
 self_pickup_par_cnt bigint  comment '自有揽收单量',
 support_pickup_par_cnt bigint  comment '支援揽收单量',
 unself_pickup_par_cnt bigint  comment '外协揽收单量',
 pickup_big_par_cnt bigint  comment '揽收大件量',
 pickup_sma_par_cnt bigint  comment '揽收小件量',
 pickup_hour double  comment '揽件时长',
 pickup_eff double  comment '揽件人效',
 self_pickup_eff double  comment '自有揽件人效',
 support_pickup_eff double  comment '支援揽件人效',
 unself_pickup_eff double  comment '外协揽件人效',


 handover_staff_cnt bigint  comment '交接人数',
 self_handover_staff_cnt bigint  comment '自有交接人数',
 support_handover_staff_cnt bigint  comment '支援交接人数',
 unself_handover_staff_cnt bigint  comment '外协交接人数',
 handover_par_cnt bigint  comment '交接单量',
 self_handover_par_cnt bigint  comment '自有交接单量',
 support_handover_par_cnt bigint  comment '支援交接单量',
 unself_handover_par_cnt bigint  comment '外协交接单量',
 handover_big_par_cnt bigint  comment '交接大件量',
 handover_sma_par_cnt bigint  comment '交接小件量',
 handover_hour double  comment '交接时长',
 handover_eff double  comment '交接人效',
 self_handover_eff double  comment '自有交接人效',
 support_handover_eff double  comment '支援交接人效',
 unself_handover_eff double  comment '外协交接人效',

 delivery_staff_cnt bigint  comment '妥投人数',
 self_delivery_staff_cnt bigint  comment '自有妥投人数',
 support_delivery_staff_cnt bigint  comment '支援妥投人数',
 unself_delivery_staff_cnt bigint  comment '外协妥投人数',
 delivery_par_cnt bigint  comment '妥投单量',
 self_delivery_par_cnt bigint  comment '自有妥投单量',
 support_delivery_par_cnt bigint  comment '支援妥投单量',
 unself_delivery_par_cnt bigint  comment '外协妥投单量',
 delivery_big_par_cnt bigint  comment '妥投大件量',
 delivery_sma_par_cnt bigint  comment '妥投小件量',
 delivery_hour double  comment '妥投时长',
 delivery_hour2 double  comment '妥投时长(计算口径 第二件)',
 delivery_eff double  comment '妥投人效',
 self_delivery_eff double  comment '自有妥投人效',
 support_delivery_eff double  comment '支援妥投人效',
 unself_delivery_eff double  comment '外协妥投人效',
 delivery_ret_par_cnt bigint  comment '退件妥投单量',

 shl_delivery_par_cnt bigint  comment '应派包裹数',
 shl_delivery_handover_par_cnt bigint  comment '应派已交接包裹数',
 shl_delivery_delivery_par_cnt bigint  comment '应派已妥投包裹数',
 shl_delivery_undelivery_par_cnt bigint  comment '应派未妥投包裹数',
 handover_rate double  comment '交接率',
 delivery_rate double  comment '妥投率',

 lazada_shl_delivery_par_cnt            bigint  comment 'lazada应派包裹数',
 lazada_shl_delivery_handover_par_cnt   bigint  comment 'lazada应派已交接包裹数',
 lazada_shl_delivery_delivery_par_cnt   bigint  comment 'lazada应派已妥投包裹数',
 lazada_shl_delivery_undelivery_par_cnt bigint  comment 'lazada应派未妥投包裹数',
 lazada_handover_rate                   double  comment 'lazada交接率',
 lazada_delivery_rate                   double  comment 'lazada妥投率',

 shopee_shl_delivery_par_cnt            bigint  comment 'shopee应派包裹数',
 shopee_shl_delivery_handover_par_cnt   bigint  comment 'shopee应派已交接包裹数',
 shopee_shl_delivery_delivery_par_cnt   bigint  comment 'shopee应派已妥投包裹数',
 shopee_shl_delivery_undelivery_par_cnt bigint  comment 'shopee应派未妥投包裹数',
 shopee_handover_rate                   double  comment 'shopee交接率',
 shopee_delivery_rate                   double  comment 'shopee妥投率',

 tiktok_shl_delivery_par_cnt            bigint  comment 'tiktok应派包裹数',
 tiktok_shl_delivery_handover_par_cnt   bigint  comment 'tiktok应派已交接包裹数',
 tiktok_shl_delivery_delivery_par_cnt   bigint  comment 'tiktok应派已妥投包裹数',
 tiktok_shl_delivery_undelivery_par_cnt bigint  comment 'tiktok应派未妥投包裹数',
 tiktok_handover_rate                   double  comment 'tiktok交接率',
 tiktok_delivery_rate                   double  comment 'tiktok妥投率',

 pre_on_warehouse_par_cnt bigint  comment '昨日在仓包裹数',
 on_warehouse_par_cnt bigint  comment '在仓包裹数',
 on_warehouse_cod_par_cnt bigint  comment '在仓COD包裹数',
 on_warehouse_big_par_cnt bigint  comment '在仓大件包裹数',
 on_warehouse_3days_par_cnt bigint  comment '在仓3天及以上包裹数',
 lazada_on_warehouse_cod_par_cnt bigint  comment 'lazada在仓包裹数',
 shopee_on_warehouse_cod_par_cnt bigint  comment 'shopee在仓包裹数',
 tiktok_on_warehouse_cod_par_cnt bigint  comment 'tiktok在仓包裹数',

 pre_on_way_par_cnt bigint  comment '昨日在途包裹数',
 on_way_par_cnt bigint  comment '在途包裹数',
 on_way_cod_par_cnt bigint  comment '在途COD包裹数',
 on_way_big_par_cnt bigint  comment '在途大件包裹数',
 lazada_on_way_cod_par_cnt bigint  comment 'lazada在途包裹数',
 shopee_on_way_cod_par_cnt bigint  comment 'shopee在途包裹数',
 tiktok_on_way_cod_par_cnt bigint  comment 'tiktok在途包裹数',

 inbound_par_cnt bigint  comment '进港包裹数',
 pk_task_cnt bigint  comment '揽收任务数',
 pk_par_cnt bigint  comment '揽收包裹数',
 pk_send_par_cnt bigint  comment '揽收及时发出包裹数',
 pk_send_par_rate double  comment '揽收发出及时率',

 plt_should_pickup_cnt            bigint  comment '平台客户应揽收包裹数',
 plt_pickup_cnt                   bigint  comment '平台客户已揽收包裹数',
 lazada_should_pickup_cnt         bigint  comment 'lazada应揽收包裹数',
 lazada_pickup_cnt                bigint  comment 'lazada已揽收包裹数',
 shopee_should_pickup_cnt         bigint  comment 'shopee应揽收包裹数',
 shopee_pickup_cnt                bigint  comment 'shopee已揽收包裹数',
 tiktok_should_pickup_cnt         bigint  comment 'tiktok应揽收包裹数',
 tiktok_pickup_cnt                bigint  comment 'tiktok已揽收包裹数',
 unplt_should_pickup_cnt          bigint  comment '非平台客户应揽收任务数',
 unplt_pickup_cnt                 bigint  comment '非平台客户已揽收任务数',
 plt_pickup_rate                  double  comment '平台客户揽收完成率',
 lazada_pickup_rate               double  comment 'lazada揽收完成率',
 shopee_pickup_rate               double  comment 'shopee揽收完成率',
 tiktok_pickup_rate               double  comment 'tiktok揽收完成率',
 unplt_pickup_rate                double  comment '非平台客户揽收完成率',

  -- 近30日日均和ma7
 avg_pickup_eff              double  comment '日均揽收人效',
 ma7_pickup_eff              double  comment 'ma7揽收人效',
 avg_self_pickup_eff         double  comment '日均自有揽收人效',
 ma7_self_pickup_eff         double  comment 'ma7自有揽收人效',
 avg_unself_pickup_eff       double  comment '日均外协揽收人效',
 ma7_unself_pickup_eff       double  comment 'ma7外协揽收人效',

 avg_handover_eff            double  comment '日均交接人效',
 ma7_handover_eff            double  comment 'ma7交接人效',
 avg_self_handover_eff       double  comment '日均自有交接人效',
 ma7_self_handover_eff       double  comment 'ma7自有交接人效',
 avg_unself_handover_eff     double  comment '日均外协交接人效',
 ma7_unself_handover_eff     double  comment 'ma7外协交接人效',

 avg_delivery_eff            double  comment '日均妥投人效',
 ma7_delivery_eff            double  comment 'ma7妥投人效',
 avg_self_delivery_eff       double  comment '日均自有妥投人效',
 ma7_self_delivery_eff       double  comment 'ma7自有妥投人效',
 avg_unself_delivery_eff     double  comment '日均外协妥投人效',
 ma7_unself_delivery_eff     double  comment 'ma7外协妥投人效',

 update_time datetime comment '数据更新时间',
 primary key (stat_date,store_id)
)distributed by hash(stat_date,store_id)
partition by value(date_format(stat_date, '%Y%m%d')) lifecycle 365
comment 'ph-网点日宽表';
-----------------------------------------------------------------------
+=====================================================================*/


insert overwrite into  dwm.dwm_ph_network_wide_s
select
ds.stat_date         -- as 日期
,ds.store_id         -- as 网点id
,ds.store_name       -- as 网点名称
,ds.store_category
,ds.store_type       -- as 网点类型
,ds.region_name      -- as 大区
,ds.piece_name       -- as 片区
,ds.belong_area_name -- as 归属区域

,ds.province_code -- '省份编码',
,ds.province_name -- '省份名称',
,ds.city_code -- '城市编码',
,ds.city_name -- '城市名称',
,ds.opening_at -- '开业日期',
,ds.sorting_no -- '分拣区编号',
,ds.state_desc -- '网点状态 1:激活, 2:未激活',
,ds.ancestry -- '父ID链',
,ds.par_store_id -- '上级网点ID',
,ds.par_store_name -- '上级网点名称',
,ds.par_store_category -- '上级网点类型ID',
,ds.par_store_type -- '上级网点类型',
,ds.par_par_store_id -- '上上级网点ID',
,ds.par_par_store_name -- '上上级网点名称',
,ds.par_par_store_category -- '上上级网点类型ID',
,ds.par_par_store_type -- '上上级网点类型',
,ds.delivery_frequency -- '网点派件频次',
,ds.lazada_area_name -- '归属区域[lazada]',
,ds.shopee_area_name -- '归属区域[shopee]',
,ds.tiktok_pickup_area_name -- '归属区域[tiktok揽件]',
,ds.tiktok_delivery_area_name -- '归属区域[tiktok派件]',

-- 快递员
,coalesce(emp.on_emp_cnt,0) as on_emp_cnt -- 在职员工
,coalesce(emp.in_emp_cnt,0) as in_emp_cnt -- 入职员工
,coalesce(emp.out_emp_cnt,0) as out_emp_cnt -- 离职员工
,coalesce(emp.hc_appr_emp_cnt,0) as hc_appr_emp_cnt -- hc审批中人数
,coalesce(emp.hc_demandnumber,0) as hc_demandnumber -- hc总需求人数
,coalesce(emp.hc_surplusnumber,0) as hc_surplusnumber -- 招聘中人数
,coalesce(emp.offer_emp_cnt,0) as offer_emp_cnt -- 已发offer数量
,coalesce(emp.wait_in_emp_cnt,0) as wait_in_emp_cnt -- 待入职数量
,coalesce(emp.atd_emp_cnt,0) as atd_emp_cnt -- 出勤人数
,coalesce(emp.pb_emp_cnt,0) as pb_emp_cnt -- 排休人数

-- dc
,coalesce(dc.on_emp_cnt,0) as on_emp_cnt -- 在职员工
,coalesce(dc.in_emp_cnt,0) as in_emp_cnt -- 入职员工
,coalesce(dc.out_emp_cnt,0) as out_emp_cnt -- 离职员工
,coalesce(dc.offer_emp_cnt,0) as offer_emp_cnt -- 已发offer数量
,coalesce(dc.wait_in_emp_cnt,0) as wait_in_emp_cnt -- 待入职数量
,coalesce(dc.atd_emp_cnt,0) as atd_emp_cnt -- 出勤人数
,coalesce(dc.pb_emp_cnt,0) as pb_emp_cnt -- 排休人数

-- 揽收
,coalesce(par.pickup_staff_cnt,0) as pickup_staff_cnt -- 揽收人数
,coalesce(par.self_pickup_staff_cnt,0) as self_pickup_staff_cnt -- 自有揽收人数
,coalesce(par.support_pickup_staff_cnt,0) as support_pickup_staff_cnt -- 支援揽收人数
,coalesce(par.unself_pickup_staff_cnt,0) as unself_pickup_staff_cnt -- 外协揽收人数
,coalesce(par.pickup_par_cnt,0) as pickup_par_cnt -- 揽收单量
,coalesce(par.self_pickup_par_cnt,0) as self_pickup_par_cnt -- 自有揽收单量
,coalesce(par.support_pickup_par_cnt,0) as support_pickup_par_cnt -- 支援揽收单量
,coalesce(par.unself_pickup_par_cnt,0) as unself_pickup_par_cnt -- 外协揽收单量
,coalesce(par.pickup_big_par_cnt,0) as pickup_big_par_cnt -- 揽收大件量
,coalesce(par.pickup_sma_par_cnt,0) as pickup_sma_par_cnt -- 揽收小件量
,coalesce(par.pickup_hour,0) as pickup_hour -- 揽件时长
,coalesce(if(par.pickup_staff_cnt=0,0,round(par.pickup_par_cnt/par.pickup_staff_cnt,2)),0) as pickup_eff -- 揽件人效
,coalesce(if(par.self_pickup_staff_cnt=0,0,round(par.self_pickup_par_cnt/par.self_pickup_staff_cnt,2)),0) as self_pickup_eff -- 自有揽件人效
,coalesce(if(par.support_pickup_staff_cnt=0,0,round(par.support_pickup_par_cnt/par.support_pickup_staff_cnt,2)),0) as self_pickup_eff -- 支援揽件人效
,coalesce(if(par.unself_pickup_staff_cnt=0,0,round(par.unself_pickup_par_cnt/par.unself_pickup_staff_cnt,2)),0) as unself_pickup_eff -- 外协揽件人效

-- 交接
,coalesce(par.handover_staff_cnt,0) as handover_staff_cnt -- 交接人数
,coalesce(par.self_handover_staff_cnt,0) as self_handover_staff_cnt -- 自有交接人数
,coalesce(par.support_handover_staff_cnt,0) as support_handover_staff_cnt -- 支援交接人数
,coalesce(par.unself_handover_staff_cnt,0) as unself_handover_staff_cnt -- 外协交接人数
,coalesce(par.handover_par_cnt,0) as handover_par_cnt -- 交接单量
,coalesce(par.self_handover_par_cnt,0) as self_handover_par_cnt -- 自有交接单量
,coalesce(par.support_handover_par_cnt,0) as support_handover_par_cnt -- 支援交接单量
,coalesce(par.unself_handover_par_cnt,0) as unself_handover_par_cnt -- 外协交接单量
,coalesce(par.handover_big_par_cnt,0) as handover_big_par_cnt -- 交接大件量
,coalesce(par.handover_sma_par_cnt,0) as handover_sma_par_cnt -- 交接小件量
,coalesce(par.handover_hour,0) as handover_hour -- 交接时长
,coalesce(if(handover_staff_cnt=0,0,round(par.handover_par_cnt/par.handover_staff_cnt,2)),0) as handover_eff -- 交接人效
,coalesce(if(self_handover_staff_cnt=0,0,round(par.self_handover_par_cnt/par.self_handover_staff_cnt,2)),0) as self_handover_eff -- 自有交接人效
,coalesce(if(support_handover_staff_cnt=0,0,round(par.support_handover_par_cnt/par.support_handover_staff_cnt,2)),0) as support_handover_eff -- 支援交接人效
,coalesce(if(unself_handover_staff_cnt=0,0,round(par.unself_handover_par_cnt/par.unself_handover_staff_cnt,2)),0) as unself_handover_eff -- 外协交接人效

-- 妥投
,coalesce(par.delivery_staff_cnt,0) as delivery_staff_cnt -- 妥投人数
,coalesce(par.self_delivery_staff_cnt,0) as self_delivery_staff_cnt -- 自有妥投人数
,coalesce(par.support_delivery_staff_cnt,0) as support_delivery_staff_cnt -- 支援妥投人数
,coalesce(par.unself_delivery_staff_cnt,0) as unself_delivery_staff_cnt -- 外协妥投人数
,coalesce(par.delivery_par_cnt,0) as delivery_par_cnt -- 妥投单量
,coalesce(par.self_delivery_par_cnt,0) as self_delivery_par_cnt -- 自有妥投单量
,coalesce(par.support_delivery_par_cnt,0) as support_delivery_par_cnt -- 支援妥投单量
,coalesce(par.unself_delivery_par_cnt,0) as unself_delivery_par_cnt -- 外协妥投单量
,coalesce(par.delivery_big_par_cnt,0) as delivery_big_par_cnt -- 妥投大件量
,coalesce(par.delivery_sma_par_cnt,0) as delivery_sma_par_cnt -- 妥投小件量
,coalesce(par.delivery_hour,0) as delivery_hour -- 妥投时长
,coalesce(par.delivery_hour2,0) as delivery_hour2 -- 妥投时长
,coalesce(if(par.delivery_staff_cnt=0,0,round(par.delivery_par_cnt/par.delivery_staff_cnt,2)),0) as delivery_eff -- 妥投人效
,coalesce(if(par.self_delivery_staff_cnt=0,0,round(par.self_delivery_par_cnt/par.self_delivery_staff_cnt,2)),0) as self_delivery_eff -- 自有妥投人效
,coalesce(if(par.support_delivery_staff_cnt=0,0,round(par.support_delivery_par_cnt/par.support_delivery_staff_cnt,2)),0) as self_delivery_eff -- 支援妥投人效
,coalesce(if(par.unself_delivery_staff_cnt=0,0,round(par.unself_delivery_par_cnt/par.unself_delivery_staff_cnt,2)),0) as unself_delivery_eff -- 外协妥投人效
,coalesce(par.delivery_ret_par_cnt,0) as delivery_ret_par_cnt -- 退件妥投单量

-- 应派
,coalesce(sdd.shl_delivery_par_cnt,0) as shl_delivery_par_cnt -- 应派包裹数
,coalesce(sdd.shl_delivery_handover_par_cnt,0) as shl_delivery_handover_par_cnt -- 应派已交接包裹数
,coalesce(sdd.shl_delivery_delivery_par_cnt,0) as shl_delivery_delivery_par_cnt -- 应派已妥投包裹数
,coalesce(sdd.shl_delivery_undelivery_par_cnt,0) as shl_delivery_undelivery_par_cnt -- 应派未妥投包裹数
,coalesce(if(sdd.shl_delivery_par_cnt=0,0,round(sdd.shl_delivery_handover_par_cnt/sdd.shl_delivery_par_cnt,2)),0) as handover_rate -- 交接率
,coalesce(if(sdd.shl_delivery_par_cnt=0,0,round(sdd.shl_delivery_delivery_par_cnt/sdd.shl_delivery_par_cnt,2)),0) as delivery_rate -- 妥投率

,coalesce(sdd.lazada_shl_delivery_par_cnt,0)            as lazada_shl_delivery_par_cnt -- 应派包裹数
,coalesce(sdd.lazada_shl_delivery_handover_par_cnt,0)   as lazada_shl_delivery_handover_par_cnt -- 应派已交接包裹数
,coalesce(sdd.lazada_shl_delivery_delivery_par_cnt,0)   as lazada_shl_delivery_delivery_par_cnt -- 应派已妥投包裹数
,coalesce(sdd.lazada_shl_delivery_undelivery_par_cnt,0) as lazada_shl_delivery_undelivery_par_cnt -- 应派未妥投包裹数
,coalesce(if(sdd.lazada_shl_delivery_par_cnt=0,0,round(sdd.lazada_shl_delivery_handover_par_cnt/sdd.lazada_shl_delivery_par_cnt,2)),0) as lazada_handover_rate -- 交接率
,coalesce(if(sdd.lazada_shl_delivery_par_cnt=0,0,round(sdd.lazada_shl_delivery_delivery_par_cnt/sdd.lazada_shl_delivery_par_cnt,2)),0) as lazada_delivery_rate -- 妥投率

,coalesce(sdd.shopee_shl_delivery_par_cnt,0)            as shopee_shl_delivery_par_cnt -- 应派包裹数
,coalesce(sdd.shopee_shl_delivery_handover_par_cnt,0)   as shopee_shl_delivery_handover_par_cnt -- 应派已交接包裹数
,coalesce(sdd.shopee_shl_delivery_delivery_par_cnt,0)   as shopee_shl_delivery_delivery_par_cnt -- 应派已妥投包裹数
,coalesce(sdd.shopee_shl_delivery_undelivery_par_cnt,0) as shopee_shl_delivery_undelivery_par_cnt -- 应派未妥投包裹数
,coalesce(if(sdd.shopee_shl_delivery_par_cnt=0,0,round(sdd.shopee_shl_delivery_handover_par_cnt/sdd.shopee_shl_delivery_par_cnt,2)),0) as shopee_handover_rate -- 交接率
,coalesce(if(sdd.shopee_shl_delivery_par_cnt=0,0,round(sdd.shopee_shl_delivery_delivery_par_cnt/sdd.shopee_shl_delivery_par_cnt,2)),0) as shopee_delivery_rate -- 妥投率

,coalesce(sdd.tiktok_shl_delivery_par_cnt,0)            as tiktok_shl_delivery_par_cnt -- 应派包裹数
,coalesce(sdd.tiktok_shl_delivery_handover_par_cnt,0)   as tiktok_shl_delivery_handover_par_cnt -- 应派已交接包裹数
,coalesce(sdd.tiktok_shl_delivery_delivery_par_cnt,0)   as tiktok_shl_delivery_delivery_par_cnt -- 应派已妥投包裹数
,coalesce(sdd.tiktok_shl_delivery_undelivery_par_cnt,0) as tiktok_shl_delivery_undelivery_par_cnt -- 应派未妥投包裹数
,coalesce(if(sdd.tiktok_shl_delivery_par_cnt=0,0,round(sdd.tiktok_shl_delivery_handover_par_cnt/sdd.tiktok_shl_delivery_par_cnt,2)),0) as tiktok_handover_rate -- 交接率
,coalesce(if(sdd.tiktok_shl_delivery_par_cnt=0,0,round(sdd.tiktok_shl_delivery_delivery_par_cnt/sdd.tiktok_shl_delivery_par_cnt,2)),0) as tiktok_delivery_rate -- 妥投率

-- 在仓
,coalesce(owp.pre_on_warehouse_par_cnt,0) as pre_on_warehouse_par_cnt -- 昨日在仓包裹数
,coalesce(ow.on_warehouse_par_cnt,0) as on_warehouse_par_cnt -- 在仓包裹数
,coalesce(ow.on_warehouse_cod_par_cnt,0) as on_warehouse_cod_par_cnt -- 在仓COD包裹数
,coalesce(ow.on_warehouse_big_par_cnt,0) as on_warehouse_big_par_cnt -- 在仓大件包裹数
,coalesce(ow.on_warehouse_3days_par_cnt,0) as on_warehouse_3days_par_cnt -- 在仓3天及以上包裹数
,coalesce(ow.lazada_on_warehouse_cod_par_cnt,0) as lazada_on_warehouse_cod_par_cnt -- lazada在仓包裹数
,coalesce(ow.shopee_on_warehouse_cod_par_cnt,0) as shopee_on_warehouse_cod_par_cnt -- shopee在仓包裹数
,coalesce(ow.tiktok_on_warehouse_cod_par_cnt,0) as tiktok_on_warehouse_cod_par_cnt -- tiktok在仓包裹数

-- 在途
,coalesce(owp.pre_on_way_par_cnt,0) as pre_on_way_par_cnt -- 昨日在途包裹数
,coalesce(ow.on_way_par_cnt,0) as on_way_par_cnt -- 在途包裹数
,coalesce(ow.on_way_cod_par_cnt,0) as on_way_cod_par_cnt -- 在途COD包裹数
,coalesce(ow.on_way_big_par_cnt,0) as on_way_big_par_cnt -- 在途大件包裹数
,coalesce(ow.lazada_on_way_cod_par_cnt,0) as lazada_on_way_cod_par_cnt -- lazada在途包裹数
,coalesce(ow.shopee_on_way_cod_par_cnt,0) as shopee_on_way_cod_par_cnt -- shopee在途包裹数
,coalesce(ow.tiktok_on_way_cod_par_cnt,0) as tiktok_on_way_cod_par_cnt -- tiktok在途包裹数

-- 路由 进港
,coalesce(ib.inbound_par_cnt,0) as inbound_par_cnt -- 进港包裹数

-- 揽收发出
,coalesce(ps.pk_task_cnt,0) as pk_par_cnt #揽收任务量
,coalesce(ps.pickup_par_cnt,0) as pk_par_cnt #揽收单量
,coalesce(ps.pickup_send_par_cnt,0) as pickup_send_par_cnt #当天揽收发出单量
,coalesce(if(ps.pickup_par_cnt=0,0,round(ps.pickup_send_par_cnt/ps.pickup_par_cnt,2)),0) as pickup_send_par_rate #当天揽收发出率

-- 应揽收
,coalesce(plt_should_pickup_cnt     ,0) as plt_should_pickup_cnt           -- 平台客户应揽收包裹数
,coalesce(plt_pickup_cnt            ,0) as plt_pickup_cnt                 -- 平台客户已揽收包裹数
,coalesce(lazada_should_pickup_cnt  ,0) as lazada_should_pickup_cnt       -- lazada应揽收包裹数
,coalesce(lazada_pickup_cnt         ,0) as lazada_pickup_cnt              -- lazada已揽收包裹数
,coalesce(shopee_should_pickup_cnt  ,0) as shopee_should_pickup_cnt       -- shopee应揽收包裹数
,coalesce(shopee_pickup_cnt         ,0) as shopee_pickup_cnt              -- shopee已揽收包裹数
,coalesce(tiktok_should_pickup_cnt  ,0) as tiktok_should_pickup_cnt       -- tiktok应揽收包裹数
,coalesce(tiktok_pickup_cnt         ,0) as tiktok_pickup_cnt              -- tiktok已揽收包裹数
,coalesce(unplt_should_pickup_cnt   ,0) as unplt_should_pickup_cnt        -- 非平台客户应揽收任务数
,coalesce(unplt_pickup_cnt          ,0) as unplt_pickup_cnt               -- 非平台客户已揽收任务数

,coalesce(if(plt_should_pickup_cnt=0,0,round(plt_pickup_cnt/plt_should_pickup_cnt,2)),0) as plt_pickup_rate  -- 平台客户揽收完成率
,coalesce(if(plt_should_pickup_cnt=0,0,round(plt_pickup_cnt/plt_should_pickup_cnt,2)),0) as lazada_pickup_rate             -- lazada揽收完成率
,coalesce(if(plt_should_pickup_cnt=0,0,round(plt_pickup_cnt/plt_should_pickup_cnt,2)),0) as shopee_pickup_rate             -- shopee揽收完成率
,coalesce(if(plt_should_pickup_cnt=0,0,round(plt_pickup_cnt/plt_should_pickup_cnt,2)),0) as tiktok_pickup_rate             -- tiktok揽收完成率
,coalesce(if(plt_should_pickup_cnt=0,0,round(plt_pickup_cnt/plt_should_pickup_cnt,2)),0) as unplt_pickup_rate              -- 非平台客户揽收完成率

-- 近30天日均和ma7
,coalesce(ama.avg_pickup_eff              ,0) as avg_pickup_eff           -- 日均揽收人效
,coalesce(ama.ma7_pickup_eff              ,0) as ma7_pickup_eff           -- ma7揽收人效
,coalesce(ama.avg_self_pickup_eff         ,0) as avg_self_pickup_eff      -- 日均自有揽收人效
,coalesce(ama.ma7_self_pickup_eff         ,0) as ma7_self_pickup_eff      -- ma7自有揽收人效
,coalesce(ama.avg_unself_pickup_eff       ,0) as avg_unself_pickup_eff    -- 日均外协揽收人效
,coalesce(ama.ma7_unself_pickup_eff       ,0) as ma7_unself_pickup_eff    -- ma7外协揽收人效
,coalesce(ama.avg_handover_eff            ,0) as avg_handover_eff         -- 日均交接人效
,coalesce(ama.ma7_handover_eff            ,0) as ma7_handover_eff         -- ma7交接人效
,coalesce(ama.avg_self_handover_eff       ,0) as avg_self_handover_eff    -- 日均自有交接人效
,coalesce(ama.ma7_self_handover_eff       ,0) as ma7_self_handover_eff    -- ma7自有交接人效
,coalesce(ama.avg_unself_handover_eff     ,0) as avg_unself_handover_eff  -- 日均外协交接人效
,coalesce(ama.ma7_unself_handover_eff     ,0) as ma7_unself_handover_eff  -- ma7外协交接人效
,coalesce(ama.avg_delivery_eff            ,0) as avg_delivery_eff         -- 日均妥投人效
,coalesce(ama.ma7_delivery_eff            ,0) as ma7_delivery_eff         -- ma7妥投人效
,coalesce(ama.avg_self_delivery_eff       ,0) as avg_self_delivery_eff    -- 日均自有妥投人效
,coalesce(ama.ma7_self_delivery_eff       ,0) as ma7_self_delivery_eff    -- ma7自有妥投人效
,coalesce(ama.avg_unself_delivery_eff     ,0) as avg_unself_delivery_eff  -- 日均外协妥投人效
,coalesce(ama.ma7_unself_delivery_eff     ,0) as ma7_unself_delivery_eff  -- ma7外协妥投人效
,now() update_time #数据更新时间
from dwm.dim_ph_sys_store_rd ds

left join (-- 工作量
           select
           stat_date
           ,store_id
           ,sum(pickup_staff_cnt) as pickup_staff_cnt -- 揽收人数
           ,sum(if(staff_attr='自有员工',pickup_staff_cnt,0)) as self_pickup_staff_cnt -- 自有揽收人数
           ,sum(if(staff_attr='支援',pickup_staff_cnt,0)) as support_pickup_staff_cnt -- 支援揽收人数
           ,sum(if(staff_attr='外协',pickup_staff_cnt,0)) as unself_pickup_staff_cnt -- 外协揽收人数
           ,sum(pickup_par_cnt) as pickup_par_cnt -- 揽收单量
           ,sum(if(staff_attr='自有员工',pickup_par_cnt,0)) as self_pickup_par_cnt -- 自有揽收单量
           ,sum(if(staff_attr='支援',pickup_par_cnt,0)) as support_pickup_par_cnt -- 支援揽收单量
           ,sum(if(staff_attr='外协',pickup_par_cnt,0)) as unself_pickup_par_cnt -- 外协揽收单量
           ,sum(pickup_big_par_cnt) as pickup_big_par_cnt -- 揽收大件量
           ,sum(pickup_sma_par_cnt) as pickup_sma_par_cnt -- 揽收小件量
           ,sum(pickup_hour) as pickup_hour -- 揽件时长

           ,sum(handover_staff_cnt) as handover_staff_cnt -- 交接人数
           ,sum(if(staff_attr='自有员工',handover_staff_cnt,0)) as self_handover_staff_cnt -- 自有交接人数
           ,sum(if(staff_attr='支援',handover_staff_cnt,0)) as support_handover_staff_cnt -- 支援交接人数
           ,sum(if(staff_attr='外协',handover_staff_cnt,0)) as unself_handover_staff_cnt -- 外协交接人数
           ,sum(handover_par_cnt) as handover_par_cnt -- 交接单量
           ,sum(if(staff_attr='自有员工',handover_par_cnt,0)) as self_handover_par_cnt -- 自有交接单量
           ,sum(if(staff_attr='支援',handover_par_cnt,0)) as support_handover_par_cnt -- 支援交接单量
           ,sum(if(staff_attr='外协',handover_par_cnt,0)) as unself_handover_par_cnt -- 外协交接单量
           ,sum(handover_big_par_cnt) as handover_big_par_cnt -- 交接大件量
           ,sum(handover_sma_par_cnt) as handover_sma_par_cnt -- 交接小件量
           ,sum(handover_hour) as handover_hour -- 交接时长

           ,sum(delivery_staff_cnt) as delivery_staff_cnt -- 妥投人数
           ,sum(if(staff_attr='自有员工',delivery_staff_cnt,0)) as self_delivery_staff_cnt -- 自有妥投人数
           ,sum(if(staff_attr='支援',delivery_staff_cnt,0)) as support_delivery_staff_cnt -- 支援妥投人数
           ,sum(if(staff_attr='外协',delivery_staff_cnt,0)) as unself_delivery_staff_cnt -- 外协妥投人数
           ,sum(delivery_par_cnt) as delivery_par_cnt -- 妥投单量
           ,sum(if(staff_attr='自有员工',delivery_par_cnt,0)) as self_delivery_par_cnt -- 自有妥投单量
           ,sum(if(staff_attr='支援',delivery_par_cnt,0)) as support_delivery_par_cnt -- 支援妥投单量
           ,sum(if(staff_attr='外协',delivery_par_cnt,0)) as unself_delivery_par_cnt -- 外协妥投单量
           ,sum(delivery_big_par_cnt) as delivery_big_par_cnt -- 妥投大件量
           ,sum(delivery_sma_par_cnt) as delivery_sma_par_cnt -- 妥投小件量
           ,sum(delivery_hour) as delivery_hour -- 妥投时长
           ,sum(delivery_hour2) as delivery_hour2 -- 妥投时长2
           ,sum(delivery_ret_par_cnt) as delivery_ret_par_cnt -- 妥投退件包裹数
           from dwm.dws_ph_network_par_data_s
           where stat_date>=date_sub(current_date,interval 7 day)
           and stat_date<= date_sub(current_date,interval 1 day)
           group by 1,2
           )par
on ds.store_id=par.store_id
and ds.stat_date=par.stat_date
left join (-- 快递员
           select
           stat_date
           ,store_id
           ,sum(on_emp_cnt) as on_emp_cnt -- 在职员工
           ,sum(in_emp_cnt) as in_emp_cnt -- 入职员工
           ,sum(out_emp_cnt) as out_emp_cnt -- 离职员工
           ,sum(hc_appr_emp_cnt) as hc_appr_emp_cnt -- hc审批中人数
           ,sum(hc_demandnumber) as hc_demandnumber -- hc总需求人数
           ,sum(hc_surplusnumber) as hc_surplusnumber -- 招聘中人数
           ,sum(offer_emp_cnt) as offer_emp_cnt -- 已发offer数量
           ,sum(wait_in_emp_cnt) as wait_in_emp_cnt -- 待入职数量
           ,sum(atd_emp_cnt) as atd_emp_cnt -- 出勤人数
           ,sum(pb_emp_cnt) as pb_emp_cnt -- 排休人数
           from dwm.dws_ph_network_emp_job_data_s
           where stat_date>=date_sub(current_date,interval 7 day)
           and stat_date<= date_sub(current_date,interval 1 day)
           and job_title in (13,110,1000)
           group by 1,2
           )emp
on ds.store_id=emp.store_id
and ds.stat_date=emp.stat_date
left join (-- 仓管
           select
           stat_date
           ,store_id
           ,sum(on_emp_cnt) as on_emp_cnt -- 在职员工
           ,sum(in_emp_cnt) as in_emp_cnt -- 入职员工
           ,sum(out_emp_cnt) as out_emp_cnt -- 离职员工
           ,sum(hc_appr_emp_cnt) as hc_appr_emp_cnt -- hc审批中人数
           ,sum(hc_demandnumber) as hc_demandnumber -- hc总需求人数
           ,sum(hc_surplusnumber) as hc_surplusnumber -- 招聘中人数
           ,sum(offer_emp_cnt) as offer_emp_cnt -- 已发offer数量
           ,sum(wait_in_emp_cnt) as wait_in_emp_cnt -- 待入职数量
           ,sum(atd_emp_cnt) as atd_emp_cnt -- 出勤人数
           ,sum(pb_emp_cnt) as pb_emp_cnt -- 排休人数
           from dwm.dws_ph_network_emp_job_data_s
           where stat_date>=date_sub(current_date,interval 7 day)
           and stat_date<= date_sub(current_date,interval 1 day)
           and job_title = 37
           group by 1,2
           )dc
on ds.store_id=dc.store_id
and ds.stat_date=dc.stat_date
left join (-- 昨日在仓在途
           select
           stat_date
           ,date_add(stat_date,interval 1 day) as stat_date_new
           ,store_id
           ,sum(on_warehouse_par_cnt) as pre_on_warehouse_par_cnt -- 昨日在仓包裹数
           ,sum(on_way_par_cnt) as pre_on_way_par_cnt -- 昨日在途包裹数
           from dwm.dws_ph_network_ow_data_s
           where stat_date>=date_sub(current_date,interval 8 day)
           and stat_date<date_sub(current_date,interval 1 day)
           group by 1,2,3
           )owp
on ds.store_id=owp.store_id
and ds.stat_date=owp.stat_date_new
left join (-- 在仓在途
           select
           stat_date
           ,store_id
           ,sum(on_warehouse_par_cnt) as on_warehouse_par_cnt -- 在仓包裹数
           ,sum(if(is_cod=1,on_warehouse_par_cnt,0)) as on_warehouse_cod_par_cnt -- 在仓COD包裹数
           ,sum(if(is_big=1,on_warehouse_par_cnt,0)) as on_warehouse_big_par_cnt -- 在仓大件包裹数
           ,sum(if(detain_warehouse_days>=3,on_warehouse_par_cnt,0)) as on_warehouse_3days_par_cnt -- 在仓3天及以上包裹数
           ,sum(if(client_type='lazada',on_warehouse_par_cnt,0)) as lazada_on_warehouse_cod_par_cnt -- lazada在仓包裹数
           ,sum(if(client_type='shopee',on_warehouse_par_cnt,0)) as shopee_on_warehouse_cod_par_cnt -- shopee在仓包裹数
           ,sum(if(client_type='tiktok',on_warehouse_par_cnt,0)) as tiktok_on_warehouse_cod_par_cnt -- tiktok在仓包裹数

           ,sum(on_way_par_cnt) as on_way_par_cnt -- 在途包裹数
           ,sum(if(is_cod=1,on_way_par_cnt,0)) as on_way_cod_par_cnt -- 在途COD包裹数
           ,sum(if(is_big=1,on_way_par_cnt,0)) as on_way_big_par_cnt -- 在途大件包裹数
           ,sum(if(client_type='lazada',on_way_par_cnt,0)) as lazada_on_way_cod_par_cnt -- lazada在途包裹数
           ,sum(if(client_type='shopee',on_way_par_cnt,0)) as shopee_on_way_cod_par_cnt -- shopee在途包裹数
           ,sum(if(client_type='tiktok',on_way_par_cnt,0)) as tiktok_on_way_cod_par_cnt -- tiktok在途包裹数
           from dwm.dws_ph_network_ow_data_s
           where stat_date>=date_sub(current_date,interval 7 day)
           and stat_date<= date_sub(current_date,interval 1 day)
           group by 1,2
           )ow
on ds.store_id=ow.store_id
and ds.stat_date=ow.stat_date
left join (-- 应派包裹数
           select
           stat_date
           ,store_id
           ,sum(shl_delivery_par_cnt) as shl_delivery_par_cnt
           ,sum(shl_delivery_handover_par_cnt) as shl_delivery_handover_par_cnt
           ,sum(shl_delivery_delivery_par_cnt) as shl_delivery_delivery_par_cnt
           ,sum(shl_delivery_undelivery_par_cnt) as shl_delivery_undelivery_par_cnt

           ,sum(if(client_name in('lazada'),shl_delivery_par_cnt,0))            as lazada_shl_delivery_par_cnt
           ,sum(if(client_name in('lazada'),shl_delivery_handover_par_cnt,0))   as lazada_shl_delivery_handover_par_cnt
           ,sum(if(client_name in('lazada'),shl_delivery_delivery_par_cnt,0))   as lazada_shl_delivery_delivery_par_cnt
           ,sum(if(client_name in('lazada'),shl_delivery_undelivery_par_cnt,0)) as lazada_shl_delivery_undelivery_par_cnt

           ,sum(if(client_name in('shopee'),shl_delivery_par_cnt,0))            as shopee_shl_delivery_par_cnt
           ,sum(if(client_name in('shopee'),shl_delivery_handover_par_cnt,0))   as shopee_shl_delivery_handover_par_cnt
           ,sum(if(client_name in('shopee'),shl_delivery_delivery_par_cnt,0))   as shopee_shl_delivery_delivery_par_cnt
           ,sum(if(client_name in('shopee'),shl_delivery_undelivery_par_cnt,0)) as shopee_shl_delivery_undelivery_par_cnt

           ,sum(if(client_name in('tiktok'),shl_delivery_par_cnt,0))            as tiktok_shl_delivery_par_cnt
           ,sum(if(client_name in('tiktok'),shl_delivery_handover_par_cnt,0))   as tiktok_shl_delivery_handover_par_cnt
           ,sum(if(client_name in('tiktok'),shl_delivery_delivery_par_cnt,0))   as tiktok_shl_delivery_delivery_par_cnt
           ,sum(if(client_name in('tiktok'),shl_delivery_undelivery_par_cnt,0)) as tiktok_shl_delivery_undelivery_par_cnt
           from dwm.dws_ph_network_should_delivery_s
           where 1=1
           and stat_date>= date_sub(current_date,interval 7 day)
           and stat_date<= date_sub(current_date,interval 1 day)
           group by 1,2
           )sdd
on ds.store_id=sdd.store_id
and ds.stat_date=sdd.stat_date

left join (-- 进港 口径来自luomingsheng  添加目的网点过滤@0418 因为部分sp有minihub功能
           select
           date(date_add(pr.routed_at,interval 8 hour)) as stat_date
           ,pr.store_id
           ,count(distinct pr.pno) as inbound_par_cnt
           from ph_staging.parcel_route pr
           inner join ph_staging.parcel_info pi2
           on pr.pno=pi2.pno
           and pr.store_id=pi2.dst_store_id
           and pi2.`created_at` >= DATE_SUB(date_sub(CURRENT_DATE,interval 14 day) , INTERVAL 8 HOUR)
           and pi2.`created_at` < convert_tz(current_date, '+08:00', '+00:00')
           and pi2.state < 9
           where 1=1
           and pr.route_action in ('ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_GOODS_VAN_CHECK_SCAN') -- 到件入仓扫描\车货关联到港
           and pr.routed_at >= DATE_SUB(date_sub(CURRENT_DATE,interval 7 day) , INTERVAL 8 HOUR)
           and pr.routed_at <DATE_SUB(date_sub(CURRENT_DATE,interval 0 day) , INTERVAL 8 HOUR)
           group by 1,2
           )ib
on ds.store_id=ib.store_id
and ds.stat_date=ib.stat_date

left join (-- 揽收发出及时率
           select stat_date #揽收日期
           ,store_id #网点名称
           ,count(distinct ticket_pickup_id) as pk_task_cnt #揽收任务数
           ,count(distinct pno) as pickup_par_cnt #揽收单量
           ,count(distinct if(routed_at < last_send_at,pno,null) )  pickup_send_par_cnt #当天揽收发出单量
           from (
                 select pi.pno,
                 pi.state,
                 pi.ticket_pickup_id,
                 ss.id as store_id,
                 date(convert_tz(pi.created_at, '+00:00', '+08:00')) stat_date,
                 convert_tz(pr.routed_at, '+00:00', '+08:00') routed_at,
                 case when ss.category = 1 then concat(date_add(date(convert_tz(pi.created_at, '+00:00', '+08:00')),interval 1 day),' 00:00:00')
                      when ss.category = 14 then concat(date_add(date(convert_tz(pi.created_at, '+00:00', '+08:00')),interval 1 day),' 02:00:00')
                      end as last_send_at #最晚发出时间
                 from ph_staging.parcel_info pi
                 inner join ph_staging.sys_store ss
                 on ss.id = pi.ticket_pickup_store_id
                 and ss.category in ( 1,14 )
                 left join ph_staging.parcel_route pr
                 on pr.pno = pi.pno
                 and pr.store_id = pi.ticket_pickup_store_id
                 and pr.route_action in ('DEPARTURE_GOODS_VAN_CK_SCAN','SHIPMENT_WAREHOUSE_SCAN','DELIVERY_TICKET_CREATION_SCAN')  -- 多加了交接扫描，算上自揽自派网点
                 and pr.routed_at >= DATE_SUB(date_sub(CURRENT_DATE,interval 7 day) , INTERVAL 8 HOUR)
                 and pr.routed_at < convert_tz(current_date, '+08:00', '+00:00')
                 where pi.`created_at` >= DATE_SUB(date_sub(CURRENT_DATE,interval 7 day) , INTERVAL 8 HOUR)
                 and pi.`created_at` < convert_tz(current_date, '+08:00', '+00:00')
                 and pi.state < 9
                 )t
           group by 1,2
           )ps
on ds.store_id=ps.store_id
and ds.stat_date=ps.stat_date

left join (-- 揽收完成率
           select stat_date
           ,store_id
           ,sum(if(client_name in('lazada','shopee','tiktok'),should_pickup_cnt,0)) as plt_should_pickup_cnt
           ,sum(if(client_name in('lazada','shopee','tiktok'),pickup_cnt,0)) as plt_pickup_cnt

           ,sum(if(client_name in('lazada'),should_pickup_cnt,0)) as lazada_should_pickup_cnt
           ,sum(if(client_name in('lazada'),pickup_cnt,0))        as lazada_pickup_cnt
           ,sum(if(client_name in('shopee'),should_pickup_cnt,0)) as shopee_should_pickup_cnt
           ,sum(if(client_name in('shopee'),pickup_cnt,0))        as shopee_pickup_cnt
           ,sum(if(client_name in('tiktok'),should_pickup_cnt,0)) as tiktok_should_pickup_cnt
           ,sum(if(client_name in('tiktok'),pickup_cnt,0))        as tiktok_pickup_cnt

           ,sum(if(client_name in('ka和小c'),should_pickup_cnt,0)) as unplt_should_pickup_cnt
           ,sum(if(client_name in('ka和小c'),pickup_cnt,0))        as unplt_pickup_cnt
           from dwm.dws_ph_network_should_pickup_s
           where 1=1
           and stat_date>= date_sub(current_date,interval 7 day)
           and stat_date<= date_sub(current_date,interval 1 day)
           group by 1,2
           )pkr
on ds.store_id=pkr.store_id
and ds.stat_date=pkr.stat_date

left join dwm.dws_ph_netwrok_ama_item_s ama
on ds.store_id=ama.store_id
and ds.stat_date=ama.stat_date
and ama.stat_date>= date_sub(current_date,interval 7 day)
and ama.stat_date<= date_sub(current_date,interval 1 day)

where 1=1
and ds.stat_date >=date_sub(current_date,interval 7 day)
and ds.stat_date <=date_sub(current_date,interval 1 day)
