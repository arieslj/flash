select
    dt.region_name 大区
    ,dt.piece_name 片区
    ,dt.store_name 网点
    ,am.merge_column 关联信息
    ,am.abnormal_time 异常日期
    ,case
        when aq.abnormal_money is not null then aq.abnormal_money                -- 处罚金额这在申诉之后固化
        when am.isdel = 1 then 0.00
        else am.punish_money
    end 处罚金额
    ,CASE am.`punish_category`
        When 1 then '虚假问题件/虚假留仓件'
        When 2 then '5天以内未妥投，且超24小时未更新'
        When 3 then '5天以上未妥投/未中转，且超24小时未更新'
        When 4 then '对问题件解决不及时'
        When 5 then '包裹配送时间超三天'
        When 6 then '未在客户要求的改约时间之前派送包裹'
        When 7 then '包裹丢失'
        When 8 then '包裹破损'
        When 9 then '其他'
        When 10 then '揽件时称量包裹不准确'
        When 11 then '出纳回款不及时'
        When 12 then '迟到罚款 每分钟10泰铢'
        When 13 then '揽收或中转包裹未及时发出'
        When 14 then '仓管对工单处理不及时'
        When 15 then '仓管未及时处理问题件包裹'
        When 16 then '客户投诉罚款 已废弃'
        When 17 then '故意不接公司电话 自定义'
        When 18 then '仓管未交接SPEED/优先包裹给快递员'
        When 19 then 'PRI或者speed包裹未妥投'
        When 20 then '虚假妥投'
        When 21 then '客户投诉'
        When 22 then '快递员公款超时未上缴'
        When 23 then 'miniCS工单处理不及时'
        When 24 then '客户投诉-虚假问题件/虚假留仓件'
        When 25 then '揽收禁运包裹'
        When 26 then '早退罚款'
        When 27 then '班车发车晚点'
        When 28 then '虚假回复工单'
        When 29 then '未妥投包裹没有标记'
        When 30 then '未妥投包裹没有入仓'
        When 31 then 'SPEED/PRI件派送中未及时联系客户'
        When 32 then '仓管未及时交接SPEED/PRI优先包裹'
        When 33 then '揽收不及时'
        When 34 then '网点应盘点包裹未清零'
        When 35 then '漏揽收'
        When 36 then '包裹外包装不合格'
        When 37 then '超大件'
        When 38 then '多面单'
        When 39 then '不称重包裹未入仓'
        When 40 then '上传虚假照片'
        When 41 then '网点到件漏扫描'
        When 42 then '虚假撤销'
        When 43 then '虚假揽件标记'
        When 44 then '外协员工日交接不满50件包裹'
        When 45 then '超大集包处罚'
        When 46 then '不集包'
        When 47 then '理赔处理不及时'
        When 48 then '面单粘贴不规范'
        When 49 then '未换单'
        When 50 then '集包标签不规范'
        When 51 then '未及时关闭揽件任务'
        When 52 then '虚假上报（虚假违规件上报）'
        When 53 then '虚假错分'
        When 54 then '物品类型错误（水果件）'
        When 55 then '虚假上报车辆里程'
        When 56 then '物品类型错误（文件）'
        When 57 then '旷工罚款'
        When 58 then '虚假取消揽件任务'
        When 59 then '72h未联系客户道歉'
        When 60 then '虚假标记拒收'
        When 61 then '外协投诉主管未及时道歉'
        When 62 then '外协投诉客户不接受道歉'
        When 63 then '揽派件照片不合格'
        When 64 then '揽件任务未及时分配'
        When 65 then '网点未及时上传回款凭证'
        When 66 then '网点上传虚假回款凭证'
    end as '处罚原因'
    ,case am.`punish_sub_category`
        when 1   then '超大件'
        when 2   then   '违禁品'
        when 3   then '寄件人电话号码是空号'
        when 4   then   '收件人电话号码是空号'
        when 5   then    '虛假上报车里程模糊'
        when 6   then    '虛假上报车里程'
        when 7   then '重量差（复秤-揽收）（0.5kg,2kg]'
        when 8   then    '重量差（复秤-揽收）（2kg,5kg]'
        when 9   then    '重量差（复秤-揽收）>5kg'
        when 10   then   '重量差（复秤-揽收）<-0.5kg'
        when 11   then   '重量差（复秤-揽收）（1kg,3kg]'
        when 12   then '重量差（复秤-揽收）（3kg,6kg]'
        when 13   then   '重量差（复秤-揽收）>6kg'
        when 14   then    '重量差（复秤-揽收）<-1kg'
        when 15   then   '尺寸差（复秤-揽收）(10cm,20cm]'
        when 16   then   '尺寸差（复秤-揽收）(20cm,30cm]'
        when 17   then    '尺寸差（复秤-揽收）>30cm'
        when 18   then   '尺寸差（复秤-揽收）<-10cm'
        when 22   then    '虛假上报车里程 虚假-图片与数字不符合'
        when 23   then    '虛假上报车里程 虚假-滥用油卡'
    end as '具体原因'
    ,case acc.`complaints_type`
        when 6 then '服务态度类投诉 1级'
        when 2 then '虚假揽件改约时间/取消揽件任务 2级'
        when 1 then '虚假妥投 3级'
        when 3 then '派件虚假留仓
件/问题件 4级'
        when 7 then '操作规范类投诉 5级'
        when 5 then '其他 6级'
        when 4 then '普通客诉 已弃用，仅供展示历史'
    end as 投诉大类
    ,case acc.complaints_sub_type
        when  1 then '业务不熟练'
        when  2 then '虚假签收'
        when  3 then '以不礼貌的态度对待客户'
        when  4 then '揽/派件动作慢'
        when  5 then '未经客户同意投递他处'
        when  6 then '未经客户同意改约时间'
        when  7 then '不接客户电话'
        when  8 then '包裹丢失 没有数据'
        when  9 then '改约的时间和客户沟通的时间不一致'
        when  10 then '未提前电话联系客户'
        when  11 then '包裹破损 没有数据'
        when  12   then '未按照改约时间派件'
        when  13    then '未按订单带包装'
        when  14   then '不找零钱'
        when  15    then '客户通话记录内未看到员工电话'
        when  16    then '未经客户允许取消揽件任务'
        when  17   then '未给客户回执'
        when  18   then '拨打电话时间太短，客户来不及接电话'
        when  19   then '未经客户允许退件'
        when  20    then '没有上门'
        when  21    then '其他'
        when  22   then '未经客户同意改约揽件时间'
        when  23    then '改约的揽件时间和客户要求的时间不一致'
        when  24    then '没有按照改约时间揽件'
        when  25    then '揽件前未提前联系客户'
        when  26    then '答应客户揽件，但最终没有揽'
        when  27    then '很晚才打电话联系客户'
        when  28    then '货物多/体积大，因骑摩托而拒绝上门揽收'
        when  29    then '因为超过当日截单时间，要求客户取消'
        when  30    then '声称不是自己负责的区域，要求客户取消'
        when  31    then '拨打电话时间太短，客户来不及接电话'
        when  32    then '不接听客户回复的电话'
        when  33    then '答应客户今天上门，但最终没有揽收'
        when  34    then '没有上门揽件，也没有打电话联系客户'
        when  35    then '货物不属于超大件/违禁品'
        when  36    then '没有收到包裹，且快递员没有联系客户'
        when  37    then '快递员拒绝上门派送'
        when  38    then '快递员擅自将包裹放在门口或他处'
        when  39    then '快递员没有按约定的时间派送'
        when  40    then '代替客户签收包裹'
        when  41   then '快说话不礼貌/没有礼貌/不愿意服务'
        when  42    then '说话不礼貌/没有礼貌/不愿意服务'
        when  43    then '快递员抛包裹'
        when  44    then '报复/骚扰客户'
        when  45   then '快递员收错COD金额'
        when  46   then '虚假妥投'
        when  47    then '派件虚假留仓件/问题件'
        when  48   then '虚假揽件改约时间/取消揽件任务'
        when  49   then '抛客户包裹'
        when  50    then '录入客户信息不正确'
        when  51    then '送货前未电话联系'
        when  52    then '未在约定时间上门'
        when  53    then '上门前不电话联系'
        when  54    then '以不礼貌的态度对待客户'
        when  55    then '录入客户信息不正确'
        when  56    then '与客户发生肢体接触'
        when  57    then '辱骂客户'
        when  58    then '威胁客户'
        when  59    then '上门揽件慢'
        when  60    then '快递员拒绝上门揽件'
        when  61    then '未经客户同意标记收件人拒收'
        when  62    then '未按照系统地址送货导致收件人拒收'
        when  63 then '情况不属实，快递员虚假标记'
        when  64 then '情况不属实，快递员诱导客户改约时间'
        when  65 then '包裹长时间未派送'
        when  66 then '未经同意拒收包裹'
        when  67 then '已交费仍索要COD'
        when  68 then '投递时要求开箱'
        when  69 then '不当场扫描揽收'
        when  70 then '揽派件速度慢'
    end as '投诉原因'
    ,am.edit_reason 备注
    ,am.staff_info_id 工号
    ,hsi.name 员工姓名
    ,hjt.job_name 员工职位
    ,case
        when coalesce(am.isappeal, aq.isappeal) = 1 then '未申诉'
        when coalesce(am.isappeal, aq.isappeal) = 2 then '申诉中'
        when coalesce(am.isappeal, aq.isappeal) = 3 then '保持原判'
        when coalesce(am.isappeal, aq.isappeal) = 4 then '已变更'
        when coalesce(am.isappeal, aq.isappeal) = 5 or am.isdel = 1 then '已删除'
    end 状态
    ,case
        when am.isdel = 1 then 0.00
        when am.isappeal = 1 then '-'
        when am.isappeal = 2 then '-'
        when am.isdel = 0 then am.punish_money
    end 申诉后的金额
from bi_pro.abnormal_message am
left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
where
    am.abnormal_object = 0
    and am.abnormal_time >= '2023-02-01'
    and am.abnormal_time < '2023-03-01'
    and am.state = 1
    and am.isdel = 0
    and dt.region_name in  ('Area14','Area3','Area6','Bulky Area 1','Bulky Area 2','Bulky Area 3','Bulky Area 4','Bulky Area 5','Bulky Area 6','Bulky Area 7','Bulky Area 8','Bulky Area 9','CDC Area 1','CDC Area 2')

;

