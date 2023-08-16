with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,ra.final_approval_time
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10' -- QC不看之前的数据
    and ra.status = 2
#     and hsi.sys_store_id = -1
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
    and ra.final_approval_time < date_add(curdate(), interval 13 hour )
#     and ra.final_approval_time < '2023-08-13 00:00:00'
#     and ra.final_approval_time > '2023-08-12 00:00:00'
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on del.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
# group by 2
;
