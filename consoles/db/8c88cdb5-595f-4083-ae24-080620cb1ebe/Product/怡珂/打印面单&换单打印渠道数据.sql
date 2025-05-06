select
    pr.pno
    ,case json_extract(dp.extra_value, '$.printLabelChannelCategory')
        when 0 then 'KIT换单打印'
        when 1 then 'KIT查件'
        when 2 then 'kIT揽收打印'
        when 3 then 'kit其他'
        when 4 then 'MS-打印预览'
        when 5 then '客户端IPC'
        when 6 then '客户端FH'
        when 7 then '客户端BS'
    end 打印渠道
    ,case json_extract(dp.extra_value, '$.printLabelType')
        when 0 then '主动打印'
        when 1 then '系统提示'
    end '主动/系统提示'
     ,case json_extract(dp.extra_value, '$.replacementEnabled')
        when true then '是'
        when false then '否'
    end '是否有换单标记'
    ,case json_extract(pr.extra_value, '$.fromScanner')
        when true then '扫描打印'
        when false then '手输打印'
        else '任务打印'
    end 打印方式
    ,pr.staff_info_id 操作人
    ,pr.store_name 操作网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
from rot_pro.parcel_route pr
left join dwm.drds_parcel_route_extra dp on dp.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId') and dp.created_at > '2024-12-30 01:00:00'
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pr.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action in ('PRINTING', 'REPLACE_PNO')
    and pr.routed_at > '2024-12-31 01:00:00'
    and pr.routed_at < '2024-12-31 05:00:00'