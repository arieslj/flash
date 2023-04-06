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
;

SELECT
    distinct pls.pno '运单号เลขพัสดุ'
    ,c.created_at 首次预警时间
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
    ,bc.client_name 客户名称
from bi_center.parcel_lose_task_sub_c pls
left join fle_staging.parcel_info pi on pi.pno = pls.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join dwm.dim_th_sys_store_rd ds on pls.store_id = ds.store_id and ds.stat_date = date_sub(curdate(), interval 1 day )
left join dwm.dim_th_sys_store_rd ds2 on pls.last_valid_store_id = ds2.store_id and ds2.stat_date = date_sub(curdate(), interval 1 day )
left join
    (
        select
            pls.pno
            ,plt.created_at
            ,row_number() over (partition by pls.pno order by plt.created_at) rn
        from bi_center.parcel_lose_task_sub_c pls
        left join bi_pro.parcel_lose_task plt on pls.pno = plt.pno and plt.source = 3
        where
             pls.created_at > '2023-01-09 00:00:00'
            and pls.state= 1
    ) c on c.pno = pls.pno and c.rn = 1
where
    pls.created_at > '2023-01-09 00:00:00'
    and pls.state=1
group by 1
;
select
    hsi.staff_info_id
    ,ss.name
from bi_pro.hr_staff_info hsi
left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    hsi.staff_info_id in (52613,632192,3365244)
;

select
    plt.pno 运单号
    ,plt.id
    ,if(pi.returned = 1, pi.pno, pi.recent_pno) 退件单号
    ,ss.name 判定责任网点
    ,dst_ss.name 目的地网点
    ,ss2.name 揽件网点
    ,pi.cod_amount/100 COD金额
    ,plt.last_valid_action 最后有效路由
    ,plt.last_valid_staff_info_id 最后有效路由操作员工
    ,ss3.name 最后有效路由操作人所属网点
    ,plr.staff_id 责任人
    ,hsi2.is_sub_staff
    ,hsi2.name 责任人姓名
    ,ss4.name 责任人所属网点
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join bi_pro.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join fle_staging.sys_store ss on ss.id = plr.store_id
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = plt.last_valid_staff_info_id
left join fle_staging.sys_store ss3 on ss3.id = hsi.sys_store_id
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = plr.staff_id
left join fle_staging.sys_store ss4 on ss4.id = hsi2.sys_store_id
where
    plt.updated_at >= '2023-03-01'
    and plt.state = 6
    and plt.duty_result = 1
    and plt.source in (1,2,3,12)
    and plr.store_id = 'TH01400201'

;



-- 任务维度
select
tp.id 揽件任务id
,convert_tz(oi.created_at,'+00:00','+07:00') 创建订单时间
,convert_tz(oi.confirm_at,'+00:00','+07:00') 确认下单时间
,oi.pno 运单号
,tp.client_id
,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
,convert_tz(tp.pickup_created_at,'+00:00','+07:00') 揽件任务生成时间
,tr.remark 取消原因备注
,concat( 'https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/'  ,sa.object_key) 取消揽件任务照片
,convert_tz(tr.routed_at,'+00:00','+07:00') 取消任务时间
,tp.staff_info_id 标记快递员ID
,ss.name 标记快递员所属网点
,case oi.state
 when 0 then '已确认'
 when 1 then '待揽件'
 when 2 then '已揽收'
 when 3 then '已取消(已终止)'
 when 4 then '已删除(已作废)'
 when 5 then '预下单'
 when 6 then '被标记多次，限制揽收'
end as 订单状态
,convert_tz(pi.created_at,'+00:00','+07:00') 揽收时间
,pi.ticket_pickup_staff_info_id 揽收快递员
,ss2.name 揽收快递员网点
,if(oi.state=3,convert_tz(oi.aborted_at,'+00:00','+07:00'),null) 取消订单时间
,if(tcf.pickup_id is not null ,'是','否') '是否进入【FBI-QAQC-虚假标记审核-标记超大件、违禁物品审核】'
,case tcf.state
when 1 then '待处理'
when 2 then '责任人已认定'
when 3 then '无需判责'
end 判责结果
,tcf.process_time 审核时间
,tcf.staff_info_id 责任快递员ID
,tcf.store_name 责任快递员网点

from fle_staging.ticket_pickup tp

left join dwm.tmp_ex_big_clients_id_detail bc
on tp.client_id=bc.client_id

left join fle_staging.ka_profile kp
on tp.client_id=kp.id

left join fle_staging.ticket_pickup_order_relation tpo -- 转单前任务id
on if(tp.transfer_ancestry is not null,substring(tp.transfer_ancestry,1,9),tp.id)=tpo.ticket_pickup_id

left join bi_pro.ticket_cancel_fake_mark tcf -- 【FBI-QAQC-虚假标记审核-标记超大件、违禁物品审核】
on tp.id=tcf.pickup_id

left join fle_staging.order_info oi
on tpo.order_id=oi.id

left join fle_staging.parcel_info pi
on oi.pno=pi.pno
left join bi_pro.hr_staff_info hsi2
on pi.ticket_pickup_staff_info_id=hsi2.staff_info_id
left join fle_staging.sys_store ss2
on hsi2.sys_store_id=ss2.id

left join bi_pro.hr_staff_info hsi
on tp.staff_info_id=hsi.staff_info_id

left join fle_staging.sys_store ss
on hsi.sys_store_id=ss.id

left join m2_pro.ticket_route tr
on tp.id=tr.current_ticket_id

left join fle_staging.sys_attachment sa
on tp.id=sa.oss_bucket_key
and sa.oss_bucket_type in ('TICKET_CANCEL_PICKUP_MARK_UPLOAD','TICKET_CANCEL_CANCEL_ORDER_PHOTO_UPLOAD')

left join fle_staging.ticket_pickup_marker tpm
on tp.id=tpm.pickup_id

where 1=1
and tcf.process_time>='2023-03-01'
and tcf.process_time<'2023-03-29'
and tp.state=4 -- 取消任务
and tr.route_action=2
-- and tr.operator_type<>6
and tpm.marker_id in (87,100) -- 违禁品
-- and tp.id=417050585

group by 1,4
;
select substring_index()