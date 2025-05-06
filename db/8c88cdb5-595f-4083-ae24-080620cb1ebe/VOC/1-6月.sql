
select
    month(convert_tz(cdt.created_at, '+00:00', '+07:00')) as 月份
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,ddd.CN_element as 问题件类型
    ,count(distinct cdt.id) as 任务量
    ,sum(if(cdt.state = 1, timestampdiff(hour, cdt.created_at, cdt.updated_at), 0))  / count(distinct if(cdt.state = 1, cdt.id, null)) 平均任务关闭时长
    ,sum(if(cdt.first_operated_at is not null, timestampdiff(hour, cdt.created_at, cdt.first_operated_at), 0)) / count(distinct if(cdt.first_operated_at is not null, cdt.id, null)) 平均响应时长
from fle_staging.customer_diff_ticket cdt
left join fle_staging.diff_info di on cdt.diff_info_id = di.id
left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
left join dwm.tmp_ex_big_clients_id_detail bc on cdt.client_id = bc.client_id
left join fle_staging.ka_profile kp on kp.id = cdt.client_id
where
    cdt.created_at > '2023-12-31 17:00:00'
    and cdt.created_at < '2024-06-30 17:00:00'
    and cdt.organization_type = 2
    and cdt.vip_enable = 1
    and di.diff_marker_category not in (22, 32, 28, 17, 23, 25, 29, 39, 26) -- 货物丢失/禁运品/已妥投未回cod
    and cdt.operator_id not in (10000,10001)
    and cdt.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0601','AA0752','AA0792','AA0660','AA0661','AA0703','AA0823','AA0824','AA0386','AA0427','AA0569','AA0574','AA0612','AA0606','AA0657','AA0707','AA0731','AA0794','AA0838')
group by 1,2,3
order by 1,2,3


;




with t as
    (
        select
            wo.order_no
            ,wo.id
            ,wo.client_id
            ,wo.created_at
            ,wo.order_type
        from bi_pro.work_order wo
        where
            wo.store_id in ('22', 'vip_ka_handler')  -- 受理网点KAM
            and wo.client_id in ('AA0330','AA0415','AA0428','AA0442','AA0461','AA0477','AA0601','AA0752','AA0792','AA0660','AA0661','AA0703','AA0823','AA0824','AA0386','AA0427','AA0569','AA0574','AA0612','AA0606','AA0657','AA0707','AA0731','AA0771','AA0794','AA0838')
            and wo.created_at >= '2024-01-01'
            and wo.created_at < '2024-07-01'
    )
select
    month(t1.created_at) as 月份
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,case t1.order_type
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
      else t1.order_type end  工单类型
    ,count(distinct t1.order_no) as 工单量
    ,sum(if(wor.created_at is not null, timestampdiff(hour, t1.created_at, wor.created_at), 0)) / count(distinct if(wor.created_at is not null, t1.order_no, null)) 平均回复时长
from t t1
left join dwm.tmp_ex_big_clients_id_detail bc on t1.client_id = bc.client_id
left join fle_staging.ka_profile kp on kp.id = t1.client_id
left join
    (
        select
            t1.id
            ,wor.created_at
            ,row_number() over (partition by wor.order_id order by wor.created_at ) rk
        from bi_pro.work_order_reply wor
        join t t1 on t1.id = wor.order_id
        where
            wor.created_at >= '2024-01-01'
            and wor.staff_info_id not in (10000, 10001)
    ) wor on t1.id = wor.id and wor.rk = 1
group by 1,2,3
order by 1,2,3