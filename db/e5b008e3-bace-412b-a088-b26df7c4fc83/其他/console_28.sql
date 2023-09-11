with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
#         and ho.staff_id = '141214'
#         and ho.start_time = '2023-06-30 13:00:00'
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id, t1.start_time order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,timestampdiff(second, convert_tz(b1.routed_at, '+00:00', '+08:00'), t1.end_time)/3600 最后一个路由动作距离加班结束时间差_hour
    ,rou.route_num 加班期间路由动作数
from t t1
left join b b1 on b1.staff_id = t1.staff_id  and b1.start_time = t1.start_time and b1.end_time = t1.end_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )