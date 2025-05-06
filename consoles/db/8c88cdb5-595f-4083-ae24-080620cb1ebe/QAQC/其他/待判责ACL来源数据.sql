select
    a.pno
from
    (
                select
            a.pno
            ,a.ss_lat
            ,a.ss_lng
            ,json_extract(a.extra_value, '$.lat') lat
            ,json_extract(a.extra_value, '$.lng') lng
        from
            (
                select
                    a1.pno
                    ,pr.extra_value
                    ,ss.lat ss_lat
                    ,ss.lng ss_lng
                    ,row_number() over (partition by a1.pno order by pr.routed_at desc) as rn
                from
                    (
                        select
                            plt.pno
                            ,plt.created_at
                            ,plt.last_valid_action
                            ,plt.last_valid_store_id
                            ,date_sub(plt.created_at, interval 7 hour) low_create_at
                        from bi_pro.parcel_lose_task plt
                        where
                            plt.state < 5
                            and plt.source in (1,3,12)
                            and plt.last_valid_action in ('INVENTORY', 'DETAIN_WAREHOUSE')
                    ) a1
                left join rot_pro.parcel_route pr on pr.pno = a1.pno and pr.routed_at <= a1.low_create_at and pr.route_action = a1.last_valid_action
                left join fle_staging.sys_store ss  on ss.id = a1.last_valid_store_id
            ) a
        where
            a.rn = 1
    ) a
where
    st_distance_sphere(point(a.lng, a.lat), point(a.ss_lng, a.ss_lat)) > 1000