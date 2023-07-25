with t as
(
    select
            pr.state
            ,pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join
            (
                select
                    plt.pno
                from ph_bi.parcel_lose_task plt
                where
                    plt.state = 6
                group by 1
            ) plt on plt.pno = pr.pno
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval  8 hour)
)
select
    a.pno
from
    (
        select
            t1.*
            ,t2.state t2_state
        from
            (
                select
                    t1.*
                from t t1
                where
                    t1.state = 2
                    and t1.routed_at > date_sub(curdate(), interval 8 hour)
            ) t1
        left join t t2 on t2.pno = t1.pno and t2.rk = t1.rk - 1
    ) a
where
    a.t2_state = 8
group by 1



;


select
    am.pno
    ,ss.name 目的地网点
from ph_bi.abnormal_message am
left join ph_staging.parcel_info pi on am.pno  = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    am.abnormal_time > '2023-07-01'
    and am.isdel = 0
    and am.isappeal != 5
    and am.punish_category = 34
    and pi.dst_store_id != 'PH36100100'
group by 1,2