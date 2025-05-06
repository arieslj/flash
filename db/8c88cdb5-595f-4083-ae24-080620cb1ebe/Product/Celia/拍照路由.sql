
with t as
(
    select
        pr.pno
        ,pr.routed_at
        ,pr.id
        ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
    from rot_pro.parcel_route pr
    left join dwm.drds_parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
    where
        pr.route_action = 'TAKE_PHOTO'
        and pr.routed_at > '2023-10-17 17:00:00'
        and json_extract(pr.extra_value, '$.forceTakePhotoCategory') = 3
        -- and pr.routed_at < '2023-06-30 17:00:00'
)
select
    a2.CN_element
    ,a2.pno
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com//',sa.object_key) 图片
from
    (
        select
            a1.*
            ,link_id
        from
            (
                select
                    ddd.CN_element
                    ,a.valu
                    ,a.pno
                from
                    (
                        select
                            t1.pno
                            ,t1.id
                            ,pr2.remark
                            ,t1.valu
                            ,row_number() over (partition by pr2.pno order by pr2.routed_at desc) rk
                        from rot_pro.parcel_route pr2
                        join t t1 on pr2.pno = t1.pno
                        where
                            pr2.routed_at < t1.routed_at
                            and pr2.route_action = 'FORCE_TAKE_PHOTO'
                            and pr2.routed_at > '2023-10-17 17:00:00'
                            -- and pr2.routed_at < '2023-06-30 17:00:00'
                #             and pr2.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                    ) a
                left join dwm.dwd_dim_dict ddd on ddd.element = a.remark and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                where
                    a.rk = 1
                    -- and ddd.CN_element in (/*'收件入仓',*/ '发件出仓扫描'/*,'交接扫描'*/)
                    and a.remark = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a1
            lateral view explode(split(a1.valu, ',')) id as link_id
    ) a2
left join fle_staging.sys_attachment sa on sa.id = a2.link_id
