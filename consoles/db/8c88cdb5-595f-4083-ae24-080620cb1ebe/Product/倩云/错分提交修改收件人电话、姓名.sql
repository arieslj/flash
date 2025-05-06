with t as
    (
        select
            di.pno
            ,di.store_id
            ,di.created_at
            ,pi.dst_store_id
            ,date (convert_tz(di.created_at, '+00:00', '+07:00')) di_date
            ,pi.ticket_delivery_store_id
        from fle_staging.diff_info di
        left join fle_staging.parcel_info pi on pi.pno = di.pno
        where
            di.created_at > '2024-04-28 17:00:00'
            and di.created_at < '2024-05-05 17:00:00'
            and di.diff_marker_category = 31
    )
, s as
    (
        select
            t1.pno
            ,pr.store_id
            ,pcd.field_name
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join fle_staging.parcel_change_detail pcd on pcd.record_id = json_extract(pr.extra_value, '$.parcelChangeId')
        where
            pr.route_action = 'CHANGE_PARCEL_INFO'
            and pr.routed_at < date_add(t1.di_date, interval 17 hour)
            and pr.routed_at > date_sub(t1.di_date, interval 7 hour)
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
        from fle_staging.diff_info di2
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
