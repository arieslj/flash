with t as
(
    select
        convert_tz(di.created_at, '+00:00', '+07:00') 疑难件提交时间
        ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收完成时间
        ,if(cdt.first_operated_at is not null, concat(timestampdiff(day ,convert_tz(di.created_at, '+00:00', '+08:00') ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00')), 'd', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00') ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00'))%24, 'h',timestampdiff(minute ,convert_tz(di.created_at, '+00:00', '+08:00') ,convert_tz(cdt.first_operated_at, '+00:00', '+08:00'))%60, 'm' ), null ) '从提交到第一次处理时长'
        ,if(cdt.first_operated_at is null, concat(timestampdiff(day ,convert_tz(di.created_at, '+00:00', '+08:00') ,now()), 'd', timestampdiff(hour ,convert_tz(di.created_at, '+00:00', '+08:00') ,now())%24, 'h',timestampdiff(minute ,convert_tz(di.created_at, '+00:00', '+08:00') ,now())%60, 'm' ), null ) 至今未处理时长
        ,concat('(', di.staff_info_id, ')', hsi.name) 提交人
        ,cdt.client_id 客户ID
        ,case
          when kp.id ='AA0622' then 'pmd-shein'
          when if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '20001' then 'ffm'
          when if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' and if(kp.`account_type_category` = '3',kp.`agent_id`, kp.`id`) = 'BF5633' then 'kam'
          when if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' then 'kam'
          when if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '4' then 'retail-network'
          when if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '34' then 'retail-bulky'
          when if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '40' then 'retail-sales'
          when if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' and hs.`node_department_id` in ('1098','1099','1100','1101') then 'retail-sales'
          when if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' then 'retail-shop'
          when if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '3' then 'customer service'
          when if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '545' then 'bulky business development'
          when kp3.`agent_category`= '3'  and kp3.department_id= '388' and kp.id is null then 'kam'
          when ss.`category` = '1' and kp.id is null then 'retail-network-c'
          when ss.`category` in ('10','13') and kp.id is null then 'retail-bul  ky-c'
          when ss.`category` = '6'  and kp.id is null then 'fh'
          when ss.`category` in ('4','5','7') and kp.id is null then 'retail-shop-c'
          when ss.`category` in ('11') and kp.id is null then 'ffm'
          else ss2.name
        end as '归属部门'
        ,di.order_info_id  订单号
        ,oi.remark 订单备注
        ,di.pno 运单号
        ,ddd.CN_element 疑难原因
        ,ddd2.CN_element 二级类型
        ,concat('(', ss.id, ')', ss.name) 提交疑难件网点
        ,case pi.insured
            when 1 then '保价'
            when 0 then '不保价'
        end 保价情况
        ,convert_tz(cdt.first_operated_at, '+00:00', '+07:00') 首次处理时间
        ,concat('(', cdt.first_operator_id, ')', hsi2.name) 首次处理人
        ,convert_tz(cdt.first_operated_at, '+00:00', '+07:00') 最后处理时间
        ,concat('(', cdt.operator_id, ')', hsi4.name) 最后处理人
        ,case cdt.state
            when 0 then '未处理'
            when 1 then '已处理'
            when 2 then '沟通中'
            when 3 then '支付驳回'
            when 4 then '客户未处理'
            when 5 then '转交闪速系统'
            when 6 then '转交QAQC'
        end 处理状态
        ,ddd3.CN_element 协商结果
        ,case sdt.pending_handle_category
            when 1 then '待揽收网点协商'
            when 2 then '待KAM问题件处理'
            when 3 then '待QAQC判责'
            when 4 then '待客户决定'
        end 待处理人
        ,if(cdt.organization_type = 1, ss3.name, sd.name) '处理问题件网点/部门'
        ,case fdt.state
            when 0 then '未支付'
            when 1 then '已支付'
            when 2 then '驳回'
            when 3 then '取消'
            when 4 then '支付中'
            when 5 then '无需支付'
        end 财务支付状态
        ,cdt.remark 备注
    from fle_staging.customer_diff_ticket cdt
    left join fle_staging.store_diff_ticket sdt on sdt.diff_info_id = cdt.diff_info_id
    join fle_staging.diff_info di on di.id = cdt.diff_info_id
    left join fle_staging.parcel_info pi on pi.pno = di.pno
    left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = di.staff_info_id
    left join fle_staging.order_info oi on oi.pno = di.pno
    left join dwm.dwd_dim_dict ddd on ddd.element = di.diff_marker_category and ddd.db = 'fle_staging' and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category'
    left join dwm.dwd_dim_dict ddd2 on ddd2.element = di.rejection_category and ddd2.db = 'fle_staging' and ddd2.tablename = 'diff_info' and ddd2.fieldname = 'rejection_category'
    left join dwm.dwd_dim_dict ddd3 on ddd3.element = cdt.negotiation_result_category and ddd3.db = 'fle_staging' and ddd3.tablename = 'customer_diff_ticket' and ddd3.fieldname = 'negotiation_result_category'
    left join fle_staging.sys_store ss on ss.id = di.store_id
    left join bi_pro.hr_staff_info hsi2 on hsi2.staff_info_id = cdt.first_operator_id
    left join bi_pro.hr_staff_info hsi4 on hsi4.staff_info_id = cdt.operator_id
    left join fle_staging.finance_diff_ticket fdt on fdt.diff_info_id = cdt.diff_info_id
    left join fle_staging.ka_profile  AS kp on kp.id = pi.client_id
    left join fle_staging.ka_profile as kp2 on  kp.`agent_id` = kp2.`id` and (kp2.`agent_category` <>'3' or kp2.`agent_category` is null)
    left join fle_staging.ka_profile kp3 on pi.`agent_id`  = kp3.`id`
    left join bi_pro.hr_staff_info AS hs on kp.`staff_info_id` = hs.`staff_info_id` AND hs.`node_department_id` IN ('1098','1099','1100','1101')
    left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
    left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = pi.client_id
    left join fle_staging.customer_group cg on cg.id = cgkr.customer_group_id
    left join fle_staging.sys_store ss2 on ss2.id = pi.ticket_pickup_store_id
    left join fle_staging.sys_department sd on sd.id = cdt.organization_id
    left join fle_staging.sys_store ss3 on ss3.id = cdt.organization_id
    where
        cdt.created_at >= '2023-04-30 17:00:00'
        and cdt.created_at < '2023-06-26 17:00:00'
        and di.diff_marker_category not in (2,17)
)
select
    t1.*
    ,am.punish_num 罚款次数
    ,am.punish_money_total 罚款总金额
from t t1
left join
    (
        select
            am.pno
            ,sum(am.punish_money) punish_money_total
            ,count(distinct if(am.abnormal_object = 0, am.id, am.average_merge_key)) punish_num
        from bi_pro.abnormal_message am
        join
            (
                select
                    t1.运单号 pno
                from t t1
                group by 1
            ) t1 on am.merge_column = t1.pno
        where
            am.punish_category = 4
            and am.isdel = 0
            and am.state = 1
        group by 1
    ) am on am.pno = t1.运单号
# where
#     am.pno = 'TH10033V0N1E3Q'

;



# select
#     count(cdt.id)
# from fle_staging.customer_diff_ticket cdt
# left join fle_staging.diff_info di on di.id = cdt.diff_info_id
# where
#         cdt.created_at >= '2023-04-30 17:00:00'
#         and cdt.created_at < '2023-06-26 17:00:00'
#         and di.diff_marker_category not in (2,17)