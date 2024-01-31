select
        ci.pno
        ,ci.id
        ,acc.client_id
        ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,acc.abnormal_time 投诉时间
    ,case
            when acc.`channel_type` =1 then 'APP揽件任务'
            when acc.`channel_type` =2 then 'APP派件任务'
            when acc.`channel_type` =3 then 'APP投诉'
            when acc.`channel_type` =4 then '短信揽件投诉'
            when acc.`channel_type` =5 then '短信派件投诉'
            when acc.`channel_type` =6 then '短信妥投投诉'
            when acc.`channel_type` =7 then 'MS问题记录本'
            when acc.`channel_type` =8 then '新增处罚记录'
            when acc.`channel_type` =9 then 'KA投诉'
            when acc.`channel_type` =10 then '官网投诉'
            when acc.`channel_type` =12 then 'BS问题记录本'
         end as '投诉渠道'
         ,case
            when acc.`complaints_type` =1 then '虚假妥投'
            when acc.`complaints_type` =2 then '虚假揽收改约时间/取消揽件任务'
            when acc.`complaints_type` =3 then '派件虚假留仓件/问题件'
            when acc.`complaints_type` =4 then '普通客诉'
            when acc.`complaints_type` =5 then '其他'
            when acc.`complaints_type` =6 then '服务态度类投诉'
            when acc.`complaints_type` =7 then '操作规范类投诉'
        end as '投诉大类'
        ,case acc.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4 then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6 then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8 then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10 then '未提前电话联系客户'
        when 11 then '包裹破损 没有数据'
        when 12 then '未按照改约时间派件'
        when 13 then '未按订单带包装'
        when 14 then '不找零钱'
        when 15 then '客户通话记录内未看到员工电话'
        when 16 then '未经客户允许取消揽件任务'
        when 17 then '未给客户回执'
        when 18 then '拨打电话时间太短，客户来不及接电话'
        when 19 then '未经客户允许退件'
        when 20 then '没有上门'
        when 21 then '其他'
        when 22 then '未经客户同意改约揽件时间'
        when 23 then '改约的揽件时间和客户要求的时间不一致'
        when 24 then '没有按照改约时间揽件'
        when 25 then '揽件前未提前联系客户'
        when 26 then '答应客户揽件，但最终没有揽'
        when 27 then '很晚才打电话联系客户'
        when 28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29 then '因为超过当日截单时间，要求客户取消'
        when 30 then '声称不是自己负责的区域，要求客户取消'
        when 31 then '拨打电话时间太短，客户来不及接电话'
        when 32 then '不接听客户回复的电话'
        when 33 then '答应客户今天上门，但最终没有揽收'
        when 34 then '没有上门揽件，也没有打电话联系客户'
        when 35 then '货物不属于超大件/违禁品'
        when 36 then '没有收到包裹，且快递员没有联系客户'
        when 37 then '快递员拒绝上门派送'
        when 38 then '快递员擅自将包裹放在门口或他处'
        when 39 then '快递员没有按约定的时间派送'
        when 40 then '代替客户签收包裹'
        when 41 then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42 then '说话不礼貌/没有礼貌/不愿意服务'
        when 43 then '快递员抛包裹'
        when 44 then '报复/骚扰客户'
        when 45 then '快递员收错COD金额'
        when 46 then '虚假妥投'
        when 47 then '派件虚假留仓件/问题件'
        when 48 then '虚假揽件改约时间/取消揽件任务'
        when 49 then '抛客户包裹'
        when 50 then '录入客户信息不正确'
        when 51 then '送货前未电话联系'
        when 52 then '未在约定时间上门'
        when 53 then '上门前不电话联系'
        when 54 then '以不礼貌的态度对待客户'
        when 55 then '录入客户信息不正确'
        when 56 then '与客户发生肢体接触'
        when 57 then '辱骂客户'
        when 58 then '威胁客户'
        when 59 then '上门揽件慢'
        when 60 then '快递员拒绝上门揽件'
        when 61 then '未经客户同意标记收件人拒收'
        when 62 then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '投诉原因'
        ,case acca.qaqc_callback_result
                when 1 then '误投诉'
                when 2 then '真实投诉，对快递员/网点人员不满意'
                when 3 then '真实投诉，对Flash公司服务不满意'
                when 4 then '未联系上'
        end '回访是否真实'
        ,acca.qaqc_callback_num 回访次数
        ,timestampdiff(hour,acca.created_at,acca.qaqc_callback_at) '回访是否真实结果➖投诉进入的时间'
        ,if(am.merge_column is not null,'是','否') 是否生成处罚
        ,acc.store_callback_at 道歉的时间
        ,acc.apology_staff_info_id 道歉人
        ,hjt.job_name 道歉人职位
        ,acc.qaqc_callback_num 是否道歉回访次数
        ,acc.qaqc_callback_at 回访时间
        ,case acc.qaqc_callback_result
                when 0 then '待回访'
                when 1 then '多次未联系上客户'
                when 2 then '误投诉'
                when 3 then '真实投诉，后接受道歉'
                when 4 then '真实投诉，后不接受道歉'
                when 5 then '真实投诉，后受到骚扰/威胁'
                when 6 then '没有快递员联系客户道歉'
                when 7 then '客户投诉回访结果'
                when 8 then '确认网点已联系客户道歉'
                when 20 then '联系不上'
        end '道歉回访结果'
        ,case acc.parcel_callback_state
            when 1 then '已收到包裹'
            when 2 then '未收到包裹'
        end '包裹回访结果'
        ,plt.created_at 进入b来源时间
        ,case plt.state
                when 1 then '丢失件待处理'
                when 2 then '疑似丢失件待处理'
                when 3 then '待工单回复'
                when 4 then '已工单回复'
                when 5 then '包裹未丢失'
                when 6 then '丢失件处理完成'
        end 处理状态
        ,case plt.duty_result
                when 1 then '丢失'
                when 2 then '破损/短少'
                when 3 then '超时效'
        end  判责类型
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,if(acc.store_callback_expired = 0 and acc.store_callback_at is not null  ,'是', '否') 是否道歉
#     ,replace(json_extract(am.extra_info, '$.request_sup_type'),'"', '') request_sup_type
#     ,ddd.CN_element 问题类型
#     ,replace(json_extract(am.extra_info, '$.request_sub_type'),'"', '')  request_sub_type
#     ,ddd2.CN_element 子问题类型
#     ,replace(json_extract(am.extra_info, '$.request_sul_type'),'"', '') request_sul_type
#     ,ddd3.CN_element 三级问题类型
# from bi_pro.abnormal_message am
# left join bi_pro.abnormal_customer_complaint acc on am.merge_column =acc.pno
from fle_staging.customer_issue ci
left join bi_pro.abnormal_message am on ci.id = json_extract(am.extra_info, '$.source_id') and am.created_at > date_sub(curdate(),interval 40 day)
left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id and acc.created_at > date_sub(curdate(),interval 40 day)
left join fle_staging.parcel_info pi on ci.pno=pi.pno and pi.created_at>='2023-08-01'
left join nl_production.abnormal_customer_complaint_authentic acca on acca.merge_column =acc.pno
left join bi_pro.parcel_lose_task plt on plt.pno=ci.pno and plt.source=2
left join backyard_pro.hr_staff_info hsi on hsi.staff_info_id=acc.apology_staff_info_id
left join backyard_pro.hr_job_title hjt on hjt.id =hsi.job_title
# left join dwm.dwd_dim_dict ddd on ddd.element = replace(json_extract(am.extra_info, '$.request_sup_type'),'"', '') and ddd.db = 'fle_staging' and ddd.tablename = 'customer_issue' and ddd.fieldname = 'request_sup_type'
# left join dwm.dwd_dim_dict ddd2 on ddd2.element = replace(json_extract(am.extra_info, '$.request_sub_type'),'"', '') and ddd2.db = 'fle_staging' and ddd2.tablename = 'customer_issue' and ddd2.fieldname = 'request_sub_type'
# left join dwm.dwd_dim_dict ddd3 on ddd3.element = replace(json_extract(am.extra_info, '$.request_sul_type'),'"', '') and ddd3.db = 'fle_staging' and ddd3.tablename = 'customer_issue' and ddd3.fieldname = 'request_sul_type'
where
    ci.created_at >= '2023-11-02 17:00:00'
    and acc.created_at<'2023-11-17 17:00:00'
    and acc.pno is not null
    and ci.request_sup_type = 22
    and ci.request_sub_type = 300
#     and am.punish_category = 21
group by 1,2,3,4
;








select
    ci.pno
    ,ci.client_id
    ,case pi.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,convert_tz(ci.created_at, '+00:00', '+07:00') 投诉时间
    ,case
        when acc.`channel_type` =1 then 'APP揽件任务'
        when acc.`channel_type` =2 then 'APP派件任务'
        when acc.`channel_type` =3 then 'APP投诉'
        when acc.`channel_type` =4 then '短信揽件投诉'
        when acc.`channel_type` =5 then '短信派件投诉'
        when acc.`channel_type` =6 then '短信妥投投诉'
        when acc.`channel_type` =7 then 'MS问题记录本'
        when acc.`channel_type` =8 then '新增处罚记录'
        when acc.`channel_type` =9 then 'KA投诉'
        when acc.`channel_type` =10 then '官网投诉'
        when acc.`channel_type` =12 then 'BS问题记录本'
     end as '投诉渠道'
     ,case
        when acc.`complaints_type` =1 then '虚假妥投'
        when acc.`complaints_type` =2 then '虚假揽收改约时间/取消揽件任务'
        when acc.`complaints_type` =3 then '派件虚假留仓件/问题件'
        when acc.`complaints_type` =4 then '普通客诉'
        when acc.`complaints_type` =5 then '其他'
        when acc.`complaints_type` =6 then '服务态度类投诉'
        when acc.`complaints_type` =7 then '操作规范类投诉'
    end as '投诉大类'
    ,case acc.complaints_sub_type
        when 1 then '业务不熟练'
        when 2 then '虚假签收'
        when 3 then '以不礼貌的态度对待客户'
        when 4 then '揽/派件动作慢'
        when 5 then '未经客户同意投递他处'
        when 6 then '未经客户同意改约时间'
        when 7 then '不接客户电话'
        when 8 then '包裹丢失 没有数据'
        when 9 then '改约的时间和客户沟通的时间不一致'
        when 10 then '未提前电话联系客户'
        when 11 then '包裹破损 没有数据'
        when 12 then '未按照改约时间派件'
        when 13 then '未按订单带包装'
        when 14 then '不找零钱'
        when 15 then '客户通话记录内未看到员工电话'
        when 16 then '未经客户允许取消揽件任务'
        when 17 then '未给客户回执'
        when 18 then '拨打电话时间太短，客户来不及接电话'
        when 19 then '未经客户允许退件'
        when 20 then '没有上门'
        when 21 then '其他'
        when 22 then '未经客户同意改约揽件时间'
        when 23 then '改约的揽件时间和客户要求的时间不一致'
        when 24 then '没有按照改约时间揽件'
        when 25 then '揽件前未提前联系客户'
        when 26 then '答应客户揽件，但最终没有揽'
        when 27 then '很晚才打电话联系客户'
        when 28 then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when 29 then '因为超过当日截单时间，要求客户取消'
        when 30 then '声称不是自己负责的区域，要求客户取消'
        when 31 then '拨打电话时间太短，客户来不及接电话'
        when 32 then '不接听客户回复的电话'
        when 33 then '答应客户今天上门，但最终没有揽收'
        when 34 then '没有上门揽件，也没有打电话联系客户'
        when 35 then '货物不属于超大件/违禁品'
        when 36 then '没有收到包裹，且快递员没有联系客户'
        when 37 then '快递员拒绝上门派送'
        when 38 then '快递员擅自将包裹放在门口或他处'
        when 39 then '快递员没有按约定的时间派送'
        when 40 then '代替客户签收包裹'
        when 41 then '快说话不礼貌/没有礼貌/不愿意服务'
        when 42 then '说话不礼貌/没有礼貌/不愿意服务'
        when 43 then '快递员抛包裹'
        when 44 then '报复/骚扰客户'
        when 45 then '快递员收错COD金额'
        when 46 then '虚假妥投'
        when 47 then '派件虚假留仓件/问题件'
        when 48 then '虚假揽件改约时间/取消揽件任务'
        when 49 then '抛客户包裹'
        when 50 then '录入客户信息不正确'
        when 51 then '送货前未电话联系'
        when 52 then '未在约定时间上门'
        when 53 then '上门前不电话联系'
        when 54 then '以不礼貌的态度对待客户'
        when 55 then '录入客户信息不正确'
        when 56 then '与客户发生肢体接触'
        when 57 then '辱骂客户'
        when 58 then '威胁客户'
        when 59 then '上门揽件慢'
        when 60 then '快递员拒绝上门揽件'
        when 61 then '未经客户同意标记收件人拒收'
        when 62 then '未按照系统地址送货导致收件人拒收'
        when 63 then '情况不属实，快递员虚假标记'
        when 64 then '情况不属实，快递员诱导客户改约时间'
        when 65 then '包裹长时间未派送'
        when 66 then '未经同意拒收包裹'
        when 67 then '已交费仍索要COD'
        when 68 then '投递时要求开箱'
        when 69 then '不当场扫描揽收'
        when 70 then '揽派件速度慢'
    end as '投诉原因'
    ,case acca.qaqc_callback_result
            when 1 then '误投诉'
            when 2 then '真实投诉，对快递员/网点人员不满意'
            when 3 then '真实投诉，对Flash公司服务不满意'
            when 4 then '未联系上'
    end '回访是否真实'
    ,acca.qaqc_callback_num 回访次数
    ,timestampdiff(hour,acca.created_at,acca.qaqc_callback_at) '回访是否真实结果➖投诉进入的时间'
    ,if(am.merge_column is not null,'是','否') 是否生成处罚
    ,acc.store_callback_at 道歉的时间
    ,acc.apology_staff_info_id 道歉人
    ,hjt.job_name 道歉人职位
    ,acc.qaqc_callback_num 是否道歉回访次数
    ,acc.qaqc_callback_at 回访时间
    ,case acc.qaqc_callback_result
            when 0 then '待回访'
            when 1 then '多次未联系上客户'
            when 2 then '误投诉'
            when 3 then '真实投诉，后接受道歉'
            when 4 then '真实投诉，后不接受道歉'
            when 5 then '真实投诉，后受到骚扰/威胁'
            when 6 then '没有快递员联系客户道歉'
            when 7 then '客户投诉回访结果'
            when 8 then '确认网点已联系客户道歉'
            when 20 then '联系不上'
    end '道歉回访结果'
    ,case acc.parcel_callback_state
        when 1 then '已收到包裹'
        when 2 then '未收到包裹'
    end '包裹回访结果'
    ,plt.created_at 进入b来源时间
    ,case plt.state
            when 1 then '丢失件待处理'
            when 2 then '疑似丢失件待处理'
            when 3 then '待工单回复'
            when 4 then '已工单回复'
            when 5 then '包裹未丢失'
            when 6 then '丢失件处理完成'
    end 处理状态
    ,case plt.duty_result
            when 1 then '丢失'
            when 2 then '破损/短少'
            when 3 then '超时效'
    end  判责类型
    ,pi.ticket_delivery_staff_info_id 妥投员工
    ,if(acc.store_callback_expired = 0 and acc.store_callback_at is not null  ,'是', '否') 是否道歉
    ,ddd.CN_element 问题类型
    ,ddd2.CN_element 子问题类型
    ,ddd3.CN_element 三级问题类型
from fle_staging.customer_issue ci
left join bi_pro.abnormal_message am on ci.id = json_extract(am.extra_info, '$.source_id') and am.created_at > date_sub(curdate(),interval 40 day)
left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id and acc.created_at > date_sub(curdate(),interval 40 day)
left join fle_staging.parcel_info pi on acc.pno=pi.pno and pi.created_at>='2023-10-01'
left join nl_production.abnormal_customer_complaint_authentic acca on acca.merge_column =acc.pno
left join bi_pro.parcel_lose_task plt on plt.pno=acc.pno and plt.source=2
left join backyard_pro.hr_staff_info hsi on hsi.staff_info_id=acc.apology_staff_info_id
left join backyard_pro.hr_job_title hjt on hjt.id =hsi.job_title
left join dwm.dwd_dim_dict ddd on ddd.element = ci.request_sup_type and ddd.db = 'fle_staging' and ddd.tablename = 'customer_issue' and ddd.fieldname = 'request_sup_type'
left join dwm.dwd_dim_dict ddd2 on ddd2.element = ci.request_sub_type and ddd2.db = 'fle_staging' and ddd2.tablename = 'customer_issue' and ddd2.fieldname = 'request_sub_type'
left join dwm.dwd_dim_dict ddd3 on ddd3.element = ci.request_sul_type and ddd3.db = 'fle_staging' and ddd3.tablename = 'customer_issue' and ddd3.fieldname = 'request_sul_type'
where
    ci.created_at >= '2023-11-02 17:00:00'
    and acc.created_at < '2023-11-17 17:00:00'
    and acc.pno is not null
    and
        (
            (ci.request_sup_type = 22 and ci.request_sub_type in (221,300))
            or
            (ci.request_sup_type = 16 and ci.request_sub_type = 160 and ci.request_sul_type = 55)
        )
group by 1,2,3,4
