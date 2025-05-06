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
from ph_staging.parcel_route pr
left join dwm.drds_ph_parcel_route_extra dp on dp.route_extra_id = json_extract(pr.extra_value, '$.routeExtraId') and  dp.created_at > '2024-12-30 01:00:00'
left join dwm.dim_ph_sys_store_rd dt on dt.store_id = pr.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
where
    pr.route_action in ('PRINTING', 'REPLACE_PNO')
    and pr.routed_at > '2024-12-31 00:00:00'
    and pr.routed_at < '2024-12-31 04:00:00'


;



select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10' -- QC不看之前的数据
    and ra.status = 2
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
    and ra.final_approval_time < date_add(curdate(), interval 13 hour )
group by 1

;


