with t as
(
        select
            pr.pno
            ,pr.routed_at
        from ph_staging.parcel_route pr
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
        where
            pr.routed_at > '2023-08-07 16:00:00'
        group by 1,2
)
select
    pr.pno
    ,concat(kp.id, kp.name) Customer
    ,convert_tz(pi.created_at, '+00:00', '+08:00') Pickup_date
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') Close_date

from ph_bi.parcel_lose_task plt
join t t1 on t1.pno = pr.pno and pr.routed_at < t1.routed_at
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
where
    pr.route_action = 'CHANGE_PARCEL_CLOSE'
    and pr.store_id = '130' -- QAQC操作
    and pr.routed_at > date_sub(curdate() ,interval 180 day) -- 半年内
group by 1


;


select
    a.pno
    ,concat(a.id, a.name) Customer
    ,a.parcel_created_at Pickup_date
    ,a.updated_at Close_date
    ,a.dc Responsible_dc
    ,convert_tz(a.routed_at, '+00:00', '+08:00') Effective_status_date
    ,dp.store_name Effective_status_dc
    ,dp.piece_name District
    ,dp.region_name Area
    ,ddd.EN_element Parcel_status
from
    (
        select
            a1.*
            ,row_number() over (partition by a1.pno order by a1.routed_at) rk
        from
            (
                select
                    plt.pno
                    ,kp.id
                    ,kp.name
                    ,plt.parcel_created_at
                    ,plt.updated_at
                    ,pr.routed_at
                    ,pr.store_id
                    ,group_concat(distinct ss.name) dc
        #             ,row_number() over (partition by plt.pno order by pr.routed_at) rk
                from ph_bi.parcel_lose_task plt
                left join ph_staging.ka_profile kp on kp.id = plt.client_id
                join ph_staging.parcel_route pr on plt.pno = pr.pno
                join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.remark = 'valid'
                left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
                left join ph_staging.sys_store ss on ss.id = plr.store_id
                where
                    plt.state = 6
                    and plt.duty_result = 1
                    and pr.routed_at > date_sub(plt.updated_at, interval 8 hour )
                    and pr.routed_at >= date_format(now() ,'%y-%m-01')
                    and pr.routed_at < curdate()
                group by 1,2,3,4,5,6,7
            ) a1
    ) a
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_info pi on pi.pno = a.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pi.state and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_info' and ddd.fieldname = 'state'
where
    a.rk = 1