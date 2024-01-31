select
    pi.src_phone 寄件人电话
    ,pi.pno 单号
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
    end as 包裹状态
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
    ,ss.name 目的地网点
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    pi.created_at > '2023-10-31 16:00:00'
    and pi.created_at < '2024-01-01 16:00:00'
    and pi.state < 9
    and pi.src_phone in ('09109699191', '09988454945', '09772111322', '09176331532')