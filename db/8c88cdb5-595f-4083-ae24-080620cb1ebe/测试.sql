SELECT
  distinct plt.pno
FROM
  bi_pro.parcel_lose_task plt
  join
  -- 交接表
  (
    select
      pr.pno pno,
      pr.route_action route_action,
      pr.routed_at routed_at
    from
      rot_pro.parcel_route pr
    where
      convert_tz(pr.routed_at, '+00:00', '+07:00') >= '2025-02-15'
      and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
  ) b on plt.pno = b.pno
where
  plt.created_at < convert_tz(b.routed_at,'+00:00','+07:00')
  and plt.updated_at>convert_tz(b.routed_at,'+00:00','+07:00')
  and plt.created_at >= '2025-02-15'
  and plt.created_at < '2025-03-01'
  and plt.source = 12
  and plt.source_id NOT LIKE '%_c_l_%' -- c to L
  and plt.state =6
  and plt.duty_result = 1


select *
from bi_pro.parcel_claim_task pct
where
    pct.pno in ('TH68156SBPUG3B','TH74086SBNS47C','TH31226SG8M30B','TH19076SCBQP7B','TH60056S8H431K')


;



select
            pi.pno
            ,pi.client_id
            ,pi.state
            ,pi.dst_store_id
            ,pssn.first_valid_routed_at
            ,dai.delivery_attempt_num
            ,ss.name ss_name
        from fle_staging.parcel_info pi
        join dwm.tmp_ex_big_clients_id_detail bc on pi.client_id = bc.client_id
        left join fle_staging.parcel_overdue_date_record podr on pi.pno = podr.pno and podr.created_at > '2025-02-28 17:00:00'
        join dw_dmd.parcel_store_stage_new pssn on pssn.pno = pi.pno and pssn.store_id = pi.dst_store_id and pssn.created_at > '2025-02-28 17:00:00'
        left join fle_staging.delivery_attempt_info dai on pi.pno = dai.pno and dai.created_at > '2025-02-28 17:00:00'
        left join fle_staging.sys_store ss on ss.id = pi.dst_store_id
        where
            pi.created_at > '2025-02-28 17:00:00'
            and pi.created_at < '2025-03-31 17:00:00'
            and bc.client_name = 'tiktok'
            and pi.cod_enabled = 0
            and pi.state in (2,4,6)
            and podr.pno is null
            and pssn.first_valid_routed_at is not null

;


with t as
    (
        select
           *
        from tmpale.tmp_th_pno_lj_0407
    )
select
    t2.pno
    ,t2.client_id 客户ID
    ,case t2.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 包裹状态
    ,t2.ss_name 目的地网点名称
    ,t2.dst_store_id 目的地网点ID
    ,convert_tz(t2.first_valid_routed_at, '+00:00', '+07:00') 目的地网点首次有效路由时间
    ,val.store_name 最后一次有效路由网点名称
    ,convert_tz(val.routed_at, '+00:00', '+07:00') 最后一次有效路由时间
    ,sc.delivery_ticket_creation_scan_cnt 交接次数
    ,t2.delivery_attempt_num 尝试派送次数
    ,if(rsc.return_source_category is not null, '是', '否') 是否满足条件自动退回
    ,case rsc.return_source_category
        when 1 then '问题件协商'
        when 2 then 'tiktok api 要求拦截退件'
        when 3 then '漏揽收'
        when 4 then '最后一次标记为收件人拒收的运单，时效最后一天退件 任务'
        when 5 then 'lazada取消订单 包裹中断运输并退回 20642'
        when 6 then '海关退回'
        when 7 then '缩短延迟退回的时间，减少丢失风险'
        when 8 then 'lazada客户常规自动退件逻辑'
        when 9 then 'tiktok客户常规自动退件逻辑'
        when 10 then 'shopee客户常规自动退件逻辑'
        when 11 then '按归属部门配置退件'
        when 12 then '爆仓自动退件逻辑'
        when 13 then 'ka&小c通用自动退件逻辑'
        when 14 then '客户定制化自动退件逻辑'
        when 15 then 'ms手动修改包裹状态为退件/批量中断运输并退回'
        when 16 then '平台撤销包裹要求退件'
        when 17 then '多次尝试派送失败回访'
        when 18 then '拒收复核上报退件'
        when 19 then '拒收复核包裹未上报+时效最后一天 自动退件'
        when 20 then '拒收复核回访'
        when 21 then '收件人拒收回访'
        when 22 then '多次提交拒收，系统自动退件(20920需求提交问题件自动协商为退件)'
        when 23 then '问题件协商未处理 自动退件( 客服决定策略n天后自动设置为退货，商户决定策略n天后自动设置为退货)'
        when 24 then '客户fda api调用'
        when 25 then '处理客户问题件-fbi导入excel处理'
        when 26 then '拒收策略直接退回'
        when 27 then 'tiktok客户常规自动退件逻辑（特殊网点配置次数）'
        when 99 then '其他'
        else null
    end 待退件原因
    ,awl_3.date_range 爆仓日期
from
    (
        select
            t1.*
        from t t1
        left join
            (
                select
                    distinct t1.pno
                from rot_pro.parcel_route pr
                join t t1 on t1.pno = pr.pno and pr.store_id = t1.dst_store_id
                where
                    pr.routed_at > '2025-02-28 17:00:00'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) pr on pr.pno = t1.pno
        where
            pr.pno is null

        union

        select
            t1.*
        from t t1
        where
            t1.delivery_attempt_num >= 1
            and t1.delivery_attempt_num < 3
            and datediff(curdate(), convert_tz(t1.first_valid_routed_at, '+00:00', '+07:00')) > 3

        union

        select
            t1.*
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
        where
            pr.routed_at > '2025-02-28 17:00:00'
            and pr.route_action = 'PENDING_RETURN'
            and json_extract(dpr.extra_value, '$.returnSourceCategory') is not null
    ) t2
left join
    (
        select
            distinct
            pr.pno
            ,json_extract(dpr.extra_value, '$.returnSourceCategory') as return_source_category
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
        where
            pr.routed_at > '2025-02-28 17:00:00'
            and pr.route_action = 'PENDING_RETURN'
            and json_extract(dpr.extra_value, '$.returnSourceCategory') is not null
    ) rsc on rsc.pno = t2.pno
left join
    (
        select
            t1.pno
            ,pr2.store_name
            ,pr2.routed_at
            ,row_number() over (partition by t1.pno order by pr2.routed_at desc) as rn
        from rot_pro.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.routed_at > '2025-02-28 17:00:00'
            and pr2.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) val on val.pno = t2.pno and val.rn = 1
left join
    (
        select
            t1.pno
            ,count(distinct date (convert_tz(pr.routed_at, '+00:00', '+07:00'))) as delivery_ticket_creation_scan_cnt
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.dst_store_id
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by t1.pno
    ) sc on sc.pno = t2.pno
left join
    (
        select
            awl_2.store_id
            ,group_concat(if(awl_2.start_date = awl_2.end_date, awl_2.start_date, concat(awl_2.start_date, '-', awl_2.end_date))) as date_range
        from
            (
                select
                    awl.store_id
                    ,date_format(awl.start_date, '%m%d') as start_date
                    ,date_format(awl.end_date, '%m%d') as end_date
                from nl_production.abnormal_white_list awl
                where
                    ( awl.start_date >= '2025-03-01' or awl.end_date >= '2025-03-01' )
                    and awl.start_date < '2025-04-01'
                    and awl.type = 2
            ) awl_2
        group by awl_2.store_id
    ) awl_3 on awl_3.store_id = t2.dst_store_id
