with t as
(
        select
            a1.*
        from
            (
                select
                    a.*
                from
                    (
                        select
                            pi.pno
                            ,pi.returned
                            ,pi.client_id
                            ,pi.state
                            ,pi.ticket_pickup_store_id
                            ,pi.dst_store_id
                            ,pi.customary_pno
                            ,pr.store_name
                            ,pr.store_id
                            ,pi.interrupt_category
                            ,pr.route_action
                            ,pr.routed_at
                            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rk
                        from ph_staging.parcel_info pi
                        left join ph_staging.parcel_route pr on pr.pno = pi.pno
                        where
                            pi.state not in (5,7,8,9)
                            and pi.created_at < date_sub(now(), interval 56 hour)
                            and pi.created_at > date_sub(curdate(), interval 100 day)
                            and pr.routed_at > date_sub(curdate(), interval 120 day)
                            and pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
                    ) a
                where
                    a.rk = 1
            ) a1
        where
            a1.routed_at < date_sub(now(), interval 56 hour)
)
select
    t1.pno
    ,if(t1.returned = 0, '正向', '退件') 包裹流向
    ,t1.client_id
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
    ,ss2.name 揽收网点
    ,case
        when ss2.province_code in ('PH01','PH02','PH03','PH04','PH05','PH06','PH07','PH08','PH09','PH10','PH11','PH12','PH13','PH14','PH15','PH16','PH17','PH18','PH19','PH20','PH21','PH22','PH23','PH24','PH25','PH26','PH27','PH61','PH62','PH63','PH64','PH65','PH66','PH67','PH78','PH79','PH80','PH82') then 'Luzon'
        when ss2.province_code in ('PH44','PH45','PH46','PH47','PH48','PH49','PH50','PH51','PH52','PH53','PH54','PH55','PH56','PH57','PH58','PH59','PH60','PH68','PH69','PH70','PH71','PH72','PH73','PH74','PH75','PH76','PH77','PH83') then 'Mindanao'
        when ss2.province_code in ('PH81') then 'Palawan'
        when ss2.province_code in ('PH28','PH29','PH30','PH31','PH32','PH33','PH34','PH35','PH36','PH37','PH38','PH39','PH40','PH41','PH42','PH43') then 'Visayas'
    end 揽收岛屿
    ,ss3.name 目的地网点
    ,case
        when ss3.province_code in ('PH01','PH02','PH03','PH04','PH05','PH06','PH07','PH08','PH09','PH10','PH11','PH12','PH13','PH14','PH15','PH16','PH17','PH18','PH19','PH20','PH21','PH22','PH23','PH24','PH25','PH26','PH27','PH61','PH62','PH63','PH64','PH65','PH66','PH67','PH78','PH79','PH80','PH82') then 'Luzon'
        when ss3.province_code in ('PH44','PH45','PH46','PH47','PH48','PH49','PH50','PH51','PH52','PH53','PH54','PH55','PH56','PH57','PH58','PH59','PH60','PH68','PH69','PH70','PH71','PH72','PH73','PH74','PH75','PH76','PH77','PH83') then 'Mindanao'
        when ss3.province_code in ('PH81') then 'Palawan'
        when ss3.province_code in ('PH28','PH29','PH30','PH31','PH32','PH33','PH34','PH35','PH36','PH37','PH38','PH39','PH40','PH41','PH42','PH43') then 'Visayas'
    end 目的地岛屿
    ,case a2.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 判责类型
    ,a2.updated_at 判责日期
    ,a3.created_at 最近进入闪速系统时间
#     ,t1.route_action
    ,case t1.route_action # 路由动作
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
    end as 最后一次有效路由操作
    ,t1.store_name 最后一次有效路由网点
    ,convert_tz(ss.routed_at, '+00:00', '+08:00') 到达网点时间
    ,date(convert_tz(t1.routed_at, '+00:00', '+08:00')) 最后一次有效路由时间
    ,timestampdiff(hour, convert_tz(t1.routed_at, '+00:00', '+08:00'), now()) 最近一次有效路由至今小时数
    ,if(t1.returned = 0, dai.delivery_attempt_num, dai.returned_delivery_attempt_num) 尝试派送次数
    ,if(t1.interrupt_category = 3, '是', '否') 是否有待退件标记
    ,case
        when t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139') and curdate() > laz.delievey_end_date then '是'
        when t1.client_id in ('AA0131', 'AA0132') and curdate() > tik.end_date then '是'
        when t1.client_id in ('AA0090', 'AA0128','AA0089') and curdate() > sho.end_date then '是'
        when t1.client_id in ('AA0149', 'AA0148') and curdate() > she.delievey_end_date then '是'
        else null
    end 是否已经超时
    ,case
        when t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139') and curdate() > laz.delievey_end_date then datediff(curdate(), laz.delievey_end_date)
        when t1.client_id in ('AA0131', 'AA0132') and curdate() > tik.end_date then datediff(curdate(), tik.end_date)
        when t1.client_id in ('AA0090', 'AA0128','AA0089') and curdate() > sho.end_date then datediff(curdate(), sho.end_date)
        when t1.client_id in ('AA0149', 'AA0148') and curdate() > she.delievey_end_date then datediff(curdate(), she.delievey_end_date)
        else null
    end  超时天数
    ,if(t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139'), oi.insure_declare_value/100, oi.cogs_amount/100) cogs金额
    ,oi.cod_amount/100 cod金额
from t t1
left join
    (
        select
            plt.pno
            ,plt.updated_at
            ,plt.duty_result
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 6
    ) a2 on a2.pno = t1.pno
left join
    (
        select
            plt.pno
            ,plt.created_at
            ,row_number() over (partition by plt.pno order by plt.created_at desc ) rk
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.created_at > date_sub(curdate(), interval 100 day)
    ) a3 on a3.pno = t1.pno and a3.rk = 1
left join dwm.dwd_ex_ph_lazada_pno_period laz on laz.pno = t1.pno
left join dwm.dwd_ex_shopee_pno_period sho on sho.pno = t1.pno
left join dwm.dwd_ex_ph_tiktok_sla_detail tik on tik.pno = t1.pno
left join dwm.dwd_ex_ph_shein_sla_detail she on she.pno = t1.pno
left join ph_staging.delivery_attempt_info dai on dai.pno = if(t1.returned = 0, t1.pno, t1.customary_pno)
left join
    (
        select
            pr.routed_at
            ,pr.pno
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.store_id
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) ss on ss.pno = t1.pno and ss.rk = 1
left join ph_staging.order_info oi on oi.pno = t1.pno
left join ph_staging.sys_store ss2 on ss2.id = t1.ticket_pickup_store_id
left join ph_staging.sys_store ss3 on ss3.id = t1.dst_store_id


;

with a as
(
    -- lazada
        select
            laz.pno
            ,laz.delievey_end_date end_date
            ,pi.returned
            ,pi.client_id
            ,pi.state
            ,pi.customary_pno
            ,pi.insure_declare_value
            ,pi.ticket_pickup_store_id
            ,pi.dst_store_id
            ,pi.interrupt_category
            ,pi.cod_amount
        from dwm.dwd_ex_ph_lazada_pno_period laz
        join ph_staging.parcel_info pi on pi.pno = laz.pno
        where
            pi.state not in (5,7,8,9)
            and laz.delievey_end_date < curdate()

        union all

        select
            sho.pno
            ,sho.end_date
            ,pi.returned
            ,pi.client_id
            ,pi.state
            ,pi.customary_pno
            ,pi.insure_declare_value
            ,pi.ticket_pickup_store_id
            ,pi.dst_store_id
            ,pi.interrupt_category
            ,pi.cod_amount
        from dwm.dwd_ex_shopee_pno_period sho
        join ph_staging.parcel_info pi on pi.pno = sho.pno
        where
            pi.state not in (5,7,8,9)
            and sho.end_date < curdate()
        -- tiktok
        union all

        select
            tik.pno
            ,tik.end_date
            ,pi.returned
            ,pi.client_id
            ,pi.state
            ,pi.customary_pno
            ,pi.insure_declare_value
            ,pi.ticket_pickup_store_id
            ,pi.dst_store_id
            ,pi.interrupt_category
            ,pi.cod_amount
        from dwm.dwd_ex_ph_tiktok_sla_detail tik
        join ph_staging.parcel_info pi on pi.pno = tik.pno
        where
            pi.state not in (5,7,8,9)
            and tik.end_date < curdate()

        union all
        -- shein
        select
            shein.pno
            ,shein.delievey_end_date
            ,pi.returned
            ,pi.client_id
            ,pi.state
            ,pi.customary_pno
            ,pi.insure_declare_value
            ,pi.ticket_pickup_store_id
            ,pi.dst_store_id
            ,pi.interrupt_category
            ,pi.cod_amount
        from dwm.dwd_ex_ph_shein_sla_detail shein
        join ph_staging.parcel_info pi on pi.pno = shein.pno
        where
            pi.state not in (5,7,8,9)
            and shein.delievey_end_date < curdate()
)
, t as
(
    select
        a1.*
    from
        (
            select
                pr.routed_at
                ,pr.route_action
                ,pr.store_name
                ,pr.store_id
                ,t1.*
                ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from ph_staging.parcel_route pr
            join a t1 on t1.pno = pr.pno
            where
                pr.routed_at > '2023-07-01'
                and pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
        ) a1
    where
        a1.rk = 1
) , inc as
(
    select
        pr4.pno
        ,pr4.id
        ,pr4.routed_at
        ,row_number() over (partition by pr4.pno order by pr4.routed_at desc) rk
    from ph_staging.parcel_route pr4
    join t t1 on t1.pno = pr4.pno
    where
        pr4.routed_at > '2023-07-01'
        and pr4.route_action = 'INCOMING_CALL'
)
select
    t1.pno
    ,if(t1.returned = 0, '正向', '退件') 包裹流向
    ,t1.client_id
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
    ,ss2.name 揽收网点
    ,ss3.name 目的地网点
    ,case a2.duty_result
        when 1 then '丢失'
        when 2 then '破损'
        when 3 then '超时效'
    end 判责类型
    ,a2.updated_at 判责日期
    ,case t1.route_action # 路由动作
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
    end as 最后一次有效路由操作
    ,t1.store_name 最后一次有效路由网点
    ,convert_tz(ss.routed_at, '+00:00', '+08:00') 到达网点时间
    ,date(convert_tz(t1.routed_at, '+00:00', '+08:00')) 最后一次有效路由时间
    ,timestampdiff(hour, convert_tz(t1.routed_at, '+00:00', '+08:00'), now()) 最近一次有效路由至今小时数
    ,if(t1.returned = 0, dai.delivery_attempt_num, dai.returned_delivery_attempt_num) 尝试派送次数
    ,if(t1.interrupt_category = 3, '是', '否') 是否有待退件标记
#     ,case
#         when t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139') and curdate() > t1.end_date then '是'
#         when t1.client_id in ('AA0131', 'AA0132') and curdate() > tik.end_date then '是'
#         when t1.client_id in ('AA0090', 'AA0128','AA0089') and curdate() > sho.end_date then '是'
#         when t1.client_id in ('AA0149', 'AA0148') and curdate() > she.delievey_end_date then '是'
#         else null
#     end 是否已经超时
    ,case
        when t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139') and curdate() > t1.end_date then datediff(curdate(), t1.end_date)
        when t1.client_id in ('AA0131', 'AA0132') and curdate() > t1.end_date then datediff(curdate(), t1.end_date)
        when t1.client_id in ('AA0090', 'AA0128','AA0089') and curdate() > t1.end_date then datediff(curdate(), t1.end_date)
        when t1.client_id in ('AA0149', 'AA0148') and curdate() > t1.end_date then datediff(curdate(), t1.end_date)
        else null
    end  超时天数
    ,if(t1.client_id in ('AA0080', 'AA0050', 'AA0121', 'AA0051', 'AA0139'), oi.insure_declare_value/100, oi.cogs_amount/100) cogs金额
    ,t1.cod_amount/100 cod金额
    ,pho.pho_count 打电话次数
    ,pho.xiangling_count 响铃未通话次数
    ,pho.tonghua_num 有效通话次数
    ,pho.8_tonghua_num 大于8秒通话次数
    ,com.in_count 呼入电话次数
    ,convert_tz(c2.routed_at, '+00:00', '+08:00') 最后一次呼入电话时间
from t t1
left join
    (
        select
            plt.pno
            ,plt.updated_at
            ,plt.duty_result
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 6
            and plt.created_at > '2023-07-01'
    ) a2 on a2.pno = t1.pno
left join ph_staging.delivery_attempt_info dai on dai.pno = if(t1.returned = 0, t1.pno, t1.customary_pno)
left join
    (
        select
            pr.routed_at
            ,pr.pno
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno and pr.store_id = t1.store_id
        where
            pr.routed_at > '2023-07-01'
            and pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
    ) ss on ss.pno = t1.pno and ss.rk = 1
left join ph_staging.order_info oi on oi.pno = t1.pno
left join ph_staging.sys_store ss2 on ss2.id = t1.ticket_pickup_store_id
left join ph_staging.sys_store ss3 on ss3.id = t1.dst_store_id
left join
    (
        select
            a1.pno
            ,count(a1.id) pho_count
            ,count(if(a1.tonghua = 0 and a1.xiangling > 0, a1.id, null)) xiangling_count
            ,count(if(a1.tonghua > 0, a1.id, null)) tonghua_num
            ,count(if(a1.tonghua > 8, a1.id, null)) 8_tonghua_num
        from
            (
                select
                    pr2.pno
                    ,pr2.id
                    ,json_extract(pr2.extra_value, '$.callDuration') tonghua
                    ,json_extract(pr2.extra_value, '$.diaboloDuration') xiangling
                from ph_staging.parcel_route pr2
                join t t1 on pr2.pno = t1.pno
                where
                    pr2.route_action = 'PHONE'
                    and pr2.routed_at >= '2023-07-01'
            ) a1
        group by 1
    ) pho on pho.pno = t1.pno
left join
    (
        select
            c1.pno
            ,count(distinct c1.id) in_count
        from inc c1
        group by 1
    ) com on com.pno = t1.pno
left join inc c2 on c2.pno = t1.pno and c2.rk = 1



;

select
    a.leave_date
    ,count(distinct a.staff_info_id) 离职快递员人数
    ,count(distinct if(a.mw_count > 0, a.staff_info_id, null))/count(distinct a.staff_info_id) 有警告信占比
    ,count(distinct if(a.mw_count = 1, a.staff_info_id, null))/count(distinct a.staff_info_id) 1封警告信占比
    ,count(distinct if(a.mw_count = 2, a.staff_info_id, null))/count(distinct a.staff_info_id) 2封警告信占比
    ,count(distinct if(a.mw_count = 3, a.staff_info_id, null))/count(distinct a.staff_info_id) 3封警告信占比
    ,count(distinct if(a.mw_count > 3, a.staff_info_id, null))/count(distinct a.staff_info_id) 3封以上警告信占比
from
    (
        select
            hsi.leave_date
            ,hsi.staff_info_id
        #     ,count(distinct hsi.staff_info_id) 离职快递员人数
        #     ,count(distinct if(mw.staff_info_id is not null, hsi.staff_info_id, null)) 有警告信占比
            ,count(mw.id) mw_count
        from ph_bi.hr_staff_info hsi
        left join ph_backyard.message_warning mw on mw.staff_info_id = hsi.staff_info_id and mw.is_delete = 0
        where
            hsi.state = 2
            and hsi.job_title in (13,110,1000)
            and hsi.leave_date >= '2023-09-01'
        group by 1,2
    ) a
group by 1
;

select
    t.*

from tmpale.tmp_th_staff_0901 t
jo