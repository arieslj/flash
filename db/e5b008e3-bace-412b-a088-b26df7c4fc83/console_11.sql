select
    ss.name
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct ppd.pno) 留仓件数
    ,count(distinct if(ppd.diff_marker_category in (9,14,70), ppd.pno, null)) 改约时间件数
    ,count(distinct if(ppd.diff_marker_category in (9,14,70), ppd.pno, null))/count(distinct ppd.pno) 改约占比
from ph_staging.parcel_problem_detail ppd
left join ph_staging.sys_store ss on ss.id = ppd.store_id
left join ph_staging.parcel_info pi on pi.pno = ppd.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    ppd.parcel_problem_type_category = 2
    and ppd.created_at >= '2023-06-25 16:00:00'
    and ppd.created_at < '2023-06-26 16:00:00'
group by 1,2

;


with t as
(
        select
            dp.store_name
            ,dp.region_name
            ,dp.piece_name
            ,ds.pno
            ,pi.client_id
            ,pi.state
        from ph_bi.dc_should_delivery_today ds
        left join ph_staging.parcel_info pi on pi.pno = ds.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            ds.stat_date = '2023-06-26'
)
select
    a.region_name 大区
    ,a.piece_name 片区
    ,a.store_name 网点
    ,a.应派量
    ,a.交接量
    ,a.应派交接占比
    ,a.留仓量
    ,a.应派留仓占比
    ,a.妥投量
    ,a.问题件量
    ,a.`未妥投&未问题件&未留仓`
    ,b.`客户不在家/电话无人接听`
    ,b.客户改约时间
    ,b.`当日运力不足，无法派送`
from
    (
        select
            t1.store_name
            ,t1.region_name
            ,t1.piece_name
#             ,case
#                 when bc.`client_id` is not null then bc.client_name
#                 when kp.id is not null and bc.client_id is null then '普通ka'
#                 when kp.`id` is null then '小c'
#             end 客户类型
            ,count(t1.pno) 应派量
            ,count(if(pr.pno is not null, t1.pno, null )) 交接量
            ,count(if(ppd.pno is not null, t1.pno , null )) 留仓量
            ,count(if(ppd2.pno is not null, t1.pno , null )) 问题件量
            ,count(if(t1.state = 5, t1.pno, null)) 妥投量
            ,count(if(t1.state != 5 and ppd2.pno is null and ppd.pno is null, t1.pno, null)) `未妥投&未问题件&未留仓`
            ,count(if(pr.pno is not null, t1.pno, null ))/count(t1.pno) 应派交接占比
            ,count(if(ppd.pno is not null, t1.pno , null ))/count(t1.pno) 应派留仓占比
        from t t1
        left join
            (
                select
                    pr.pno
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.created_at >= '2023-06-25 16:00:00'
                    and pr.created_at < '2023-06-26 16:00:00'
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                group by 1
            ) pr on pr.pno = t1.pno
        left join
            (
                select
                    ppd.pno
                    ,ppd.diff_marker_category
                    ,ddd.CN_element
                from ph_staging.parcel_problem_detail ppd
                left join dwd_dim_dict ddd on ddd.element = ppd.diff_marker_category and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category' and ddd.db = 'ph_staging'
                join t t1 on t1.pno = ppd.pno
                where
                    ppd.parcel_problem_type_category = 2
                    and ppd.created_at >= '2023-06-25 16:00:00'
                    and ppd.created_at < '2023-06-26 16:00:00'

            ) ppd on ppd.pno = t1.pno
        left join
            (
                select
                    ppd.pno
                    ,ppd.diff_marker_category
                    ,ddd.CN_element
                from ph_staging.parcel_problem_detail ppd
                left join dwd_dim_dict ddd on ddd.element = ppd.diff_marker_category and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category' and ddd.db = 'ph_staging'
                join t t1 on t1.pno = ppd.pno
                where
                    ppd.parcel_problem_type_category = 1
                    and ppd.created_at >= '2023-06-25 16:00:00'
                    and ppd.created_at < '2023-06-26 16:00:00'
            ) ppd2 on ppd2.pno = t1.pno
        left join ph_staging.ka_profile kp on kp.id = t1.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
        group by 1,2,3
    ) a
left join
    (
        select
            t1.store_name
#             ,case
#                 when bc.`client_id` is not null then bc.client_name
#                 when kp.id is not null and bc.client_id is null then '普通ka'
#                 when kp.`id` is null then '小c'
#             end 客户类型
            ,count(if(ppd.diff_marker_category in (1,40), ppd.pno, null)) '客户不在家/电话无人接听'
            ,count(if(ppd.diff_marker_category in (9,14,70), ppd.pno, null)) '客户改约时间'
            ,count(if(ppd.diff_marker_category in (15,71), ppd.pno, null))  '当日运力不足，无法派送'
        from t t1
        left join
            (
                select
                    ppd.pno
                    ,ppd.diff_marker_category
                    ,ddd.CN_element
                from ph_staging.parcel_problem_detail ppd
                left join dwd_dim_dict ddd on ddd.element = ppd.diff_marker_category and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category' and ddd.db = 'ph_staging'
                join t t1 on t1.pno = ppd.pno
                where
                    ppd.parcel_problem_type_category = 2
                    and ppd.created_at >= '2023-06-25 16:00:00'
                    and ppd.created_at < '2023-06-26 16:00:00'
            ) ppd on ppd.pno = t1.pno
        left join ph_staging.ka_profile kp on kp.id = t1.client_id
        left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
        group by 1
    ) b on a.store_name = b.store_name