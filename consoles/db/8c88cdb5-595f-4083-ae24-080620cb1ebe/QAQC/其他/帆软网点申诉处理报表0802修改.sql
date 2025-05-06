select
    case a.punish_category
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
        When 67 then '时效延迟'
        When 68 then '未及时呼叫快递员'
        When 69 then '未及时尝试派送'
        When 70 then '退件包裹未处理'
    end 任务类型
    ,count(distinct if(a.deal_status = 'n' and a.created_at < date(date_sub(now(), interval 1 hour)), a.id, null)) 历史积压量
    ,count(distinct if(a.created_at >= date(date_sub(now(), interval 1 hour)), a.id, null)) 当日新增量
    ,count(distinct if(a.deal_status = 'n', a.id, null)) 待处理总量
    ,count(distinct if(a.deal_status = 'y' and a.deal_date >= date(date_sub(now(), interval 1 hour)), a.id, null)) 当日已处理总量
    ,count(distinct if(a.deal_status = 'y' and a.deal_date >= date(date_sub(now(), interval 1 hour)) and a.created_at < date(date_sub(now(), interval 1 hour)), a.id, null)) 当日已处理积压量
    ,count(distinct if(a.deal_status = 'y' and a.deal_date >= date(date_sub(now(), interval 1 hour)) and a.created_at >= date(date_sub(now(), interval 1 hour)), a.id, null)) 当日已处理新增量
from
    (
        select
            am.punish_category
            ,if(am.isdel = 1 or coalesce(aq.isappeal,am.isappeal) in (3,4,5), 'y', 'n') deal_status
            ,case
                when am.isdel = 1 then am.del_date
                when am.isdel = 0 and coalesce(aq.isappeal, am.isappeal) then aq.handle_time
            end deal_date
            ,aq.created_at
            ,aq.id
        from bi_pro.abnormal_qaqc aq
        left join bi_pro.abnormal_message am on am.id = aq.abnormal_message_id
        left join nl_production.abnormal_message_del amd on amd.id = aq.abnormal_message_id
        where
            aq.type = 2

        union all

        select
            am.punish_category
            ,if(am.isdel = 1 or coalesce(aq.isappeal,am.isappeal) in (3,4,5), 'y', 'n') deal_status
            ,case
                when am.isdel = 1 then am.del_date
                when am.isdel = 0 and coalesce(aq.isappeal, am.isappeal) then aq.handle_time
            end deal_date
            ,aq.created_at
            ,aq.id
        from bi_pro.abnormal_qaqc aq
        left join bi_pro.abnormal_message am on am.average_merge_key = aq.qaqc_merge_key
        where
            aq.type = 1
        group by 1,2,3,4,5
    ) a
group by 1


;

select date(date_sub('2024-09-05 00:10:00', interval 1 hour))