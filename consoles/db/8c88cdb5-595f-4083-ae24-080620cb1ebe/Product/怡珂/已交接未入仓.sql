with t as
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.staff_info_id
            ,convert_tz(pr.routed_at, '+00:00', '+07:00') route_time
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) route_date
        from
            (
                select
                    pr.*
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from
                    (
                        select
                            pi.pno
                        from fle_staging.parcel_info pi
                        where
                            pi.state = 3 -- 派送中
                            and pi.created_at > date_sub(curdate(), interval 3 month)
                    ) pi
                join
                    (
                        select
                            pr.pno
                            ,pr.routed_at
                            ,pr.store_id
                            ,pr.staff_info_id
                        from rot_pro.parcel_route pr
                        where
                            pr.routed_at > date_sub(curdate(), interval 3 month)
                            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                    ) pr on pr.pno = pi.pno
            ) pr
        where
            pr.rk = 1
    )
select
    t1.pno 运单号
    ,t1.staff_info_id 交接员工ID
    ,dt.store_name 网点
    ,dt.region_name 大区
    ,dt.piece_name 片区
    ,t1.route_date 交接日期
    ,case
        when hsi.hire_type in (1,2,3,4,5) then '正式员工'
        when hsi.hire_type in (11,12) then '外协'
        when hsi.hire_type in (13) then '个人代理'
    end 员工类型
    ,if(ad.attendance_started_at is not null, '是', '否') 是否打上班卡
    ,if(ad.attendance_end_at is not null, '是', '否') 是否打下班卡
    ,ad.attendance_end_at 下班打卡时间
    ,date_format(ad.attendance_end_at, '%H') 下班打卡小时
    ,hjt.job_name
    ,oi.cod_amount/100 COD
    ,oi.cogs_amount/100 COGS
from t t1
left join dwm.dim_th_sys_store_rd dt on dt.store_id = t1.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join backyard_pro.attendance_data_v2 ad on ad.staff_info_id = t1.staff_info_id and ad.stat_date = t1.route_date
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join fle_staging.order_info oi on oi.pno = t1.pno