select
    a.pno '运单号/任务号'
#     ,case a.ticket_type
#         when 1 then '揽件'
#         when 2 then '派件'
#     end 揽派件类型
    ,case
        when a.merge_column is null then '其他'
        when a.merge_column is not null and a.relative_type = 1 then '派件'
        when a.merge_column is not null and a.relative_type = 2 then '揽件'
    end 揽派件类型
    ,a.abnormal_time 投诉日期
    ,a.client_id 客户ID
    ,if(a.归属部门 = 'Retail-sales', a.staff_info_id, ss.name) '客户所属网点-工号'
    ,a.归属部门
    ,smr.name 客户所属大区
    ,ss2.name 被投诉网点
    ,case
        when a.`channel_type` =1 then 'APP揽件任务'
        when a.`channel_type` =2 then 'APP派件任务'
        when a.`channel_type` =3 then 'APP投诉'
        when a.`channel_type` =4 then '短信揽件投诉'
        when a.`channel_type` =5 then '短信派件投诉'
        when a.`channel_type` =6 then '短信妥投投诉'
        when a.`channel_type` =7 then 'MS问题记录本'
        when a.`channel_type` =8 then '新增处罚记录'
        when a.`channel_type` =9 then 'KA投诉'
        when a.`channel_type` =10 then '官网投诉'
        when a.`channel_type` =12 then 'BS问题记录本'
    end as '投诉渠道'
    ,case a.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
    end as 投诉大类
    ,case a.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4   then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6   then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8   then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10   then '未提前电话联系客户'
        when 11   then '包裹破损 没有数据'
        when 12   then '未按照改约时间派件'
        when 13    then '未按订单带包装'
        when 14   then '不找零钱'
        when 15    then '客户通话记录内未看到员工电话'
        when 16    then '未经客户允许取消揽件任务'
        when 17   then '未给客户回执'
        when 18   then '拨打电话时间太短，客户来不及接电话'
        when 19   then '未经客户允许退件'
        when 20    then '没有上门'
        when 21    then '其他'
        when 22   then '未经客户同意改约揽件时间'
        when 23    then '改约的揽件时间和客户要求的时间不一致'
        when 24    then '没有按照改约时间揽件'
        when 25    then '揽件前未提前联系客户'
        when 26    then '答应客户揽件，但最终没有揽'
        when 27    then '很晚才打电话联系客户'
        when 28    then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29    then '因为超过当日截单时间，要求客户取消'
        when 30    then '声称不是自己负责的区域，要求客户取消'
        when 31    then '拨打电话时间太短，客户来不及接电话'
        when 32    then '不接听客户回复的电话'
        when 33    then '答应客户今天上门，但最终没有揽收'
        when 34    then '没有上门揽件，也没有打电话联系客户'
        when 35    then '货物不属于超大件/违禁品'
        when 36    then '没有收到包裹，且快递员没有联系客户'
        when 37    then '快递员拒绝上门派送'
        when 38    then '快递员擅自将包裹放在门口或他处'
        when 39    then '快递员没有按约定的时间派送'
        when 40    then '代替客户签收包裹'
        when   41   then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42    then '说话不礼貌/没有礼貌/不愿意服务'
        when   43    then '快递员抛包裹'
        when   44    then '报复/骚扰客户'
        when 45   then '快递员收错COD金额'
        when   46   then '虚假妥投'
        when   47    then '派件虚假留仓件/问题件'
        when 48   then '虚假揽件改约时间/取消揽件任务'
        when   49   then '抛客户包裹'
        when 50    then '录入客户信息不正确'
        when 51    then '送货前未电话联系'
        when 52    then '未在约定时间上门'
        when   53    then '上门前不电话联系'
        when   54    then '以不礼貌的态度对待客户'
        when   55    then '录入客户信息不正确'
        when   56    then '与客户发生肢体接触'
        when   57    then '辱骂客户'
        when   58    then '威胁客户'
        when   59    then '上门揽件慢'
        when   60    then '快递员拒绝上门揽件'
        when 61    then '未经客户同意标记收件人拒收'
        when 62    then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as 投诉原因
    ,case
        when a.isdel = 1 then '已删除'
        when a.state = 1 then '责任已认定'
        when a.state = 2 then '未处理'
        when a.state = 3 then '无需追责'
        when a.state = 5 then '重复投诉'
    end 状态

from
    (
        select
            acc.pno
            ,acc.ticket_type
            ,am.relative_type
            ,am.merge_column
            ,acc.abnormal_time
            ,acc.client_id
            ,kp.staff_info_id
            ,kp.store_id
            ,acc.store_id duty_store_id
            ,acc.channel_type
            ,acc.complaints_type
            ,acc.complaints_sub_type
            ,acc.state
            ,am.isdel
            ,case
                when kp.`agent_category`= '3'  AND kp.department_id= '388' THEN 'PMD-KAM'
                when ss.`category` in ('1') THEN 'Network'
                when ss.`category` in ('10','13') THEN 'Network Bulky'
                when ss.`category` in ('4','5','7') THEN 'Shop'
                when ss.`category` in ('6') THEN 'FH'
                when ss.`category` in ('11') THEN 'FFM'
                else 'Other'
           end 归属部门
        from bi_pro.abnormal_customer_complaint acc
        left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id
        left join  fle_staging.parcel_info pi on pi.pno = acc.pno
        left join `fle_staging`.`sys_store` ss on ss.`id` =pi.`ticket_pickup_store_id`
        left join fle_staging.ka_profile kp on pi.`agent_id`  =kp.`id`
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.`client_id` =pi.`client_id`
        where
            acc.abnormal_time >= '${date1}'
            and acc.abnormal_time <= '${date2}'
            -- and bc.client_id is null

        union all

        select
            acc.pno
            ,acc.ticket_type
            ,am.relative_type
            ,am.merge_column
            ,acc.abnormal_time
            ,acc.client_id
            ,kp.staff_info_id
            ,kp.store_id
            ,acc.store_id duty_store_id
            ,acc.channel_type
            ,acc.complaints_type
            ,acc.complaints_sub_type
            ,acc.state
            ,am.isdel
            ,CASE
                WHEN bc.client_name = 'lazada' then  'PMD-lazada'
                WHEN bc.client_name = 'shopee' then  'PMD-shopee'
                WHEN bc.client_name = 'tiktok' then  'PMD-tiktok'
                WHEN bc.client_name ='AA0622' THEN 'PMD-shein'
                WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '20001' THEN 'FFM'
                WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '4' THEN 'Network'
                WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '34' THEN 'Network Bulky'
                WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '40' THEN 'Sales'
                WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' and if(kp.`account_type_category` = '3',hs2.`node_department_id`, hs.`node_department_id`) IN ('1098','1099','1100','1101','1268') THEN 'Retail-sales'
                WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' THEN 'Shop'
                WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' AND if(kp.`account_type_category` = '3',kp.`agent_id`, kp.`id`) = 'BF5633' THEN 'PMD-CFM'
                WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' THEN 'PMD-KAM'
                WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '3' THEN 'Customer Service'
                WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '545' THEN 'Bulky Business Development'
                else 'Other'
            END AS 归属部门
        from bi_pro.abnormal_customer_complaint acc
        left join bi_pro.abnormal_message am on am.id = acc.abnormal_message_id
        left join fle_staging.ka_profile kp on kp.id = acc.client_id
        left join fle_staging.ka_profile kp2 on kp2.`id` =kp.`agent_id`
        left join bi_pro.hr_staff_info hs on kp.`staff_info_id` = hs.`staff_info_id`
        left join bi_pro.hr_staff_info hs2 on kp2.`staff_info_id` = hs2.`staff_info_id`
        left join `fle_staging`.`sys_store` ss on ss.`id` =kp.store_id
        left join `fle_staging`.`sys_store` ss2 on ss2.`id` =kp2.store_id
        left join dwm.tmp_ex_big_clients_id_detail bc on bc.`client_id` =kp.id
        where
            acc.abnormal_time >= '${date1}'
            and acc.abnormal_time <= '${date2}'
            -- and bc.client_id is null
    ) a
left join fle_staging.sys_store ss on ss.id = a.store_id
left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
left join fle_staging.sys_store ss2 on ss2.id = a.duty_store_id
where
    a.归属部门 in ('Shop','Network','Retail-sales','Network Bulky')