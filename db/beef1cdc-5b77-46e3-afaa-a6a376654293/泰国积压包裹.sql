select
    *
from
    (
        select
            pr.pno
            ,pr.state
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from fle_dwd.dwd_wide_fle_route_and_parcel_created_at pr
        where
            pr.p_date >= '2022-08-01'
            and pr.p_date < '2022-09-01'

    ) pr
where
    pr.rk = 1
    and pr.state not in (5,7,8,9)

;


select
    pi.pno
    ,pi.state
    ,pi.ticket_pickup_store_id
    ,pi.agent_id
    ,pi.p_date
from fle_dwd.dwd_fle_parcel_info_di pi
where
    pi.p_date >= '2022-01-01'
    and pi.p_date < '2023-01-01'
    and pi.state not in ('5', '7', '8', '9')
