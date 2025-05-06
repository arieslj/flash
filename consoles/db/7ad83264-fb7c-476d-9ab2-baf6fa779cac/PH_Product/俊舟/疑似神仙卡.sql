-- 所有通话记录特征为 响铃3-5s 通话时长 14-17s

select
    pr.pno
    ,pr.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pr.staff_info_id 操作人
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
    ,json_extract(pr.extra_value, '$.carrierName') 运营商
from ph_staging.parcel_route pr
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'PHONE'
    and pr.routed_at > '2023-12-10 16:00:00'
    and json_extract(pr.extra_value, '$.callDuration') >= 14
    and json_extract(pr.extra_value, '$.callDuration') <= 17
    and json_extract(pr.extra_value, '$.diaboloDuration') >= 3
    and json_extract(pr.extra_value, '$.diaboloDuration') <= 5
group by 1,2,3,4,5,6,7