select
#     am.merge_column 单号
#     ,am.abnormal_time 异常日期
#     ,ddd.CN_element  最后有效路由
#     ,hjt.job_name 责任人岗位
#     ,am.staff_info_id 责任人
#     ,dp.store_name 网点
#     ,dp.piece_name 片区
#     ,dp.region_name 大区
    am.abnormal_time
    ,case am.punish_category
        when 84 then '24小时未更新有效路由'
        when 85 then '72小时未终态'
    end 处罚原因
    ,count(distinct am.merge_column) 单量数
    ,count(am.merge_column) 处罚数
from ph_bi.abnormal_message am
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and  ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = am.store_id and dp.stat_date = curdate()
where
    am.punish_category in (84,85) -- 24小时未更新有效路由
group by 1,2

;


select
    am.merge_column 单号
    ,am.abnormal_time 异常日期
    ,ddd.CN_element  最后有效路由
    ,hjt.job_name 责任人岗位
    ,am.staff_info_id 责任人
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
from ph_bi.abnormal_message am
left join ph_staging.parcel_route pr on pr.pno = am.merge_column
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and  ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = am.store_id and dp.stat_date = curdate()
where
    am.punish_category in (84,85)
    and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    and pr.routed_at > date_sub(am.created_at, interval 8 hour)
group by 1,2,3,4,5,6,7,8

;





select
    case am.punish_category
        when 84 then '24小时未更新有效路由'
        when 85 then '72小时未终态'
    end 处罚原因
    ,count(distinct if(ps.arrival_scan_route_at > '2024-06-01', am.merge_column, null)) 6月后到达目的地网点处罚单量
    ,count(distinct if(pd.resp_store_updated > '2024-06-01', am.merge_column, null)) 最新有效路由为6月单量
    ,count(distinct am.merge_column) 所有处罚单量
from ph_bi.abnormal_message am
left join ph_staging.parcel_info pi on pi.pno = am.merge_column
left join ph_bi.parcel_sub ps  on pi.dst_store_id = ps.arrive_duty_store_id and ps.pno = am.merge_column
left join ph_bi.parcel_detail pd on pd.pno = am.merge_column
where
    am.punish_category in (84,85)
    and am.abnormal_time = '2024-06-04'
group by 1

;

select
    case am.punish_category
        when 84 then '24小时未更新有效路由'
        when 85 then '72小时未终态'
    end 处罚原因
#     ,am.abnormal_time
    ,count(distinct am.merge_column) num
from ph_bi.abnormal_message am
where
    am.punish_category in (84,85)
    and am.store_id = 'PH19280F11'
group by 1


;


select
    am.merge_column 单号
    ,case am.punish_category
        when 84 then '24小时未更新有效路由'
        when 85 then '72小时未终态'
    end 处罚原因
    ,convert_tz(am.created_at, '+00:00', '+08:00') 包裹揽收时间
    ,date_format(convert_tz(am.routed_at, '+00:00', '+08:00'), '%Y-%m-%d %H:%i:%s') 最新有效路由时间
    ,am.pr_staff 最新有效路由操作人
    ,dp.store_name 包裹所在网点
    ,dp.region_name 所在大区
    ,am.staff_info_id 处罚责任人

from
    (
        select
            am.merge_column
            ,am.punish_category
            ,pi.created_at
            ,am.staff_info_id
            ,pr.store_id
            ,pr.staff_info_id pr_staff
            ,pr.routed_at
            ,row_number() over (partition by am.merge_column, am.staff_info_id order by pr.routed_at desc) rk
        from ph_bi.abnormal_message am
        left join ph_staging.parcel_info pi on pi.pno = am.merge_column
        left join ph_bi.parcel_sub ps  on pi.dst_store_id = ps.arrive_duty_store_id and ps.pno = am.merge_column
        left join ph_staging.parcel_route pr on pr.pno = am.merge_column and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN''DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
        where
            am.punish_category in (84,85)
            and am.abnormal_time = '2024-06-04'
            and pr.routed_at > '2024-01-01'
    ) am
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = am.store_id and dp.stat_date = curdate()
where
    am.rk = 1
    and am.routed_at < '2024-05-31 16:00:00'


;













select
  pct.pno
  ,pct.client_id
  ,coalesce(la.item_name, sp.item_name, tt.product_name)  包裹内物
from
  (
    select
      pct.*
      ,replace(get_json_object(pcn.neg_result,'$.money'),'"','') money
      ,row_number() over (partition by pct.id order by pcn.created_at desc) rk
    from
      (
        select
          pct.pno
          ,pct.id
          ,pct.client_id
          ,pct.duty_result
          ,pct.created_at
          ,pct.updated_at
          ,pct.state
        from  fle_dim. dim_bi_parcel_claim_task_da pct
        where
          pct.p_date = '2024-06-05'
          and pct.client_id in ('BG2229','BG1272','BG1272','BG2229')
      ) pct
    left join
      (
        select
          pcn.task_id
          ,pcn.neg_result
          ,pcn.created_at
        from  fle_dim. dim_bi_parcel_claim_negotiation_da pcn
        where
            pcn.p_date >= '2019-09-29'
      ) pcn on pcn.task_id = pct.id
  )
left join
  (
    select
      la.pno
      ,la.item_name
      ,la.quantity pro_cnt
    from fle_dwd.dwd_drds_lazada_order_item_di la
    where
      la.p_date >= '2019-01-01'
  ) la on la.pno = pct.pno
left join
  (
    select
      la.pno
      ,la.item_name
      ,la.item_quantity pro_cnt
    from  fle_dwd. dwd_drds_shopee_item_info_di la
    where
      la.p_date >= '2019-01-01'
  ) sp on sp.pno = pct.pno
left join
  (
    select
      la.pno
      ,la.product_name
      ,la.qty pro_cnt
    from  fle_dwd. dwd_drds_tiktok_order_item_di la
    where
      la.p_date >= '2019-01-01'
  ) tt on tt.pno = pct.pno
;











