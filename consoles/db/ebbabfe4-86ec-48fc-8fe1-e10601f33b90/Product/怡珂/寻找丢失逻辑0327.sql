with t as
    (
        select
            plt.pno
            ,plt.id
            ,plt.client_id
            ,case
                when bc.`client_id` is not null then bc.client_name
                when kp.id is not null and bc.client_id is null then '普通ka'
                when kp.`id` is null then '小c'
            end as 客户类型
            ,plt.link_type
            ,greatest(ifnull(oi.cogs_amount/100, 0), ifnull(oi.cod_amount/100, 0)) parcel_value
            ,coalesce(cast(oi.`ka_warehouse_id` as char),concat(oi.client_id,'-',trim(oi.`src_phone`),'-',trim(oi.src_detail_address))) seller
        from my_bi.parcel_lose_task plt
        left join my_staging.parcel_info pi on plt.pno = pi.pno
        left join my_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
        left join my_staging.ka_profile kp on kp.id = plt.client_id
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
        where
            plt.parcel_created_at >= '2024-02-01'
            and plt.parcel_created_at < '2024-03-01'
            and plt.state = 6
            and plt.duty_result = 1
            and plt.penalties > 0
    )
, a as
    (
        select
            t1.id
            ,t1.pno
            ,pcol.created_at
            ,date_sub(pcol.created_at, interval 8 hour) route_at
        from my_bi.parcel_cs_operation_log pcol
        join t t1 on t1.id = pcol.task_id
        where
            pcol.created_at > '2024-02-01'
            and pcol.action = 4
    )
select
    t1.pno
    ,t1.client_id
    ,t1.parcel_value
    ,t1.seller
    ,t1.`客户类型` 平台
    ,plr.duty_store 责任网点
    ,case t1.`link_type`
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
    ,a3.ub_cnt 解锁次数
    ,a3.cn_element 解锁路由
    ,pri.reason 打印面单原因次数
from t t1
left join
    (
        select
            a2.pno
            ,count(distinct a2.created_at) ub_cnt
            ,group_concat(distinct ddd.cn_element) cn_element
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            a1.*
                            ,pr.route_action
                            ,pr.routed_at
                            ,row_number() over (partition by a1.pno order by pr.routed_at) rk
                        from my_staging.parcel_route pr
                        join a a1 on a1.pno = pr.pno
                        where
                            pr.routed_at > '2023-01-31 16:00:00' -- 闪速认定最新有效路由
                            and pr.routed_at > route_at
                            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                    ) a1
                where
                    a1.rk = 1
            ) a2
        left join dwm.dwd_dim_dict ddd on ddd.element = a2.route_action and ddd.db = 'my_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        group by 1
    ) a3 on a3.pno = t1.pno
left join
    (
        select
            a.pno
            ,group_concat(distinct concat(a.reason, a.pr_cnt)) reason
        from
            (
                select
                    t1.pno
                    ,case
                        when json_extract(extra_value, '$.parcelScanManualImportCategory') = 0 then '面单条码褶皱/破损'
                        when json_extract(extra_value, '$.parcelScanManualImportCategory') = 99 then '其他'
                        else '无'
                    end reason
                    ,count(pr.id) pr_cnt
                from my_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > '2023-01-31 16:00:00'
                    and pr.route_action = 'PRINTING'
                group by 1,2
            ) a
        group by 1
    ) pri on pri.pno = t1.pno
left join
    (
        select
            t1.id
            ,group_concat(distinct ss.name) duty_store
        from my_bi.parcel_lose_responsible plr
        join t t1 on t1.id = plr.lose_task_id
        left join my_staging.sys_store ss on ss.id = plr.store_id
        where
            plr.created_at > '2023-01-31 16:00:00'
        group by 1
    ) plr on plr.id = t1.id

