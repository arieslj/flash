-- https://flashexpress-th.feishu.cn/docx/V2pNd7rrqonVKKxUYJncqqZtnBg


with t as
    (
        select
            put.pno
            ,put.client_id
            ,pi.settlement_category
            ,pi.dst_store_id
            ,concat(pi.src_name, '(', pi.src_phone, ')', pi.src_detail_address) src_info
            ,pi.state
            ,pi.finished_at
            ,pi.ticket_delivery_store_id
            ,pi.returned_pno
            ,pi.ticket_pickup_store_id
            ,pi.ticket_pickup_id
            ,pi.ticket_pickup_staff_info_id
        from bi_pro.parcel_unpickup_task put
        join
            (
                select
                    pi.pno
                    ,pi.settlement_category
                    ,pi.dst_store_id
                    ,pi.src_name
                    ,pi.src_phone
                    ,pi.src_detail_address
                    ,pi.state
                    ,pi.finished_at
                    ,pi.ticket_pickup_id
                    ,pi.ticket_pickup_staff_info_id
                    ,pi.ticket_delivery_store_id
                    ,pi.returned_pno
                    ,pi.ticket_pickup_store_id
                from fle_staging.parcel_info pi
                where
                    pi.created_at > date_sub(curdate(), interval 2 month)
            )pi on pi.pno = put.pno
        where
            put.process_status in (1,2,3)
            and put.punishment_type = 1
    )
select
    t1.pno '面单号/เลขพัสดุ'
    ,t1.client_id '客户ID/ไอดีลูกค้า'
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end '客户类型/ประเภทลูกค้า'
    ,case t1.settlement_category
        when 1 then '现结'
        when 2 then '定结'
    end  '结算类型/วิธีชำระค่าขนส่ง'
    ,ss.name '目的地网点/สาขาปลายทาง'
    ,t1.src_info '发件人信息/ข้อมูลผู้ส่ง'
    ,convert_tz(a1.routed_at, '+00:00', '+07:00') '第一次收件入仓时间/เวลาที่สแกนรับพัสดุเข้าคลังครั้งแรก'
    ,a1.store_name '第一次收件入仓网点/สาขาแรกที่รับพัสดุเข้าคลัง'
    ,convert_tz(a2.routed_at, '+00:00', '+07:00') '第一次集包时间/เวลาที่แบ็กกิ้งครั้งแรก'
    ,a2.store_name '第一次集包网点/สาขาแรกที่แบ็กกิ้งพัสดุ'
    ,convert_tz(a3.routed_at, '+00:00', '+07:00') '第一次到件入仓时间/เวลาที่พัสดุไปถึงสาขาแรก'
    ,a3.store_name '第一次到件入仓网点สาขาแรกที่พัสดุไปถึง'
    ,if(t1.state = 5, convert_tz(t1.finished_at, '+00:00', '+07:00'), null) '包裹妥投时间/เวลาที่ยืนยันการส่งปลายทาง'
    ,if(t1.state = 5, ss2.name, null) '包裹妥投网点/สาขาที่ยืนยันการส่งปลายทาง'
    ,t1.returned_pno '退件单号/returned_pno'
    ,ss3.name '揽件网点/เก็บรวบรวมสาขา'
    ,case ss3.category
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
    ,t1.ticket_pickup_id '揽件任务ID/IDงานรับ'
    ,t1.ticket_pickup_staff_info_id '揽件员工ID/IDผู้รับสินค้า'
    ,hjt.job_name '员工职位/รหัสพนักงาน'
    ,ss4.name '员工网点/สาขา'
from t t1
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = t1.client_id
left join fle_staging.ka_profile kp on kp.id = t1.client_id
left join fle_staging.sys_store ss on ss.id = t1.dst_store_id
left join fle_staging.sys_store ss2 on ss2.id = t1.ticket_delivery_store_id
left join fle_staging.sys_store ss3 on ss3.id = t1.ticket_pickup_store_id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = t1.ticket_pickup_staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join fle_staging.sys_store ss4 on ss4.id = hsi.sys_store_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'RECEIVE_WAREHOUSE_SCAN'
    ) a1 on a1.pno = t1.pno and a1.rk = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'SEAL'
    ) a2 on a2.pno = t1.pno and a2.rk = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_name
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from rot_pro.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.routed_at > date_sub(curdate(), interval 2 month)
            and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    ) a3 on a3.pno = t1.pno and a3.rk = 1
