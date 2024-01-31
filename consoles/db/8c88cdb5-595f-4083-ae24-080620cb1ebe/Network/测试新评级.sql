with sa as
    (
        select
            swa.staff_info_id
            ,swa.organization_id
        from backyard_pro.staff_work_attendance swa
        join fle_staging.sys_store ss on ss.id = swa.organization_id and ss.delivery_frequency = 2
        where
            swa.attendance_date = '${date}'
            and ( swa.started_at is not null  or swa.end_at is not null ) -- 出勤人数
            and swa.job_title in (13,110,452) -- van\bike\boat
    )
select
    a2.region_name 大区
    ,a2.piece_name 片区
    ,a2.organization_id 网点ID
    ,a2.store_name 网点
    ,a2.work_staff 出勤人数
    ,a2.back_staff 二派返回网点人数
    ,a2.staff_ratio 二派返回网点比例
    ,case
        when a2.staff_ratio < 0.5 or a2.staff_ratio is null then 0
        when a2.staff_ratio >= 0.5 and a2.staff_ratio < 0.55 then 2
        when a2.staff_ratio >= 0.55 and a2.staff_ratio < 0.6 then 5
        when a2.staff_ratio >= 0.6 then 10
    end 打分
from
    (
        select
            s2.organization_id
            ,dt.store_name
            ,dt.piece_name
            ,dt.region_name
            ,count(s2.staff_info_id) work_staff
            ,count(if(a1.staff_info_id is not null, s2.staff_info_id, null)) back_staff
            ,count(if(a1.staff_info_id is not null, s2.staff_info_id, null))/count(s2.staff_info_id) staff_ratio
        from sa s2
        left join
            (
                select
                    bef.organization_id
                    ,bef.store_name
                    ,bef.staff_info_id
                from
                    (-- 12点前要有交接
                        select
                            s1.organization_id
                            ,pr.store_name
                            ,s1.staff_info_id
                            ,count(distinct pr.pno) pno_count
                        from rot_pro.parcel_route pr
                        join sa s1 on s1.organization_id = pr.store_id and s1.staff_info_id = pr.staff_info_id
                        where
                            pr.routed_at >= date_sub('${date}', interval 7 hour )
                            and pr.routed_at < date_add('${date}', interval 5 hour) -- 当天12点前有交接
                            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
                        group by 1,2,3
                    ) bef
                join
                    (-- 12点后交接量大于 10
                        select
                            s1.organization_id
                            ,pr.store_name
                            ,s1.staff_info_id
                            ,count(distinct pr.pno) pno_count
                        from rot_pro.parcel_route pr
                        join sa s1 on s1.organization_id = pr.store_id and s1.staff_info_id = pr.staff_info_id
                        where
                            pr.routed_at >= date_add('${date}', interval 5 hour)
                            and pr.routed_at < date_add('${date}', interval 17 hour) -- 当天12点前有交接
                            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
                        group by 1,2,3
                    ) aft on aft.staff_info_id = bef.staff_info_id
                where
                    aft.pno_count >= 10
                    and bef.pno_count > 0
                group by 1,2,3
            ) a1 on s2.staff_info_id = a1.staff_info_id and s2.organization_id = a1.organization_id
        left join dwm.dim_th_sys_store_rd dt on dt.store_id = s2.organization_id and dt.stat_date = date_sub(curdate(), interval 1 day)
        group by 1,2,3,4
    ) a2

