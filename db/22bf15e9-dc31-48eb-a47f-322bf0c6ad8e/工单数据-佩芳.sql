with rep as
(
    select
        wo.order_no
        ,wo.pnos
        ,wor.created_at
        ,row_number() over (partition by wo.order_no order by wor.created_at ) rn
    from bi_pro.work_order wo
    left join bi_pro.work_order_reply wor on wo.id = wor.order_id
    where
        wo.created_store_id = 3
        and wo.created_at >= date_sub(curdate(), interval 1 day)
        and wo.created_at < curdate()
)
, pho as
(
    select
        pr.pno
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk2
    from rot_pro.parcel_route pr
    join
        (
            select rep.pnos from rep group by 1
        ) r on pr.pno = r.pnos
    where
        pr.route_action = 'PHONE'
)
select
    date(wo.created_at) Date
    ,wo.order_no 'Ticket ID'
    ,wo.pnos 运单号
    ,wo.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then 'ka'
        when kp.`id` is null then 'GE'
    end '平台客户ลูกค้าแพลตฟอร์ม'
    ,case ci.requester_category
        when 0 then '托运人员 ผู้ส่ง'
        when 1 then '收货人员 ผู้รับ'
        when 2 then '操作人员 ฝ่ายปฏิบัติการ(Operation)'
        when 3 then '销售人员 พนักงานขาย(Sales)'
        when 4 then '客服人员 ฝ่ายบริการลูกค้า(CS)'
    end '请求者角色ผู้ร้องขอ'
    ,case ci.channel_category
         when 0 then '电话 โทรศัพท์'
         when 1 then '电子邮件 อีเมล'
         when 2 then '网页 เว็บไซต์'
         when 3 then '网点 สาขา'
         when 4 then '自主投诉页面 การส่งคำร้องโดยลูกค้า'
         when 5 then '网页（facebook） facebook'
         when 6 then 'APPSTORE APPSTORE'
         when 7 then 'Lazada系统 X-Space（LZD）'
         when 8 then 'Shopee系统 In House(Shopee)'
         when 9 then 'TikTok TikTok'
    end '请求渠道ช่องทางการติดต่อ'
    ,case wo.status
        when 1 then '未阅读ไม่ได้อ่าน'
        when 2 then '已经阅读อ่านแล้ว'
        when 3 then '已回复ตอบกลับแล้ว'
        when 4 then '已关闭ปิดแล้ว'
    end '状态สถานะTicket'
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单 ค้นหาพัสดุ'
        when 2 then '加快处理 เร่งจัดการ'
        when 3 then '调查员工 ตรวจสอบพนักงาน'
        when 4 then '其他 อื่นๆ'
        when 5 then '网点信息维护提醒 แจ้งเตือนดูแลข้อมูลสาขา'
        when 6 then '培训指导 แนะนำอบรม'
        when 7 then '异常业务询问 ตรวจสอบการทำงานผิดปกติ'
        when 8 then '包裹丢失 พัสดุสูญหาย'
        when 9 then '包裹破损 พัสดุเสียหาย'
        when 10 then '货物短少 พัสดุขาดหาย'
        when 11 then '催单 เร่งติดตามพัสดุ'
        when 12 then '有发无到 พัสดุตกหล่น'
        when 13 then '上报包裹不在集包里 รายงานพัสดุไม่อยู่ในถุงแบ๊คกิ้ง'
        when 16 then '漏揽收 รับพัสดุตกหล่น'
        when 50 then '虚假撤销 ยกเลิกเป็นเท็จ'
        when 17 then '已签收未收到 เซ็นรับไม่ได้รับ'
        when 18 then '客户投诉 ลูกค้าร้องเรียน'
        when 19 then '修改包裹信息 แก้ไขข้อมูลพัสดุ'
        when 20 then '修改 COD 金额 แก้ไขยอดCOD'
        when 21 then '解锁包裹 ปลดล็อกพัสดุ'
        when 22 then '申请索赔 เคลม'
        when 23 then 'MS 问题反馈 แจ้งปัญหาMS'
        when 24 then 'FBI 问题反馈 แจ้งปัญหาFBI'
        when 25 then 'KA System 问题反馈 แจ้งปัญหาKA System'
        when 26 then 'App 问题反馈 แจ้งปัญหาApp'
        when 27 then 'KIT 问题反馈 แจ้งปัญหาKIT'
        when 28 then 'Backyard 问题反馈 แจ้งปัญหาBackyard'
        when 29 then 'BS/FH 问题反馈 แจ้งปัญหาBS/FH'
        when 30 then '系统建议 คำแนะนำระบบ'
        when 31 then '申诉罚款 ยื่นขอคืนค่าปรับ'
        else wo.order_type
    end  '工单类型ประเภทTicket'
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要 ไม่ต้องการ'
        when 1 then '需要 ต้องการ'
    end '致电客户ลูกค้าต้องการให้โทรหาหรือไม่'
    ,if(timestampdiff(second, coalesce(rep.created_at, now()), wo.latest_deal_at) > 0, 'NO', 'YES') 是否超时
    ,case wo.up_report
        when 0 then 'NO'
        when 1 then 'YES'
    end 是否上报虚假工单
    ,datediff(wo.updated_at, wo.created_at) 工单处理天数
    ,wo.store_id '受理网点ID/部门'
    ,case
        when ss.`category` in (1,2,10,13) then 'sp'
        when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
        when ss.`category` IN (4,5,7) then 'SHOP/ushop'
        when ss.`category` IN (6)  then 'FH'
        when wo.`store_id` = '22' then 'kam客服中心'
        when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
        when wo.`store_id`= '12' then 'QA&QC'
        when wo.`store_id`= '18' then 'Flash Home客服中心'
        when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
        else '其他网点'
    end 受理部门
    ,ss.name 网点名称
    ,ss.sorting_no 区域
    ,smr.name Area
    ,smp.name 片区
    ,case pi.state
        when 1 then '已揽收 รับพัสดุแล้ว'
        when 2 then '运输中 ระหว่างการขนส่ง'
        when 3 then '派送中 ระหว่างการจัดส่ง'
        when 4 then '已滞留 พัสดุคงคลัง'
        when 5 then '已签收 เซ็นรับแล้ว'
        when 6 then '疑难件处理中 ระหว่างจัดการพัสดุมีปัญหา'
        when 7 then '已退件 ตีกลับแล้ว'
        when 8 then '异常关闭 ปิดงานมีปัญหา'
        when 9 then '已撤销 ยกเลิกแล้ว'
    end as '运单状态สถานะพัสดุ'
    ,if(pi.state = 5, date(convert_tz(pi.finished_at, '+00:00', '+07:00')), null) 妥投日期
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+07:00'), null ) 妥投时间
    ,convert_tz(p1.routed_at, '+00:00', '+07:00') 第一次联系客户
    ,convert_tz(p2.routed_at, '+00:00', '+07:00') 最后联系客户
    ,if(pi.state = 5, datediff(date(convert_tz(pi.finished_at, '+00:00', '+07:00')), date(convert_tz(pi.created_at, '+00:00', '+07:00'))), null) 揽收至妥投
    ,datediff(curdate(), date(convert_tz(pi.created_at, '+00:00', '+07:00'))) 揽收至今
from bi_pro.work_order wo
join fle_staging.customer_issue ci on wo.customer_issue_id = ci.id
left join rep on rep.order_no = wo.order_no and rep.rn = 1
left join fle_staging.sys_store ss on ss.id = wo.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1
left join fle_staging.ka_profile kp on kp.id = wo.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = wo.client_id
where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= date_sub(curdate(), interval 1 day)
    and wo.created_at < curdate()
