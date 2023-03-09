select
    di.pno
    ,di.client_id
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,if(pr.pno is null , '仓管直接标记疑难件拒收，无快递员标记', '快递员标记') 谁标记拒收
    ,case
        when json_extract(pr.extra_value, '$.rejectionModeCategory') = 1 then '当面拒收'
        when json_extract(pr.extra_value, '$.rejectionModeCategory') = 2 then '电话拒收'
    end 拒收方式
    ,case json_extract(pr.extra_value, '$.rejectionCategory')
        when 1 then '未购买商品'
        when 2 then '商品不满意'
        when 3 then '不想买了'
        when 4 then '物流不满意'
        when 5 then '理赔不满意'
        when 6 then '外包装破损'
        when 7 then '卖家问题拒收'
        when 8 then '包裹破损'
        when 9 then '包裹短少'
        when 10 then '收件人不接受理赔'
        when 11 then '其他'
        when 12 then '收件人拒付COD金额'
    end 拒收原因
    ,coalesce(convert_tz(pr.routed_at, '+00:00', '+07:00'),convert_tz(di.di_creat_at, '+00:00', '+07:00')) 拒收时间
    ,if(acc.pno is null , '否', '是') '是否投诉【派件虚假留仓件/问题件】'
    ,if(di.cod_enabled = 1, '是', '否') 是否COD
    ,di.staff_info_id 标记仓管员工ID
    ,di.diff_name 标记仓管员工姓名
    ,di.store_id 标记仓管所在网点
    ,pr.staff_info_id 标记快递员员工ID
    ,pr.pr_name 标记快递员工姓名
    ,pr.store_id 标记快递员工所在网点
    ,if(cdt.diff_info_id is null , '否', '是') '是否进入【问题件协商】'
    ,case cdt. negotiation_result_category
        when 1 then '赔偿'
        when 2 then '关闭订单(不赔偿不退货)'
        when 3 then '退货'
        when 4 then  '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK'
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
    end AS 协商结果
    ,case di.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as  包裹状态
    ,di.cod_amount/100 COD金额
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
    ,if(vrv.link_id is null, '否', '是') 是否进入疑似违规回访
    ,case vrv.`visit_result`
        when 1 then '联系不上'
        when 2 then '取消原因属实、合理'
        when 3 then '快递员虚假标记/违背客户意愿要求取消'
        when 4 then '多次联系不上客户'
        when 5 then '收件人已签收包裹'
        when 6 then '收件人未收到包裹'
        when 7 then '未经收件人允许投放他处/让他人代收'
        when 8 then '快递员没有联系客户，直接标记收件人拒收'
        when 9 then '收件人拒收情况属实'
        when 10 then '快递员服务态度差'
        when 11 then '因快递员未按照收件人地址送货，客户不方便去取货'
        when 12 then '网点派送速度慢，客户不想等'
        when 13 then '非快递员问题，个人原因拒收'
        when 14 then '其它'
        when 15 then '未经客户同意改约派件时间'
        when 16 then '未按约定时间派送'
        when 17 then '派件前未提前联系客户'
        when 18 then '收件人拒收情况不属实'
        when 19 then '快递员联系客户，但未经客户同意标记收件人拒收'
        when 20 then '快递员要求/威胁客户拒收'
        when 21 then '快递员引导客户拒收'
        when 22 then '其他'
        when 23 then '情况不属实，快递员虚假标记'
        when 24 then '情况不属实，快递员诱导客户改约时间'
        when 25 then '情况属实，客户原因改约时间'
        when 26 then '客户退货，不想购买该商品'
        when 27 then '客户未购买商品'
        when 28 then '客户本人/家人对包裹不知情而拒收'
        when 29 then '商家发错商品'
        when 30 then '包裹物流派送慢超时效'
        when 31 then '快递员服务态度差'
        when 32 then '因快递员未按照收件人地址送货，客户不方便去取货'
        when 33 then '货物验收破损'
        when 34 then '无人在家不便签收'
        when 35 then '客户错误拒收包裹'
    end as '回访结果'
from
    (
        select
            *
        from
            (
                select
                    di.pno
                    ,di.id
                    ,di.created_at di_creat_at
                    ,row_number() over (partition by di.pno order by di.created_at desc ) rn
                    ,pi.client_id
                    ,pi.state
                    ,pi.cod_amount
                    ,pi.cod_enabled
                    ,di.staff_info_id
                    ,di.store_id
                    ,hsi.name diff_name
                    ,date(convert_tz(sdt.created_at, '+00:00', '+07:00')) sdt_date
                from fle_staging.store_diff_ticket sdt
                left join fle_staging.diff_info di on sdt.diff_info_id = di.id
                left join fle_staging.parcel_info pi on pi.pno = di.pno
                left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = di.staff_info_id
                where
                    di.diff_marker_category in (2, 17)
                    and pi.created_at >= '2022-10-31 17:00:00'
                    and pi.created_at < '2022-11-30 17:00:00'
            ) di
        where di.rn =1
    ) di
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.staff_info_id
            ,pr.extra_value
            ,pr.store_id
            ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) pr_date
            ,hsi.name pr_name
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn2
        from rot_pro.parcel_route pr
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
        where
            pr.route_action = 'DELIVERY_MARKER'
            and pr.created_at > '2022-09-30 17:00:00'
            and pr.marker_category in (2, 17)
    ) pr on pr.pno = di.pno and pr.rn2 = 1
left join fle_staging.ka_profile kp on di.client_id = kp.id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = di.client_id
left join
    (
        select
            acc.pno
            ,acc.created_at
            ,row_number() over (partition by acc.pno order by acc.created_at desc ) rn
        from bi_pro.abnormal_customer_complaint acc
        where
            acc.complaints_sub_type = 47
    ) acc on acc.pno = di.pno and acc.rn = 1
left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join dwm.dwd_th_network_spill_detl_rd dt on dt.网点ID = coalesce(pr.store_id, di.store_id) and dt.统计日期 = coalesce(pr.pr_date, di.sdt_date)
left join nl_production.violation_return_visit vrv on di.pno = vrv.link_id
;

case
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
end as '投诉原因'