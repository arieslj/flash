with t as
(
    select
        'shopee' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,ds.end_date del_date
        ,pi.pno
        ,pi.state
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('shopee')
    left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and ds.end_date < curdate()

    union all

    select
        'lazada' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dl.delievey_end_date del_date
        ,pi.pno
        ,pi.state
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dl.delievey_end_date < curdate()

    union all

    select
        'tiktok' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dt.end_date del_date
        ,pi.pno
        ,pi.state
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dt.end_date < curdate()

)
select
    t.pno
    ,t.client_name 客户
    ,t.pick_time 揽收时间
    ,t.del_date 派送时效
    ,case t.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,ss.name 目的地网点
    ,count(pcd.id) 修改收件人地址次数
from ph_staging.parcel_change_detail pcd
join t on pcd.pno = t.pno
left join ph_staging.sys_store ss on ss.id = t.dst_store_id
where
    pcd.field_name = 'dst_detail_address'
#     and t.pick_time > '2023-01-01'
group by 1,2,3,4,5



;




with t as
(
    select
        di.pno
        ,di.created_at
        ,date(convert_tz(di.created_at, '+00:00', '+08:00')) date_d
    from ph_staging.diff_info di
    where
        di.created_at >= date_sub('2023-03-01', interval 8 hour)
        and di.diff_marker_category in (31)
)
select
    t.pno
    ,t.date_d 提交疑难件日期
    ,convert_tz(t.created_at, '+00:00', '+08:00') 错分疑难件交接时间
    ,convert_tz(cal.routed_at, '+00:00', '+08:00') 有通话时长通话时间
    ,cal.callDuration 通话时长
    ,convert_tz(mak.created_at, '+00:00', '+08:00') 标记联系不上时间
from t
join
    (
        select
            pr.pno
            ,pr.routed_at
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
            ,json_extract(pr.extra_value, '$.callDuration') callDuration
        from ph_staging.parcel_route pr
        join
            (
                select t.pno from t group by 1
            ) t1 on pr.pno = t1.pno
        where
            pr.route_action in ('PHONE', 'INCOMING_CALL')
#             and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.routed_at >= date_sub('2023-03-01', interval 32 hour)
            and json_extract(pr.extra_value, '$.callDuration') > 0
    ) cal on cal.pno = t.pno and cal.routed_at < t.created_at and cal.date_d = t.date_d
left join
    (
        select
            td.pno
            ,tdm.created_at
            ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) date_d
        from ph_staging.ticket_delivery_marker tdm
        left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
        join
            (
                select t.pno from t group by 1
            ) t1 on td.pno = t1.pno
        where
            tdm.created_at >= date_sub('2023-03-01', interval 8 hour)
            and tdm.marker_id in (1)
    ) mak on mak.pno = t.pno and mak.date_d = t.date_d
where
    mak.created_at > cal.routed_at
    and mak.created_at < t.created_at

;












;


