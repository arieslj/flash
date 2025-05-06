-- 需求文档：https://flashexpress.feishu.cn/docx/CyvNdH4eBoSPTnx9EG3cnA1unJh



with t as
    (
        select
            plt.created_at
            ,concat('SSRD', plt.id) plt_id
            ,plt.pno
            ,bc.client_name
            ,plt.client_id
            ,plt.id
            ,plt.parcel_created_at
        from ph_bi.parcel_lose_task plt
        left join ph_staging.parcel_info pi on pi.pno = plt.pno
        join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
        where
            plt.created_at >= '2024-01-01'
            and plt.created_at < '2024-02-16'
            and pi.dst_store_id = 'PH19040F05'
            and plt.state = 6
            and plt.duty_result = 1
        --  and plt.id = '16395381'
    )
, s as
    (
        select
            pc.id
            ,pc.pno
            ,pc.sub_8_action_at
            ,pc.action_at
        from
            (
                select
                    t1.id
                    ,t1.pno
                    ,date_sub(pcol.created_at, interval 8 hour) sub_8_action_at
                    ,pcol.created_at action_at
                    ,row_number() over (partition by t1.id order by pcol.created_at) rk
                from ph_bi.parcel_cs_operation_log pcol
                join t t1 on t1.id = pcol.task_id
                where
                    pcol.created_at > '2023-12-31'
                    and pcol.action = 4
            ) pc
        where
            pc.rk = 1
    )
select
    t1.created_at 闪速任务生成时间
    ,t1.plt_id 闪速任务ID
    ,t1.pno
    ,t1.client_id 客户ID
    ,s1.action_at 判责时间
    ,convert_tz(fir.routed_at, '+00:00', '+08:00') 解锁时间
    ,fir.CN_element 解锁路由
    ,ss.duty_store 责任网点
    ,if(pn.pno is not null, 'y', 'n') 是否在PN5操作过
    ,t1.parcel_created_at 揽收时间
    ,case
            when t1.client_name = 'lazada' then la.whole_end_date
            when t1.client_name = 'shopee' then sh.end_date
            when t1.client_name = 'tiktok' then if( tt.end_7_date is null, tt.end_date, tt.end_7_date)
            when t1.client_name = 'shein' then ein.whole_end_date
            else null
        end 丢失时效
from t t1
left join s s1 on s1.id = t1.id
left join
    (
        select
            pr.pno
            ,s1.id
            ,pr.route_action
            ,ddd.CN_element
            ,pr.routed_at
            ,row_number() over (partition by s1.id order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        left join s s1 on s1.pno = pr.pno
        where
            pr.routed_at > '2023-12-31 16:00:00'
            and pr.routed_at > s1.sub_8_action_at
            and pr.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER', 'REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN', 'SORTING_SCAN', 'CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM', 'DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN', 'ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    ) fir on fir.id = s1.id and fir.rk = 1
left join
    (
        select
            t1.id
            ,group_concat(distinct ss.name) duty_store
        from ph_bi.parcel_lose_responsible plr
        join t t1 on t1.id = plr.lose_task_id
        left join ph_staging.sys_store ss on ss.id = plr.store_id
        where
            plr.created_at >= '2024-01-01'
        group by 1
    ) ss on ss.id = t1.id
left join
    ( -- PN5修改包裹状态为关闭
        select
            pr.pno
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
           pr.routed_at > '2023-12-31 16:00:00'
            and pr.route_action = 'CHANGE_PARCEL_CLOSE'
            and pr.store_id = 'PH19040F05'
        group by 1
    ) pn on pn.pno = t1.pno
left join dwm.dwd_ex_ph_lazada_pno_period la on la.pno = t1.pno
left join dwm.dwd_ex_shopee_lost_pno_period sh on sh.pno = t1.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tt on tt.pno = t1.pno
left join dwm.dwd_ex_ph_shein_sla_detail ein on ein.pno = t1.pno

;

select
    t1.pno
    ,case
            when bc.client_name = 'lazada' then la.whole_end_date
            when bc.client_name = 'shopee' then sh.end_date
            when bc.client_name = 'tiktok' then if( tt.end_7_date is null, tt.end_date, tt.end_7_date)
            when bc.client_name = 'shein' then ein.whole_end_date
            else null
    end 丢失时效
from tmpale.tmp_ph_pno_lj_0228 t1
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_lazada_pno_period la on la.pno = t1.pno
left join dwm.dwd_ex_shopee_lost_pno_period sh on sh.pno = t1.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tt on tt.pno = t1.pno
left join dwm.dwd_ex_ph_shein_sla_detail ein on ein.pno = t1.pno


;



select
    *
from ph_bi.parcel_lose_task plt
where
    plt.source = 1 -- A来源
    and plt.state = 5 -- 无责
    and plt.operator_id in (10000,10001)