select
    count(1)
from
    (
        select
            pr.pno
            ,convert_tz(pr.routed_at, '+00:00', '+07:00') pr_time
            ,json_extract(pr.extra_value, '$.startTime') start_time
            ,cast(json_extract(pr.extra_value, '$.callDuration') as int) call_duration
            ,cast(json_extract(pr.extra_value, '$.diaboloDuration') as int) diabolo_duration
            ,cast(json_extract(pr.extra_value, '$.callDuration') as int)  + cast(json_extract(pr.extra_value, '$.diaboloDuration') as int) total
        from rot_pro.parcel_route pr
        where
            pr.routed_at > '2025-01-31 17:00:00'
            and pr.routed_at < '2025-02-28 17:00:00'
            and pr.route_action in ('PHONE', 'INCOMING_CALL')
          --  and pr.pno = 'TH76076WRYMV7A'
    ) pr
where
    pr.pr_time < date_add(pr.start_time, interval pr.call_duration + pr.diabolo_duration second)
