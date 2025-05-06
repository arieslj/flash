select
    pre_1.pno 运单号
    ,pre_1.pickup_time 揽收时间
    ,pre_1.remark 异常件类型
    ,pre_1.client_id 客户ID
    ,pre_1.store_name 上报分拨
    ,pre_1.route_action 路由动作
    ,group_concat(distinct concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa.object_key)) 图片链接
from
    (
        select
            pre.*
            ,link
        from
            (
                select
                    pr.pno
                    ,pr.route_action
                    ,convert_tz(pi.created_at, '+00:00', '+07:00') pickup_time
                    ,pr.remark
                    ,pi.client_id
                    ,pr.store_name
                    ,replace(replace(replace(json_extract(dpr.extra_value, '$.images'), '"', ''),'[', ''),']', '') value
                from rot_pro.parcel_route pr
                join fle_staging.parcel_info pi on pi.pno = pr.pno
                left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
                where

                    pi.client_id = 'AA0906'
                    and pr.routed_at > date_sub(date_sub(curdate(), interval 35 day), interval 7 hour)
                    and pr.store_id in ('TH02030121', 'TH02030307') -- 88,99 HUB
                    and dpr.created_at > date_sub(date_sub(curdate(), interval 35 day), interval 7 hour)
                    and ( pr.route_action = 'REPAIRED' or pr.marker_category = 20 )
                  -- and pr.pno = 'CNTHF000134192'
            ) pre
        lateral view explode(split(pre.value, ',')) id as link
    ) pre_1
left join fle_staging.sys_attachment sa on sa.id = pre_1.link and sa.created_at > date_sub(date_sub(curdate(), interval 35 day), interval 7 hour)
group by 1,2,3,4,5