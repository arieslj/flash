SELECT
t.pno 运单号
,pi2.customary_pno 退件前单号
,pi2.cod_amount1
,pi3.cod_amount / 100 cod_amount2
,pi2.name 目的地网点
,pr.created_at 最后有效路由时间
,pr.name 最后有效路由网点
,pr1.ct 交接扫描次数
,pr1.staff_info_id 最后一次交接员工ID
,pr1.created_at 最后一次交接扫描时间
,pr2.ct 盘库扫描次数
,pr2.staff_info_id 最后一次盘库员工ID
,pr2.created_at 最后一次盘库扫描时间
,pr3.ct 强制拍照次数
,pr3.staff_info_id 最后一次强制拍照员工ID
,pr3.created_at 最后一次强制拍照时间
,pr4.ct 联系客户次数
,pr5.ct 疑难件交接次数
,timestampdiff(day,pr6.created_at,now())到达目的网点天数
FROM tmpale.th_test_pno_20230224 t
left join
(
    select
    pi2.pno
    ,pi2.customary_pno
    ,ss.name
    ,if(pi2.customary_pno is null,pi2.cod_amount / 100,null) cod_amount1
    from fle_staging.parcel_info pi2
    left join fle_staging.sys_store ss onss.id= pi2.dst_store_id
) pi2 on pi2.pno = t.pno
left join fle_staging.parcel_info pi3 on pi2.customary_pno = pi3.pno
left join
(--最后有效路由
select
    *
from
    (
        select
        pr.pno
        ,convert_tz(pr.created_at,'+00:00','+07:00') created_at
        ,ss.name
        ,row_number() over (partition by pr.pno order by pr.created_at desc) rn
        from tmpale.th_test_pno_20230224 t
        join rot_pro.parcel_route pr on t.pno=pr.pno
        and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
            'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER',
            'DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT',
            'STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER',
            'PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN'
            ,'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','ACCEPT_PARCEL','REFUND_CONFIRM')
        left join fle_staging.sys_store ss on pr.store_id =ss.id
    ) pr
    where pr.rn = 1
) pr on pr.pno = t.pno
left join
(--交接扫描
    select
    pr.pno
    ,pr.staff_info_id
    ,pr.created_at
    ,pr.ct
    from
    (
        select
        pr.pno
        ,pr.staff_info_id
        ,pr.created_at
        ,pr.rn
        ,count(pr.pno) ct
        from
        (
            select
            pr.pno
            ,pr.staff_info_id
            ,convert_tz(pr.created_at,'+00:00','+07:00') created_at
            ,row_number()over(partition by pr.pno order by pr.created_at desc)rn
            from tmpale.th_test_pno_20230224 t
            join rot_pro.parcel_route pr on t.pno=pr.pno
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            group by 1,2,3
        )pr
        group by 1
    )pr where pr.rn=1
)pr1 on pr1.pno=t.pno

left join
(--盘库扫描
    select
    pr.pno
    ,pr.staff_info_id
    ,pr.created_at
    ,pr.ct
    from
    (
        select
        pr.pno
        ,pr.staff_info_id
        ,pr.created_at
