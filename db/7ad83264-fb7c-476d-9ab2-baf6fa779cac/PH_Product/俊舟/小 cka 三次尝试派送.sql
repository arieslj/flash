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
    from ph_staging.parcel_info pi
    left join dwm.dwd_ex_ph_parcel_details de on de.pno = pi.pno
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    left join ph_staging.parcel_change_detail pcd on pcd.pno = pi.pno and pcd.field_name = 'dst_store_id' and pcd.new_value != pcd.old_value
    where
        pi.state not in (5,7,8,9)
        and bc.client_id is null
        and  ( pi.interrupt_category != 3 or pi.interrupt_category is null )
        and pi.created_at >= date_sub(date_sub(curdate(), interval 10 day), interval 8 hour) -- 10天内揽收

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
        where
            if(t1.change_store = 'n', 1 = 1, tdm.created_at > t1.pcd_create_at)
            and td.created_at > date_sub(curdate(), interval 90 day)
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
            and ppd.created_at > date_sub(curdate(), interval 90 day)
            and if(t1.change_store = 'n', 1 = 1, ppd.created_at > t1.pcd_create_at)
        group by 1,2
    ) ppd on ppd.pno = mark.pno and mark.mark_date = ppd.mark_date
left join
    (
        select
            ppd.pno
            ,ppd.diff_marker_category
            ,row_number() over (partition by ppd.pno order by ppd.created_at desc ) rk
        from ph_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.created_at > date_sub(curdate(), interval 90 day)
    ) las on las.pno = mark.pno and las.rk = 1
where
    ppd.mark_date is not null
    and las.diff_marker_category  in (1,40)
group by 1
having count(distinct ppd.mark_date) >= 3



;


select
    count(distinct if(di.diff_marker_category in (9,14,70), di.pno, null)) 客户改约时间
    ,count(distinct if(di.diff_marker_category in (40,1), di.pno, null)) 联系不上客户
    ,count(distinct if(di.diff_marker_category in (25,75), di.pno, null)) 电话号码错误
    ,count(distinct if(di.diff_marker_category in (23,73), di.pno, null)) '收件人/地址不清晰或不正确'
    ,count(distinct if(di.diff_marker_category in (2,17), di.pno, null)) 收件人拒收
    ,count(distinct if(di.diff_marker_category in (29,78), di.pno, null)) 电话号码是空号
    ,count(distinct if(di.diff_marker_category in (87,100), di.pno, null)) 违禁品
    ,count(distinct if(di.diff_marker_category in (15,71), di.pno, null)) 运力不足
from ph_staging.parcel_problem_detail  di
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    di.created_at >= date_sub(curdate(),interval 32 hour)
    and di.created_at < date_sub(curdate(), interval 8 hour)
    and bc.client_id is null

;


with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.finished_at
    from ph_staging.parcel_info pi
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id
    where
        pi.returned = 1
        and pr.routed_at >= date_sub(date_sub(curdate(), interval 30 day ), interval 8 hour )
        and bc.client_id is null
        and pr.route_action in ('SORTING_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','STAFF_INFO_UPDATE_WEIGHT','DELIVERY_CONFIRM','ACCEPT_PARCEL','REPLACE_PNO','UNSEAL','STORE_SORTER_UPDATE_WEIGHT','RECEIVED','PARCEL_HEADLESS_PRINTED','SEAL','DIFFICULTY_HANDOVER','DETAIN_WAREHOUSE','REFUND_CONFIRM','FLASH_HOME_SCAN','RECEIVE_WAREHOUSE_SCAN','PICKUP_RETURN_RECEIPT','STORE_KEEPER_UPDATE_WEIGHT','INVENTORY','DELIVERY_TRANSFER','DELIVERY_MARKER','DISCARD_RETURN_BKK','DELIVERY_PICKUP_STORE_SCAN')
    group by 1
) ,
b as
(
    select
        a1.pno
        ,a1.td_date
        ,row_number() over (partition by a1.pno order by a1.td_date) rk
    from
        (
            select
                t1.pno
                ,date(convert_tz(td.created_at, '+00:00', '+08:00')) td_date
            from ph_staging.ticket_delivery td
            join t t1 on t1.pno = td.pno
            left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
            group by 1,2
        ) a1
)
select
    b1.*
    ,b2.*
    ,b3.*
from
    (
        select
            count(distinct t1.pno) 总数
            ,count(distinct if(a3.rk = 1, t1.pno, null))/count(distinct t1.pno) 第一次尝试派送妥投占比
            ,count(distinct if(a3.rk = 2, t1.pno, null))/count(distinct t1.pno) 第二次尝试派送妥投占比
            ,count(distinct if(a3.rk = 3, t1.pno, null))/count(distinct t1.pno) 第三次尝试派送妥投占比
        from t t1
        left join
            (
                select
                    a2.pno
                    ,a2.td_date
                    ,a2.rk
                from b a2
                join t t1 on t1.pno = a2.pno and t1.state = 5 and date(convert_tz(t1.finished_at, '+00:00', '+08:00')) = a2.td_date
            ) a3 on a3.pno = t1.pno
    ) b1
cross join
    (
        select
            count(distinct di.pno) 第一次就标记拒收包裹数
            ,count(distinct if(cdt.negotiation_result_category in (2,4), di.pno, null)) 第一次协商结果为退件
        from ph_staging.diff_info di
        join b a1 on a1.pno = di.pno and a1.rk = 1 and date(convert_tz(di.created_at, '+00:00', '+08:00')) = a1.td_date
        left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        where
            di.diff_marker_category in (2,17)
    ) b2
cross join
    (
        select
            count(distinct t1.pno) 标记拒收后妥投数
        from t t1
        join ph_staging.diff_info di on di.pno = t1.pno and di.diff_marker_category in (2,17)
        where
            t1.state = 5
            and t1.finished_at > di.created_at
    ) b3