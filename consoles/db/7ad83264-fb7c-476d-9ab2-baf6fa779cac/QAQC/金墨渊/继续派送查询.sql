select
    ct.pno 正向运单号
    ,pi.returned_pno 退件单号
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.client_id 客户ID
    ,pi.cod_amount/100 COD金额
    ,pi.exhibition_weight/1000 包裹重量
    ,convert_tz(ct.routed_at,'+00:00','+08:00') 修改时间
    ,ct.staff_info_id 修改ID
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
    end 包裹最后状态
    ,if(pi.state = 5, pi.ticket_delivery_staff_info_id, null) 操作ID
    ,if(pi.state = 5, convert_tz(pi.finished_at,'+00:00','+08:00'), null) 操作时间
from
    (
        select
            *
        from
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                    ,pr.staff_info_id
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                from ph_staging.parcel_route pr
                where
                    pr.route_action = 'CONTINUE_TRANSPORT'
                    and pr.routed_at > date_sub(date_sub(curdate(), interval 1 month), interval 8 hour)
                    and pr.routed_at < date_sub(curdate(), interval 8 hour) -- 今天之前
            ) a
        where
            a.rk = 1
    ) ct
join
    (
        select
            pr.pno
            ,max(pr.routed_at) routed_time
        from ph_staging.parcel_route pr
        where
            pr.route_action = 'PENDING_RETURN'
            and pr.routed_at > date_sub(curdate(), interval 3 month)
        group by 1
    ) pt on pt.pno = ct.pno
left join ph_staging.parcel_info pi on pi.pno = ct.pno
left join ph_bi.parcel_detail pd on pd.pno = ct.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.last_valid_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    ct.routed_at > pt.routed_time