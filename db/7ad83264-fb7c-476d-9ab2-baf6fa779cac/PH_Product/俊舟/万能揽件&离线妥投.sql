select
    case
        when a.揽收日期 >= '2023-09-12' and a.揽收日期 <= '2023-10-12' then '0912-1012'
        when a.揽收日期 >= '2023-10-13' and a.揽收日期 <= '2023-11-12' then '1013-1112'
    end 时间段
    ,sum(a.完成揽收时间)/count(if(a.opt != 512, a.id, null)) 平均时长_min
from
    (
        select
            date(convert_tz(tp.created_at, '+00:00', '+08:00')) 揽收日期
            ,tp.ka_warehouse_id
            ,tp.id
            ,tp.opt
            ,tp.src_name
            ,ss.name PDC_name
            ,kp.staff_info_id
            ,if(tp.opt = 512, '万能揽件', '其他') 揽件方式
            ,timestampdiff(second, tp.created_at, tp.finished_at)/60 完成揽收时间
            ,convert_tz(min(pi.created_at), '+00:00', '+08:00') 最小揽收时间
            ,convert_tz(max(pi.created_at), '+00:00', '+08:00') 最大揽收时间
            ,count(distinct pi.pno) 揽件量
        from ph_staging.ticket_pickup tp
        left join dwm.dwd_dim_bigClient bc on bc.client_id = tp.client_id
        left join ph_staging.ka_profile kp on kp.id = tp.client_id
        left join ph_staging.sys_store ss on ss.id = tp.store_id
        left join ph_staging.parcel_info pi on pi.ticket_pickup_id = tp.id and tp.created_at >= '2023-09-11 16:00:00'
        where
            tp.created_at >= '2023-09-11 16:00:00'
            and tp.created_at < '2023-11-12 16:00:00'
            and tp.state = 2 -- 已揽件
            and ss.category = 14
        group by 1,2,3
    ) a
group by 1

;



select
    date(convert_tz(pi.finished_at, '+00:00', '+08:00')) 日期
    ,ss.name 网点
    ,count(pi.pno) 当日妥投包裹数
    ,count(if(hour(convert_tz(pi.finished_at, '+00:00', '+08:00')) < 16, pi.pno, null))/count(pi.pno) 4点前妥投占比
    ,count(if(st_distance_sphere(point(ss.lng,ss.lat), point(pi.ticket_delivery_staff_lng,pi.ticket_delivery_staff_lat)) < 100, pi.pno, null))/count(pi.pno) 100m以内妥投占比
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.finished_at >= '2023-10-08 16:00:00'
    and pi.finished_at < '2023-12-09 16:00:00'
    and pi.state = 5
    and pi.ticket_delivery_store_id in ('PH18040100','PH18040104','PH18040503','PH18060100','PH18060800','PH18061R03','PH18061R04','PH18061R05','PH18061R06','PH19030P02','PH19030P03','PH19040202','PH19240100','PH19241601','PH19241U01','PH19250100')
group by 1,2