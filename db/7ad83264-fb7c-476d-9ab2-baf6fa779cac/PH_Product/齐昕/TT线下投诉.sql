with t as
    (
        select
            pi.pno
            ,pi.ticket_delivery_staff_info_id
            ,hsi.name
            ,pi.dst_store_id
            ,pi.finished_at
            ,pi.cod_amount
            ,date (convert_tz(pi.finished_at, '+00:00', '+08:00')) fin_date
        from ph_staging.parcel_info pi
        join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
        left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_delivery_staff_info_id
        where
            pi.finished_at >= date_sub(curdate(), interval 32 hour)
            and pi.finished_at < date_sub(curdate(), interval 8 hour)
            and pi.state = 5
            and pi.returned = 0
            and bc.client_name = 'tiktok'
    )
select
    *
from
    (
                select
            t1.pno
            ,t1.cod_amount/100 cod
            ,oi.cogs_amount/100 cogs
            ,dai.delivery_attempt_num 尝试派送次数
            ,if(p1.pno is not null, 'y', 'n') 是否有打电话
            ,if(p2.pno is not null, 'y', 'n') 是否打通电话
            ,if(p3.pno is not null,  'y', 'n') 是否接电话
            ,timestampdiff(second , ps.arrive_dst_route_at, t1.finished_at)/3600 + 8 目的地网点的时长
            ,la.CN_element 最后一次的派件标记的原因
            ,ss.name 目的地网点

            ,t1.name 快递员
            ,work.cnt 快递员当日的工作量
            ,t1.ticket_delivery_staff_info_id 快递员的工号
            ,ro.roles 全部角色
            ,if(plt.pno is not null, '是', '否') 是否有判责丢失
        from t t1
        left join ph_staging.order_info oi on oi.pno = t1.pno
        left join ph_staging.delivery_attempt_info dai on dai.pno = t1.pno
        left join ph_staging.sys_store ss on ss.id = t1.dst_store_id
        left join
            (
                select
                    pr.pno
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > date_sub(curdate(), interval 2 month )
                    and pr.route_action = 'PHONE'
                group by pr.pno
            ) p1 on p1.pno = t1.pno
        left join
            ( -- 有通话
                select
                    pr.pno
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > date_sub(curdate(), interval 2 month )
                    and pr.route_action = 'PHONE'
                    and json_extract(pr.extra_value, '$.callDuration') > 0
                group by pr.pno
            ) p2 on p2.pno = t1.pno
        left join
            ( -- 接电话
                select
                    pr.pno
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.routed_at > date_sub(curdate(), interval 2 month )
                    and pr.route_action = 'INCOMING_CALL'
                    and json_extract(pr.extra_value, '$.callDuration') > 0
                group by pr.pno
            ) p3 on p3.pno = t1.pno
        left join ph_bi.parcel_sub ps on ps.pno = t1.pno
        left join
            (
                select
                    pr.pno
                    ,ddd.CN_element
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                left join dwm.dwd_dim_dict ddd on ddd.element = pr.marker_category and ddd.db = 'ph_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
                where
                    pr.routed_at > date_sub(curdate(), interval 2 month )
                    and pr.route_action = 'DELIVERY_MARKER'
            ) la on la.pno = t1.pno and la.rk = 1
        left join
            (
                select
                    plt.pno
                from ph_bi.parcel_lose_task plt
                join t t1 on t1.pno = plt.pno
                where
                    plt.created_at > date_sub(curdate(), interval 2 month )
                    and plt.state = 6
                    and plt.duty_result = 1
                group by 1
            ) plt on plt.pno = t1.pno
        left join
            (
                select
                    t1.ticket_delivery_staff_info_id
                    ,t1.fin_date
                    ,count(distinct pr.pno) cnt
                from ph_staging.parcel_route pr
                join t t1 on t1.ticket_delivery_staff_info_id = pr.staff_info_id
                where
                    pr.routed_at > date_sub(curdate(), interval 2 month )
                    and pr.route_action = 'DELIVERY_CONFIRM'
                    and pr.routed_at > date_sub(t1.fin_date, interval 8 hour)
                    and pr.routed_at < date_add(t1.fin_date, interval 16 hour)
                group by 1,2
            ) work on work.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id and work.fin_date = t1.fin_date
        left join
            (
                select
                    t1.ticket_delivery_staff_info_id
                    ,group_concat(distinct r.name) roles
                from ph_bi.hr_staff_info_position hp
                join t t1 on t1.ticket_delivery_staff_info_id = hp.staff_info_id
                left join ph_bi.roles r on r.id = hp.position_category
                group by 1
            ) ro on ro.ticket_delivery_staff_info_id = t1.ticket_delivery_staff_info_id
    ) a
where
    a.快递员当日的工作量 in (41,46,51,56,61,66,71,76,81)
    and a.尝试派送次数 is null
    and (a.cod is null or a.cod = 0)
    and ( a.是否打通电话 = 'n' or a.是否接电话 = 'n')


;


select
    distinct
    plt.pno
from ph_bi.parcel_lose_task plt
where
    plt.state = 6
    and plt.duty_result = 1
    -- updated_at限定判责时间，创建时间限定创建时间