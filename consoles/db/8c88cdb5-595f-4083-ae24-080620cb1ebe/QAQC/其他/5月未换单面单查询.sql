select
    t.pno
    ,pi.client_id '客户ID/ไอดีลูกค้า'
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  '客户类型/ประเภทลูกค้า'
    ,case pi.settlement_category
        when 1 then '现结'
        when 2 then '定结'
    end  '结算类型/วิธีชำระค่าขนส่ง'
    ,dst_ss.name '目的地网点/สาขาปลายทาง'
    ,concat(pi.src_name, '-', pi.src_phone, '-', pi.src_detail_address) '发件人信息/ข้อมูลผู้ส่ง'
    ,convert_tz(rwc.routed_at, '+00:00', '+07:00') '第一次收件入仓时间/เวลาที่สแกนรับพัสดุเข้าคลังครั้งแรก'
    ,rwc.store_name '第一次收件入仓网点/สาขาแรกที่รับพัสดุเข้าคลัง'
    ,convert_tz(sl.routed_at, '+00:00', '+07:00') '第一次集包时间/เวลาที่แบ็กกิ้งครั้งแรก'
    ,sl.store_name '第一次集包网点/สาขาแรกที่แบ็กกิ้งพัสดุ'
    ,convert_tz(awc.routed_at, '+00:00', '+07:00') '第一次到件入仓时间/เวลาที่พัสดุไปถึงสาขาแรก'
    ,awc.store_name '第一次到件入仓网点สาขาแรกที่พัสดุไปถึง'
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null)  '包裹妥投时间/เวลาที่ยืนยันการส่งปลายทาง'
    ,if(pi.state = 5, fin_ss.name, null) '包裹妥投网点/สาขาที่ยืนยันการส่งปลายทาง'
    ,pi.returned_pno '退件单号/returned_pno'
    ,pick_ss.name '揽件网点/เก็บรวบรวมสาขา'
    ,case pick_ss.category
        when 1 then 'SP'
        when 2 then 'DC'
        when 4 then 'SHOP'
        when 5 then 'SHOP'
        when 6 then 'FH'
        when 7 then 'SHOP'
        when 8 then 'Hub'
        when 9 then 'Onsite'
        when 10 then 'BDC'
        when 11 then 'fulfillment'
        when 12 then 'B-HUB'
        when 13 then 'CDC'
        when 14 then 'PDC'
    end '揽件网点类型/ประเภทสาขา'
    ,pi.ticket_pickup_id '揽件任务ID/IDงานรับ'
    ,pi.ticket_pickup_staff_info_id '揽件员工ID/IDผู้รับสินค้า'
    ,hjt.job_name '员工职位/รหัสพนักงาน'
    ,hsi_ss.name '员工网点/สาขา'
from tmpale.tmp_th_pno_lj_0612 t
left join fle_staging.parcel_info pi on pi.pno = t.pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.sys_store fin_ss on fin_ss.id = pi.ticket_delivery_store_id
left join fle_staging.sys_store pick_ss on pick_ss.id = pi.ticket_pickup_store_id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_pickup_staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join fle_staging.sys_store hsi_ss on hsi_ss.id = hsi.sys_store_id
-- 收件入仓
left join
    (
        select
            t.pno
            ,pr.routed_at
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_0612 t on t.pno = pr.pno
        where
            pr.route_action = 'RECEIVE_WAREHOUSE_SCAN'
            and pr.routed_at > '2024-04-15'
    ) rwc on rwc.pno = t.pno and rwc.rk = 1
-- 集包
left join
    (
        select
            t.pno
            ,pr.routed_at
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_0612 t on t.pno = pr.pno
        where
            pr.route_action = 'SEAL'
            and pr.routed_at > '2024-04-15'
    ) sl on sl.pno = t.pno and sl.rk = 1
-- 到件入仓
left join
    (
        select
            t.pno
            ,pr.routed_at
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
        from rot_pro.parcel_route pr
        join tmpale.tmp_th_pno_lj_0612 t on t.pno = pr.pno
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            and pr.routed_at > '2024-04-15'
    ) awc on awc.pno = t.pno and awc.rk = 1


;

select * from tmpale.tmp_th_pno_lj_0612 t

