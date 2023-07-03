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
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on de.pno = pi.pno
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'PENDING_RETURN'
    where
        datediff(now(), de.dst_routed_at) <= 7
        and pi.state not in (5,7,8,9)
        and bc.client_id is null
        and pr.pno is not null
    group by 1
)
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
        group by 1,2
    ) mark on mark.pno = t1.pno
left join
    (
        select
            ppd.pno
            ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) mark_date
        from ph_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.diff_marker_category not in (7,22,5,20,6,21,15,71)
        group by 1,2
    ) ppd on ppd.pno = mark.pno and mark.mark_date = ppd.mark_date
where
    ppd.mark_date is not null
group by 1
having count(distinct ppd.mark_date) >= 3
