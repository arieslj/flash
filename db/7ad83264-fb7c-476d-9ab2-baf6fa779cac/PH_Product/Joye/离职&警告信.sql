
select
    date(a.leave_date) 日期
    ,count(distinct a.staff_info_id) 离职快递员人数
    ,count(distinct if(a.mw_count > 0, a.staff_info_id, null))/count(distinct a.staff_info_id) 有警告信占比
    ,count(distinct if(a.mw_count = 1, a.staff_info_id, null))/count(distinct a.staff_info_id) 1封警告信占比
    ,count(distinct if(a.mw_count = 2, a.staff_info_id, null))/count(distinct a.staff_info_id) 2封警告信占比
    ,count(distinct if(a.mw_count = 3, a.staff_info_id, null))/count(distinct a.staff_info_id) 3封警告信占比
    ,count(distinct if(a.mw_count > 3, a.staff_info_id, null))/count(distinct a.staff_info_id) 3封以上警告信占比
from
    (
        select
            hsi.leave_date
            ,hsi.staff_info_id
        #     ,count(distinct hsi.staff_info_id) 离职快递员人数
        #     ,count(distinct if(mw.staff_info_id is not null, hsi.staff_info_id, null)) 有警告信占比
            ,count(mw.id) mw_count
        from ph_bi.hr_staff_info hsi
        left join ph_backyard.message_warning mw on mw.staff_info_id = hsi.staff_info_id and mw.is_delete = 0
        where
            hsi.state = 2
            and hsi.job_title in (13,110,1000)
            and hsi.leave_date >= date_sub(curdate(), interval 30 day)
            and hsi.leave_date < curdate()
        group by 1,2
    ) a
group by 1

;
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name
        ,hsi.state
        ,hsi.wait_leave_state
        ,hjt.job_name
        ,dp.store_name
        ,dp.piece_name
        ,dp.region_name
        ,swd.warning_count
        ,swd.warning_pending_count
        ,mw.created_at
        ,mw.warning_type
        ,row_number() over (partition by swd.staff_info_id order by mw.created_at ) rk
    from ph_backyard.staff_warning_dismiss swd
    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = swd.staff_info_id and hsi.state = 1
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_backyard.message_warning mw on mw.staff_info_id = swd.staff_info_id and mw.warning_type > 1
    where
        swd.warning_pending_count >= 3
        and hsi.state = 1
)
select
    t1.staff_info_id 员工工号
    ,t1.name 员工名字
    ,case
        when t1.state = 1 and t1.wait_leave_state = 0 then '在职'
        when t1.state = 1 and t1.wait_leave_state = 1 then '待离职'
        when t1.state = 2 then '离职'
        when t1.state = 3 then '停职'
    end 在职状态
    ,t1.job_name 职位
    ,t1.store_name 所属网点
    ,t1.region_name 大区
    ,t1.piece_name 片区
    ,t1.warning_count 警告书总次数
    ,t1.warning_pending_count '严厉&最后警告次数'
    ,t1.created_at 第一次
    ,t2.created_at 第二次
    ,t3.created_at 第三次
    ,t4.created_at 第四次
    ,t5.created_at 第五次
from t t1
left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = 2
left join t t3 on t3.staff_info_id = t1.staff_info_id and t3.rk = 3
left join t t4 on t4.staff_info_id = t1.staff_info_id and t4.rk = 4
left join t t5 on t5.staff_info_id = t1.staff_info_id and t5.rk = 5
where
    t1.rk = 1

