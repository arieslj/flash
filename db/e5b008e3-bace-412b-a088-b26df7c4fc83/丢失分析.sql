SELECT
    plt.pno
    ,plt.created_at
    ,plt.updated_at
    ,case
    when bc.client_id is not null then bc.client_name
    when kp.id is not null and bc.client_id is null then '普通ka'
    when kp.id is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,case pi2.article_category
         when 0 then '文件'
         when 1 then '干燥食品'
         when 2 then '日用品'
         when 3 then '数码产品'
         when 4 then '衣物'
         when 5 then '书刊'
         when 6 then '汽车配件'
         when 7 then '鞋包'
         when 8 then '体育器材'
         when 9 then '化妆品'
         when 10 then '家居用具'
         when 11 then '水果'
         when 99 then '其它'
        end as 物品类型
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 cod金额
    ,if(pi2.cod_enabled = 1, 'y')
    ,case plt.last_valid_action
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
        end as  最后一个有效路由
    ,ss.name 丢失包裹所在网点
    ,case
        when ss.category=1 then 'SP'
        when ss.category=2 then 'DC'
        when ss.category=4 then 'SHOP'
        when ss.category=5 then 'SHOP'
        when ss.category=6 then 'FH'
        when ss.category=7 then 'SHOP'
        when ss.category=8 then 'Hub'
        when ss.category=9 then 'Onsite'
        when ss.category=10 then 'BDC'
        when ss.category=11 then 'fulfillment'
        when ss.category=12 then 'B-HUB'
        when ss.category=13 then 'CDC'
        when ss.category=14 then 'PDC'
    end 网点类型
    ,plt.last_valid_staff_info_id 最后操作快递员
    ,case plt.source
        WHEN 1 THEN 'A-问题件-丢失'
        WHEN 2 THEN 'B-记录本-丢失'
        WHEN 3 THEN 'C-包裹状态未更新'
        WHEN 4 THEN 'D-问题件-破损/短少'
        WHEN 5 THEN 'E-记录本-索赔-丢失'
        WHEN 6 THEN 'F-记录本-索赔-破损/短少'
        WHEN 7 THEN 'G-记录本-索赔-其他'
        WHEN 8 THEN 'H-包裹状态未更新-IPC计数'
        WHEN 9 THEN 'I-问题件-外包装破损险'
        WHEN 10 THEN 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end '来源'
    ,case plt.duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓7主3套餐(仓管70%主管30%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 21 then '仓7主3套餐(仓管70%主管30%)'
    end 套餐
    ,t.t_value 原因
from ph_bi.parcel_lose_task plt
left join ph_staging.sys_store ss on plt.last_valid_store_id =ss.id
left join ph_drds.lazada_order_info_d loi on plt.pno=loi.pno
left join ph_staging.order_info oi on plt.pno=oi.pno
left join dwm.dwd_dim_bigClient bc on oi.client_id=bc.client_id
left join ph_staging.ka_profile kp on oi.client_id=kp.id
left join ph_staging.parcel_info pi2 on plt.pno=pi2.pno
left join ph_bi.translations t on plt.duty_reasons=t.t_key
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
    and t.lang = 'zh-CN'

;


-- 责任均摊逻辑

select
    plr.store_id
    ,ss.name 网点
    ,count(plt.id) 技术
from ph_bi.parcel_lose_task plt
left join
    (
        select
            plr.lose_task_id
            ,plr.store_id
        from ph_bi.parcel_lose_responsible plr
        where
            plr.created_at >= '2023-03-01'
        group by 1,2
    ) plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2
order by 3 desc


;

with t as
(
   select
       a.*
   from
       (
            select
                plt.pno
                ,plr.store_id
                ,plt.id
                ,pr.routed_at
                ,row_number() over (partition by plt.id order by pr.routed_at desc ) rk
            from ph_bi.parcel_lose_task plt
            join
                (
                    select
                        plr.lose_task_id
                        ,plr.store_id
                    from ph_bi.parcel_lose_responsible plr
                    where
                        plr.created_at >= '2023-03-01'
                        and plr.store_id in ('PH19280F01', 'PH61182U01', 'PH14010F00', 'PH19280400', 'PH61270401', 'PH61180400', 'PH14010400', 'PH18180200', 'PH14160300', 'PH52050800', 'PH74060200', 'PH18060200', 'PH18040100', 'PH14200300', 'PH21130100', 'PH61184403', 'PH64021N00', 'PH51050301', 'PH21020301')
                    group by 1,2
                ) plr on plr.lose_task_id = plt.id
            left join ph_staging.parcel_route pr on pr.pno = plt.pno and pr.routed_at < date_sub(plt.created_at, interval 8 hour)
            where
                plt.state = 6
                and plt.duty_result = 1
                and plt.created_at >= '2023-03-01'
                and plt.created_at < '2023-04-27'
       ) a
   where
       a.rk = 1
   group by 1,2,3,4,5
)
select
    t.store_id
    ,ss.short_name
    ,date(convert_tz(t.routed_at, '+00:00', '+08:00')) date_d
    ,t.id
    ,t.pno
from t
left join ph_staging.sys_store ss on ss.id = t.store_id

;

select
    case
        when bc.client_id is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.id is null then '小c'
    end as  客户
    ,if(pi.cod_enabled = 1, 'COD', '非COD') 是否COD
    ,count(plt.id)
from ph_bi.parcel_lose_task plt
left join ph_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.dwd_dim_bigClient bc on pi.client_id=bc.client_id
left join ph_staging.ka_profile kp on pi.client_id=kp.id
where
     plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2

;

-- 责任均摊逻辑

select
    plr.store_id
    ,ss.name 网点
    ,plr.staff_id
    ,case
        when  hsi.`state`=1 and hsi.`wait_leave_state` =0 then '在职'
        when  hsi.`state`=1 and hsi.`wait_leave_state` =1 then '待离职'
        when hsi.`state` =2 then '离职'
        when hsi.`state` =3 then '停职'
    end 在职状态
#     ,sum(plr.duty_ratio)/100 jishu
    ,count(plt.id) jishu
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
left join ph_staging.sys_store ss on ss.id = plr.store_id
left join ph_backyard.hr_staff_info hsi on hsi.staff_info_id = plr.staff_id
where
    plt.state = 6
    and plt.duty_result = 1
    and plt.created_at >= '2023-03-01'
    and plt.created_at < '2023-04-27'
group by 1,2,3,4
order by 5 desc

;

select
    hsi.staff_info_id
    ,hjt.job_name
from ph_bi.hr_staff_info hsi
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
where
    hsi.staff_info_id in ('122045', '123109', '136875', '131888', '126146', '135814', '139915', '126295', '121862', '139548', '146160', '126298', '124824', '138330', '133128', '138072', '132653', '131546', '134129', '126554', '139332', '138177', '138416', '135259', '125453', '137715', '134042', '133699', '134773', '134040', '137721', '126308', '136759', '124969', '136043', '136435', '132455', '124821', '138385', '145375', '140081', '139920', '136217', '125133', '140921', '124968', '140079', '124840')
