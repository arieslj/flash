-- 需求文档：https://flashexpress.feishu.cn/wiki/ObOxwqLujiTCrjk4YSqcm0OqnGe

select
    concat('SSRD', t.task_id) id
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
    end  问题渠道
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case plt.state
        when 1 then '待处理'   -- 待处理
        when 2 then '待处理' -- 待处理
        when 3 then '待工单回复'  -- 待工单回复
        when 4 then '已工单回复' -- 已工单回复
        when 5 then '无须追责'  -- 无须追责
        when 6 then '责任人已认定' -- 责任人已认定
    end 闪速最终判责结果
    ,if(pct.pno is not null, 'Y', 'N' ) 最终是否丢失理赔
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 确认妥投时间
from bi_pro.parcel_lose_task plt
join tmpale.tmp_th_plt_task_id_0131 t on t.task_id = plt.id
left join fle_staging.customer_issue ci on ci.id = plt.source_id
left join fle_staging.ka_profile kp on kp.id = plt.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
left join bi_pro.parcel_claim_task pct on pct.pno = plt.pno and pct.state = 6
left join rot_pro.parcel_route pr on pr.pno = plt.pno and pr.route_action = 'DELIVERY_CONFIRM'

;



select
    pci.merge_column
    ,case  pci.client_type
        when 1 then 'lazada'
        when 2 then 'shopee'
        when 3 then 'tiktok'
        when 4 then 'shein'
        when 5 then 'otherKAM'
        when 6 then 'otherKA'
        when 7 then '小C'
    end 客户类型
    ,case pci.source
        when 1 then '问题记录本'
        when 2 then '疑似违规回访'
        when 3 then 'APP'
        when 4 then '官网'
        when 5 then '短信'
        when 6 then 'FBI'
        when 7 then 'WhatsApp'
    end 任务渠道
    ,pci.created_at 询问任务生成时间
    ,pci.apology_at 询问任务完成时间
    ,pci.staff_info_id 询问任务员工
    ,dt.store_name  询问任务网点
    ,dt.piece_name 询问任务所属片区
    ,dt.region_name 询问任务所属大区
    ,case pci.apology_type
        when 0 then '进行中'
        when 1 then '已超时关闭'
        when 2 then '道歉后自动关闭'
        when 3 then '无需处理自动关闭'
    end 询问任务处理状态
    ,pci.qaqc_created_at 回访任务生成时间
    ,case pci.qaqc_is_receive_parcel
        when 0 then '未处理'
        when 1 then '联系不上'
        when 2 then '已收到包裹'
        when 3 then '未收到包裹'
        when 4 then '未收到包裹,已有约定派送时间'
    end 回访结果
    ,pci.staff_info_id 责任人
    ,hjt2.job_name 责任人职务
    ,hsi2.leave_date 责任人离职时间
    ,pci.apology_staff_info_id 实际处理人工号
    ,a1.duty_manager 责任人2
    ,hjt.job_name 实际处理人职务
    ,dt.store_name 回访任务网点
    ,if(hsi.is_sub_staff = 1, 'Y', 'N') 是否支援员工
    ,case
        when 0 then 'N'
        when 1 then 'Y'
    end 是否退件
    ,if(tn.双重预警 = 'Alert', 'Y', 'N') 当日是否爆仓
from bi_center.parcel_complaint_inquiry pci
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pci.store_id and dt.stat_date = date_sub(curdate(), 1)
left  join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pci.apology_staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join fle_staging.parcel_info pi on pi.pno = pci.merge_column
left join dwm.dwd_th_network_spill_detl_rd tn on tn.网点ID = pci.store_id and tn.统计日期 = date(pci.created_at)
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = pci.staff_info_id
left join bi_pro.hr_job_title hjt2 on hjt2.id = hsi2.job_title
left join
    (
        select
            pci.id
            ,coalesce(ss.manager_id, smp.manager_id, smr.manager_id) duty_manager
        from bi_center.parcel_complaint_inquiry pci
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pci.staff_info_id
        left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
        left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
        left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
        where
            pci.created_at >= '2023-12-29'
            and pci.created_at < '2024-01-30'
            and pci.staff_formal = 1
            and hsi.is_sub_staff = 0

        union all

        select
            pci.id
            ,group_concat(hsa.staff_store_id, ss.manager_id, ss2.manager_id) duty_manager
        from bi_center.parcel_complaint_inquiry pci
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pci.staff_info_id
        left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
        left join backyard_pro.hr_staff_apply_support_store hsa on hsa.sub_staff_info_id = pci.staff_info_id
        left join bi_pro.hr_staff_info hsi3 on hsi3.staff_info_id = hsa.staff_info_id
        left join fle_staging.sys_store ss2 on ss2.id = hsi3.sys_store_id
        where
            pci.created_at >= '2023-12-29'
            and pci.created_at < '2024-01-30'
            and pci.staff_formal = 1
            and hsi.is_sub_staff = 1
        union all

        select
            pci.id
            ,ss.manager_id duty_manager
        from bi_center.parcel_complaint_inquiry pci
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pci.staff_info_id
        left join fle_staging.sys_store ss on ss.id = hsi.sys_store_id
        where
            pci.created_at >= '2023-12-29'
            and pci.created_at < '2024-01-30'
            and pci.staff_formal = 2
    ) a1 on a1.id = pci.id
where
    pci.created_at >= '2023-12-29'
    and pci.created_at < '2024-01-30'

;

select
    pci.merge_column 单号
    ,pci.staff_info_id 询问任务员工
    ,case  pci.client_type
        when 1 then 'lazada'
        when 2 then 'shopee'
        when 3 then 'tiktok'
        when 4 then 'shein'
        when 5 then 'otherKAM'
        when 6 then 'otherKA'
        when 7 then '小C'
    end 客户类型
    ,case pci.source
        when 1 then '问题记录本'
        when 2 then '疑似违规回访'
        when 3 then 'APP'
        when 4 then '官网'
        when 5 then '短信'
    end 任务渠道
    ,pci.complaints_at 用户反馈时间
    ,pci.apology_at 快递员处理时间
    ,case pci.apology_type
        when 0 then '进行中'
        when 1 then '已超时关闭'
        when 2 then '道歉后自动关闭'
        when 3 then '无需处理自动关闭'
    end 询问任务处理状态
    ,pci.qaqc_created_at 回访任务生成时间
    ,pci.qaqc_callback_at 回访任务完成时间
    ,case pci.qaqc_is_receive_parcel
        when 0 then '未处理'
        when 1 then '联系不上'
        when 2 then '已收到包裹'
        when 3 then '未收到包裹'
        when 4 then '未收到包裹,已有约定派送时间'
    end 回访结果
    ,acc.created_at 进入投诉时间
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '无须追责'
        when 6 then '责任人已认定'
    end 客诉的判责结果
    ,pct.claim_money 理赔金额
    ,aq.appeal_time 申诉时间
    ,aq.handle_time 申诉处理时间
    ,case
        when coalesce(am.isappeal, aq.isappeal) = 1 then '未申诉'
        when coalesce(am.isappeal, aq.isappeal) = 2 then '申诉中'
        when coalesce(am.isappeal, aq.isappeal) = 3 then '保持原判'
        when coalesce(am.isappeal, aq.isappeal) = 4 then '已变更'
        when coalesce(am.isappeal, aq.isappeal) = 5 or am.isdel = 1 then '已删除'
    end 申诉结果
    ,if(pci.callback_state = 4 or pci.qaqc_is_receive_parcel in (3,4), 'Y', 'N') 询问任务是否丢失处罚
    ,pai.cogs_amount/100 cogs
    ,if(am2.id is not null, 'Y', 'N') 第一次询问任务是否处罚
    ,case
        when coalesce(am2.isappeal, aq2.isappeal) = 1 then '未申诉'
        when coalesce(am2.isappeal, aq2.isappeal) = 2 then '申诉中'
        when coalesce(am2.isappeal, aq2.isappeal) = 3 then '保持原判'
        when coalesce(am2.isappeal, aq2.isappeal) = 4 then '已变更'
        when coalesce(am2.isappeal, aq2.isappeal) = 5 or am2.isdel = 1 then '已删除'
    end 第一次询问任务处罚申诉结果
    ,if(am3.id is not null, 'Y', 'N') 第二次进入询问任务是否生成客诉处罚
    ,case
        when coalesce(am3.isappeal, aq3.isappeal) = 1 then '未申诉'
        when coalesce(am3.isappeal, aq3.isappeal) = 2 then '申诉中'
        when coalesce(am3.isappeal, aq3.isappeal) = 3 then '保持原判'
        when coalesce(am3.isappeal, aq3.isappeal) = 4 then '已变更'
        when coalesce(am3.isappeal, aq3.isappeal) = 5 or am3.isdel = 1 then '已删除'
    end 第二次进入询问任务是否生成客诉处罚申诉结果
from bi_center.parcel_complaint_inquiry pci
left join bi_center.parcel_complaint_inquiry_punish pcip on pcip.merge_column = pci.merge_column
left join bi_pro.abnormal_customer_complaint acc on acc.pno = pci.merge_column and acc.channel_type = 16
left join bi_pro.parcel_lose_task plt on acc.abnormal_message_id = substring(plt.source_id, 16)
left join bi_pro.abnormal_message am on am.id = substring(plt.source_id, 16)
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = acc.abnormal_message_id
-- 询问任务直接生成处罚
left join bi_pro.abnormal_message am2 on json_extract(am2.extra_info, '$.source_id') = pci.id and json_extract(am2.extra_info, '$.src') = 'parcel_complaint_inquiry'
left join bi_pro.abnormal_qaqc aq2 on aq2.abnormal_message_id = am2.id
-- 第二次进入生成客户投诉处罚
left join bi_pro.abnormal_message am3 on json_extract(am3.extra_info, '$.source_id') = pcip.id and json_extract(am3.extra_info, '$.src') = 'parcel_complaint_inquiry_punish'
left join bi_pro.abnormal_qaqc aq3 on aq3.abnormal_message_id = am3.id

left join fle_staging.parcel_info pi on pi.pno = pci.merge_column
left join fle_staging.parcel_additional_info pai on pai.pno = if(pi.returned = 1, pi.customary_pno, pi.pno )

left join
    (
        select
            pct.pno
            ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
            ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) rn
        from bi_pro.parcel_claim_task pct
        left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.state = 6
            and pct.created_at > '2023-12-25'
    ) pct on pct.pno = pci.merge_column and pct.rn = 1
where
    pci.created_at >= '2023-12-29'
    and pci.created_at < '2024-02-21'
;

select
    di.pno
    ,di.created_at
    ,di.diff_marker_category
    ,cdt.organization_type
    ,cdt.organization_id
    ,cdt.vip_enable
    ,cdt.service_type
from fle_staging.diff_info di
left join fle_staging.parcel_info pi on pi.pno = di.pno
left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join fle_staging.store_diff_ticket sdt on sdt.diff_info_id = di.id
where
    pi.client_id = 'CJ2579'
    and sdt.state = 0


;

select
    t.pno
    ,if(am.pno is not null, 'Y', 'N') 是否生成丢失处罚
from tmpale.tmp_th_pno_lj_0321_v2 t
left join bi_center.parcel_complaint_inquiry pci on pci.merge_column = t.pno
left join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.source_id') = pci.id and json_extract(am.extra_info, '$.src') = 'parcel_complaint_inquiry' and am.punish_category = 7
group by 1,2


;

-- 询问任务明细

select
    pci.merge_column
    ,pci.client_id 客户ID
    ,case  pci.client_type
        when 1 then 'lazada'
        when 2 then 'shopee'
        when 3 then 'tiktok'
        when 4 then 'shein'
        when 5 then 'otherKAM'
        when 6 then 'otherKA'
        when 7 then '小C'
    end 客户类型
    ,case pci.source
        when 1 then '问题记录本'
        when 2 then '疑似违规回访'
        when 3 then 'APP'
        when 4 then '官网'
        when 5 then '短信'
        when 6 then 'FBI'
        when 7 then 'WhatsApp'
    end 任务渠道
    ,pci.complaints_at 用户反馈时间
    ,pci.created_at 询问任务生成时间
    ,pci.apology_at 询问任务完成时间
    ,pci.staff_info_id 询问任务员工
    ,dt.store_name  询问任务网点
    ,dt.piece_name 询问任务所属片区
    ,dt.region_name 询问任务所属大区
    ,case pci.apology_type
        when 0 then '进行中'
        when 1 then '已超时关闭'
        when 2 then '道歉后自动关闭'
        when 3 then '无需处理自动关闭'
    end 询问任务处理状态
    ,pci.qaqc_created_at 回访任务生成时间
    ,case pci.qaqc_is_receive_parcel
        when 0 then '未处理'
        when 1 then '联系不上'
        when 2 then '已收到包裹'
        when 3 then '未收到包裹'
        when 4 then '未收到包裹,已有约定派送时间'
    end 回访结果
    ,pci.staff_info_id 责任人
    ,hjt2.job_name 责任人职务
    ,hsi2.leave_date 责任人离职时间
    ,pci.apology_staff_info_id 实际处理人工号
    ,hjt.job_name 实际处理人职务
    ,dt.store_name 回访任务网点
    ,pci.cod_amount/100 cod
    ,pci.cogs_amount/100 cogs
    ,pci.qaqc_callback_remark 回访备注
from bi_center.parcel_complaint_inquiry pci
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pci.store_id and dt.stat_date = date_sub(curdate(), 1)
left  join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pci.apology_staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join fle_staging.parcel_info pi on pi.pno = pci.merge_column
left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = pci.staff_info_id
left join bi_pro.hr_job_title hjt2 on hjt2.id = hsi2.job_title
where
    pci.created_at > '2024-06-01'
    and pci.created_at < '2024-07-01'
    and pci.client_id in ('AA0636','CP5939','AA0546','AA0622','BG2332','BA5494','BA0823','BG2398','AA0745','BG1193','BF7905','AA0853','BG1992','BF5633','AA0649','AA0641','BG0906','BG1147','BG1948','BG0043','AA0617','BG2436','AA0413','BG2403','AA0650','BG2421','BG0702','AA0473','AA0632','BG2383','BG2435','BG0452','BG2318','BA0274','BG1865','CAW2782','BF9951','BA0358','BG2085','CB4693','CC3651','AA0655','BG2064','BG2382','BG1916','BG1904','BG2030','CBB8482','BG2224','BG2422','BG0947','CBB5384','AA0772','BF6905','CN2660','BG1852','BG2334','BG2209','BG2025','BG2289','AA0439','BG2043','AA0634','BG0660','CT5332','CV6258','BG0735','CBB5020','BA0309','CAP0883','CBC4582','BG2219','CBA9147','BF7121','CBB6965','BG2369','BF4657','BG2361','BG2428','BA4508','AA0635','BG0707','CY3109','AA0662','BG1612','BA8070','BG2359','BG2252','BF8350','AA0621','BG0528','BA0004','CD6543','BG2396','BG2393','AA0341','BG2342','BG1678','CR3437','CA0681','AA0265','BG1976','CAW9566','BG1826','BF9799','CAW1107','BG1701','AA0579','CAW9530','CAW9531','CZ0657','BG0636','CAQ8460','BG1673','BF9740','BF9669','BC1012','CD5370','AA0581','BG1697','BG1218','AA0698','BG1658','CF9990','BF9680','AA0623','BG1594','BG0213','BG1266','CA8653','BG1747','AA0423','BF3476','CS7278','BG1698','BG1994','BG0099','CAN2560','BG1647','CT9381','BA1006','AA0647','AA0463','AA0588','AA0580','BF9798','BF9787','BF9668','BG1907','BG0070','CAE9792','AA0675','CAU0143','BG1840','AA0638','AA0624','AA0424','BD8916','CR7338','BF9967','AA0488','AA0305','CU1963','BF4661','CJ9404','AA0418','AA0472','AA0545','BF1296','BF6125','BF9690','BF9701','BG1622','BG1635','BG1217','AA0408','BF9709','AA0411','AA0566','CX3663','BB2054','BF9860','AA0435','CX3929','CM9964','CS7272','AA0298','AA0565','AA0437','BF7019','BF9181','AA0342','AA0270','BG1810','CAQ9122','BF9692','BE4738','AA0275','BF9790','CAA0023','AA0656','AA0654','BF9691','BG1595','CR3487','BG1808','CAX9113','CAZ4104','BG2271','BG2281','BG2337','BG2395','CBB6791','CBC4022','CBC2320','BG2420')
