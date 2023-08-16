SELECT
pr.pno
,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key)) url

from
    (
        select
            pr.pno
            ,json_extract(pr.extra_value,'$.routeExtraId') routeExtraId
        from ph_staging.parcel_route pr
        where
            pr.route_action ='DIFFICULTY_HANDOVER'
            and pr.marker_category in (5,20)
            and pr.created_at > '2023-05-31 16:00:00'
    )pr
left join
    (
        select
            pre.pno
            ,pre.route_extra_id
            ,c
        from
        (
            select
                pre.pno
                ,pre.route_extra_id
                ,replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') value
            from dwm.drds_ph_parcel_route_extra pre
            where
                pre.created_at > '2023-05-31 16:00:00'
#                 and pre.created_at<'2023-04-01'
        )pre
        lateral view explode(split(pre.value, ',')) id as c
    )pre on pr.routeExtraId=pre.route_extra_id
left join ph_staging.sys_attachment sa on sa.id=pre.c
group by 1
;


select
    *
from ph_backyard.message_warning mw
left join ph_backyard.staff_warning_message swm on swm.warning_no = mw.staff_warning_message_no

where
    mw.created_at >= '2023-06-01'