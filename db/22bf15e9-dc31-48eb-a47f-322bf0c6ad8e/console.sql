select
    ds.store_name 网点名称
    ,ds.region_name 大区
    ,ds.piece_name 片区
    ,count(if(pls.state = 1, pls.id, null)) 待处理数量
    ,count(distinct if(pls.state = 1, pls.pno, null)) 待处理包裹量
    ,count(if(pls.state = 3 , pls.id, null)) 超时自动处理量
    ,count(distinct if(pls.state = 3, pls.pno, null)) 超时自动处理包裹量
    ,count(if(pls.state = 2 , pls.id, null)) 网点处理量
    ,count(distinct if(pls.state = 2, pls.pno, null)) 网点处理包裹量
from bi_center.parcel_lose_task_sub_c pls
left join dwm.dim_th_sys_store_rd ds on pls.store_id = ds.store_id and ds.stat_date = date_sub(curdate(), interval 1 day )
where
    pls.created_at > '2023-01-09 00:00:00'
group by 1,2,3

;

SELECT
distinct pls.pno '运单号เลขพัสดุ'
,ds.store_name '网点名称'
,pls.created_at '任务生成时间เวลาที่จัดการสำเร็จ'
,if(
    TIMESTAMPDIFF(hour,pls.created_at,now())<48,
concat(cast(TIMESTAMPDIFF(minute,now(),date_add(pls.created_at,interval 2 day))/60 as int),'h ',cast(round(TIMESTAMPDIFF(minute,now(),date_add(pls.created_at,interval 2 day))%60,0)as int),'min'),
concat('已超时',concat(cast(TIMESTAMPDIFF(minute,date_add(pls.created_at,interval 2 day),now())/60 as int),'h ',cast(round(TIMESTAMPDIFF(minute,date_add(pls.created_at,interval 2 day),now())%60,0)as int),'min'))) '任务处理倒计时เวลาที่สะสม'
,pls.pack_no '集包号เลขแบ็กกิ้ง'
,pls.arrival_time '入仓时间เวลาที่เข้าคลัง'
,pls.parcel_created_at '揽件时间เวลาที่รับ'
,pls.proof_id '出车凭证ใบรับรองปล่อยรถ'
,case pls.state
when 1 then '待处理'
when 2 then '网点处理'
when 3 then '超时自动处理'
when 4 then 'QAQC处理'
when 5 then '已更新路由(无需处理)'
end  '状态สถานะ'
,case pls.speed
when 1 then '是'
when 2 then '否'
end  'SPEED件มีพัสดุSpeed'
,pls.last_valid_action '最后有效路由สถานะสุดท้าย'
,pls.last_valid_at '最后操作时间เวลาสุดท้ายที่ดำเนินการ'
,ds2.store_name '最后有效路由所在网点สาขาสุดท้ายที่ดำเนินการ'
,ds.piece_name '片区District'
,ds.region_name '大区Area'
from bi_center.parcel_lose_task_sub_c pls
left join dwm.dim_th_sys_store_rd ds on pls.store_id = ds.store_id and ds.stat_date = date_sub(curdate(), interval 1 day )
left join dwm.dim_th_sys_store_rd ds2 on pls.last_valid_store_id = ds2.store_id and ds2.stat_date = date_sub(curdate(), interval 1 day )
where
    pls.created_at > '2023-01-09 00:00:00'
    and pls.state=1
group by 1

;

select
    *
from bi_center.parcel_lose_task_sub_c pls
where
    pls.state = 1
    and pls.store_id = ''