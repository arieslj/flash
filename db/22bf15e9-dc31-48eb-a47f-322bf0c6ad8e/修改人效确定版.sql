select
    *
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-04-01'
    and plt.state in (5,6)
    and plt.penalties > 0
limit 100
;

select
    *
from bi_pro.parcel_lose_task plt
where
    plt.total >= 2
    and plt.created_at >= '2023-04-01'
order by pno
;



select
    b.operator_id
    ,hsi.name
#     ,b.creat_date 日期
    ,count(b.id) 总处理合计
    ,sum(b.point) 综合人效得分
from
    (
        select
            a.pno
            ,a.operator_id
            ,date(a.created_at) creat_date
            ,a.source
            ,a.action
            ,a.point
            ,a.id
        from
            (
                select
                    a.pno
                    ,a.operator_id
                    ,a.created_at
                    ,a.action
                    ,a.source
                    ,row_number() over (partition by a.pno, a.action, a.created_at order by a.point desc ) rk
                    ,a.point
                    ,a.id
                from
                    (
                        select
                            pcol.action
                            ,plt.pno
                            ,pcol.operator_id
                            ,pcol.created_at
                            ,plt.source
                            ,pcol.id
                        #     ,count(pcol.id)over (partition by pcol.created_at) num
                            ,case
                                when plt.source in (3,33,12) and pcol.action = 4 then 3
                                when plt.source in (1,4,8,11) and pcol.action = 4 then 5
                                when plt.source in (2,5,6,7) and pcol.action = 4 then 7
                                when plt.source in (1,2,3,33,5,11,12) and pcol.action = 3 then 1
                                when plt.source in (4,8) and pcol.action = 3 then 3
                                when plt.source in (6,7) and pcol.action = 3 then 5
                            end as point
                        from bi_pro.parcel_cs_operation_log pcol
                        left join bi_pro.parcel_lose_task plt on pcol.task_id = plt.id
                        where
                            pcol.created_at >= '${date}'
                            and pcol.created_at < date_add('${date1}', interval 1 day)
        #                 plt.pno = 'TH01283YYCN60C'
                            and pcol.action in (3,4)
                            and pcol.operator_id not in (10000,10001)
                    ) a
            ) a
        where
            a.rk = 1

        union

        select
            plt.pno
            ,pcol.operator_id
            ,date(pcol.created_at) creat_date
            ,plt.source
            ,pcol.action
            ,case
                when plt.source in (1,2,3,4,5,11,12) then 1
                when plt.source in (6,7,8) then 2
            end point
            ,pcol.id
        from bi_pro.parcel_cs_operation_log pcol
        left join bi_pro.parcel_lose_task plt on pcol.task_id = plt.id
        where
            pcol.created_at >= '${date}'
            and pcol.created_at < date_add('${date1}', interval 1 day)
            and pcol.action in (1)
            and pcol.operator_id not in (10000,10001)
    ) b
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = b.operator_id
group by 1,2