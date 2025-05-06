with p as
(
    select
        pr.pno
        ,count(pr.id) pri_num
    from ph_staging.parcel_route pr
    where
        pr.pno in ('P02151SMA10AC','P02151SM9ZRAC','P02151SM9PSAG','P02081SM9JVAC','P02151SM9CZAC','P02081SM9C3AC','P02151SM9BSAC','P02081SM9BRAC','P02151SM9AYAC','P02151SM9AVAC','P02151SM9A9AC','P02151SM998AC','P02151SM96VAC','P02151SM926AC','P02081SM8Z1AC','P02151SM8TAAC','P02081SM8MPAC')
        and pr.route_action = 'PRINTING'
    group by 1
)

select
    pi.pno
    ,pi.recent_pno
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,ss.name 揽收网点
    ,pi.ticket_pickup_staff_info_id 揽收快递员
    ,ss2.name 目的地网点
    ,oi.weight 订单重量
    ,pi.src_name 寄件人姓名
    ,pi.src_detail_address 寄件人地址
    ,pi.src_phone 寄件人
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
    ,pi.dst_detail_address 收件人地址
    ,p1.pri_num 打印面单次数
from ph_staging.parcel_info pi
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join p p1 on p1.pno = pi.pno
where
    pi.pno in ('P02151SMA10AC','P02151SM9ZRAC','P02151SM9PSAG','P02081SM9JVAC','P02151SM9CZAC','P02081SM9C3AC','P02151SM9BSAC','P02081SM9BRAC','P02151SM9AYAC','P02151SM9AVAC','P02151SM9A9AC','P02151SM998AC','P02151SM96VAC','P02151SM926AC','P02081SM8Z1AC','P02151SM8TAAC','P02081SM8MPAC')


;



select
    pi.src_phone
from ph_staging.parcel_info pi
where
    pi.pno in ('P02151SMA10AC','P02151SM9ZRAC','P02151SM9PSAG','P02081SM9JVAC','P02151SM9CZAC','P02081SM9C3AC','P02151SM9BSAC','P02081SM9BRAC','P02151SM9AYAC','P02151SM9AVAC','P02151SM9A9AC','P02151SM998AC','P02151SM96VAC','P02151SM926AC','P02081SM8Z1AC','P02151SM8TAAC','P02081SM8MPAC')
group by 1