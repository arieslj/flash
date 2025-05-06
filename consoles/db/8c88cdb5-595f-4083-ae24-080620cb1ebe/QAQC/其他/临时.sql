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

;

with a as
    (
        select
            t.pno
            ,dsa.url
            ,row_number() over (partition by t.pno order by dsa.created_at) rk
        from tmpale.tmp_th_pno_lj_sort_0222 t
        left join dwm.dwd_sorting_attachment dsa on dsa.oss_bucket_key = t.pno
    )

select
    t.pno
    ,t1.url 1st
    ,t2.url 2nd
from tmpale.tmp_th_pno_lj_sort_0222 t
left join a t1 on t1.pno = t.pno and t1.rk = 1
left join a t2 on t2.pno = t.pno and t2.rk = 2



;



select
    pssn.pno
from dw_dmd.parcel_store_stage_new pssn
left join fle_staging.parcel_info pi on pi.pno = pssn.pno
left join
    (
        select
            pssn.pno
        from dw_dmd.parcel_store_stage_new pssn
        where
            pssn.created_at > '2024-05-01'
            and pssn.pno_created_at > '2024-05-01'
            and pssn.pno_created_at < '2024-05-21'
            and pssn.store_category in (8,12)
         --   and pssn.valid_store_order is not null
          --  and pssn.pno = 'TH01175NG6ET5A'
        group by 1
    ) p1 on p1.pno = pssn.pno
where
    p1.pno is null
    and pssn.created_at > '2024-05-01'
    and pssn.pno_created_at > '2024-05-01'
    and pssn.pno_created_at < '2024-05-21'
group by 1


;



tmp_th_pno_lj_0620




select
    t.pno
    ,convert_tz(dst.routed_at, '+00:00', '+07:00') 第一次到达目的地网点时间
    ,convert_tz(src.routed_at, '+00:00', '+07:00') 最新有效路由时间
from tmpale.tmp_th_pno_lj_0620 t
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by t.pno order by pr.routed_at ) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_0620 t on t.pno = pr.pno
        left join fle_staging.parcel_info pi on pi.pno = t.pno
        where
            pr.routed_at > '2024-04-01'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN''DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
            and pr.store_id = pi.dst_store_id
    ) dst on dst.pno = t.pno and dst.rk = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by t.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_0620 t on t.pno = pr.pno
        where
            pr.routed_at > '2024-04-01'
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN''DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) src on src.pno = t.pno and src.rk = 1

;





select
    t.单号
    ,pi.created_at
from tmpale.tmp_th_pno_lj_0624 t
left join fle_staging.parcel_info pi on pi.pno = t.单号
;




with t as
    (
        select
            pr.staff_info_id
            ,pr.pno
            ,pr.route_action
            ,pr.routed_at
        from rot_pro.parcel_route pr
        where
            pr.staff_info_id in (68739, 600614)
            and pr.routed_at >= '2024-06-22 01:40:50'
            and pr.routed_at <= '2024-06-22 01:59:00'
    )

select
    t1.pno 运单号
    ,ddd.CN_element 操作路由名称
    ,t1.staff_info_id 操作人
    ,convert_tz(t1.routed_at, '+00:00', '+07:00') 时间
    ,oi.cod_amount/100 cod
    ,oi.cogs_amount/100 cogs
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
    ,sc.staff_name
from t t1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm.dwd_dim_dict ddd on ddd.element = t1.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join
    (
        select
            pr.pno
            ,group_concat(distinct pr.staff_info_name) staff_name
        from rot_pro.parcel_route pr
        join
            (
                select t1.pno from t t1 group by 1
            )t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2024-05-01'
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.pno = t1.pno

;



select
    t.pno
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,ss.name 妥投网点
from tmpale.tmp_th_pno t
left join fle_staging.parcel_info pi on pi.pno = t.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
;



select
    t.pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,pi.src_name 发件人姓名
    ,pi.src_detail_address 发件人地址
    ,pi.src_phone 发件人电话
    ,case pi.article_category
         when 0 then '文件'
         when 1 then '干燥食品'
         when 2 then '日用品'
         when 3 then '数码产品'
         when 4 then '衣物'
         when 5 then '书刊'
         when 6 then '汽车配件'
         when 7 then '鞋包'
         when 8 then '体育器材'
         when 9 then '化妆品'
         when 10 then '家居用具'
         when 11 then '水果'
         when 99 then '其它'
    end as 物品类型
    ,ss.name 揽收网点
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 发件出仓时间
    ,pi.exhibition_weight/1000 重量_kg
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
from tmpale.tmp_th_pno_lj_0627 t
left join fle_staging.parcel_info pi on pi.pno = t.pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join rot_pro.parcel_route pr on pr.store_id = pi.ticket_pickup_store_id and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.pno = t.pno
;



select
    t.pno
    ,pi.client_id
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,pi.src_name 寄件人姓名
    ,pi.src_phone 寄件人电话
    ,pi.src_detail_address 寄件人地址
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
    ,pi.dst_detail_address 收件人地址
    ,ss.name  揽收网点
from tmpale.tmp_th_pno_lj_0809 t
left join fle_staging.parcel_info pi on pi.pno = t.pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id






;


select
    min(pi.created_at)
    ,count(pi.pno)
from tmpale.tmp_th_pno_lj_0701 t
left join fle_staging.parcel_info pi on pi.pno = t.pno


;



with t as
    (
        select
            distinct
            pct.pno
            ,pct.updated_at
            ,date(plt.last_valid_routed_at) p_date
            ,pct.id
            ,plt.duty_type
            ,plr.store_id
            ,ss.category
            ,ss.manage_piece
            ,ss.manage_region
        from bi_pro.parcel_claim_task pct
        left join bi_pro.parcel_lose_task plt on plt.id = pct.lose_task_id
        left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join fle_staging.sys_store ss on ss.id = plr.store_id
        where
            pct.state = 6
            and pct.updated_at >= '2024-06-25'
            and pct.updated_at < '2024-07-01'
    )
select
    *
from t t1
left join
    (
        select
            *
        from bi_pro.hr_staff_transfer hst
        join t t1 on
    ) am

;


select
    distinct
    pct.pno
    ,plt.id lose_task_id
    ,pct.updated_at
    ,pct.id
    ,date(plt.last_valid_routed_at) p_date
    ,plt.duty_type
    ,plr.store_id
from
    (
        select
            pct.pno
            ,pct.lose_task_id
            ,pct.id
            ,pct.updated_at
        from bi_pro.parcel_claim_task  pct
        where
            pct.state = 6
            and pct.duty_result = 1
            and pct.updated_at >= '2024-06-25 00:00:00'
            and pct.updated_at <= '2024-06-30 00:00:00'
    ) pct
join
    (
        select
            plt.id
            ,plt.pno
            ,plt.duty_type
            ,plt.last_valid_routed_at
            ,date(plt.last_valid_routed_at) p_date
        from bi_pro.parcel_lose_task  plt
        where
            plt.created_at >= '2023-11-01 00:00:00'
            and plt.state = 6
            and plt.duty_result = 1
            and plt.penalties > 0
    )plt on pct.pno = plt.pno
left join bi_pro.parcel_lose_responsible plr on plt.id = plr.lose_task_id



;


select
    ss.name
    ,am.miss_scan_new_cnt / am.total_cnt 漏揽收率
from bi_pro.am_miss_scan_rate_monthly am
left join fle_staging.sys_store ss on ss.id = am.store_id
where
    am.stat_date = '2024-06-01'

;

-- TH02030145
select
    pi.pno
    ,kw.out_client_id
from fle_staging.parcel_info pi
left join fle_staging.ka_warehouse kw on kw.id = pi.ka_warehouse_id
where
    pi.pno = 'THT200711CV4B5Z'
;

select
    distinct plt.pno
from bi_pro.parcel_lose_task plt
left join bi_pro.parcel_lose_responsible plr on plt.id = plr.lose_task_id
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join fle_staging.ka_warehouse kw on kw.id = pi.ka_warehouse_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.penalties > 0
    and plr.store_id = 'TH02030145'
    and plt.updated_at >= '2024-06-01'
    and plt.updated_at < '2024-07-01'
    and kw.out_client_id = 'Hygiene.thailand'

;



select
    count(1)
from
    (
        select
            ppl.initial_pno
        from fle_staging.parcel_pno_log ppl
        join tmpale.tmp_th_pno_lj_0829 t on t.pno = ppl.replace_pno
#         where
#             ppl.replace_pno = 'TH012661EZEK7B'

        union

        select
            ppl.initial_pno
        from fle_staging.parcel_pno_log ppl
        join tmpale.tmp_th_pno_lj_0829 t on t.pno = ppl.initial_pno
    ) a
;


with t as
    (
        select
            fvp.relation_no
            ,fvp.pack_no
            ,pi.ticket_pickup_store_id
            ,pi.dst_store_id
            ,pi.client_id
            ,pi.created_at
            ,pi.customary_pno
            ,pi.finished_at
            ,pi.state
            ,pi.ticket_delivery_store_id
        from fle_staging.fleet_van_proof_parcel_detail fvp
        left join fle_staging.parcel_info pi on pi.pno = fvp.relation_no
        where
            fvp.proof_id = 'AYU140UU63'
            and fvp.relation_category in (1,3)
    )
select
    t1.relation_no
    ,t1.pack_no 包裹集包号
    ,oi.cod_amount/100 COD金额
    ,convert_tz(t1.created_at, '+00:00', '+07:00') 揽件时间
    ,ss.name 揽件网点
    ,ss2.name 目的地网点
    ,concat(kp.id, '(', kp.name, ')') 客户ID
    ,case
        when bc.client_id is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.id is null then '小c'
    end as 客户类型
    ,ddd.CN_element 最后有效路由
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后有效路由时间
    ,p2.store_name 最后有效路由网点
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 最后一次车货关联到港时间
    ,p1.store_name 最后一次车货关联到港
    ,if(t1.state = 5, convert_tz(t1.finished_at, '+00:00', '+07:00'), null) 包裹妥投时间
    ,if(t1.state = 5, ss3.name, null) 包裹妥投网点
from t t1
left join fle_staging.order_info oi on oi.pno = coalesce(t1.customary_pno, t1.relation_no)
left join fle_staging.sys_store ss on ss.id = t1.ticket_pickup_store_id
left join fle_staging.sys_store ss2 on ss2.id = t1.dst_store_id
left join fle_staging.sys_store ss3 on ss3.id = t1.ticket_delivery_store_id
left join fle_staging.ka_profile kp on kp.id = t1.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.relation_no = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action = 'ARRIVAL_GOODS_VAN_CHECK_SCAN'
    ) p1 on p1.pno = t1.relation_no and p1.rk = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_name
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.relation_no = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) p2 on p2.pno = t1.relation_no and p2.rk = 1
left join dwm.dwd_dim_dict ddd on ddd.element = p2.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'