select
#    case
#         when a.处罚原因 = '包裹丢失' then '包裹丢失'
#         when a.处罚原因 = '仓管未交接SPEED/优先包裹给快递员' then '仓管未交接SPEED/优先包裹给快递员'
#         when a.处罚原因 = '迟到罚款 ' then '迟到罚款 '
#         when a.处罚原因 = '揽件任务未及时分配' then '揽件任务未及时分配'
#         when a.处罚原因 = '揽收不及时' then '揽收不及时'
#         when a.处罚原因 = '揽收或中转包裹未及时发出' then '揽收或中转包裹未及时发出'
#         when a.处罚原因 = '客户投诉' then '客户投诉'
#         else '其他罚款'
#    end 分类
#   ,count(1)
    *
from
    (
        select
            dt.region_name 大区
            ,dt.piece_name 片区
            ,dt.store_name 网点
            ,sd.name 部门
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
                when 67 then '时效延迟'
                when 68 then '未及时呼叫快递员'
                when 69 then '未及时尝试派送'
                when 70 then '退件包裹未处理'
                when 71 then '不更新包裹状态'
                when 72 then 'PRI包裹未及时妥投'
                when 73 then '临近时效包裹未及时妥投'
                when 74 then '暴力分拣'
                when 75 then '上报拒收证据不合格'
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
                when 24   then   '虚假标记拒收'
                when 25   then   '虚假标记改约时间'
                when 26   then   '恢复任务再次取消'
                when 27   then   '个人外协违规投诉主管72小时内未道歉'
                when 28   then   '个人外协违规投诉客户不接受主管道歉'
                when 29   then   '虛假上报车里程 虚假审批里程'

                when 71 then '重量差（复秤后-复秤前）【KG】（2kg,5kg]'
                when 72 then '重量差（复秤后-复秤前）【KG】 >5 kg'
                when 73 then '重量差（复秤后-复秤前）【KG】<-2kg'
                when 74 then '尺寸差（复秤后-复秤前）【CM】(20,30]'
                when 75 then '尺寸差（复秤后-复秤前）【CM】>30'
                when 76 then '尺寸差（复秤后-复秤前）【CM】<-20'
            end as '具体原因'
            ,case acc.`complaints_type`
                when 6 then '服务态度类投诉 1级'
                when 2 then '虚假揽件改约时间/取消揽件任务 2级'
                when 1 then '虚假妥投 3级'
                when 3 then '派件虚假留仓件/问题件 4级'
                when 7 then '操作规范类投诉 5级'
                when 5 then '其他 6级'
                when 4 then '普通客诉 已弃用，仅供展示历史'
                when 8 then '不当场扫描揽收'
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
                when hsi.`state`=1 and hsi.`wait_leave_state`= 0 then '在职'
                when hsi.`state`=1 and hsi.`wait_leave_state`= 1 then '待离职'
                when hsi.`state`=2 then '离职'
                when hsi.`state`=3 then '停职'
            end as 在职状态
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
            ,json_extract(am.extra_info, '$.attendance_at')  打卡时间
            ,am.reward_staff_info_id 奖励员工
            ,am.reward_money 奖励金额
            ,ddd.CN_element 最后有效路由
            ,am.route_at 最后有效路由时间
           -- count(1)
        from bi_pro.abnormal_message am
        left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
        left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
        left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
        left join fle_staging.sys_department sd on sd.id = hsi.sys_department_id
        left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
        left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            am.created_at >= date_sub(last_day(date_sub(curdate(), interval 1 month)), interval day(last_day(date_sub(curdate(), interval 1 month))) - 16 day)
            and am.created_at < date_sub(last_day(curdate()), interval day(last_day(curdate()))  - 1 day)
            -- and hsi.job_title in (13,110,452,1497)
           -- and hsi.hire_type = 13
            and hsi.sys_store_id != -1
    ) a
where
    a.状态 in ('未申诉', '申诉中', '保持原判', '已变更')
    and a.部门 in ('Network Bulky Area' , 'Network Management' , 'Network Area')
    and a.处罚原因 = '揽收或中转包裹未及时发出'
-- group by 1
;

select date_sub(last_day(date_sub(curdate(), interval 1 month)), interval day(last_day(date_sub(curdate(), interval 1 month))) - 16 day) as 上个月16号;
select date_sub(last_day(date_sub(curdate(), interval 1 month)), interval day(last_day(date_sub(curdate(), interval 1 month)))  -1 day) as 上个月1号;
select date_sub(last_day(curdate()), interval day(last_day(curdate()))  -1 day) as 本月1号;
select date_sub(last_day(curdate()), interval day(last_day(curdate()))  - 16 day) as 本月16号;


/*
  =====================================================================+
  表名称：2035d_th_before_half_month_personal_agency_abnormal_message
  功能描述：泰国前半月个人代理处罚记录

  需求来源：
  编写人员: 吕杰
  设计日期：2024-03-13
  修改日期:
  修改人员:
  修改原因:
  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
  +=====================================================================
*/
select
  *
from
    (
        select
            dt.region_name 大区
            ,dt.piece_name 片区
            ,dt.store_name 网点
            ,sd.name 部门
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
                When 12 then '迟到罚款'
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
                when 67 then '时效延迟'
                when 68 then '未及时呼叫快递员'
                when 69 then '未及时尝试派送'
                when 70 then '退件包裹未处理'
                when 71 then '不更新包裹状态'
                when 72 then 'PRI包裹未及时妥投'
                when 73 then '临近时效包裹未及时妥投'
                when 74 then '暴力分拣'
                when 75 then '上报拒收证据不合格'
                WHEN 76 THEN '个人代理-不接单未提前通知'
    			WHEN 77 THEN '个人代理-终止合同未提前通知'
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
                when 24   then   '虚假标记拒收'
                when 25   then   '虚假标记改约时间'
                when 26   then   '恢复任务再次取消'
                when 27   then   '个人外协违规投诉主管72小时内未道歉'
                when 28   then   '个人外协违规投诉客户不接受主管道歉'
                when 29   then   '虛假上报车里程 虚假审批里程'

                when 71 then '重量差（复秤后-复秤前）【KG】（2kg,5kg]'
                when 72 then '重量差（复秤后-复秤前）【KG】 >5 kg'
                when 73 then '重量差（复秤后-复秤前）【KG】<-2kg'
                when 74 then '尺寸差（复秤后-复秤前）【CM】(20,30]'
                when 75 then '尺寸差（复秤后-复秤前）【CM】>30'
                when 76 then '尺寸差（复秤后-复秤前）【CM】<-20'
            end as '具体原因'
            ,case acc.`complaints_type`
                when 6 then '服务态度类投诉 1级'
                when 2 then '虚假揽件改约时间/取消揽件任务 2级'
                when 1 then '虚假妥投 3级'
                when 3 then '派件虚假留仓件/问题件 4级'
                when 7 then '操作规范类投诉 5级'
                when 5 then '其他 6级'
                when 4 then '普通客诉 已弃用，仅供展示历史'
                when 8 then '不当场扫描揽收'
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
                when hsi.`state`=1 and hsi.`wait_leave_state`= 0 then '在职'
                when hsi.`state`=1 and hsi.`wait_leave_state`= 1 then '待离职'
                when hsi.`state`=2 then '离职'
                when hsi.`state`=3 then '停职'
            end as 在职状态
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
            ,json_extract(am.extra_info, '$.attendance_at')  打卡时间
            ,am.reward_staff_info_id 奖励员工
            ,am.reward_money 奖励金额
            ,ddd.CN_element 最后有效路由
            ,am.route_at 最后有效路由时间
           -- count(1)
        from bi_pro.abnormal_message am
        left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
        left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
        left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
        left join fle_staging.sys_department sd on sd.id = hsi.sys_department_id
        left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
        left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            am.created_at >= date_sub(last_day(date_sub(curdate(), interval 1 month)), interval day(last_day(date_sub(curdate(), interval 1 month))) - 16 day)
            and am.created_at < date_sub(last_day(curdate()), interval day(last_day(curdate()))  -1 day)
            -- and hsi.job_title in (13,110,452,1497)
            and hsi.hire_type = 13
            and hsi.sys_store_id != -1
    ) a
where
    a.状态 in ('未申诉', '申诉中', '保持原判', '已变更')
    and a.部门 in ('Network Bulky Area' , 'Network Management' , 'Network Area')
   ;
   select
  *
from
    (
        select
            dt.region_name 大区
            ,dt.piece_name 片区
            ,dt.store_name 网点
            ,sd.name 部门
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
                when 67 then '时效延迟'
                when 68 then '未及时呼叫快递员'
                when 69 then '未及时尝试派送'
                when 70 then '退件包裹未处理'
                when 71 then '不更新包裹状态'
                when 72 then 'PRI包裹未及时妥投'
                when 73 then '临近时效包裹未及时妥投'
                when 74 then '暴力分拣'
                when 75 then '上报拒收证据不合格'
                when 76 then '个人代理-不接单未提前通知'
                when 77 then '个人代理-终止合同未提前通知'
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
                when 24   then   '虚假标记拒收'
                when 25   then   '虚假标记改约时间'
                when 26   then   '恢复任务再次取消'
                when 27   then   '个人外协违规投诉主管72小时内未道歉'
                when 28   then   '个人外协违规投诉客户不接受主管道歉'
                when 29   then   '虛假上报车里程 虚假审批里程'

                when 71 then '重量差（复秤后-复秤前）【KG】（2kg,5kg]'
                when 72 then '重量差（复秤后-复秤前）【KG】 >5 kg'
                when 73 then '重量差（复秤后-复秤前）【KG】<-2kg'
                when 74 then '尺寸差（复秤后-复秤前）【CM】(20,30]'
                when 75 then '尺寸差（复秤后-复秤前）【CM】>30'
                when 76 then '尺寸差（复秤后-复秤前）【CM】<-20'
            end as '具体原因'
            ,case acc.`complaints_type`
                when 6 then '服务态度类投诉 1级'
                when 2 then '虚假揽件改约时间/取消揽件任务 2级'
                when 1 then '虚假妥投 3级'
                when 3 then '派件虚假留仓件/问题件 4级'
                when 7 then '操作规范类投诉 5级'
                when 5 then '其他 6级'
                when 4 then '普通客诉 已弃用，仅供展示历史'
                when 8 then '不当场扫描揽收'
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
                when hsi.`state`=1 and hsi.`wait_leave_state`= 0 then '在职'
                when hsi.`state`=1 and hsi.`wait_leave_state`= 1 then '待离职'
                when hsi.`state`=2 then '离职'
                when hsi.`state`=3 then '停职'
            end as 在职状态
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
            ,json_extract(am.extra_info, '$.attendance_at')  打卡时间
            ,am.reward_staff_info_id 奖励员工
            ,am.reward_money 奖励金额
            ,ddd.CN_element 最后有效路由
            ,am.route_at 最后有效路由时间
           -- count(1)
        from bi_pro.abnormal_message am
        left join bi_pro.abnormal_customer_complaint acc on acc.abnormal_message_id = am.id
        left join dwm.dim_th_sys_store_rd dt on dt.store_id = am.store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = am.staff_info_id
        left join bi_pro.staff_achievements_give_object_day sag on sag.staff_info_id = am.staff_info_id and sag.stat_date = date_sub(date_format(hsi1.`leave_date`, '%Y-%m-%d'), interval 1 day)
        left join bi_pro.staff_achievements_give_object_day sag2 on sag2.staff_info_id = am.staff_info_id and sag2.stat_date = am.abnormal_time
        left join bi_pro.hr_job_title hjt on hjt.id = sag2.job_title
        left join fle_staging.sys_department sd on sd.id = hsi.sys_department_id
        left join bi_pro.abnormal_qaqc aq on aq.abnormal_message_id = am.id
        left join dwm.dwd_dim_dict ddd on ddd.element = am.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            am.abnormal_time >= date_sub(last_day(date_sub(curdate(), interval 1 month)), interval day(last_day(date_sub(curdate(), interval 1 month)))  -1 day)
            and am.abnormal_time < date_sub(last_day(date_sub(curdate(), interval 1 month)), interval day(last_day(date_sub(curdate(), interval 1 month))) - 16 day)
            -- and hsi.job_title in (13,110,452,1497)
            and (sag2.hire_type = 13 or sag.hire_type = 13)
            and am.state = 1
            and am.isdel = 0
            and coalesce(sag.store_id, hsi.sys_store_id) != -1
    ) a



