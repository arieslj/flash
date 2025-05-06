select
        a.*
    from
        (
            select
                a1.dst_store_id
                ,a1.pno
                ,a1.sorting_code
                ,td.created_at td_time
                ,td.staff_info_id
                ,pi.state
                ,pi.finished_at
                ,pi.ticket_delivery_staff_info_id
                ,row_number() over (partition by td.pno order by td.created_at desc ) rn
            from
                (
                    select
                        a.*
                    from
                        (
                            select
                                ds.pno
                                ,ds.dst_store_id
                                ,ps.sorting_code
                                ,row_number() over (partition by ps.pno order by ps.created_at desc ) rk
                            from dwm.dwd_th_dc_should_be_delivery ds
                            join dwm.drds_parcel_sorting_code_info ps on ds.pno =  ps.pno and ds.dst_store_id = ps.dst_store_id
                        ) a
                    where
                        a.rk = 1
                ) a1
            join fle_staging.ticket_delivery td on td.pno = a1.pno and td.created_at >= date_sub('${date}', interval 7 hour) and td.created_at < date_add('${date}', interval 17 hour)
            left join fle_staging.parcel_info pi on pi.pno = a1.pno
        ) a
    where
        a.rn = 1
        and a.staff_info_id = '3800529'