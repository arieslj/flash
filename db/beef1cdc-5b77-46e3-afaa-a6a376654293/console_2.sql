select
    a.pno
    ,case a.cod_enabled
        when '0' then '否'
        when '1' then '是'
    end `是否COD`
    ,case
        when bc.client_id is null and kp.id is null then '小C'
        when bc.client_id is null and kp.id is not null then '普通KA'
        when bc.client_id is not null  then bc.custom_name
    end `客户类型`
    ,b.routed_at `最后一次到件扫描时间`
    ,ss.name `最后一次到件扫描网点`
from
    (
        select
            pi.*
        from
            (
                select
                    pi.pno
                    ,pi.cod_enabled
                    ,pi.client_id
                from fle_dwd.dwd_fle_parcel_info_di pi
                where
                    pi.p_date >= '2022-10-01'
            ) pi
        join
            (
                select
                    *
                from test.tmp_th_pno_ciwei_0319
            ) t on t.pno = pi.pno
    ) a
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from
                    (
                        select
                            pr.pno
                            ,pr.store_id
                            ,pr.routed_at
                        from fle_dwd.dwd_rot_parcel_route_di pr
                        where
                            pr.p_date >= '2022-10-01'
                            and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                    ) pr
                join
                    (
                        select
                            *
                        from test.tmp_th_pno_ciwei_0319
                    ) t on t.pno = pr.pno
            ) b
        where
            b.rn = 1
    )  b on b.pno = a.pno
left join
    (
        select
            *
        from fle_dim.dim_fle_ka_profile_da kp
        where
            kp.p_date = date_sub(current_date(), 1)
    ) kp on kp.id = a.client_id
left join
    (
        select
            *
        from fle_dim.dim_csv_big_client_conf_info bc
    ) bc on bc.client_id = a.client_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(current_date(), 1)
    ) ss on ss.id = b.store_id
;

select
    a.pno
    ,a.cod_am
from
    (
        select
            pi.pno
            ,pi.cod_amount/100 cod_am
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-01-01'
    ) a
join
    (
        select
            *
        from test.tmp_th_pno_zjq_0319 t
        group by 1
    ) b on a.pno = b.pno



































;


select
    pi.pno
    ,pi.created_at
from
    (
        select
            plt.pno
            ,plt.updated_at
        from fle_dwd.dwd_bi_parcel_lose_task_di plt
        where
            plt.p_date >= '2022-01-01'
            and plt.state = '6'
        group by 1
    ) plt
left join
    (
        select
            pi.pno
            ,pi.finished_at
            ,pi.created_at
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2022-01-01'
            and pi.state = 5
    ) pi on pi.pno = plt.pno
where
    plt.updated_at < pi.finished_at
group by 1,2


;

select
    a.pno
    ,case a.route_action
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
    end as `最后一条路由`
from
    (
        select
            t.pno
            ,pr.route_action
            ,row_number() over (partition by t.pno order by pr.routed_at desc ) rk
        from
            (
                select
                    pr.pno
                    ,pr.route_action
                    ,pr.routed_at
                from fle_dwd.dwd_rot_parcel_route_di pr
                where
                    pr.p_date >= '2022-10-01'
            ) pr
        join
            (
                select
                    *
                from test.pno_date_0509 t
                where
                    t.created_at >= '2022-10-01'
            ) t on t.pno = pr.pno
    ) a
where
    a.rk = 1

;






select
    a2.pno
    ,a2.updated_at `判责时间`
    ,a2.routed_at `路由时间`
    ,case a2.route_action
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
    end as `最近一条有效路由`
from
    (
        select
            a.pno
            ,a.updated_at
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by a.pno order by pr.routed_at) rk
        from
            (
                select
                    plt.pno
                    ,plt.updated_at
                from
                    (
                        select
                            plt.pno
                            ,plt.updated_at
                        from fle_dwd.dwd_bi_parcel_lose_task_di plt
                        where
                            plt.p_date >= '2023-01-01'
                            and plt.state = '6'
                            and plt.penalties > '0'
                    ) plt
                join test.pno_date_0509_v1 t on t.pno = plt.pno
                group by 1,2
            ) a
        left join
            (
                select
                    pr.*
                from
                    (
                        select
                            pr.pno
                            ,pr.routed_at
                            ,pr.route_action
                        from fle_dwd.dwd_rot_parcel_route_di pr
                        where
                            pr.p_date >= '2023-01-01'  -- 有效路由
                            and pr.route_action in ('RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
                    ) pr
                join test.pno_date_0509_v1 t on t.pno = pr.pno
            ) pr on pr.pno = a.pno
        where
            pr.routed_at > a.updated_at
    ) a2
where
    a2.rk = 1
    and a2.routed_at < hours_add(a2.updated_at, 24)
;

with pr as
(
    select
        pr.*
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.route_action
            from fle_dwd.dwd_rot_parcel_route_di pr
            where
                pr.p_date >= '2023-01-01'  -- 有效路由
                and pr.route_action in ('RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
        ) pr
    join test.pno_date_0509_v1 t on t.pno = pr.pno
)
select
    a1.pno
    ,a1.updated_at `判责时间`
    ,a1.routed_at `判责后最近一条有效路由时间`
    ,case a1.route_action
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
    end as `最近一条有效路由`
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
    ,`if`(pi.dst_store_id = pi.ticket_delivery_store_id, 'yes',  'no') `是否目的网点妥投`
from
    (
        select
            a2.pno
            ,a2.updated_at
            ,a2.routed_at
            ,a2.route_action
        from
            (
                select
                    a.pno
                    ,a.updated_at
                    ,pr.route_action
                    ,pr.routed_at
                    ,row_number() over (partition by a.pno order by pr.routed_at) rk
                from
                    (
                        select
                            plt.pno
                            ,plt.updated_at
                        from
                            (
                                select
                                    plt.pno
                                    ,plt.updated_at
                                from fle_dwd.dwd_bi_parcel_lose_task_di plt
                                where
                                    plt.p_date >= '2023-01-01'
                                    and plt.state = '6'
                                    and plt.penalties > '0'
                            ) plt
                        join test.pno_date_0509_v1 t on t.pno = plt.pno
                        group by 1,2
                    ) a
                left join pr on pr.pno = a.pno
                where
                    pr.routed_at > a.updated_at
            ) a2
        where
            a2.rk = 1
    ) a1
left join
    (
        select
            pi.pno
            ,pi.state
            ,pi.dst_store_id
            ,pi.ticket_delivery_store_id
        from
            (
                select
                    pi.pno
                    ,pi.state
                    ,pi.dst_store_id
                    ,pi.ticket_delivery_store_id
                from fle_dwd.dwd_fle_parcel_info_di pi
                where
                    pi.p_date >= '2023-01-01'
            ) pi
        join test.pno_date_0509_v1 t on t.pno = pi.pno
    ) pi on pi.pno = a1.pno
