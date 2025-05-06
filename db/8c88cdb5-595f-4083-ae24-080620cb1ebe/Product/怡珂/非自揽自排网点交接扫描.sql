with t as
    (
        select
            pr.store_name pr_store_name
            ,pr.store_id pr_store_id
            ,pi.pno
            ,pi.ticket_pickup_store_id
            ,pr.staff_info_id
            ,pi.dst_store_id
            ,pr.routed_at
            ,pi.state
            ,pi.created_at
            ,pi.ticket_delivery_store_id
        from fle_staging.parcel_info pi
        join rot_pro.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        where
            pi.created_at >= '2023-11-30 17:00:00'
            and pi.created_at < '2023-12-07 17:00:00'
            and pi.dst_store_id != pi.ticket_pickup_store_id
            and pr.store_id != pi.dst_store_id
            and pr.store_id != pi.ticket_delivery_store_id
        group by 1,2,3,4,5,6,7,8,9,10
    )
select
    t1.pno
    ,ss.name 揽件网点
    ,t1.pr_store_name 交接扫描网点
    ,ss2.name 目的地网点
    ,ss3.name 妥投网点
    ,t1.staff_info_id 交接扫描员工
    ,convert_tz(t1.routed_at, '+00:00', '+07:00') 交接扫描时间
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as `运单状态`
    ,if(plt.pno is null, '否', '是' ) 是否丢失
from t t1
left join
    (
        select
            t1.pno
            ,pcd.old_value
        from fle_staging.parcel_change_detail pcd
        join t t1 on t1.pno = pcd.pno
        where
            pcd.created_at > '2023-11-20'
            and pcd.field_name = 'dst_store_id'
        group by 1,2
    ) a on a.pno = t1.pno
left join fle_staging.sys_store ss on ss.id = t1.ticket_pickup_store_id
left join fle_staging.sys_store ss2 on ss2.id = t1.dst_store_id
left join bi_pro.parcel_lose_task plt on plt.pno = t1.pno and plt.state = 6 and plt.duty_result = 1 and plt.penalties > 0
left join fle_staging.sys_store ss3 on ss3.id = t1.ticket_delivery_store_id
where
    a.pno is null