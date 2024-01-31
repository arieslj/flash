select
    t.pno 单号
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
    end as 包裹状态
    ,pi2.pno 正向单号
    ,pi2.returned_pno 逆向单号
    ,las.CN_element  最后有效路由
    ,las.store_name 最后有效路由网点
    ,convert_tz(las.routed_at, '+00:00', '+07:00') 最后有效路由操作时间
    ,las.staff_info_id 最后有效路由操作人
    ,if(plt.pno is not null, '是', '否') 是否判责遗失
    ,plt.handle_time 判责遗失时间
    ,pi.client_id 客户ID
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人手机号
    ,pi.src_name 寄件人姓名
    ,pi.src_phone 寄件人手机号
    ,case pct.state
        when 1 then '待协商'
        when 2 then '协商不一致，待重新协商'
        when 3 then '待财务核实'
        when 4 then '核实通过，待财务支付'
        when 5 then '财务驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止'
        when 8 then '异常关闭'
        when 9 then' 待协商（搁置）'
        when 10 then '等待再次联系'
    end 理赔状态
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_1226 t on t.pno = pi.pno
left join  fle_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join
    (
        select
            ddd.CN_element
            ,pr.pno
            ,pr.routed_at
            ,pr.store_name
            ,pr.staff_info_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_1226 t on t.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) las on las.pno = pi.pno and las.rk = 1
left join
    (
        select
            plt.pno
            ,min(plt.updated_at) handle_time
        from bi_pro.parcel_lose_task plt
        join tmpale.tmp_th_pno_lj_1226 t on t.pno = plt.pno
        where
            plt.state = 6
            and plt.duty_result = 1
        group by 1
    ) plt on plt.pno = pi.pno
left join bi_pro.parcel_claim_task pct on pct.pno = t.pno
;

select
    t.pno
    ,case pct.state
        when 1 then '待协商'
        when 2 then '协商不一致，待重新协商'
        when 3 then '待财务核实'
        when 4 then '核实通过，待财务支付'
        when 5 then '财务驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止'
        when 8 then '异常关闭'
        when 9 then' 待协商（搁置）'
        when 10 then '等待再次联系'
    end 理赔状态
from tmpale.tmp_th_pno_lj_1226 t
left join bi_pro.parcel_claim_task pct on pct.pno = t.pno
;
select
    t.pno `单号`
    ,b.pno `正向单号`
    ,b.returned_pno `逆向单号`
    ,las.route_action  `最后有效路由`
    ,las.store_name `最后有效路由网点`
    ,las.routed_at `最后有效路由操作时间`
    ,las.staff_info_id `最后有效路由操作人`
    ,if(plt.pno is not null, '是', '否') `是否判责遗失`
    ,plt.hand_time `判责遗失时间`
    ,a.client_id `客户ID`
    ,a.dst_name `收件人姓名`
    ,a.dst_phone `收件人手机号`
    ,a.src_name `寄件人姓名`
    ,a.src_phone `寄件人手机号`
from
  (
    select
      pi.pno
      ,pi.returned
      ,pi.customary_pno
      ,pi.client_id
      ,pi.dst_name
      ,pi.dst_phone
      ,pi.src_name
      ,pi.src_phone
    from fle_dwd.dwd_fle_parcel_info_di pi
    where
      pi.p_date >= '2023-04-08'
  ) a
join test.tmp_th_m_pno_lj_1226 t on t.pno = a.pno
left join
  (
    select
      pi.pno
      ,pi.returned_pno
    from fle_dwd.dwd_fle_parcel_info_di pi
    where
      pi.p_date >= '2023-04-08'
  ) b on if(a.returned = '1', a.customary_pno, a.pno) = b.pno
left join
  (
    select
      a.*
    from
      (
         select
          pr.pno
          ,pr.staff_info_id
          ,pr.store_name
          ,pr.routed_at
          ,pr.route_action
          ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from fle_dwd.dwd_rot_parcel_route_di pr
        where
          pr.p_date >= '2023-04-08'
          and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
      ) a
    join test.tmp_th_m_pno_lj_1226 t on t.pno = a.pno
    where
      a.rk = 1
  ) las on las.pno = t.pno
left join
  (
    select
      t.pno
      ,min(a1.updated_at) hand_time
    from
      (
         select
          plt.pno
          ,plt.updated_at
        from fle_dwd.dwd_bi_parcel_lose_task_di plt
        where
          plt.p_date >= '2023-04-08'
          and plt.state = '6'
          and plt.duty_result = '1'
      ) a1
      join test.tmp_th_m_pno_lj_1226 t on t.pno = a1.pno
    group by 1
  ) plt on plt.pno = t.pno

