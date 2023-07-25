with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.cod_enabled
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-06-28 16:00:00'
        and pi.state not in (5,7,8,9)
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
#     ,case
#         when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
#         when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
#         when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
#         when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
#         when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
#         when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
#         when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
#         else null
#     end 卡点原因
#     ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,pr.store_name 最后有效路由动作网点
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,de.src_store 揽收网点
    ,de.pickup_time 揽收时间
    ,de.pick_date 揽收日期
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
    ,if(pr3.pno is not null, 'yes', 'no') 是否有待退件标记
    ,td.try_num 尝试派送次数
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
            and pr.organization_type = 1
        ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
left join
    (
        select
            pr2.pno
        from  ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'PENDING_RETURN'
        group by 1
    ) pr3 on pr3.pno = t1.pno
left join
    (
        select
            td.pno
            ,count(distinct date(convert_tz(tdm.created_at, '+00:00', '+08:00'))) try_num
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1
    ) td on td.pno = t1.pno
group by t1.pno

    ;
# select
#     di.pno
#     ,cdt.*
# from ph_staging.diff_info di
# left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
# where
#     di.pno = 'P2206126FUVAL'
;
#
# select
#     t.*
#     ,pi.src_phone
#     ,pi.src_name
#     ,pi.dst_phone
#     ,pi.dst_name
#     ,fp.id
#     ,fp.name
# from ph_staging.parcel_info pi
# join tmpale.tmp_ph_pno_0621 t on t.pno = pi.pno
# left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
# left join ph_staging.franchisee_profile fp on fp.id = ss.franchisee_id
#
#
# ;
# select
#     pcd.field_name
# from ph_staging.parcel_change_detail pcd
# group by 1