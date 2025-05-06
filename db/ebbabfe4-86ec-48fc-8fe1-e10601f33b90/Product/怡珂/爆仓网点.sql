
select
    date_sub(curdate(), interval 1 day) 日期
    ,ss.name 网点
from nl_production.abnormal_white_list awl
left join my_staging.sys_store ss on ss.id = awl.store_id
where
    awl.type = 2
    and awl.start_date <= date_sub(curdate(), interval 1 day)
    and awl.end_date >= date_sub(curdate(), interval 1 day)

;

select
    ss.name 爆仓网点名称
    ,case a1.`punish_category`
        when 1 then '虚假问题件/虚假留仓件'
        when 2 then '5天以内未妥投，且超24小时未更新'
        when 3 then '5天以上未妥投/未中转，且超24小时未更新'
        when 4 then '对问题件解决不及时'
        when 5 then '包裹配送时间超三天'
        when 6 then '未在客户要求的改约时间之前派送包裹'
        when 7 then '包裹丢失'
        when 8 then '包裹破损'
        when 9 then '其他'
        when 10 then '揽件时称量包裹不准确'
        when 11 then '出纳回款不及时'
        when 12 then '迟到罚款 每分钟10泰铢'
        when 13 then '揽收或中转包裹未及时发出'
        when 14 then '仓管对工单处理不及时'
        when 15 then '仓管未及时处理问题件包裹'
        when 16 then '客户投诉罚款 已废弃'
        when 17 then '故意不接公司电话 自定义'
        when 18 then '仓管未交接speed/优先包裹给快递员'
        when 19 then 'pri或者speed包裹未妥投'
        when 20 then '虚假妥投'
        when 21 then '客户投诉'
        when 22 then '快递员公款超时未上缴'
        when 23 then 'minics工单处理不及时'
        when 24 then '客户投诉-虚假问题件/虚假留仓件'
        when 25 then '揽收禁运包裹'
        when 26 then '早退罚款'
        when 27 then '班车发车晚点'
        when 28 then '虚假回复工单'
        when 29 then '未妥投包裹没有标记'
        when 30 then '未妥投包裹没有入仓'
        when 31 then 'speed/pri件派送中未及时联系客户'
        when 32 then '仓管未及时交接speed/pri优先包裹'
        when 33 then '揽收不及时'
        when 34 then '网点应盘点包裹未清零'
        when 35 then '漏揽收'
        when 36 then '包裹外包装不合格'
        when 37 then '超大件'
        when 38 then '多面单'
        when 39 then '不称重包裹未入仓'
        when 40 then '上传虚假照片'
        when 41 then '网点到件漏扫描'
        when 42 then '虚假撤销'
        when 43 then '虚假揽件标记'
        when 44 then '外协员工日交接不满50件包裹'
        when 45 then '超大集包处罚'
        when 46 then '不集包'
        when 47 then '理赔处理不及时'
        when 48 then '面单粘贴不规范'
        when 49 then '未换单'
        when 50 then '集包标签不规范'
        when 51 then '未及时关闭揽件任务'
        when 52 then '虚假上报（虚假违规件上报）'
        when 53 then '虚假错分'
        when 54 then '物品类型错误（水果件）'
        when 55 then '虚假上报车辆里程'
        when 56 then '物品类型错误（文件）'
        when 57 then '旷工罚款'
        when 58 then '虚假取消揽件任务'
        when 59 then '72h未联系客户道歉'
        when 60 then '虚假标记拒收'
        when 61 then '外协投诉主管未及时道歉'
        when 62 then '外协投诉客户不接受道歉'
        when 63 then '揽派件照片不合格'
        when 64 then '揽件任务未及时分配'
        when 65 then '网点未及时上传回款凭证'
        when 66 then '网点上传虚假回款凭证'
        when 67 then '时效延迟'
        when 68 then '未及时呼叫快递员'
        when 69 then '未及时尝试派送'
        when 70 then '退件包裹未处理'
        when 71 then '不更新包裹状态'
        when 72 then 'pri包裹未及时妥投'
        when 73 then '临近时效包裹未及时妥投'
        when 74 then '暴力分拣'
        when 75 then '上报拒收证据不合格'
    end as '处罚原因'
    ,count(distinct a1.merge_column) 处罚单量
from
    (
        select
            am.merge_column
            ,am.store_id
            ,am.punish_category
        from my_bi.abnormal_message am
        where
            am.edit_reason = 'System modification，Bursting store'
            and am.abnormal_time = date_sub(curdate(), interval 1 day)

        union all

        select
            amd.merge_column
            ,amd.store_id
            ,amd.punish_category
        from nl_production.abnormal_message_del amd
        where
            amd.edit_reason = 'System modification，Bursting store'
            and amd.abnormal_time = date_sub(curdate(), interval 1 day)
    ) a1
left join my_staging.sys_store ss on ss.id = a1.store_id
group by 1,2
order by 1,2