select
    a.pno
    ,ss.name  网点
    ,a.arrive_dst_route_at  到仓时间
    ,a.cod_amount/100 cod
    ,case a.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 当前状态
    ,convert_tz(a.state_change_at, '+00:00', '+08:00') 终态时间
from
    (
        select
            pi.pno
            ,ps.arrive_dst_store_id
            ,ps.arrive_dst_route_at
            ,pi.cod_amount
            ,pi.state
            ,pi.state_change_at
            ,coalesce(convert_tz(pi.state_change_at, '+00:00', '+08:00'), now()) end_at
        from ph_staging.parcel_info pi
        join ph_bi.parcel_sub ps on ps.pno = pi.pno
        where
            ps.arrive_dst_route_at > '2024-12-01'
          --  and ps.arrive_dst_route_at < '2024-12-01'
            and pi.cod_amount > 200000
    ) a
left join ph_staging.sys_store ss on ss.id = a.arrive_dst_store_id
where
    timestampdiff(hour, a.arrive_dst_route_at, a.end_at) > 168