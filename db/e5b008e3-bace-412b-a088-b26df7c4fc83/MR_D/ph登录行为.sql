with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
        ,case ss.category
          when 1 then 'SP'
          when 2 then 'DC'
          when 4 then 'SHOP'
          when 5 then 'SHOP'
          when 6 then 'FH'
          when 7 then 'SHOP'
          when 8 then 'Hub'
          when 9 then 'Onsite'
          when 10 then 'BDC'
          when 11 then 'fulfillment'
          when 12 then 'B-HUB'
          when 13 then 'CDC'
          when 14 then 'PDC'
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.staff_info_id order by ldr.created_at) rk
        ,row_number() over (order by ldr.created_at ) rn
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-16 16:00:00'
        and ldr.created_at < '2023-07-17 16:00:00'
)
, staff as
(
    select
        t1.*
        ,min(t2.登录时间) other_login_time
    from t t1
    left join t t2 on t2.device_id = t1.device_id
    where
        t2.staff_info_id != t1.staff_info_id
        and t2.登录时间 > t1.登录时间
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,s2.other_login_time
        ,t2.登录时间 t2_登录时间
        ,least(s2.other_login_time, t2.登录时间) 最小时间
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = t1.rk + 1
    left join staff s2 on s2.rn = t1.rn
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-18'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(least(s2.other_login_time, t2.登录时间), interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-17 16:00:00'
        and pr2.routed_at < '2023-07-18 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1
# where
#     b1.归属网点 = 'RBL_SP'