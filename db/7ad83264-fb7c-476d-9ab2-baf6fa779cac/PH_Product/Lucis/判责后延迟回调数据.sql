with t as
    (
        select
            a1.*
        from
            (
                select
                    plt.pno
                    ,plt.client_id
                    ,plt.id
                    ,plt.source
                    ,plt.created_at
                    ,plt.updated_at
                    ,bc.client_name
                    ,date_sub(plt.updated_at, interval 8 hour) update_time
                    ,row_number() over (partition by plt.pno order by plt.updated_at) rk
                from ph_bi.parcel_lose_task plt
                join dwm.dwd_dim_bigClient bc on plt.client_id = bc.client_id
                where
                    plt.state = 6
                    and plt.updated_at >= '2024-03-28'
                    and plt.updated_at < '2024-04-28'
                    and plt.penalties > 0
                    and bc.client_name in ('lazada', 'shopee', 'tiktok')
            ) a1
        where
            a1.rk = 1
    )
select
    t1.pno 单号
    ,t1.client_id 客户ID
    ,case t1.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,concat('SSRD', t1.id) 任务ID
    ,t1.created_at 任务生成时间
    ,t1.updated_at 判责时间
    ,a2.CN_element 判责后产生的第一个有效路由名称
    ,convert_tz(a2.routed_at, '+00:00', '+08:00') 产生有效路由的时间
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
    end 当前状态
    ,ss.name 目的地网点
    ,oi.cod_amount/100 cod
    ,oi.cogs_amount/100 cogs
    ,case
            when t1.client_name = 'lazada' then la.whole_end_date
            when t1.client_name = 'shopee' then sh.end_date
            when t1.client_name = 'tiktok' then if( tt.end_7_date is null, tt.end_date, tt.end_7_date)
            when t1.client_name = 'shein' then ein.whole_end_date
            else null
        end 丢失时效
from t t1
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,ddd.CN_element
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
            and pr.routed_at > t1.update_time
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT', 'DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN''DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY', 'REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) a2 on a2.pno = t1.pno and a2.rk = 1
left join ph_staging.parcel_info pi on pi.pno = t1.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join dwm.dwd_ex_ph_lazada_pno_period la on la.pno = oi.pno
left join dwm.dwd_ex_shopee_lost_pno_period sh on sh.pno = oi.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tt on tt.pno = oi.pno
left join dwm.dwd_ex_ph_shein_sla_detail ein on ein.pno = oi.pno