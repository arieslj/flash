 -- 一个账号多设备登录操作交接妥投
with t as
    (
        select
            a1.staff_info_id
             ,a1.device_id
             ,date_format(a1.created_at, '%Y-%m-%d %H:%i:%s') created_at
             ,a1.ldr_date
             ,date_format(ifnull(a1.next_created_at, concat(a1.ldr_date, ' 16:59:59')), '%Y-%m-%d %H:%i:%s')  next_created_at
             ,a1.next_device_id
        from
            (
                select
                    ldr.staff_info_id
                    ,ldr.device_id
                    ,ldr.created_at
                    ,date(convert_tz(ldr.created_at, '+00:00', '+07:00')) ldr_date
                    ,lead(ldr.created_at, 1) over (partition by ldr.staff_info_id, date(convert_tz(ldr.created_at, '+00:00', '+07:00')) order by ldr.created_at) next_created_at
                    ,lead(ldr.device_id, 1) over (partition by ldr.staff_info_id, date(convert_tz(ldr.created_at, '+00:00', '+07:00')) order by ldr.created_at) next_device_id
                from fle_staging.login_device_record ldr
                join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
                where
                    ldr.created_at > '2024-04-14 17:00:00'
                    and ldr.created_at < '2024-04-21 17:00:00'
                    and hsi.hire_type = 13
            ) a1
    )
select
    a.ldr_date
    ,a.staff_info_id
    ,count(distinct a.device_id) as device_cnt
from
    (
        select
            t1.staff_info_id
            ,t1.ldr_date
            ,t1.created_at
            ,t1.device_id
            ,t1.next_created_at
            ,sc.pno_cnt
            ,con.pno_cnt as con_pno_cnt
        from t t1
        left join
            (
                select
                    t1.staff_info_id
                    ,t1.created_at
                    ,t1.next_created_at
                    ,t1.device_id
                    ,t1.ldr_date
                    ,count(distinct pr.pno) pno_cnt
                from rot_pro.parcel_route pr
                join t t1 on t1.staff_info_id = pr.staff_info_id
                where
                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                    and pr.routed_at > '2024-04-14 17:00:00'
                    and pr.routed_at < '2024-04-21 17:00:00'
                    and pr.routed_at > t1.created_at
                    and pr.routed_at < t1.next_created_at
                group by 1,2,3,4,5
            ) sc on sc.staff_info_id = t1.staff_info_id and sc.ldr_date = t1.ldr_date and sc.created_at = t1.created_at and sc.next_created_at = t1.next_created_at
        left join
            (
                select
                    t1.staff_info_id
                    ,t1.created_at
                    ,t1.next_created_at
                    ,t1.device_id
                    ,t1.ldr_date
                    ,count(distinct pr.pno) pno_cnt
                from rot_pro.parcel_route pr
                join t t1 on t1.staff_info_id = pr.staff_info_id
                where
                    pr.route_action = 'DELIVERY_CONFIRM'
                    and pr.routed_at > '2024-04-14 17:00:00'
                    and pr.routed_at < '2024-04-21 17:00:00'
                    and pr.routed_at > t1.created_at
                    and pr.routed_at < t1.next_created_at
                group by 1,2,3,4,5
            ) con on con.staff_info_id = t1.staff_info_id and con.ldr_date = t1.ldr_date and con.created_at = t1.created_at and con.next_created_at = t1.next_created_at
        where
            sc.pno_cnt > 0
            and con.pno_cnt > 0
    ) as a
group by 1,2
having count(distinct a.device_id) > 1

;







with t as
    (
        select
            a1.staff_info_id
            ,a1.hire_type
            ,a1.device_id
            ,date_format(a1.created_at, '%Y-%m-%d %H:%i:%s') created_at
            ,a1.ldr_date
            ,date_format(ifnull(a1.next_created_at, concat(a1.ldr_date, ' 16:59:59')), '%Y-%m-%d %H:%i:%s')  next_created_at
        from
            (
                select
                    ldr.staff_info_id
                    ,hsi.hire_type
                    ,ldr.device_id
                    ,date(convert_tz(ldr.created_at, '+00:00', '+07:00')) ldr_date
                    ,ldr.created_at
                    ,lead(ldr.created_at, 1) over (partition by ldr.staff_info_id, date(convert_tz(ldr.created_at, '+00:00', '+07:00')) order by ldr.created_at) next_created_at
                from fle_staging.login_device_record ldr
                left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
                where
                    ldr.created_at > '2024-04-14 17:00:00'
                    and ldr.created_at < '2024-04-21 17:00:00'
            ) a1
    )
, s as
    (
        select
            t1.staff_info_id
            ,t1.device_id
            ,t1.ldr_date
            ,t1.hire_type
        from t t1
        left join
            (
                select
                    t1.staff_info_id
                    ,t1.created_at
                    ,t1.next_created_at
                    ,t1.device_id
                    ,t1.ldr_date
                    ,count(distinct pr.pno) pno_cnt
                from rot_pro.parcel_route pr
                join t t1 on t1.staff_info_id = pr.staff_info_id
                where
                    pr.route_action = 'DELIVERY_CONFIRM'
                    and pr.routed_at > '2024-04-14 17:00:00'
                    and pr.routed_at < '2024-04-21 17:00:00'
                    and pr.routed_at > t1.created_at
                    and pr.routed_at < t1.next_created_at
                group by 1,2,3,4,5
            ) con on con.staff_info_id = t1.staff_info_id and con.ldr_date = t1.ldr_date and con.created_at = t1.created_at and con.next_created_at = t1.next_created_at
        where
            con.pno_cnt > 0
        group by 1,2,3,4
    )
select
    s1.*
from s s1
left join
    (
        select
            *
        from s s1
        where
            s1.hire_type = 13
    ) a1 on a1.ldr_date = s1.ldr_date and a1.device_id = s1.device_id
join
    (
        select
            *
        from s s2
        where
            s2.hire_type != 14
    ) a2 on a2.ldr_date = s1.ldr_date and a2.device_id = s1.device_id
where
    a1.device_id is not null
    or a2.device_id is not null
;























;

