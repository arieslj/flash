with p as (
select
  id,
  pno,
  vip_enable,
  duty_result,
  plt.remark,
  plt.client_id,
  plt.last_valid_routed_at,
  plt.last_valid_store_id,
  plt.last_valid_staff_info_id,
  plt.is_abnormal,
  plt.source,
  plt.state,
  plt.updated_at,
  plt.created_at,
  plt.fleet_stores,
  plt.link_type,
  plt.duty_type,
  plt.last_valid_action,
  plt.lose_tag
from
  ph_bi.parcel_lose_task plt
where
  plt.state = 6
  and plt.duty_result = 1
  and plt.created_at >= date_sub(curdate(), interval 2 week)
  and plt.penalties > 0
  #and pno = 'P7003A6TMP9AD'
)
select
plt.pno 运单号
,case plt.vip_enable when 0 then '普通客户' when 1 then 'KAM客户' end 客户类型
,case plt.duty_result when 1 then '丢失' when 2 then '破损' end 判责类型
,plt.remark 备注
,plt.client_id 客户ID
,pi.cod_amount/100 COD金额
,cast(pi.exhibition_weight as double)/1000 重量
,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) 尺寸
,ddd.CN_element 最后有效路由动作
,plt.last_valid_routed_at  最后有效路由时间
,plt.last_valid_store_id 最后有效路由网点id
,dp.store_name 最后有效路由网点
,concat(hsi.name, '(', plt.last_valid_staff_info_id, ')') 最后有效路由操作人
,ne.next_store_name 下一站网点
,case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
,plt.updated_at 处理时间
,case plt.link_type
       when 0 then 'ipc计数后丢失'
       when 1 then '揽收网点已揽件，未收件入仓'
       when 2 then '揽收网点已收件入仓，未发件出仓'
       when 3 then '中转已到件入仓扫描，中转未发件出仓'
       when 4 then '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
       when 5 then '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
       when 6 then '分拨发件出仓扫描，目的地未到件入仓(集包)'
       when 7 then '分拨发件出仓扫描，目的地未到件入仓(单件)'
       when 8 then '目的地到件入仓扫描，目的地未交接,当日遗失'
       when 9 then '目的地到件入仓扫描，目的地未交接,次日遗失'
       when 10 then '目的地交接扫描，目的地未妥投'
       when 11 then '目的地妥投后丢失'
       when 12 then '途中破损/短少'
       when 13 then '妥投后破损/短少'
       when 14 then '揽收网点已揽件，未收件入仓'
       when 15 then '揽收网点已收件入仓，未发件出仓'
       when 16 then '揽收网点发件出仓到分拨了'
       when 17 then '目的地到件入仓扫描，目的地未交接'
       when 18 then '目的地交接扫描，目的地未妥投'
       when 19 then '目的地妥投后破损短少'
       when 20 then '分拨已发件出仓，下一站分拨未到件入仓(集包)'
       when 21 then '分拨已发件出仓，下一站分拨未到件入仓(单件)'
       when 22 then 'ipc计数后丢失'
       when 23 then '超时效sla'
       when 24 then '分拨发件出仓到下一站分拨了'
end 判责环节
,case plt.duty_type
       when 1 then '快递员100%套餐'
       when 2 then '仓9主1套餐(仓管90%主管10%)'
       when 3 then '仓9主1套餐(仓管90%主管10%)'
       when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
       when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
       when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
       when 8 then 'LH全责（LH100%）'
       when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
       when 9 then '加盟商套餐'
       when 10 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
       when 19 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
       when 20 then  '加盟商双黄套餐（加盟商50%网点仓管45%主管5%）'
   end 套餐
,group_concat(distinct ss.name) 责任网点
,group_concat(distinct smr1.name) 责任大区
, concat(
        case when find_in_set('1', lose_tag) then '高价值包裹 ' else '' end,
        case when find_in_set('2', lose_tag) then '大件包裹 ' else '' end,
        case when find_in_set('3', lose_tag) then '重要物品 ' else '' end
    )  疑似丢失标签
,oi.cogs_amount/100 COGS
,case when amaq.isappeal > 1 then '是' else '否' end as 是否申诉
,hsi1.name as 申诉人
,amaq.appeal_staff_id as 申诉人ID
,hjt.job_name as 岗位
,ss1.name 申诉网点
,smr.name 申诉大区
,amaq.appeal_time 申诉时间
,case
    when amaq.isappeal = 1 then '未申诉'
    when amaq.isappeal = 2 then '申诉中'
    when amaq.isappeal = 3 then '保持原判'
    when amaq.isappeal = 4 then '已变更'
    when amaq.isappeal = 5 or amaq.isdel = 1 then '申诉成功&已删除'
end 申诉状态
,case when amaq.isdel = 1 or amaq.isappeal = 5 then '是' else '否' end as 是否申诉成功
from p plt
left join (
  select pi.*
  from ph_staging.parcel_info pi
  join p plt on pi.pno = plt.pno and pi.created_at >= date_sub(curdate(), interval 4 week)
)pi on pi.pno = plt.pno
left join (
  select oi.*
  from ph_staging.order_info oi
  join p plt on oi.pno = plt.pno and oi.created_at >= date_sub(curdate(), interval 4 week)
)oi on oi.pno = pi.pno
left join (
  select plr.*
  from ph_bi.parcel_lose_responsible plr
  join p plt on plr.lose_task_id = plt.id and plr.created_at >= date_sub(current_date(), interval 2 week)
)plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
left join ph_staging.sys_manage_region smr1 on smr1.id  =ss.manage_region
left join dwm.dim_ph_sys_store_rd  dp on dp.store_id = plt.last_valid_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = plt.last_valid_staff_info_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join (
         select am.merge_column,am.isdel,am.isappeal,am.lose_task_id,aq.appeal_time,aq.appeal_staff_id
         from(
               select am.id
                    ,am.merge_column
                    ,am.isappeal
                    ,am.isdel
                    ,json_extract (am.extra_info, '$.losr_task_id') as lose_task_id
               from ph_bi.abnormal_message am
               where am.abnormal_object = 0
                    and am.created_at >= date_sub(curdate(), interval 2 week)
              ) am
          left join (
                select aq.abnormal_message_id
                      ,aq.appeal_time
                      ,aq.appeal_staff_id
                from ph_bi.abnormal_qaqc aq
                where aq.created_at >= date_sub(curdate(), interval 2 week)
                    )aq on aq.abnormal_message_id = am.id

          union all

          select am.merge_column,am.isdel,am.isappeal,am.lose_task_id,aq.appeal_time,aq.appeal_staff_id
          from(
               select am.id
                    ,am.merge_column
                    ,am.isappeal
                    ,am.isdel
                    ,json_extract (am.extra_info, '$.losr_task_id') as lose_task_id
                    ,am.average_merge_key
               from ph_bi.abnormal_message am
               where am.abnormal_object = 1
                   and am.created_at >= date_sub(curdate(), interval 2 week)
              ) am
           left join (
                select aq.abnormal_message_id
                      ,aq.appeal_time
                      ,aq.appeal_staff_id
                      ,aq.qaqc_merge_key
                from ph_bi.abnormal_qaqc aq
                where aq.created_at >= date_sub(curdate(), interval 2 week)
                      )aq on aq.qaqc_merge_key = am.average_merge_key
)amaq on amaq.lose_task_id = plt.id
left join ph_bi.hr_staff_info hsi1 on hsi1.staff_info_id = amaq.appeal_staff_id
left join ph_staging.sys_store ss1 on ss1.id = hsi1.sys_store_id
left join ph_staging.sys_manage_region smr on smr.id  =ss1.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi1.job_title
left join
    (
        select
            pr.pno
            ,pr.next_store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from ph_staging.parcel_route pr
        join  p plt on plt.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 week)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) ne on ne.pno = plt.pno and ne.rk = 1
group by plt.id

;


select
    date(convert_tz(pi.created_at, '+00:00', '+08:00')) p_date
   ,count(pi.pno) p_cnt
from ph_staging.parcel_info pi
where
    pi.created_at > '2025-03-31 16:00:00'
    and pi.state < 9
    and pi.returned = 0
group by 1