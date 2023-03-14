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
        and wo.created_at >= '2023-03-13'
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
        when wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707') then 'Shopee'
        when wo.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601') then 'Lazada'
        when wo.client_id in ('AA0660','AA0661','AA0703') then 'Tiktok'
    end 平台客户
    ,case ci.requester_category
        when 0 then '托运人员'
        when 1 then '收货人员'
        when 2 then '操作人员'
        when 3 then '销售人员'
        when 4 then '客服人员'
    end 请求者角色
    ,case ci.channel_category # 渠道
         when 0 then '电话'
         when 1 then '电子邮件'
         when 2 then '网页'
         when 3 then '网点'
         when 4 then '自主投诉页面'
         when 5 then '网页（facebook）'
         when 6 then 'APPSTORE'
         when 7 then 'Lazada系统'
         when 8 then 'Shopee系统'
         when 9 then 'TikTok'
    end 请求渠道
    ,case wo.status
        when 1 then '未阅读'
        when 2 then '已经阅读'
        when 3 then '已回复'
        when 4 then '已关闭'
    end 工单状态
    ,wo.title 工单主题
    ,case wo.order_type
        when 1 then '查找运单'
        when 2 then '加快处理'
        when 3 then '调查员工'
        when 4 then '其他'
        when 5 then '网点信息维护提醒'
        when 6 then '培训指导'
        when 7 then '异常业务询问'
        when 8 then '包裹丢失'
        when 9 then '包裹破损'
        when 10 then '货物短少'
        when 11 then '催单'
        when 12 then '有发无到'
        when 13 then '上报包裹不在集包里'
        when 16 then '漏揽收'
        when 50 then '虚假撤销'
        when 17 then '已签收未收到'
        when 18 then '客户投诉'
        when 19 then '修改包裹信息'
        when 20 then '修改 COD 金额'
        when 21 then '解锁包裹'
        when 22 then '申请索赔'
        when 23 then 'MS 问题反馈'
        when 24 then 'FBI 问题反馈'
        when 25 then 'KA System 问题反馈'
        when 26 then 'App 问题反馈'
        when 27 then 'KIT 问题反馈'
        when 28 then 'Backyard 问题反馈'
        when 29 then 'BS/FH 问题反馈'
        when 30 then '系统建议'
        when 31 then '申诉罚款'
        else wo.order_type
    end  工单类型
    ,wo.created_at 工单创建时间
    ,rep.created_at 工单回复时间
    ,case wo.is_call
        when 0 then '不需要'
        when 1 then '需要'
    end 致电客户
    ,case wo.up_report
        when 0 then '否'
        when 1 then '是'
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
    ,ss.sorting_no 区域
    ,smr.name Area
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
    end as 运单状态
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
left join fle_staging.parcel_info pi on wo.pnos = pi.pno
left join pho p1 on p1.pno = wo.pnos and p1.rk = 1
left join pho p2 on p2.pno = wo.pnos and p2.rk = 1

where
    wo.created_store_id = 3 -- 总部客服中心
    and wo.created_at >= '2023-03-13'
    and wo.client_id in ('AA0386','AA0425','AA0427','AA0569','AA0572','AA0574','AA0606','AA0612','AA0657','AA0707','AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0538','AA0601','AA0660','AA0661','AA0703')