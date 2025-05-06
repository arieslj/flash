with t as
    (
        select
            di.pno
            ,di.store_id
            ,di.created_at
            ,pi.dst_store_id
            ,date (convert_tz(di.created_at, '+00:00', '+08:00')) di_date
            ,pi.ticket_delivery_store_id
        from my_staging.diff_info di
        left join my_staging.parcel_info pi on pi.pno = di.pno
        where
            di.created_at > '2024-05-05 16:00:00'
            and di.created_at < '2024-05-12 16:00:00'
            and di.diff_marker_category = 31
    )

select
    t1.pno
    ,a2.store_id 首次上报网点
    ,if(t1.ticket_delivery_store_id is null,'不确定',if(t1.store_id =t1.ticket_delivery_store_id,'虚假错分','非虚假错分')) `是否虚假错分`
    ,if(a3.pno is not null, '是', '否') 是否修改收件人姓名
    ,a3.store_id 姓名修改网点ID
    ,if(a4.pno is not null, '是', '否') 是否修改收件人电话
    ,a4.store_id 电话修改网点ID
    ,t1.ticket_delivery_store_id 最终派件网点ID
    ,t1.dst_store_id 目的地网点ID
from t t1
left join
    (
        select
            di2.pno
            ,di2.store_id
            ,row_number() over (partition by di2.pno order by di2.created_at) rk
        from my_staging.diff_info di2
        join
            (
                select
                    t1.pno
                from t t1
                group by 1
            ) a1 on di2.pno = a1.pno
        where
            di2.created_at > date_sub(curdate(), interval 2 month)
            and di2.diff_marker_category = 31
    ) a2 on t1.pno = a2.pno and a2.rk = 1
left join
    (
        select
            s1.pno
            ,s1.store_id
        from s s1
        where
            s1.field_name = 'dst_name'
        group by 1,2
    ) a3 on t1.pno = a3.pno
left join
    (
        select
            s1.pno
            ,s1.store_id
        from s s1
        where
            s1.field_name = 'dst_phone'
        group by 1,2
    ) a4 on t1.pno = a4.pno



;



with t as
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.routed_at
            ,pi.created_at
            ,pi.ticket_delivery_store_id
            ,json_extract(pr.extra_value, '$.parcelChangeId') record_id
        from my_staging.parcel_route pr
        join my_staging.parcel_info pi on pi.pno = pr.pno
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and pr.marker_category = 31
            and pi.created_at > '2024-05-05 17:00:00'
            and pi.created_at < '2024-05-12 17:00:00'
            and pr.routed_at > '2024-05-05 17:00:00'
    )

select
    a1.pno
    ,convert_tz(a1.created_at, '+00:00', '+08:00') 包裹揽收时间
    ,ss.name 首次上报网点
    ,if(a1.ticket_delivery_store_id is null, '不确定',if(a1.store_id = a1.ticket_delivery_store_id,'虚假错分','非虚假错分')) `是否虚假错分`
    ,if(pcd.pno is not null, '是', '否') 是否修改收件人电话
    ,t2.pi_cnt  上报次数
    ,convert_tz(a1.routed_at, '+00:00', '+08:00') 包裹上报时间
from
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,row_number() over (partition by t1.pno order by t1.routed_at) rk
                from t t1
            ) a
        where
            a.rk = 1
    ) a1
left join
    (
        select
            pcd.pno
        from my_staging.parcel_change_detail pcd
        join t t1 on t1.record_id = pcd.record_id
        where
            pcd.created_at > '2024-05-05 17:00:00'
            and pcd.field_name in ('dst_phone', 'dst_home_phone')
        group by 1
    ) pcd on a1.pno = pcd.pno
left join
    (
        select
            t1.pno
            ,count(t1.created_at) pi_cnt
        from t t1
        group by 1
    ) t2 on a1.pno = t2.pno
left join my_staging.sys_store ss on ss.id = a1.store_id

