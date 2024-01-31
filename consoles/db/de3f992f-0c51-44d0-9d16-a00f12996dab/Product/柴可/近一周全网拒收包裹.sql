
with t as
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+07:00')) p_date
            ,pr.routed_at
            ,pr.pno
            ,pr.id
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.routed_at > '2023-11-29 17:00:00'
            and pr.routed_at < '2023-12-06 17:00:00'
            and pr.marker_category = 2
    )
select
    a.pno
    ,a.p_date 日期
    ,a.mark_count 当日标记次数
    ,a.CN_element 当日提交疑难件
    ,a.di_time 提交疑难件时间
    ,a.store_id 提交问题件网点ID
    ,a.name 提交问题件网点
    ,group_concat(a.rn) 当日第几次标记
    ,group_concat(a.reject_time) 标记拒收时间
from
    (
        select
            t1.pno
            ,t1.p_date
            ,t2.rn
            ,t3.mark_count
            ,convert_tz(t1.routed_at, '+00:00', '+07:00') reject_time
            ,t4.CN_element
            ,convert_tz(t4.created_at, '+00:00', '+07:00') di_time
            ,t4.store_id
            ,t4.name
        from t t1
        left join
            (
                select
                    pr.id
                    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) p_date
                    ,row_number() over (partition by t1.pno, date(convert_tz(pr.routed_at, '+00:00', '+07:00')) order by pr.routed_at) rn
                from rot_pro.parcel_route pr
                join
                    (
                        select t1.pno  from t t1 group by 1
                    ) t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_MARKER'
                    and pr.routed_at > '2023-11-29 17:00:00'
                    and pr.routed_at < '2023-12-06 17:00:00'
            ) t2  on t2.id = t1.id
        left join
            (
                select
                    pr.pno
                    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) p_date
                    ,count(pr.id) mark_count
                from rot_pro.parcel_route pr
                join
                    (
                        select t1.pno  from t t1 group by 1
                    ) t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_MARKER'
                    and pr.routed_at > '2023-11-29 17:00:00'
                    and pr.routed_at < '2023-12-06 17:00:00'
                group by 1,2
            ) t3 on t3.pno = t1.pno and t3.p_date = t1.p_date
        left join
            (
                select
                    di.pno
                    ,date(convert_tz(di.created_at, '+00:00', '+07:00')) p_date
                    ,di.created_at
                    ,di.diff_marker_category
                    ,ddd.CN_element
                    ,di.store_id
                    ,ss.name
                from fle_staging.diff_info di
                join
                    (
                        select t1.pno,t1.p_date  from t t1 group by 1,2
                    ) t1 on t1.pno = di.pno
                left join fle_staging.sys_store ss on ss.id = di.store_id
                left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
                where
                    di.created_at > '2023-11-29 17:00:00'
                    and di.created_at < '2023-12-06 17:00:00'
                    and di.created_at >= date_sub(t1.p_date, interval 7 hour)
                    and di.created_at < date_add(t1.p_date, interval 17 hour)
            ) t4 on t4.pno = t1.pno and t4.p_date = t1.p_date
    ) a
group by 1,2,3,4,5,6,7

