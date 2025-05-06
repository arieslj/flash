
with t as
(
    select
        pi.pno
        ,pssn.store_id
        ,pssn.store_name
        ,pssn.next_store_id
        ,pi.dst_store_id
        ,pssn.shipped_at
    from fle_staging.parcel_info pi
    left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = pi.pno
    where
        pssn.shipped_at >= date_sub(curdate(), interval 1 day)
        and pssn.shipped_at < curdate()
        and pssn.store_category in (1,10)
        and pssn.next_store_category in (8,12)
        and pssn.store_id != pi.ticket_pickup_store_id
        and pi.state not in (5,7,8,9)
)
select
    pssn.pno
    ,t1.store_name 网点
    ,pssn.store_name 途径分拨
    ,ss.name  目的地网点
    ,t1.shipped_at 发件出仓时间
    ,pssn.shipped_at 分拨历史发件出仓时间
from dw_dmd.parcel_store_stage_new pssn
join t t1 on t1.pno = pssn.pno and t1.store_id = pssn.next_store_id and t1.next_store_id = pssn.store_id
left join fle_staging.sys_store ss on ss.id = t1.dst_store_id
where
    pssn.valid_store_order is not null
    and pssn.shipped_at < t1.shipped_at


