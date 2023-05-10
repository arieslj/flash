select
    de.pno
    ,pi.cod_amount/100 cod_amount
from dwm.dwd_ex_ph_parcel_details de
left join ph_staging.parcel_info pi on pi.pno = de.pno
where
    de.dst_routed_at < date_sub(curdate(), interval 2 day )
    and de.cod_enabled = 'YES'
    and de.parcel_state not in (5,7,8,9)
;

-- A,C来源
select
    plt.pno 运单号
    ,plt.created_at 任务生成时间
    ,concat('SSRD', plt.id) 任务ID
    ,case plt.vip_enable
        when 0 then '普通客户'
        when 1 then 'KAM客户'
    end 客户类型
    ,plt.client_id 客户ID
    ,pi.cod_amount/100 COD金额
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) '物品价值(cogs)'
    ,ss.short_name 始发地
    ,ss2.short_name  目的地
    ,convert_tz(pi.created_at , '+00:00', '+07:00') 揽件时间
    ,cast(pi.exhibition_weight as double)/1000 '重量'
    ,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) '尺寸'
    ,case pi.parcel_category
        when '0' then '文件'
        when '1' then '干燥食品'
        when '10' then '家居用具'
        when '11' then '水果'
        when '2' then '日用品'
        when '3' then '数码产品'
        when '4' then '衣物'
        when '5' then '书刊'
        when '6' then '汽车配件'
        when '7' then '鞋包'
        when '8' then '体育器材'
        when '9' then '化妆品'
        when '99' then '其它'
    end  as 物品类型
    ,case  plt.last_valid_action
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
    end 最后有效路由
    ,plt.last_valid_routed_at 最后有效路由网点
    ,plt.last_valid_staff_info_id 最后有效路由操作人
    ,ss3.name 最后有效路由网点
    ,case plt.is_abnormal
        when 1 then '是'
        when 0 then '否'
     end 是否异常
    ,group_concat(wo.order_no) 工单编号
    ,'C-包裹状态未更新' 问题来源渠道
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 状态
    ,if(plt.fleet_routeids is null, '一致', '不一致') 解封车是否异常
    ,plt.fleet_stores 异常区间
    ,fvp.van_line_name 异常车线
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.dwd_dim_bigClient bc on bc.client_id = plt.client_id
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join ph_staging.fleet_van_proof fvp on fvp.id = substring_index(plt.fleet_routeids, '/', 1)
left join ph_staging.sys_store ss3 on ss3.id = plt.last_valid_store_id
left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
where
    plt.created_at >= '2023-04-01'
    and plt.source = 1 -- C来源
    and plt.state < 5
group by 3

;





;


with t as
(
    select
        de.pno
        ,pcd.created_at
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on pi.pno = de.pno
    left join ph_staging.parcel_change_detail pcd  on de.pno = pcd.pno
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > pcd.created_at
    where
        pi.dst_store_id in  ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13') -- 目的地网点是拍卖仓
        and pcd.field_name = 'dst_store_id'
        and pcd.new_value = 'PH19040F05'
        and de.parcel_state not in (5,7,8,9)
        and pr.pno is null
)
, b as
(
    select
            a.pno
            ,a.store_name store
            ,'弃件未发出包裹' type
        from
            (
                select
                    pr.pno
                    ,pr.store_name
                    ,row_number() over (partition by pr.pno order by pr.id desc ) rn
                from ph_staging.parcel_route pr
                join t on t.pno = pr.pno
                where
                    pr.store_category is not null
                    and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN')
            ) a
        where
            a.rn = 1


        union

        -- 目的地网点在仓未达终态
        select
            de.pno
            ,de.last_store_name store
            ,'目的地在仓未终态' type
        from dwm.dwd_ex_ph_parcel_details de
        left join ph_staging.parcel_info p2 on p2.pno = de.pno
        where
            de.dst_routed_at is not null
            and p2.state not in (5,7,8,9) -- 未终态，且目的地网点有路由
            and p2.dst_store_id  not in ('PH19040F05', 'PH19040F04', 'PH19040F06', 'PH19040F07', 'PH19280F10', 'PH19280F13')   -- 目的地网点不是拍卖仓,PN5-CS1,2,3,4,5 为拍卖仓

        union
        -- 退件未发出

        select
            de.pno
            ,de.src_store store
            ,'退件未发出包裹' type
        from dwm.dwd_ex_ph_parcel_details de
        join ph_staging.parcel_info pi2 on pi2.pno = de.pno
        where
            de.returned = 1
            and de.last_store_id = de.src_store_id
            and pi2.state not in (2,5,7,8,9)
)
select
    de.pno
    ,oi.src_name 寄件人姓名
    ,oi.src_detail_address 寄件人地址
    ,oi.dst_name 收件人姓名
    ,oi.dst_detail_address 收件人地址
    ,b.type 类型
    ,b.store 当前网点
    ,dp.piece_name 当前网点所属片区
    ,dp.region_name 当前网点所属大区
    ,de.parcel_state_name 当前状态
    ,if(de.returned = 1, '退件', '正向') 流向
    ,if(de.client_id in ('AA0050','AA0121','AA0139','AA0051','AA0080'), oi.insure_declare_value/100, oi.cogs_amount/100) 正向物品价值
    ,oi.cod_amount/100 COD金额
    ,de.pickup_time 揽收时间
    ,de.src_store 揽收网点
    ,dp2.store_name 目的地网点
    ,last_cn_route_action 最后一条有效路由
    ,last_route_time 最后一条有效路由时间
    ,src_piece 揽件网点所属片区
    ,src_region 揽件网点所属大区
    ,de.discard_enabled 是否为丢弃
    ,inventorys 盘库次数
    ,if(pr.pno is null ,'否', '是') 是否有效盘库
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一次盘库时间
from dwm.dwd_ex_ph_parcel_details de
join b on b.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_name = b.store and dp.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.parcel_info pi on pi.pno = de.pno
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_staging.order_info oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
left join
    (
        select
            b.*
        from
            (
                select
                    pr.pno
                    ,pr.routed_at
                    ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
                from ph_staging.parcel_route pr
                join b on b.pno = pr.pno
                where
                    pr.route_action = 'INVENTORY'
                    and pr.routed_at >= date_add(curdate(), interval 8 hour)
            ) b
        where
            b.rn = 1
    ) pr on pr.pno = b.pno
where
    pi.state not in (5,7,8,9)
    and dp.store_category not in (8,12)
#     and pi.pno = 'P61022HXGYAD'
group by 1


