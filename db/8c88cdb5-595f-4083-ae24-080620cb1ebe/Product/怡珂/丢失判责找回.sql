-- 需求文档：https://flashexpress.feishu.cn/wiki/NeRmwAJMjil0zjkFmDEcRx0jnwb




select
    a1.pno
    ,if(a1.operator_id in (10000, 10001), 'Y', 'N') 是否自动判责
    ,case
        when timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 < 4 then '0-4'
        when timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 < 8 and timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 >= 4 then '4-8'
        when timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 < 12 and timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 >= 8 then '8-12'
        when timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 < 24 and timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 >= 12 then '12-24'
        when timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 < 36 and timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 >= 24 then '24-36'
        when timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 < 48 and timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 >= 36 then '36-48'
        when timestampdiff(second , a1.updated_at_zero_zone, a1.routed_at) / 3600 >= 48 then '48+'
    end 找回的间隔时长
    ,case
        when pi.state = 1 then '已揽收'
        when pi.state = 2 then '运输中'
        when pi.state = 3 then '派送中'
        when pi.state = 4 then '已滞留'
        when pi.state = 5 then '已签收'
        when pi.state = 6 then '疑难件处理中'
        when pi.state = 7 then '已退件'
        when pi.state = 8 and pi.dst_store_id = 'TH05110303' then '异常关闭(目的地为LAS)'
        when pi.state = 8  and pi.dst_store_id != 'TH05110303' then '异常关闭(目的地非LAS)'
        when pi.state = 9 then '已撤销'
    end 找回后的包裹状态
    ,a1.staff_info_id 上报丢失的快递员工号
    ,dt.store_name 上报丢失的网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,case
        when bc.client_id is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.id is null then '小c'
    end as  客户类型
    ,t.t_value 判责所属原因
    ,case a1.link_type
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
from
    (
        select
            plt.*
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by plt.pno order by pr.routed_at ) rk
        from
            (
                select
                    plt.id
                    ,plt.pno
                    ,plt.duty_reasons
                    ,plt.link_type
                    ,di.staff_info_id
                    ,di.store_id
                    ,plt.operator_id
                    ,plt.client_id
                    ,plt.updated_at
                    ,date_sub(plt.updated_at, interval 7 hour) as updated_at_zero_zone
                from bi_pro.parcel_lose_task plt
                left join fle_staging.customer_diff_ticket cdt on cdt.id = plt.source_id and cdt.created_at > date_sub(curdate(), interval 2 month )
                left join fle_staging.diff_info di on di.id = cdt.diff_info_id and di.created_at > date_sub(curdate(), interval 2 month )
                where
                    plt.source = 1
                    and plt.created_at > '2025-01-01'
                    and plt.created_at < '2025-01-13'
                    and plt.state = 6
            ) plt
        join
            (
                select
                    pr.pno
                    ,pr.route_action
                    ,pr.routed_at
                from rot_pro.parcel_route pr
                where
                    pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
                    and pr.routed_at > '2024-12-31'
            ) pr on pr.pno = plt.pno
        where
            pr.routed_at > plt.updated_at_zero_zone
    ) a1
left join fle_staging.parcel_info pi on pi.pno = a1.pno and pi.created_at > date_sub(curdate(), interval 2 month )
left join dwm.dim_th_sys_store_rd dt on dt.store_id = a1.store_id and dt.stat_date = date_sub(curdate(),1)
left join fle_staging.ka_profile kp on kp.id = a1.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = a1.client_id
left join bi_pro.translations t on a1.duty_reasons = t.t_key AND t.lang = 'zh-CN'
where
    a1.rk = 1