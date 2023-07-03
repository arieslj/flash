
  SELECT
     concat('`',wo.order_no)  工单编号
	 ,case wo.status when 1 then '未阅读' when 2 then '已经阅读' when 3 then '已回复' when 4 then '已关闭' end 状态
     ,wo.`client_id` 客户ID
	 ,wo.`pnos`  运单号
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
      else wo.order_type end  工单类型
     ,wo.title 工单标题
     ,wo.created_at 创建时间
     ,wor.`created_at` 第一次工单回复时间
     ,wo.`closed_at`  工单关闭时间
     ,wo.`created_staff_info_id`  发起人ID
     ,hi.`name`  发起人姓名
     ,wo.created_store_id 发起人网点ID
     ,ss.`short_name`  发起人所属部门网点code
     ,ss.`name`  发起人所属部门名称
       ,wor.`staff_info_id`  第一次回复人ID
     ,hi1.`name`  第一次回复人姓名
     ,case when ss1.`category` in (1,2,10,13) then 'sp'
          when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
          when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
          when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
          when wo.`store_id`in (3,'customer_manger') then  '总部客服中心'
          when wo.`store_id`= '12' then 'QA&QC'
          when wo.`store_id`= '18' then 'Flash Home客服中心'
          when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
          else '其他网点'
      end 受理部门

     ,case
          when wo.`original_acceptance_info` is null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<24  then '是'
          when wo.`original_acceptance_info` is not null and wor.created_at is not null and  TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )<72  then '是'
          else '否'
      end  是否在24小时内回复
     ,if(wor.created_at is not null and wo.`original_acceptance_info` is not null  and TIMESTAMPDIFF(HOUR, wo.`created_at`,wor.`created_at` )>48,'是','否') 是否为FH48小时超时工单
     ,TIMESTAMPDIFF(MINUTE, wo.`created_at`,wor.`created_at`) 第一次回复时长
     ,if(wt.`created_at` is not null and nwt.`created_at` is null,'是','否') 是否为工作时间创建工单
     ,case
          when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<40 then '是'
           when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(MINUTE, wt.`created_at`,wor.`created_at`)<2920 then '是'
      else '否'
       end 工作时间内创建的工单是否在40分钟内回复
     ,case
          when wo.`original_acceptance_info` is null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<24 then '是'
          when wo.`original_acceptance_info` is not null and wor.created_at is not null and TIMESTAMPDIFF(HOUR, nwt.`created_at`,wor.`created_at` )<72 then '是'
          else '否'
    end 非工作时间是否在24小时内回复
     ,case
          when nwt.`tg` in (1,3) and wor.`created_at` < concat(date_add(nwt.`created_at`, interval 1 day) , ' 10:00') then '是'
          when nwt.`tg` in (2,4) and wor.`created_at` < concat(date(nwt.`created_at`), ' 10:00') then '是'
          ELSE '否'
      end as '工作时间外创建的工单是否在次日10:00前回复'
FROM `bi_pro`.work_order wo
LEFT JOIN ( #第一次回复
   select * from (SELECT wor.`created_at`
         				,wor.`order_id`
    					,wor.`staff_info_id`
    					,ROW_NUMBER() over(PARTITION by wor.`order_id` order by wor.`created_at`) rn
   						 FROM `bi_pro`.work_order_reply wor
   				 )wor
           where wor.rn=1
			)wor on wo.id = wor.`order_id`
LEFT JOIN `bi_pro`.`hr_staff_info` hi on hi.`staff_info_id` = wo.`created_staff_info_id`
LEFT JOIN `bi_pro`.`sys_store` ss on ss.`id` = wo.`created_store_id`
LEFT JOIN `bi_pro`.`hr_staff_info` hi1 on hi1.`staff_info_id` =wor.`staff_info_id`
LEFT JOIN `bi_pro`.`sys_store` ss1 on ss1.`id` = wo.`store_id`
LEFT JOIN (   #工作时间
    SELECT  wo.`id`
           ,wo.`created_at`
           ,date_format(wo.`created_at`,'%w') as weekNum
     FROM `bi_pro`.work_order wo
    where date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%H%i') between 11000 and 11900 or (date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i') between 11000 and 11700)
          ) wt on wt.id = wo.id
LEFT JOIN ( #非工作时间
    SELECT  wo.`id`
           ,wo.`created_at`
           ,date_format(wo.`created_at`,'%w') as weekNum
    ,case
    when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%H%i')>11900 and date_format(wo.`created_at`,'1%H%i') <10000 then '1'
    when  date_format(wo.`created_at`,'%w')  between 1 and 5 and date_format(wo.`created_at`,'1%H%i')>=10000 and date_format(wo.`created_at`,'1%H%i') <11000 then '2'
    when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i')>11700 and date_format(wo.`created_at`,'1%H%i') <10000 then '3'
    when  date_format(wo.`created_at`,'%w') in (0,6) and date_format(wo.`created_at`,'1%H%i')>=10000 and date_format(wo.`created_at`,'1%H%i') <11000 then '4'
    end as 'tg'
     FROM `bi_pro`.work_order wo
    where date_format(wo.`created_at`,'%w')  between 1 and 5 and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11900) or (date_format(wo.`created_at`,'%w') in (0,6) and (date_format(wo.`created_at`,'1%H%i') <11000 or date_format(wo.`created_at`,'1%H%i')>11700))
          ) nwt on nwt.id = wo.id
WHERE wo.created_at >= date_sub(curdate(),interval 30 day)
AND wo.created_at < curdate()
-- and wo.status < 4
-- and wo.`created_store_id` !=1 -- 自动创建的工单
and hi1.`node_department_id` =86
and hi1.`state` =1
order by 7