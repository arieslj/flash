-- https://flashexpress.feishu.cn/docx/KQqLdfFe9oihCcx7jRWcR9Njn1c

with t as
    (
        select
            pi.pno
            ,pi.cod_enabled
            ,pi.client_id
            ,dai.delivery_attempt_num
            ,pi.created_at
            ,pi.dst_store_id
            ,pi.duty_store_id
            ,pi.dst_province_code
            ,pi.dst_city_code
            ,pi.dst_district_code
        from
            (
                select
                    pi.pno
                    ,pi.client_id
                    ,pi.cod_enabled
                    ,pi.duty_store_id
                    ,pi.created_at
                    ,pi.dst_store_id
                    ,pi.dst_province_code
                    ,pi.dst_city_code
                    ,pi.dst_district_code
                from ph_staging.parcel_info pi
                join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
                where
                    pi.returned = 0
                    and pi.state in (1,2,3,4,6)
                    and bc.client_name = 'shein'
                    and pi.client_id in ('AA0148', 'AA0149')
            ) pi
        join ph_staging.delivery_attempt_info dai on dai.pno = pi.pno
        join
            (
                select
                    pr.pno
#                     ,json_extract(pr.extra_value, '$.deliveryAttempt') deliveryAttempt
#                     ,json_extract(pr.extra_value, '$.deliveryAttemptNum') deliveryAttemptNum
                from ph_staging.parcel_route pr
                where
                    route_action in ('DELIVERY_TICKET_CREATION_SCAN', 'DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE')
                    and pr.marker_category in (14, 70)
                    and pr.routed_at > date_sub(curdate(), interval 4 day)
                    and json_extract(pr.extra_value, '$.deliveryAttempt') = true
                    and json_extract(pr.extra_value, '$.deliveryAttemptNum') = 3
            ) pr on pr.pno = pi.pno
        where
            dai.delivery_attempt_num >= 3
    )
select
    oi.id 订单号
    ,t1.pno 运单号
    ,if(t1.cod_enabled = 1, '是', '否') 是否COD
    ,t1.client_id 客户ID
    ,t1.delivery_attempt_num 尝试派送次数
    ,pr.mark_reason 标记原因
    ,pr.gy_count 标记改约次数
    ,t1.created_at 揽收日期时间
    ,ps.arrive_dst_route_at 到达目的网点日期时间
    ,sp.name 目的地省
    ,sc.name 目的地市
    ,sd.name 目的地乡
    ,dp.region_name 目的地大区
    ,ss.name 包裹目前所在网点
from t t1
left join
    (
        select
            oi.pno
            ,oi.id
        from ph_staging.order_info oi
        join t t1 on t1.pno = oi.pno
        where
            oi.created_at > date_sub(curdate(), interval 4 month)
    ) oi on oi.pno = t1.pno
left join
    (
        select
            t1.pno
            ,group_concat(distinct ddd.CN_element separator '/') mark_reason
            ,count(if(pr.marker_category in (14, 70), pr.id, null)) gy_count
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
        where
            route_action in ('DELIVERY_TICKET_CREATION_SCAN', 'DIFFICULTY_HANDOVER', 'DETAIN_WAREHOUSE')
           -- and pr.marker_category in (14, 70)
            and pr.routed_at > date_sub(curdate(), interval 4 month)
            and json_extract(pr.extra_value, '$.deliveryAttempt') = true
        group by 1
    ) pr on pr.pno = t1.pno
left join
    (
        select
            ps.pno
            ,ps.arrive_dst_route_at
        from ph_bi.parcel_sub ps
        join t t1 on t1.pno = ps.pno and ps.arrive_dst_store_id = t1.dst_store_id
        where
            ps.arrive_dst_route_at > '1970-01-01 00:00:00'
    ) ps on ps.pno = t1.pno
left join ph_staging.sys_store ss on ss.id = t1.duty_store_id
left join ph_staging.sys_province sp on sp.code = t1.dst_province_code
left join ph_staging.sys_city sc on sc.code = t1.dst_city_code
left join ph_staging.sys_district sd on sd.code = t1.dst_district_code
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.dst_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)

