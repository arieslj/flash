# select date_sub(date_sub(date_sub(date_format(now(), '%y-%m-%d 00:00:00'), interval extract(day from now())-1 day), interval 2 month), interval 8 hour) as first_day_of_previous_month;
# ;
with lz as
    (
        select
            a.*
        from
            (
                select
                    coalesce(pi2.pno, pi.pno) pno
                    ,pi.state
                    ,pi.created_at pi_create_at
                    ,pi.client_id
                    ,bc.client_name
                    ,coalesce(pi2.cod_enabled, pi.cod_enabled) cod_enabled
                    ,lcr.updated_at created_at
                    ,lcr.duty_reasons
                    ,t_value
                    ,lcr.id task_id
                    ,rank() over (partition by coalesce(pi2.pno, pi.pno) order by lcr.updated_at desc) rk
                from ph_staging.parcel_info pi
                join ph_bi.parcel_lose_task lcr on lcr.pno = pi.pno and lcr.state = 6 and lcr.duty_result = 1 and lcr.penalties > 0
                join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada', 'shopee', 'tiktok')
                left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
                left join ph_bi.`translations` t on lcr.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'
                -- left join dwm.dwd_ex_ph_tiktok_sla_detail dep2 on dep2.pno = pi.customary_pno
                where
                    pi.created_at >= date_sub(date_sub(date_sub(date_format(now(), '%y-%m-%d 00:00:00'), interval extract(day from now())-1 day), interval 2 month), interval 8 hour) -- 2个月前第一天
                    -- and pi.created_at < '2023-10-19 16:00:00'
                    -- and pi.client_id in ('AA0148','AA0149')
                    and pi.state != 5
            ) a
        where
            a.rk = 1
    )
# , val as
#     (
#         select
#             l.*
#             ,pr.routed_at
#             ,ddd.CN_element
#             ,row_number() over (partition by pr.pno order by pr.routed_at ) rk1
#             -- ,row_number() over (partition by pr.pno order by pr.routed_at ) rk2
#         from ph_staging.parcel_route pr
#         join lz l on l.pno = pr.pno
#         left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.fieldname = 'route_action'
#         where
#             pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN','PICKUP_RETURN_RECEIPT','DISCARD_RETURN_BKK','SORTING_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','SHIPMENT_WAREHOUSE_SCAN','REPLACE_PNO','STAFF_INFO_UPDATE_WEIGHT','DELIVERY_CONFIRM','REFUND_CONFIRM','RECEIVE_WAREHOUSE_SCAN','DELIVERY_PICKUP_STORE_SCAN','DETAIN_WAREHOUSE','SEAL','UNSEAL','STORE_SORTER_UPDATE_WEIGHT','RECEIVED','ACCEPT_PARCEL','STORE_KEEPER_UPDATE_WEIGHT','INVENTORY','DELIVERY_MARKER','DIFFICULTY_HANDOVER','ARRIVAL_WAREHOUSE_SCAN','FLASH_HOME_SCAN','DELIVERY_TRANSFER','PARCEL_HEADLESS_PRINTED','DISTRIBUTION_INVENTORY')
#             and pr.routed_at > l.created_at
#             and pr.routed_at > date_sub(date_sub(date_sub(date_format(now(), '%y-%m-%d 00:00:00'), interval extract(day from now())-1 day), interval 2 month), interval 8 hour) -- 2个月前第一天
#     )
select
    convert_tz(l1.pi_create_at, '+00:00', '+08:00') pick_time
    ,date_format(convert_tz(l1.pi_create_at, '+00:00', '+08:00'), '%Y-%m')  pick_month
    ,convert_tz(l1.created_at, '+00:00', '+08:00') handle_time
    ,l1.client_id
    ,l1.client_name
    ,l1.pno
#     ,case
#         when timestampdiff(hour, v1.created_at, v1.routed_at) < 24 then '24小时内'
#         when timestampdiff(hour, v1.created_at, v1.routed_at) >= 24 and timestampdiff(hour, v1.created_at, v1.routed_at) < 48 then '24-48小时内'
#         when timestampdiff(hour, v1.created_at, v1.routed_at) >= 48 and timestampdiff(hour, v1.created_at, v1.routed_at) < 72 then '48-72小时内'
#         when timestampdiff(hour, v1.created_at, v1.routed_at) >= 72 and timestampdiff(hour, v1.created_at, v1.routed_at) < 96 then '72-96小时内'
#         when timestampdiff(hour, v1.created_at, v1.routed_at) >= 96 and timestampdiff(hour, v1.created_at, v1.routed_at) < 120 then '96-120小时内'
#         when timestampdiff(hour, v1.created_at, v1.routed_at) >= 120 then '120小时'
#     end 判责丢失后多久有有效路由
    ,'丢失' handle_type
    ,l1.t_value handle_reason
    ,a2.submit_store
    ,a2.remark
    ,a2.duty_store
    ,a2.duty_staff
    ,'' after_lost_first_valid_time
    ,'' after_lost_first_valid_action
    -- ,convert_tz(v2.routed_at, '+00:00', '+08:00') 丢失后最后一次有效路由时间
#     ,case v1.state
#         when 1 then '已揽收'
#         when 2 then '运输中'
#         when 3 then '派送中'
#         when 4 then '已滞留'
#         when 5 then '已签收'
#         when 6 then '疑难件处理中'
#         when 7 then '已退件'
#         when 8 then '异常关闭'
#         when 9 then '已撤销'
#     end 当前状态
    ,if(l1.cod_enabled = 1, 'y', 'n') cod
    ,oi.cogs_amount/100 cogs
from lz l1
# left join
#     (
#         select
#             *
#         from val v1
#         where
#             v1.rk1 = 1
#     ) v1 on v1.pno = l1.pno
left join
    (
        select
            l1.pno
            ,ss2.name submit_store
            ,cdt.remark
            ,group_concat(distinct ss.name) duty_store
            ,group_concat(distinct plr.staff_id) duty_staff
        from lz l1
        left join ph_bi.parcel_lose_task plt on plt.id = l1.task_id
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        left join ph_staging.customer_diff_ticket cdt on cdt.id = plt.source_id
        left join ph_staging.diff_info di on di.id = cdt.diff_info_id
        left join ph_staging.sys_store ss2 on ss2.id = di.store_id
        group by 1,2,3
    ) a2 on a2.pno = l1.pno
-- left join val v2 on v2.pno = v1.pno and v2.rk2 = 1
left join ph_staging.order_info oi on oi.pno = l1.pno and oi.created_at > date_sub(date_sub(date_sub(date_format(now(), '%y-%m-%d 00:00:00'), interval extract(day from now())-1 day), interval 2 month), interval 8 hour) -- 2个月前第一天
;













with lz as
    (
        select
            a.*
        from
            (
                select
                    coalesce(pi2.pno, pi.pno) pno
                    ,pi.state
                    ,pi.created_at pi_create_at
                    ,pi.client_id
                    ,bc.client_name
                    ,coalesce(pi2.cod_enabled, pi.cod_enabled) cod_enabled
                    ,pcol.created_at created_at
                    ,lcr.duty_reasons
                    ,t_value
                    ,lcr.id task_id
                    ,row_number() over (partition by coalesce(pi2.pno, pi.pno) order by pcol.created_at desc) rk
                from ph_staging.parcel_info pi
                join ph_bi.parcel_lose_task lcr on lcr.pno = pi.pno and lcr.duty_result = 2
                join ph_bi.parcel_cs_operation_log pcol on pcol.task_id = lcr.id and pcol.action = 4
                join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada', 'shopee', 'tiktok')
                left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
                left join ph_bi.`translations` t on lcr.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'
                -- left join dwm.dwd_ex_ph_tiktok_sla_detail dep2 on dep2.pno = pi.customary_pno
                where
                    pi.created_at >= date_sub(date_sub(date_sub(date_format(now(), '%y-%m-%d 00:00:00'), interval extract(day from now())-1 day), interval 2 month), interval 8 hour) -- 2个月前第一天
                    -- and pi.created_at < '2023-10-19 16:00:00'
                    -- and pi.client_id in ('AA0148','AA0149')
                    -- and pi.state != 5
                    -- and pi.pno = 'P12112F7KKTAE'
            ) a
        where
            a.rk = 1
    )
select
    convert_tz(l1.pi_create_at, '+00:00', '+08:00') pick_time
    ,date_format(convert_tz(l1.pi_create_at, '+00:00', '+08:00'), '%Y-%m')  pick_month
    ,convert_tz(l1.created_at, '+00:00', '+08:00') handle_time
    ,l1.client_id
    ,l1.client_name
    ,l1.pno
#     ,case
#         when timestampdiff(hour, v1.created_at, v1.routed_at) < 24 then '24小时内'
#         when timestampdiff(hour, v1.created_at, v1.routed_at) >= 24 and timestampdiff(hour, v1.created_at, v1.routed_at) < 48 then '24-48小时内'
#         when timestampdiff(hour, v1.created_at, v1.routed_at) >= 48 and timestampdiff(hour, v1.created_at, v1.routed_at) < 72 then '48-72小时内'
#         when timestampdiff(hour, v1.created_at, v1.routed_at) >= 72 and timestampdiff(hour, v1.created_at, v1.routed_at) < 96 then '72-96小时内'
#         when timestampdiff(hour, v1.created_at, v1.routed_at) >= 96 and timestampdiff(hour, v1.created_at, v1.routed_at) < 120 then '96-120小时内'
#         when timestampdiff(hour, v1.created_at, v1.routed_at) >= 120 then '120小时'
#     end 判责丢失后多久有有效路由
    ,'破损' handle_type
    ,l1.t_value handle_reason
    ,a2.submit_store
    ,a2.remark
    ,a2.duty_store
    ,a2.duty_staff
    ,'' after_lost_first_valid_time
    ,'' after_lost_first_valid_action
    -- ,convert_tz(v2.routed_at, '+00:00', '+08:00') 丢失后最后一次有效路由时间
#     ,case v1.state
#         when 1 then '已揽收'
#         when 2 then '运输中'
#         when 3 then '派送中'
#         when 4 then '已滞留'
#         when 5 then '已签收'
#         when 6 then '疑难件处理中'
#         when 7 then '已退件'
#         when 8 then '异常关闭'
#         when 9 then '已撤销'
#     end 当前状态
    ,if(l1.cod_enabled = 1, 'y', 'n') cod
    ,oi.cogs_amount/100 cogs
from lz l1
left join
    (
        select
            l1.pno
            ,ss2.name submit_store
            ,cdt.remark
            ,group_concat(distinct ss.name) duty_store
            ,group_concat(distinct plr.staff_id) duty_staff
        from lz l1
        left join ph_bi.parcel_lose_task plt on plt.id = l1.task_id
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        left join ph_staging.customer_diff_ticket cdt on cdt.id = plt.source_id
        left join ph_staging.diff_info di on di.id = cdt.diff_info_id
        left join ph_staging.sys_store ss2 on ss2.id = di.store_id
        group by 1,2,3
    ) a2 on a2.pno = l1.pno
-- left join val v2 on v2.pno = v1.pno and v2.rk2 = 1
left join ph_staging.order_info oi on oi.pno = l1.pno and oi.created_at > date_sub(date_sub(date_sub(date_format(now(), '%y-%m-%d 00:00:00'), interval extract(day from now())-1 day), interval 2 month), interval 8 hour)

;




select
    convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,pi.pno 运单号
    ,pi.state
    ,if(pi.cod_enabled = 1, 'y', 'n') 是否COD
    ,pi.client_id 客户id
    ,bc.client_name 客户类型
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,oi.cogs_amount/100 cogs
    ,case
        when bc.client_name = 'lazada' then la.whole_end_date
        when bc.client_name = 'shopee' then sp.end_date
        when bc.client_name = 'tiktok' then if(pi.returned = 0, tt.end_7_date, tt.end_7_plus_date)
    end 超时效日期
from ph_staging.parcel_info pi
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada', 'shopee','tiktok')
left join dwm.dwd_ex_ph_lazada_pno_period la on la.pno = pi.pno
left join dwm.dwd_ex_shopee_lost_pno_period sp on sp.pno = pi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tt on tt.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
where
    pi.created_at >= '2023-08-31 16:00:00'
    and pi.discard_enabled = 1
    and (pi.opt >> 4 & 1 = 1 OR pi.opt >> 8 & 1 = 1)

;

select
    t.*
    ,oi.insure_declare_value/100 cogs
from tmpale.tmp_ph_lazada_cogs_1024 t
left join ph_staging.parcel_info pi on pi.pno = t.pno
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)

;

select * from tmpale.tmp_ph_lost_pno