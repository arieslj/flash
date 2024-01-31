/*
=====================================================================+
表名称：1821d_th_problem_piece_monit
功能描述：疑难件日监控

需求来源：
编写人员: 黄烁烁
设计日期：2023-11-2
修改日期: 2023-11-16
修改人员: 吕杰
修改原因: 添加字段：退件前单号、当前所属网点，片区，大区
-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+=====================================================================
*/
select
  case
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer') then 'Retail Management'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
      when di.organization_type=2 and di.vip_enable=0 then '总部cs'
      when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
            or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
  end 部门
  ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
      when di.organization_type=2 and di.vip_enable=0 then '总部cs'
      when coalesce(ss.category,ss2.category) in (11) then 'FFM'
      when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
      when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
      when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
      when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
   end as 处理组织
  ,count(di.id) 总任务量
  ,count(if(datediff(current_date,date(di.created_at))<=1,di.id,null)) D0任务量
  ,count(if(datediff(current_date,date(di.created_at))<=1 and di.state=1,di.id,null)) D0已完成
  ,count(if(datediff(current_date,date(di.created_at))<=1 and di.state in (2,3,4),di.id,null)) 'D0沟通中ระหว่างเจรจา'
  ,count(if(datediff(current_date,date(di.created_at))<=1 and di.state=0,di.id,null)) 'D0未处理ยังไม่จัดการ'
  ,concat(round(
  (
  count(if(datediff(current_date,date(di.created_at))<=1 and di.state in (2,3,4),di.id,null))
  +count(if(datediff(current_date,date(di.created_at))<=1 and di.state=0,di.id,null))
  )/count(if(datediff(current_date,date(di.created_at))<=1,di.id,null))*100
  			,2),'%') D0未处理完成占比

  ,count(if(datediff(current_date,date(di.created_at))=2,di.id,null)) D1任务量
  ,count(if(datediff(current_date,date(di.created_at))=2 and di.state=1,di.id,null)) D1已完成
  ,count(if(datediff(current_date,date(di.created_at))=2 and di.state in (2,3,4),di.id,null)) 'D1沟通中ระหว่างเจรจา'
  ,count(if(datediff(current_date,date(di.created_at))=2 and di.state=0,di.id,null)) 'D1未处理ยังไม่จัดการ'
  ,concat(round(
  (
  count(if(datediff(current_date,date(di.created_at))=2 and di.state in (2,3,4),di.id,null))
  +count(if(datediff(current_date,date(di.created_at))=2 and di.state=0,di.id,null))
  )/count(if(datediff(current_date,date(di.created_at))=2,di.id,null))*100
  			,2),'%') D1未处理完成占比

  ,count(if(datediff(current_date,date(di.created_at))=3,di.id,null)) D2任务量
  ,count(if(datediff(current_date,date(di.created_at))=3 and di.state=1,di.id,null)) D2已完成
  ,count(if(datediff(current_date,date(di.created_at))=3 and di.state in (2,3,4),di.id,null)) 'D2沟通中ระหว่างเจรจา'
  ,count(if(datediff(current_date,date(di.created_at))=3 and di.state=0,di.id,null)) 'D2未处理ยังไม่จัดการ'
  ,concat(round(
  (
  count(if(datediff(current_date,date(di.created_at))=3 and di.state in (2,3,4),di.id,null))
  +count(if(datediff(current_date,date(di.created_at))=3 and di.state=0,di.id,null))
  )/count(if(datediff(current_date,date(di.created_at))=3,di.id,null))*100
  			,2),'%') D2未处理完成占比

  ,count(if(datediff(current_date,date(di.created_at))=4,di.id,null)) D3任务量
  ,count(if(datediff(current_date,date(di.created_at))=4 and di.state=1,di.id,null)) D3已完成
  ,count(if(datediff(current_date,date(di.created_at))=4 and di.state in (2,3,4),di.id,null)) 'D3沟通中ระหว่างเจรจา'
  ,count(if(datediff(current_date,date(di.created_at))=4 and di.state=0,di.id,null)) 'D3未处理ยังไม่จัดการ'
  ,concat(round(
  (
  count(if(datediff(current_date,date(di.created_at))=4 and di.state in (2,3,4),di.id,null))
  +count(if(datediff(current_date,date(di.created_at))=4 and di.state=0,di.id,null))
  )/count(if(datediff(current_date,date(di.created_at))=4,di.id,null))*100
  			,2),'%') D3未处理完成占比

  ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8),di.id,null)) D4_7任务量
  ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state=1,di.id,null)) D4_7已完成
  ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state in (2,3,4),di.id,null)) 'D4_7沟通中ระหว่างเจรจา'
  ,count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state=0,di.id,null)) 'D4_7未处理ยังไม่จัดการ'
  ,concat(round(
  (
  count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state in (2,3,4),di.id,null))
  +count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8) and di.state=0,di.id,null))
  )/count(if(datediff(current_date,date(di.created_at)) in (5,6,7,8),di.id,null))*100
  			,2),'%') D4_7未处理完成占比

  ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16),di.id,null)) D8_15任务量
  ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state=1,di.id,null)) D8_15已完成
  ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state in (2,3,4),di.id,null)) 'D8_15沟通中ระหว่างเจรจา'
  ,count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state=0,di.id,null)) 'D8_15未处理ยังไม่จัดการ'
  ,concat(round(
  (
  count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state in (2,3,4),di.id,null))
  +count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16) and di.state=0,di.id,null))
  )/count(if(datediff(current_date,date(di.created_at)) in (9,10,11,12,13,14,15,16),di.id,null))*100
  			,2),'%') D8_15未处理完成占比

  ,count(if(datediff(current_date,date(di.created_at))>=17,di.id,null)) 'D16+任务量'
  ,count(if(datediff(current_date,date(di.created_at))>=17 and di.state=1,di.id,null)) 'D16+已完成'
  ,count(if(datediff(current_date,date(di.created_at))>=17 and di.state in (2,3,4),di.id,null)) 'D16+沟通中ระหว่างเจรจา'
  ,count(if(datediff(current_date,date(di.created_at))>=17 and di.state=0,di.id,null)) 'D16+未处理ยังไม่จัดการ'
  ,concat(round(
  (
  count(if(datediff(current_date,date(di.created_at))>=17 and di.state in (2,3,4),di.id,null))
  +count(if(datediff(current_date,date(di.created_at))>=17 and di.state=0,di.id,null))
  )/count(if(datediff(current_date,date(di.created_at))>=17,di.id,null))*100
  			,2),'%') 'D16+未处理完成占比'

from
(
  select
    di.id
    ,convert_tz(di.created_at,'+00:00','+07:00') created_at
    ,di.pno
    ,ddd.cn_element
    ,pi.ticket_pickup_store_id
    ,pi.client_id
    ,cdt.state
    ,cdt.organization_type
    ,cdt.organization_id
    ,cdt.vip_enable
    ,cdt.service_type
    ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
    ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
  from fle_staging.diff_info di
  join fle_staging.parcel_info pi on di.pno=pi.pno
  left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
  join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'

  where pi.created_at>=date_sub(current_date,interval 3 month)
      and di.created_at<=date_sub(current_date,interval 7 hour)
      and (pi.state=6 or (cdt.state=1 and date(convert_tz(cdt.updated_at,'+00:00','+07:00'))=date_sub(current_date,interval 1 day)))
      and cdt.state in (0,1,2,3,4)
      and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
)di
left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
group by 1,2
;

select
  case
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Bulky BD') then 'Bulky Business Development'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('Group VIP Customer') then 'Retail Management'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('LAZADA','TikTok','Shopee','KAM CN','THAI KAM') then 'PMD'
      when di.organization_type=2 and di.vip_enable=1 and cg.name in ('FFM') then 'FFM'
      when di.organization_type=2 and di.vip_enable=0 then '总部cs'
      when ((di.organization_type=1 and (di.service_type != 3 or di.service_type is null) and di.vip_enable=0)
            or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3)) then 'Mini CS'
  end '部门แผนกที่จัดการ'
  ,case when di.organization_type=2 and di.vip_enable=1 then cg.name
      when di.organization_type=2 and di.vip_enable=0 then '总部cs'
      when coalesce(ss.category,ss2.category) in (11) then 'FFM'
      when coalesce(ss.category,ss2.category) in (4,5,7) then 'SHOP'
      when coalesce(ss.category,ss2.category) in (1,9,10,13,14) then 'NW'
      when coalesce(ss.category,ss2.category) = 6 or (di.organization_type=1 and di.vip_enable=0 and di.service_type = 3) then 'FH'
      when coalesce(ss.category,ss2.category) in (8,12) then 'HUB'
   end as '处理组织ทีมที่จัดการ'
 ,ss.name '问题件待处理网点สาขาที่จัดการ'
 ,di.pno '包裹号เลขพัสดุ'
 ,di.client_id
 ,di.pi_created_at '揽收时间เวลารับงาน'
 ,di.customary_pno '退件前单号'
 ,dt.store_name '当前所处网点'
 ,dt.piece_name '当前所处片区'
 ,dt.region_name '当前所处大区'
 ,di.created_at '问题件生成时间เวลาที่ติดปัญหาเข้าระบบ'

  	,case di.state
     when 0 then '客服未处理'
     when 1 then '已处理完毕'
     when 2 then '正在沟通中'
     when 3 then '财务驳回'
     when 4 then '客户未处理'
     when 5 then '转交闪速系统'
     when 6 then '转交QAQC'
     end as '处理状态สถานะจัดการปัจจุบัน'
 ,datediff(current_date,date(di.created_at)) '问题件生成天数'

from
(
  select
    di.id
    ,convert_tz(di.created_at,'+00:00','+07:00') created_at
    ,convert_tz(pi.created_at,'+00:00','+07:00') pi_created_at
    ,di.pno
    ,ddd.cn_element
    ,pi.ticket_pickup_store_id
    ,pi.client_id
    ,cdt.state
    ,cdt.organization_type
    ,cdt.organization_id
    ,cdt.vip_enable
    ,cdt.service_type
    ,pi.customary_pno
    ,pd.last_valid_store_id
    ,convert_tz(cdt.updated_at,'+00:00','+07:00') updated_at
    ,convert_tz(cdt.first_operated_at,'+00:00','+07:00') first_operated_at
  from fle_staging.diff_info di
  join fle_staging.parcel_info pi on di.pno=pi.pno
  left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id=di.id
  join dwm.dwd_dim_dict ddd on ddd.element=di.diff_marker_category and ddd.db='fle_staging' and ddd.tablename='diff_info' and ddd.fieldname='diff_marker_category'
  left join bi_pro.parcel_detail pd on pd.pno = pi.pno

  where pi.created_at>=date_sub(current_date,interval 3 month)
  and di.created_at<=date_sub(current_date,interval 7 hour)
  and (pi.state=6 or (cdt.state=1 and date(convert_tz(cdt.updated_at,'+00:00','+07:00'))=date_sub(current_date,interval 1 day)))

  and cdt.state in (0,2,3,4)
  and (cdt.operator_id not in (10001,10000) or  cdt.operator_id is null)
)di
left join fle_staging.sys_store ss on di.ticket_pickup_store_id=ss.id
left join fle_staging.sys_store ss2 on di.organization_id=ss2.id
left join fle_staging.customer_group_ka_relation cgk on cgk.ka_id=di.client_id and cgk.deleted=0
left join fle_staging.customer_group cg on cg.id=cgk.customer_group_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = di.last_valid_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
group by 1,2,3,4,5
