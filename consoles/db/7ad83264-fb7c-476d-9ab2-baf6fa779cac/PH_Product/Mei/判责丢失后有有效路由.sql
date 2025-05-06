with
    t as
(
    select
        plt2.pno
        ,pcol.created_at
        ,convert_tz(pcol.created_at, '+08:00', '+00:00') created_time
        ,plt2.client_id
        ,plt2.parcel_created_at
        ,plt2.id
    from ph_bi.parcel_cs_operation_log pcol
    left join ph_bi.parcel_lose_task plt2 on pcol.task_id = plt2.id
    where
        pcol.type = 1
        and pcol.action = 4
        and pcol.operator_id != 10001
        and pcol.created_at >= '2023-06-01'
        and pcol.created_at < '2023-07-01'
)
,
    pr as
(
    select
        t1.*
        ,pr.route_action
        ,pr.routed_at
        ,pr.store_name
        ,pr.store_id
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from ph_staging.parcel_route pr
    join t t1 on t1.pno = pr.pno
#     join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
    where
        pr.routed_at > t1.created_time
        and pr.route_action in ('SORTING_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','STAFF_INFO_UPDATE_WEIGHT','DELIVERY_CONFIRM','ACCEPT_PARCEL','REPLACE_PNO','UNSEAL','STORE_SORTER_UPDATE_WEIGHT','RECEIVED','PARCEL_HEADLESS_PRINTED','SEAL','DIFFICULTY_HANDOVER','DETAIN_WAREHOUSE','REFUND_CONFIRM','FLASH_HOME_SCAN','RECEIVE_WAREHOUSE_SCAN','PICKUP_RETURN_RECEIPT','STORE_KEEPER_UPDATE_WEIGHT','INVENTORY','DELIVERY_TRANSFER','DELIVERY_MARKER','DISCARD_RETURN_BKK','DELIVERY_PICKUP_STORE_SCAN')
)
select
    a.PNO
    ,a.parcel_created_at
    ,case
        when bc.client_id is not null then bc.client_name
        when bc.client_id is null and kp.id is not null then 'KA'
        when kp.id is null then 'GE'
    end 客户类型
    ,case
        when a.diff_hour < 24 then '24小时内'
        when a.diff_hour >= 24 and a.diff_hour < 48 then '24-48小时'
        when a.diff_hour >= 48 and a.diff_hour < 72 then '48-72小时'
        when a.diff_hour >= 72 and a.diff_hour < 96 then '72-96小时'
        when a.diff_hour >= 96 and a.diff_hour < 120 then '96-120小时'
        when a.diff_hour >= 120 then '120小时以上'
    end 判责丢失后找回包裹时效
    ,case pi.cod_enabled
        when 0 then '否'
        when 1 then '是'
    end 是否COD
    ,if(pi.state = 5 , datediff(convert_tz(pi.finished_at, '+00:00', '+08:00'), a.created_at), null) 判责丢失后几天内投妥成功
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
    ,if(a2.store_name = 'PN5-CS(INVENTORY)', '是', '否') 是否到拍卖场
    ,if(bc.client_name is not null ,
        case
            when bc.client_name = 'lazada' and date(convert_tz(a.routed_at, '+00:00', '+08:00')) <= la.whole_end_date then '是'
            when bc.client_name = 'shopee' and date(convert_tz(a.routed_at, '+00:00', '+08:00')) <= sh.end_date then '是'
            when bc.client_name = 'tiktok' and date(convert_tz(a.routed_at, '+00:00', '+08:00')) <= if( tt.end_7_date is null, tt.end_date, tt.end_7_date) then '是'
            when bc.client_name = 'shein' and date(convert_tz(a.routed_at, '+00:00', '+08:00')) <= ein.whole_end_date then '是'
            else '否'
        end, null) 是否在丢弃时效前有有效路由
from
    (
        select
            a.*
            ,timestampdiff(hour, a.created_at, convert_tz(a.routed_at, '+00:00', '+08:00')) diff_hour
        from pr a
        where
            a.rk = 1
    ) a
left join ph_staging.ka_profile kp on kp.id = a.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = a.client_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = a.pno
left join
    (
        select
            a.*
        from pr a
        where
            a.rk2 = 1
    ) a2 on a2.pno = a.pno
left join dwm.dwd_ex_ph_lazada_pno_period la on la.pno = a.pno
left join dwm.dwd_ex_shopee_lost_pno_period sh on sh.pno = a.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tt on tt.pno = a.pno
left join dwm.dwd_ex_ph_shein_sla_detail ein on ein.pno = a.pno;


select
    plt.pno
    ,plt.parcel_created_at
from ph_bi.parcel_lose_task plt
join tmpale.tmp_ph_pno_plt_0828 t on t.pno = plt.pno
group by 1,2