with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)

select
    ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.sh_del_del_num 网点当日应派件妥投量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,shl_del.delivery_rate 当日妥投率
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
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
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
group by 1
;
