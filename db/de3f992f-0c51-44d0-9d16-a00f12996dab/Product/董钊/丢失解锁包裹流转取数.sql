-- 丢失解锁包裹流转取数 https://flashexpress.feishu.cn/docx/WT9YdKr2wozM44x4kqBcy9bgnph

with t as

(
    select
        pr.pno
        ,t1.client_id
        ,t1.updated_at
        ,t1.state
        ,t1.ticket_delivery_store_id
        ,t1.parcel_created_at
        ,convert_tz(t1.updated_at, '+07:00', '+00:00') updated_time
    from rot_pro.parcel_route pr
    join
        (
            select
                plt.pno
                ,plt.updated_at
                ,plt.client_id
                ,plt.parcel_created_at
                ,pi.state
                ,pi.ticket_delivery_store_id
                ,date_sub(plt.updated_at, interval 7 hour) update_time
            from bi_pro.parcel_lose_task plt
            left join fle_staging.parcel_info pi on pi.pno = plt.pno and pi.created_at > '2023-08-01'
            where
                plt.source in (1,3,12)
                and plt.state = 6
                and plt.updated_at >= '2023-11-01'
                and plt.updated_at < '2023-11-24'
                and pi.returned = 0
                and pi.cod_enabled = 1
                and pi.dst_store_id = 'TH05110303' -- AAA拍卖仓
        ) t1 on t1.pno = pr.pno
    join rot_pro.parcel_route pr2 on pr2.pno = t1.pno
    where
        pr.route_action = 'DISCARD_RETURN_BKK'
        and pr.routed_at > t1.update_time
        and pr2.routed_at > '2023-10-31 17:00:00'
        and pr.routed_at > '2023-10-31 17:00:00'
        and pr2.routed_at < pr.routed_at
        and pr2.routed_at > t1.update_time
        and pr2.route_action in ('RECEIVED','STAFF_INFO_UPDATE_WEIGHT','RECEIVE_WAREHOUSE_SCAN','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','PRINTING','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','THIRD_EXPRESS_ROUTE','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','SORTING_SCAN','CANCEL_SHIPMENT_WAREHOUSE','INVENTORY','REFUND_CONFIRM','DISTRIBUTION_INVENTORY','DELIVERY_TRANSFER','DELIVERY_PICKUP_STORE_SCAN','ACCEPT_PARCEL','DIFFICULTY_HANDOVER')
    group by 1,2,3,4
)
select
    t1.pno 单号
    ,t1.client_id 客户ID
    ,t1.parcel_created_at 揽收时间
    ,mark.mark_count 责任人认定前派件次数
    ,ppd.pnp_count '责任人认定前留仓/问题件次数'
    ,coalesce(dai.delivery_attempt_num, a3.del_count)  有效尝试派送天数
    ,if(t1.state = 5, ss.name, '否') 是否已妥投
from t t1
left join fle_staging.delivery_attempt_info dai on dai.pno = t1.pno
left join
    (
        select
            t1.pno
            ,count(distinct pr.id) mark_count
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action  = 'DELIVERY_MARKER'
            and pr.routed_at > date_sub(curdate(), interval 2 month )
            and pr.routed_at < t1.updated_time
            -- and pr.marker_category in (9,14,70,1,40,2,17,23,73,26,76,29,78)
        group by 1
    ) mark on mark.pno = t1.pno
left join
    (
        select
            t1.pno
            ,count(distinct ppd.id) pnp_count
        from fle_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.created_at > date_sub(curdate(), interval 2 month )
            and ppd.created_at < t1.updated_time
            -- and ppd.diff_marker_category in (9,14,70,1,40,2,17,23,73,26,76,29,78)
        group by 1
    ) ppd on ppd.pno = t1.pno
left join
    (
        select
            t1.pno
            ,count(distinct if(mark.mark_date is not null and ppd.pnp_date is not null, mark.mark_date, null)) del_count
        from t t1
        left join
            (
                select
                    t1.pno
                   ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) mark_date
                from rot_pro.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action  = 'DELIVERY_MARKER'
                    and pr.routed_at > date_sub(curdate(), interval 2 month )
                    and pr.routed_at < t1.updated_time
                    and pr.marker_category in (9,14,70,1,40,2,17,23,73,26,76,29,78)
                group by 1,2
            ) mark on mark.pno = t1.pno
        left join
            (
                select
                    t1.pno
                  ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) pnp_date
                from fle_staging.parcel_problem_detail ppd
                join t t1 on t1.pno = ppd.pno
                where
                    ppd.created_at > date_sub(curdate(), interval 2 month )
                    and ppd.created_at < t1.updated_time
                    and ppd.diff_marker_category in (9,14,70,1,40,2,17,23,73,26,76,29,78)
                group by 1,2
            ) ppd on ppd.pno = t1.pno and ppd.pnp_date = mark.mark_date
        group by 1
    ) a3 on a3.pno = t1.pno
left join fle_staging.sys_store ss on ss.id = t1.ticket_delivery_store_id

;
