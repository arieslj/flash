select
    t.pno
    ,if(oi.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,oi.cod_amount/100 cod
from tmpale.tmp_ph_pno_1211 t
join ph_staging.parcel_info pi on pi.pno = t.pno
left join  ph_staging.order_info oi on oi.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)

;


SELECT
    wo.`order_no` `工单编号`,
case wo.status
     when 1 then '未阅读'
     when 2 then '已经阅读'
     when 3 then '已回复'
     when 4 then '已关闭'
     end '工单状态',
pi.`client_id`  '客户ID',
wo.`pnos` '运单号',
case wo.order_type
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
          end  '工单类型',
wo.`title` `工单标题`,
wo.`created_at` `工单创建时长`,
wor.`工单回复时间` `工单回复时间`,
wo.`created_staff_info_id` `发起人`,
wo.`closed_at` `工单关闭时间`,
wor.staff_info_id `回复人`,
ss1.name `创建网点名称`,
case
when ss1.`category` in (1,2,10,13) then 'sp'
              when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`created_store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`created_store_id`= '12' then 'QA&QC'
              when wo.`created_store_id`= '18' then 'Flash Home客服中心'
              when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`created_store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `创建网点/部门 `,
ss.name `受理网点名称`,
case when ss.`category` in (1,2,10,13) then 'sp'
              when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`store_id`= '12' then 'QA&QC'
              when wo.`store_id`= '18' then 'Flash Home客服中心'
              when wo.`store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `受理网点/部门 `,
pi. `last_cn_route_action` `最后一步有效路由`,
pi.last_route_time `操作时间`,
pi.last_store_name `操作网点`,
pi.last_staff_info_id `操作人员`

from `ph_bi`.`work_order` wo
left join dwm.dwd_ex_ph_parcel_details pi on wo.`pnos` =pi.`pno` and  pick_date>=date_sub(curdate(),interval 2 month)
left join
    (select order_id,staff_info_id ,max(created_at) `工单回复时间`
     from `ph_bi`.`work_order_reply`
     group by 1,2) wor
on  wor.`order_id`=wo.`id`

left join   `ph_bi`.`sys_store`  ss on ss.`id` =wo.`store_id`
left join   `ph_bi`.`sys_store`  ss1 on ss1.`id` =wo.`created_store_id`
where wo.`created_at` >= date_sub(curdate() , interval 31 day)




;



with t as
    (
        select
            wo.order_no
            ,wo.id
            ,wo.closed_at
        from ph_bi.work_order wo
        join tmpale.tmp_ph_work_order_lj_0708 t on t.order_no = wo.order_no
    )
select
    *
from t t1
left join
    (
        select
            wor.order_id
            ,wor.created_at
            ,row_number() over (partition by wor.order_id order by wor.created_at) rk
        from ph_bi.work_order_reply wor
        join t t1 on t1.id = wor.order_id
        where
            wor.created_at > '2024-01-01'
    ) wor on wor.order_id = t1.id and wor.rk = 1

;


select count(1) from tmpale.tmp_ph_work_order_lj_0708
;




select
    pno ,arrive_dst_route_at
from ph_bi.parcel_sub ps
where   pno in (
select   DISTINCT( `merge_column`) as merge_column  from  ph_bi.`abnormal_message` WHERE  `punish_category` =  85 AND  `abnormal_time`  = '2024-06-05'
)
  and ps.arrive_dst_route_at  >= '2024-06-01 00:00:00'
# group by 1,2