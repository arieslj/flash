select
    pre.*
from
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].aiPodCount') AS ai_count_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[1].aiPodCount') as ai_count_2
        from rot_pro.parcel_route pr
        join fle_staging.parcel_info pi on pi.pno = pr.pno
        left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
        where
            pr.routed_at > '2025-02-27 17:00:00'
            and pr.routed_at < '2025-02-28 17:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
            and dpr.created_at > '2025-02-01'
            and pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.client_id in ('AA0461','AA0731','AA0477','AA0752','AA0612','AA0853','AA0771','AA0650','AA0330','AA0574','AA0794','AA0838','AA0657','AA0415','CBD1993','AA0601','AA0622','AA0386','AA0661','AA0660','AA0662','AA0906','AA0546','AA0442','AA0606','AA0707','AA0427','AA0823','AA0569','AA0649','AA0703','AA0824','AA0428','AA0904')
           -- and pr.pno = 'THT68141J00F15Z'
    ) pre
where
    pre.ai_count_1 >= 10
    or pre.ai_count_2 >= 10

;


select
    pre.*
from
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].aiPodCount') AS ai_count_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[1].aiPodCount') as ai_count_2
            ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) distance
        from rot_pro.parcel_route pr
        join fle_staging.parcel_info pi on pi.pno = pr.pno
        left join fle_staging.sys_store ss on ss.id = pr.store_id
        left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
        where
            pr.routed_at > '2025-02-27 17:00:00'
            and pr.routed_at < '2025-02-28 17:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
            and dpr.created_at > '2025-02-01'
            and pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.client_id in ('AA0461','AA0731','AA0477','AA0752','AA0612','AA0853','AA0771','AA0650','AA0330','AA0574','AA0794','AA0838','AA0657','AA0415','CBD1993','AA0601','AA0622','AA0386','AA0661','AA0660','AA0662','AA0906','AA0546','AA0442','AA0606','AA0707','AA0427','AA0823','AA0569','AA0649','AA0703','AA0824','AA0428','AA0904')
           -- and pr.pno = 'THT68141J00F15Z'
    ) pre
where
    pre.ai_count_1 < 10
    and pre.ai_count_2 < 10
    and pre.distance < 200


;



select
    pre.*
from
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].aiPodCount') AS ai_count_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[1].aiPodCount') as ai_count_2
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].noBill') nobill_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].waybillNumberAvailability') waybillNumberAvailability_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].waybillNumberConsistency')  waybillNumberConsistency_1
         --   ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) distance
        from rot_pro.parcel_route pr
        join fle_staging.parcel_info pi on pi.pno = pr.pno
        left join fle_staging.sys_store ss on ss.id = pr.store_id
        left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
        where
            pr.routed_at > '2025-02-27 17:00:00'
            and pr.routed_at < '2025-02-28 17:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
            and dpr.created_at > '2025-02-01'
            and pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.client_id in ('AA0461','AA0731','AA0477','AA0752','AA0612','AA0853','AA0771','AA0650','AA0330','AA0574','AA0794','AA0838','AA0657','AA0415','CBD1993','AA0601','AA0622','AA0386','AA0661','AA0660','AA0662','AA0906','AA0546','AA0442','AA0606','AA0707','AA0427','AA0823','AA0569','AA0649','AA0703','AA0824','AA0428','AA0904')
           -- and pr.pno = 'THT68141J00F15Z'
    ) pre
where
    pre.ai_count_1 < 10
    and pre.ai_count_2 < 10
    and (pre.nobill_1 = 1.0 or ( pre.waybillNumberConsistency_1 = 1 and  pre.waybillNumberAvailability_1 = 0 ))


;





select
    pre.*
from
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].aiPodCount') AS ai_count_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[1].aiPodCount') as ai_count_2
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].noBill') nobill_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].billAreaRatio') billAreaRatio_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[1].billAreaRatio') billAreaRatio_2
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[1].parcelAreaRatio')  parcelAreaRatio_2
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].simpleColor') simpleColor_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[1].simpleColor') simpleColor_2
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].lowQuality') lowQuality_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[1].lowQuality') lowQuality_2
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].waybillNumberAvailability') waybillNumberAvailability_1
            ,json_extract(dpr.extra_value , '$.deliveryImageAiScore[0].waybillNumberConsistency')  waybillNumberConsistency_1
            ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) distance
        from rot_pro.parcel_route pr
        join fle_staging.parcel_info pi on pi.pno = pr.pno
        left join fle_staging.sys_store ss on ss.id = pr.store_id
        left join dwm.drds_parcel_route_extra dpr on dpr.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId')
        where
            pr.routed_at > '2025-02-27 17:00:00'
            and pr.routed_at < '2025-02-28 17:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
            and dpr.created_at > '2025-02-01'
            and pi.created_at > date_sub(curdate(), interval 3 month)
            and pi.client_id in ('AA0461','AA0731','AA0477','AA0752','AA0612','AA0853','AA0771','AA0650','AA0330','AA0574','AA0794','AA0838','AA0657','AA0415','CBD1993','AA0601','AA0622','AA0386','AA0661','AA0660','AA0662','AA0906','AA0546','AA0442','AA0606','AA0707','AA0427','AA0823','AA0569','AA0649','AA0703','AA0824','AA0428','AA0904')
           -- and pr.pno = 'THT68141J00F15Z'
    ) pre
where
    pre.ai_count_1 < 10
    and pre.ai_count_2 < 10
    and pre.distance < 200
    and
        (
            ( pre.nobill_1 = 0 and pre.waybillNumberAvailability_1 = 1 and pre.billAreaRatio_1 > 0.3 )
            or ( pre.simpleColor_1 = true or pre.simpleColor_2 = true )
            or ( pre.lowQuality_1  != 0 or pre.lowQuality_2 != 0 )
            or ( pre.parcelAreaRatio_2 >= 0.5 and pre.billAreaRatio_2 >= 0.5 )
        )