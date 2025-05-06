with t as
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.routed_at
            ,pi.client_id
            ,if(pi.returned = 1, pi.customary_pno, pi.pno) ori_pno
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
        from my_staging.parcel_route pr
        left join my_staging.parcel_info pi on pi.pno = pr.pno
        where
            pr.routed_at > '2023-12-31 16:00:00'
            and  pr.route_action = 'REPLACE_PNO'
            and pr.store_category in (8,12)
    )
, cn as
    (
        select
            a1.pno
            ,pcd.field_name
            ,pcd.old_value
            ,pcd.new_value
        from
            (
                select
                    a.*
                    ,json_extract(a.extra_value, '$.parcelChangeId')  parcelChangeId
                from
                    (
                        select
                            pr.pno
                            ,pr.extra_value
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                        from my_staging.parcel_route pr
                        join t t1 on t1.pno = pr.pno
                        where
                            pr.route_action = 'CHANGE_PARCEL_INFO'
                            and pr.routed_at > '2023-12-31 16:00:00'
                            and pr.routed_at < t1.routed_at
                    ) a
                where
                    a.rk = 1
            ) a1
        left join my_staging.parcel_change_detail pcd on pcd.record_id = a1.parcelChangeId
    )
select
    t1.pno 单号
    ,t1.client_id
    ,if(dtj.pno is null, 'y', 'n') 包裹有待退件标记
    ,if(dstss.pno is not null and fc.pno is not null, 'y', 'n') '包裹目的地网点变更+复称'
    ,if(dstss.pno is not null and ads.pno is not null, 'y', 'n') '包裹目的地网点变更+收件人地址变更'
    ,if(dstss.pno is null and ads.pno is null and oth.pno is not null, 'y', 'n' ) '修改包裹信息-其他'
    ,if(dam.pno is not null, 'y', 'n')  提交破损
    ,if(pai.parcel_miss_enabled = 1, 'y', 'n') 包裹有丢弃标记
    ,if(bc.client_name = 'lazada' and oi.pno is null, 'y', null) '客户类型为Lazada，包裹下单未经过预下单'
    ,if(p2.sub_channel_category = 14, 'y', 'n') ‘扫描单号为喵喵机’
    ,if(s1.id != s2.id, 'y', 'n') '预下单返回目的地网点与确认下单返回目的地网点不一致'
    ,if(s1.category = 1 and s2.category = 10, 'y', null) '确认下单返回目的地网点为大件网点，预下单返回目的地网点为小件网点'
from t t1
left join
    (
        select
            pr.pno
        from my_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > '2023-12-31 16:00:00'
            and pr.route_action = 'PENDING_RETURN'
        group by 1
    ) dtj on dtj.pno = t1.pno
left join
    (
        select
            c1.pno
        from cn c1
        where
            c1.field_name = 'dst_store_id'
        group by 1
    ) dstss on dstss.pno = t1.pno
left join
    (
        select
            c1.pno
        from cn c1
        where
            c1.field_name in ('exhibition_weight', 'courier_weight', 'store_weight', 'exhibition_length', 'courier_length', 'store_length', 'exhibition_width', 'courier_width', 'store_width', 'exhibition_height', 'courier_height', 'store_height')
        group by 1
    ) fc on fc.pno = t1.pno
left join
    (
        select
            c1.pno
        from cn c1
        where
            c1.field_name = 'dst_detail_address'
        group by 1
    ) ads on ads.pno = t1.pno
left join
    (
        select
            c1.pno
        from cn c1
        where
            c1.field_name not in ('dst_store_id','dst_detail_address','exhibition_weight', 'courier_weight', 'store_weight', 'exhibition_length', 'courier_length', 'store_length', 'exhibition_width', 'courier_width', 'store_width', 'exhibition_height', 'courier_height', 'store_height')
    ) oth on oth.pno = t1.pno
left join
    (
        select
            di.pno
        from my_staging.diff_info di
        join t t1 on t1.pno = di.pno
        where
            di.created_at > '2023-12-31 16:00:00'
            and di.store_id = t1.store_id
            and di.diff_marker_category = 20
        group by 1
    ) dam on dam.pno = t1.pno
left join my_staging.parcel_additional_info pai on pai.pno = t1.ori_pno
left join my_staging.order_info oi on oi.pno = t1.ori_pno
left join my_staging.parcel_info p2 on p2.pno = t1.ori_pno
left join my_staging.sys_store s1 on s1.id  = oi.dst_store_id
left join my_staging.sys_store s2 on s2.id  = p2.dst_store_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id




;

select
    pcd.field_name
from my_staging.parcel_change_detail pcd
where
    pcd.created_at > '2024-01-01'
group by 1

；