select
    count(oi.pno) `总包裹量`
    ,count(`if`(pi.state = 5, pi.pno, null)) `成功妥投量`
    ,count(`if`(pi.state = 7, pi.pno, null)) `退件量`
    ,count(`if`(los.pno is not null , pi.pno, null)) `丢失包裹量`
    ,count(`if`(det.pno is not null , pi.pno, null)) `短少量`
from
    (
        select
            oi.pno
        from fle_dwd.dwd_fle_order_info_di oi
        where
            oi.p_date >= '2022-04-03'
            and oi.src_phone = '09178104049'
            and oi.cogs_amount > 500000
    )  oi
left join
    (
        select
            pi.pno
            ,pi.state
            ,pi.returned
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-05-03'
            and pi.src_phone = '09178104049'
    ) pi on pi.pno = oi.pno
left join
    (
        select
            pr.pno
        from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
        where
            pr.p_date >= '2022-05-03'
            and pr.route_action = 'LOSE_PARCEL_TEAM_OPERATION'
        group by 1
    ) los on los.pno = pi.pno
left join
    (
        select
            pr.pno
        from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
        where
            pr.p_date >= '2022-05-03'
            and pr.route_action = 'DISCARD_RETURN_BKK'
        group by 1
    ) bkk on bkk.pno = pi.pno
left join
    (
        select
            pr.pno
        from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
        where
            pr.p_date >= '2022-05-03'
            and pr.route_action = 'DIFFICULTY_HANDOVER'
            and pr.marker_category in ('6','21')
        group by 1
    ) det