select
    a1.pno 运单
    ,a1.client_id 客户ID
    ,a1.cod
    ,a1.cogs
    ,a1.insure_declare_value 保价金额
    ,a1.ss_name 目的地网点
    ,a1.manager_name 主管
    ,a1.waybillcount ai解析面单拍照次数
    ,a1.waybillReason ai解析面单拍照失败原因
    ,a1.parseParcelCount ai解析包裹拍照次数
    ,a1.parcelReason ai解析包裹拍照失败原因
    ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) 照片
from
    (
        select
            *
        from
            (
                select
                    pr.pno
                    ,pi.client_id
                    ,oi.cod_amount/100 cod
                    ,oi.cogs_amount/100 cogs
                    ,oi.insure_declare_value/100 insure_declare_value
                    ,ss.name ss_name
                    ,ss.manager_name
                    ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') images
                    ,replace(replace(replace(json_extract(pre.extra_value, '$.waybillCount'), '"', ''),'[', ''),']', '')   waybillcount
                    ,replace(replace(replace(json_extract(pre.extra_value, '$.waybillReason'), '"', ''),'[', ''),']', '')  waybillReason
                    ,replace(replace(replace(json_extract(pre.extra_value, '$.parseParcelCount'), '"', ''),'[', ''),']', '') parseParcelCount
                    ,replace(replace(replace(json_extract(pre.extra_value, '$.parcelReason'), '"', ''),'[', ''),']', '') parcelReason
                from ph_staging.parcel_route pr
                join ph_drds.parcel_route_extra pre on pre.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
                left join ph_staging.parcel_info pi on pi.pno = pr.pno
                left join ph_staging.order_info oi on oi.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )
                left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
                where
                    pr.route_action = 'DETAIN_WAREHOUSE'
                    and pre.route_action = 'DETAIN_WAREHOUSE'
                    and pr.routed_at > date_sub(curdate(), interval 32 hour)
                    and pr.routed_at < date_sub(curdate(), interval 8 hour)
                    and json_extract(pre.extra_value, '$.images') is not null
            ) a
            lateral view explode(split(a.images, ',')) a as link_id
    ) a1
left join ph_staging.sys_attachment sa on sa.id = a1.link_id;


