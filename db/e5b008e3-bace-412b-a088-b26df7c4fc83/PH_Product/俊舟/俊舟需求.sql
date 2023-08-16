with t as
(
    select
        de.pno
        ,de.dst_store_id
        ,de.dst_store
        ,de.dst_region
        ,de.dst_piece
        ,pi.state
        ,pi.dst_phone
        ,pi.dst_home_phone
        ,if(pcd.pno is not null , 'y', 'n') change_store
        ,max(pcd.created_at) pcd_create_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on de.pno = pi.pno
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'PENDING_RETURN'
    left join ph_staging.parcel_change_detail pcd on pcd.pno = pi.pno and pcd.field_name = 'dst_store_id' and pcd.new_value != pcd.old_value
    where
        datediff(now(), de.dst_routed_at) <= 7
        and pi.state not in (5,7,8,9)
        and bc.client_id is null
        and pr.pno is null
    group by 1
)
select
    a.*
    ,b.diff_marker_category
from
    (
        select
            t1.pno
            ,t1.dst_store 目的地网点
            ,t1.dst_store_id 目的网点ID
            ,t1.dst_piece 目的地片区
            ,t1.dst_region 目的地大区
            ,case t1.state
                when '1' then '已揽收'
                when '2' then '运输中'
                when '3' then '派送中'
                when '4' then '已滞留'
                when '5' then '已签收'
                when '6' then '疑难件处理中'
                when '7' then '已退件'
                when '8' then '异常关闭'
                when '9' then '已撤销'
            end as `包裹状态`
            ,t1.dst_phone 收件人电话
            ,t1.dst_home_phone 收件人家庭电话
            ,count(distinct ppd.mark_date) 尝试天数
        from t t1
        left join
            (
                select
                    td.pno
                    ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) mark_date
                from ph_staging.ticket_delivery td
                join t t1 on t1.pno = td.pno
                left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.marker_id not in (7,22,5,20,6,21,15,71,32,69,31)
                    and if(t1.change_store = 'n', 1 = 1, tdm.created_at > t1.pcd_create_at)
                group by 1,2
            ) mark on mark.pno = t1.pno
        join
            (
                select
                    ppd.pno
                    ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) mark_date
                from ph_staging.parcel_problem_detail ppd
                join t t1 on t1.pno = ppd.pno
                where
                    if(t1.change_store = 'n', 1 = 1, ppd.created_at > t1.pcd_create_at)
                group by 1,2
            ) ppd on ppd.pno = mark.pno and mark.mark_date = ppd.mark_date
        group by 1
        having count(distinct ppd.mark_date) >= 3
    ) a
left join
    (
        select
            *
        from
            (
                select
                    ppd.pno
                    ,ppd.diff_marker_category
                    ,row_number() over (partition by ppd.pno order by ppd.created_at desc) rk
                from ph_staging.parcel_problem_detail ppd
                join t t1 on t1.pno = ppd.pno
                where
                    ppd.parcel_problem_type_category = 1
            ) b
        where
            b.rk = 1
    ) b on b.pno = a.pno
where
    b.diff_marker_category != 17 -- 拒收疑难件
    or b.diff_marker_category is null


;




-- 自动邮件修改时间逻辑


with t as
(
    select
        de.pno
        ,de.dst_store_id
        ,de.dst_store
        ,de.dst_region
        ,de.dst_piece
        ,pi.state
        ,pi.dst_phone
        ,pi.dst_home_phone
        ,if(pcd.pno is not null , 'y', 'n') change_store
        ,max(pcd.created_at) pcd_create_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on de.pno = pi.pno
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'PENDING_RETURN'
    left join ph_staging.parcel_change_detail pcd on pcd.pno = pi.pno and pcd.field_name = 'dst_store_id' and pcd.new_value != pcd.old_value
    where
        datediff(now(), de.dst_routed_at) <= 7
        and pi.state not in (5,7,8,9)
        and bc.client_id is null
        and pr.pno is null
    group by 1
)
select
    a.*
    ,b.diff_marker_category
    ,b.ppd_time '最后一次留仓/问题件时间'
from
    (
        select
            t1.pno
            ,t1.dst_store 目的地网点
            ,t1.dst_store_id 目的网点ID
            ,t1.dst_piece 目的地片区
            ,t1.dst_region 目的地大区
            ,case t1.state
                when '1' then '已揽收'
                when '2' then '运输中'
                when '3' then '派送中'
                when '4' then '已滞留'
                when '5' then '已签收'
                when '6' then '疑难件处理中'
                when '7' then '已退件'
                when '8' then '异常关闭'
                when '9' then '已撤销'
            end as `包裹状态`
            ,t1.dst_phone 收件人电话
            ,t1.dst_home_phone 收件人家庭电话
            ,count(distinct ppd.mark_date) 尝试天数
        from t t1
        left join
            (
                select
                    td.pno
                    ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) mark_date
                from ph_staging.ticket_delivery td
                join t t1 on t1.pno = td.pno
                left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.marker_id not in (7,22,5,20,6,21,15,71,32,69,31)
                    and if(t1.change_store = 'n', 1 = 1, tdm.created_at > t1.pcd_create_at)
                group by 1,2
            ) mark on mark.pno = t1.pno
        join
            (
                select
                    ppd.pno
                    ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) mark_date
                from ph_staging.parcel_problem_detail ppd
                join t t1 on t1.pno = ppd.pno
                where
                    if(t1.change_store = 'n', 1 = 1, ppd.created_at > t1.pcd_create_at)
                group by 1,2
            ) ppd on ppd.pno = mark.pno and mark.mark_date = ppd.mark_date
        group by 1
        having count(distinct ppd.mark_date) >= 3
    ) a
left join
    (
        select
            *
        from
            (
                select
                    ppd.pno
                    ,ppd.diff_marker_category
                    ,convert_tz(ppd.created_at, '+00:00', '+08:00') ppd_time
                    ,row_number() over (partition by ppd.pno order by ppd.created_at desc) rk
                from ph_staging.parcel_problem_detail ppd
                join t t1 on t1.pno = ppd.pno
#                 where
#                     ppd.parcel_problem_type_category = 1
            ) b
        where
            b.rk = 1
    ) b on b.pno = a.pno
where
     ( b.diff_marker_category != 17 or b.diff_marker_category is null )
    and if(hour(now()) = 9,  b.ppd_time >= date_sub(curdate(), interval 4 hour) and  b.ppd_time < date_add(curdate(), interval 9 hour), b.ppd_time >= date_add(curdate(), interval hour(now()) - 1 hour ) and b.ppd_time < date_add(curdate(), interval hour(now()) hour) )

;

select date_add(curdate(), interval hour(now()) - 9 hour )