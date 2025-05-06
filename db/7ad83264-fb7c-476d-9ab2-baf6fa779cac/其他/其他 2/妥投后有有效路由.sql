select
    pr.pno
from ph_staging.parcel_route pr
where
    pr.route_action = 'DELIVERY_CONFIRM'
    and pr.routed_at > '2023-07-02 16:00:00'

;

select
   fn.运单号
   ,fn.妥投快递员ID
   ,fn.妥投时间
   ,fn.妥投网点
   , fn.平台账号ID
   , fn.平台名称
   , fn.包裹最新状态
   , fn.包裹签收时间
,date(fn.妥投时间) 妥投日期
   , fn.最后一条路由操作时间
   , fn.最后一条有效路由
   , fn.最后一条有效路由所在网点ID
   , fn.最后一条有效路由所在网点名称
   , fn.片区
   , fn.大区
   , fn.操作人员ID
   , fn.操作人员名称
   , fn.收件人姓名
   , fn.收件人电话
   , fn.收件人地址
from
(
    select
       pr.pno as 运单号
       ,pi.ticket_delivery_staff_info_id 妥投快递员ID
       ,ss2.name 妥投网点
       ,convert_tz(pi.finished_at,'+00:00','+08:00') 妥投时间
        , db.client_id as 平台账号ID
        , db.client_name as 平台名称
       , convert_tz(pr.created_at,'+00:00','+08:00') as 最后一条路由操作时间
        , convert_tz(pi.finished_at,'+00:00','+08:00') as 包裹签收时间
       , pr.route_action as 最后一条有效路由
        , pr.staff_info_id as 操作人员ID
        , pr.staff_info_name as 操作人员名称
        , pi.dst_name as 收件人姓名
        , pi.dst_phone as 收件人电话
        , pi.dst_detail_address as 收件人地址
       , pr.store_id as 最后一条有效路由所在网点ID
       , pr.store_name as 最后一条有效路由所在网点名称
       , mr.name as 大区
       , mp.name as 片区
        , case when pi.state = 1 then '已揽收'
          when pi.state = 2 then '运输中'
          when pi.state = 3 then '派送中'
          when pi.state = 4 then '已滞留'
          when pi.state = 5 then '已签收'
          when pi.state = 6 then '疑难件处理中'
          when pi.state = 7 then '已退件'
          when pi.state = 8 then '异常关闭'
          when pi.state = 9 then '已撤销'
         end as 包裹最新状态
      , row_number() over (partition by  pr.pno order by pr.created_at desc) as rnk
   from ph_staging.parcel_route pr
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = ''
   join ph_staging.parcel_info pi on pr.pno=pi.pno
   left join ph_staging.sys_store ss2 on ss2.id = pi.ticket_delivery_store_id
   left join dwm.dwd_dim_bigClient db on pi.client_id=db.client_id
   join ph_staging.sys_store ss on pr.store_id=ss.id
   left join ph_staging.sys_manage_piece mp on mp.id= ss.manage_piece
   left join ph_staging.sys_manage_region mr on mr.id= ss.manage_region
   where pr.route_action in
   ('RECEIVED'
   ,'RECEIVE_WAREHOUSE_SCAN'
   ,'SORTING_SCAN'
   ,'DELIVERY_TICKET_CREATION_SCAN'
   ,'ARRIVAL_WAREHOUSE_SCAN'
   ,'SHIPMENT_WAREHOUSE_SCAN'
   ,'DETAIN_WAREHOUSE'
   ,'DELIVERY_CONFIRM'
   ,'DIFFICULTY_HANDOVER'
   ,'DELIVERY_MARKER'
   ,'REPLACE_PNO'
   ,'SEAL'
   ,'UNSEAL'
   ,'PARCEL_HEADLESS_PRINTED'
   ,'STAFF_INFO_UPDATE_WEIGHT'
   ,'STORE_KEEPER_UPDATE_WEIGHT'
   ,'STORE_SORTER_UPDATE_WEIGHT'
   ,'DISCARD_RETURN_BKK'
   ,'DELIVERY_TRANSFER'
   ,'PICKUP_RETURN_RECEIPT'
   ,'FLASH_HOME_SCAN'
   ,'seal.ARRIVAL_WAREHOUSE_SCAN'
   ,'INVENTORY'
   ,'SORTING_SCAN'
   ,'PHONE'
   )
   and pi.state=5
   and pi.finished_at>=date_sub(date_sub(current_date,interval 2 day), interval 8 hour )
)fn
where fn.rnk=1
    and timestampdiff(second,fn.包裹签收时间,fn.最后一条路由操作时间)>=100