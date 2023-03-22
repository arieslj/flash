with t as
(
    select
        hsi.staff_info_id
        ,ss.name ss_name
        ,ss.id ss_id
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    where
        ss.name in ('ABL_SP', 'ABY_SP', 'AGN_SP', 'AGO_SP', 'AGS_SP', 'AMD_SP', 'ANG_SP', 'ART_SP', 'ATQ_SP', 'AUR_SP', 'BAG_SP', 'BAH_SP', 'BAI_SP', 'BAT_SP', 'BAU_SP', 'BAY_SP', 'BCE_SP', 'BCP_SP', 'BCR_SP', 'BGO_SP', 'BGS_SP', 'BLC_SP', 'BLM_SP', 'BLN_SP', 'BLR_SP', 'BMG_SP', 'BOG_SP', 'BOH_SP', 'BTC_SP', 'BTG_SP', 'BUG_SP', 'BUS_SP', 'BYB_SP', 'BYY_SP', 'CAB_SP', 'CAD_SP', 'CAS_SP', 'CBA_SP', 'CBL_SP', 'CBO_SP', 'CBT_SP', 'CBY_SP', 'CDS_SP', 'CLN_SP', 'CLO_SP', 'CLS_SP', 'CMD_SP', 'CPG_SP', 'CUP_SP', 'CYZ_SP', 'DAA_SP', 'DEN_SP', 'DET_SP', 'DLM_SP', 'DMB_SP', 'DMT_SP', 'DOL_SP', 'FLR_SP', 'GAN_SP', 'GAP_SP', 'GAT_SP', 'GBA_SP', 'GOA_SP', 'GUM_SP', 'HOL_SP', 'HOT_SP', 'IBC_SP', 'IFT_SP', 'ILA_SP', 'IRG_SP', 'JUA_SP', 'KAV_SP', 'KBL_SP', 'KLB_SP', 'KLM_SP', 'KLS_SP', 'LAG_SP', 'LAM_SP', 'LAR_SP', 'LAU_SP', 'LBN_SP', 'LBO_SP', 'LBS_SP', 'LEY_SP', 'LGA_SP', 'LGN_SP', 'LGP_SP', 'LLI_SP', 'LMA_SP', 'LPZ_SP', 'LSA_SP', 'LUN_SP', 'LUT_SP', 'MAO_SP', 'MAR_SP', 'MAS_SP', 'MBA_SP', 'MBL_SP', 'MBR_SP', 'MBS_SP', 'MBT_SP', 'MIL_SP', 'MLG_SP', 'MLO_SP', 'MON_SP', 'MOZ_SP', 'MRA_SP', 'MRD_SP', 'MRN_SP', 'MTI_SP', 'MTS_SP', 'MUS_SP', 'NAG_SP', 'NAR_SP', 'NAU_SP', 'NBC_SP', 'NJU_SP', 'NOA_SP', 'NOV_SP', 'NUE_SP', 'OLP_SP', 'OMC_SP', 'PAL_SP', 'PAS_SP', 'PDC_SP', 'PIL_SP', 'PLA_SP', 'PLW_SP', 'PLY_SP', 'PMY_SP', 'PPA_SP', 'PSC_SP', 'PSG_SP', 'PSK_SP', 'PSP_SP', 'PSS_SP', 'PST_SP', 'PUT_SP', 'QUN_SP', 'RBL_SP', 'RIZ_SP', 'ROS_SP', 'ROX_SP', 'RZZ_SP', 'SAN_SP', 'SAY_SP', 'SBG_SP', 'SCZ_SP', 'SDS_SP', 'SEL_SP', 'SJS_SP', 'SMB_SP', 'SML_SP', 'SMN_SP', 'SNA_SP', 'SOL_SP', 'SPB_SP', 'SSG_SP', 'SSP_SP', 'STC_SP', 'STG_SP', 'STS_SP', 'STZ_SP', 'SUB_SP', 'TAA_SP', 'TAB_SP', 'TAL_SP', 'TAN_SP', 'TAU_SP', 'TBC_SP', 'TBK_SP', 'TCL_SP', 'TJY_SP', 'TNA_SP', 'TOO_SP', 'TTB_SP', 'TUA_SP', 'TUG_SP', 'TUM_SP', 'TYZ_SP', 'UDA_SP', 'UDS_SP', 'VZA_SP', 'WAK_SP', 'WTB_SP', 'WTG_SP')
        and hsi.state = 1
        and hsi.job_title in (13,110,1000)  -- 快递员
#         and hsi.staff_info_id = '136400'
)
, total as
(
    select
            date(date_add(pr.routed_at , interval 8 hour)) date_d
            ,'scan' type
            ,t.ss_name
            ,pr.staff_info_id
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join t on pr.staff_info_id = t.staff_info_id
        where
            pr.routed_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' -- 交接扫描
#             and pr.staff_info_id = '136400'
        group by 1,2,3,4

        union all

        select
            date(date_add(pi.finished_at , interval 8 hour)) date_d
            ,'fin' type
            ,t.ss_name
            ,t.staff_info_id
            ,count(distinct pi.pno) num
        from ph_staging.parcel_info pi
        join t on pi.ticket_delivery_staff_info_id = t.staff_info_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(date_sub(curdate(), interval 30 day), interval 8 hour)
            and pi.finished_at < date_sub(curdate(), interval 8 hour)
        group by 1,2,3,4
)
select
    *
from total
select
    a.ss_name 网点
    ,a.staff_info_id 员工ID
    ,sum(scan.num)/count(distinct scan.date_d) 日均交接量
    ,count(distinct scan.date_d) 近30天交接天数
    ,sum(fin.num)/count(distinct fin.date_d) 日均妥投量
    ,count(distinct fin.date_d) 近30天妥投天数
from t a
left join
    (
        select
            total.staff_info_id
            ,total.date_d
            ,total.ss_name
        from total
        group by 1,2,3
    ) t on t.staff_info_id = a.staff_info_id and t.ss_name = a.ss_name
left join total scan on scan.staff_info_id = t.staff_info_id and scan.date_d = t.date_d and scan.type = 'scan'
left join total fin on fin.staff_info_id = t.staff_info_id and fin.date_d = t.date_d and fin.type = 'fin'
group by 1,2

;


--  weichuan 需求

select
    pi.pno
    ,case pi.returned
        when 0 then '正向'
        when 1 then '逆向'
    end 包裹类型
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
    end as 最后一条有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后有效路由时间
    ,date_format(convert_tz(pri.routed_at, '+00:00', '+08:00'), '%Y-%m-%d') 打印面单日期
    ,date_format(convert_tz(pri.routed_at, '+00:00', '+08:00'), '%H:%i:%s') 打印面单时间
    ,pi.client_id 包裹客户ID
    ,if(ss.pno is not null , '是', '否') 是否有申诉记录
    ,plt.staff
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0321 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on t.pno = pr.pno
        where  -- 最后有效路由
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = pi.pno and pr.rn = 1
left join
    (
        select
            plt.pno
            ,group_concat(plr.staff_id) staff
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno
        left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
        group by 1
    ) plt on plt.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on t.pno = pr.pno
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = pi.pno and pri.rn = 1
left join
    (
        select
            am.pno
        from ph_bi.abnormal_message am
        join tmpale.tmp_ph_pno_0321 t on am.pno = t.pno
        where
            am.isappeal in (2,3,4,5)
            and am.state = 1
        group by 1
    ) ss on ss.pno = pi.pno
;