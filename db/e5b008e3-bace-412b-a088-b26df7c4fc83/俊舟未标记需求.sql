with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    join tmpale.tmp_ph_pno_0710 t on t.pno = pr.pno
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,b1.staff_info_id
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 17:00:00' -- 延迟1个小时
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
#     ) a
# group by 1,2,3

;

;

select
    t.*
    ,a.attendance_started_at 上班打卡时间
    ,a.attendance_end_at 下班打卡时间
    ,sa.reissue_card_date 补卡时间
from tmpale.tmp_ph_pno_0710 t
left join ph_bi.attendance_data_v2 a on t.staff_info_id = a.staff_info_id and a.stat_date = '2023-07-08'
left join ph_backyard.staff_audit sa on sa.staff_info_id = t.staff_info_id and sa.audit_type = 1 and sa.attendance_type in (2,4) and sa.attendance_date = '2023-07-08'