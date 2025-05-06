select
    count(a.pno) 提交错分问题件数
    ,count(if(b.pno is null, a.pno, null)) / count(a.pno) 仓管提交占比
    ,count(if(b.pno is not null, a.pno, null)) / count(a.pno) 快递员标记占比
from
    (
        select
            distinct pr.pno
        from rot_pro.parcel_route pr
        where
            pr.marker_category = 31
            and pr.routed_at > '2024-07-11 17:00:00'
            and pr.routed_at < '2024-07-12 17:00:00'
    ) a
left join
    (
        select
            distinct pr.pno
        from rot_pro.parcel_route pr
        where
            pr.marker_category = 79
            and pr.routed_at > '2024-07-11 17:00:00'
            and pr.routed_at < '2024-07-12 17:00:00'
    ) b on a.pno = b.pno


;

select
    count(a.pno) 快递员标记包裹量
    ,count(if(b.pno is not null, a.pno, null)) / count(a.pno) 快递员标记里错分占比
from
    (
        select
            distinct pr.pno
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.routed_at > '2024-07-11 17:00:00'
            and pr.routed_at < '2024-07-12 17:00:00'
    ) a
left join
    (
        select
            distinct pr.pno
        from rot_pro.parcel_route pr
        where
            pr.marker_category = 79
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.routed_at > '2024-07-11 17:00:00'
            and pr.routed_at < '2024-07-12 17:00:00'
    ) b on a.pno = b.pno
;

select
    pr.store_id 操作标记网点
    ,pr.store_name 操作标记网点名称
    ,pr.staff_info_id 操作标记员工ID
    ,pr.pno 包裹号
    ,ss.name 包裹归属网点
from rot_pro.parcel_route pr
left join fle_staging.parcel_info pi on pi.pno = pr.pno
left join fle_staging.sys_store ss on ss.id = pi.dst_store_id
where
    pr.marker_category = 79
    and pr.route_action = 'DELIVERY_MARKER'
    and pr.routed_at > '2024-07-11 17:00:00'
    and pr.routed_at < '2024-07-12 17:00:00'
    and pi.dst_store_id != pr.store_id

;



with t as
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.staff_info_id
        from rot_pro.parcel_route pr
        where
            pr.marker_category = 79
            and pr.route_action = 'DELIVERY_MARKER'
            and pr.routed_at > '2024-07-11 17:00:00'
            and pr.routed_at < '2024-07-12 17:00:00'
    )
select
    t1.store_id 操作标记网点
    ,t1.store_name 操作标记网点名称
    ,t1.staff_info_id 操作标记员工ID
    ,t1.pno 包裹号
    ,ss.name 包裹归属网点
from t t1
left join
    (
        select
            pcd.old_value
            ,pcd.pno
            ,pcd.created_at
            ,row_number() over (partition by pcd.pno order by pcd.created_at) rk
        from fle_staging.parcel_change_detail pcd
        join
            (
                select t1.pno from t t1 group by t1.pno
            )t1 on t1.pno = pcd.pno
        where
            pcd.created_at > '2024-07-11 17:00:00'
            and pcd.field_name = 'dst_store_id'
    ) a on a.pno = t1.pno and a.rk = 1
left join fle_staging.parcel_info pi on pi.pno = t1.pno
left join fle_staging.sys_store ss on ss.id = coalesce(a.old_value, pi.dst_store_id)
where
    t1.store_id !=  ss.id

;



select
    distinct
    t.pno
    ,if(pr.pno is not null, 'y', 'n') 是否有快递员错分标记
from tmpale.tmp_th_pno_lj_0716 t
left join rot_pro.parcel_route pr on t.pno = pr.pno and pr.marker_category = 79 and pr.route_action = 'DELIVERY_MARKER'
