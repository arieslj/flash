select
    a1.plt_date 日期
    ,a1.plt_count 生成量
    ,a1.auto_no_duty_count 系统自动无责量
    ,a1.man_no_duty_count 人工无责量
    ,a1.man_duty_count QAQC判责量
    ,a1.have_hair_scan_no_num 上报有发无到量
    ,a2.plt_count 自动上报量
    ,a2.a_lost_duty_count 自动上报升级a来源判责丢失量
from
    (
        select
            date(plt.created_at) plt_date
            ,count(distinct plt.id) plt_count
            ,count(distinct if(plt.operator_id in (10000,10001) and plt.state = 5, plt.id, null)) auto_no_duty_count
            ,count(distinct if(plt.operator_id not in (10000,10001) and plt.state = 5, plt.id, null)) man_no_duty_count
            ,count(distinct if(plt.operator_id not in (10000,10001) and plt.state = 6 and plt.penalties > 0, plt.id, null)) man_duty_count
            ,count(distinct if(pr.pno is not null, plt.id, null)) have_hair_scan_no_num
        from my_bi.parcel_lose_task plt
        left join my_staging.parcel_route pr on pr.pno = plt.pno and pr.route_action = 'HAVE_HAIR_SCAN_NO_TO'
        where
            plt.created_at >= '2023-11-01'
            and plt.created_at < '2023-12-01'
            and plt.source = 3
        group by 1
    ) a1
left join
    (
        select
            date(plt.created_at) plt_date
            ,count(distinct plt.id) plt_count
            ,count(distinct if(plt.state = 6 and plt.penalties > 0 and plt.duty_result = 1, plt.id, null)) a_lost_duty_count
        from my_staging.parcel_route pr
        join my_staging.customer_diff_ticket cdt on cdt.diff_info_id = json_extract(pr.extra_value, '$.diffInfoId')
        join my_bi.parcel_lose_task plt on plt.source_id = cdt.id and plt.source = 1
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and pr.remark = 'SS Judge Auto Created For Overtime'
            and pr.routed_at > '2022-10-01'
            and plt.created_at >= '2023-11-01'
            and plt.created_at < '2023-12-01'
        group by 1
    ) a2 on a2.plt_date  = a1.plt_date
order by 1


;
select datediff('2024-04-01', '2024-04-02')