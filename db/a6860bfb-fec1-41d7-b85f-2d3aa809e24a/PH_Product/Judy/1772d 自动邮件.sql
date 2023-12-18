/*
  =====================================================================+
  表名称：1772d_ph_over_sla_delivery_parcel_info
  功能描述：超派送时效继续派送包裹明细

  需求来源：
  编写人员: 吕杰
  设计日期：2023-09-27
  修改日期:
  修改人员:
  修改原因:
  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
  +=====================================================================
*/

with a as
(
    -- lazada
        select
            laz.pno
            ,laz.whole_end_date end_date
            ,pi.returned
            ,pi.client_id
            ,pi.state
            ,pi.customary_pno
            ,pi.insure_declare_value
            ,pi.ticket_pickup_store_id
            ,pi.dst_store_id
            ,pi.interrupt_category
            ,pi.cod_amount
            ,pi.created_at
        from dwm.dwd_ex_ph_lazada_sla_detail laz
        join ph_staging.parcel_info pi on pi.pno = laz.pno and pi.created_at > date_sub(curdate(), interval 50 day )
        where
            pi.state not in (5,7,8,9)
            and pi.client_id in ('AA0051','AA0139','AA0050','AA0080','AA0121') -- lazada
            and laz.delievey_end_date < curdate()
            and laz.pick_date > date_sub(curdate(), interval 50 day )

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
            ,pi.created_at
        from dwm.dwd_ex_shopee_lost_pno_period sho
        join ph_staging.parcel_info pi on pi.pno = sho.pno and pi.created_at > date_sub(curdate(), interval 50 day )
        where
            pi.state not in (5,7,8,9)
            and pi.client_id in ('AA0128','AA0089','AA0090') -- shopee
            and sho.end_date < curdate()
            and sho.pick_date > date_sub(curdate(), interval 50 day )
        -- tiktok
        union all

        select
            pi.pno
            ,if(pi.returned = 0 ,tik.end_7_date, tik2.end_7_plus_date) end_date
            ,pi.returned
            ,pi.client_id
            ,pi.state
            ,pi.customary_pno
            ,pi.insure_declare_value
            ,pi.ticket_pickup_store_id
            ,pi.dst_store_id
            ,pi.interrupt_category
            ,pi.cod_amount
            ,pi.created_at
        from  ph_staging.parcel_info pi
        left join dwm.dwd_ex_ph_tiktok_sla_detail tik on pi.pno = tik.pno
        left join dwm.dwd_ex_ph_tiktok_sla_detail tik2 on pi.customary_pno = tik2.pno
        where
            pi.state not in (5,7,8,9)
            and pi.client_id in ('AA0132','AA0131')
            and tik.end_date < curdate()
            and tik.pick_date > date_sub(curdate(), interval 50 day )
            and pi.created_at > date_sub(curdate(), interval 50 day )

        union all
        -- shein
        select
            shein.pno
            ,shein.whole_end_date end_date
            ,pi.returned
            ,pi.client_id
            ,pi.state
            ,pi.customary_pno
            ,pi.insure_declare_value
            ,pi.ticket_pickup_store_id
            ,pi.dst_store_id
            ,pi.interrupt_category
            ,pi.cod_amount
            ,pi.created_at
        from dwm.dwd_ex_ph_shein_sla_detail shein
        join ph_staging.parcel_info pi on pi.pno = shein.pno and pi.created_at > date_sub(curdate(), interval 50 day )
        where
            pi.state not in (5,7,8,9)
            and pi.client_id in ('AA0148','AA0149')
            and shein.delievey_end_date < curdate()
            and shein.pick_date > date_sub(curdate(), interval 50 day )
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
                pr.routed_at > date_sub(curdate(), interval 50 day )
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
        pr4.routed_at > date_sub(curdate(), interval 50 day )
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
            and plt.created_at > date_sub(curdate(), interval 50 day )
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
            pr.routed_at > date_sub(curdate(), interval 50 day )
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
                    and pr2.routed_at >= date_sub(curdate(), interval 50 day )
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
