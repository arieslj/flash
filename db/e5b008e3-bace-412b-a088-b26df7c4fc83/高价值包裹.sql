with a as
    (
        select
            pi.pno
            ,pi.state
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_staff_info_id
#             ,if(pi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) parcel_value
            ,pi.cod_amount/100 parcel_value
        from ph_staging.parcel_info pi
        left join ph_staging.order_info oi on oi.pno = pi.pno
        where
            pi.created_at >= '2023-03-31 16:00:00'
            and pi.created_at < '2023-04-30 16:00:00'
    )
# select
#     ss.name
#     ,count(a.pno) 包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null)) 高价值包裹数
#     ,count(if(a.parcel_value > 10000, a.pno, null))/count(a.pno) 高价值占比
# from a
# left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
# group by 1
# having count(a.pno) > 10000
# order by 4 desc
select
    *
from
    (
        select
            a.*
            ,row_number() over (partition by a.name order by a.num desc ) rk
        from
            (
                select
                    ss.name
                    ,a.ticket_pickup_staff_info_id
                    ,count(a.pno) num
                from a
                left join ph_staging.sys_store ss on ss.id = a.ticket_pickup_store_id
                where
                    a.parcel_value > 20000
                    and ss.name in ('11 PN5-HUB_Santa Rosa','PSA_PDC','CLB_PDC','TOA_PDC','NOP_PDC')
                group by 1,2
            ) a
    ) b
where
    b.rk < 6